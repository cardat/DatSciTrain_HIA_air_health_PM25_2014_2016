## install the cran packages, if not already avalailable
load_packages <- function(pkg = c("targets",
                                  "data.table"),
                          do_it = T, force_install = F){
  
  
  if(do_it){
    if (force_install){ 
      install.packages(pkg, dependencies = TRUE)
    }
    
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)){ 
      install.packages(new.pkg, dependencies = TRUE)
    }
    
    sapply(pkg, require, character.only = TRUE)
  }
}
load_packages(c(
"sf",
"leaflet",
"raster",
"foreign",
"sqldf",
"dplyr",
"data.table",
"reshape"))


