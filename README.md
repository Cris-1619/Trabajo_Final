# Análisis exploratorio de antibióticos en aguas residuales y sistemas fluviales

## Descripción del proyecto

El aumento en el consumo de antibióticos en los últimos años ha llevado a un aumento en la presencia de estos en plantas de tratamiento de aguas residual, en donde estos compuestos no pueden ser pueden ser degradados por métodos convencionales, siendo descargados en rios generando una complicación ambiental. 


Este repositorio tiene como finalidad desarrollar un análisis exploratorio utilizando datos generados mediante inteligencia artificial. El conjunto de datos representa diez días de monitoreo en plantas de tratamiento de aguas residuales (PTAR) y puntos de muestreo del río Mapocho.

Se consideran concentraciones de contaminantes emergentes, variables ambientales (temperatura y precipitación), parámetros de calidad del agua (pH, conductividad, DBO y DQO) y caudal.

**Los datos son simulados y no representan mediciones ambientales reales.** 

## Objetivo general

Explorar la variabilidad espacial y temporal de las concentraciones de antibióticos en PTAR y puntos de muestreo fluviales, evaluando posibles relaciones con variables ambientales y parámetros de calidad del agua mediante herramientas estadísticas y de visualización.

## Preguntas exploratorias

1. ¿Cómo varían las concentraciones de antibióticos entre los diferentes puntos de muestreo?
2. ¿Qué patrones temporales presentan las concentraciones durante los diez días analizados?
3. ¿Qué relaciones exploratorias existen entre las concentraciones, el caudal y la temperatura?
4. ¿Es posible identificar puntos de muestreo con concentraciones relativamente elevadas?

## Organización del repositorio

- `datos_raw/`: datos originales sin modificaciones.
- `datos_procesados/`: datos sometidos a limpieza y transformación.
- `figures/`: visualizaciones generadas durante el análisis.
- `outputs/`: resultados y tablas derivados del procesamiento.
- `README.md`: documentación general del proyecto.

## Flujo de trabajo

1. Importación y revisión de los datos originales.
2. Identificación de valores faltantes, duplicados e inconsistencias.
3. Limpieza y transformación de los datos.
4. Análisis estadístico descriptivo.
5. Elaboración de visualizaciones espaciales y temporales.
6. Interpretación de patrones y relaciones exploratorias.

## Limitaciones

Los datos utilizados son sintéticos y abarcan únicamente diez días. Por lo tanto, los patrones observados no permiten establecer conclusiones sobre las condiciones reales del río Mapocho ni de las PTAR consideradas. Las relaciones identificadas tienen carácter exploratorio y no implican causalidad.
