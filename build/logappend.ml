open Crypt_util
open Gallery
open Parserlist

exception Integrity_error ;;
exception Timestamp_error ;;

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
  "logappend - T<timestamp> -K <token> (-E <employee-name> | -G <guest-name>) (-A | -L) [-R <room-id>] <log>\n"^
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
    begin
      check_token tk;
      token := tk;
    end
  else
    begin
      print_string usage_msg;
      failwith("Option -K called twice.")
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
    ()
;;

(* Check if the timestamp is going greater between calls *)
let check_timestamp log t =
  if(log.timestamp >= t) then
    raise Timestamp_error
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

let perform logdb log_file_name token time_stamp guest employee arrival leave room =
  let iv = find_iv logdb log_file_name in
  if(not(check_integrity logdb log_file_name token true)) then
    begin
      raise Integrity_error
    end
  else
    begin
      let log = load_file log_file_name token iv true in
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
     begin
       Hashtbl.replace log.hash p.name new_p;
       let niv = generate_iv logdb log_file_name iv in
       write_file log_file_name token niv
	 {timestamp = time_stamp; hash = log.hash};
       (* update logdb *)
       update_logdb logdb log_file_name token niv;
       write_logfile logdb;
     end;
    end
;;


let rec perform_batch logdb cmd =
  match cmd with
  | [] -> ()
  | t::q ->
    begin
      perform logdb t.log_file_name t.token t.time_stamp t.guest t.employee
	t.arrival t.leave t.room;
      perform_batch logdb q
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
      in Arg.parse_argv ?current:(Some(ref 0)) Sys.argv speclist (set_log_file_name) usage_msg;
      let logdb = load_logfile true in 
      if(!batch_file_name = "") then
	begin
	  check_arg !log_file_name !token !time_stamp !guest !employee
	    !arrival !leave !room;
	  perform logdb !log_file_name !token !time_stamp !guest !employee
	    !arrival !leave !room
	end
      else
	begin
	  let cmd = load_batch_file !batch_file_name in
	  perform_batch logdb cmd
	end;

      exit 0
    end
  with
  | Failure(s) ->
    (*    print_string ("Failure :"^s^"\n"); *)
    exit 0
  | Timestamp_error ->
    print_string ("invalid\n");
    exit 255
  | Integrity_error ->
    print_string ("invalid\n");
    exit 255
  | Lexer.LexError(s) ->
    (* print_string ("Batch lexing error : "^s^"....\n"); *)
    exit 255
  | Invalid_argument(_) ->
    exit 255
  | Arg.Bad(e) ->
    print_string "invalid\n";
    exit 255
  | e ->
    (* print_string ("Exc : "^(Printexc.to_string e)^"\n"); *)
    exit 0
;;
