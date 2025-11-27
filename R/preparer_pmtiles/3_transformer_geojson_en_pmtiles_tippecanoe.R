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


system("tippecanoe -o data/output/fm.pmtiles --minimum-zoom=4 --maximum-zoom=11 --force --drop-rate=0 --no-feature-limit --no-tile-size-limit --layer=iris_pop_retraite data/derived/fm.geojson")
