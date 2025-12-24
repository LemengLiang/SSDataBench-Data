Steps to Construct the Panel for Replicating the Add Health Results

1. Download and prepare the replication package

Download and unzip the replication package, and place all extracted files in a single directory. This directory will serve as the main working environment for all Add Health data processing and replication tasks.

2. Download the original Add Health data

Access to the Add Health data must be obtained through the official Add Health data distribution system at
[https://www.icpsr.umich.edu/sites/icpsr/home](https://www.icpsr.umich.edu/sites/icpsr/home). Download the individual-level interview data for Waves I, III, IV, and V. All data access, storage, and use must comply with Add Health data use agreements and security requirements.

3. Run the Add Health processing code

All Add Health data processing scripts are written in Stata. Run the provided Stata scripts to clean and recode demographic, socioeconomic, health, behavioral, and attitudinal variables within each wave. These scripts also harmonize variables across waves and generate wave-specific datasets (`wave1`, `wave3`, `wave4`, and `wave5`).

4. Construct the cross-wave panel dataset

After each wave has been processed separately, the scripts merge all waves at the individual level using the respondent identifier (AID) to construct the cross-wave panel dataset.
The final dataset is exported as a comma-delimited file `addhealth_1994_2018.csv`.