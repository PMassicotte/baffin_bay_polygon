# Polygon of Baffin Bay

Code to create a polygon that covers Baffin Bay. Will be useful for many projects where spatial analysis are involved. The *overall* polygon was made with <https://geojson.io> and exported into a geojson file.

<img src="graphs/baffin_bay.png" width="340"/>

## How to get the polygon file

```{r}
sf::st_read("https://github.com/PMassicotte/baffin_bay_polygon/blob/main/data/clean/baffin_bay.gpkg?raw=true")

terra::vect("https://github.com/PMassicotte/baffin_bay_polygon/blob/main/data/clean/baffin_bay.gpkg?raw=true")
```
