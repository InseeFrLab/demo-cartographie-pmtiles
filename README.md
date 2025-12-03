# Démonstration carte interactive de données fines

Exemple minimal de création et visualisation d'une carte interactive "fluide" de données fines à l'aide de R, [tippecanoe](https://github.com/felt/tippecanoe), [maplibre](https://maplibre.org/), et le format [pmtiles](https://docs.protomaps.com/pmtiles/).

L'exemple donné consiste à représenter une donnée issue du [recensement de la population de l'Insee](https://www.insee.fr/fr/metadonnees/definition/c1486) par [Iris](https://www.insee.fr/fr/metadonnees/definition/c1523) sur l'ensemble de la France métropolitaine (**+48 000** territoires/polygones), mais peut servir de base pour produire une carte équivalente sur tout autre donnée et territoires.

Le principe présenté est utilisé par [l'outil interactif de cartographie infracommunale de l'Insee](https://www.insee.fr/fr/outil-interactif/7737357/index.html). L'approche consiste à réunir contours géographiques et données un même fichier "tuilé" et pré-calculer des indicateurs afin d'en proposer rapidement un rendu. Certains aspects sont ici volontairement éludés et seraient à étudier pour application en production : optimisation du poids des tuiles générées, fusion des données et contours métropole et DOM, ...

![Part des retraités par iris sur le côte Atlantique](capture.png)

## Installation
Pré-requis :
- [tippecanoe](https://github.com/felt/tippecanoe?tab=readme-ov-file#installation) (Linux/Mac requis)
- R

Le projet peut s'exécuter notamment dans [un service RStudio du SSPcloud](https://datalab.sspcloud.fr/). Exécuter ensuite `0_install_tippecanoe.sh` pour installer tippecanoe.

## Utilisation

### 1 - Préparer le jeu de données tuilé (pmtiles)

Le script `R/1_preparer_pmtiles.R` permet de préparer le jeu de données tuilé à représenter, en plusieurs étapes :
* Téléchargement & décompression
* Conversion en geojson des contours
* Enrichir le fichier geojson avec les données
* Générer un fichier tuilé pmtiles

### 2 - Visualiser le jeu de données en R

Le script `R/2_visualiser_pmtiles.R` permet d'afficher dans R un fichier pmtiles.

### 3 - Visualiser le jeu de données sur une page web

`index.html` propose un rendu basique avec maplibre du jeu de données tuilé.
