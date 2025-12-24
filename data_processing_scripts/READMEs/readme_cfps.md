Steps to Construct the Panel for Replicating the CFPS Results

1. Download and prepare the replication package.

Download and unzip the replication package. Place all extracted files in a single directory, which will serve as the root folder for all CFPS data processing and replication materials.

2. Download the original CFPS data.

The CFPS data are publicly available from the Institute of Social Science Survey (ISSS), Peking University:
[https://www.isss.pku.edu.cn/cfps/en/index.htm](https://www.isss.pku.edu.cn/cfps/en/index.htm). Users must register for an account and download the original CFPS data in accordance with CFPS data access and security policies.

3. Prepare the raw CFPS data files.

Owing to ongoing data releases and routine maintenance updates, CFPS data files are typically named using the format `cfps + wave + adult / child / famecon / famconf / person + update date`
(e.g., cfps2018adult_202309.dta).
Before running the processing scripts, users should manually remove the date suffix from all CFPS data filenames, retaining only the wave and content identifiers (for example, renaming cfps2018adult_202309.dta to cfps2018adult.dta).

4. Run the CFPS processing code.

All CFPS processing scripts are written in Stata. Run the provided scripts sequentially to clean the raw data, harmonize variables across survey waves, and generate all variables required for the analysis.

5. Harmonize occupational measures for CFPS 2014.

The occupational classification system used in CFPS was revised in the 2014 wave. To ensure comparability with other survey years, occupational variables in CFPS 2014 must be adjusted following the procedures described in: Huang, Guoying and Yu Xie. [Construction of Occupational Socioeconomic Status Measures in the China Family Panel Studies](http://www.isss.pku.edu.cn/cfps/docs/20180927133140517170.pdf). The paper provides detailed recoding rules and technical guidance for harmonizing occupational measures across waves.

6. Construct the longitudinal panel.

After completing data cleaning and variable harmonization, run the panel construction scripts to merge all survey waves and assemble the longitudinal dataset covering CFPS 2010–2022. The final panel dataset is saved as `cfps_2010_2022.csv`.

