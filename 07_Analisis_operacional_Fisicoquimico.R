library(tidyverse)
library(here)
library(broom)

datos_largos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)

variables <- c(
  "pH",
  "DO_mg_L",
  "Conductividad_uS_cm",
  "DQO_mg_L",
  "SST_mg_L"
)

etiquetas <- c(
  pH = "pH",
  DO_mg_L = "Oxígeno disuelto (mg/L)",
  Conductividad_uS_cm = "Conductividad (µS/cm)",
  DQO_mg_L = "DQO (mg/L)",
  SST_mg_L = "SST (mg/L)"
)

datos_operacionales <- datos_largos |>
  pivot_longer(
    cols = all_of(variables),
    names_to = "Variable_Operacional",
    values_to = "Valor_Operacional"
  )
for (variable in variables) {

  datos_variable <- datos_operacionales |>
    filter(Variable_Operacional == variable)

  grafico <- ggplot(
    datos_variable,
    aes(
      x = Valor_Operacional,
      y = Concentracion_ng_L,
      color = Nombre_Sitio
    )
  ) +
    geom_point(
      alpha = 0.7,
      size = 1.8
    ) +
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
modelos_operacionales <- datos_operacionales |>
  filter(
    is.finite(Concentracion_ng_L),
    is.finite(Valor_Operacional)
  ) |>
  group_by(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional
  ) |>
  filter(
    n() >= 3,
    n_distinct(Valor_Operacional) > 1,
    n_distinct(Concentracion_ng_L) > 1
  ) |>
  ungroup() |>
  nest(
    .by = c(
      Nombre_Sitio,
      Antibiotico,
      Variable_Operacional
    )
  ) |>
  mutate(
    modelo = map(
      data,
      ~ lm(
        Concentracion_ng_L ~ Valor_Operacional,
        data = .x
      )
    ),
    coeficientes = map(modelo, broom::tidy),
    estadisticas = map(modelo, broom::glance)
  )
coeficientes_operacionales <- modelos_operacionales |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional,
    coeficientes
  ) |>
  unnest(coeficientes) |>
  filter(term == "Valor_Operacional") |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional,
    Coeficiente = estimate,
    Error_Estandar = std.error,
    Valor_p = p.value
  )
r2_operacionales <- modelos_operacionales |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional,
    estadisticas
  ) |>
  unnest(estadisticas) |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional,
    R2 = r.squared,
    R2_Ajustado = adj.r.squared,
    N = nobs
  )
tabla_operacional <- coeficientes_operacionales |>
  left_join(
    r2_operacionales,
    by = c(
      "Nombre_Sitio",
      "Antibiotico",
      "Variable_Operacional"
    )
  )

View(tabla_operacional)
resumen_operacional <- tabla_operacional |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable_Operacional,
    Coeficiente
  ) |>
  pivot_wider(
    names_from = Variable_Operacional,
    values_from = Coeficiente
  )

View(resumen_operacional)
write_csv(
  tabla_operacional,
  here(
    "outputs",
    "Regresiones_operacionales.csv"
  )
)

write_csv(
  resumen_operacional,
  here(
    "outputs",
    "Resumen_coeficientes_operacionales.csv"
  )
)
grafico_r2_operacional <- ggplot(
  tabla_operacional,
  aes(
    x = Variable_Operacional,
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
    limits = variables,
    labels = c(
      pH = "pH",
      DO_mg_L = "OD",
      Conductividad_uS_cm = "Conductividad",
      DQO_mg_L = "DQO",
      SST_mg_L = "SST"
    )
  ) +
  scale_fill_gradient(
    low = "white",
    high = "steelblue",
    limits = c(0, 1),
    name = "R²"
  ) +
  labs(
    title = "Asociación con factores fisicoquímicos",
    subtitle = "Coeficientes de determinación - Datos simulados",
    x = "Variable fisicoquímica",
    y = "Antibiótico"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )
grafico_r2_operacional
ggsave(
  filename = here(
    "outputs",
    "Mapa_calor_R2_operacional.png"
  ),
  plot = grafico_r2_operacional,
  width = 14,
  height = 10,
  dpi = 300,
  bg = "white"
)
