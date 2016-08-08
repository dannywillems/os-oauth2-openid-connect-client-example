(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(** This module defines the default template for application pages *)

[%%shared
  open Eliom_content.Html.F
]

[%%shared.start]

let user_menu close user uploader = [
  p [pcdata "Change your password:"];
  Eba_view.password_form ~service:Eba_services.set_password_service' ();
  hr ();
  Eba_userbox.upload_pic_link close uploader (Eba_user.userid_of_user user);
  hr ();
  Eba_userbox.reset_tips_link close;
  hr ();
  Eba_view.disconnect_button ();
]

let%client _ = Eba_userbox.set_user_menu user_menu

let header ?user () =
  ignore user;
  let%lwt user_box =
    Eba_userbox.userbox user
    Oauth_client_services.upload_user_avatar_service in
  Lwt.return
    (header ~a:[a_id "main"] [
       a ~a:[a_id "oauth_client-logo"]
         ~service:Eba_services.main_service [
         pcdata Oauth_client_base.application_name;
       ] ();
       ul ~a:[a_id "oauth_client-navbar"]
         [
           li [a ~service:Eba_services.main_service
                 [pcdata "Home"] ()];
           li [a ~service:Oauth_client_services.about_service
                 [pcdata "About"] ()];
           li [a ~service:Oauth_client_services.otdemo_service
                 [pcdata "ocsigen-toolkit demo"] ()]
         ];
       user_box;
     ])

let footer () =
  div ~a:[a_id "oauth_client-footer"] [
    pcdata "This application has been generated using the ";
    a ~service:Eba_services.eba_github_service [
      pcdata "Eliom-base-app"
    ] ();
    pcdata " template for Eliom-distillery and uses the ";
    a ~service:Eba_services.ocsigen_service [
      pcdata "Ocsigen"
    ] ();
    pcdata " technology.";
  ]

let%server connected_welcome_box () =
  let info, ((fn, ln), (p1, p2)) =
    match Eliom_reference.Volatile.get Eba_msg.wrong_pdata with
    | None ->
      p [
        pcdata "Your personal information has not been set yet.";
        br ();
        pcdata "Please take time to enter your name and to set a password."
      ], (("", ""), ("", ""))
    | Some wpd -> p [pcdata "Wrong data. Please fix."], wpd
  in
  div ~a:[a_id "eba_welcome_box"] [
    div [h2 [pcdata ("Welcome!")]; info];
    Eba_view.information_form
      ~firstname:fn ~lastname:ln
      ~password1:p1 ~password2:p2
      ()
  ]

let%server page userid_o content =
  let%lwt user =
    match userid_o with
    | None ->
      Lwt.return None
    | Some userid ->
      let%lwt u = Eba_user_proxy.get_data userid in
      Lwt.return (Some u)
  in
  let l = [
    div ~a:[a_id "oauth_client-body"] content;
    footer ();
  ] in
  let%lwt h = header ?user () in
  Lwt.return @@ match user with
  | Some user when not (Eba_user.is_complete user) ->
    h :: connected_welcome_box () :: l
  | _ ->
    h :: l

let%client page _ content =
  let l = [
    div ~a:[a_id "oauth_client-body"] content;
    footer ();
  ] in
  let%lwt h = header () in Lwt.return (h :: l)
