library(archive) # to deal with 7-Zip format

# Script de récupération de la géo et données nécessaires
# Veiller en particulier à ce que la géographie des données et des contours concordent

# Paramètres --------------------------------------------------------------

## Données ----------------------------------------------------------------
# Insee - RP Iris Population en 2022 https://www.insee.fr/fr/statistiques/8647014
url_data <- "https://www.insee.fr/fr/statistiques/fichier/8647014/base-ic-evol-struct-pop-2022_csv.zip"

## Contours ----------------------------------------------------------------
# Iris GE 2022 - https://geoservices.ign.fr/irisge
url_geo <- "https://data.geopf.fr/telechargement/download/IRIS-GE/IRIS-GE_2-0__SHP__FRA_2022-01-01/IRIS-GE_2-0__SHP__FRA_2022-01-01.7z"

# Téléchargement & décompression -------------------------------------------

## Données ----------------------------------------------------------------
path_zip_data <- file.path(tempdir(), "data.zip")

utils::download.file(url = url_data,
                     destfile = path_zip_data)

utils::unzip(zipfile = path_zip_data,
             exdir="data/raw/")

## Contours ----------------------------------------------------------------
path_7z_geo <- file.path(tempdir(), "geo.7z")

utils::download.file(url = url_geo,
                     destfile = path_7z_geo)

archive::archive_extract(path_7z_geo,
                         dir = "data/raw")

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

##################################################################################
#Enrichir le fichier geojson avec des indicateurs du recensement de la population 2022
##################################################################################

library(sf)
library(dplyr)

chemin_geojson <- "data/derived/geo.geojson"
chemin_donnees <- "data/raw/base-ic-evol-struct-pop-2022.CSV"

chemin_geojson_with_data <- "data/derived/geo_with_data.geojson"

#import du fichier geojson pour la france métropolitaine
fm <- st_read(chemin_geojson)

# Au besoin afficher les iris de loire atlantique. A noter que la base est assez lourde.
# Par exemple si on veut afficher les iris des pays de la loire, R a du mal à suivre. Il faut être patient.
# plot(fm[which(substr(fm$CODE_IRIS,1,2) %in% c("44")),1])

#import des données du RP 2022
donnee_rp <- read.csv2(chemin_donnees, dec=".") |> 
  select(IRIS,C22_POP15P,C22_POP15P_STAT_GSEC32)
#C22_POP15P : nombre de personnes de 15 ans ou plus
#C22_POP15P_STAT_GSEC32 : nombre de personnes de 15 ans ou plus à la retraite

#part des retraités parmi les 15 ans ou plus
donnee_rp$part_retraite_15p <- round(donnee_rp$C22_POP15P_STAT_GSEC32/donnee_rp$C22_POP15P*100, 2)

#fusion des données (dans la table donnee_rp) et de la géographie (dans la table fm)
fm <- merge(fm,
            donnee_rp,
            by.x="CODE_IRIS",
            by.y="IRIS",
            all.x=T,
            all.y=F)

#export du fichier geojson
st_write(fm, chemin_geojson_with_data)

# générer un fichier tuilé pour les iris\communes entre le zoom 4 et le zoom 11 avec l'outil tippecanoe

## tippecanoe : nom de l'outil qui construit le fichier tuilé pmtiles, cet outil doit être installé
## fm.pmtiles : fichier tuilé en sortie
## fm.geojson : fichier geojson en entrée
## --minimum-zoom=4 : zoom minimum auquel on veut représenter les iris\communes
## --maximum-zoom=11 : zoom maximal auquel on veut représenter les iris\communes
## au-delà du zoom 11 le fond de carte continu à s'afficher mais les polygones ne gagnent pas en qualité
## --layer=iris_pop_retraite : iris_pop_retraite est le nom de la couche dans le fichier tuilé, il contient la géométrie + les indicateurs
## --no-tile-size-limit ne limite pas la taille des tuiles
## --force : écrase le fichier pmtiles s'il existe déjà
## --drop-rate=0, --no-feature-limi et --no-tile-size-limit sont des paramètres qui limitent au maximum la simplification des polygones, on aura ici des polygones bien définis, ce qui peut parfois entrainer des lenteur sur la carte

## la fonction system de R permet d'exécuter à partir d'un script R des commandes dans un terminal

system("tippecanoe -o data/output/geo_with_data.pmtiles --minimum-zoom=4 --maximum-zoom=11 --force --drop-rate=0 --no-feature-limit --no-tile-size-limit --layer=data data/derived/geo_with_data.geojson")
