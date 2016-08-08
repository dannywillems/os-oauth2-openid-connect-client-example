[%%shared
  open Eliom_content
  open Html.D
]

module B = Bootstrap

let title_page () =
  B.row
   ~children:[
     B.col
      ~lg:12
      ~css:["text-center"]
      ~children:[
        B.h1 "Welcome in OAuth2.0 template for Eliom"
      ]
      ()
  ] ()

let%client click_besport_connect () =
  Eliom_client.change_page
    ~service:Oauth_client_services.eba_connect_service
    ()
    ();
  Jsoo_lib.console_log "Click BeSport Connect"


let login =
  [
    B.h3 "Log in" ;
    B.form_group `Email "login-email" "Email: " ;
    B.form_group `Password "login-password" "Password: " ;

    B.h3 "or" ;
    button
      ~a:[
        a_onclick ([%client (fun _ -> click_besport_connect ())]);
        a_id "besport-connect" ;
        a_class ["btn" ; (B.Button.to_string B.Button.Danger) ; "besport-color"] ;
        a_button_type `Submit
      ]
      [
        (*
        img
          ~alt:"BeSport"
          ~src:(
            make_uri
              ~service:(Eliom_service.static_dir ())
              ["img" ; "besport.png"]
          )
          () ;
        *)
        pcdata "BeSport Connect"
      ]
  ]

(* -------------------------------------------------------------------------- *)
(* Eliom *)
let%client update_eliom () =
  let firstname =
    Js.to_string (Jsoo_lib.get_input_by_id "signup-firstname")##.value
  in
  let lastname =
    Js.to_string (Jsoo_lib.get_input_by_id "signup-lastname")##.value
  in
  let email =
    Js.to_string (Jsoo_lib.get_input_by_id "signup-email")##.value
  in
  let pwd =
    Js.to_string (Jsoo_lib.get_input_by_id "signup-pwd")##.value
  in
  Lwt.ignore_result
    (Eliom_client.call_service
      ~service:Oauth_client_services.register_eliom_client
      ((firstname, lastname), (email, pwd))
      ()
    )

let%client remove_eliom_client id =
  Lwt.ignore_result
  (
    Eliom_client.call_service
      ~service:Oauth_client_services.remove_eliom_client
      id
      () ;
    Eba_lib.reload ()
  )

let eliom_client_to_html c =
  let firstname = Eba_user.firstname_of_user c in
  let lastname  = Eba_user.lastname_of_user c in
  let userid    = Eba_user.userid_of_user c in
  let%lwt email = Eba_user.email_of_user c in
  Lwt.return (
    div ~a:[a_class ["text-left" ; "border-bottom" ; "padding-top" ]]
    [
      p [b [pcdata "Firstname: "] ; pcdata firstname] ;
      p [b [pcdata "Lastname: "] ; pcdata lastname] ;
      p [b [pcdata "Email: "] ; pcdata email] ;
      div ~a:[a_class ["text-center"]]
      [
        button
          ~a:[
            a_onclick [%client (fun _ -> remove_eliom_client ~%userid)] ;
            a_button_type `Submit ;
            a_class ["btn" ; B.Button.to_string B.Button.Danger]
          ]
          [pcdata "Remove Eliom client"]
      ]
    ]
  )

let eliom_clients_list_to_html () =
  let%lwt l = Eba_user.get_users () in
  let%lwt html = Lwt_list.map_s (fun u -> (eliom_client_to_html u)) l in
  Lwt.return (
    [
      div
      ~a:[a_class ["text-center"]]
      ([h2 ~a:[a_class ["text-center"]] [pcdata "Eliom clients list"]] @ html)
    ]
  )

let form_eliom =
  B.form
    ~children:[
      B.h3 "Sign up" ;
      B.form_group `Text "signup-firstname" "Firstname: " ;
      B.form_group `Text "signup-lastname" "Lastname: " ;
      B.form_group `Email "signup-email" "Email: " ;
      B.form_group `Password "signup-pwd" "Password: " ;
      button
        ~a:[
          a_onclick ([%client (fun _ -> update_eliom ())]);
          a_id "signup-submit" ;
          a_class (["btn " ^ (B.Button.to_string B.Button.Default)]) ;
          a_button_type `Submit
        ]
        [pcdata "Register"]
    ]
    ()
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let oauth2_server_to_html server =
  let id = Eba_oauth2.Client.id_of_registered_server server in
  let server_id = Eba_oauth2.Client.server_id_of_registered_server server in
  let a_url = Eba_oauth2.Client.authorization_url_of_registered_server server in
  let t_url = Eba_oauth2.Client.token_url_of_registered_server server in
  let d_url = Eba_oauth2.Client.data_url_of_registered_server server in
  let client_credentials =
    Eba_oauth2.Client.client_credentials_of_registered_server server
  in
  let client_id =
    Eba_oauth2.client_credentials_id client_credentials
  in
  let client_secret =
    Eba_oauth2.client_credentials_secret client_credentials
  in
  div ~a:[a_class ["text-left" ; "padding-top"]]
  [
    p [b [pcdata "ID: "] ; pcdata (string_of_int (Int64.to_int id))] ;
    p [b [pcdata "Server ID: "] ; pcdata server_id] ;
    p [b [pcdata "Authorization URL: "] ; pcdata a_url] ;
    p [b [pcdata "Token URL: "] ; pcdata t_url] ;
    p [b [pcdata "Data URL: "] ; pcdata d_url] ;
    p [b [pcdata "Client ID: "] ; pcdata client_id] ;
    p [b [pcdata "Client secret: "] ; pcdata client_secret]
  ]

let oauth2_server_list_to_html () =
  let%lwt l = Eba_oauth2.Client.list_servers () in
  let html = List.map (fun u -> oauth2_server_to_html u) l in
  Lwt.return (
    [
      div
        ~a:[a_class ["text-center"]]
        ([h2 ~a:[a_class ["text-center"]] [pcdata "OAuth2.0 server list"]] @ html)
    ]
  )
(* -------------------------------------------------------------------------- *) 
(* -------------------------------------------------------------------------- *)
let main_service_handler =
  fun () () ->
    let%lwt user_list = eliom_clients_list_to_html () in
    let%lwt server_list = oauth2_server_list_to_html () in
    Lwt.return (
      Eliom_tools.D.html
        ~title:"Welcome in OAuth2.0 Client template for Eliom"
        ~css:[["css" ; "bootstrap.min.css"] ; ["css" ; "oauth_client.css"]]
        Eliom_content.Html.D.(body [
          B.container
            ~children:[
              title_page () ;
              B.row
                ~children:[
                  B.col ~lg:6 ~children:login () ;
                  B.col ~lg:6 ~children:[form_eliom] () ;
                  B.col ~lg:6 ~children:user_list () ;
                  B.col ~lg:6 ~children:server_list ()
                ]
                ()
            ]
            ()
        ])
      )
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let register_eliom_client_handler =
  (fun ((firstname, lastname), (email, password)) () ->
    ignore (Eba_user.create ~password ~firstname ~lastname email);
    Lwt.return ()
  )

let remove_eliom_client_handler =
  (fun id () ->
    (*Eba_db.User.remove_user_by_userid id ;*)
    Lwt.return ()
  )
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let eba_connect_handler =
  (fun () () ->
    (* You can also check if we have the data from the OAuth2.0 server *)

    (* Compute the service and the data to sent to the service *)
    let%lwt _ =
      Eba_oauth2.Client.request_authorization_code
        (*~default_scope:"oauth"*)
        ~redirect_uri:"http://localhost:8000/redirect-uri"
        ~server_id:"oauth-server-test"
        ~scope:["name" ; "firstname"]
        ()
    in

    Lwt.return (
      Eliom_tools.D.html
        ~title:"BeSport Connect temporary page"
        Eliom_content.Html.D.(body []);
    )
  )
(* -------------------------------------------------------------------------- *)
