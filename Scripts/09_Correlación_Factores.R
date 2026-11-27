
library(tidyverse)
library(here)

# ------------------------------------------------------------
# 1. Carga de datos
# ------------------------------------------------------------

datos_largos <- readRDS(
  here("datos_procesados", "datos_largos.rds")
)

tabla_integrada <- read_csv(
  here("outputs", "Resultados_integrados.csv"),
  show_col_types = FALSE
)

ruta_outputs <- here("outputs")

dir.create(
  ruta_outputs,
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 2. Configuracion general
# ------------------------------------------------------------

orden_sitios <- c(
  "La Farfana - Afluente",
  "El Trebal - Efluente",
  "Mapocho - Aguas arriba",
  "Mapocho - Aguas abajo"
)

variables <- c(
  "Temperatura_Agua_C",
  "Caudal_m3_s",
  "Precipitacion_Diaria_mm",
  "pH",
  "DO_mg_L",
  "Conductividad_uS_cm",
  "DQO_mg_L",
  "SST_mg_L"
)

etiquetas_cortas <- c(
  Temperatura_Agua_C = "Temp.",
  Caudal_m3_s = "Caudal",
  Precipitacion_Diaria_mm = "PP",
  pH = "pH",
  DO_mg_L = "OD",
  Conductividad_uS_cm = "Cond.",
  DQO_mg_L = "DQO",
  SST_mg_L = "SST"
)

etiquetas_completas <- c(
  Temperatura_Agua_C = "Temperatura",
  Caudal_m3_s = "Caudal",
  Precipitacion_Diaria_mm = "Precipitación",
  pH = "pH",
  DO_mg_L = "Oxígeno disuelto",
  Conductividad_uS_cm = "Conductividad",
  DQO_mg_L = "DQO",
  SST_mg_L = "SST"
)

colores_variables <- c(
  Temperatura_Agua_C = "#C77CFF",
  Caudal_m3_s = "#619CFF",
  Precipitacion_Diaria_mm = "#00BA38",
  pH = "#B79F00",
  DO_mg_L = "#F564E3",
  Conductividad_uS_cm = "#F8766D",
  DQO_mg_L = "#7CAE00",
  SST_mg_L = "#00BFC4"
)

datos_largos <- datos_largos |>
  mutate(
    Nombre_Sitio = factor(
      Nombre_Sitio,
      levels = orden_sitios
    )
  )

tabla_integrada <- tabla_integrada |>
  mutate(
    Nombre_Sitio = factor(
      Nombre_Sitio,
      levels = orden_sitios
    )
  )
# ------------------------------------------------------------
# 3. Tema grafico general
# ------------------------------------------------------------

tema_proyecto <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "grey30"
    ),
    plot.caption = element_text(
      size = 10,
      color = "grey40",
      hjust = 0
    ),
    strip.text = element_text(
      face = "bold",
      size = 12
    ),
    axis.title = element_text(
      face = "bold",
      size = 12
    ),
    axis.text = element_text(
      size = 11,
      color = "grey20"
    ),
    legend.position = "bottom",
    legend.title = element_text(
      face = "bold"
    ),
    panel.grid.minor = element_blank(),
    plot.title.position = "plot"
  )
# ------------------------------------------------------------
# 4. Revision del numero de observaciones
# ------------------------------------------------------------

resumen_observaciones <- datos_largos |>
  group_by(Nombre_Sitio, Antibiotico) |>
  summarise(
    N = n(),
    N_Validas = sum(is.finite(Concentracion_ng_L)),
    Fechas = n_distinct(Fecha, na.rm = TRUE),
    .groups = "drop"
  )

print(resumen_observaciones, n = Inf)

write_csv(
  resumen_observaciones,
  here("outputs",
    "Resumen_observaciones.csv"
  )
)
# ------------------------------------------------------------
# 5. Correlacion entre factores explicativos
# ------------------------------------------------------------

datos_factores <- datos_largos |>
  select(
    Fecha,
    Nombre_Sitio,
    all_of(variables)
  ) |>
  distinct() |>
  mutate(
    across(
      all_of(variables),
      ~ replace(.x, !is.finite(.x), NA_real_)
    )
  )

correlaciones_factores <- datos_factores |>
  nest(.by = Nombre_Sitio) |>
  mutate(
    matriz = map(
      data,
      ~ cor(
        select(.x, all_of(variables)),
        use = "pairwise.complete.obs",
        method = "pearson"
      )
    ),
    matriz_n = map(
      data,
      ~ crossprod(
        1L * !is.na(
          as.matrix(select(.x, all_of(variables)))
        )
      )
    ),
    tabla = map(
      matriz,
      ~ as.data.frame(as.table(.x))
    ),
    tabla_n = map(
      matriz_n,
      ~ as.data.frame(as.table(.x))
    ),
    tabla = map2(
      tabla,
      tabla_n,
      ~ left_join(
        .x,
        rename(.y, N = Freq),
        by = c("Var1", "Var2")
      )
    )
  ) |>
  select(Nombre_Sitio, tabla) |>
  unnest(tabla) |>
  rename(
    Variable_1 = Var1,
    Variable_2 = Var2,
    Correlacion = Freq
  )
# ------------------------------------------------------------
# 6. Mapa de correlacion entre factores
# ------------------------------------------------------------

correlaciones_grafico <- correlaciones_factores |>
  filter(
    match(Variable_1, variables) <=
      match(Variable_2, variables)
  )

grafico_correlacion_factores <- ggplot(
  correlaciones_grafico,
  aes(
    x = Variable_1,
    y = Variable_2,
    fill = Correlacion
  )
) +
  geom_tile(
    color = "white",
    linewidth = 0.8
  ) +
  geom_text(
    aes(
      label = if_else(
        is.na(Correlacion),
        "NA",
        sprintf("%.2f", Correlacion)
      ),
      color = abs(Correlacion) >= 0.7
    ),
    size = 3.5
  ) +
  scale_color_manual(
    values = c(
      "TRUE" = "white",
      "FALSE" = "black"
    ),
    na.value = "black",
    guide = "none"
  ) +
  facet_wrap(
    ~ Nombre_Sitio,
    ncol = 2,
    axes = "all",
    axis.labels = "all"
  ) +
  scale_x_discrete(
    limits = variables,
    labels = etiquetas_cortas
  ) +
  scale_y_discrete(
    limits = rev(variables),
    labels = etiquetas_cortas
  ) +
  scale_fill_gradient2(
    low = "#2166AC",
    mid = "white",
    high = "#B2182B",
    midpoint = 0,
    limits = c(-1, 1),
    na.value = "grey85",
    name = "Pearson (r)"
  ) +
  coord_fixed() +
  labs(
    title = "Correlación entre factores explicativos",
    subtitle = "Evaluación exploratoria de asociaciones entre predictores",
    x = NULL,
    y = NULL,
    caption = paste(
      "Datos simulados.",
      "Se presenta únicamente el triángulo inferior",
      "para evitar información duplicada."
    )
  ) +
  tema_proyecto +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )

print(grafico_correlacion_factores)

ggsave(
  filename = here("outputs",
    "Correlacion_factores_explicativos.png"
  ),
  plot = grafico_correlacion_factores,
  width = 14,
  height = 12,
  dpi = 300,
  bg = "white"
)
# ------------------------------------------------------------
# 7. Identificacion de correlaciones elevadas
# ------------------------------------------------------------

correlaciones_altas <- correlaciones_factores |>
  filter(
    match(Variable_1, variables) <
      match(Variable_2, variables),
    is.finite(Correlacion),
    abs(Correlacion) >= 0.8
  ) |>
  arrange(
    Nombre_Sitio,
    desc(abs(Correlacion))
  )

print(correlaciones_altas, n = Inf)

write_csv(
  correlaciones_factores,
  here(
    "outputs",
    "Correlaciones_factores_explicativos.csv"
  )
)

write_csv(
  correlaciones_altas,
  here("outputs",
    "Correlaciones_altas_predictores.csv"
  )
)
# ------------------------------------------------------------
# 8. Diagnostico de correlaciones elevadas
# ------------------------------------------------------------

diagnostico_correlaciones <- tabla_integrada |>
  filter(is.finite(Correlacion)) |>
  summarise(
    N_Correlaciones = n(),
    R_Minimo = min(Correlacion),
    R_Maximo = max(Correlacion),
    R_Promedio = mean(Correlacion),
    R_Absoluto_Promedio = mean(abs(Correlacion)),
    Porcentaje_R_08 = 100 * mean(
      abs(Correlacion) >= 0.8
    ),
    Porcentaje_R_09 = 100 * mean(
      abs(Correlacion) >= 0.9
    ),
    Porcentaje_R_095 = 100 * mean(
      abs(Correlacion) >= 0.95
    )
  )

print(diagnostico_correlaciones)

write_csv(
  diagnostico_correlaciones,
  here(
    "outputs",
    "Diagnostico_correlaciones.csv"
  )
)
# ------------------------------------------------------------
# 9. Identificacion de factores principales
# ------------------------------------------------------------

factores_principales <- tabla_integrada |>
  filter(is.finite(Correlacion)) |>
  group_by(Nombre_Sitio, Antibiotico) |>
  arrange(
    desc(abs(Correlacion)),
    Variable,
    .by_group = TRUE
  ) |>
  mutate(
    Correlacion_Absoluta = abs(Correlacion),
    Diferencia_R = first(Correlacion_Absoluta) -
      nth(
        Correlacion_Absoluta,
        2,
        default = NA_real_
      ),
    N_Empates = sum(
      near(
        Correlacion_Absoluta,
        max(Correlacion_Absoluta)
      )
    )
  ) |>
  slice_head(n = 1) |>
  ungroup() |>
  select(
    Nombre_Sitio,
    Antibiotico,
    Variable,
    Tipo,
    Correlacion,
    Correlacion_Absoluta,
    R2,
    Diferencia_R,
    N_Empates
  )

print(factores_principales, n = Inf)

write_csv(
  factores_principales,
  here(
    "outputs",
    "Factores_principales.csv"
  )
)
# ------------------------------------------------------------
# 10. Grafico de barras de factores principales
# ------------------------------------------------------------

grafico_factores_principales <- ggplot(
  factores_principales,
  aes(
    x = Antibiotico,
    y = Correlacion,
    fill = Variable
  )
) +
  geom_col(
    width = 0.75
  ) +
  geom_text(
    aes(
      label = sprintf("%.3f", Correlacion),
      vjust = if_else(
        Correlacion >= 0,
        -0.5,
        1.5
      )
    ),
    size = 3
  ) +
  geom_hline(
    yintercept = 0,
    color = "grey40",
    linewidth = 0.4
  ) +
  facet_wrap(
    ~ Nombre_Sitio,
    ncol = 2,
    axes = "all_x",
    axis.labels = "all_x"
  ) +
  scale_y_continuous(
    breaks = seq(-1, 1, 0.5)
  ) +
  coord_cartesian(
    ylim = c(-1.1, 1.1)
  ) +
  scale_fill_manual(
    values = colores_variables,
    labels = etiquetas_completas
  ) +
  labs(
    title = "Principales factores asociados a los antibióticos",
    subtitle = "Mayor correlación absoluta por sitio y compuesto",
    x = "Antibiótico",
    y = "Correlación de Pearson (r)",
    fill = "Variable",
    caption = paste(
      "Datos simulados.",
      "Las asociaciones no implican causalidad."
    )
  ) +
  tema_proyecto

print(grafico_factores_principales)

ggsave(
  filename = here(
    "outputs",
    "Factores_principales.png"
  ),
  plot = grafico_factores_principales,
  width = 16,
  height = 10,
  dpi = 300,
  bg = "white"
)
# ------------------------------------------------------------
# 11. Mapa categorico de factores principales
# ------------------------------------------------------------

grafico_factores_mapa <- ggplot(
  factores_principales,
  aes(
    x = Antibiotico,
    y = Nombre_Sitio,
    fill = Variable
  )
) +
  geom_tile(
    color = "white",
    linewidth = 1,
    width = 0.98,
    height = 0.98
  ) +
  geom_text(
    aes(
      label = sprintf("%.3f", Correlacion)
    ),
    size = 4.5,
    fontface = "bold",
    color = "black"
  ) +
  scale_y_discrete(
    limits = rev(orden_sitios)
  ) +
  scale_fill_manual(
    values = colores_variables,
    labels = etiquetas_completas
  ) +
  labs(
    title = "Factores con mayor asociación lineal",
    subtitle = paste(
      "Mayor correlación absoluta de Pearson",
      "por sitio y antibiótico"
    ),
    x = "Antibiótico",
    y = NULL,
    fill = "Variable",
    caption = paste(
      "Datos simulados.",
      "Las asociaciones son exploratorias",
      "y no implican causalidad."
    )
  ) +
  tema_proyecto +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(
      face = "bold",
      size = 12
    ),
    axis.text.y = element_text(
      size = 11
    ),
    legend.position = "bottom"
  )

print(grafico_factores_mapa)

ggsave(
  filename = here(
    "outputs",
    "Mapa_factores_principales.png"
  ),
  plot = grafico_factores_mapa,
  width = 14,
  height = 4.5,
  dpi = 300,
  bg = "white"
)
# ------------------------------------------------------------
# 12. Frecuencia de los factores principales
# ------------------------------------------------------------

resumen_factores <- factores_principales |>
  count(
    Variable,
    name = "Frecuencia"
  ) |>
  mutate(
    Porcentaje = 100 * Frecuencia / sum(Frecuencia),
    Factor = unname(
      etiquetas_completas[Variable]
    )
  ) |>
  arrange(desc(Frecuencia))

print(resumen_factores)

write_csv(
  resumen_factores,
  here(
    "outputs",
    "Resumen_frecuencia_factores.csv"
  )
)
# ------------------------------------------------------------
# 13. Grafico resumen de frecuencia
# ------------------------------------------------------------

grafico_frecuencia_factores <- ggplot(
  resumen_factores,
  aes(
    x = reorder(Factor, Porcentaje),
    y = Porcentaje,
    fill = Variable
  )
) +
  geom_col(
    width = 0.65
  ) +
  geom_text(
    aes(
      label = paste0(
        round(Porcentaje, 1),
        "% (",
        Frecuencia,
        ")"
      )
    ),
    hjust = -0.15,
    size = 4.5,
    fontface = "bold"
  ) +
  coord_flip() +
  scale_y_continuous(
    expand = expansion(
      mult = c(0, 0.25)
    )
  ) +
  scale_fill_manual(
    values = colores_variables,
    guide = "none"
  ) +
  labs(
    title = "Frecuencia de los factores principales",
    subtitle = "Variable con mayor correlación por sitio y antibiótico",
    x = NULL,
    y = "Porcentaje de combinaciones (%)",
    caption = paste(
      "Datos simulados.",
      "La frecuencia no representa importancia causal."
    )
  ) +
  tema_proyecto +
  theme(
    panel.grid.major.y = element_blank()
  )

print(grafico_frecuencia_factores)

ggsave(
  filename = here(
    "outputs",
    "Frecuencia_factores_principales.png"
  ),
  plot = grafico_frecuencia_factores,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)
# ------------------------------------------------------------
# 14. Resumen de factores por sitio
# ------------------------------------------------------------

resumen_factores_sitio <- factores_principales |>
  count(
    Nombre_Sitio,
    Variable,
    name = "Frecuencia"
  ) |>
  group_by(Nombre_Sitio) |>
  mutate(
    Porcentaje = 100 * Frecuencia / sum(Frecuencia),
    Factor = unname(
      etiquetas_completas[Variable]
    )
  ) |>
  ungroup() |>
  arrange(
    Nombre_Sitio,
    desc(Frecuencia)
  )

print(resumen_factores_sitio, n = Inf)

write_csv(
  resumen_factores_sitio,
  here(
    "outputs",
    "Resumen_factores_por_sitio.csv"
  )
)
