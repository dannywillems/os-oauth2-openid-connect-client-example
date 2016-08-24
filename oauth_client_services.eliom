[%%shared
  open Eliom_parameter
]

(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

let%shared about_service =
  Eliom_service.create
    ~id:(Eliom_service.Path ["about"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let%shared upload_user_avatar_service =
  Ot_picture_uploader.mk_service
    "upload_user_avatar_service"
    [%derive.json: unit]

let%shared otdemo_service =
  Eliom_service.create
    ~id:(Eliom_service.Path ["otdemo"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let%shared register_eliom_client =
  let param =
    ((string "firstname") ** (string "lastname"))
    **
    ((string "email") ** (string "password"))
  in
  Eliom_service.create
    ~name:"register_eliom_client"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()

let%shared remove_eliom_client =
  let param = Eliom_parameter.int64 "id" in
  Eliom_service.create
    ~name:"remove_eliom_client"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()

(* -------------------------------------------------------------------------- *)
let%shared eba_connect_service =
  let param = Eliom_parameter.unit in
  Eliom_service.create
    ~name:"eba_connect_service"
    ~id:(Eliom_service.Path ["eba_connect"])
    ~meth:(Eliom_service.Get param)
    ()

let%shared remove_connect_registered_server_service =
  let param = Eliom_parameter.int64 "id" in
  Eliom_service.create
    ~name:"remove connect registered server"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()

let%shared remove_connect_token_service =
  let param =
    (Eliom_parameter.string "token") ** (Eliom_parameter.int64 "server_id")
  in
  Eliom_service.create
    ~name:"remove connect token"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let%shared eba_oauth2_service =
  let param = Eliom_parameter.unit in
  Eliom_service.create
    ~name:"eba_oauth2_service"
    ~id:(Eliom_service.Path ["eba_oauth2"])
    ~meth:(Eliom_service.Get param)
    ()

let%shared remove_oauth2_registered_server_service =
  let param = Eliom_parameter.int64 "id" in
  Eliom_service.create
    ~name:"remove oauth2 registered server"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()

let%shared remove_oauth2_token_service =
  let param =
    (Eliom_parameter.string "token") ** (Eliom_parameter.int64 "server_id")
  in
  Eliom_service.create
    ~name:"remove oauth2 token"
    ~id:Eliom_service.Global
    ~meth:(Eliom_service.Get param)
    ()
(* -------------------------------------------------------------------------- *)
