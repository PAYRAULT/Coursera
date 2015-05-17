open Crypt_util
open Gallery
open Parserlist

exception Integrity_error ;;

let token = ref "";;
let log_file_name = ref "";;
let batch_file_name = ref "";;
let employee = ref "";;
let guest = ref "";;
let time_stamp = ref (-1);;
let room = ref (-1);;
let arrival = ref false;;
let leave = ref false;;

let ouex a b = (a&&(not b))||((not a)&&b);;

let usage_msg = "usage :\n"^
  "logappend -T <timestamp> -K <token> (-E <employee-name> | -G <guest-name>) (-A | -L) [-R <room-id>] <log>\n"^
  "logappend -B <file>\n"
;;

(* Set the timestamp parameter *)
let set_time_stamp t =
  if(t < 0) then
    (* bad argument : t is positive *)
    begin
      print_string usage_msg;
      failwith("Timestamp should be positive.")
    end
  else if(!time_stamp = -1) then
    (* Time stamp never assigned *)
    time_stamp := t
  else
    (* Time stamp already assigned *)
    begin
      print_string usage_msg;
      failwith("Option -T called twice.")
    end

(* Set the room number *)      
let set_room r =
  if(r < 0) then
    (* bad argument : r is positive *)
    begin
      print_string usage_msg;
      failwith("Room is a positive number")
    end
  else if(!room = -1) then
    (* Time stamp never assigned *)
    room := r
  else
    (* Time stamp already assigned *)
    begin
      print_string usage_msg;
      failwith("Option -R called twice.")
    end
    
(* Set the token number *)
let set_token tk =
  if(!token = "") then
    token := tk
  else
    begin
      print_string usage_msg;
      failwith("Option -K called twice.")
    end
;;

(* Set name of the log file *)
let set_log_file_name f =
  if(!log_file_name = "") then
    log_file_name := f
  else
    begin
      print_string usage_msg;
      failwith("Option -S called twice or called with a extra file name.")
    end
;;


(* Set batch file name *)
let set_batch_file_name f =
  if(!batch_file_name = "") then
    batch_file_name := f
  else
    begin
      print_string usage_msg;
      failwith("Option -B called twice")
    end
;;

(* Set employee name *)
let set_employee emp =
  if(!employee = "") then
    employee := emp
  else
    begin
      print_string usage_msg;
      failwith("Option -E called twice.");
    end
;;  

(* Set guest name *)
let set_guest gu =
  if(!guest = "") then
    guest := gu
  else
    begin
      print_string usage_msg;
      failwith("Option -G called twice.");
   end
;;  

(* Check the consistency of the arguments *)
let check_arg log_file_name token time_stamp guest employee
    arrival leave room =
  if(token = "" || time_stamp = -1 || log_file_name = "") then
    begin
      print_string usage_msg;
      failwith("Options -K, -T and logfile are mandatory")
    end
  else if(not(ouex arrival leave)) then
    begin
      print_string usage_msg;
      failwith("Options -A and -L are exclusive and at least once should be called");
    end
  else if(not(ouex (guest = "") (employee = ""))) then
    begin
      print_string usage_msg;
      failwith("Options -E and -G are exclusive and at least once should be called");
    end
  else 
    begin
      check_name guest;
      check_name employee;
      check_token token;
    end
;;

(* Check if the timestamp is going greater between calls *)
let check_timestamp log t =
  if(log.timestamp >= t) then
    failwith("Time stamp Error")
  else
    ()
;;

let load_batch_file name =
  let in_ch = open_in name in
  let current_lexbuf = Lexing.from_channel in_ch in
  let cmd_list = Parser.toplevel Lexer.token current_lexbuf in
  close_in in_ch;
  List.rev cmd_list
;;

let perform log_file_name token time_stamp guest employee arrival leave room =
  if(not(check_integrity log_file_name token true)) then
    begin
      raise Integrity_error
    end
  else
    begin
      let log = load_file log_file_name token true in
      check_timestamp log time_stamp;
      let p =
	if(guest <> "") then
	  find_log log.hash guest Guest true 
	else
	  find_log log.hash employee Employee true
      in
      let act = action arrival leave room in
      let next_st = next_state p.state act in
      let new_p = create_p p next_st time_stamp in
(*
      if (new_p.state = Unknown) then
	begin
	  print_string "Exit the gallery\n";
	  Hashtbl.remove log.hash p.name;
	  print_log log.hash;
	  write_file log_file_name token
	    {timestamp = time_stamp; hash = log.hash};
	end
      else
*)
      begin
	Hashtbl.replace log.hash p.name new_p;
	write_file log_file_name token
	  {timestamp = time_stamp; hash = log.hash};
      end;
      (* update logdb *)
      let logdb = load_logfile() in
      update_logdb logdb log_file_name token;
      write_logfile logdb;
    end
;;


let rec perform_batch cmd =
  match cmd with
  | [] -> ()
  | t::q ->
    begin
      perform t.log_file_name t.token t.time_stamp t.guest t.employee
	t.arrival t.leave t.room;
      perform_batch q
    end
;;

(* Main of the logappend primitive *)
let main =
  try
    begin
      let speclist =
	[("-K", Arg.String(set_token),
	  ": Token used to authenticate the log. ");
	 ("-B", Arg.String(set_batch_file_name),
	  ": Specifies a batch file of commands");
	 ("-R", Arg.Int(set_room),
	  ": Specifies the room ID for an event.");
	 ("-E", Arg.String(set_employee),
	  ": Name of employee.");
	 ("-G", Arg.String(set_guest),
	  ": Name of guest.");
	 ("-T", Arg.Int(set_time_stamp),
	  ": Gives the total time spent in the gallery by an employee or guest.");
	 ("-A", Arg.Set(arrival),
	  ": Specify that the current event is an arrival;");
	 ("-L", Arg.Set(leave),
	  ": Specify that the current event is a departure");
	]
      in Arg.parse speclist (set_log_file_name) usage_msg;
      if(!batch_file_name = "") then
	begin
	  check_arg !log_file_name !token !time_stamp !guest !employee
	    !arrival !leave !room;
	  perform !log_file_name !token !time_stamp !guest !employee
	    !arrival !leave !room
	end
      else
	begin
	  let cmd = load_batch_file !batch_file_name in
	  perform_batch cmd
	end;

      exit 0
    end
  with
  | Failure(s) ->
    print_string (s^"\n");
    exit 255
  | Integrity_error ->
    print_string ("invalid\n");
    exit 255
  | Lexer.LexError(s) ->
    print_string ("Batch lexing error : "^s^"....\n");
    exit 255
  | _ ->
    exit 255
;;
