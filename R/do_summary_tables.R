
'name:do_summary_tables'

flist <- dir("figures_and_tables", pattern = "attributable")

output_results <- as.data.frame(matrix(NA, ncol = 6, nrow = 0))

for(fi in flist){
##  fi <- flist[2]
result <- read.csv(file.path("figures_and_tables", fi), as.is = T)
str(result)
summary(result)
result[is.na(result$GCC_CODE16),]
## first issue, we have the 9999s not joining to the spatial data
result <- result[!is.na(result$GCC_CODE16),]
table(result$GCC_CODE16)

setDT(result)
resultV3 <- result[, .(attributable_number = sum(an_sa3, na.rm = T),
                       pop_total = sum(pop_tot_sa3, na.rm = T),
                       pm25_anthro_pw_gcc = sum(pm25_anthro_pw_sa3 * pop_tot_sa3, na.rm = T)/sum(pop_tot_sa3, na.rm = T),
                       pm25_pw_gcc = sum(pm25_pw_sa3 * pop_tot_sa3, na.rm = T)/sum(pop_tot_sa3, na.rm = T)
                       ),
                   by = .(STE_NAME16, GCC_NAME16)
                   ]


if(specific_stdy_reg){
  names(result)
  
  results_specific <- result[SA3 == specific_sa3_code, 
                             .(attributable_number = sum(an_sa3, na.rm = T),
                               pop_total = sum(pop_tot_sa3, na.rm = T),
                               pm25_anthro_pw_gcc = sum(pm25_anthro_pw_sa3 * pop_tot_sa3, na.rm = T)/sum(pop_tot_sa3, na.rm = T),
                               pm25_pw_gcc = sum(pm25_pw_sa3 * pop_tot_sa3, na.rm = T)/sum(pop_tot_sa3, na.rm = T)
                             ), by = .(STE_NAME16, GCC_NAME16, SA3_NAME16, SA3_NAME16, SA3)]
  resultV3 <- rbind(resultV3, results_specific, fill = T)
}

resultV3$rate_per_100000 <- (resultV3$attributable_number/resultV3$pop_total) * 100000
setDF(resultV3)
resultV3$run <- fi
output_results <- rbind(output_results, data.frame(resultV3))


}
output_results
