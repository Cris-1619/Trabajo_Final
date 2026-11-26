
library(tidyverse)
library(readxl)
library(here)

datos <- read_excel(
  here("datos_raw", "Dataset_Trabajo_VDA.xlsx")
)

# Antibióticos que analizaremos
antibioticos <- c(
  "AMX", "AZM", "CIP", "SMX", "CFX",
  "CLR", "AMP", "LEV", "MTZ", "OTC"
)

columnas_ab <- paste0(antibioticos, "_ng_L")

# Verificar columnas
stopifnot(all(columnas_ab %in% names(datos)))

# Transformar de formato ancho a largo
datos_largos <- datos %>%
  pivot_longer(
    cols = all_of(columnas_ab),
    names_to = "Antibiotico",
    values_to = "Concentracion_ng_L"
  ) %>%
  mutate(
    Antibiotico = str_remove(
      Antibiotico, "_ng_L$"
    )
  )

# Guardar datos procesados
dir.create(
  here::here("datos_procesados"),
  showWarnings = FALSE,
  recursive = TRUE
)

saveRDS(
  datos_largos,
  here::here("datos_procesados", "datos_largos.rds")
)

write_csv(
  datos_largos,
  here::here("datos_procesados", "datos_largos.csv")
)
