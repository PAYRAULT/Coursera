open Hashtbl
open Cryptokit
open Unix


type file_authen =
  {
    filename : string;  (* filename of the log file *)
    mac : string;       (* Mac of the log file *)
    iv : string;        (* IV for the AES encryption of the file *)
  }

(* the log database file *)
let log_db_name = (Sys.getenv "HOME")^"/.logdb";;

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
  |  Entropy_source_closed ->   print_string( "Entropy_source_closed\n")
  | Compression_not_supported ->  print_string( "Compression_not_supported\n")
;;

(* Load the log db in memeory or create one if file not existing *)
let load_logfile () =
  try
    if( Sys.file_exists log_db_name ) then
      begin
      (* Load the log database file *)
	let in_ch = open_in_bin log_db_name in
	let log_db = input_value in_ch in
	close_in in_ch;
	log_db
      end
    else
      begin
	(* Log database file does not exist, create a new log db *)
	Hashtbl.create 97
      end
  with
  | e -> raise e
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

(* Udate the log database *)
let update_logdb logdb logname key =
  let hkey = sha3_224 key in
  let hash = hmac logname hkey in
  try
    let elem = Hashtbl.find logdb logname in
    let nelem = {
      filename = elem.filename;
      mac = hash;
      iv = elem.iv
    } in
    replace logdb logname nelem
  with
  | Not_found ->
    let nelem = {
      filename = logname;
      mac = hash;
      iv = "0";
    } in
    add logdb logname nelem    
  | e -> raise e
;;

let check_integrity logname key app =
  try
    if( Sys.file_exists log_db_name ) then
      begin
	(* Load the log database file *)
	let in_ch = open_in_bin log_db_name in
	let logdb = input_value in_ch in
	close_in in_ch;
	try
	  let elem = Hashtbl.find logdb logname in
	  let hkey = sha3_224 key in
	  let hash = hmac logname hkey in
	  if(elem.mac = hash) then
	    true
	  else
	    false
	with
	| Not_found ->
	(* if logappend make the call and the logname doesn't exist,
	   first time, no integrity check *)
	  app
	| e -> raise e
      end
    else
      (* if logappend make the call and log database file does not exist, *)
      (* no integrity check *)
      app
  with
  | e -> raise e
;;


let encrypt tk fic_in fic_out =
  let k = sha256 tk in
  let arcfour = Cipher.arcfour k Cipher.Encrypt in
  try
    Cryptokit.transform_channel arcfour fic_in fic_out;
  with
  | Cryptokit.Error(e) ->  print_error e;
;;

let decrypt tk fic_in fic_out =
  let k = sha256 tk in
  let arcfour = Cipher.arcfour k Cipher.Decrypt in
  transform_channel arcfour fic_in fic_out
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


let decrypt_log_file token name =
  let tname = Filename.temp_file "a-" ".out" in
  let in_ch = open_in name in
  let out_ch = open_out tname in

  decrypt token in_ch out_ch;

  close_in in_ch;
  close_out out_ch;
  
  let in_ch = open_in_bin tname in
  let log = input_value in_ch in
  close_in in_ch;

  secure_erase tname;
  log
;;


let encrypt_log_file name token log =
  let tname = Filename.temp_file "a-" ".out" in

  let out_ch = open_out_bin tname in
  output_value out_ch log;
  close_out out_ch;
  
  let in_ch = open_in tname in
  let out_ch = open_out name in

  encrypt token in_ch out_ch;

  close_in in_ch;
  close_out out_ch;

  secure_erase tname
;;


let load_authen_file token name =
  decrypt_log_file token name
;;
  
let write_authen_file name token log =
  encrypt_log_file name token log
;;
