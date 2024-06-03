## this script is a work in progress
## to demonstrate how to take this analysis to the next step
## which is to assess the years of life lost, and change in life expectancy for children
## NB codes have *not* been thoroughly checked
## ivanhanigan 2024-06-03
outdir <- "working_temporary"

# head(deathV4)
# head(indat_popV2)

mrg_dth_pop <- merge(deathV4, indat_popV2, by = "Age")
mrg_dth_popV2 <- mrg_dth_pop[,c("SA2_MAINCODE_2016", "Age", "variable", "value", "rate")]
qc <- data.frame(table(mrg_dth_popV2$SA2_MAINCODE_2016))
# nrow(qc)

# head(mrg_dth_popV2)
mrg_dth_popV2$expected <- mrg_dth_popV2$value * mrg_dth_popV2$rate

dths_expected <- data.table(mrg_dth_popV2[mrg_dth_popV2$Age != "All ages",])
dths_expectedV2 <- dths_expected[,.(deaths = sum(expected)), .(SA2_MAINCODE_2016)]

# paste(names(table(dths_expected$Age)), sep = "", collapse = "', '")

#### create a lifetable for each SA2 ####
dths_expected_lifetable <- dths_expected[,.(deaths = sum(expected),
                                            pop = sum(value)), 
                                         .(SA2_MAINCODE_2016,
                                           Age)]

# dths_expected_lifetable[SA2_MAINCODE_2016 == 511031281,]

## join with the GCC/SA3 codes

flist <- dir("figures_and_tables", pattern = "attributable")
# fi <- flist[1]
result <- read.csv(file.path("figures_and_tables", fi), as.is = T)
# str(result)
setDT(result)

# str(dths_expected_lifetable)
dths_expected_lifetable$SA3 <- as.integer(substr(dths_expected_lifetable$SA2_MAINCODE_2016, 1, 5))
dths_expected_lifetableV2 <- dths_expected_lifetable[,.(population=sum(pop),
                                                        deaths=sum(deaths)),
                                                     by = .(SA3, Age)]

dths_expected_lifetableV3 <- merge(dths_expected_lifetableV2, result)
dths_expected_lifetableV3 <- dths_expected_lifetableV3[,.(STE_NAME16, GCC_NAME16, SA3, Age, population, deaths, pm25_pw_sa3, pm25_anthro_pw_sa3)]

## do life expectency for whole state
demog_data_ste <- dths_expected_lifetableV3[,.(
  population = sum(population), 
  deaths = sum(deaths)
), by = .(agecat = Age)]
## recode to the first age, by hand this time
# paste(demog_data_ste$agecat, sep = "", collapse = "', '")
demog_data_ste$age <- as.numeric(c('0', '10', '100', '15', '20', '25', '30', '35', '40', '45', '5', '50', '55', '60', '65', '70', '75', '80', '85', '90', '95'))
demog_data_ste <- demog_data_ste[order(age)]
demog_data_ste$age_agg <- c(demog_data_ste$age[1:17], rep(85, 4))
# demog_data_ste
demog_data_ste <- demog_data_ste[,
                         .(
                           population = sum(population),
                           deaths = sum(deaths)
                         )
                         , by = .(age = age_agg)
]
# demog_data_ste
# # qc 
# demog_data_ste[,.(pop_15 = sum(population), deaths_15 = sum(deaths))]
"    pop_15 deaths_15
     <int>     <num>
1: 2,474,394     14,666"
# https://www.abs.gov.au/ausstats/abs@.nsf/Previousproducts/3235.0Main%20Features352015?opendocument&tabname=Summary&prodno=3235.0&issue=2015&num=&view=#:~:text=TOTAL%20POPULATION,of%20all%20states%20and%20territories.
# pop = 2.59 mil
# https://www.wa.gov.au/organisation/department-of-justice/the-registry-of-births-deaths-and-marriages/statistics-births-deaths-and-marriages-registered
# deaths 14,705
# this is about right

#### get the delta pm change
cf_ste <- dths_expected_lifetableV3[,.(pm25_pw_sa3=mean(pm25_pw_sa3),
                             pm25_anthro_pw_sa3 = mean(pm25_anthro_pw_sa3))]
# cf_ste

le <- burden_le(demog_data_ste, pm_concentration = cf_ste$pm25_anthro_pw_sa3, RR = 1.06)
le

# We can check this method against the spreadsheet
do_qc_le <- FALSE
if(do_qc_le){
# first we need to estimate the age 0-1
# simplest assumption is to divide by 5
demog_data_ste_for_s_sheet <- demog_data_ste[1,]
demog_data_ste_for_s_sheet$population <- demog_data_ste[1,"population"]/5
demog_data_ste_for_s_sheet$deaths <- demog_data_ste[1,"deaths"]/5

demog_data_ste_for_s_sheet2 <- demog_data_ste[1,]
demog_data_ste_for_s_sheet2$age <- 1
demog_data_ste_for_s_sheet2$population <- (demog_data_ste[1,"population"]/5)*4
demog_data_ste_for_s_sheet2$deaths <- (demog_data_ste[1,"deaths"]/5)*4

demog_data_ste_for_s_sheet <- rbind(demog_data_ste_for_s_sheet, demog_data_ste_for_s_sheet2)
demog_data_ste_for_s_sheet <- rbind(demog_data_ste_for_s_sheet, demog_data_ste[2:nrow(demog_data_ste),])
demog_data_ste_for_s_sheet$n <- c(1, 4, rep(5, nrow(demog_data_ste)-2), 11)
demog_data_ste_for_s_sheet$ax <- c(.1, rep(.5, nrow(demog_data_ste)))
demog_data_ste_for_s_sheet_output <- demog_data_ste_for_s_sheet[,.(age, n, ax, population, deaths)]

write.csv(demog_data_ste_for_s_sheet_output, file.path("references_Lifetables_with_spreadsheet", sprintf("lifetable_demog_data_ste_%s_%s.csv", state, timepoint)), row.names = F)
}

#### use iomlifetr to check ANs
# we can then extend further and look at the difference to our calculations
# sum(burden_an(demog_data_ste, pm_concentration = cf_ste$pm25_anthro_pw_sa3, RR = 1.06))
# most likely source of difference is averaging the counterfactual over all SA3s