/*-----------------------------------------------------------------------
_NLSY79_Longitudinal.do

Stata do file to perform data construction of NLSY79 for
'Evaluating Statistical Realism of LLM-Based Society Simulation'
*
* confidential files needed to upload to NLSY79 Investigator
* NLSY79/SocietySimulationNLSY79.NLSY79
-----------------------------------------------------------------------*/

* set all localisations here --------------------------------------------

clear all
cd "NLSY79"

insheet using SocietySimulationNLSY79.csv, case
do SocietySimulationNLSY79.do

* R0214800 gender
gen gender=""
replace gender="Male" if R0214800==1
replace gender="Female" if R0214800==2

* R0000500 birth_year
gen birth_year=R0000500+1900

* R0214700 race
gen race=""
replace race="Hispanic" if R0214700==1
replace race="Black" if R0214700==2
replace race="Non-Black, Non-Hispanic" if R0214700==3

* R0000700 country of birth→immigrant_status
gen immigrant_status=""
replace immigrant_status="immigrant" if R0000700==2
replace immigrant_status="non-immigrant" if R0000700==1

* R0006500 mother_education
gen mother_education=""
replace mother_education="Less than high school" if (R0006500>=0 & R0006500<=11) | (R0006500==95)
replace mother_education="High school" if R0006500==12
replace mother_education="Some college" if (R0006500>=13 & R0006500<=15)
replace mother_education="Bachelor and above" if (R0006500>=16 & R0006500<=20)

* R0007900 father_education
gen father_education=""
replace father_education="Less than high school" if (R0007900>=0 & R0007900<=11) | (R0007900==95)
replace father_education="High school" if R0007900==12
replace father_education="Some college" if (R0007900>=13 & R0007900<=15)
replace father_education="Bachelor and above" if (R0007900>=16 & R0007900<=20)

* R0006100 mother_immigrant_status
gen mother_immigrant_status=""
replace mother_immigrant_status="immigrant" if R0006100==2
replace mother_immigrant_status="non-immigrant" if R0006100==1

* R0007300 father_immigrant_status
gen father_immigrant_status=""
replace father_immigrant_status="immigrant" if R0007300==2
replace father_immigrant_status="non-immigrant" if R0007300==1

* education
recode R0017300 R0229200 R0417400 R0664500 R0905900 R1205800 R1605100 R1905600 R2306500 R2509000 R2908100 R3110200 R3510200 R3710200 R4137900 R4526500 R5221800 R5821800 R6540400 R7103600 R7810500 T0014400 T1214300 T2272800 T3212900 T4201100 T5176100 T7743900 T8355300 (min/-1=.) (90/95=0), generate(edugrades1979 edugrades1980 edugrades1981 edugrades1982 edugrades1983 edugrades1984 edugrades1985 edugrades1986 edugrades1987 edugrades1988 edugrades1989 edugrades1990 edugrades1991 edugrades1992 edugrades1993 edugrades1994 edugrades1996 edugrades1998 edugrades2000 edugrades2002 edugrades2004 edugrades2006 edugrades2008 edugrades2010 edugrades2012 edugrades2014 edugrades2016 edugrades2018 edugrades2020)

recode T9900000 (min/-1=.), generate(highest_edugrades)

recode R0017300 R0229200 R0417400 R0664500 R0905900 R1205800 R1605100 R1905600 R2306500 R2509000 R2908100 R3110200 R3510200 R3710200 R4137900 R4526500 R5221800 R5821800 R6540400 R7103600 R7810500 T0014400 T1214300 T2272800 T3212900 T4201100 T5176100 T7743900 T8355300 T9900000 (min/-1=.) (0/11 90/95=1) (12=2) (13/15=3) (16/20=4)
label define vleducation 1 "Less than high school" 2 "High school" 3 "Some college" 4 "Bachelor and above"
label val R0017300 R0229200 R0417400 R0664500 R0905900 R1205800 R1605100 R1905600 R2306500 R2509000 R2908100 R3110200 R3510200 R3710200 R4137900 R4526500 R5221800 R5821800 R6540400 R7103600 R7810500 T0014400 T1214300 T2272800 T3212900 T4201100 T5176100 T7743900 T8355300 T9900000 vleducation

local rawvars R0017300 R0229200 R0417400 R0664500 R0905900 R1205800 R1605100 R1905600 R2306500 R2509000 R2908100 R3110200 R3510200 R3710200 R4137900 R4526500 R5221800 R5821800 R6540400 R7103600 R7810500 T0014400 T1214300 T2272800 T3212900 T4201100 T5176100 T7743900 T8355300 T9900000

local strvars  education1979 education1980 education1981 education1982 education1983 education1984 education1985 education1986 education1987 education1988 education1989 education1990 education1991 education1992 education1993 education1994 education1996 education1998 education2000 education2002 education2004 education2006 education2008 education2010 education2012 education2014 education2016 education2018 education2020 highest_education

local n1 : word count `rawvars'
local n2 : word count `strvars'
assert `n1' == `n2'

forvalues i = 1/`n1' {
    local v : word `i' of `rawvars'
    local g : word `i' of `strvars'
    decode `v', gen(`g')
}

forvalues i=14/65{
	gen education_`i'=""
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace education_`age' = education`year' if R0000600==`i'
	}
	}
	
forvalues i=29/37{
	forvalues j=0(2)26{
			local year = 1994 + `j'
			local age = `i'+`j'
			replace education_`age' = education`year' if R0000600==`i'-15
	}
	}

drop education19* education20*

* highest_education
gen age_finished_education = .
local yrs 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1996 1998 2000 2002 2004 2006
foreach y of local yrs {
    replace age_finished_education = R0000600+`y'-1979 ///
        if missing(age_finished_education) ///
        & edugrades`y' == highest_edugrades ///
        & !missing(highest_edugrades) ///
        & !missing(edugrades`y')
}
local years 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1996 1998 2000
local edug edugrades1979 edugrades1980 edugrades1981 edugrades1982 edugrades1983 edugrades1984 edugrades1985 edugrades1986 edugrades1987 edugrades1988 edugrades1989 edugrades1990 edugrades1991 edugrades1992 edugrades1993 edugrades1994 edugrades1996 edugrades1998 edugrades2000

local gnum
local n : word count `years'
forvalues i = 1/`n' {
    local y : word `i' of `years'
    local g : word `i' of `edug'
    capture confirm numeric variable `g'
    if _rc==0 {
        gen double __g`y' = `g'
    }
    else {
        gen double __g`y' = real(`g')
    }
    local gnum `gnum' __g`y'
}
capture drop _final_max
egen double _final_max = rowmax(`gnum')
capture drop age_finished_education2
gen double age_finished_education2 = .
forvalues i = 1/`n' {
    local y : word `i' of `years'
    gen double _age_`y' = R0000600 + (`y' - 1979)
    replace age_finished_education2 = _age_`y' if missing(age_finished_education2) & !missing(__g`y') & __g`y' == _final_max
}
drop _final_max
drop __g* _age_*
replace age_finished_education=age_finished_education2 if age_finished_education==.
drop age_finished_education2 *edugrades*

* employment
recode R0214901 (min/-1=.) (1=1) (2 3 4=0)
label define vlemployment 1 "Employed" 0 "Unemployed"
label val R0214901 vlemployment
recode R0406512 R0645681 R0896712 R1145112 R1520312 R1891012 R2258112 R2445512 R2871302 R3075002 R3401702 R3657102 R4007602 R4418702 R5081702 R5167002 R6479802 R7007502 R7704802 R8497202 T0989002 T2210802 T3108702 T4113202 T5023800 T5771700 T8219600 T8788800 T9300600 (min/-1=.) (1=1)
label val R0406512 R0645681 R0896712 R1145112 R1520312 R1891012 R2258112 R2445512 R2871302 R3075002 R3401702 R3657102 R4007602 R4418702 R5081702 R5167002 R6479802 R7007502 R7704802 R8497202 T0989002 T2210802 T3108702 T4113202 T5023800 T5771700 T8219600 T8788800 T9300600 vlemployment

local rawemploy R0214901 R0406512 R0645681 R0896712 R1145112 R1520312 R1891012 R2258112 R2445512 R2871302 R3075002 R3401702 R3657102 R4007602 R4418702 R5081702 R5167002 R6479802 R7007502 R7704802 R8497202 T0989002 T2210802 T3108702 T4113202 T5023800 T5771700 T8219600 T8788800 T9300600
local stremploy employment1979 employment1980 employment1981 employment1982 employment1983 employment1984 employment1985 employment1986 employment1987 employment1988 employment1989 employment1990 employment1991 employment1992 employment1993 employment1994 employment1996 employment1998 employment2000 employment2002 employment2004 employment2006 employment2008 employment2010 employment2012 employment2014 employment2016 employment2018 employment2020 employment2022

local n1 : word count `rawemploy'
local n2 : word count `stremploy'
assert `n1' == `n2'

forvalues i = 1/`n1' {
    local v : word `i' of `rawemploy'
    local g : word `i' of `stremploy'
    decode `v', gen(`g')
}
forvalues i=14/65{
	gen employment_`i'=""
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace employment_`age' = employment`year' if R0000600==`i'
	}
	}
forvalues i=29/37{
	forvalues j=0(2)26 {
			local year = 1996 + `j'
			local age = `i'+`j'
			replace employment_`age' = employment`year' if R0000600==`i'-17
	}
	}

drop employment19* employment20*

* age_started_work

forvalues a = 14/65 {
    gen empN_`a' = lower(strtrim(employment_`a'))
}
capture drop age_started_work
gen age_started_work = .
forvalues a = 14/65 {
    replace age_started_work = `a' if missing(age_started_work) & empN_`a' == "employed"
}
drop empN_*

* occupation
recode R0046400 R0263400 R0446400 R0702100 (-5/-1 0 990/999=.) (1/195=2) (201/245=1) (260/285=5) (301/395  = 4) (401/575  = 7) (580/590 = 10) (601/715  = 8) (740/785  = 9) (801/802  = 6) (821/824  = 6) (901/965  = 5) (980/984  = 5)
recode R0828000 R0945300 R1255700 R1650500 R1923100 R2317900 R2525700 R2924700 R3127400 R3523100 R3728100 R4587901 R5270900 R6473700 R6592900 R7209600 (-5/-1=.) (3/199 = 2) (200/235  = 3) (240/292 = 5) (300/395 = 4) (403/472 = 5) (473/499  = 6) (500/699  = 7) (700/799  = 8) (800/859  = 8) (860/896 = 9) (900/975=8) (980/983 = 10) (990/999=.)
recode R7898000 T0138400 T1298000 T2326500 T3308700 T4282800 T5256900  T7818600 T8428300 T8982400 (-5/-1=.) (10/950=1) (1000/1990=2) (2000/2060=2) (2100/2150=2) (2200/2550=2) (2600/2960=2) (3000/3260=2) (3300/3650=3) (3700/3950=5) (4000/4160=5) (4200/4250=5) (4300/4430=5) (4460=5) (4500/4650=5) (4700/4960=5) (5000/5930=4) (6000/6130=6) (6200/6940=7) (7000/7620=7) (7700/7850=8) (7900/8960=8) (9000/9750=8) (9840=10) (9900/9990=.)

label define vloccupation 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerical" 5 "Service/Sales" 6 "Agriculture" 7 "Craft/Trades" 8 "Machine Operators" 9 "Elementary" 10 "Military"
label val R0046400 R0263400 R0446400 R0702100 R0828000 R0945300 R1255700 R1650500 R1923100 R2317900 R2525700 R2924700 R3127400 R3523100 R3728100 R4587901 R5270900 R6473700 R6592900 R7209600 R7898000 T0138400 T1298000 T2326500 T3308700 T4282800 T525690  T7818600 T8428300 T8982400 vloccupation

local rawoccupation R0046400 R0263400 R0446400 R0702100 R0828000 R0945300 R1255700 R1650500 R1923100 R2317900 R2525700 R2924700 R3127400 R3523100 R3728100 R4587901 R5270900 R6473700 R6592900 R7209600 R7898000 T0138400 T1298000 T2326500 T3308700 T4282800 T525690  T7818600 T8428300 T8982400
local stroccupation occupation1979 occupation1980 occupation1981 occupation1982 occupation1983 occupation1984 occupation1985 occupation1986 occupation1987 occupation1988 occupation1989 occupation1990 occupation1991 occupation1992 occupation1993 occupation1994 occupation1996 occupation1998 occupation2000 occupation2002 occupation2004 occupation2006 occupation2008 occupation2010 occupation2012 occupation2014 occupation2016 occupation2018 occupation2020 occupation2022

local n1 : word count `rawoccupation'
local n2 : word count `stroccupation'
assert `n1' == `n2'

forvalues i = 1/`n1' {
    local v : word `i' of `rawoccupation'
    local g : word `i' of `stroccupation'
    decode `v', gen(`g')
}
forvalues i=14/65{
	gen occupation_`i'=""
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace occupation_`age' = occupation`year' if R0000600==`i'
	}
	}
forvalues i=31/39{
	forvalues j=0(2)26 {
			local year = 1996 + `j'
			local age = `i'+`j'
			replace occupation_`age' = occupation`year' if R0000600==`i'-17
	}
	}
drop occupation19* occupation20*

* income
recode R0169100 R0328000 R0498500 R0798600 R1024000 R1410700 R1778501 R2141601 R2350301 R2722501 R2971401 R3279401 R3559001 R3897101 R4295101 R4982801 R5626201 R6364601 R6909701 R7607800 R8316300 T0912400 T2076700 T3045300 T3977400 T4915800 T5619500 T8115400 T8645700 T9198400 (min/-1=.), generate(income1979 income1980 income1981 income1982 income1983 income1984 income1985 income1986 income1987 income1988 income1989 income1990 income1991 income1992 income1993 income1994 income1996 income1998 income2000 income2002 income2004 income2006 income2008 income2010 income2012 income2014 income2016 income2018 income2020 income2022)

forvalues i=14/65{
	gen income_`i'=.
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace income_`age' = income`year' if R0000600==`i'
	}
	}
forvalues i=31/39{
	forvalues j=0(2)26 {
			local year = 1996 + `j'
			local age = `i'+`j'
			replace income_`age' = income`year' if R0000600==`i'-17
	}
	}
drop income19* income20*

* ever_divorced
local mlist R0217501 R0405601 R0618601 R0898401 R1144901 R1520101 R1890801 R2257901 R2445301 R2871000 R3074700 R3401400 R3656800 R4007300 R4418400 R5081400 R5166700 R6479300 R7007000 R7704300 R8496700 T0988500 T2210500 T3108400 T4112900 T5023300 T5771200 T8219300 T8788500 T9300300
gen ever_divorced = 0
foreach v of local mlist {
    replace ever_divorced = 1 if `v' == 3
}

* marital_status
recode R0217501 R0405601 R0618601 R0898401 R1144901 R1520101 R1890801 R2257901 R2445301 R2871000 R3074700 R3401400 R3656800 R4007300 R4418400 R5081400 R5166700 R6479300 R7007000 R7704300 R8496700 T0988500 T2210500 T3108400 T4112900 T5023300 T5771200 T8219300 T8788500 T9300300 (min/-1=.) (0 2=1) (1=2) (3 4 6=3)
label define vlmarital 1 "Unmarried" 2 "Married" 3 "Divorced or Widowed"

label val R0217501 R0405601 R0618601 R0898401 R1144901 R1520101 R1890801 R2257901 R2445301 R2871000 R3074700 R3401400 R3656800 R4007300 R4418400 R5081400 R5166700 R6479300 R7007000 R7704300 R8496700 T0988500 T2210500 T3108400 T4112900 T5023300 T5771200 T8219300 T8788500 T9300300 vlmarital
local rawmarital R0217501 R0405601 R0618601 R0898401 R1144901 R1520101 R1890801 R2257901 R2445301 R2871000 R3074700 R3401400 R3656800 R4007300 R4418400 R5081400 R5166700 R6479300 R7007000 R7704300 R8496700 T0988500 T2210500 T3108400 T4112900 T5023300 T5771200 T8219300 T8788500 T9300300
local strmarital marital_status1979 marital_status1980 marital_status1981 marital_status1982 marital_status1983 marital_status1984 marital_status1985 marital_status1986 marital_status1987 marital_status1988 marital_status1989 marital_status1990 marital_status1991 marital_status1992 marital_status1993 marital_status1994 marital_status1996 marital_status1998 marital_status2000 marital_status2002 marital_status2004 marital_status2006 marital_status2008 marital_status2010 marital_status2012 marital_status2014 marital_status2016 marital_status2018 marital_status2020 marital_status2022

local n1 : word count `rawmarital'
local n2 : word count `strmarital'
assert `n1' == `n2'

forvalues i = 1/`n1' {
    local v : word `i' of `rawmarital'
    local g : word `i' of `strmarital'
    decode `v', gen(`g')
}
forvalues i=14/65{
	gen marital_status_`i'=""
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace marital_status_`age' = marital_status`year' if R0000600==`i'
	}
	}
forvalues i=31/39{
	forvalues j=0(2)26 {
			local year = 1996 + `j'
			local age = `i'+`j'
			replace marital_status_`age' = marital_status`year' if R0000600==`i'-17
	}
	}
drop marital_status19* marital_status20*

* child_number
recode R9908000 (min/-1=.), generate(child_number)

* children_number
recode R0013400 (-5 -3/-1=.) (-4=0), generate(children_number1979)
recode R0226400 (min/-1=0)
gen children_number1980=R0226400+children_number1979
recode R0414000 (min/-1=0)
gen children_number1981=R0226400+children_number1980

recode R0898837 R1146829 R1522036 R1892736 R2259836 R2448036 R2877500 R3076841 R3407600 R3659046 R4009446 R4444600 R5087400 R5172700 R6486300 R7014100 R7711700 R8504200 T0995900 T2217700 T3115700 T4120200 T5031400 T5779600 T8226700 T8796000 T9307800 (min/-1=.), generate(children_number1982 children_number1983 children_number1984 children_number1985 children_number1986 children_number1987 children_number1988 children_number1989 children_number1990 children_number1991 children_number1992 children_number1993 children_number1994 children_number1996 children_number1998 children_number2000 children_number2002 children_number2004 children_number2006 children_number2008 children_number2010 children_number2012 children_number2014 children_number2016 children_number2018 children_number2020 children_number2022)

forvalues i=14/65{
	gen children_number_`i'=.
}
forvalues i=14/22{
	forvalues j=0/15{
			local year = 1979 + `j'
			local age = `i'+`j'
			replace children_number_`age' = children_number`year' if R0000600==`i'
	}
	}
forvalues i=31/39{
	forvalues j=0(2)26 {
			local year = 1996 + `j'
			local age = `i'+`j'
			replace children_number_`age' = children_number`year' if R0000600==`i'-17
	}
	}
drop children_number19* children_number20*

* R9908600 age_at_first_marriage
recode R9908600 (-5/-1=.), gen(age_at_first_marriage_numeric)
gen age_at_first_marriage=""
forvalues i=14/62{
	replace age_at_first_marriage="`i'" if age_at_first_marriage_numeric==`i'
}
replace age_at_first_marriage="Never Married" if age_at_first_marriage_numeric==-999
drop age_at_first_marriage_numeric

* R9900002 year at first child→age_at_first_child
recode R9900002 (0=1978) (-5/-1=.)
gen age_at_first_child_numeric=R9900002-birth_year
gen age_at_first_child=""
forvalues i=10/70{
	replace age_at_first_child="`i'" if age_at_first_child_numeric==`i'
}
replace age_at_first_child="No Childbearing" if R9908000==0
drop age_at_first_child_numeric

* H0003200 physical_health
recode H0003200 (min/-1=.), generate(physical_health)

* H0003300 mental_health
recode H0003300 (min/-1=.), generate(mental_health)

* H0003400 self_rated_general_health
gen self_rated_general_health=""
replace self_rated_general_health="Excellent" if H0003400==1
replace self_rated_general_health="Very Good" if H0003400==2
replace self_rated_general_health="Good" if H0003400==3
replace self_rated_general_health="Fair" if H0003400==4
replace self_rated_general_health="Poor" if H0003400==5

* H0001101 self_rated_depression
recode H0001101 (min/-1=.), gen(self_rated_depression)

* X0031200 self_rated_memory
gen self_rated_memory=""
replace self_rated_memory="Excellent" if X0031200==1
replace self_rated_memory="Very Good" if X0031200==2
replace self_rated_memory="Good" if X0031200==3
replace self_rated_memory="Fair" if X0031200==4
replace self_rated_memory="Poor" if X0031200==5

keep gender birth_year race immigrant_status mother_education father_education mother_immigrant_status father_immigrant_status education_* highest_education employment_* age_started_work occupation_* income_* ever_divorced marital_status_* child_number children_number_* age_at_first_marriage age_at_first_child physical_health mental_health self_rated_general_health self_rated_depression self_rated_memory

egen mean_income_30_40 = rowmean(income_30 income_31 income_32 income_33 income_34 income_35 income_36 income_37 income_38 income_39 income_40)

gen strL occupation_30_40 = ""
local occvars occupation_40 occupation_39 occupation_38 occupation_37 occupation_36 occupation_35 occupation_34 occupation_33 occupation_32 occupation_31 occupation_30

foreach v of local occvars {
    replace occupation_30_40 = `v' if missing(occupation_30_40) & `v' != ""
}


save NLSY79_Longitudinal.dta, replace
export delimited using "NLSY79.csv", replace






