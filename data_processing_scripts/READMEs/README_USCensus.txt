README
Dec 23, 2025

Steps to Construct the U.S. Census Dataset (Replication of 1980 Results)

This guide describes how to construct the U.S. Census 1980 dataset used to replicate the results reported in this project.

1. Set Up the Python Environment
Ensure that the following Python packages are installed:
	•	pandas
	•	lumpy
You may install missing packages using pip or conda as needed.

2. Download the Original Data Extract from IPUMS-USA
	1	Visit IPUMS-USA: https://usa.ipums.org/usa/ (Registration is required if you do not already have an account.)
	2	Click “Get Data”, then select “SELECT SAMPLES.” Choose the 1980 “5% State” sample and submit the sample selection.
	4	Under “SELECT HARMONIZED VARIABLES,” select the variables required for constructing the 1980 dataset. All required variables can be found in USCensus.py.
	5	Submit the extract request and download the prepared data extract as a csv file once it is available.

3. Run the Data Processing Script
	1	Place the downloaded IPUMS csv file in the appropriate directory.
	2	Run the processing script: USCensus.py
	3	The script will generate the processed dataset: acs1980.csv