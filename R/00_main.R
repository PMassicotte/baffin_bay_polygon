library(tidyverse)
library(sf)
library(here)
library(rnaturalearth)
library(rnaturalearthhires)
library(crsuggest)
library(mapview)

rm(list = ls())

# General polygon that covers the main area of Baffin Bay -----------------

overall_polygon <- st_read(here("data", "raw", "overall_polygon.geojson"))
mapview(overall_polygon)

dest_proj <- crsuggest::suggest_crs(overall_polygon) |>
  head(1) |>
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
  xmin = -85,
  xmax = -40,
  ymin = 64,
  ymax = 80
)) |>
  st_as_sfc() |>
  st_segmentize(dfMaxLength = 1/3) |>
  st_set_crs(4326) |>
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
  width = 6,
  height = 8,
  dpi = 300,
  bg = "white"
)

# Export ------------------------------------------------------------------

# It looks good so far, lets export it

baffin_bay_croped |>
  st_write(here("data", "clean", "baffin_bay.gpkg"), append = FALSE)
