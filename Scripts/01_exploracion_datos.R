
library(tidyverse)
library(readxl)
library(lubridate)
library(skimr)
library(here)

# 1. Importar datos originales
datos <- read_excel(
  here("datos_raw", "Dataset_Trabajo_VDA.xlsx")
)

# 2. Revisar estructura
glimpse(datos)

# 3. Revisar dimensiones
dim(datos)

# 4. Nombres de variables
names(datos)

# 5. Valores faltantes
colSums(is.na(datos))

# 6. Resumen descriptivo
skim(datos)

# 7. Identificar sitios de muestreo
datos %>%
  count(Nombre_Sitio)

# 8. Revisar fechas
summary(datos$Fecha)
