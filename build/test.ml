open Cryptokit
open Unix

let sha256 s =
  let h = hash_string (Hash.sha256()) s in
  h
;;
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


let encrypt key fic_in fic_out =
  print_string("Encrypt\n");

  let in_ch = open_in fic_in in
  let out_ch = open_out fic_out in
  
  let k = sha256 key in
  let arcfour = Cipher.arcfour k Cipher.Encrypt in
  try
    Cryptokit.transform_channel arcfour in_ch out_ch;

    close_in in_ch;
    close_out out_ch;
  with
  | Cryptokit.Error(e) ->
    begin
      print_error e;
      close_in in_ch;
      close_out out_ch;
    end
;;


let decrypt key fic_in fic_out =
  print_string("Decrypt\n");
  
  let in_ch = open_in fic_in in
  let out_ch = open_out fic_out in
  
  let k = sha256 key in
  let arcfour = Cipher.arcfour k Cipher.Decrypt in
  transform_channel arcfour in_ch out_ch;

  close_in in_ch;
  close_out out_ch;
 
;;


let hmac filename key =
  let in_ch = open_in filename in
  let hash = (MAC.hmac_md5 key) in
  hash_channel hash in_ch
;;

let secure_erase name =
  let out_desc = Unix.openfile name [O_WRONLY; O_APPEND] 0o600 in
  let fsize = lseek out_desc 0 SEEK_END in
  let _ = lseek out_desc 0 SEEK_SET in
  let nb = (fsize / 128) + 1 in
  print_string ("fsize : "^(string_of_int fsize)^"  :  "^(string_of_int nb)^"\n");
  for j = 1 to 10 do
    let _ = lseek out_desc 0 SEEK_SET in
    for i = 1 to nb do

      let s = Random.string Random.secure_rng 128 in
(*
      let _ = Unix.write out_desc s 0 128 in
*)
      ()
    done
  done;
  Unix.close out_desc;
  Unix.unlink name;
;;

encrypt "1234567891011" "fic_p.txt" "fic_c.aes";;
decrypt "1234567891011" "fic_c.aes" "fic2_p.txt";;

print_string((transform_string (Hexa.encode()) (hmac "fic_p.txt" "1234567891010"))^"\n");;

secure_erase "fic_c.aes";
