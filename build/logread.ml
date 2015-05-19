open Crypt_util
open Gallery

exception Integrity_error ;;

let set_room = ref false;;
let set_time = ref false;;
let set_opt_s = ref false;;
let token = ref "";;
let log_file_name = ref "";;
let employee = ref "";;
let guest = ref "";;

let ouex a b = (a&&(not b))||((not a)&&b);;

let usage_msg = "usage :\n"^
  "logread -K <token> -S <log>\n"^
  "logread -K <token> -R (-E <name> | -G <name>) <log>\n"^
  "logread -K <token> -T (-E <name> | -G <name>) <log>\n"^
  "logread -K <token> -I (-E <name> | -G <name>) [(-E <name> | -G <name>) ...] <log>";; 

(* Set the token number *)
let set_token tk =
  if(!token = "") then
    begin
      check_token tk;
      token := tk;
    end
  else
    begin
      print_string usage_msg;
      failwith("Option -K called twice.");
    end
;;

(* Set name of the log file *)
let set_log_file_name f =
  if(!log_file_name = "") then
    begin
      check_filename f;
      log_file_name := f;
    end
  else
    begin
      print_string usage_msg;
      failwith("Option -S called twice or called with a extra file name.");
    end
;;

(* Set log file name and the option type (-S or not) *)
let set_log_file_name_opt s f =
  set_opt_s := s;
  set_log_file_name f
;;

(* Set employee name *)
let set_employee emp =
  if(!employee = "") then
    begin
      check_name emp;
      employee := emp;
    end
  else
    begin
      print_string usage_msg;
      failwith("Option -E called twice.");
    end
;;  

(* Set guest name *)
let set_guest gu =
  if(!guest = "") then
    begin
      check_name gu;
      guest := gu;
    end
  else
    begin
      print_string usage_msg;
      failwith("Option -G called twice.");
    end
;;  

(* For unimplemented features *)
let unimplemented() =
  print_endline ("unimplemented");
  exit 0
;;

(* Check the consistency of the arguments *)
let check_arg() =
  if(!token = "" || !log_file_name = "") then
    begin
      print_string usage_msg;
      failwith("Options -K, -T and logfile are mandatory");     
    end
  else if(!set_room) then
    if(not(ouex (!guest = "") (!employee = ""))) then
      begin
	print_string usage_msg;
	failwith("Options -E and -G are exclusive and at least once should be called");
      end
    else if(!set_opt_s) then
      begin
	print_string usage_msg;
	failwith("Options -R and -S are exclusive");
      end
    else
      ()
  else if(!set_time) then
    if(!set_opt_s) then
      begin
	print_string usage_msg;
	failwith("Options -T and -S are exclusive");
      end
    else
      ()
  else
    ()
;;

let main =
  try
    begin
      let speclist =
	[("-K", Arg.String(set_token),
	  ": Token used to authenticate the log. ");
	 ("-S", Arg.String(set_log_file_name_opt true),
	  ": Print the current state of the log to stdout");
	 ("-R", Arg.Set(set_room),
	  ": Give a list of all rooms entered by an employee or guest.");
	 ("-E", Arg.String(set_employee),
	  ": Print the current state of the log to stdout");
	 ("-G", Arg.String(set_guest),
	  ": Print the current state of the log to stdout");
	 ("-T", Arg.Set(set_time),
	  ": Gives the total time spent in the gallery by an employee or guest.");
	 ("-I", Arg.Unit(unimplemented),
	  ": Prints the rooms, as a comma-separated list of room IDs");
	]
      in Arg.parse speclist (set_log_file_name_opt false) usage_msg;
      check_arg();
      let logdb = load_logfile false in
      if( not(check_integrity logdb !log_file_name !token false)) then
	raise Integrity_error
      else
	begin
	  let iv = find_iv logdb !log_file_name in
	  let log = load_file !log_file_name !token iv false in
	  if(!set_room) then  
	    let p =
	      if(!guest <> "") then
		find_log log.hash !guest Guest false
	      else
		find_log log.hash !employee Employee false
	    in
	    print_hist (List.rev p.history)
	  else if(!set_time) then
	    let p =
	      if(!guest <> "") then
		find_log log.hash !guest Guest false
	      else
		find_log log.hash !employee Employee false
	    in
	    print_string ((string_of_int (p.leave_time - p.enter_time))^"\n")
	  else
	    print_result_s log.hash;
	    exit 0;
	end
    end
  with
  | Failure(s) ->
    print_string (s^"\n"); 
    exit 0
  | Integrity_error ->
    print_string ("invalid\n");
    exit 255
  | _ ->
    exit 255
;;

