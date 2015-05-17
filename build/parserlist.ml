
type elem =
  {
    log_file_name : string;
    token : string;
    time_stamp : int;
    employee : string;
    guest : string;
    room : int;
    arrival : bool;
    leave : bool;
  }
;;

let print_elem e =
  if (e.token <> "") then
    print_string (" -K "^e.token);
  if (e.time_stamp <> -1) then
    print_string (" -T "^(string_of_int e.time_stamp));
  if (e.arrival) then
    print_string (" -A");
  if (e.leave) then
    print_string (" -L");
  if (e.employee <> "") then
    print_string (" -E "^e.employee);
  if (e.guest <> "") then
    print_string (" -G "^e.guest);
  if (e.room <> -1) then
    print_string (" -R "^(string_of_int e.room));
  if (e.log_file_name <> "") then
    print_string (" -T "^e.log_file_name);
;;

let rec print_elem_list l =
  match l with
  | [] -> print_string "\n"
  | t::q -> print_elem t; print_string "...\n"; print_elem_list q
;;
