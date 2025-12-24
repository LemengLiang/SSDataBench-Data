
README
Dec 23, 2025



Steps to Construct the CPS-ASEC Dataset (Replication of 1980 Results)

This guide describes how to construct the CPS-ASEC 1980 dataset used to replicate the results reported in this project.



1. Set Up the Python Environment

Ensure that the following Python packages are installed:

* pandas
* lumpy

You may install missing packages using pip or conda as needed.



2. Download the Original Data Extract from IPUMS-CPS

Visit IPUMS-CPS: https://cps.ipums.org/cps/. Registration is required if you do not already have an account.

Click “Get Data,” then select “SELECT SAMPLES” Under the "ASEC" column, choose the 1980 sample and submit the sample selection.

Under “SELECT VARIABLES,” select the variables required for constructing the 1980 dataset.
All required variables are specified in CPS-ASEC.py.

Submit the extract request and download the prepared data extract as a CSV file once it is available.



3. Run the Data Processing Script

Place the downloaded IPUMS CSV file in the appropriate directory.

Run the processing script: CPS-ASEC.py

The script will generate the processed dataset: cps-asec1980.csv