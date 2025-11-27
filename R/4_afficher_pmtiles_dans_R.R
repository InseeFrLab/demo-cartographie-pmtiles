# install.packages('pmtiles', repos = c('https://walkerke.r-universe.dev', 'https://cloud.r-project.org'))
library(pmtiles)

#######################################
#représenter un pmtiles en mode serveur, visualisation proche de ce qu'on a ici : https://pmtiles.io/#
#permet de connaitre la structure du fichier pmtiles
#######################################

#chemin vers le fichier pmtiles que l'on veut afficher
chemin_pmtiles <- "data/output/geo_with_data.pmtiles"

#lance un serveur qui affiche le fichier pmtiles
pm_view(
  chemin_pmtiles, #chemin vers le fichier pmtiles
  layer_type = "fill", #représentation de type choroplèthe
  fill_color = "#125", #couleur des iris\communes
  fill_opacity = 0.4, #opacité par rapport au fond de carte
  inspect_features = TRUE #popup qui affiche les "propriétés" du fichier pmtiles
)

#pour arrêter le serveur qui appelle le fichier pmtiles
pm_stop_server()

