##################################################################################
#Enrichir le fichier geojson avec des indicateurs du recensement de la population 2022
##################################################################################

library(sf)
library(dplyr)

#chemin du fichier geojson
chemin_geojson <- "Z:/carto/présentation tuiles/fonds carte iris/fm.geojson"

#chemin du fichier RP 2022 qui contient les indicateurs qui nous intéressent
#où trouver le fichier https://www.insee.fr/fr/statistiques/8647014
chemin_fichier_rp_2022 <- "Z:/carto/présentation tuiles/données/base-ic-evol-struct-pop-2022.CSV"

#import du fichier geojson pour la france métropolitaine
fm <- st_read(chemin_geojson)

#afficher les iris de loire atlantique. A noter que la base est assez lourde.
#par exemple si on veut afficher les iris des pays de la loire, R a du mal à suivre. Il faut être patient.
plot(fm[which(substr(fm$CODE_IRIS,1,2) %in% c("44")),1])

#import des données du RP 2022
donnee_rp<- read.csv2(chemin_fichier_rp_2022,dec=".") |> select(IRIS,C22_POP15P,C22_POP15P_STAT_GSEC32)
#C22_POP15P : nombre de personnes de 15 ans ou plus
#C22_POP15P_STAT_GSEC32 : nombre de personnes de 15 ans ou plus à la retraite

#part des retraités parmi les 15 ans ou plus
donnee_rp$part_retraite_15p <- round(donnee_rp$C22_POP15P_STAT_GSEC32/donnee_rp$C22_POP15P*100,2)

#fusion des données (dans la table donnee_rp) et de la géographie (dans la table fm)
fm <- merge(fm,donnee_rp,by.x="CODE_IRIS",by.y="IRIS",all.x=T,all.y=F)

#export du fichier geojson
st_write(fm,chemin_geojson)
