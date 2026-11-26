
library(tidyverse)
library(here)

datos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)

Antibioticos_Por_Sitio<-ggplot(
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
    scales = "free_y",
    ncol = 5,
    axes = "all_x",
    axis.labels = "all_x"
  ) +
  scale_x_discrete(
    limits = c(
      "La Farfana - Afluente",
      "El Trebal - Efluente",
      "Mapocho - Aguas arriba",
      "Mapocho - Aguas abajo"
    ),
    labels = c(
      "Afluente",
      "Efluente",
      "Río arriba",
      "Río abajo"
    )
  ) +
  theme(
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      size = 9
    ),
    strip.text = element_text(
      face = "bold",
      size = 12
    ),
    panel.grid.minor = element_blank()
  )
ggsave(
  filename = here::here("outputs", "Antibioticos_por_sitio.png"),
  width = 12,
  height = 8,
  units = "in",
  dpi = 300
)
