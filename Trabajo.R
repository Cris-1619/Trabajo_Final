getwd()
library(tidyverse)
library(readxl)

# Importar datos
datos <- read_excel("datos_raw/Dataset_Trabajo_VDA.xlsx")

# Gráfico único: EDAR + Río
grafica<-ggplot(
  datos,
  aes(
    x = Temperatura_Agua_C,
    y = CIP_ng_L,
    color = Nombre_Sitio
  )
) +
  geom_point(size = 3, alpha = 0.75) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "Ciprofloxacino vs temperatura",
    x = "Temperatura del agua (°C)",
    y = "Ciprofloxacino (ng/L)",
    color = "Sitio"
  ) +
  theme_minimal()
grafica
ggsave("C:/Users/crist/OneDrive/Documents/Trabajo_Final/figures/concetracion_temperatura_ciprofloxacino.png", plot=grafica)
