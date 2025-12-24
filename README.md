# SSDataBench-Data
## Overview
Large Language Models (LLMs) hold great promise for generating social science data, potentially expanding the methodological toolkit of quantitative social research. Prior  studies have primarily focused on individual-level predictability or behavioral plausibility of LLM-generated data. We propose a new framework for assessing the validity of LLM-generated data by returning to the  foundational principles of survey research in the social sciences. Just as surveys based on representative samples yield statistics that approximate the corresponding statistical moments of the target population, assessments should center on the  ability of LLM-generated data to reproduce real-world, population-level statistical patterns. 

We introduce SSDataBench, the first systematic benchmark designed to evaluate population-level statistical realism in LLM-generated social science data. The benchmark assesses five types of statistical patterns central to social research: univariate distributions, bivariate associations, multivariate outcome predictions, life event sequence distributions, and associations between life event sequences and covariates. We illustrate SSDataBench using four longitudinal datasets and three cross-sectional datasets spanning six major social domains: demographics, socioeconomic status, marriage, health, abilities, and attitudes. Our study reveals systematic representational limitations in current LLMs, manifested in a pronounced tendency to compress real-world heterogeneity into simplified topological structures.

This repository provides the data processing codes used in this study, along with a limited set of processed datasets that are permitted to be shared. The goal is to facilitate transparency and replication while respecting data use agreements of the original sources. Researchers can use the code in this repository to replicate our workflow or apply the same procedures to the original microdata obtained directly from the data providers.

## Repo Contents
- [data_processing_scripts](https://github.com/LemengLiang/SocietyBench-Data/tree/main/data_processing_scripts): Codes to clean and process original survey data. NLSY, CFPS, Add Health, and Understanding Society are implemented in STATA, and U.S. Census, CPS-ASEC, and GSS are implemented in python. Please see instructions on how to construct survey datasets from [READMEs](https://github.com/LemengLiang/SSDataBench-Data/tree/main/data_processing_scripts/READMEs).

  Original microdata were obtained from the following platforms:
  - **NLSY**: [NLSY website](https://nlsinfo.org/investigator/pages/home)
  - **CFPS**: [CFPS website](https://www.isss.pku.edu.cn/cfps/en/index.htm)
  - **Add Health**: [ICPSR Add Health](https://www.icpsr.umich.edu/web/ICPSR/studies/21600/datadocumentation)
  - **Understanding Society**: [UK Data Service](https://datacatalogue.ukdataservice.ac.uk/studies/study/6614#details)
  - **U.S. Census**: [IPUMS USA](https://usa.ipums.org/usa/index.shtml)
  - **CPS-ASEC**: [IPUMS CPS](https://cps.ipums.org/cps/)
  - **GSS**: [GSS Data Explorer](https://gssdataexplorer.norc.org/MyGSS)
  
- [processed_survey_data](https://github.com/LemengLiang/SocietyBench-Data/tree/main/processed_survey_data): Processed datasets that are permitted to be shared, consisting of randomly selected 1,000-person samples from the original data used for simulation.

