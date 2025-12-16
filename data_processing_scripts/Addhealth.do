clear
use Add_health_Wave_1
merge 1:1 AID using Add_health_Wave_3, keepus(AID)
drop _merge
merge 1:1 AID using Add_health_Wave_4, keepus(AID)
drop _merge
merge 1:1 AID using Add_health_Wave_5, keepus(AID)
drop _merge

**# WAVE I
**# 1. Demography
* Gender
fre BIO_SEX
gen gender = ""
replace gender = "male"   if BIO_SEX == 1
replace gender = "female" if BIO_SEX == 2
fre gender

* Race
fre H1GI4 H1GI6A H1GI6B H1GI6C H1GI6D H1GI6E
gen race_new = .
replace race_new = 1 if H1GI6A==1 & H1GI4==0      // Non-Hispanic White
replace race_new = 2 if H1GI6B==1 & H1GI4==0      // Black
replace race_new = 3 if H1GI6C==1 & H1GI4==0      // American Indian / Native American
replace race_new = 4 if H1GI6D==1 & H1GI4==0      // Asian
replace race_new = 5 if H1GI4==1                  // Hispanic
replace race_new = 6 if H1GI6E==1 & H1GI4==0      // Other
label define racelbl 1 "non-Hispanic white" 2 "black" 3 "native american" 4 "asian" 5 "hispanic" 6 "others"
label values race_new racelbl
label var race_new "Race category (Add Health Wave I)"
fre race_new

gen race = ""
replace race = "non-Hispanic white" if race_new == 1
replace race = "black"              if race_new == 2
replace race = "native american"    if race_new == 3
replace race = "asian"              if race_new == 4
replace race = "hispanic"           if race_new == 5
replace race = "others"             if race_new == 6
fre race

* number of siblings
fre H1HR5*
foreach v of varlist H1HR5* {
    recode `v' (96 97 98 . = 0) (else = 1), gen(sib_`v'_dummy)
    label var sib_`v'_dummy "Has sibling recorded in `v' (1=yes,0=no)"
}
fre sib_*_dummy
egen siblings = rowtotal(sib_H1HR5A_dummy-sib_H1HR5T_dummy)
label var siblings "Total number of siblings (any reported = 1, missing=0)"
fre siblings
recode siblings(6/12=6)

* birth_year
fre H1GI1Y
gen birth_year = 1900 + H1GI1Y
fre birth_year
recode birth_year(1996=.)

* religion
fre H1RE1
gen religion = ""
* Protestant
replace religion = "Protestant" if inlist(H1RE1, ///
    1,2,3,4,5,7,10,13,14,15,16,17,18,19)
* Catholic
replace religion = "Catholic" if H1RE1 == 22
* Jewish
replace religion = "Jewish" if H1RE1 == 26
* None / No preference
replace religion = "None/No preference" if inlist(H1RE1, 0,96,98,99)
* Other
replace religion = "Other" if inlist(H1RE1, ///
    6,8,9,11,12,20,21,23,24,25,27,28)
fre religion

* migrant
fre H1GI15
gen migrant_1 = .
replace migrant_1 = 1 if H1GI11 == 0    // Not born in the US → immigrant
replace migrant_1 = 0 if H1GI11 == 1    // Born in the US → non-immigrant
label define migrantlbl 0 "born in U.S." 1 "immigrant"
label values migrant_1 migrantlbl
fre migrant_1

gen migrant = ""
replace migrant = "immigrant"   if migrant_1 == 1
replace migrant = "born in U.S." if migrant_1 == 0
fre migrant

**# 2. SES
* education
fre H1RM1 H1RF1
replace H1RM1 = H1NM4 if H1RM1 >= 11 & H1NM4<11
replace H1RF1 = H1NF4 if H1RF1 >= 11 & H1NF4<11
recode H1RM1 ///
    (1/5 = 1 "high school or below")(6/7 = 2 "some college")(8/9 = 3 "BA or above")(10 = 1 "high school or below")(11/99=.),gen(mother_education)
fre mother_education

gen mother_edu = ""
replace mother_edu = "high school or below" if mother_education == 1
replace mother_edu = "some college"         if mother_education == 2
replace mother_edu = "BA or above"          if mother_education == 3

recode H1RF1 ///
    (1/5 = 1 "high school or below")(6/7 = 2 "some college")(8/9 = 3 "BA or above")(10 = 1 "high school or below")(11/99=.),gen(father_education)
fre father_education
gen father_edu = ""
replace father_edu = "high school or below" if father_education == 1
replace father_edu = "some college"         if father_education == 2
replace father_edu = "BA or above"          if father_education == 3
fre mother_edu father_edu

* income
// About how much total income (in thousands of dollars), before taxes did your family receive in 1994? Include your own income, the income of everyone else in your household, and income from welfare benefits, dividends, and all other sources.
fre PA55
gen income = PA55 if PA55<1000 & PA55!=.
fre income
replace income = income * 1000

**# 3. Marriage
* ever_married
fre H1GI15
gen married = .
replace married = 1 if H1GI15 == 1    // Ever married
replace married = 0 if H1GI15 == 0    // Never married
label define marriedlbl 0 "never married" 1 "ever married"
label values married marriedlbl
label var married "Ever married status (Wave I)"
fre married

gen ever_married = ""
replace ever_married = "ever married"  if married == 1
replace ever_married = "never married" if married == 0
fre ever_married

* have sex
fre H1CO1
gen ever_sex = ""
replace ever_sex = "never sex" if H1CO1 == 0
replace ever_sex = "ever sex"   if H1CO1 == 1
fre ever_sex

* age_at_first_sex
gen first_sex_year = .
replace first_sex_year = H1CO2Y + 1900 if inrange(H1CO2Y, 77, 95)
replace first_sex_year = . if inlist(H1CO2Y, 96, 98, 99)
g age_at_first_sex = first_sex_year - birth_year
fre age_at_first_sex
replace age_at_first_sex = . if age_at_first_sex<15

* age_at_first_marriage
fre H1GI16Y
gen year_marriage = 1900 + H1GI16Y
fre year_marriage
recode year_marriage(1997=.)
gen age_at_first_marriage = year_marriage - birth_year
fre age_at_first_marriage

**# 4. Health
* self_rated_health:
fre H1GH1
gen health = ""
replace health = "excellent" if H1GH1 == 1
replace health = "very good" if H1GH1 == 2
replace health = "good"      if H1GH1 == 3
replace health = "fair"      if H1GH1 == 4
replace health = "poor"      if H1GH1 == 5
fre health
ren health self_rated_health

* mental health
fre H1FS1-H1FS19
recode H1FS1-H1FS19(6/8=.)
recode H1FS4 H1FS8 H1FS11 H1FS15(0=3)(1=2)(2=1)(3=0)
factor  H1FS1-H1FS3 H1FS5-H1FS7 H1FS9-H1FS10 H1FS12-H1FS14 H1FS16-H1FS19, pcf
rotate, blanks(0.55)
predict self_rated_depression
fre self_rated_depression

**# 5. Ability
* non-cognitive skills
* When you get what you want, it's usually because you worked hard for it.
fre H1PF8
gen hardwork = ""
replace hardwork = "strongly agree"    if H1PF8 == 1
replace hardwork = "agree"             if H1PF8 == 2
replace hardwork = "neither agree nor disagree" if H1PF8 == 3
replace hardwork = "disagree"          if H1PF8 == 4
replace hardwork = "strongly disagree" if H1PF8 == 5
fre hardwork

* interpersonal skills
fre S46D // TROUBLE WITH OTHER STUDENTS
gen interpersonal = ""
replace interpersonal = "never"            if S46D == 1
replace interpersonal = "few times"        if S46D == 2
replace interpersonal = "once a week"      if S46D == 3
replace interpersonal = "almost everyday"  if S46D == 4
replace interpersonal = "everyday"         if S46D == 5

keep AID gender race siblings birth_year religion mother_edu father_edu income migrant ever_married age_at_first_marriage self_rated_health self_rated_depression hardwork interpersonal ever_sex age_at_first_sex
ren * *_1
ren AID_ AID
save wave1, replace

**# WAVE 3
clear
use "E:\AI助研 数据\Add Health\Wave3\21600-0008-Data.dta"

**# 1. Demography
* religion
fre H3RE1
gen religion = ""
* Protestant (Protestant + Christian)
replace religion = "Protestant" if inlist(H3RE1, 1, 8)
* Catholic
replace religion = "Catholic" if H3RE1 == 2
* Jewish
replace religion = "Jewish" if H3RE1 == 3
* None / No preference
replace religion = "None/No preference" if inlist(H3RE1, 0,96,98,99)
* Other (Buddhist, Hindu, Moslem, Other religion)
replace religion = "Other" if inlist(H3RE1, 4,5,6,7)
fre religion

**# 2. SES
* highest education
gen education = ""
replace education = "BA or above" if inlist(1, H3ED5, H3ED6, H3ED7, H3ED8)
replace education = "some college" if education=="" & H3ED4 == 1
replace education = "high school or below" if education=="" & ///
    (H3ED3 == 1 | H3ED2 == 1 | H3ED9 == 1 | ///
     H3ED3==0 | H3ED2==0 | H3ED9==7 | H3ED9==8)
fre education

* employment
gen employment = ""
replace employment = "unemployed" ///
    if H3LM71 == 0 & H3LM75 == 0 & H3LM79 == 0
replace employment = "employed" ///
    if H3LM71 == 1 | H3LM75 == 1 | H3LM79 == 1
fre employment

* occupation
gen occupation = ""
replace occupation = "Legislators, senior officials and managers" ///
    if H3LM10 == "11-0000"
replace occupation = "Professionals" ///
    if inlist(H3LM10,"13-0000","15-0000","17-0000","19-0000", ///
                         "21-0000","23-0000","25-0000","27-0000","29-0000")
replace occupation = "Technicians and associate professionals" ///
    if H3LM10 == "31-0000"
replace occupation = "Clerks" ///
    if H3LM10 == "43-0000"
replace occupation = "Service workers and shop and market sales workers" ///
    if inlist(H3LM10,"33-0000","35-0000","37-0000","39-0000","41-0000")
replace occupation = "Skilled agricultural and fishery workers" ///
    if H3LM10 == "45-0000"
replace occupation = "Craft and related trades workers" ///
    if H3LM10 == "47-0000"
replace occupation = "Plant and machine operators and assemblers" ///
    if inlist(H3LM10,"49-0000","51-0000","53-0000")
replace occupation = "Armed forces" ///
    if H3LM10 == "55-0000"
replace occupation = "unemployed" if employment=="unemployed"

* income
fre H3EC2
recode H3EC2(200000/10000000=.), gen(income)
fre income
	
**# 3. marry
* ever_married
fre H3MR1
gen married = .
replace married = 1 if H3MR1>0 & H3MR1<=3  // Ever married
replace married = 0 if H3MR1 == 0    // Never married
label define marriedlbl 0 "never married" 1 "ever married"
label values married marriedlbl
label var married "Ever married status (Wave I)"
fre married

gen ever_married = ""
replace ever_married = "ever married"  if married == 1
replace ever_married = "never married" if married == 0
fre ever_married

* ever_divorced
gen ever_divorced = ""
replace ever_divorced = "never married" if ever_married == "never married"
replace ever_divorced = "ever divorced" if inlist(H3MR4_A,1,2) | inlist(H3MR4_B,1,2)
replace ever_divorced = "never divorced" if ever_divorced=="" & ever_married=="ever married"
fre ever_divorced

* have sex
fre H3SE1
gen ever_sex = ""
replace ever_sex = "never sex" if H3SE1 == 0
replace ever_sex = "ever sex"   if H3SE1 == 1
fre ever_sex

* age_at_first_sex
g age_at_first_sex = H3SE2 if H3SE2<50 & H3SE2>=15
fre age_at_first_sex

* age_at_first_marriage
fre H3MR2Y_A H3MR2Y_B H3MR2Y_C
recode H3MR2Y_A H3MR2Y_B H3MR2Y_C(9990/9999=.)
gen age_at_first_marriage = H3MR2Y_A - H3OD1Y
replace age_at_first_marriage = H3MR2Y_B - H3OD1Y if age_at_first_marriage==.
replace age_at_first_marriage = H3MR2Y_C - H3OD1Y if age_at_first_marriage==.
fre age_at_first_marriage

* age_at_first_divorce
fre H3MR5Y_A H3MR5Y_B
recode H3MR5Y_A H3MR5Y_B(9990/9999=.)
gen age_at_first_divorce = H3MR5Y_A - H3OD1Y
replace age_at_first_divorce = H3MR5Y_B - H3OD1Y if age_at_first_divorce==.
replace age_at_first_divorce = . if age_at_first_divorce<age_at_first_marriage
fre age_at_first_divorce

* self_rated_health:
fre H3GH1
gen health = ""
replace health = "excellent" if H3GH1 == 1
replace health = "very good" if H3GH1 == 2
replace health = "good"      if H3GH1 == 3
replace health = "fair"      if H3GH1 == 4
replace health = "poor"      if H3GH1 == 5
fre health
ren health self_rated_health

**# 4. Attitudes 
* political attitudes
fre H3CC13
gen political_orientation = ""
replace political_orientation = "very conservative"   if H3CC13 == 1
replace political_orientation = "conservative"        if H3CC13 == 2
replace political_orientation = "middle-of-the-road"  if H3CC13 == 3
replace political_orientation = "liberal"             if H3CC13 == 4
replace political_orientation = "very liberal"        if H3CC13 == 5

keep AID religion education occupation income employment ever_married ever_divorced age_at_first_marriage age_at_first_divorce self_rated_health political_orientation ever_sex age_at_first_sex
ren * *_3
ren AID_ AID
save wave3, replace

**# Wave 4
clear
use "E:\AI助研 数据\Add Health\Wave4\21600-0022-Data.dta"

**# 1. SES
* highest education
gen education = ""
replace education = "BA or above" if inlist(H4ED2, 7, 8, 9, 10, 11, 12, 13)
replace education = "some college" if inlist(H4ED2, 6)
replace education = "high school or below" if inlist(H4ED2, 1, 2, 3, 4, 5)
fre education

* employment
fre H4LM7
gen employment = ""
replace employment = "unemployed" ///
    if H4LM7 == 0
replace employment = "employed" ///
    if H4LM7 == 1
fre employment

* occupation
fre H4LM18
gen occ_major = substr(H4LM18,1,2)
gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major=="11"
replace occupation = "Professionals" if inlist(occ_major,"13","15","17","19","21","23","25","27","29")
replace occupation = "Technicians and associate professionals" if occ_major=="31"
replace occupation = "Clerks" if occ_major=="43"
replace occupation = "Service workers and shop and market sales workers" if inlist(occ_major,"33","35","37","39","41")
replace occupation = "Skilled agricultural and fishery workers" if occ_major=="45"
replace occupation = "Craft and related trades workers" if occ_major=="47"
replace occupation = "Plant and machine operators and assemblers" if inlist(occ_major,"49","51","53")
replace occupation = "Armed forces" if occ_major=="55"
replace occupation = "unemployed" if employment=="unemployed"
fre occupation

* income
fre H4EC2
recode H4EC2(900000/10000000=.), gen(income)
fre income
	
**# 2. marry
* ever_married
fre H4TR1
gen married = .
replace married = 1 if H4TR1>0 & H4TR1<=4  // Ever married
replace married = 0 if H4TR1 == 0    // Never married
fre married

gen ever_married = ""
replace ever_married = "ever married"  if married == 1
replace ever_married = "never married" if married == 0
fre ever_married

* have sex
fre H4SE6
gen ever_sex = ""
replace ever_sex = "never sex" if H4SE6 == 0
replace ever_sex = "ever sex"   if H4SE6 == 1
fre ever_sex

* age_at_first_sex
fre H4SE7
g age_at_first_sex = H4SE7 if H4SE7<50 & H4SE7>=15
fre age_at_first_sex

* number_of_children
fre H4TR10
gen number_of_children = H4TR10
replace number_of_children = . if inlist(H4TR10, 97, 98)

* age_started_work:
gen age_started_work = H4LM5 if H4LM5<40
fre age_started_work

* self_rated_health:
fre H4GH1
gen health = ""
replace health = "excellent" if H4GH1 == 1
replace health = "very good" if H4GH1 == 2
replace health = "good"      if H4GH1 == 3
replace health = "fair"      if H4GH1 == 4
replace health = "poor"      if H4GH1 == 5
fre health
ren health self_rated_health

keep AID education employment occ_major occupation income married ever_married number_of_children age_started_work self_rated_health ever_sex age_at_first_sex
ren * *_4
ren AID AID
save wave4, replace

**# Wave 5
clear
use "E:\AI助研 数据\Add Health\Wave5\21600-0032-Data.dta"

**# 1. SES
* highest education
gen education = ""
replace education = "BA or above" if inlist(H5OD11, 10, 12, 14, 16, 11, 13, 15)
replace education = "some college" if inlist(H5OD11, 6, 7, 8, 9)
replace education = "high school or below" if inlist(H5OD11, 2, 3, 4, 5)
fre education

* employment
gen employment = ""
replace employment = "employed" if H5LM5 == 1
replace employment = "unemployed" if inlist(H5LM5, 2, 3)
fre employment

* income
gen income = .
replace income =  2500   if H5EC1 == 1
replace income =  7500   if H5EC1 == 2
replace income = 12500   if H5EC1 == 3
replace income = 17500   if H5EC1 == 4
replace income = 22500   if H5EC1 == 5
replace income = 27500   if H5EC1 == 6
replace income = 35000   if H5EC1 == 7
replace income = 45000   if H5EC1 == 8
replace income = 62500   if H5EC1 == 9
replace income = 87500   if H5EC1 == 10
replace income = 125000  if H5EC1 == 11
replace income = 175000  if H5EC1 == 12
replace income = 200000  if H5EC1 == 13
fre income
	
**# 2. marry
* ever_married
gen ever_married = ""
replace ever_married = "ever married" if inlist(H5HR1,1,2,3,4)
replace ever_married = "never married" if H5HR1 == 5
fre ever_married

* ever_divorced
gen ever_divorced = ""
replace ever_divorced = "never married" if H5HR1 == 5
replace ever_divorced = "ever divorced" if H5HR1 == 3
replace ever_divorced = "never divorced" if ever_divorced=="" & inlist(H5HR1,1,2,4)
fre ever_divorced

* have sex
fre H5SE1
gen ever_sex = ""
replace ever_sex = "never sex" if H5SE1 == 0
replace ever_sex = "ever sex"   if H5SE1 == 1
fre ever_sex

* age_at_first_sex
fre H5SE2
g age_at_first_sex = H5SE2 if H5SE2<50 & H5SE2>=15
fre age_at_first_sex

* self_rated_health:
fre H5ID1
gen health = ""
replace health = "excellent" if H5ID1 == 1
replace health = "very good" if H5ID1 == 2
replace health = "good"      if H5ID1 == 3
replace health = "fair"      if H5ID1 == 4
replace health = "poor"      if H5ID1 == 5
fre health
ren health self_rated_health

**# 3. Attitudes
* political attitudes
fre H5SS9
gen political_orientation = ""
replace political_orientation = "very conservative"   if H5SS9 == 1
replace political_orientation = "conservative"        if H5SS9 == 2
replace political_orientation = "middle-of-the-road"  if H5SS9 == 3
replace political_orientation = "liberal"             if H5SS9 == 4
replace political_orientation = "very liberal"        if H5SS9 == 5
fre political_orientation

keep AID education-political_orientation ever_sex age_at_first_sex
ren * *_5
ren AID_ AID
save wave5, replace

**# 
**# 
**# 
**# Merge Data
clear
use wave1
merge 1:1 AID using wave3
drop _merge
merge 1:1 AID using wave4
drop _merge
merge 1:1 AID using wave5
drop _merge

* demography
ren birth_year_1 birth_year
ren (father_edu_1 gender_1 hardwork_1 interpersonal_1 migrant_1 mother_edu_1 race_1 self_rated_depression_1 siblings_1)(father_edu gender hardwork interpersonal migrant mother_edu race self_rated_depression siblings)

* number_of_children
tostring number_of_children_4, replace
replace number_of_children_4 = "7 or more" if number_of_children_4=="7"
replace number_of_children_4 = "" if number_of_children_4=="."
ren number_of_children_4 child_number

* ever_married: 1, 3, 4, 5
gen ever_married = ever_married_5
replace ever_married = ever_married_4 if ever_married=="" & ever_married_4!=""
replace ever_married = ever_married_3 if ever_married=="" & ever_married_3!=""
replace ever_married = ever_married_1 if ever_married=="" & ever_married_1!=""
fre ever_married

* education: 3, 4, 5
gen education = education_5
replace education = education_4 if education=="" & education_4!=""
replace education = education_3 if education=="" & education_3!=""
ren education highest_education

* employment: 3, 4, 5
gen employment = employment_5
replace employment = employment_4 if employment=="" & employment_4!=""
replace employment = employment_3 if employment=="" & employment_3!=""

* ever_divorced: 3, 5
gen ever_divorced = ever_divorced_5
replace ever_divorced = ever_divorced_3 if ever_divorced=="" & ever_divorced_3!=""

* occupation: 3, 4
gen occupation = occupation_4
replace occupation = occupation_3 if occupation=="" & occupation_3!=""

* political_orientation: 3, 5
gen political_orientation = political_orientation_5
replace political_orientation = political_orientation_3 if political_orientation=="" & political_orientation_3!=""

* religion: 1, 3
gen religion = religion_3
replace religion = religion_1 if religion=="" & religion_1!=""

* self_rated_health: 1, 3, 4, 5
gen self_rated_health = self_rated_health_5
replace self_rated_health = self_rated_health_4 if self_rated_health=="" & self_rated_health_4!=""
replace self_rated_health = self_rated_health_3 if self_rated_health=="" & self_rated_health_3!=""
replace self_rated_health = self_rated_health_1 if self_rated_health=="" & self_rated_health_1!=""

* age_at_first_divorce
ren age_at_first_divorce_3 age_at_first_divorce
tostring age_at_first_divorce, replace
fre age_at_first_divorce
replace age_at_first_divorce = "" if age_at_first_divorce=="."
fre ever_married
replace age_at_first_divorce = "never married" if ever_married=="never married"
fre ever_divorced
replace age_at_first_divorce = "never divorced" if ever_divorced=="never divorced"
fre age_at_first_divorce

* age_started_work
fre age_started_work_4
replace age_started_work_4=. if age_started_work_4<18
ren age_started_work_4 age_started_work

* age_at_first_marriage
fre age_at_first_marriage_1 age_at_first_marriage_3
fre income_1 income_3 income_4 income_5
gen age_at_first_marriage = age_at_first_marriage_3
replace age_at_first_marriage = age_at_first_marriage_1 if missing(age_at_first_marriage) & !missing(age_at_first_marriage_1)
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "" if age_at_first_marriage=="."
replace age_at_first_marriage = "never married" if ever_married=="never married"
fre age_at_first_marriage

* income: 1, 3, 4, 5
gen income = income_5
replace income = income_4 if missing(income) & !missing(income_4)
replace income = income_3 if missing(income) & !missing(income_3)
replace income = income_1 if missing(income) & !missing(income_1)

* ever_sex
gen ever_sex = ever_sex_5
replace ever_sex = ever_sex_4 if ever_sex=="" & ever_sex_5!=""
replace ever_sex = ever_sex_3 if ever_sex=="" & ever_sex_4!=""
replace ever_sex = ever_sex_1 if ever_sex=="" & ever_sex_1!=""
fre ever_sex

* age_at_first_sex
gen age_at_first_sex = age_at_first_sex_5
replace age_at_first_sex = age_at_first_sex_4 if age_at_first_sex==. & age_at_first_sex_4!=.
replace age_at_first_sex = age_at_first_sex_3 if age_at_first_sex==. & age_at_first_sex_3!=.
replace age_at_first_sex = age_at_first_sex_1 if age_at_first_sex==. & age_at_first_sex_1!=.
fre age_at_first_sex
tostring age_at_first_sex, replace
replace age_at_first_sex = "never sex" if ever_sex == "never sex"
replace age_at_first_sex = "" if age_at_first_sex == "."
fre age_at_first_sex

* first_occupation
g first_occupation = ""
foreach yr in 3 4 {
    replace first_occupation = occupation_`yr' if missing(first_occupation) & !missing(occupation_`yr')
}
fre first_occupation

* siblings
tostring siblings, replace
replace siblings = "6 or above" if siblings == "6"
replace siblings = "" if siblings == "."
fre siblings
save working, replace

keep AID gender race siblings birth_year mother_edu father_edu migrant self_rated_depression hardwork interpersonal age_at_first_divorce child_number age_started_work ever_married highest_education ever_divorced political_orientation religion self_rated_health age_at_first_marriage ever_sex age_at_first_sex first_occupation
save addhealth_1994_2018, replace

**# sequential part
clear
use working
destring birth_year, replace
g age = 2018 - birth_year
fre age
drop if age == .

recode income_4(200000/1000000=200000)
drop income_1
keep AID education_* employment_* income_* occupation_* ever_married_* ever_divorced_* age
ren ever_married_* ever_married_sequential_*
ren ever_divorced_* ever_divorced_sequential_*

reshape long education_ employment_ income_ occupation_ ever_married_sequential_ ever_divorced_sequential_, i(AID) j(year)
gen age_year = age - (2018-1994) if year == 1
replace age_year = age - (2018-2008) if year == 3
replace age_year = age - (2018-2016) if year == 4
replace age_year = age if year == 5

drop year 
drop age
sort AID age_year
reshape wide education_ employment_ income_ occupation_ ever_married_sequential_ ever_divorced_sequential_, i(AID) j(age_year)

* mean_income_30_40
forvalues i = 21/24 {
	g income_`i' = .
	g occupation_`i' = .
	g employment_`i' = .
	g education_`i' = .
	g ever_divorced_sequential_`i' = .
	g ever_married_sequential_`i'=.
}
egen mean_income_30_40 = rowmean(income_30 income_31 income_32 income_33 income_34 income_35 income_36 income_37 income_38 income_39 income_40)
fre mean_income_30_40

forvalues i = 11/44 {
	tostring income_`i', replace
	replace income_`i' = "200000 or above" if income_`i' == "200000"
	replace income_`i' = "" if income_`i' == "."
}
gen mean_income_30_40_str = string(mean_income_30_40)
drop mean_income_30_40
ren mean_income_30_40_str mean_income_30_40
replace mean_income_30_40 = "200000 or above" if mean_income_30_40 == "200000"
replace mean_income_30_40 = "" if mean_income_30_40 == "."
fre mean_income_30_40

* main_occupation_30_40
preserve
keep AID occupation_30 occupation_31 occupation_32 occupation_33 occupation_34 occupation_35 occupation_36 occupation_37 occupation_38 occupation_39 occupation_40
reshape long occupation_, i(AID) j(year)
drop if occupation_ == ""
contract AID occupation_, freq(freq)
bysort AID (freq): keep if _n == _N
tempfile mode_occ
save `mode_occ'
restore
merge m:1 AID using `mode_occ', keepus(occupation_)
rename occupation_ occupation_30_40 
fre occupation_30_40

* Merge data
drop _merge
merge 1:1 AID using addhealth_1994_2018
drop _merge
save addhealth_1994_2018, replace
export delimited using addhealth_1994_2018, replace






