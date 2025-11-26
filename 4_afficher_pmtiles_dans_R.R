library(pmtiles)
library(mapgl)
library(mapboxapi)
#chemin vers le fichier pmtiles que l'on veut afficher
chemin_pmtiles <- "Z:/carto/présentation tuiles/fm.pmtiles"

#######################################
#représenter un pmtiles en mode serveur
#######################################

#lance un serveur qui affiche le fichier pmtiles
pm_view(
  chemin_pmtiles,
  layer_type = "fill", #représentation de type choroplèthe
  fill_color = "#125", #couleur des iris\communes
  fill_opacity = 0.4, #opacité par rapport au fond de carte
  inspect_features = TRUE) #popup qui affiche les "prop

#pour arrêter le serveur qui appelle le fichier pmtiles
pm_stop_server()

############################
############################
#https://gist.github.com/walkerke/cf87df489be8065635cf9b0c0dee34f5
#page d'aide https://walkerke.r-universe.dev/pmtiles
pm_serve(chemin_pmtiles, port = 8080)


maplibre(center = c(2, 48), zoom= 4) |>
  set_projection("globe") |> 
  add_vector_source("pmtiles_source",
                    url = "pmtiles://http://localhost:8080/fm.pmtiles"
  ) |>
  add_fill_layer(
    id = "iris_pop_retraite",
    source = "pmtiles_source",
    source_layer = "iris_pop_retraite",
    tooltip = "indice_retraite",
    fill_color = interpolate(
      column = "indice_retraite",
      values = c(0,21,27,32,39,50),
      stops = c("#fbd9d9", "#f8aeb1","#fa7075", "#fa4545","#fb1e1e","#8e0000")),
    fill_opacity = 0.9
  ) |> add_line_layer(
    id = "contour_iris_com",
    source = "pmtiles_source",
    source_layer = "iris_pop_retraite",
    line_color = "blue",
    line_width = 0.2,
    line_opacity = 0.7
  )  |>
  add_control(
    html = '<div id="legend_iris_com" class="legend">
        <h4>Parmi les 15 ans ou plus, part des retraités (en %) </h4>
        <div><span style="background-color: #D3D3D3"></span>Valeur manquante</div>
      <div><span style="background-color: #fbd9d9"></span>Inférieur à 21%</div>
      <div><span style="background-color: #f8aeb1"></span>Entre 21 % et 27 % exclu</div>
      <div><span style="background-color: #fa7075"></span>Entre 27 % et 32 % exclu</div>
      <div><span style="background-color: #fa4545"></span>Entre 32 % et 39 % exclu</div>
      <div><span style="background-color: #fb1e1e"></span>Entre 39 % et 50 % exclu</div>
      <div><span style="background-color: #8e0000"></span>50 % ou plus</div>
      </div>',
    position = "botton-left"
  )




