# -*- coding: utf-8 -*-

###############################################################################
##
## CPS-ASEC data cleaning (1980)
## Note: Use environment "python3.11"
##
## Created : 11/07/2025
##
###############################################################################

import os
import pandas as pd
import numpy as np


######################### Read in dataset ################################

Asec = pd.read_csv("READ IN YOUR DATA FILE HERE")

######################### Mappings ################################

def cps_clean(df, year, output):
    
    # select year
    df = df[df["YEAR"] == year]
    
    # create empty variable list
    var_lst = []

    # gender
    if not df["SEX"].isna().all():
        def gender_mapping(x):
            if x == 1:
                return "Male"
            elif x == 2:
                return "Female"
            else:
                return np.nan
        df["gender"] = df["SEX"].apply(gender_mapping)
        var_lst.append("gender")
        print("gender cleaned!")
    else:
        print("no data for gender")
    
    # age
    if not df["AGE"].isna().all():
        def age_mapping(x):
            if x >= 0 and x <= 99:
                return x
            else:
                return np.nan
        df["age"] = df["AGE"].apply(age_mapping)
        var_lst.append("age")
        print("age cleaned!")
    else:
        print("no data for age")
    
    # birth year
    df["birth_year"] = np.where(df["AGE"].notna(), year - df["AGE"], np.nan)
    var_lst.append("birth_year")

    print("birth_year calculated!")

            
    # race (for 1970)
    if year == 1970:
        if not df["RACE"].isna().all():
            def race_mapping70(x):
                if x == 100:
                    return "White"
                elif x == 200:
                    return "Black"
                elif x > 200 and x < 999:
                    return "Other"
                else:
                    return np.nan
            df["race"] = df["RACE"].apply(race_mapping70)
            var_lst.append("race")
            print("race cleaned!")
        else:
            print("no data for race")
            
    # race (for other years)
    if year != 1970:
        if not df["HISPAN"].isna().all():
            def race_mapping(x, y):
                if x == 200:
                    return "Black"
                elif y >= 100 and y < 900:
                    return "Hispanic"
                else:
                    return "Non-Black, Non-Hispanic"
            df["race"] = df.apply(lambda row: race_mapping(row["RACE"], row["HISPAN"]), axis=1)
            var_lst.append("race")
            print("race cleaned!")
        else:
            print("no data for race")
    
            
    # immigrant status
    if "BPL" in df.columns:
        if not df["BPL"].isna().all():
            def migration_mapping(x):
                if x < 10000:
                    return "Non-immigrant"
                elif x >= 10000 and x < 99999:
                    return "Immigrant"
                else:
                    return np.nan
            df["immigrant_status"] = df["BPL"].apply(migration_mapping)
            var_lst.append("immigrant_status")
            print("immigrant_status cleaned!")
        else:
            print("no data for immigrant status")
        
    # mother immigrant status:
    if "MBPL" in df.columns:
        if not df["MBPL"].isna().all():
            def migration_m_mapping(x):
                if x < 10000:
                    return "Non-immigrant"
                elif x >= 10000 and x < 99999:
                    return "Immigrant"
                else:
                    return np.nan
            df["mother_immigrant_status"] = df["MBPL"].apply(migration_m_mapping)
            var_lst.append("mother_immigrant_status")
            print("mother_immigrant_status cleaned!")
        else:
            print("no data for mother's immigrant status")
    else:
        print("mother's immigrant status not in acs")
        
    # father immigrant status:
    if "FBPL" in df.columns:
        if not df["FBPL"].isna().all():
            def migration_f_mapping(x):
                if x < 10000:
                    return "Non-immigrant"
                elif x >= 10000 and x < 99999:
                    return "Immigrant"
                else:
                    return np.nan
            df["father_immigrant_status"] = df["FBPL"].apply(migration_f_mapping)
            var_lst.append("father_immigrant_status")
            print("father_immigrant_status cleaned!")
        else:
            print("no data for father's immigrant status")
    else:
        print("father's immigrant status not in acs")
        
        

    # marital status
    if not df["MARST"].isna().all():
        def marital_mapping(x):
            if x in [1, 2, 3]: # including separated
                return "Married"
            elif x in [4, 5, 7]:
                return "Divorced/widowed"
            elif x == 6:
                return "Single"
            else:
                return np.nan
        df["marital_status"] = df["MARST"].apply(marital_mapping)
        var_lst.append("marital_status")
        print("marital_status cleaned!")
    else:
        print("no data for marital status")
    
    
    
    # child number
    if "NCHILD" in df.columns:
        if not df["NCHILD"].isna().all():
            def nchild_mapping(x):
                if x >= 0 and x <= 9: 
                    return x
                else:
                    return np.nan
            df["child_number"] = df["NCHILD"].apply(nchild_mapping)
            var_lst.append("child_number")
            print("child_number cleaned!")
        else:
            print("no data for child_number")
    

    
    # age at first marriage
    if "AGEMARR" in df.columns:
        if not df["AGEMARR"].isna().all():
            def agemarr_mapping(x, y):
                if x >= 12 and x <= 90: 
                    return x
                elif y == 6:
                    return "Never Married"
                else:
                    return np.nan
    
            df["age_first_marriage"] = df.apply(
                lambda row: agemarr_mapping(row["AGEMARR"], row["MARST"]), axis=1)
            var_lst.append("age_first_marriage")
            print("age_first_marriage cleaned!")
        else:
            print("no data for age at first marriage")
        
        
    # age at first childbirth
    if "ELDCH" in df.columns:
        if not df["ELDCH"].isna().all(): # age of oldest child
            def agechildbirth_mapping(x, y, z):
                if x < 99 and y <= 99: 
                    age_birth = y-x
                    if age_birth >= 12 and age_birth <= 90:
                        return age_birth
                    else:
                        return np.nan
                elif z == 0:
                    return "No Child"
                else:
                    return np.nan
    
            df["age_first_childbirth"] = df.apply(
                lambda row: agechildbirth_mapping(
                    row["ELDCH"], row["AGE"], row["child_number"]
                    ), axis=1)
            
            var_lst.append("age_first_childbirth")
            print("age_first_childbirth cleaned!")
        else:
            print("no data for age at first childbirth")
    
    
    # education
    if not df["EDUC"].isna().all():
        def edu_mapping(x):
            if x < 40: 
                return "Less than high school"
            elif x >= 40 and x < 80:
                return "High school"
            elif x >= 80 and x < 999:
                return "College and above"
            else:
                return np.nan
        df["education"] = df["EDUC"].apply(edu_mapping)   
        var_lst.append("education")
        print("education cleaned!")
    else:
        print("no data for education")
          
        
    # labor force
    if not df["LABFORCE"].isna().all():
        def labor_mapping(x):
            if x == 1: 
                return "Not in the labor force"
            elif x == 2:
                return "In the labor force"
            else:
                return np.nan
        df["laborforce"] = df["LABFORCE"].apply(labor_mapping)   
        var_lst.append("laborforce")
        print("laborforce cleaned!")
    else:
        print("no data for laborforce")
    
    
    # occupation
    if not df["OCC1990"].isna().all():
        def occ_mapping(x):
            if x <= 37: 
                return "Managerial Occupations"
            elif x > 37 and x <= 200:
                return "Professional Specialty Occupations"
            elif x > 200 and x <= 235:
                return "Technicians and Related Support Occupations"
            elif x > 235 and x <= 283:
                return "Sales Occupations"
            elif x > 283 and x <= 389:
                return "Clerical and Administrative Support Occupations"
            elif x > 389 and x <= 469:
                return "Service Occupations"
            elif x > 469 and x <= 498:
                return "Farming, Forestry, and Fishing Occupations"
            elif x > 498 and x <= 699:
                return "Precision Production, Craft, and Repair Occupations"
            elif x > 699 and x <= 889:
                return "Operators, Fabricators, and Laborers"
            elif x > 889 and x <= 905:
                return "Military Occupations"
            elif x == 991:
                return "Unemployed"
            else:
                return np.nan
        df["occupation"] = df["OCC1990"].apply(occ_mapping)
        var_lst.append("occupation")
        print("occupation cleaned!")
    else:
        print("no data for occupation")
    
    
    # income
    if not df["INCTOT"].isna().all():
        def inc_mapping(x):
            if x >= 0 and x < 9999998: 
                return x
            elif x < 0:
                return 0
            else:
                return np.nan
        df["income"] = df["INCTOT"].apply(inc_mapping)  
        var_lst.append("income")
        print("income cleaned!")
    else:
        print("no data for income")
    
    
    # poverty status
    if not df["OFFPOV"].isna().all():
        def pov_mapping(x):
            if x == 1: 
                return "Below poverty line"
            elif x == 2:
                return "Above poverty line"
            else:
                return np.nan
        df["poverty_status"] = df["OFFPOV"].apply(pov_mapping)  
        var_lst.append("poverty_status")
        print("poverty_status cleaned!")
    else:
        print("no data for poverty_status")
        
        
    # health status
    if not df["HEALTH"].isna().all():
        def health_mapping(x):
            if x == 1: 
                return "Excellent"
            elif x == 2:
                return "Very good"
            elif x == 3:
                return "Good"
            elif x == 4:
                return "Fair"
            elif x == 5:
                return "Poor"
            else:
                return np.nan
        df["health"] = df["HEALTH"].apply(health_mapping)  
        var_lst.append("health")
        print("health cleaned!")
    else:
        print("no data for health")
    
    
    # health affects work
    if not df["DISABWRK"].isna().all():
        def healthwork_mapping(x):
            if x == 2: 
                return "Health affects work"
            if x == 1:
                return "Health doesn't affect work"
            else:
                return np.nan
        df["health_work_difficulty"] = df["DISABWRK"].apply(healthwork_mapping)  
        var_lst.append("health_work_difficulty")
        print("health_work_difficulty cleaned!")
    else:
        print("no data for DISABWRK")
    
    
    
    # select vars
    print(f"{year}: {var_lst}")
    df = df[var_lst]
    
    # save to csv
    df.to_csv(output)
    print(f"Cleaned ASEC {year} saved to {output}!")
    
    return var_lst




# use the function to get 1980 dataset

cps_clean(df = asec, year=1980, 
          output = "cps-asec1980.csv")    
