##################################################################################
#Créer un fichier geojson depuis un fichier shapefile pour les iris de France métropolitaine
##################################################################################
library(sf)
library(dplyr)

#chemin du fichier en entrée qui peut être un fichier shapefile ou geopackage : fonds de carte trouvés ici : https://geoservices.ign.fr/irisge
chemin_shapefile_geopackage <- "Z:/carto/formation pour cartofine/rp_iris/fond_carte/FM/IRIS_GE.shp"

#chemin du fichier en sortie qui est le fichier geojson
chemin_geojson <- "Z:/carto/présentation tuiles/fonds carte iris/fm.geojson"

#charger un fichier shapefile en mémoire
fm <- st_read(chemin_shapefile_geopackage)

#afficher les 5 premières ligne du fichier
View(fm[1:5,])

#projeter en wgs 84 (code crs=4326) la géométrie (https://fr.wikipedia.org/wiki/WGS_84)
fm <- st_transform(fm, crs = 4326)
st_crs(fm)

#export de la table fm au format geojson (à noter que l'export peut être un peu long et que le fichier geojson peut être important, supérieur à 1 go pour les zonages à l'iris)
st_write(fm, chemin_geojson, driver = "GeoJSON")
