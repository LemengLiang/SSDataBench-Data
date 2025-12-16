clear all
set more off
use cfps2010adult, clear

**# CFPS WAVE 1 2010

**# 1. Demography
gen gender_c = ""
fre gender
replace gender_c = "Male" if gender == 1
replace gender_c = "Female" if gender == 0
drop gender
ren gender_c gender
fre gender

* birth year
fre qa1y_best
g birth_year = qa1y_best if qa1y_best>0

* minzu (ethnic group in China "民族")
gen minzu = ""
fre qa5code
replace minzu = "han" if qa5code == 1
replace minzu = "minority" if qa5code > 1 & qa5code < .
fre minzu

**# 2. Marriage
* age at first marriage
g age_at_first_marriage = qe605y_best - birth_year if qe605y_best>0 & qe605y_best - birth_year>20
fre age_at_first_marriage
fre qe1_best
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qe1_best == 1

* age at first divorce
g age_at_first_divorce = qe602y- birth_year if qe602y>0 & qe602y>qe605y_best & qe602y- birth_year>20
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qe1_best, 1, 2, 3, 5)

* age at first child
g age_at_first_child = tb1y_a_c1- birth_year if tb1y_a_c1>0 & tb1y_a_c1>qe605y_best & tb1y_a_c1- birth_year>20
fre age_at_first_child
tostring age_at_first_child, replace
replace age_at_first_child = "never had child" if qe1_best == 1

* ever_married
gen ever_married = ""
replace ever_married = "never married" if qe1_best == 1
replace ever_married = "ever married"  if inlist(qe1_best, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qe1_best == 1
replace marital_status = "married" if qe1_best == 2
replace marital_status = "cohabitation" if qe1_best == 3
replace marital_status = "divorced" if qe1_best == 4
replace marital_status = "widowed" if qe1_best == 5

* ever_divorced
gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qe1_best == 4
replace ever_divorced = "never divorced" if inlist(qe1_best, 1, 2, 3, 5)
fre ever_divorced

**# 3. SES
* age finished education
fre qc104 qc204 qc304 qc404 qc502 qc602 qc702 birth_year
foreach v of varlist qc104 qc204 qc304 qc404 qc502 qc602 qc702 {
    replace `v' = . if `v' < 0
}
fre qc104 qc204 qc304 qc404 qc502 qc602 qc702
gen age_finished_education = .
replace age_finished_education = qc104 - birth_year if !missing(qc104)
replace age_finished_education = . if !missing(qc104) & (qc104 - birth_year < 22)
* Master
replace age_finished_education = qc204 - birth_year if missing(age_finished_education) & !missing(qc204)
replace age_finished_education = . if !missing(qc204) & (qc204 - birth_year < 20)
* Undergraduate
replace age_finished_education = qc304 - birth_year if missing(age_finished_education) & !missing(qc304)
replace age_finished_education = . if !missing(qc304) & (qc304 - birth_year < 20)
* Undergraduate (junior college "专科")
replace age_finished_education = qc404 - birth_year if missing(age_finished_education) & !missing(qc404)
replace age_finished_education = . if !missing(qc404) & (qc404 - birth_year < 19)
* High school
replace age_finished_education = qc502 - birth_year if missing(age_finished_education) & !missing(qc502)
replace age_finished_education = . if !missing(qc502) & (qc502 - birth_year < 16)
* Middle high school
replace age_finished_education = qc602 - birth_year if missing(age_finished_education) & !missing(qc602)
replace age_finished_education = . if !missing(qc602) & (qc602 - birth_year < 14)
* Elementary school
replace age_finished_education = qc702 - birth_year if missing(age_finished_education) & !missing(qc702)
replace age_finished_education = . if !missing(qc702) & (qc702 - birth_year < 6)
fre age_finished_education
label var age_finished_education "Age finished highest education"
tostring age_finished_education, replace

* Maternal education
fre tb4_a_m
gen mother_education = ""
replace mother_education = "primary school or below" if inlist(tb4_a_m, 1, 2)
replace mother_education = "middle school"           if tb4_a_m == 3
replace mother_education = "high school"             if tb4_a_m == 4
replace mother_education = "college and above"       if inlist(tb4_a_m, 5, 6, 7, 8)
fre mother_education

* Paternal education
fre tb4_a_f
gen father_education = ""
replace father_education = "primary school or below" if inlist(tb4_a_f, 1, 2)
replace father_education = "middle school"           if tb4_a_f == 3
replace father_education = "high school"             if tb4_a_f == 4
replace father_education = "college and above"       if inlist(tb4_a_f, 5, 6, 7, 8)
fre father_education

* Personal education
fre cfps2010eduy_best
gen education = ""
replace education = "primary school or below" if inrange(cfps2010eduy_best, 0, 6)
replace education = "middle school" if inrange(cfps2010eduy_best, 7, 9)
replace education = "high school" if inrange(cfps2010eduy_best, 10, 12)
replace education = "college and above" if cfps2010eduy_best >= 13 & cfps2010eduy_best < .
fre education

* income
recode income(-8=.)
fre income

* occupation
gen occ_code = qg307isco
replace occ_code = qg601_isco if missing(occ_code) & qg601_isco != .
replace occ_code = qg701_isco if missing(occ_code) & qg701_isco != .
replace occ_code = qh405isco if missing(occ_code) & qh405isco != .
fre occ_code
* Extract the first digit (ISCO major group)
gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
replace occ_major = floor(occ_code / 100)  if occ_code < 1000 & occ_code >= 100
replace occ_major = floor(occ_code / 10)   if occ_code < 100 & occ_code >= 10
replace occ_major = occ_code               if occ_code < 10 & occ_code >= 1
fre occ_major
gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "Unemployed" if qg3 == 0 & occupation==""
fre occupation

* age_exited_work
gen age_exited_work = qj2 - birth_year if !missing(qj2, birth_year)
replace age_exited_work = . if age_exited_work < 30   // 退休年龄至少30岁
replace age_exited_work = . if age_exited_work > 100  
fre age_started_work
fre age_exited_work
fre qg3
tostring age_exited_work, replace
replace age_exited_work = "still working" if qg3 == 1

* employment
fre qg3
gen employment = ""
replace employment = "unemployed" if qg3 == 0
replace employment = "employed"   if qg3 == 1
fre employment

**# 4. Health
gen self_rated_health = ""
fre qp3
replace self_rated_health = "very healthy"        if qp3 == 1
replace self_rated_health = "fairly healthy"      if qp3 == 2
replace self_rated_health = "somewhat unhealthy"  if qp3 == 3
replace self_rated_health = "unhealthy"           if qp3 == 4
replace self_rated_health = "very unhealthy"      if qp3 == 5
fre self_rated_health

gen self_rated_depression = fdepression

**# 5. Ability
fre ks601 ks602 ks603 ks604 ks605 ks606  
local namelist ks601 ks602 ks603 ks604 ks605 ks606
forvalues j = 1/6 {
local varname = word("`namelist'",`j')
g non`j'_stu = `varname'
}
recode non*_stu(-8/-1=.)(79=.)
factor non1_stu - non6_stu, pcf
rotate, blanks(0.55)
predict self_control

* skills rated by interviewers
fre qz201 qz208 qz212
g comprehension = qz201 if qz201>0 //comprehension ability
g interpersonal_skills = qz208 if qz208>0  //interpersonal skills
g expression = qz212 if qz212>0 //expression ability

* Cognitive ability
fre mathtest wordtest
gen math_cognitive = mathtest if inrange(mathtest, 0, 24)
gen verbal_cognitive = wordtest if inrange(wordtest, 0, 34)

**# Age at death (data from 2020)
merge 1:1 pid using cfps2020crossyearid, keepus(death_year)
drop _merge
* age_at_death
fre death_year birth_year
foreach v of varlist death_year birth_year {
    replace `v' = . if `v' < 0
}
gen age_at_death = death_year - birth_year if !missing(death_year, birth_year)
replace age_at_death = . if age_at_death < 0      // 出生后未满0岁
replace age_at_death = . if age_at_death > 120  
sum age_at_death, detail
fre age_at_death

keep pid gender birth_year ///
minzu ///
mother_education father_education ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce age_at_first_child ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health age_at_death self_rated_depression ///
self_control interpersonal_skills ///
comprehension expression math_cognitive verbal_cognitive marital_status
save CFPS2010_clean1, replace

* number of siblings (data from famconf.dta)
clear
use cfps2010famconf
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_c`i' == -8 | pid_c`i' == 77   
replace xx`i' = 1 if pid_c`i' != -8 & pid_c`i' != 77 
}
egen child_number = rowtotal(xx*) 
fre child_number
keep pid child_number
merge 1:1 pid using CFPS2010_clean1
keep if _merge == 3
drop _merge

rename * *_2010
rename pid_2010 pid
save CFPS2010_clean1_1, replace

**# 
**# 
**# 
**# 2012
clear all
set more off
use cfps2012adult, clear

**# 1. Demography
gen gender_c = ""  // cfps2012_gender_best
fre cfps2012_gender_best
replace gender_c = "Male" if cfps2012_gender_best == 1
replace gender_c = "Female" if cfps2012_gender_best == 0
rename gender_c gender
fre gender

* birth year
fre cfps2012_birthy_best
gen birth_year = cfps2012_birthy_best if cfps2012_birthy_best > 0

* ethnic identity
gen minzu = "" // qa701code "民族"
fre qa701code
replace minzu = "han" if qa701code == 1
replace minzu = "minority" if qa701code > 1 & qa701code < .
fre minzu

* religion
fre qm601
gen religion = ""
replace religion = "Buddha or Bodhisattva" if qm601 == 1
replace religion = "Taoist deities"        if qm601 == 2
replace religion = "Allah"                 if qm601 == 3
replace religion = "God (Catholic)"        if qm601 == 4
replace religion = "God (Christian)"       if qm601 == 5
replace religion = "Ancestors"             if qm601 == 6
replace religion = "No religious belief"   if qm601 == 7
label var religion "Religious belief or affiliation"
fre religion

**# 2. Socioeconomic Status (SES)
* mother's education
fre qv202
gen mother_education = ""
replace mother_education = "primary school or below" if inlist(qv202, 1, 2)
replace mother_education = "middle school"           if qv202 == 3
replace mother_education = "high school"             if qv202 == 4
replace mother_education = "college and above"       if inlist(qv202, 5, 6, 7, 8)
fre mother_education

* father's education
fre qv102
gen father_education = ""
replace father_education = "primary school or below" if inlist(qv102, 1, 2)
replace father_education = "middle school"           if qv102 == 3
replace father_education = "high school"             if qv102 == 4
replace father_education = "college and above"       if inlist(qv102, 5, 6, 7, 8)
fre father_education

* personal education
fre eduy2012
gen education = ""
replace education = "primary school or below" if inrange(eduy2012, 0, 6)
replace education = "middle school" if inrange(eduy2012, 7, 9)
replace education = "high school" if inrange(eduy2012, 10, 12)
replace education = "college and above" if eduy2012 >= 13 & eduy2012 < .
fre education

* age finished education
fre kw2y
gen age_finished_education = kw2y - birth_year if kw2y > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* income
recode income (-8 = .)
fre income

* employment
fre qg101
gen employment = ""
replace employment = "unemployed" if qg101 == 5
replace employment = "employed"   if qg101 == 1
label var employment "Current job status"
fre employment

* occupation
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi202y
gen age_exited_work = qi202y - birth_year if qi202y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
label var age_exited_work "Age exited work"
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if qg101 == 1

**# 3. Marriage and Familty
fre qe104
gen ever_married = ""
replace ever_married = "never married" if qe104 == 1
replace ever_married = "ever married"  if inlist(qe104, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qe104 == 1
replace marital_status = "married" if qe104 == 2
replace marital_status = "cohabitation" if qe104 == 3
replace marital_status = "divorced" if qe104 == 4
replace marital_status = "widowed" if qe104 == 5

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qe104 == 4
replace ever_divorced = "never divorced" if inlist(qe104, 1, 2, 3, 5)
fre ever_divorced

* age at first marriage
fre qec702y
gen age_at_first_marriage = qec702y - birth_year if qec702y > 0 & (qec702y - birth_year > 20)
fre age_at_first_marriage
fre qe104
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qe104 == 1

* age at first divorce
fre qe602y
gen age_at_first_divorce = qe602y - birth_year if qe602y > 0 & qe602y > qec702y & (qe602y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qe104, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre qq6011-qq60120
factor qq6011-qq60120, pcf
rotate, blanks(0.55)
predict self_rated_depression
label var self_rated_depression "Depression score (higher=worse mental health)"
sum self_rated_depression

**# 5. Ability
fre ks601 ks602 ks603 ks604 ks605 ks606
local namelist ks601 ks602 ks603 ks604 ks605 ks606
forvalues j = 1/6 {
    local varname = word("`namelist'", `j')
    gen non`j'_stu = `varname'
	recode non`j'_stu (-8/-1 = .) (79 = .)(1=5)(2=4)(4=2)(5=1)
}
factor non1_stu - non6_stu, pcf
rotate, blanks(0.55)
predict self_control
label var self_control "Self-control ability (factor score)"
fre self_control

* skills rated by interviewers
fre qz201 qz208 qz212
g comprehension = qz201 if qz201>0 //comprehension ability
g interpersonal_skills = qz208 if qz208>0  //interpersonal skills
g expression = qz212 if qz212>0 //expression ability

keep pid gender birth_year ///
minzu ///
mother_education father_education ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression ///
self_control interpersonal_skills ///
comprehension expression religion marital_status
save CFPS2012_clean1, replace

* number of siblings
clear
use cfps2012famconf
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_c`i' == -8 | pid_c`i' == 77   
replace xx`i' = 1 if pid_c`i' != -8 & pid_c`i' != 77  
}
egen child_number = rowtotal(xx*)  
fre child_number
keep pid child_number
duplicates drop pid, force
merge 1:1 pid using CFPS2012_clean1
keep if _merge == 3
drop _merge

rename * *_2012
rename pid_2012 pid
save CFPS2012_clean1_1, replace

**# 2014
* occupation recode // technical details see http://www.isss.pku.edu.cn/cfps/docs/20180927133140517170.pdf  "中国家庭动态跟踪调查职业社会经济地位测量指标构建" by Guoying Huang and Yu Xie
clear
global c14 "$cfps2014"
clear matrix
cap do close
cap log close
set more off
set memory 400m
cd  "$c14"
log using output_occrecode.log, replace text
adopath+"c14\iscoocc.ado"
local iscolab = "$c14\"
use cfps2014adult.dta,clear

*Map CSCO codes to ISCO88 codes.
iscoocc occp2014, iocc(qg303code)
do iscolab.do 
g occ_code = occp2014
fre occ_code
save, replace

clear all
set more off
use cfps2014adult, clear

**# 1. Demography
gen gender_c = ""  // cfps2014_gender_best
fre cfps_gender
replace gender_c = "Male" if cfps_gender == 1
replace gender_c = "Female" if cfps_gender == 0
rename gender_c gender
fre gender

* birth year
fre cfps_birthy
gen birth_year = cfps_birthy if cfps_birthy > 0

* ethnic identity
gen minzu = "" // qa701code "民族"
fre qa701code
replace minzu = "han" if qa701code == 1
replace minzu = "minority" if qa701code > 1 & qa701code < .
fre minzu

* religion
fre qm601a_s_1
gen religion = ""
replace religion = "Buddha or Bodhisattva" if qm601a_s_1 == 1
replace religion = "Taoist deities"        if qm601a_s_1 == 2
replace religion = "Allah"                 if qm601a_s_1 == 3
replace religion = "God (Catholic)"        if qm601a_s_1 == 4
replace religion = "God (Christian)"       if qm601a_s_1 == 5
replace religion = "Ancestors"             if qm601a_s_1 == 6
replace religion = "No religious belief"   if qm601a_s_1 == 78
label var religion "Religious belief or affiliation"
fre religion

**# 2. Socioeconomic Status (SES)
* personal education
fre cfps2014eduy_im
gen education = ""
replace education = "primary school or below" if inrange(cfps2014eduy_im, 0, 6)
replace education = "middle school" if inrange(cfps2014eduy_im, 7, 9)
replace education = "high school" if inrange(cfps2014eduy_im, 10, 12)
replace education = "college and above" if cfps2014eduy_im >= 13 & cfps2014eduy_im < .
fre education

* income
recode income (-8 = .)
fre income

* employment
fre employ2014
gen employment = ""
replace employment = "unemployed" if employ2014 == 0 | employ2014 == 3
replace employment = "employed"   if employ2014 == 1
label var employment "Current job status"
fre employment

* age finished education
fre kw2y
gen age_finished_education = kw2y - birth_year if kw2y > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* occupation
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi102y
gen age_exited_work = qi102y - birth_year if qi102y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if qg101 == 1

**# 3. Marriage and Familty
fre qea0
gen ever_married = ""
replace ever_married = "never married" if qea0 == 1
replace ever_married = "ever married"  if inlist(qea0, 2, 3, 4, 5)
fre ever_married

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qea0 == 4
replace ever_divorced = "never divorced" if inlist(qea0, 1, 2, 3, 5)
fre ever_divorced

g marital_status = ""
replace marital_status = "single" if qea0 == 1
replace marital_status = "married" if qea0 == 2
replace marital_status = "cohabitation" if qea0 == 3
replace marital_status = "divorced" if qea0 == 4
replace marital_status = "widowed" if qea0 == 5

* age at first marriage
fre qea205y
gen age_at_first_marriage = qea205y - birth_year if qea205y > 0 & (qea205y - birth_year > 20)
fre age_at_first_marriage
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qea0 == 1

* age at first divorce
fre qea208y
gen age_at_first_divorce = qea208y - birth_year if qea208y > 0 & qea208y > qea205y & (qea208y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qea0, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre qq601 qq602 qq603 qq604 qq605 qq606
factor qq601 qq602 qq603 qq604 qq605 qq606, pcf
rotate, blanks(0.55)
predict self_rated_depression
label var self_rated_depression "Depression score (higher=worse mental health)"
sum self_rated_depression

**# 5. Ability
fre ks601 ks602 ks603 ks604 ks605 ks606
local namelist ks601 ks602 ks603 ks604 ks605 ks606
forvalues j = 1/6 {
    local varname = word("`namelist'", `j')
    gen non`j'_stu = `varname'
	recode non`j'_stu (-8/-1 = .) (79 = .)(1=5)(2=4)(4=2)(5=1)
}
factor non1_stu - non6_stu, pcf
rotate, blanks(0.55)
predict self_control
label var self_control "Self-control ability (factor score)"
fre self_control

* skills rated by interviewers
fre qz201 qz208 qz212
g comprehension = qz201 if qz201>0 //comprehension ability
g interpersonal_skills = qz208 if qz208>0  //interpersonal skills
g expression = qz212 if qz212>0 //expression ability

* Cognitive ability
fre mathtest14 wordtest14
gen math_cognitive = mathtest14 if inrange(mathtest14, 0, 24)
gen verbal_cognitive = wordtest14 if inrange(wordtest14, 0, 34)

* gender role
fre qm1101 qm1102 qm1103 qm1104
foreach v of varlist qm1101 qm1102 qm1103 qm1104 {
    replace `v' = . if `v' < 0
}
factor qm1101 qm1102 qm1103 qm1104, factors(1)
predict gender_role

keep pid gender birth_year ///
minzu ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression ///
self_control interpersonal_skills ///
comprehension expression gender_role math_cognitive verbal_cognitive religion marital_status
save CFPS2014_clean1, replace

* number of siblings
clear
use cfps2014famconf 
duplicates drop pid, force
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_c`i' == -8 | pid_c`i' == 77  
replace xx`i' = 1 if pid_c`i' != -8 & pid_c`i' != 77  
}
egen childnumber = rowtotal(xx*)  
fre childnumber
g sib_number = childnumber - 1 if childnumber>=1 
keep pid sib_number
merge 1:1 pid using CFPS2014_clean1
keep if _merge == 3
drop _merge

rename * *_2014
rename pid_2014 pid
save CFPS2014_clean1_1, replace

**# 2016
clear all
set more off
use "$cfps2016\cfps2016adult.dta", clear

**# 1. Demography
gen gender_c = ""  // cfps2016_gender_best
fre cfps_gender
replace gender_c = "Male" if cfps_gender == 1
replace gender_c = "Female" if cfps_gender == 0
rename gender_c gender
fre gender

* birth year
fre cfps_birthy
gen birth_year = cfps_birthy if cfps_birthy > 0

* ethnic identity
gen minzu = "" // qa701code "民族"
fre pa701code
replace minzu = "han" if pa701code == 1
replace minzu = "minority" if pa701code > 1 & pa701code < .
fre minzu

* religion
fre qm601_s_1
gen religion = ""
replace religion = "Buddha or Bodhisattva" if qm601_s_1 == 1
replace religion = "Taoist deities"        if qm601_s_1 == 2
replace religion = "Allah"                 if qm601_s_1 == 3
replace religion = "God (Catholic)"        if qm601_s_1 == 4
replace religion = "God (Christian)"       if qm601_s_1 == 5
replace religion = "No religious belief"   if qm601_s_1 == 77
label var religion "Religious belief or affiliation"
fre religion

**# 2. Socioeconomic Status (SES)
* personal education
fre cfps2016eduy_im
gen education = ""
replace education = "primary school or below" if inrange(cfps2016eduy_im, 0, 6)
replace education = "middle school" if inrange(cfps2016eduy_im, 7, 9)
replace education = "high school" if inrange(cfps2016eduy_im, 10, 12)
replace education = "college and above" if cfps2016eduy_im >= 13 & cfps2016eduy_im < .
fre education

* age finished education
fre kw2y_b_1
gen age_finished_education = kw2y_b_1 - birth_year if kw2y_b_1 > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* income
recode income (-8 = .)
fre income

* employment
fre employ
gen employment = ""
replace employment = "unemployed" if employ == 0 | employ == 3
replace employment = "employed"   if employ == 1
fre employment

* occupation
g occ_code = qg303code_isco if qg303code_isco>0
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi102y
gen age_exited_work = qi102y - birth_year if qi102y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if employment == "employed"

**# 3. Marriage and Familty
fre qea0
gen ever_married = ""
replace ever_married = "never married" if qea0 == 1
replace ever_married = "ever married"  if inlist(qea0, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qea0 == 1
replace marital_status = "married" if qea0 == 2
replace marital_status = "cohabitation" if qea0 == 3
replace marital_status = "divorced" if qea0 == 4
replace marital_status = "widowed" if qea0 == 5

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qea0 == 4
replace ever_divorced = "never divorced" if inlist(qea0, 1, 2, 3, 5)
fre ever_divorced

* age at first marriage
fre qea205y
fre qea0
gen age_at_first_marriage = qea205y - birth_year if qea205y > 0 & (qea205y - birth_year > 20)
fre age_at_first_marriage
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qea0 == 1

* age at first divorce
fre qea208y
gen age_at_first_divorce = qea208y - birth_year if qea208y > 0 & qea208y > qea205y & (qea208y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qea0, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre pn401- pn420
factor pn401- pn420, pcf
rotate, blanks(0.55)
predict self_rated_depression
label var self_rated_depression "Depression score (higher=worse mental health)"
sum self_rated_depression

**# 5. Ability
fre ks601 ks602 ks603 ks604 ks605 ks606
local namelist ks601 ks602 ks603 ks604 ks605 ks606
forvalues j = 1/6 {
    local varname = word("`namelist'", `j')
    gen non`j'_stu = `varname'
	recode non`j'_stu (-8/-1 = .) (79 = .)
}
factor non1_stu - non6_stu, pcf
rotate, blanks(0.55)
predict self_control
label var self_control "Self-control ability (factor score)"
fre self_control

* skills rated by interviewers
fre qz201 qz208 qz212
g comprehension = qz201 if qz201>0 //comprehension ability
g interpersonal_skills = qz208 if qz208>0  //interpersonal skills
g expression = qz212 if qz212>0 //expression ability

keep pid gender birth_year ///
minzu ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression ///
self_control interpersonal_skills ///
comprehension expression religion marital_status
save "$working_data\CFPS2016_clean1.dta", replace

* number of siblings
clear
use "$cfps2016\cfps2016famconf.dta" 
duplicates drop pid, force
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_c`i' == -8 | pid_c`i' == 77   
replace xx`i' = 1 if pid_c`i' != -8 & pid_c`i' != 77  
}
egen childnumber = rowtotal(xx*)  
fre childnumber
g sib_number = childnumber - 1 if childnumber>=1 
keep pid sib_number
merge 1:1 pid using "$working_data\CFPS2016_clean1"
keep if _merge == 3
drop _merge

rename * *_2016
rename pid_2016 pid
save "$working_data\CFPS2016_clean1_1.dta", replace

**# 2018
clear all
set more off
use "$cfps2018\cfps2018person.dta", clear

**# 1. Demography
gen gender_c = ""  // cfps2018_gender_best
fre gender
replace gender_c = "Male" if gender == 1
replace gender_c = "Female" if gender == 0
drop gender
rename gender_c gender
fre gender

* birth year
fre ibirthy_update
gen birth_year = ibirthy_update if ibirthy_update > 0

* ethnic identity
drop minzu
gen minzu = "" // qa701code "民族"
fre qa701code
replace minzu = "han" if qa701code == 1
replace minzu = "minority" if qa701code > 1 & qa701code < .
fre minzu

* religion
fre qm6010 qm6011 qm6012 qm6013 qm6014 qm6015
gen religion = ""
replace religion = "Buddha or Bodhisattva" if qm6010 == 1
replace religion = "Taoist deities"        if qm6011 == 1
replace religion = "Allah"                 if qm6012 == 1
replace religion = "God (Catholic)"        if qm6013 == 1
replace religion = "God (Christian)"       if qm6014 == 1
replace religion = "Ancestors"             if qm6015 == 1
replace religion = "No religious belief"   if religion == ""
label var religion "Religious belief or affiliation"
fre religion

**# 2. Socioeconomic Status (SES)
* personal education
fre cfps2018eduy_im
gen education = ""
replace education = "primary school or below" if inrange(cfps2018eduy_im, 0, 6)
replace education = "middle school" if inrange(cfps2018eduy_im, 7, 9)
replace education = "high school" if inrange(cfps2018eduy_im, 10, 12)
replace education = "college and above" if cfps2018eduy_im >= 13 & cfps2018eduy_im < .
fre education

* age finished education
fre kw2y
gen age_finished_education = kw2y - birth_year if kw2y > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* income
recode income (-9/-1 = .)
fre income

* employment
fre employ
gen employment = ""
replace employment = "unemployed" if employ == 0 | employ == 3
replace employment = "employed"   if employ == 1
fre employment

* occupation
g occ_code = qg303code_isco if qg303code_isco>0
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi102y
gen age_exited_work = qi102y - birth_year if qi102y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if employment == "employed"

**# 3. Marriage and Familty
fre qea0
gen ever_married = ""
replace ever_married = "never married" if qea0 == 1
replace ever_married = "ever married"  if inlist(qea0, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qea0 == 1
replace marital_status = "married" if qea0 == 2
replace marital_status = "cohabitation" if qea0 == 3
replace marital_status = "divorced" if qea0 == 4
replace marital_status = "widowed" if qea0 == 5

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qea0 == 4
replace ever_divorced = "never divorced" if inlist(qea0, 1, 2, 3, 5)
fre ever_divorced

* age at first marriage
fre qea205y
fre qea0
gen age_at_first_marriage = qea205y - birth_year if qea205y > 0 & (qea205y - birth_year > 20)
fre age_at_first_marriage
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qea0 == 1

* age at first divorce
fre qea208y
gen age_at_first_divorce = qea208y - birth_year if qea208y > 0 & qea208y > qea205y & (qea208y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qea0, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre cesd8
zscore cesd8
ren z_cesd8 self_rated_depression
sum self_rated_depression

* ability
gen math_cognitive = mathtest18 if inrange(mathtest18, 0, 24)
gen verbal_cognitive = wordtest18 if inrange(wordtest18, 0, 34)
fre wordtest18 mathtest18 

keep pid gender birth_year ///
minzu ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression math_cognitive verbal_cognitive religion marital_status
save "$working_data\CFPS2018_clean1.dta", replace

* number of siblings
clear
use "$cfps2018\cfps2018famconf.dta" 
duplicates drop pid, force
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_a_c`i' == -8 | pid_a_c`i' == 77   
replace xx`i' = 1 if pid_a_c`i' != -8 & pid_a_c`i' != 77 
}
egen childnumber = rowtotal(xx*) 
fre childnumber
g sib_number = childnumber - 1 if childnumber>=1
keep pid sib_number
merge 1:1 pid using "$working_data\CFPS2018_clean1"
keep if _merge == 3
drop _merge

rename * *_2018
rename pid_2018 pid
save "$working_data\CFPS2018_clean1_1.dta", replace

**# 2020
clear all
set more off
use "$cfps2020\cfps2020person.dta", clear

**# 1. Demography
gen gender_c = ""  // cfps2020_gender_best
fre gender
replace gender_c = "Male" if gender == 1
replace gender_c = "Female" if gender == 0
drop gender
rename gender_c gender
fre gender

* birth year
fre ibirthy_update
gen birth_year = ibirthy_update if ibirthy_update > 0

* ethnic identity
drop minzu
gen minzu = "" // qa701code "民族"
fre qa701code
replace minzu = "han" if qa701code == 1
replace minzu = "minority" if qa701code > 1 & qa701code < .
fre minzu

**# 2. Socioeconomic Status (SES)
* personal education
fre cfps2020eduy_im
gen education = ""
replace education = "primary school or below" if inrange(cfps2020eduy_im, 0, 6)
replace education = "middle school" if inrange(cfps2020eduy_im, 7, 9)
replace education = "high school" if inrange(cfps2020eduy_im, 10, 12)
replace education = "college and above" if cfps2020eduy_im >= 13 & cfps2020eduy_im < .
fre education

* age finished education
fre kw2y
gen age_finished_education = kw2y - birth_year if kw2y > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* income
recode emp_income (-8 = .)
fre emp_income
g income = emp_income

* employment
fre employ
gen employment = ""
replace employment = "unemployed" if employ == 0 | employ == 3
replace employment = "employed"   if employ == 1
fre employment

* occupation
g occ_code = qg303code_isco if qg303code_isco>0
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi102y
gen age_exited_work = qi102y - birth_year if qi102y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if employment == "employed"

**# 3. Marriage and Familty
fre qea0
gen ever_married = ""
replace ever_married = "never married" if qea0 == 1
replace ever_married = "ever married"  if inlist(qea0, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qea0 == 1
replace marital_status = "married" if qea0 == 2
replace marital_status = "cohabitation" if qea0 == 3
replace marital_status = "divorced" if qea0 == 4
replace marital_status = "widowed" if qea0 == 5

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qea0 == 4
replace ever_divorced = "never divorced" if inlist(qea0, 1, 2, 3, 5)
fre ever_divorced

* age at first marriage
fre qea205y
fre qea0
gen age_at_first_marriage = qea205y - birth_year if qea205y > 0 & (qea205y - birth_year > 20)
fre age_at_first_marriage
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qea0 == 1

* age at first divorce
fre qea208y
gen age_at_first_divorce = qea208y - birth_year if qea208y > 0 & qea208y > qea205y & (qea208y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qea0, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre cesd8
zscore cesd8
ren z_cesd8 self_rated_depression
sum self_rated_depression

keep pid gender birth_year ///
minzu ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression marital_status
save "$working_data\CFPS2020_clean1.dta", replace

* number of siblings
clear
use "$cfps2020\cfps2020famconf.dta" 
duplicates drop pid, force
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_a_c`i' == -8 | pid_a_c`i' == 77   
replace xx`i' = 1 if pid_a_c`i' != -8 & pid_a_c`i' != 77 
}
egen childnumber = rowtotal(xx*) 
fre childnumber
g sib_number = childnumber - 1 if childnumber>=1
keep pid sib_number
merge 1:1 pid using "$working_data\CFPS2020_clean1"
keep if _merge == 3
drop _merge

rename * *_2020
rename pid_2020 pid
save "$working_data\CFPS2020_clean1_1.dta", replace

**# 2022
clear all
set more off
use "$cfps2022\cfps2022person.dta", clear

**# 1. Demography
gen gender_c = ""  // cfps2022_gender_best
fre gender
replace gender_c = "Male" if gender == 1
replace gender_c = "Female" if gender == 0
drop gender
rename gender_c gender
fre gender

* birth year
fre ibirthy_update
gen birth_year = ibirthy_update if ibirthy_update > 0

* ethnic identity
drop minzu
gen minzu = "" // qa701code "民族"
fre qa701code
replace minzu = "han" if qa701code == 1
replace minzu = "minority" if qa701code > 1 & qa701code < .
fre minzu

**# 2. Socioeconomic Status (SES)
* personal education
fre cfps2022eduy_im
gen education = ""
replace education = "primary school or below" if inrange(cfps2022eduy_im, 0, 6)
replace education = "middle school" if inrange(cfps2022eduy_im, 7, 9)
replace education = "high school" if inrange(cfps2022eduy_im, 10, 12)
replace education = "college and above" if cfps2022eduy_im >= 13 & cfps2022eduy_im < .
fre education

* age finished education
fre kw2y
gen age_finished_education = kw2y - birth_year if kw2y > 0
replace age_finished_education = . if age_finished_education < 6 | age_finished_education > 63
label var age_finished_education "Age finished highest education"
fre age_finished_education

* income
recode emp_income (-8 = .)
fre emp_income
g income = emp_income

* employment
fre employ
gen employment = ""
replace employment = "unemployed" if employ == 0 | employ == 3
replace employment = "employed"   if employ == 1
fre employment

* occupation
g occ_code = qg303code_isco if qg303code_isco>0
fre occ_code

gen occ_major = .
replace occ_major = floor(occ_code / 1000) if occ_code >= 1000
fre occ_major

gen occupation = ""
replace occupation = "Legislators, senior officials and managers" if occ_major == 1
replace occupation = "Professionals" if occ_major == 2
replace occupation = "Technicians and associate professionals" if occ_major == 3
replace occupation = "Clerks" if occ_major == 4
replace occupation = "Service workers and shop and market sales workers" if occ_major == 5
replace occupation = "Skilled agricultural and fishery workers" if occ_major == 6
replace occupation = "Craft and related trades workers" if occ_major == 7
replace occupation = "Plant and machine operators and assemblers" if occ_major == 8
replace occupation = "Elementary occupations" if occ_major == 9
replace occupation = "Armed forces" if occ_major == 0
replace occupation = "unemployed" if employment == "unemployed" & occupation == ""
fre occupation

* retire age
fre qi102y
gen age_exited_work = qi102y - birth_year if qi102y > 0
replace age_exited_work = . if age_exited_work < 30 | age_exited_work > 100
fre age_exited_work
tostring age_exited_work, replace
replace age_exited_work = "still working" if employment == "employed"

**# 3. Marriage and Familty
fre qea0
gen ever_married = ""
replace ever_married = "never married" if qea0 == 1
replace ever_married = "ever married"  if inlist(qea0, 2, 3, 4, 5)
fre ever_married

g marital_status = ""
replace marital_status = "single" if qea0 == 1
replace marital_status = "married" if qea0 == 2
replace marital_status = "cohabitation" if qea0 == 3
replace marital_status = "divorced" if qea0 == 4
replace marital_status = "widowed" if qea0 == 5

gen ever_divorced = ""
replace ever_divorced = "ever divorced"  if qea0 == 4
replace ever_divorced = "never divorced" if inlist(qea0, 1, 2, 3, 5)
fre ever_divorced

* age at first marriage
fre qea205y
fre qea0
gen age_at_first_marriage = qea205y - birth_year if qea205y > 0 & (qea205y - birth_year > 20)
fre age_at_first_marriage
tostring age_at_first_marriage, replace
replace age_at_first_marriage = "never married" if qea0 == 1

* age at first divorce
fre qea208y
gen age_at_first_divorce = qea208y - birth_year if qea208y > 0 & qea208y > qea205y & (qea208y - birth_year > 20)
fre age_at_first_divorce
tostring age_at_first_divorce, replace
replace age_at_first_divorce = "never divorced" if inlist(qea0, 1, 2, 3, 5)

**# 4. Health
fre qp201
gen self_rated_health = ""
replace self_rated_health = "very healthy"        if qp201 == 1
replace self_rated_health = "fairly healthy"      if qp201 == 2
replace self_rated_health = "somewhat unhealthy"  if qp201 == 3
replace self_rated_health = "unhealthy"           if qp201 == 4
replace self_rated_health = "very unhealthy"      if qp201 == 5
fre self_rated_health

* depression
fre cesd8
zscore cesd8
ren z_cesd8 self_rated_depression
sum self_rated_depression

* ability
gen math_cognitive = mathtest22 if inrange(mathtest22, 0, 24)
gen verbal_cognitive = wordtest22 if inrange(wordtest22, 0, 34)
fre wordtest22 mathtest22 

* fixed and growth mindset
fre qms1 qms2 qms3 qms4
egen fixed_mindset = rowmean(qms1 qms2) if qms1>0 & qms2>0
egen growth_mindset = rowmean(qms3 qms4) if qms3>0 & qms4>0

keep pid gender birth_year ///
minzu ///
ever_married ever_divorced ///
age_at_first_marriage age_at_first_divorce ///
age_finished_education age_started_work age_exited_work ///
education education occupation income employment ///
self_rated_health self_rated_depression math_cognitive verbal_cognitive fixed_mindset growth_mindset marital_status
save "$working_data\CFPS2022_clean1.dta", replace

* number of siblings
clear
clear
use "$cfps2022\cfps2022famconf.dta" 
duplicates drop pid, force
forvalues i = 1(1)10{   
gen xx`i' = 0 if pid_c`i' == -8 | pid_c`i' == 77   
replace xx`i' = 1 if pid_c`i' != -8 & pid_c`i' != 77 
}
egen childnumber = rowtotal(xx*)
fre childnumber
g sib_number = childnumber - 1 if childnumber>=1
keep pid sib_number
keep pid sib_number
merge 1:1 pid using "$working_data\CFPS2022_clean1"
keep if _merge == 3
drop _merge

rename * *_2022
rename pid_2022 pid
save "$working_data\CFPS2022_clean1_1.dta", replace

**# 
**# 
**# 
**# Merge data
clear all
set more off
clear
use "$working_data\CFPS2010_clean1_1.dta"

* MERGE DATA FROM ALL WAVES
local waves 2012 2014 2016 2018 2020 2022
foreach yr of local waves {
    merge 1:1 pid using "$working_data\CFPS`yr'_clean1_1.dta"
    drop _merge
}
save "$working_data\CFPS_panel_2010_2022.dta", replace

**# 1. static variables
ren age_at_death_2010 age_at_death
fre age_at_death
tostring age_at_death, replace
replace age_at_death = "still alive" if age_at_death==""

fre age_at_first_child_2010
replace age_at_first_child_2010 = "" if age_at_first_child_2010=="."
ren age_at_first_child_2010 age_at_first_child

* Based on the first year, with missing values imputed using information from later waves
fre age_at_first_divorce_2010
foreach yr in 2010 2012 2014 2016 2018 2020 2022 {
    replace age_at_first_divorce_`yr' = "" if age_at_first_divorce_`yr' == "."
}
foreach yr in 2010 2012 2014 2016 2018 2020 {
    local next = `yr' + 2
    replace age_at_first_divorce_`yr' = age_at_first_divorce_`next' if age_at_first_divorce_`yr' == ""
}
fre age_at_first_divorce_2010
ren age_at_first_divorce_2010 age_at_first_divorce

fre mother_education*
replace mother_education_2010 = mother_education_2012 if mother_education_2010==""
replace father_education_2010 = father_education_2012 if father_education_2010==""
ren father_education_2010 father_education
ren mother_education_2010 mother_education

tostring age_finished_education*, replace
tostring birth_year*, replace

local varlist age_at_first_marriage age_exited_work age_finished_education age_started_work birth_year self_rated_health gender minzu
foreach var of local varlist {
    foreach yr in 2010 2012 2014 2016 2018 2020 2022 {
        replace `var'_`yr' = "" if `var'_`yr' == "."
    }
}

foreach var of local varlist {
    foreach yr in 2020 2018 2016 2014 2012 2010 {
    local next = `yr' + 2
    replace `var'_`yr' = `var'_`next' if `var'_`yr' == ""
    }
    rename `var'_2010 `var'
}

* religion
replace religion_2012 = religion_2014 if religion_2012 == "" & religion_2014 != ""
replace religion_2012 = religion_2016 if religion_2012 == "" & religion_2016 != ""
replace religion_2012 = religion_2018 if religion_2012 == "" & religion_2018 != ""
rename religion_2012 religion

* number of siblings
recode child_number_201*(6/100=6)
tostring child_number_2010, replace
replace child_number_2010 = "" if child_number_2010=="."
replace child_number_2010 = "6 or above" if child_number_2010=="6"
tostring child_number_2012, replace
replace child_number_2012 = "" if child_number_2012=="."
replace child_number_2012 = "6 or above" if child_number_2012=="6"

gen child_number = child_number_2010
replace child_number = child_number_2012 if child_number == ""
fre child_number

gen sib_number = .
foreach yr in 2022 2020 2018 2016 2014 {
    replace sib_number = sib_number_`yr' if missing(sib_number) & !missing(sib_number_`yr')
}
fre sib_number
recode sib_number(6/9=6)
tostring sib_number, replace
replace sib_number = "6 or above" if sib_number == "6"
replace sib_number = "" if sib_number == "."
fre sib_number*

foreach var in ever_married ever_divorced {
    gen `var' = ""
    foreach yr in 2022 2020 2018 2016 2014 2012 2010 {
        replace `var' = `var'_`yr' if (`var' == "" | `var' == ".") & ///
            (`var'_`yr' != "" & `var'_`yr' != ".")
    }
    label var `var' "`var' (latest available status, 2010–2022)"
}

* mean score
local varlist comprehension expression fixed_mindset gender_role growth_mindset interpersonal_skills math_cognitive self_control self_rated_depression verbal_cognitive
foreach var of local varlist {
    unab allvars : `var'_*
    egen `var' = rowmean(`allvars')
}

* highest_education
g highest_education = ""
foreach yr in 2022 2020 2018 2016 2014 2012 2010 {
    replace highest_education = education_`yr' if missing(highest_education) & !missing(education_`yr')
}
fre highest_education

* first_occupation
g first_occupation = ""
foreach yr in 2010 2012 2014 2016 2018 2020 2022 {
    replace first_occupation = occupation_`yr' if missing(first_occupation) & !missing(occupation_`yr')
}
replace first_occupation = "unemployed" if first_occupation == "Unemployed"
fre first_occupation

**# 2. sequential
destring birth_year, replace
g age = 2010 - birth_year
fre age
drop if age == .
drop if age<0

keep pid education_* employment_* income_* occupation_* marital_status_* child_number_* age age_at_death age_at_first_child age_at_first_divorce age_at_first_marriage age_exited_work age_finished_education age_started_work birth_year child_number comprehension ever_divorced ever_married expression fixed_mindset gender gender_role growth_mindset interpersonal_skills math_cognitive minzu self_control self_rated_depression self_rated_health sib_number verbal_cognitive religion mother_education father_education highest_education first_occupation
save working_data, replace

keep pid education_* employment_* income_* occupation_* child_number_2010 child_number_2012 marital_status_* age
forvalues i = 2010(2)2022 {
	replace occupation_`i' = "unemployed" if occupation_`i' == "Unemployed"
}

reshape long education_ employment_ income_ occupation_ child_number_ marital_status_, i(pid) j(year)
gen age_year = age + (year - 2010)
drop year 
drop age
sort pid age_year
reshape wide education_ employment_ income_ occupation_ child_number_ marital_status_, i(pid) j(age_year)
ren child_number* children_number*
merge 1:1 pid using working_data
drop _merge

drop education_201* education_202* occupation_201* occupation_202* income_201* income_202* employment_201* employment_202* marital_status_201* marital_status_202* child_number_2010 child_number_2012

* mean_income_30_40
egen mean_income_30_40 = rowmean(income_30 income_31 income_32 income_33 income_34 income_35 income_36 income_37 income_38 income_39 income_40)
fre mean_income_30_40

* occupation_30_40
preserve
keep pid occupation_30 occupation_31 occupation_32 occupation_33 occupation_34 occupation_35 occupation_36 occupation_37 occupation_38 occupation_39 occupation_40
reshape long occupation_, i(pid) j(year)
drop if occupation_ == ""
contract pid occupation_, freq(freq)
bysort pid (freq): keep if _n == _N
tempfile mode_occ
save `mode_occ'
restore
merge m:1 pid using `mode_occ', keepus(occupation_)
rename occupation_ occupation_30_40 
fre occupation_30_40

replace age_at_death = "still alive" if age_at_death=="."
drop age
drop _merge
save cfps_2010_2022, replace
export delimited using cfps_2010_2022, replace
