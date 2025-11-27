##################################################################################
#Créer un fichier geojson depuis un fichier shapefile pour les iris de France métropolitaine
##################################################################################
library(sf)
library(dplyr)

chemin_shapefile_geopackage <- "data/raw/IRIS-GE_2-0__SHP__FRA_2022-01-01/IRIS-GE/1_DONNEES_LIVRAISON_2022-05-00267/IRIS-GE_2-0_SHP_LAMB93_FXX-2022/IRIS_GE.SHP"

#chemin du fichier en sortie qui est le fichier geojson
chemin_geojson <- "data/derived/geo.geojson"

#charger un fichier shapefile en mémoire
fm <- st_read(chemin_shapefile_geopackage)

#au besoin afficher les 5 premières ligne du fichier
#View(fm[1:5,])

#projeter en wgs 84 (code crs=4326) la géométrie (https://fr.wikipedia.org/wiki/WGS_84)
fm <- st_transform(fm, crs = 4326)
st_crs(fm)

#export de la table fm au format geojson 
# (à noter que l'export peut être un peu long et que le fichier geojson peut être important, supérieur à 1 go pour les zonages à l'iris)
st_write(fm, chemin_geojson, driver = "GeoJSON")
