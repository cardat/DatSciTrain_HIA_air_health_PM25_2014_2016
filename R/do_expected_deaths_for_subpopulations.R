
outdir <- "working_temporary"

head(deathV4)
head(indat_popV2)

mrg_dth_pop <- merge(deathV4, indat_popV2, by = "Age")
mrg_dth_popV2 <- mrg_dth_pop[,c("SA2_MAINCODE_2016", "Age", "variable", "value", "rate")]
qc <- data.frame(table(mrg_dth_popV2$SA2_MAINCODE_2016))
nrow(qc)

head(mrg_dth_popV2)
mrg_dth_popV2$expected <- mrg_dth_popV2$value * mrg_dth_popV2$rate

dths_expected <- data.table(mrg_dth_popV2[mrg_dth_popV2$Age != "All ages",])
dths_expectedV2 <- dths_expected[,.(deaths = sum(expected)), .(SA2_MAINCODE_2016)]

#### now for the R pipeline  we just want the 30 plus, by age ####
paste(names(table(dths_expected$Age)), sep = "", collapse = "', '")
dths_expectedV3 <- dths_expected[Age %in% c('30 - 34', '35 - 39', '40 - 44', 
                                            '45 - 49', '50 - 54',
                                            '55 - 59', '60 - 64', 
                                            '65 - 69', '70 - 74',
                                            '75 - 79', '80 - 84', '85 - 89', 
                                            '90 - 94', '95 - 99',
                                            '100 and over'),]

qc_30andUp <- dths_expectedV3[,.(deaths = sum(expected)), .(SA2_MAINCODE_2016)]

write.csv(dths_expectedV3, file.path(outdir, sprintf("dths_expectedV3_%s_%s.csv", state, timepoint)), row.names = F)
