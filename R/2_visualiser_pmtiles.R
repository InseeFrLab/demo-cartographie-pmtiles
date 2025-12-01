# Visualiser le pmtiles depuis R
# Avertissement : expérimental, repose sur des packages jeunes et en cours de développement

# install.packages('pmtiles', repos = c('https://walkerke.r-universe.dev', 'https://cloud.r-project.org'))
library(pmtiles)
# La version sur le CRAN ne semble pas opérationnelle, préférer celle de dev :
# remotes::install_github("walkerke/mapgl")
library(mapgl)

chemin_pmtiles <- "data/output/geo_avec_donnees.pmtiles"

# 1) Visualiser le pmtiles (comme sur pmtiles.io) -------------------------

# Show basic info
pm_show(chemin_pmtiles)

# lance un serveur qui affiche le fichier pmtiles
pm_view(
  input = chemin_pmtiles,
  source_layer = "data",
  #TODO sspcloud/à creuser : port 8080 ne fonctionne pas, changé pour 58080
  port = 58080,
  inspect_features = TRUE # popup qui affiche les "propriétés" du fichier pmtiles
)

# Penser à arrêter le serveur après !
pm_stop_server()

#chemin vers le fichier pmtiles que l'on veut afficher

# 2) Représenter un pmtiles en mode serveur avec un choroplèthe ----------

#https://gist.github.com/walkerke/cf87df489be8065635cf9b0c0dee34f5
#https://walkerke.r-universe.dev/pmtiles

#lancer le serveur
pm_serve(chemin_pmtiles, port = 58080)

#création de la carte
maplibre(center = c(2, 48), zoom= 4) |># on utilise la bibliothèque maplibre
  add_vector_source(# permet d'aller pointer vers le fichier pmtiles que l'on veut interroger
    "pmtiles_source", #nom donnée au fichier pmtiles pour R
    url = "pmtiles://http://localhost:58080/geo_avec_donnees.pmtiles" #url du fichier pmtiles qui sera requêté pour construire la carte
  ) |>
  add_fill_layer(#permet d'ajouter les choroplèthes
    id = "data",# nom de la couche
    source = "pmtiles_source",#fait référence au nom que l'on donne dans "add_vector_source" pour le fichier pmtiles utilisé
    source_layer = "data",#nom de la couche dans le pmtiles que l'on veut représenter
    tooltip = "part_retraite_15p",#variable que l'on veut utiliser pour colorer la carte
        fill_color = list(
      "step",
      list("get", "part_retraite_15p"),
      "#fbd9d9", 21,#inférieur à 21 %
      "#f8aeb1", 27,#Entre 21 % et 27 % exclu
      "#fa7075", 32,#Entre 27 % et 32 % exclu
      "#fa4545", 39,#Entre 32 % et 39 % exclu
      "#fb1e1e", 50,#>Entre 39 % et 50 % exclu
      "#8e0000"#50 % ou plus
    ),#les couleurs des différentes classes
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
    <h4>Part des retraités parmi les 15 ans ou plus (en %)</h4>
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

