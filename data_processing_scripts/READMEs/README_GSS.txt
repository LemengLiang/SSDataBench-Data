README
Dec 23, 2025

Steps to Construct the GSS Dataset (Replication of 2018 Results)

This guide describes how to construct the GSS 2018 dataset used to replicate the results reported in this project.

1. Set Up the Python Environment
Ensure that the following Python packages are installed:
	•	pandas
	•	lumpy
You may install missing packages using pip or conda as needed.

2. Download the Original Data Extract from IPUMS-CPS
	1	Visit GSS Data Explorer: https://gssdataexplorer.norc.org/home. Registration is required if you do not already have an account.
	2	Click “Search GSS Variables,” then search and select needed variables. All required variables can be found in GSS.py.
	3	Construct and download data extract from “Create Extract.” I downloaded two versions of the GSS dataset from the GSS Data Explorer, one with labels and one with codes. Follow GSS.py to clean and combine them into the final dataset.

3. Run the Data Processing Script
	1	Place the downloaded files in the appropriate directory.
	2	Run the processing script: GSS.py
	3	The script will generate the processed dataset: gss2018.csv