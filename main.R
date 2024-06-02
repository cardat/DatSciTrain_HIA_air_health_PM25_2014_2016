# HIA_air_health_PM25_2014_2016
# A demonstration of a simple pipeline for mortality attributable to long-term air pollution exposure
# ivanhanigan

#### install the required packages ####
## if you need to force installations set this
force_install_pkgs <- FALSE
## load packages
source("R/func.R")

#### load settings ####
## this sets all the data sources and global variables
source("config.R")

#### identify specific study region #### 
## OPTIONAL
## the default settings are to run this pipeline for a state or territory of Aust
## if you want to look at a specific SA3 run the following
## and edit the config
source("R/do_stdy_region_select.R")
show_map
## if you choose to change the configuration 
## go to config.R
## then change specific_stdy_reg <- TRUE
## and specify which SA3 you want to assess (specific_sa2_code)
## AND MAKE SURE TO RELOAD THE UPDATED CONFIG FILE
source("config.R")

#### data management settings ####
## create folders needed to store working files and results
if(!dir.exists("working_temporary")) dir.create("working_temporary")
if(!dir.exists("figures_and_tables")) dir.create("figures_and_tables")

#### do the HIA pipeline ####
for(timepoint in timepoints){
  ## for testing set this and don't loop
  ## timepoint <- 2015
  
  source("R/load_pops_mb.R")
  source("R/load_pops_sa2.R")
  source("R/load_health_rates_standard_pop.R")
  source("R/do_expected_deaths_for_subpopulations.R")  
  source("R/load_environment_exposure_pm25_modelled.R")
  source("R/qc_environment_exposure_pm25_modelled_missing.R")
  source("R/load_environment_exposure_pm25_model_fill_missing.R")  
  source("R/load_environment_exposure_pm25_counterfactual.R")
  source("R/load_enviro_monitor_model_counterfactual_linked.R")
  source("R/load_linked_pop_health_enviro.R")
  source("R/do_attributable_number.R")
  
}

#### summary tables ####
source("R/do_summary_tables.R")
if(specific_stdy_reg){
  output_results[,
                 c('run', 'STE_NAME16', 'GCC_NAME16', "SA3_NAME16", 'attributable_number', 'pop_total', 'pm25_anthro_pw_gcc', 'pm25_pw_gcc', 'rate_per_100000')]  
} else {
  output_results[,
                 c('run', 'STE_NAME16', 'GCC_NAME16', 'attributable_number', 'pop_total', 'pm25_anthro_pw_gcc', 'pm25_pw_gcc', 'rate_per_100000')]
}
## write out and keep record of runs
write.csv(output_results, 
          sprintf("figures_and_tables/results_%s.csv", make.names(Sys.time())), 
          row.names = F)


