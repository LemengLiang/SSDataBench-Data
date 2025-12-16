Steps to Construct the Panel for Replicating the UnderstandingSociety Results

1. Download and unzip the replication package
Place the uncompressed files in a directory that will serve as the root folder for all replication materials.

2. Download the original data
In accordance with Understanding Society data security policies, users must create their own account and download the Understanding Society data from https://datacatalogue.ukdataservice.ac.uk/series/series/2000053#abstract .
The datafiles in our analysis are a part of the project Understanding Society: Waves 1-14, 2009-2023 and Harmonised BHPS: Waves 1-18, 1991-2009. We mainly use xwavedat.dta and 14 waves of `w'_indresp.dta in our work.

3. Construct the longitudinal panel
Run UnderstandingSociety_Longitudinal.do to collect all static and sequential variables necessary for the longitudinal analysis.

4. Final output
The completed panel dataset is saved as UnderstandingSociety.csv.