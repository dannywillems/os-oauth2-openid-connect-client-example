(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
    open Eliom_content.Html.D
]

let%shared main_service_handler userid_o () () =
  Oauth_client_container.page userid_o (
    [
      p [em [pcdata "Eliom base app: Put app content here."]]
    ]
  )

let%shared about_handler userid_o () () =
  Oauth_client_container.page userid_o [
    div [
      p [pcdata "This template provides a skeleton \
                 for an Ocsigen application."];
      hr ();
      p [pcdata "Feel free to modify the generated code and use it \
                 or redistribute it as you want."]
    ]
  ]

let%server upload_user_avatar_handler myid () ((), (cropping, photo)) =
  let avatar_dir =
    List.fold_left Filename.concat
      (List.hd !Oauth_client_config.avatar_dir)
      (List.tl !Oauth_client_config.avatar_dir) in
  let%lwt avatar =
    Eba_uploader.record_image avatar_dir ~ratio:1. ?cropping photo in
  let%lwt user = Eba_user.user_of_userid myid in
  let old_avatar = Eba_user.avatar_of_user user in
  let%lwt () = Eba_user.update_avatar avatar myid in
  match old_avatar with
  | None -> Lwt.return ()
  | Some old_avatar ->
    Lwt_unix.unlink (Filename.concat avatar_dir old_avatar )

let () =
  (* Registering services. Feel free to customize handlers. *)
  Eliom_registration.Action.register
    ~service:Eba_services.set_personal_data_service'
    (Eba_session.connected_fun Eba_handlers.set_personal_data_handler');

  Eliom_registration.Action.register
    ~service:Eba_services.set_password_service'
    (Eba_session.connected_fun Eba_handlers.set_password_handler');

  Eliom_registration.Action.register
    ~service:Eba_services.forgot_password_service
    (Eba_handlers.forgot_password_handler Eba_services.main_service);

  Eliom_registration.Action.register
    ~service:Eba_services.preregister_service'
    Eba_handlers.preregister_handler';

  Eliom_registration.Action.register
    ~service:Eba_services.sign_up_service'
    Eba_handlers.sign_up_handler;

  Eliom_registration.Action.register
    ~service:Eba_services.connect_service
    Eba_handlers.connect_handler;

  Eliom_registration.Action.register
    ~service:Eba_services.disconnect_service
    Eba_handlers.disconnect_handler;

  Eliom_registration.Any.register
    ~service:Eba_services.activation_service
    Eba_handlers.activation_handler;

  Oauth_client_base.App.register
    ~service:Oauth_client_services.about_service
    (Oauth_client_page.Opt.connected_page about_handler) ;

  Eliom_registration.Ocaml.register
    ~service:Oauth_client_services.upload_user_avatar_service
    (Eba_session.connected_fun upload_user_avatar_handler);

  (* End predefined *)
  (* -------------- *)

  Oauth_client_base.App.register
    ~service:Oauth_client_services.eba_connect_service
    (Oauth_client_handlers.eba_connect_handler);

  Oauth_client_base.App.register
    ~service:Eba_services.main_service
    (Oauth_client_handlers.main_service_handler);

  Eliom_registration.Action.register
    ~service:Oauth_client_services.remove_registered_server_service
    (Oauth_client_handlers.remove_registered_server_handler);

  Eliom_registration.Action.register
    ~service:Oauth_client_services.remove_token_service
    Oauth_client_handlers.remove_token_handler



(* -------------------------- *)
(* We save the oauth2 servers *)

let _ =
  try%lwt
    let%lwt _ = Eba_oauth2_client.save_oauth2_server
      ~server_id:"oauth-server-test"
      ~server_authorization_url:"http://localhost:8080/oauth2/authorization"
      ~server_token_url:"http://localhost:8080/oauth2/token"
      ~server_data_url:"http://localhost:8080/api"
      ~client_id:"4UyXHdbZqwiaIuGuHk9gmM4KqtsTSPLEjW6zPAnAaa"
      ~client_secret:"k2bB0RLBuXdEcYbyUhHwXnTtTNBsievDI4KNKFiB4D" in
    Lwt.return ()
  with _ -> Lwt.return ()

(* We save the oauth2 servers *)
(* -------------------------- *)

(* ---------------------------- *)
(* We register the redirect_uri *)

let _ =
  Eba_oauth2_client.register_redirect_uri
    ~redirect_uri:"http://localhost:8000/redirect-uri"
    ~success_redirection:(Eliom_registration.Redirection
    Eba_services.main_service)
    ~error_redirection:(Eliom_registration.Redirection
    Eba_services.main_service)

(* We register the redirect_uri *)
(* ---------------------------- *)


let%client set_client_fun ~app ~service f : unit =
  Eliom_content.set_client_fun ~app ~service
    (fun get post ->
       let%lwt content = f get post in
       Eliom_client.set_content_local
         (Eliom_content.Html.To_dom.of_element content))

let%client () =
  let app = Eliom_client.get_application_name () in
  set_client_fun ~app ~service:Oauth_client_services.about_service
    (Oauth_client_page.Opt.connected_page about_handler);
  set_client_fun ~app ~service:Oauth_client_services.otdemo_service
    (Oauth_client_page.Opt.connected_page Oauth_client_otdemo.handler);
  set_client_fun ~app ~service:Eba_services.main_service
    (Oauth_client_page.Opt.connected_page main_service_handler)
