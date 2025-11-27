library(archive) # to deal with 7-Zip format

# Script de récupération de la géo et données nécessaires
# Veiller en particulier à ce que la géographie des données et des contours concordent

# Paramètres --------------------------------------------------------------

## Contours ----------------------------------------------------------------
# Iris GE 2022 - https://geoservices.ign.fr/irisge
# Que du shapefile... Mais geopackage à partir de 2023
url_geo <- "https://data.geopf.fr/telechargement/download/IRIS-GE/IRIS-GE_2-0__SHP__FRA_2022-01-01/IRIS-GE_2-0__SHP__FRA_2022-01-01.7z"

## Données ----------------------------------------------------------------
# Insee - RP Iris Population en 2022 https://www.insee.fr/fr/statistiques/8647014
url_data <- "https://www.insee.fr/fr/statistiques/fichier/8647014/base-ic-evol-struct-pop-2022_csv.zip"

# Téléchargement & décompression -------------------------------------------

## Contours ----------------------------------------------------------------
path_7z_geo <- file.path(tempdir(), "geo.7z")

utils::download.file(url = url_geo,
                     destfile = path_7z_geo)

archive::archive_extract(path_7z_geo,
                         dir = "data/raw")

## Données ----------------------------------------------------------------
path_zip_data <- file.path(tempdir(), "data.zip")

utils::download.file(url = url_data,
                     destfile = path_zip_data)

utils::unzip(zipfile = path_zip_data,
             exdir="data/raw/")
