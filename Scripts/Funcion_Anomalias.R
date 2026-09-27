
library(tidyverse)

diccionario <- tibble(
  variable = c(
    "Temperatura_Agua_C",
    "Concentracion",
    "Caudal_m3_s"
  ),

  descripcion = c(
    "Temperatura del agua en el punto de muestreo",
    "Concentración de antibióticos en el agua",
    "Caudal registrado en el punto de muestreo"
  ),

  unidad = c("°C", "ng/L", "m³/s"),

  valores_esperados = c(
    "Entre 0 y 40 °C",
    "Mayor o igual a 0 ng/L",
    "Mayor o igual a 0 m³/s"
  )
)

print(diccionario)


validar_datos <- function(datos) {

  datos |>
    mutate(
      valida_temperatura =
        !is.na(Temperatura_Agua_C) &
        between(Temperatura_Agua_C, 0, 40),

      valida_concentracion =
        !is.na(Concentracion) &
        Concentracion >= 0,

      valida_caudal =
        !is.na(Caudal_m3_s) &
        Caudal_m3_s >= 0,

      registro_valido =
        valida_temperatura &
        valida_concentracion &
        valida_caudal)
}

