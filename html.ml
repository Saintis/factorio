type t = Dom.node Js.t

let alert x =
  Dom_html.window##alert(Js.string x)

let text value =
  let text = Dom_html.document##createTextNode(Js.string value) in
  (text :> t)

let text' value =
  let text = Dom_html.document##createTextNode(Js.string value) in
  let set_text value = text##replaceData(0, text##length, Js.string value) in
  (text :> t), set_text

let img ?(class_ = "") ?alt src =
  let alt = match alt with None -> src | Some alt -> alt in
  let img = Dom_html.(createImg document) in
  img##src <- Js.string src;
  img##alt <- Js.string alt;
  img##className <- Js.string class_;
  (img :> t)

let a ?(class_ = "") ?(href = "") items =
  let a = Dom_html.(createA document) in
  let append_node node =
    let _: Dom.node Js.t = a##appendChild(node) in
    ()
  in
  List.iter append_node items;
  a##className <- Js.string class_;
  a##href <- Js.string href;
  (a :> t)

let div' ?(class_ = "") items =
  let div = Dom_html.(createDiv document) in
  let append_node node =
    let _: Dom.node Js.t = div##appendChild(node) in
    ()
  in
  List.iter append_node items;
  let set_items (items: t list) =
    List.iter
      (fun child -> let _: Dom.node Js.t = div##removeChild(child) in ())
      (Dom.list_of_nodeList div##childNodes);
    List.iter append_node items;
  in
  div##className <- Js.string class_;
  (div :> t), set_items

let div ?class_ items =
  let div, _ = div' ?class_ items in
  div

let span' ?(class_ = "") items =
  let span = Dom_html.(createSpan document) in
  let append_node node =
    let _: Dom.node Js.t = span##appendChild(node) in
    ()
  in
  List.iter append_node items;
  let set_items (items: t list) =
    List.iter
      (fun child -> let _: Dom.node Js.t = span##removeChild(child) in ())
      (Dom.list_of_nodeList span##childNodes);
    List.iter append_node items;
  in
  span##className <- Js.string class_;
  (span :> t), set_items

let span ?class_ items =
  let span, _ = span' ?class_ items in
  span

let checkbox_input' ?(class_ = "") ?(on_change = fun _ -> ()) checked =
  let input = Dom_html.(createInput ~_type: (Js.string "checkbox") document) in
  input##checked <- Js.bool checked;
  let on_click _ = on_change (Js.to_bool input##checked); Js._true in
  input##onclick <- Dom.handler on_click;
  input##className <- Js.string class_;
  let set_checked checked = input##checked <- Js.bool checked in
  (input :> t), set_checked

let checkbox_input ?class_ ?on_change items =
  let checkbox_input, _ = checkbox_input' ?class_ ?on_change items in
  checkbox_input

let text_input' ?(class_ = "") ?(on_change = fun _ -> ()) value =
  let input = Dom_html.(createInput ~_type: (Js.string "text") document) in
  input##value <- Js.string value;
  let on_input _ = on_change (Js.to_string input##value); Js._true in
  input##oninput <- Dom.handler on_input;
  input##className <- Js.string class_;
  let set_value value = input##value <- Js.string value in
  (input :> t), set_value

let text_input ?class_ ?on_change items =
  let text_input, _ = text_input' ?class_ ?on_change items in
  text_input

let run html =
  let on_load _ =
    let html = html () in
    let body =
      let find_tag name =
        let elements =
          Dom_html.window##document##getElementsByTagName(Js.string name)
        in
        let element =
          Js.Opt.get elements##item(0)
            (fun () -> failwith ("find_tag("^name^")"))
        in
        element
      in
      find_tag "body"
    in
    let _: t = body##appendChild(html) in
    Js._false
  in
  Dom_html.window##onload <- Dom.handler on_load

let get_hash () =
  let fragment = Dom_html.window##location##hash |> Js.to_string in
  if fragment = "" then
    ""
  else if fragment.[0] = '#' then
    String.sub fragment 1 (String.length fragment - 1)
  else
    fragment

let set_hash hash =
  Dom_html.window##location##hash <- Js.string hash

let on_hash_change handler =
  let handler _ = handler (); Js._true in
  Dom_html.window##onhashchange <- Dom.handler handler