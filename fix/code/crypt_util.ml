open Hashtbl
open Cryptokit
open Unix
open Rand

type file_authen =
  {
    filename : string;    (* filename of the log file *)
    mac : string option;  (* Mac of the log file *)
    iv : int;             (* IV for the AES encryption of the file *)
  }
;;

(* the log database file *)
let log_db_name = ".logdb";;

(* Error message from the cryto library *)
let print_error e =
  match e with
  | Wrong_key_size -> print_string("Wrong_key_size\n")
  | Wrong_IV_size -> print_string( "Wrong_IV_size\n")
  | Wrong_data_length ->  print_string( "Wrong_data_length\n")
  | Bad_padding -> print_string( "Bad_padding\n")
  | Output_buffer_overflow ->   print_string( "Output_buffer_overflow\n")
  | Incompatible_block_size ->   print_string( "Incompatible_block_size\n")
  | Number_too_long ->  print_string( "Number_too_long\n")
  | Seed_too_short ->  print_string( "Seed_too_short\n")
  | Message_too_long ->   print_string( "Message_too_long\n")
  | Bad_encoding  ->  print_string( "Bad_encoding\n")
  | Compression_error(s1, s2) ->  print_string( "Compression_error( "^s1^", "^s2^")\n")
  | No_entropy_source ->  print_string( "No_entropy_source\n")
  | Entropy_source_closed ->   print_string( "Entropy_source_closed\n")
  | Compression_not_supported ->  print_string( "Compression_not_supported\n")
;;

let print_logdb db =
  let print_db f e =
    print_string("filename : "^f^"\n");
    print_string("filename : "^e.filename^"\n");
    print_string("iv       : "^(string_of_int e.iv)^"\n");
  in
  Hashtbl.iter print_db db
;;


(* Load the log db in memory or create one if file not existing *)
let load_logfile app =
  if( Sys.file_exists log_db_name ) then
    begin
      (* Load the log database file *)
      let in_ch = open_in_bin log_db_name in
      let log_db = input_value in_ch in
      close_in in_ch;
      log_db
    end
  else
    if( app ) then
      (* Log database file does not exist, create a new log db *)
      Hashtbl.create 97
    else
      failwith("log database inexisting.")
;;

(* Write the log database on disk *)
let write_logfile logdb =
  try
    let out_ch = open_out_bin log_db_name in
    output_value out_ch logdb;
    close_out out_ch;
  with
  | e -> raise e
;;

(* Hmac function *)
let hmac filename key =
  let in_ch = open_in filename in
  let hash = (MAC.hmac_md5 key) in
  let res = hash_channel hash in_ch in
  close_in in_ch;
  res
;;

(* Hash sha256 the token string to have a true random key and the same key length whatever the token is *)
let sha256 s =
  let h = hash_string (Hash.sha256()) s in
  h
;;

(* Hash the token string to have a true random key and the same key length whatever the token is *)
let sha3_224 s =
  let h = hash_string (Hash.sha3 224) s in
  h
;;

let generate_iv logdb log_file_name iv =
  try
    let e = Hashtbl.find logdb log_file_name in
    let niv = e.iv + 1 in
    niv
  with
  | Not_found ->
    iv
  | e ->
    raise e
;;

let find_iv logdb log_file_name =
  try
    let e = Hashtbl.find logdb log_file_name in
    e.iv
  with
  | Not_found ->
    rand()
  | e ->
    raise e
;;

let find_log_info logdb log_file_name =
  try
    Hashtbl.find logdb log_file_name
  with
  | Not_found ->
    {
      filename = log_file_name;
      iv = rand();
      mac = None;
    }
  | e ->
    raise e
;;


(* Udate the log database *)
let update_logdb logdb logname key iv =
  let hkey = sha3_224 key in
  let hash = hmac logname hkey in
  try
    let elem = Hashtbl.find logdb logname in
    let nelem = {
      filename = elem.filename;
      mac = Some(hash);
      iv = iv
    } in
    replace logdb logname nelem
  with
  | Not_found ->
    let nelem = {
      filename = logname;
      mac = Some(hash);
      iv = iv;
    } in
    add logdb logname nelem    
  | e -> raise e
;;

let check_integrity loginfo logname key app =
  match loginfo.mac with
  | Some(mac) ->
    let hkey = sha3_224 key in
    let hash = hmac logname hkey in
    if(mac = hash) then
      begin
	true
      end
    else
      begin
	false
      end
  | None ->
      (* if logappend make the call and the logname doesn't exist,
	 first time, no integrity check *)
    app
;;


let encrypt tk iv fic_in fic_out =
  try
    let k = sha256 tk in
    let kiv = String.sub (sha256 (string_of_int iv)) 0 16 in 
    let aes = Cipher.aes k Cipher.Encrypt ?pad:(Some(Padding._8000))
      ?iv:(Some(kiv)) in
    Cryptokit.transform_channel aes fic_in fic_out;
  with
  | Cryptokit.Error(e) ->  print_error e;
;;

let decrypt tk iv fic_in fic_out =
  try
    let k = sha256 tk in
    let kiv = String.sub (sha256 (string_of_int iv)) 0 16 in
    let aes = Cipher.aes k Cipher.Decrypt ?pad:(Some(Padding._8000))
      ?iv:(Some(kiv)) in
    transform_channel aes fic_in fic_out
  with
  | Cryptokit.Error(e) ->  print_error e;
;;

(* Securely erase the temporay file with random values *)
let secure_erase name =
  let out_desc = Unix.openfile name [O_WRONLY; O_APPEND] 0o600 in
  let fsize = lseek out_desc 0 SEEK_END in
  let _ = lseek out_desc 0 SEEK_SET in
  let nb = (fsize / 10) + 1 in
  for j = 1 to 10 do
    let _ = lseek out_desc 0 SEEK_SET in
    for i = 1 to nb do
      let s = "1234567890" in
      let _ = Unix.write out_desc s 0 10 in
      ()
    done;
    ()
  done;
  Unix.close out_desc;
  Unix.unlink name;
;;


let decrypt_log_file token iv name =
  let tname = Filename.temp_file "a-" ".out" in
  let in_ch = open_in name in
  let out_ch = open_out tname in

  decrypt token iv in_ch out_ch;

  close_in in_ch;
  close_out out_ch;
  
  let in_ch = open_in_bin tname in
  let log = input_value in_ch in
  close_in in_ch;

  secure_erase tname;
  log
;;


let encrypt_log_file name token iv log =
  let tname = Filename.temp_file "a-" ".out" in

  let out_ch = open_out_bin tname in
  output_value out_ch log;
  close_out out_ch;
  
  let in_ch = open_in tname in
  let out_ch = open_out name in

  encrypt token iv in_ch out_ch;

  close_in in_ch;
  close_out out_ch;

  secure_erase tname
;;


let load_authen_file token iv name =
  decrypt_log_file token iv name
;;
  
let write_authen_file name token iv log =
  encrypt_log_file name token iv log
;;
