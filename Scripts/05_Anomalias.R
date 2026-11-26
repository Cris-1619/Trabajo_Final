library(tidyverse)
library(here)

datos_largos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)
datos_anomalias <- datos_largos |>
  group_by(Nombre_Sitio, Antibiotico) |>
  mutate(
    Q1 = quantile(Concentracion_ng_L, 0.25, na.rm = TRUE),
    Q3 = quantile(Concentracion_ng_L, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,

    Limite_Inferior = Q1 - 1.5 * IQR,
    Limite_Superior = Q3 + 1.5 * IQR,

    Estado = case_when(
      is.na(Concentracion_ng_L) ~ NA_character_,
      Concentracion_ng_L > Limite_Superior ~ "Anomalía superior",
      Concentracion_ng_L < Limite_Inferior ~ "Anomalía inferior",
      TRUE ~ "Normal"
    )
  ) |>
  ungroup()
datos_anomalias |>
  filter(Estado != "Normal") |>
  select(
    Fecha,
    Nombre_Sitio,
    Antibiotico,
    Concentracion_ng_L,
    Estado
  ) |>
  arrange(Fecha) |>
  print(n = Inf)
sitios <- unique(datos_anomalias$Nombre_Sitio)

for (sitio in sitios) {

  datos_sitio <- datos_anomalias |>
    filter(Nombre_Sitio == sitio)

  grafico <- ggplot(
    datos_sitio,
    aes(x = Fecha, y = Concentracion_ng_L)
  ) +
    geom_line(
      color = "grey60",
      linewidth = 0.6
    ) +

    geom_hline(
      aes(yintercept = Limite_Superior),
      color = "red",
      linetype = "dashed"
    ) +

    geom_hline(
      aes(yintercept = Limite_Inferior),
      color = "blue",
      linetype = "dashed"
    ) +

    geom_point(
      aes(color = Estado),
      size = 2
    ) +

    facet_wrap(
      ~ Antibiotico,
      scales = "free_y",
      ncol = 5,
      axes = "all_x",
      axis.labels = "all_x"
    ) +

    scale_color_manual(
      values = c(
        "Normal" = "grey40",
        "Anomalía superior" = "red",
        "Anomalía inferior" = "blue"
      ),
      limits = c(
        "Normal",
        "Anomalía superior",
        "Anomalía inferior"
      ),
      drop = FALSE
    ) +

    scale_x_datetime(
      date_labels = "%d/%m",
      date_breaks = "3 days"
    ) +

    labs(
      title = paste("Detección de anomalías:", sitio),
      subtitle = "Método IQR - Datos simulados",
      x = "Fecha de muestreo",
      y = "Concentración (ng/L)",
      color = "Clasificación",
      caption = "Línea roja: límite superior. Línea azul: límite inferior."
    ) +

    theme_minimal() +
    theme(
      legend.position = "bottom",
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

  print(grafico)

grafico_anomalias
resumen_anomalias <- datos_anomalias |>
  group_by(Nombre_Sitio, Antibiotico) |>
  summarise(
    Observaciones = sum(!is.na(Estado)),
    Anomalias = sum(Estado != "Normal", na.rm = TRUE),
    Porcentaje = if_else(
      Observaciones > 0,
      100 * Anomalias / Observaciones,
      NA_real_
    ),
    .groups = "drop"
  )
grafico_heatmap <- ggplot(
  resumen_anomalias,
  aes(
    x = Antibiotico,
    y = Nombre_Sitio,
    fill = Porcentaje
  )
) +
  geom_tile(color = "white") +
  geom_text(
    aes(label = paste0(round(Porcentaje, 1), "%")),
    size = 3.5
  ) +
  scale_fill_gradient(
    low = "white",
    high = "tomato",
    name = "Anomalías (%)"
  ) +
  labs(
    title = "Frecuencia de anomalías por sitio y antibiótico",
    subtitle = "Datos simulados",
    x = "Antibiótico",
    y = "Sitio de muestreo"
  ) +
  theme_minimal() +
  theme(panel.grid = element_blank())

grafico_heatmap
ggsave(
  filename = here("outputs", "Mapa_calor_anomalias.png"),
  plot = grafico_heatmap,
  width = 12,
  height = 5,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = here(
    "outputs",
    paste0(
      "Anomalias_",
      gsub(" ", "_", sitio),
      ".png"
    )
  ),
  plot = grafico,
  width = 16,
  height = 8,
  dpi = 300,
  bg = "white"
)
}
