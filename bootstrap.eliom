[%%shared
  open Eliom_content.Html.D
]

let container ?(css=[]) ?(children=[]) () =
  div ~a:[a_class (["container"] @ css)] children

let row ?(css=[]) ?(children=[]) () =
  div ~a:[a_class (["row"] @ css)] children

let col_args_to_str offset lg =
  match (offset, lg) with
  | (0, 0) -> ""
  | (a, 0) when a > 0 -> "col-offset-lg-" ^ (string_of_int a)
  | (0, a) when a > 0 -> "col-lg-" ^ (string_of_int a)
  | (a, b) when a > 0 && b > 0 ->
      "col-lg-offset-" ^ (string_of_int a) ^
      " col-lg-" ^ (string_of_int b)
  | _ -> ""

let col ?(css=[]) ?(element=div) ?(offset=0) ?(lg=0) ?(children=[]) () =
  element
    ~a:[a_class ([col_args_to_str offset lg] @ css)]
    children

let p ?(css=[]) ?(children=[]) text =
  p ~a:[a_class css] ([pcdata text] @ children)

let form ?(css=[]) ?(children=[]) () =
  form ~a:[Unsafe.string_attrib "role" "form" ; a_class css] children

let label ?(children=[]) for_ content =
  label ~a:[a_label_for for_] ([pcdata content] @ children)

let input ?(css=[]) input_type id =
  input
    ~a:[a_class (["form-control"] @ css) ; a_id id ; a_input_type input_type]
    ()

let form_group ?(css=[]) ?(children=[]) input_type id content =
  div
    ~a:[a_class (["form-group"] @ css)]
    ([label id content ; input input_type id] @ children)

let h1 content = h1 [pcdata content]
let h2 content = h2 [pcdata content]
let h3 content = h3 [pcdata content]
let h4 content = h4 [pcdata content]
let h5 content = h5 [pcdata content]
let h6 content = h6 [pcdata content]

module Button =
  struct
    type t =
      | Primary
      | Default
      | Success
      | Info
      | Warning
      | Danger
      | Link

    let to_string t = match t with
      | Primary -> "btn-primary"
      | Default -> "btn-default"
      | Success -> "btn-success"
      | Info -> "btn-info"
      | Warning -> "btn-warning"
      | Danger -> "btn-danger"
      | Link -> "btn-link"

    let button ?(css=[]) ?(css_type=Default) button_type id content =
      button
        ~a:[
          a_id id ;
          a_class (["btn" ; (to_string css_type)] @ css) ;
          a_button_type button_type
        ]
        [pcdata content]

    let submit ?(css=[]) ?(css_type=Default) id content =
      button ~css ~css_type `Submit id content
  end
