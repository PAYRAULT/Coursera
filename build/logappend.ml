open Crypt_util
open Gallery
open Parserlist

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
  if((t < 1) || (t>1073741823)) then
    (* bad argument : t is positive *)
    begin
       raise (Arg.Bad "Wrong time stamp.")
    end
  else if(!time_stamp = -1) then
    (* Time stamp never assigned *)
    time_stamp := t
  else
    (* Time stamp already assigned *)
    begin
       raise (Arg.Bad "Option -T called twice.")
    end

(* Set the room number *)      
let set_room r =
  if((r < 0) || (r>1073741823)) then
    (* bad argument : r is positive *)
    begin
      raise (Arg.Bad "Wrong room number")
    end
  else if(!room = -1) then
    (* Time stamp never assigned *)
    room := r
  else
    (* Time stamp already assigned *)
    begin
      raise (Arg.Bad "Option -R called twice.")
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
      raise (Arg.Bad "Option -K called twice.")
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
      raise (Arg.Bad "Option -S called twice or called with a extra file name.")
    end
;;


(* Set batch file name *)
let set_batch_file_name f =
  if(!batch_file_name = "") then
    batch_file_name := f
  else
    begin
      raise (Arg.Bad "Option -B called twice")
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
      raise (Arg.Bad "Option -E called twice.");
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
      raise (Arg.Bad "Option -G called twice.");
   end
;;  

(* Check the consistency of the arguments *)
let check_arg batch_file_name log_file_name token time_stamp guest employee
    arrival leave room =
  if(batch_file_name = "") then
    begin
      if(token = "" || time_stamp = -1 || log_file_name = "") then
	begin
	  raise (Arg.Bad "Options -K, -T and logfile are mandatory")
	end
      else if(not(ouex arrival leave)) then
	begin
	  raise (Arg.Bad "Options -A and -L are exclusive and at least once should be called");
	end
      else if(not(ouex (guest = "") (employee = ""))) then
	begin
	  raise (Arg.Bad "Options -E and -G are exclusive and at least once should be called");
	end
      else 
	()
    end
  else
    if(token <> "" || time_stamp <> -1 || log_file_name <> "" ||
    guest <> "" || employee <> "") then
      raise (Arg.Bad "Options -B is only with -K.");
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



let close_log_file logdb log time_stamp log_file_name token iv = 
  let niv = generate_iv logdb log_file_name iv in
  write_file log_file_name token niv
    {timestamp = time_stamp; hash = log.hash; filename = log_file_name};
  (* update logdb *)
  update_logdb logdb log_file_name token niv;
  write_logfile logdb;
;;


let perform logdb log_file_name token time_stamp guest employee
    arrival leave room =
  let log_info = find_log_info logdb log_file_name in
  let log = load_log_file log_info token time_stamp true in
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
  let p1 = {p_name = p.name; p_gender = p.gender} in
  Hashtbl.replace log.hash p1 new_p;
  close_log_file logdb log time_stamp log_file_name token log_info.iv;
;;

let perform_local log file_name time_stamp guest employee arrival leave room =
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
    let p1 = {p_name = p.name; p_gender = p.gender} in
    Hashtbl.replace log.hash p1 new_p;
    {timestamp = time_stamp; hash = log.hash; filename = file_name}
  end
;;


let rec perform_batch logdb log_info log_file t cmd =
  let log = perform_local log_file t.log_file_name t.time_stamp t.guest t.employee
    t.arrival t.leave t.room
  in
  match cmd with
  | [] ->
    close_log_file logdb log t.time_stamp t.log_file_name t.token log_info.iv ;
    
  | t1::q ->
    begin
      if(t.log_file_name = t1.log_file_name) then
	begin
	  perform_batch logdb log_info log t1 q
	end
      else
	begin
	  close_log_file logdb log_file t.time_stamp t.log_file_name t.token log_info.iv ;
	  let log_info = find_log_info logdb t1.log_file_name in
          let log = load_log_file log_info t1.token t1.time_stamp true in
	  perform_batch logdb log_info log t1 q
	end
    end
;;

(* Main of the logappend primitive *)
let main =
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
    in
    try
      Arg.parse_argv ?current:(Some(ref 0)) Sys.argv speclist
	(set_log_file_name) usage_msg;
      let logdb = load_logfile true
      in 
      check_arg !batch_file_name !log_file_name !token !time_stamp !guest
	!employee !arrival !leave !room;
     if(!batch_file_name = "") then
	begin
	  perform logdb !log_file_name !token !time_stamp !guest !employee
	    !arrival !leave !room
	end
      else
	begin
	  let cmd = load_batch_file !batch_file_name in
	  match cmd with
	  | [] -> ()
	  | t::q ->
	    begin
	      let log_info = find_log_info logdb t.log_file_name in
	      let logt = load_log_file log_info !token t.time_stamp true in
	      perform_batch logdb log_info logt t q
	    end
	end;
      
      exit 0
    with
    | Failure(s) ->
      (* print_string ("Failure : "^s^"\n");*)
      exit 0
    | Timestamp_error ->
      print_string ("invalid\n");
      exit 255
    | Integrity_error ->
      print_string ("invalid\n");
      exit 255
    | Lexer.LexError(s) ->
    (*print_string ("Batch lexing error : "^s^"....\n");*)
      exit 255
    | Invalid_argument(_) ->
      exit 255
    | Arg.Bad(e) ->
      if(!batch_file_name = "") then
	begin
	  print_string "invalid\n";
	  exit 255
	end
      else
	exit 0
    | e ->
      (* print_string ("Exc : "^(Printexc.to_string e)^"\n"); *)
      exit 0
;;
