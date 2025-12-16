Steps to Construct the Panel for Replicating the NLSY79 Results

1. Download and unzip the replication package
Place the uncompressed files in a directory that will serve as the root folder for all replication materials.

2. Download the original NLSY79 data
In accordance with NLSY data security policies, users must create their own account and download the NLSY79 data from
https://www.nlsinfo.org/investigator/pages/search# .
The file NLSY79/SocietySimulationNLSY79.dct contains the tagsets required to upload to the NLSY Investigator, allowing users to obtain the full list of original variables used in our analysis.

3. Export selected variables from NLSY Investigator
After selecting the variables indicated in the tagset, export:
(i) the Stata dictionary file of the selected variables,
(ii) the codebook,
(iii) the short description file,
(iv) the comma-delimited dataset (with reference numbers as column headers).

4. Process the raw NLSY79 extract
Load SocietySimulationNLSY79.csv and run SocietySimulationNLSY79.do to generate and tag all variables required for the study.

5. Construct the longitudinal panel
Run NLSY79_Longitudinal.do to collect all static and sequential variables necessary for the longitudinal analysis.

6. Final output
The completed panel dataset is saved as NLSY79.csv.