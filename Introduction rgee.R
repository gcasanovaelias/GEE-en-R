# Packages ----------------------------------------------------------------

library(rgee)
library(leaflet)
library(leaflet.extras)
library(leaflet.extras2)
library(mapview)
library(mapedit)

# GEE and rgee ------------------------------------------------------------

# Google Earth Engine (GEE)
# GEE es una plataforma de computo en la nube, que aporta una infraestructura así como un toolkit (catalogo de datos) diseñada para el análisis ambiental a nivel planetario (Gorelick et al., 2017). Esta plataforma se caracteriza por ser de libre acceso (gratis) pero, a diferencia de otras, no es de código abierto (no sabemos lo que sucede en el backend), es decir, los usuarios normales no tenemos acceso a los códigos que emplea GEE, sólo los desarrolladores de Google.

# Componentes de GEE:
#* (1) Datasets: Catálogo de datos espaciales (satelitales y otros) más grande del planeta el cual se encuentra en constante crecimiento (> 200 publix datasets, 5 million images, 4000 new images every day) Junto con esto está la posibilidad de importar nuestros propios datos espaciales a la plataforma.
#* (2) Sistema de computo altamente optimizado para el procesamiento en paralelo en base a la infraestructura computacional de Google.
#* (3) Interconexión entre los componentes anteriores mediante Web REST API y Client Libraries: JavaScript, Python, R(rgee), REST.

# Problemas con GEE y su sistema de computo
# Debido a su procesamiento en paralelo, donde cada imagen se subdivide en 256x256 porciones y cada una se dirige a un procesador esclavo para ser posteriormente ser unida en el procesador maestro, existen muchos procesos que no son capaces de realizarse en GEE principalmente aquellos que guarden relación con la recursividad y dependencia de los valores obtenidos en las secciones vecinas (flujo acumulativo por ejemplo). Nosotros como usuarios debemos tener cautela y conocimiento acerca de cuando esta limitante es importante o no para la investigación que estamos realizando.

# API & Client Library
# API (Application Programming Interface) es una interfaz de computo que permite la interacción entre múltiples softwares intermedios. Librerias clientes, como Python y JavaScript en este caso, se emplean para convertir un código en un JSON el cual es capaz de interactuar como un HTTP con el servidor de Google. De esta manera, los lenguajes de programación sólo se emplean para convertir una acción dada por un código en un JSON que será enviado a los servidores de Google. El paquete rgee convierte un código en R a una petición en formato JSON que es enviada a los servidores de Google.

# La API de GEE es absurdamente compleja (en cuanto a volumen) pero a su vez intuitiva con más de 1000 tipos distintos de datos, operadores, entre otros. 

# Librerias cliente
#* JavaScript (JS) es suficiente para principiantes que recien se están interiorizando pero para lo que son proyectos demandantes y ambiciosos presenta serias limitantes en cuanto a la importación y exportación de grandes volumenes de datos además de que la mayor parte de las herramientas para el análisis espacial se encuentran en las librerias de Python.
#* Python y R presentan la ventaja de un buen environment además de grandes herramientas para la visualización, aplicaciones web, etc otorgando una mayor flexibilidad al usuario. Una desventaja es que Python requiere de un mayor conocimiento del lenguaje de programación.

# La principal diferencia entre JS y Python es que en este último siempre será necesario inicializar el código además de que en la primera no se puede correr el código línea por línea.

# rgee
# rgee es un paquete "puente" (binding package) que permite la conexión a la API Google Earth Engine (GEE) desde R (transforma el código en R en una petición en JSON). Para transformar el código de Python (similar tambien al JS) a R simplemente se cambia el símbolo de punto (ee.Image()) por un símbolo de dolar (ee$Image()).

# ¿Cómo funciona rgee por detrás?
# El código en R se somete al paquee reticulate que permite comunicarse con el lenguaje Python, es decir, se transforma el código en R en un código en Python. Este código de R transformado a Python pasa a ser un JSON para comunicarse con los servidores de Google. Esta conversión es muy fácil, dada tipo de dato o estructura en R tiene un uquivalente en Python de modo que esta conversión es inequívoca (en los dos sentidos).

# Más que sólo transcribir código
# rgee no sólo transforma el código a Python sino que se crea una serie funciones por encima de la API de Python de modo de facilitar la comunicación de Google con R.

# Cambios en el I/O de GEE
# Las funciones para importar y exportar de GEE son bastante complicadas por lo que se crean nuevas funciones que son más fáciles de entender para los usuarios de R (los cuales son más verbales en cuanto a sus funciones), entre ellas ee_as_sf() la cual permite descargar objetos shape desde el servidor EE al coputador local como un objeto sf, ó ee_as_raster() para el análogo a RasterStack. Las funciones nativas de GEE siguen disponibles para ser empleadas, solamente que estas nuevas funciones se crean por encima.

# Introduction ------------------------------------------------------------
# https://r-earthengine.github.io/intro_01/


# Instalar dependecnias y Python environment
ee_install(py_env = "rgee")

# Identificación de la cuenta de GEE
ee_Initialize(user = 'gcasanovaelias@gmail.com', drive = T)

# FIRST STEPS

# Get an Image
srtm <- ee$Image("USGS/SRTMGL1_003")

# Get info (similar to the print() in JS)
srtm$bandNames()$getInfo()

# Visualization parameters
viz <- list(
  max = 4000,
  min = 0,
  palette = c("#000000","#5AAD5A","#A9AD84","#FFFFFF")
)

# Add Layer to the Viewer
Map$addLayer(
  eeObject = srtm,
  visParams = viz,
  name = 'SRTM'
)

# Checking the package and Python environment
ee_check()
ee_check_credentials()
ee_check_python()


# Image Overview ----------------------------------------------------------
# https://r-earthengine.github.io/image_01/

# ee.Image constructor
srtm <- ee$Image("USGS/SRTMGL1_003")

# Get an ee.Image from an ee.ImageCollection with filters
sen <- ee$ImageCollection("COPERNICUS/S2")$
  filterBounds(ee$Geometry$Point(-70.48, 43.3631))$
  filterDate('2019-01-01', '2019-12-31')$
  # avoid sorting the entire collection by applying it after the filter
  sort('CLOUDY_PIXEL_PERCENTAGE')$
  first()

# Define visualization parameters
vizParams <- list(
  bands = c("B4", "B3", "B2"),
  min = 0,
  max = 2000,
  gamma = c(0.95, 1.1, 1)
)

# Center the map and display the image
Map$centerObject(sen, 7)
# You can see it
Map$addLayer(sen, vizParams, 'first')

# Display the results in QGis as XYZ Tiles
m1 <- Map$addLayer(sen, vizParams, 'first')
m1$rgee$tokens

# CONSTANTS IMAGES
# We can create images from constants, lists or other suitable Earth Engine objects

# Create a constant Image with a pixel value of 1
image1 <- ee$Image(1)
print(image1, type = "json")
print(image1, type = "simply")
print(image1, type = "ee_print")

print(image1)

# See it
Map$addLayer(image1)

# Concatenate two images into one multi-band image
image2 <- ee$Image(2)
image3 <- ee$Image$cat(c(image1, image2))

print(image3, clean = T) #2 bands

# Change global print option by: "simply", "json", "ee_print"
options(rgee.print.option = "ee_print")

# Create a multi-band image from a list of constants
multiband <- ee$Image(c(1, 2, 3))
print(multiband)

# Select and (optionally) rename bands
renamed <- multiband$select(
  # old names
  opt_selectors = c("constant", "constant_1", "constant_2"),
  # new names
  opt_names = c("band1", "band2", "band3")
)

ee_print(renamed)

# Add bands to an image
image4 <- image3$addBands(ee$Image(42))
print(image4)



# Image Visualizations ----------------------------------------------------
# https://r-earthengine.github.io/image_02/

# (1) RGB composites

landsat <- ee$Image("LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318")

vizParams <- list(
  # False color
  bands = c("B5", "B4", "B3"),
  min = 0,
  max = 0.5,
  gamma = c(0.95, 1.1, 1)
)

Map$setCenter(lon = -122.1899, lat = 37.5010, zoom = 10)
Map$addLayer(landsat, vizParams, 'false color composite')

# (2) Color palettes
# To display a SINGLE BAND of an image in color, set the palette parameter with a color ramp represented by a list of CSS-style color strings

landsat <- ee$Image("LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318")

# Create an NDWI image
ndwi <- landsat$normalizedDifference(c("B3", "B5"))

ndwiViz <- list(
  min = 0.5, 
  max = 1,
  # Continuo de colores entre ambos extremos
  palette = c('00FFFF', '0000FF')
)

Map$addLayer(
  eeObject = ndwi,
  visParams = ndwiViz,
  # Ponerle nombre a la capa
  name = 'NDWI',
  # Mostrar?
  shown = F
)

# (3) Masking
# image$updateMask() sets the opacity of certain pixels based on their value (non-zero). Pixels equal to zero in the mask are excluded from computations and the opacity is set to 0 for display.

# Mask the non-watery parts of the image where NDWI < 0.4
ndwiMasked <- ndwi$updateMask(ndwi$gte(0.4))
Map$addLayer(ndwiMasked, ndwiViz, 'NDWI masked', F)

# (4) Visualization images
# image$visualize() convert an image into an 8-bit RGB image for display or export. For example, convert the false color composite and NDWI to 3-band display images

landsat <- ee$Image("LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318")

imageRGB <- landsat$visualize(
  list(
    bands = list("B5", "B4", "B3"),
    max = 0.5
  )
)

ndwiRGB <- ndwiMasked$visualize(
  list(
    min = 0.5,
    max = 1,
    palette = c('00FFFF', '0000FF')
  )
)

# (5) Mosaicking
# We can use masking and imageCollection$mosaic() to achieve various cartographic effects. The mosaic() method renders layers in the output image according to their order in the input collection.

mosaic <- ee$ImageCollection(list(imageRGB, ndwiRGB))$mosaic()
Map$addLayer(eeObject = mosaic, list(), name = 'mosaic')

# (6) Integration with other R packages
# Map$addLayer() creates a leaflet object, this help the users to customize their interactive maps integrating this function with mapview, mapedit and leaflet packages

landsat <- ee$Image('LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318')

vizParams <- list(
  bands = c('B5', 'B4', 'B3'),
  min = 0, 
  max = 0.5,
  gamma = c(0.95, 1.1, 1)
)

Map$setCenter(lon = -122.1899, lat = 37.5010, zoom = 10)
m1 <- Map$addLayer(eeObject = landsat, visParams = vizParams, name = 'false color composite')
m1$rgee

# leaflet
# R package binding developed by RStudio. Open-spurce JavaScript library for mobile-friendly interactive maps.

leaflet %>% 
  addTiles() %>% 
  setView(-122.1899, 37.5010, 9) %>% 
  addTiles(
    urlTemplate = m1$rgee$tokens,
    layerId = "leaflet_false_color",
    options = leaflet::tileOptions(opacity = 1)
  )

# mapview
# Provides functions to very quickly and conveniently create interactive visualizations of R spatial data. It supports the most popular R packages for spatial data (sf, sp, stars and raster)
stp <- st_sfc(st_point(c(-122.27234, 37.46941)), crs = 4326)
mapview(m1)

# mapedit
# Adds spatial data edition functionality similar to Code Editor geometry tool
my_geom <- editMap(m1)$drawn

# (7) Map Operators
m1 <- Map$addLayer(eeObject = landsat, visParams = vizParams, name = 'false color composite')
m2 <- Map$addLayer(ndwiMasked, ndwiViz, 'NDWI masked')

# overlay layers with `+`
m1 + m2

# Side by side slide View (leaflet.extras2)
m1 | m2


# DEMO --------------------------------------------------------------------


ee_Initialize(drive = TRUE)
ee_user_info()

# Region of interest
roi <- ee$Geometry$Point(c(-122.2575, 37.8795)) %>%
  ee$Geometry$buffer(10000)

## 1. Download a small FeatureCollections
blocks <- ee$FeatureCollection("TIGER/2010/Blocks")
subset <- blocks$filterBounds(roi)
sf_subset <- ee_as_sf(x = subset, maxFeatures = 10000)
plot(sf_subset["countyfp10"])

