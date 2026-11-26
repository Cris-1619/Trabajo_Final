
library(tidyverse)
library(here)

datos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)

ggplot(
  datos,
  aes(
    x = Nombre_Sitio,
    y = Concentracion_ng_L,
    fill = Nombre_Sitio
  )
) +
  geom_boxplot(
    outlier.alpha = 0.4,
    na.rm = TRUE
  ) +
  facet_wrap(
    ~ Antibiotico,
    scales = "free_y"
  ) +
  labs(
    title = "Distribución de antibióticos por sitio",
    subtitle = "Datos simulados",
    x = "Sitio de muestreo",
    y = "Concentración (ng/L)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )
