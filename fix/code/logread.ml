open Crypt_util
open Gallery

let set_room = ref false;;
let set_time = ref false;;
let set_opt_s = ref false;;
let token = ref "";;
let log_file_name = ref "";;
let employee = ref "";;
let guest = ref "";;
let set_opt_i = ref false;;
let opt_i_list = ref [];;

let ouex a b = (a&&(not b))||((not a)&&b);;

let usage_msg = "usage :\n"^
  "logread -K <token> -S <log>\n"^
  "logread -K <token> -R (-E <name> | -G <name>) <log>\n"^
  "logread -K <token> -T (-E <name> | -G <name>) <log>\n"^
  "logread -K <token> -I (-E <name> | -G <name>) [(-E <name> | -G <name>) ...] <log>";; 

(* Set the token number *)
let set_token tk =
  check_token tk;
  token := tk;
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
      raise ( Arg.Bad "Option -S called twice or called with a extra file name.");
    end
;;

(* Set log file name and the option type (-S or not) *)
let set_log_file_name_opt s f =
  set_opt_s := s;
  set_log_file_name f
;;

(* Set employee name *)
let set_employee emp =
  check_name emp;
  if(!set_opt_i) then
    begin
      opt_i_list := {p_gender = Employee; p_name = emp}::!opt_i_list
    end
  else
    if(!employee = "") then
      begin
	employee := emp;
      end
    else
      begin
	raise( Arg.Bad "Option -E called twice.");
      end
;;  

(* Set guest name *)
let set_guest gu =
  if(!set_opt_i) then
    begin
      opt_i_list := {p_gender = Guest; p_name = gu}::!opt_i_list
    end
  else
    if(!guest = "") then
      begin
	check_name gu;
	guest := gu;
      end
    else
      begin
	raise(Arg.Bad "Option -G called twice.");
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
      raise( Arg.Bad "Options -K and logfile are mandatory");     
    end
  else if(!set_room) then
    if(not(ouex (!guest = "") (!employee = ""))) then
      begin
	raise(Arg.Bad "Options -E and -G are exclusive and at least once should be called");
      end
    else if(!set_opt_s || !set_opt_i) then
      begin
	raise(Arg.Bad "Options -R, -I and -S are exclusive");
      end
    else
      ()
  else if(!set_time) then
    if(!set_opt_s || !set_opt_i) then
      begin
	raise( Arg.Bad "Options -T and -S are exclusive");
      end
    else
      ()
  else
    ()
;;


let print_room_history log l =
  let rec lr l =
    match l with
    | [] -> []
    | t::q ->
      let ph =
	try
	  if(t.p_gender = Guest) then
	    let ppp = find_log log t.p_name Guest false in ppp.history
	  else
	    let ppp = find_log log t.p_name Employee false in ppp.history
	with
	| Not_found ->
	  []
      in
      ph::(lr q)
  in
  let rec same_room_same_time (r1,ta1,tl1) (r2,ta2,tl2) =
    (r1 = r2) &&
      (((ta1 > ta2) && (tl1 < tl2)) ||
       ((ta1 < ta2) && (tl1 < tl2) && (ta2 < tl1)) ||
       ((ta1 < ta2) && (tl1 > tl2)) ||
       ((ta1 > ta2) && (tl1 > tl2) && (tl2 > ta1)))
  in
  let rec parcours e1 l =
    match l with
    | [] -> false
    | e2::q ->
      begin
	if (same_room_same_time e1 e2) then
	  true
	else
	  parcours e1 q
      end
  in
  let rec parcours2 ((r,ta,tl) as e) l =
    match l with
    | [] -> r
    | t::q ->
      begin
	if(parcours e t) then
	  (parcours2 e q)
	else
	  -1
      end
  in
  let rec parcours3 e q =
    match e with
    | [] -> []
    | t1::q1 ->
      begin
	let res = (parcours2 t1 q) in
	if( res = -1) then
	  parcours3 q1 q
	else
	  res::( parcours3 q1 q)
      end
  in
  let llr = lr l in
  match llr with
  | fe::q -> (parcours3 fe q)
  | _ -> failwith("Error")
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
	 ("-I", Arg.Set(set_opt_i),
	  ": Prints the rooms, as a comma-separated list of room IDs");
	]
      in Arg.parse_argv ?current:(Some(ref 0)) Sys.argv speclist (set_log_file_name) usage_msg;
      check_arg();
      let logdb = load_logfile false in
      let log_info = find_log_info logdb !log_file_name in
      let log = load_log_file log_info !token 0 false in
      if(!set_room) then  
	let p =
	  if(!guest <> "") then
	    find_log log.hash !guest Guest false
	  else
	    find_log log.hash !employee Employee false
	in
	print_hist (List.rev p.history);
      else if(!set_time) then
	let p =
	  if(!guest <> "") then
	    find_log log.hash !guest Guest false
	  else
	    find_log log.hash !employee Employee false
	in
	if(p.leave_time <> -1) then
	  print_string ((string_of_int (p.leave_time - p.enter_time))^"\n")
	else
	  print_string((string_of_int 0)^"\n")
      else if(!set_opt_i) then
	begin
	  let lr = print_room_history log.hash !opt_i_list
	  in
	  print_rooms_i lr
	end
      else
	print_result_s log.hash;
	exit 0;
    end
  with
  | Failure(s) ->
    (*print_string (s^"\n");*)
    exit 0
  | Integrity_error ->
    print_string ("integrity violation\n");
    exit 255
  | Arg.Bad(_) ->
    print_string ("invalid\n");
    exit 255
  | Sys_error(_) ->
    print_string ("invalid\n");
    exit 255      
  | e ->
    (*print_string ("Exc : "^(Printexc.to_string e)^"\n");*)
    exit 255
;;

