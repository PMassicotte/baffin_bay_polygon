library(tidyverse)
library(sf)
library(here)
library(rnaturalearth)
library(rnaturalearthhires)
library(crsuggest)
library(mapview)
library(styler)

rm(list = ls())

# General polygon that covers the main area of Baffin Bay -----------------

overall_polygon <- st_read(here("data", "raw", "overall_polygon.geojson"))
mapview(overall_polygon)

dest_proj <- crsuggest::suggest_crs(overall_polygon) |>
  head(1L) |>
  pull(crs_code) |>
  as.numeric()

overall_polygon <- overall_polygon |>
  st_transform(dest_proj)

# Ocean data --------------------------------------------------------------

ocean <-
  ne_download(
    category = "physical",
    type = "ocean",
    scale = "large",
    returnclass = "sf"
  ) |>
  st_transform(dest_proj)

# Croping -----------------------------------------------------------------

baffin_bay <- ocean |>
  st_intersection(overall_polygon)

mapview(baffin_bay)

bbox <- st_bbox(c(
  xmin = -85L,
  xmax = -40L,
  ymin = 64L,
  ymax = 80L
)) |>
  st_as_sfc() |>
  st_segmentize(dfMaxLength = 1L / 3L) |>
  st_set_crs(4326L) |>
  st_transform(dest_proj)

mapview(baffin_bay) +
  mapview(bbox)

baffin_bay_croped <- baffin_bay |>
  st_intersection(bbox)

mapview(baffin_bay_croped)

baffin_bay_croped |>
  ggplot() +
  geom_sf(size = 0.1) +
  theme_minimal()

ggsave(
  here("graphs", "baffin_bay.png"),
  width = 6L,
  height = 8L,
  dpi = 300L,
  bg = "white"
)

# Export ------------------------------------------------------------------

# It looks good so far, lets export it

baffin_bay_croped |>
  st_write(here("data", "clean", "baffin_bay.gpkg"), append = FALSE)
