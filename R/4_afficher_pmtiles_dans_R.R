library(pmtiles)
library(mapgl)
library(mapboxapi)

#chemin vers le fichier pmtiles que l'on veut afficher
chemin_pmtiles <- "Z:/carto/présentation tuiles/afficher pmtiles/fm.pmtiles"

#######################################
#représenter un pmtiles en mode serveur, visualisation proche de ce qu'on a ici : https://pmtiles.io/#
#permet de connaitre la structure du fichier pmtiles
#######################################

#lance un serveur qui affiche le fichier pmtiles
pm_view(
  chemin_pmtiles,#chemin vers le fichier pmtiles
  layer_type = "fill", #représentation de type choroplèthe
  fill_color = "#125", #couleur des iris\communes
  fill_opacity = 0.4, #opacité par rapport au fond de carte
  inspect_features = TRUE) #popup qui affiche les "propriétés" du fichier pmtiles

#pour arrêter le serveur qui appelle le fichier pmtiles
pm_stop_server()

############################
#représenter un pmtiles en mode serveur avec un choroplèthe
############################
#https://gist.github.com/walkerke/cf87df489be8065635cf9b0c0dee34f5
#https://walkerke.r-universe.dev/pmtiles

#lancer le serveur
pm_serve(chemin_pmtiles, port = 8080)


#création de la carte
maplibre(center = c(2, 48), zoom= 4) |># on utilise la bibliothèque maplibre
  set_projection("globe") |> #on choisit la projection de type globe
  add_vector_source(# permet d'aller pointer vers le fichier pmtiles que l'on veut interroger
    "pmtiles_source", #nom donnée au fichier pmtiles pour R
                    url = "pmtiles://http://localhost:8080/fm.pmtiles"#url du fichier pmtiles qui sera requêté pour construire la carte
  ) |>
  add_fill_layer(#permet d'ajouter les choroplèthes
    id = "iris_pop_retraite",# nom de la couche
    source = "pmtiles_source",#fait référence au nom que l'on donne dans "add_vector_source" pour le fichier pmtiles utilisé
    source_layer = "iris_pop_retraite",#nom de la couche dans le pmtiles que l'on veut représenter
    tooltip = "part_retraite_15p",#variable que l'on veut utiliser pour colorer la carte
    fill_color = interpolate(
      column = "part_retraite_15p",#variable que l'on veut utiliser pour colorer la carte
      values = c(0,21,27,32,39,50),#les seuils des différentes classes
      stops = c("#fbd9d9", "#f8aeb1","#fa7075", "#fa4545","#fb1e1e","#8e0000")),#les couleurs des différentes classes
    fill_opacity = 0.9# opacité 
  ) |> add_line_layer(#permet d'ajouter les contours des iris\communes
    id = "contour_iris_com",#nom donné aux contours des iris\communes
    source = "pmtiles_source",#fait référence au nom que l'on donne dans "add_vector_source" pour le fichier pmtiles utilisé
    source_layer = "iris_pop_retraite",#nom de la couche dans le pmtiles que l'on veut représenter
    line_color = "blue",#couleur des frontières
    line_width = 0.2, #largeur des frontières
    line_opacity = 0.9 #opacité des frontières
  ) |>
  add_control(#permet d'ajouter une légende ou par exemple un titre, elle est construite en html
    #####
    #.legend définit la légende de manière globale
    ####
    #par exemple, background: white veut dire que l'on veut l'arrière plan en blanc
    #####
    #.legend div définit chaque ligne de la légende
    ####
    #par exemple margin-bottom: 4px correspond à l'écart entre 2 lignes de la légende 
    #####
    #.legend span définit les carrés colorés de la légende
    ####
    #par exemple width: 14px; et height: 14px; définissement la largeur et la hauteur des carrés de la légende
    
    html = '<style>
    .legend {
      background: white;
      padding: 10px;
      line-height: 1.4;
      font-size: 12px;
    }
    .legend div {
      display: flex;
      align-items: center;
      margin-bottom: 4px;
    }
    .legend span {
      display: inline-block;
      width: 14px;
      height: 14px;
      margin-right: 6px;
      border: 1px solid #555;
    }
  </style>

  <div id="legend_iris_com" class="legend">
    <h4>Parmi les 15 ans ou plus, part des retraités (en %)</h4>
    <div><span style="background-color: #000000"></span>Valeur manquante</div>
    <div><span style="background-color: #fbd9d9"></span>Inférieur à 21%</div>
    <div><span style="background-color: #f8aeb1"></span>Entre 21 % et 27 % exclu</div>
    <div><span style="background-color: #fa7075"></span>Entre 27 % et 32 % exclu</div>
    <div><span style="background-color: #fa4545"></span>Entre 32 % et 39 % exclu</div>
    <div><span style="background-color: #fb1e1e"></span>Entre 39 % et 50 % exclu</div>
    <div><span style="background-color: #8e0000"></span>50 % ou plus</div>
  </div>', # ce bloc construit la légende ligne à ligne, aves les couleurs et les libellés associés
    position = "top-right" #permet de mettre la légende en haut à droite
  )


#pour arrêter le serveur qui appelle le fichier pmtiles
pm_stop_server()

