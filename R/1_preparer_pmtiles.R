library(archive) # pour gérer format 7-Zip IGN
library(sf)
library(dplyr)
library(glue)

# 0) Paramètres --------------------------------------------------------------
# Données et contours
# Veiller en particulier à ce que la géographie des données et des contours concordent !

# Insee - RP Iris Population en 2022 https://www.insee.fr/fr/statistiques/8647014
url_data <- "https://www.insee.fr/fr/statistiques/fichier/8647014/base-ic-evol-struct-pop-2022_csv.zip"
chemin_donnees <- "data/raw/base-ic-evol-struct-pop-2022.CSV"

# Iris GE 2022 - https://geoservices.ign.fr/irisge
# TODO Ici France métro uniquement, adapter pour ajouter les DOM (projections différentes à gérer)
url_geo <- "https://data.geopf.fr/telechargement/download/IRIS-GE/IRIS-GE_2-0__SHP__FRA_2022-01-01/IRIS-GE_2-0__SHP__FRA_2022-01-01.7z"
chemin_shapefile_geopackage <- "data/raw/IRIS-GE_2-0__SHP__FRA_2022-01-01/IRIS-GE/1_DONNEES_LIVRAISON_2022-05-00267/IRIS-GE_2-0_SHP_LAMB93_FXX-2022/IRIS_GE.SHP"

# Repertoires de travail
chemin_geojson <- "data/derived/geo.geojson"
chemin_geojson_avec_donnees <- "data/derived/geo_avec_donnees.geojson"
chemin_pmtiles <- "data/output/geo_avec_donnees.pmtiles"

# 1) Téléchargement & décompression ------------------------------------------

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

# 2) Conversion en geojson des contours ------------------------------------

#charger un fichier shapefile en mémoire
geo <- st_read(chemin_shapefile_geopackage)

#au besoin afficher les 5 premières ligne du fichier
#View(geo[1:5,])

#projeter en wgs 84 (code crs=4326) la géométrie (https://fr.wikipedia.org/wiki/WGS_84)
geo <- st_transform(geo, crs = 4326)
st_crs(geo)

# au besoin : export de la table au format geojson 
# (à noter que l'export peut être un peu long et que le fichier geojson peut être important, 
# supérieur à 1 go pour les zonages à l'iris)
# st_write(geo, chemin_geojson, driver = "GeoJSON")

# 3) Enrichir le fichier geojson avec les données ------------------------------

# Au besoin afficher les iris de loire atlantique. A noter que la base est assez lourde.
# Par exemple si on veut afficher les iris des pays de la loire, R a du mal à suivre. Il faut être patient.
# plot(geo[which(substr(geo$CODE_IRIS,1,2) %in% c("44")),1])

#import des données et sélection des variables utiles
donnees <- read.csv2(chemin_donnees, dec=".") |> 
  select(IRIS, C22_POP15P, C22_POP15P_STAT_GSEC32)
#C22_POP15P : nombre de personnes de 15 ans ou plus
#C22_POP15P_STAT_GSEC32 : nombre de personnes de 15 ans ou plus à la retraite

#part des retraités parmi les 15 ans ou plus
donnees$part_retraite_15p <- round(donnees$C22_POP15P_STAT_GSEC32/donnees$C22_POP15P*100, 2)

#fusion des données (dans la table donnees) et de la géographie (dans la table geo)
geo_avec_donnees <- merge(geo,
                          donnees,
                          by.x="CODE_IRIS",
                          by.y="IRIS",
                          all.x=T,
                          all.y=F
                        )

#export du fichier geojson
st_write(
  obj = geo_avec_donnees, 
  dsn = chemin_geojson_avec_donnees,
  # écrase si existe déjà
  append = FALSE, 
  delete_dsn = TRUE
)

# générer un fichier tuilé avec l'outil tippecanoe

## --minimum-zoom=4 : zoom minimum auquel on veut représenter les iris\communes
## --maximum-zoom=11 : zoom maximal auquel on veut représenter les iris\communes
## au-delà du zoom 11 le fond de carte continu à s'afficher mais les polygones ne gagnent pas en qualité
## --layer= : à noter car à reprendre ensuite dans la visualisation : nom de la couche dans le fichier tuilé, il contient la géométrie + les indicateurs
## --no-tile-size-limit ne limite pas la taille des tuiles
## --force : écrase le fichier pmtiles s'il existe déjà
## TODO A ajuster pour optimiser la taille des tuiles
## --drop-rate=0, --no-feature-limit et --no-tile-size-limit sont des paramètres qui limitent au maximum la simplification des polygones, on aura ici des polygones bien définis, ce qui peut parfois entrainer des lenteur sur la carte

## la fonction system de R permet d'exécuter à partir d'un script R des commandes dans un terminal
## et le package glue facilite l'injection des paramètres et les sauts de lignes

system(
  glue(
    "tippecanoe ",
    "{chemin_geojson_avec_donnees} -o {chemin_pmtiles} ",
    "--minimum-zoom=4 --maximum-zoom=11 ",
    "--force ",
    "--drop-rate=0 ",
    "--no-feature-limit ",
    # "--no-tile-size-limit ",
    "--layer=data"
  )
)
