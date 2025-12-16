/*-----------------------------------------------------------------------
_UnderstandingSociety_Longitudinal.do

Stata do file to perform data construction of UnderstandingSociety for
'Evaluating Statistical Realism of LLM-Based Society Simulation'
*
-----------------------------------------------------------------------*/

* set all localisations here --------------------------------------------

clear all
cd "UnderstandingSociety"

* static variables

* Datafile: xwavedat
use xwavedat.dta, clear

* sex gender
gen gender=""
replace gender="Male" if sex==1
replace gender="Female" if sex==2

* birthy birthy
recode birthy (min/-1 9898=.)

* age_finished_education
recode scend_dv (min/-1=.), generate(age_finished_education)
replace age_finished_education=feend_dv if age_finished_education==. & feend_dv>0

* ethn_dv race
gen race=""
replace race="White" if inlist(ethn_dv,1,2,4)
replace race="South Asian" if inlist(ethn_dv,9,10,11)
replace race="Black" if inlist(ethn_dv,14,15,16)
replace race="Other Minorities" if inlist(ethn_dv,5,6,7,8,12,13,17,97)
replace race="" if ethn_dv == -9

* bornuk_dv immigrant_status
gen immigrant_status=""
replace immigrant_status="immigrant" if bornuk_dv==2
replace immigrant_status="non-immigrant" if bornuk_dv==1

* macob mother_immigrant_status
gen mother_immigrant_status="immigrant"
replace mother_immigrant_status="non-immigrant" if inlist(macob,1,2,3,4)
replace mother_immigrant_status="" if macob<0

* pacob father_immigrant_status
gen father_immigrant_status="immigrant"
replace father_immigrant_status="non-immigrant" if inlist(pacob,1,2,3,4)
replace father_immigrant_status="" if pacob<0

* maedqf mother_education
gen mother_education=""
replace mother_education="Less than high school" if inlist(maedqf,1,2)
replace mother_education="High school" if maedqf==3
replace mother_education="Some college" if maedqf==4
replace mother_education="Bachelor and above" if maedqf==5

* paedqf father_education
gen father_education=""
replace father_education="Less than high school" if inlist(paedqf,1,2)
replace father_education="High school" if paedqf==3
replace father_education="Some college" if paedqf==4
replace father_education="Bachelor and above" if paedqf==5

* lmar1y_dv age_at_first_marriage
recode lmar1y_dv (min/-1=.), generate(year_at_first_marriage)
gen age_at_first_marriage=""
forvalues i=16/120{
	replace age_at_first_marriage="`i'" if year_at_first_marriage-birthy==`i'
}
replace age_at_first_marriage="Never Married" if evermar_dv==2

* ch1by_dv age_at_first_child
recode ch1by_dv (min/-1=.), generate(year_at_first_child)
gen age_at_first_child=""
forvalues i=10/120{
	replace age_at_first_child="`i'" if year_at_first_child-birthy==`i'
}
replace age_at_first_child="No Childbearing" if anychild_dv==2

keep pidp gender birthy age_finished_education race immigrant_status mother_immigrant_status father_immigrant_status mother_education father_education age_at_first_marriage age_at_first_child

save xwavedat.dta, replace

* sequential variables

* Datafiles: 14 waves of `w'_indresp.dta
* a for 2009, b for 2010...n for 2022
* Use a for 2009 as an example first

/*
use a_indresp.dta, clear

* a_hiqual_dv education
recode a_hiqual_dv (min/-1=.) (1=4) (2=3) (3=2) (4 5 9=1), generate(education2009)

* a_jbstat employment
recode a_jbstat (1 2=1) (3/max=0) (min/-1=.), generate(employment2009)

* a_jbsoc00_cc occupation
recode a_jbsoc00_cc (111/123=1) (211/245=2) (311/356=3) (411/421=4) (511/549=5) (611/629=6) (711/721=7) (811/822=8) (911/925=9) (min/-1=.), gen(occupation2009)

* a_fimnnet_dv income
recode a_fimnnet_dv (min/0=0), generate(income2009)

* a_mastat_dv marital_status
recode a_mastat_dv (min/0=.) (1 7/10=1) (2/4=2) (5/6=3), generate(marital_status2009)

* a_nchild_dv children_number
recode a_nchild_dv (min/-1=.), generate(children_number2009)

* a_sf12pcs_dv physical_health
recode a_sf12pcs_dv (min/-1=.), generate(physical_health2009)

* a_sf12mcs_dv mental_health
recode sf12mcs_dv (min/-1=.), generaye(mental_health2009)

keep pidp education2009 employment2009 occupation2009 income2009 marital_status2009 children_number2009 physical_health2009 mental_health2009
save indresp2009.dta, replace
*/

local waves "a b c d e f g h i j k l m n"
local years "2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022"

forvalues i = 1/14 {
    local w : word `i' of `waves'
    local y : word `i' of `years'

use `w'_indresp.dta, clear

* Define variable labels first
* education
label define vleducation 1 "Less than high school" 2 "High school" 3 "Some college" 4 "Bachelor and above"
* employment
label define vlemployment 1 "Employed" 0 "Unemployed"
* occupation
label define vloccupation 1 "Managers" 2 "Professionals" 3 "Associate professionals" 4 "Clerical/Admin" 5 "Skilled trades" 6 "Personal services" 7 "Sales & customer service" 8 "Operatives & drivers" 9 "Elementary occupations"
* marital_status
label define vlmarital 1 "Unmarried" 2 "Married" 3 "Divorced or Widowed"

* education
recode `w'_hiqual_dv (min/-1=.) (1 2=4) (5=3) (3 4=2) (9=1), gen(hiqual`y')
label value hiqual`y' vleducation
decode hiqual`y', gen(education`y')

* employment
recode `w'_jbstat (1 2=1) (3/max=0) (min/-1=.), gen(jbstat`y')
label value jbstat`y' vlemployment
decode jbstat`y', gen(employment`y')

* occupation
recode `w'_jbsoc00_cc (111/123=1) (211/245=2) (311/356=3) (411/421=4)  (511/549=5) (611/629=6) (711/721=7) (811/822=8) (911/925=9) (min/-1=.), gen(jbsoc00_`y')
label value jbsoc00_`y' vloccupation
decode jbsoc00_`y', gen(occupation`y')

* income
recode `w'_fimnnet_dv (min/0=0), gen(income`y')

* marital status
recode `w'_marstat_dv (min/0=.) (2 6=1) (1 5=2) (3 4=3), gen(marstat`y')
label value marstat`y' vlmarital
decode marstat`y', gen(marital_status`y')

* number of children
recode `w'_nchild_dv (min/-1=.), gen(children_number`y')

keep pidp education`y' employment`y' occupation`y' income`y' marital_status`y' children_number`y'
save indresp`y'.dta, replace
}

use indresp2009.dta, clear
forvalues i=2010/2022{
	merge 1:1 pidp using indresp`i'.dta, nogen
}
save indresp.dta, replace

* Health variables * 

* calculate the mean values of general, mental, physical health, depression into static variables

local waves "a b c d e f g h i j k l m n"
local years "2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022"

forvalues i = 1/14 {
    local w : word `i' of `waves'
    local y : word `i' of `years'
use `w'_indresp.dta, clear

* physical health
recode `w'_sf12pcs_dv (min/-1=.), gen(physical_health`y')

* mental health
recode `w'_sf12mcs_dv (min/-1=.), gen(mental_health`y')

* depression
recode `w'_scghqi (min/-1=.), gen(depression`y')

keep pidp physical_health`y' mental_health`y' depression`y'
save h3alth`y'.dta, replace
}

local waves "a b c d e"
local years "2009 2010 2011 2012 2013"

forvalues i = 1/5 {
    local w : word `i' of `waves'
    local y : word `i' of `years'

use `w'_indresp.dta, clear

recode `w'_sf1 (min/-1=.), generate(general_health`y')

keep pidp general_health`y'
save gh`y'.dta, replace
}

local waves "f g h i j k l m n"
local years "2014 2015 2016 2017 2018 2019 2020 2021 2022"

forvalues i = 1/9 {
    local w : word `i' of `waves'
    local y : word `i' of `years'

use `w'_indresp.dta, clear

replace `w'_scsf1=`w'_sf1 if `w'_scsf1<0
recode `w'_scsf1 (min/-1=.), generate(general_health`y')

keep pidp general_health`y'

save gh`y'.dta, replace
}

use gh2009.dta, clear
forvalues i=2010/2022{
	merge 1:1 pidp using gh`i'.dta, nogen
}
save gh.dta, replace

use h3alth2009.dta, clear
forvalues i=2010/2022{
	merge 1:1 pidp using h3alth`i'.dta, nogen
}
save h3alth.dta, replace
merge 1:1 pidp using gh.dta, nogen

egen general_health = rowmean(general_health2009 general_health2010 general_health2011 general_health2012 general_health2013 general_health2014 general_health2015 general_health2016 general_health2017 general_health2018 general_health2019 general_health2020 general_health2021 general_health2022)
replace general_health=6-general_health

egen physical_health = rowmean(physical_health2009 physical_health2010 physical_health2011 physical_health2012 physical_health2013 physical_health2014 physical_health2015 physical_health2016 physical_health2017 physical_health2018 physical_health2019 physical_health2020 physical_health2021 physical_health2022)

egen mental_health = rowmean(mental_health2009 mental_health2010 mental_health2011 mental_health2012 mental_health2013 mental_health2014 mental_health2015 mental_health2016 mental_health2017 mental_health2018 mental_health2019 mental_health2020 mental_health2021 mental_health2022)

egen depression = rowmean(depression2009 depression2010 depression2011 depression2012 depression2013 depression2014 depression2015 depression2016 depression2017 depression2018 depression2019 depression2020 depression2021 depression2022)

keep pidp general_health physical_health mental_health depression
save health.dta, replace

forvalues y = 2009/2022 {
    erase indresp`y'.dta
	erase gh`y'.dta
	erase h3alth`y'.dta
}

erase h3alth.dta
erase gh.dta

* Memory variables * 
* Use memory in Wave 3 as static variable
use c_indresp.dta, clear

gen memory=""
replace memory="Excellent" if c_memper==1
replace memory="Very Good" if c_memper==2
replace memory="Good" if c_memper==3
replace memory="Fair" if c_memper==4
replace memory="Poor" if c_memper==5

keep pidp memory
save memory.dta, replace

* Distinguish divorce and widow
local waves "a b c d e f g h i j k l m n"
local years "2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022"

forvalues i = 1/14 {
    local w : word `i' of `waves'
    local y : word `i' of `years'

use `w'_indresp.dta, clear

* divorce status
gen `w'_divorced=(`w'_marstat_dv==4)
keep pidp `w'_divorced
save divorce`y'.dta, replace
}

use divorce2009.dta, clear
forvalues i=2010/2022{
	merge 1:1 pidp using divorce`i'.dta, nogen
}
gen ever_divorced_correct=(a_divorced==1 | b_divorced==1 | c_divorced==1 | d_divorced==1 | e_divorced==1 | f_divorced==1 | g_divorced==1 | h_divorced==1 | i_divorced==1 | j_divorced==1 | k_divorced==1 | l_divorced==1 | m_divorced==1 | n_divorced==1)
save divorce.dta, replace

forvalues y = 2009/2022 {
    erase divorce`y'.dta
}

* merge all files * 

* xwavedat.dta + indresp.dta + memory.dta + health.dta
use xwavedat.dta, clear
merge 1:1 pidp using indresp.dta
keep if _merge==3
drop _merge
merge 1:1 pidp using health.dta, nogen
merge 1:1 pidp using memory.dta, nogen
merge 1:1 pidp using divorce.dta, nogen

drop if birthy>=2009 | birthy<=1919

save understandingsociety.dta, replace

* generating age-specific sequential variables * 
* education
forvalues i=2/102{
	gen education_`i'=""
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace education_`age' = education`year' if 2009-birthy==`i'
	}
	}

drop education20*

* highest_education
gen str40 highest_education = ""
forvalues a = 102(-1)2 {
    replace highest_education = education_`a' if highest_education == "" & education_`a' != ""
}

* employment
forvalues i=2/102{
	gen employment_`i'=""
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace employment_`age' = employment`year' if 2009-birthy==`i'
	}
	}

drop employment20*

* occupation
forvalues i=2/102{
	gen occupation_`i'=""
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace occupation_`age' = occupation`year' if 2009-birthy==`i'
	}
	}

drop occupation20*

* occupation_30_40
gen strL occupation_30_40 = ""

local occvars occupation_40 occupation_39 occupation_38 occupation_37 ///
               occupation_36 occupation_35 occupation_34 occupation_33 ///
               occupation_32 occupation_31 occupation_30

foreach v of local occvars {
    replace occupation_30_40 = `v' if missing(occupation_30_40) & `v' != ""
}

* income
forvalues i=2/102{
	gen income_`i'=.
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace income_`age' = income`year' if 2009-birthy==`i'
	}
	}

drop income20*

* mean_income_30_40
egen mean_income_30_40 = rowmean(income_30 income_31 income_32 income_33 income_34 income_35 income_36 income_37 income_38 income_39 income_40)

* marital_status
forvalues i=2/102{
	gen marital_status_`i'=""
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace marital_status_`age' = marital_status`year' if 2009-birthy==`i'
	}
	}

drop marital_status20*

* ever_divorced
gen str3 ever_divorced="No"
forvalues a = 2/102 {
    replace ever_divorced = "Yes" ///
        if marital_status_`a' != "" ///
        & strtrim(marital_status_`a') == "Divorced or Widowed"
}

* children_number
forvalues i=2/102{
	gen children_number_`i'=.
}

forvalues i=2/89{
	forvalues j=0/13{
			local year = 2009 + `j'
			local age = `i'+`j'
			replace children_number_`age' = children_number`year' if 2009-birthy==`i'
	}
	}

drop children_number20*

* child_number
egen child_number = rowmax(children_number_2-children_number_102)

* birth_year
rename birthy birth_year

save, replace

* monthly income into annual income
replace mean_income_30_40=12*mean_income_30_40 if mean_income_30_40<.
forvalues a = 2/102 {
    replace income_`a' = income_`a' * 12 if income_`a' < .
}

save, replace

export delimited using "/Users/shimengdi/Princeton Dropbox/AI4SS_Data/UnderstandingSociety/understandingsociety.csv", replace
















