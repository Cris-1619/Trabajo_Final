library(tidyverse)
library(here)
library(broom)

datos_largos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)
datos_ambientales <- datos_largos |>
  pivot_longer(
    cols = c(
      Temperatura_Agua_C,
      Caudal_m3_s,
      Precipitacion_Diaria_mm
    ),
    names_to = "Variable_Ambiental",
    values_to = "Valor_Ambiental"
  )
variables <- c(
  "Temperatura_Agua_C",
  "Caudal_m3_s",
  "Precipitacion_Diaria_mm"
)

etiquetas <- c(
  Temperatura_Agua_C = "Temperatura del agua (°C)",
  Caudal_m3_s = "Caudal (m³/s)",
  Precipitacion_Diaria_mm = "Precipitación diaria (mm)"
)

for (variable in variables) {

  datos_variable <- datos_ambientales |>
    filter(Variable_Ambiental == variable)

  grafico <- ggplot(
    datos_variable,
    aes(
      x = Valor_Ambiental,
      y = Concentracion_ng_L,
      color = Nombre_Sitio
    )
  ) +
    geom_point(alpha = 0.7, size = 1.8) +

    geom_smooth(
      method = "lm",
      formula = y ~ x,
      se = TRUE,
      linewidth = 0.8
    ) +

    facet_wrap(
      ~ Antibiotico,
      scales = "free_y",
      ncol = 5,
      axes = "all_x",
      axis.labels = "all_x"
    ) +

    labs(
      title = paste(
        "Concentración de antibióticos y",
        etiquetas[[variable]]
      ),
      subtitle = "Regresión lineal - Datos simulados",
      x = etiquetas[[variable]],
      y = "Concentración (ng/L)",
      color = "Sitio de muestreo"
    ) +

    theme_minimal() +
    theme(
      legend.position = "bottom",
      strip.text = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )

  print(grafico)

  ggsave(
    filename = here(
      "outputs",
      paste0("Regresion_", variable, ".png")
    ),
    plot = grafico,
    width = 16,
    height = 8,
    dpi = 300,
    bg = "white"
  )
}
modelos <- datos_ambientales |>
  filter(
    is.finite(Concentracion_ng_L),
    is.finite(Valor_Ambiental)
  ) |>
  group_by(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental
  ) |>
  filter(
    n() >= 3,
    n_distinct(Valor_Ambiental) > 1
  ) |>
  ungroup() |>
  nest(
    .by = c(
      Nombre_Sitio,
      Antibiotico,
      Variable_Ambiental
    )
  ) |>
  mutate(
    modelo = map(
      data,
      ~ lm(
        Concentracion_ng_L ~ Valor_Ambiental,
        data = .x
      )
    ),
    coeficientes = map(modelo, broom::tidy),
    estadisticas = map(modelo, broom::glance)
  )
tabla_coeficientes <- modelos |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental,
    coeficientes
  ) |>
  unnest(coeficientes) |>
  filter(term == "Valor_Ambiental") |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental,
    Coeficiente = estimate,
    Error_Estandar = std.error,
    Valor_p = p.value
  )
tabla_r2 <- modelos |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental,
    estadisticas
  ) |>
  unnest(estadisticas) |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental,
    R2 = r.squared,
    R2_Ajustado = adj.r.squared,
    N = nobs
  )
tabla_regresiones <- tabla_coeficientes |>
  left_join(
    tabla_r2,
    by = c(
      "Nombre_Sitio",
      "Antibiotico",
      "Variable_Ambiental"
    )
  )

View(tabla_regresiones)
tabla_resumen <- tabla_regresiones |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Ambiental,
    Coeficiente
  ) |>
  pivot_wider(
    names_from = Variable_Ambiental,
    values_from = Coeficiente
  )

View(tabla_resumen)
dir.create(
  here("outputs"),
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  tabla_regresiones,
  here("outputs", "tabla_regresiones.csv")
)

write_csv(
  tabla_resumen,
  here("outputs", "Resumen_coeficientes.csv")
)
grafico_r2 <- ggplot(
  tabla_regresiones,
  aes(
    x = Variable_Ambiental,
    y = Antibiotico,
    fill = R2
  )
) +
  geom_tile(color = "white") +

  geom_text(
    aes(label = round(R2, 2)),
    size = 3
  ) +

  facet_wrap(
    ~ Nombre_Sitio,
    ncol = 2,
    axes = "all",
    axis.labels = "all"
  ) +

  scale_x_discrete(
    labels = c(
      Temperatura_Agua_C = "Temperatura",
      Caudal_m3_s = "Caudal",
      Precipitacion_Diaria_mm = "Precipitación"
    )
  ) +

  scale_fill_gradient(
    low = "white",
    high = "steelblue",
    limits = c(0, 1),
    name = "R²"
  ) +

  labs(
    title = "Asociación entre antibióticos y variables ambientales",
    subtitle = "Coeficientes de determinación - Datos simulados",
    x = "Variable ambiental",
    y = "Antibiótico"
  ) +

  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold")
  )

grafico_r2
ggsave(
  filename = here(
    "outputs",
    "Mapa_calor_R2.png"
  ),
  plot = grafico_r2,
  width = 12,
  height = 10,
  units = "in",
  dpi = 300,
  bg = "white"
)
