# create an interactive map of SA3s
sf_an <- st_read(file.path(indir_sa3, infile_sa3))
sf_an <- st_transform(sf_an, '+proj=longlat +datum=WGS84')
sf_an <- st_simplify(sf_an[!st_is_empty(sf_an),], dTolerance = 100)
# get bounds of sf object
bounds <- st_bbox(sf_an)

suburb_popup <- paste0(
  "<strong>SA3_Name: </strong>", sf_an$SA3_NAME16,
  "<br><strong>SA3_Code: </strong>", sf_an$SA3_CODE16
  
)

show_map <- leaflet(data = sf_an) %>% 
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(fillColor = 'lightgreen', 
              fillOpacity = 0.6, 
              color = "#BDBDC3", 
              weight = 1, 
              popup = suburb_popup,
              group = "SA3")  %>%
  addScaleBar("bottomright", options = scaleBarOptions(metric = T)) %>%
  fitBounds(bounds[["xmin"]], bounds[["ymin"]], bounds[["xmax"]], bounds[["ymax"]])
 

