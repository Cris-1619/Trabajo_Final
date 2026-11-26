library(tidyverse)
library(here)

datos_largos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)
grafico_temporal <- ggplot(
  datos_largos,
  aes(
    x = Fecha,
    y = Concentracion_ng_L,
    color = Nombre_Sitio,
    group = Nombre_Sitio
  )
) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.2, alpha = 0.7) +
  facet_wrap(
    ~ Antibiotico,
    scales = "free_y",
    ncol = 5,
    axes = "all_x",
    axis.labels = "all_x"
  ) +
  scale_x_date(
    date_labels = "%d/%m",
    date_breaks = "7 days"
  ) +
  labs(
    title = "Evolución temporal de los antibióticos",
    subtitle = "Datos simulados",
    x = "Fecha de muestreo",
    y = "Concentración (ng/L)",
    color = "Sitio de muestreo"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    strip.text = element_text(
      face = "bold"
    ),
    panel.grid.minor = element_blank()
  )

grafico_temporal
dir.create(
  here("outputs"),
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  filename = here(
    "outputs",
    "Evolucion_temporal_antibioticos.png"
  ),
  plot = grafico_temporal,
  width = 16,
  height = 8,
  units = "in",
  dpi = 300,
  bg = "white"
)
