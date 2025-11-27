# install.packages('pmtiles', repos = c('https://walkerke.r-universe.dev', 'https://cloud.r-project.org'))
library(pmtiles)

#######################################
#représenter un pmtiles en mode serveur, visualisation proche de ce qu'on a ici : https://pmtiles.io/#
#permet de connaitre la structure du fichier pmtiles
#######################################

#lance un serveur qui affiche le fichier pmtiles
pm_view(
  input = "data/output/geo_with_data.pmtiles",
  inspect_features = TRUE # popup qui affiche les "propriétés" du fichier pmtiles
)

#pour arrêter le serveur qui appelle le fichier pmtiles
pm_stop_server()

