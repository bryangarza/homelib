open Core.Std

type book = {
  title        : string;
  authors      : string list;
  pubdate      : string;
  publishers   : string list;
  subjects     : string list
} with sexp

let body isbn =
  let open Lwt in
  let open Cohttp in
  let open Cohttp_lwt_unix in
  let uri = String.concat
      ["https://openlibrary.org/api/books?bibkeys=ISBN:"
      ;isbn
      ;"&format=json&jscmd=data"] in
  Client.get (Uri.of_string uri) >>= fun (resp, body) ->
  (* let code = resp |> Response.status |> Code.code_of_status in *)
  (* Printf.printf "Response code: %d\n" code; *)
  (* Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string); *)
  body |> Cohttp_lwt_body.to_string >|= fun body ->
  (* Printf.printf "Body of length: %d\n" (String.length body); *)
  body

let get_single_field_from_list json item field =
  let open Yojson.Basic.Util in
  let j = json |> member item |> to_list in
  List.map j ~f:(fun json -> member field json |> to_string)

let json_test isbn = lazy (
  let json_str = Lwt_main.run (body isbn)
  and my_isbn = "ISBN:" ^ isbn in

  let open Yojson.Basic.Util in
  let json         = Yojson.Basic.from_string json_str |> member my_isbn in
  let mem item     = member item json in
  let memstr item  = mem item
                     |> to_string_option
                     |> Option.value ~default:"<unknown>"
  (* and memint item  = mem item |> to_int_option *)
  and memlist item = mem item |> to_list in
  let memlist_name item =
    List.map (memlist item) ~f:(fun j -> member "name" j |> to_string) in

  let b : book = {
    title      = memstr "title";
    authors    = memlist_name "authors";
    pubdate    = memstr "publish_date";
    publishers = memlist_name "publishers";
    subjects   = memlist_name "subjects"
  } in
  b
)

let () = json_test Sys.argv.(1)
         |> Lazy.force
         |> sexp_of_book
         |> Sexp.to_string
         |> print_string
