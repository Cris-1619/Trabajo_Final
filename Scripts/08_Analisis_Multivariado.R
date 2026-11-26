tabla_integrada <- bind_rows(

  tabla_regresiones |>
    rename(
      Variable = Variable_Ambiental
    ) |>
    mutate(Tipo = "Ambiental"),

  tabla_operacional |>
    rename(
      Variable = Variable_Operacional
    ) |>
    mutate(Tipo = "Fisicoquímica")

) |>
  mutate(
    Correlacion = sign(Coeficiente) * sqrt(R2)
  )
grafico_integrado <- ggplot(
  tabla_integrada,
  aes(
    x = Variable,
    y = Antibiotico,
    fill = Correlacion
  )
) +
  geom_tile(color = "white") +
  geom_text(
    aes(label = round(Correlacion, 2)),
    size = 3
  ) +
  facet_wrap(
    ~ Nombre_Sitio,
    ncol = 2,
    axes = "all",
    axis.labels = "all"
  ) +
  scale_x_discrete(
    limits = c(
      "Temperatura_Agua_C",
      "Caudal_m3_s",
      "Precipitacion_Diaria_mm",
      "pH",
      "DO_mg_L",
      "Conductividad_uS_cm",
      "DQO_mg_L",
      "SST_mg_L"
    ),
    labels = c(
      "Temperatura",
      "Caudal",
      "Precipitación",
      "pH",
      "OD",
      "Conductividad",
      "DQO",
      "SST"
    )
  ) +
  scale_fill_gradient2(
    low = "#2166AC",
    mid = "white",
    high = "#B2182B",
    midpoint = 0,
    limits = c(-1, 1),
    name = "Pearson (r)"
  ) +
  labs(
    title = "Asociaciones ambientales y fisicoquímicas",
    subtitle = "Correlaciones con las concentraciones de antibióticos - Datos simulados",
    x = "Variable explicativa",
    y = "Antibiótico"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    legend.position = "bottom"
  )

grafico_integrado
ggsave(
  filename = here(
    "outputs",
    "Mapa_calor_correlaciones_integrado.png"
  ),
  plot = grafico_integrado,
  width = 16,
  height = 10,
  dpi = 300,
  bg = "white"
)

write_csv(
  tabla_integrada,
  here(
    "outputs",
    "Resultados_integrados.csv"
  )
)
