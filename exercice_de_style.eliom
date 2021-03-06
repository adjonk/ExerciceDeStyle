{shared{
open Eliom_lib
open Eliom_content
open Html5.D
}}

module Exercice_de_style_app =
  Eliom_registration.App (
  struct
    let application_name = "exercice_de_style"
  end)


(************)
(* Services *)
(************)

let home_service =
  Eliom_service.App.service 
    ~path:[] 
    ~get_params:Eliom_parameter.unit 
    ()

let gallery_service =
  Eliom_service.App.service 
    ~path:["gallery"] 
    ~get_params:Eliom_parameter.unit 
    ()

let deco_service =
  Eliom_service.App.service 
    ~path:["decoration"] 
    ~get_params:Eliom_parameter.unit 
    ()

let philosophy_service =
  Eliom_service.App.service 
    ~path:["philosophy"] 
    ~get_params:Eliom_parameter.unit 
    ()

    (**********)
    (* Client *)
    (**********)

    {client{

        let resize_body () =
          let innerHeight = Dom_html.window##innerHeight in
          if Js.Optdef.test innerHeight then
            let window_height =
              (Js.Optdef.get innerHeight (fun () -> raise Not_found)) - (85+25+34+10)
            in
            let body_container_dom =
              Js.Opt.get Dom_html.document##getElementById(Js.string "body-container") 
                (fun _ -> raise Not_found) 
            in
            (*   Eliom_content.Html5.To_dom.of_div (%body_container (div[])) in *)
            (body_container_dom##style)##height <- Js.string ((string_of_int window_height) ^ "px");
          else 
            ();

          (* let _ = *)
          (*   Dom_html.window##onload <- *)
          (*     Dom.handler (fun _ -> resize_body()); *)
          (*   Dom_html.window##onresize <- *)
          (*     Dom.handler (fun _ -> resize_body());  *)
          (*   Js._true;     *)                                               
      }}

    {client{
        let generate_gallery_js () = 
          Js.Unsafe.fun_call (Js.Unsafe.variable "generate_gallery") [||]
      }}

    {client{
        let generate_gallery () =
          let unopt x = Js.Opt.get x (fun _ -> raise Not_found) in
          let retrieve id = unopt Dom_html.document##getElementById(Js.string id) in
          let thumbListId = "thumbs" in
          let imgViewerId = "viewer" in
          let activeClass = "active" in
          let activeTitle = "Photo en cours de visualisation" in
          let loaderTitle = "Chargement en cours" in
          let loaderImage = "static/img/loader.img" in
          let thumbLinks = (retrieve thumbListId)##getElementsByTagName(Js.string "a") in
          (* let highlight elt =  *)
          (*   thumbLinks##removeClass (); *)
          (* in *)
          let firstThumbLink = 
            let elt = unopt thumbLinks##item(0) in
            unopt (Dom_html.CoerceTo.a (Dom_html.element elt))
          in
          (* Image Viewer Creation *)
          let imgViewer = Dom_html.createImg Dom_html.document in
          imgViewer##alt <- Js.string "";
          imgViewer##src <- firstThumbLink##href;
          let imgViewerDiv = Dom_html.document##createElement(Js.string "div") in
          imgViewerDiv##id <- Js.string imgViewerId;
          
          
      }}

(***********************)
(* Skeletton Web Pages *)
(***********************)

let title_container = div [
    pre ~a:[a_class ["big-century"]] [
      a home_service
        [pcdata "V L A D A N A  J O N Q U E T"]
        ()
    ];
    div ~a:[a_class ["average-century"]] [
      pcdata "Art Conseil"
    ];
    div ~a:[a_class ["average-century"]] [
      pcdata "Galerie – Art et arts décoratifs du XXe siècle"
    ] 
  ]

let logo_container = div ~a:[a_class ["logo-container"]] [
    img ~alt:("LOGO")
      ~a:[a_width 50]
      ~src:(make_uri ~service:(Eliom_service.static_dir ()) ["img/LOGO_G.png"]) ()
  ]

let header_container_left = 
  div ~a:[a_class ["header-left-container"]] [
    logo_container;
    title_container
  ]

let header_container_right =
  div ~a:[a_class ["header-right-container"]] [
    nav [
      ul ~a:[a_class ["skel-menu"]] [
        li [a gallery_service
              [pcdata "Galerie"]
              ()];
        li [a deco_service
              [pcdata "Décoration Intérieure"]
              ()];
        li [a philosophy_service
              [pcdata "Art Conseil"]
              ()];
      ]
    ]
  ]

let footer =
  footer ~a:[a_class ["skel-footer"]] [
    div ~a:[a_class []] [
      div ~a:[a_class ["float-right"; "skel-footer-text"]] [
        pcdata "vladana.jonquet@outlook.com | 00 336 70 88 54 63"
      ]
    ]
  ]

let header_container = div ~a:[a_class ["header-container"]] [
    header_container_left;
    header_container_right;
  ]

let body_container body_content = 
  div ~a:[a_id "body-container"] body_content

let skeletton body_content title =
  ignore {unit{
      Dom_html.window##onresize <-
        Dom.handler (fun _ -> resize_body(); Js._true;);
      resize_body();
      generate_gallery_js();
    }};
  Lwt.return
    (Eliom_tools.F.html
       ~title:title
       ~css:[["css";"exercice_de_style.css"]]
       ~js:[["script";"jquery-1.11.1.min.js"];["script";"gallery.js"]]
       (body [
           header [header_container];
           body_container body_content;
           footer
         ]))

(*************)
(* Home Page *)
(*************)

let home_page = 
  div ~a:[a_style "text-align: center; height: 100%"] [
    img ~alt:("home-image")
      ~a:[a_style "max-height: 100%; max-width: 100%"]
      ~src:(make_uri ~service:(Eliom_service.static_dir ()) ["img/home/B23K0049.JPG"]) ()
  ]

let _ =
  Exercice_de_style_app.register
    ~service:home_service
    (fun () () -> skeletton [home_page] "Vladana Jonquet")

(****************)
(* Gallery Page *)
(****************)

let gallery_page =
  div ~a:[a_id "viewer-container"] [
    ul ~a:[a_id "thumbs"] [
      li [
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/01_IMG_7682.JPG"]) ();
          div ~a:[a_style "width: 250px; margin-right: 30px; display:none;"] [

          ]
        ] ["img/gallery/01_IMG_7682.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/02_IMG_9192_v2.JPG"]) ();
          div ~a:[a_style " display:none;"] [
            h3 [pcdata "Irving Penn (1917-2009) : Christmas at Cuzco, \"Fruit vendor from the valley\" (1948)"];
            p [pcdata "Tirage argentique de 1949"; br ();
               pcdata "Au dos: Etiquette manuscrite de parution: crédit, titre, parution:«page 88 December 1949 Vogue», cachet humide copyright"; br (); 
               pcdata "Dimension : 19,6 x 19,4 cm (image) - 25,4 x 20,6 cm (feuille)"]
          ]
        ] ["img/gallery/02_IMG_9192_v2.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/03_IMG_7935.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            h3 [pcdata "Adree  Bloc (1896-1966) : Sans Titre (1956)"];
            p [pcdata "Sérigraphie couleurs"; br ();
               pcdata "Signée en bas a droite"; br ();
               pcdata "Dimensions :  21 x 32 cm"; br ()]
          ]
        ] ["img/gallery/03_IMG_7935.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/04_IMG_8328.JPG"]) ();
          div ~a:[a_style "width: 250px; margin-right: 30px; display:none;"] [
            
          ]
        ] ["img/gallery/04_IMG_8328.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/05_B23K0051-2.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            h3 [pcdata "Fernand LÉGER (1881-1955) : La lecture (1924)"];
            p [pcdata "Lithographie en couleurs"; br ();
               pcdata "Signée par l’artiste a la mine de plomb et numerotee 299/350"; br ();
               pcdata "Éditée par la Galerie Louis Carré, Paris 1953. Imprimée par Mourlot, tirage à 350 exemplaires."; br ();
               pcdata "Dimensions 55 x 70 cm"; br ()];
            h3 [pcdata "Gunnar Nylund (1904-1997) : Vases biomorphiques la  série Caolina"];
            p [pcdata "Grès noir,"; br ();
               pcdata "Signés GN avec la triple couronne de la manufacture Rörstrand, Suede"];
            h3 [pcdata "Jacques Adnet (1900-1984) :"];
            p [pcdata "Petit meuble à musique en placage de sycomore à corps quadrangulaire souligné de filets en bronze doré ouvrant en façade par deux portes et surmonté d'une trappe montée sur des charnières. Il repose sur quatre pieds cubiques."; br ();
               pcdata "Vers 1940"; br ();
               pcdata "Dimensions 90,5 x 96,5 x 47,5 cm"];
            h3 [pcdata "Rome IIe siècle  : Tete masculine barbue provenant d’un sarcophage"];
            p [pcdata "Marbre"; br ();
               pcdata "Dimensions : H 9 cm"]
          ]
        ] ["img/gallery/05_B23K0051-2.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/06_IMG_7595.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            p [pcdata "Importante lampe à poser en laiton et socle en bois. Vers 1960."; br ();
               pcdata "Editeur américain Laurel."];
            h3 [pcdata "CARL HARRY STAHLANE (NÉ EN 1920) : Vase en gres"];
            p [pcdata "Signé"; br ();
               pcdata "Manufacture Rörstrand"; br ();
               pcdata "Dimensions : 27 cm"];
            h3 [pcdata "Wilhelm KAGE (1889-1960) : Coupe de la série \"Argenta\", vers 1940"];
            p [pcdata "Grès , manufacture Gustavsberg"; br ();
               pcdata "Diamètre 18 cm"]
          ]
        ] ["img/gallery/06_IMG_7595.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/07_IMG_7737.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            h3 [pcdata "Charles Lapicque (1898-1988) : Littoral breton (1952)"];
            p [pcdata "Pinceau et encre de chine sur papier"; br ();
               pcdata "Signé en bas a droite et date 52"; br ();
               pcdata "Dimensions : 45 x 56 cm"];
            h3 [pcdata "Gunnar Nylund (1904-1997) : Une petite coupe en grès noir"];
            p [pcdata "Grès noir"; br ();
               pcdata "Signe GN avec la triple couronne de la manufacture Rorstrand, Suede"; br ();
               pcdata "Dimensions : 8 x 16 x 12 cm"];
            h3 [pcdata "Jean & Robert Cloutier :  Vase \"Le Taureau\" (1960)"];
            p [pcdata "Céramique noire vernie, intérieure rouge"; br ();
               pcdata "Signé « Cloutier RJ » au revers"; br ();
               pcdata "Dimensions : 13 x 20 cm"];
          ]
        ] ["img/gallery/07_IMG_7737.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/08_IMG_7760.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/08_IMG_7760.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/09_IMG_7852.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/09_IMG_7852.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/10_IMG_7889.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/10_IMG_7889.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/11_IMG_8331.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/11_IMG_8331.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/12_IMG_8505 1.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/12_IMG_8505 1.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/13_IMG_8545.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/13_IMG_8545.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/14_IMG_9095.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/14_IMG_9095.JPG"];
        a (Eliom_service.static_dir ()) [
          img ~alt:("1") 
            ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                    ["img/gallery/thumbs/15_IMG_9126.JPG"]) ();
          div ~a:[a_style "display:none;"] [
            
          ]
        ] ["img/gallery/15_IMG_9126.JPG"];
      ]
    ]
  ]

let _ =
  Exercice_de_style_app.register
    ~service:gallery_service
    (fun () () -> skeletton [gallery_page] "Actuellement dans la galerie")

(*************)
(* Deco Page *)
(*************)

let deco_page =
  [
    div ~a:[a_style "float: left; width: 250px; margin-right: 30px;"] [
      h3 [pcdata "Décoration Intérieure"];
      p [ pcdata "Dans une démarche esthétique exigeante je vous offre une approche personnalisée de la décoration de votre intérieur.  
    Pour un amateur ou un collectionneur je propose des conseils ou un projet précis afin de créer  des décors contemporains et sophistiqués ou chaque objet ou oeuvre est mis en valeur.
    Je vous propose dès maintenant de partir à la découverte de mon site et des oeuvres que";
          a gallery_service [pcdata "j’ai choisies pour vous"] ();
          pcdata ".";
        ]
    ];
    div ~a:[a_id "viewer-container"] [
      ul ~a:[a_id "thumbs"] [
        li [
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/2013-10-13 13.24.36.JPG"]) ()
          ] ["img/decoration/2013-10-13 13.24.36.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/B23K0077.JPG"]) ()
          ] ["img/decoration/B23K0077.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/CU8D0029.JPG"]) ()
          ] ["img/decoration/CU8D0029.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_7674.JPG"]) ()
          ] ["img/decoration/IMG_7674.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_7916.JPG"]) ()
          ] ["img/decoration/IMG_7916.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_7924.JPG"]) ()
          ] ["img/decoration/IMG_7924.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_7958.JPG"]) ()
          ] ["img/decoration/IMG_7958.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_8303.JPG"]) ()
          ] ["img/decoration/IMG_8303.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_8373.JPG"]) ()
          ] ["img/decoration/IMG_8373.JPG"];
          a (Eliom_service.static_dir ()) [
            img ~alt:("1") 
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["img/decoration/thumbs/IMG_8534.JPG"]) ()
          ] ["img/decoration/IMG_8534.JPG"];
        ]
      ]
    ]
  ]

let _ =
  Exercice_de_style_app.register
    ~service:deco_service
    (fun () () -> skeletton deco_page "Décoration Intérieure")

(******************)
(* Philosphy Page *)
(******************)

let philosophy_page = 
  div ~a:[a_style "max-width: 1000px; margin-left: auto; margin-right: auto; max-height: 100%; overflow: auto"] [
    aside ~a:[a_style "float: left; width: 520px;"] [
      img ~alt:("Portrait")
        ~a:[a_width 500]
        ~src:(make_uri ~service:(Eliom_service.static_dir ()) ["img/portrait.JPG"]) ()
    ];
    div ~a:[a_class ["presentation"]] [
      h3 [pcdata "ART CONSEIL"];
      p [pcdata "Pour décorer votre intérieur avec originalité ou envisager l'aventure d'une collection, je vous propose mon assistance dans la découverte du monde de l'art et des conseils éclairés pour l'acquisition d’œuvres d'art de qualité  L'offre étant aujourd’hui particulièrement vaste et complexe, je mets à votre disposition mon expertise pour vous permettre d'affiner votre regard et de trouver les œuvres qui vous correspondent.  En vous accompagnant en grandes foires internationales, galeries ou salles de vente, je serai heureuse de vous guider dans les différentes tendances et les multiples mouvements qui animent l'art  moderne et contemporain. 
Acquérir des œuvres d'art participe également d'une stratégie de valorisation patrimoniale. C'est la raison pour laquelle le choix d’œuvres de qualité disposant d’un potentiel d’appréciation est essentiel. Je vous offre mes compétences et ma connaissance du marché d'art international afin de sécuriser et d'optimiser votre patrimoine en alliant le plaisir avec la qualité de placement."]
    ];
    br ();
    p [pcdata "Services proposés :"];
    ul ~a:[a_style "list-style-type:circle"] [
      li [pcdata "§ analyse du marché de l'art et de ses meilleures opportunités"];
      li [pcdata "§ représentation lors des ventes aux enchères"];
      li [pcdata "§ vérification de l'authenticité et de la valeur d'une oeuvre ou d'un objet"];
      li [pcdata "§ gestion logistique - transport"];
      li [pcdata "§ conseil en gestion des collections - valorisation documentaire"];
    ];
    h3 [pcdata "PARCOURS"];
    p [pcdata "Historienne de l'art de formation et diplômée de l'Ecole du Louvre, j'ai travaillé pendant plus de vingt ans à la Réunion des Musées Nationaux, un établissement public qui joue un rôle phare dans la valorisation des collections des musées français et qui organise de grandes expositions d’art de niveau international.
Spécialiste en art moderne j'ai une parfaite connaissance du marché de l'art et de ses acteurs ainsi que des collections publiques ou privées du monde entier."]
  ]

let _ =
  Exercice_de_style_app.register
    ~service:philosophy_service
    (fun () () -> skeletton [philosophy_page] "Philosophie")

