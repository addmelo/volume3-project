/*
Examine and merge datasets together for Volume 3 Data Project

Samuel McIntyre
November 2023

*/

cd "C:\Users\spm42\Box\ACME\Data Project"


*****ACT DATA********
import delimited using "ACT_Data 2021.csv", clear
drop percentwith schoolyear
ren avgcomposite act21
ren avgenglish english21
ren avgmath math21
ren avgscience science21
ren avgreading reading21

drop districtid lea leanumber schoolnumber 
save act_2021.dta, replace

import delimited using "ACT_Data 2022.csv", clear
drop percentwith schoolyear
ren avgcomposite act22
ren avgenglish english22
ren avgmath math22
ren avgscience science22
ren avgreading reading22

save act_2022.dta, replace


*Merge the ACT tables together
merge 1:1 school using act_2021.dta, keepusing(act21 english21 math21 science21 reading21)
tab school if _merge==2 | _merge==1 //Probably safe to just keep the matching ones
keep if _merge == 3
drop _merge

save act_merged.dta, replace


******Attendance Data**********
import delimited using "Attendance_Cleaned.csv", clear
drop v1 v36 v37
ren schoolname school

merge 1:1 school using act_merged.dta, keepusing(act21 english21 math21 science21 reading21 act22 english22 math22 science22 reading22)
tab school if _merge==2 | _merge==1
keep if _merge == 3  //We lose a few that were likely matching, but most were not
drop _merge
save act_attendance_merged.dta, replace


*******Demographics Data**********
import delimited using "EnrollmentDemographics_Cleaned.csv", clear
ren schoolname school
drop v1 leatype leaname

*Break up into multiple years and merge
forvalues y = 2021/2023{
	preserve
	keep if schoolyear == `y'
	duplicates drop school, force
	foreach var in totalk12 grade_9 grade_10 grade_11 grade_12 female male americanindian afamblack asian hispanic multiplerace pacificislander white economicallydisadvantaged englishlearner studentwithadisability homeless {
		ren `var' `var'_`y'
	}
	save demographics_`y'.dta, replace
	restore
}

use demographics_2021, clear
merge 1:1 school using demographics_2022, keep(3) nogen
merge 1:1 school using demographics_2023, keep(3) nogen
save demographics_to_merge.dta, replace


use act_attendance_merged.dta, clear
merge 1:1 school using demographics_to_merge.dta, keep(3) nogen

save act_attendance_demographics_clean.dta, replace




***Trimmed Dataset***
use act_attendance_demographics_clean.dta, clear
foreach var in totalk12 grade_9 grade_10 grade_11 grade_12 female male americanindian afamblack asian hispanic multiplerace pacificislander white economicallydisadvantaged englishlearner studentwithadisability homeless {
	drop `var'_2021
	drop `var'_2023
}
drop grade9attendance2021 grade10attendance2021 grade11attendance2021 grade12attendance2021
drop grade9attendance2022 grade10attendance2022 grade11attendance2022 grade12attendance2022
ren overallattendance2021 attendance21
ren overallattendance2022 attendance22

drop afamblackattendance2021 americanindianattendance2021 asianattendance2021 hispaniclatinoattendance2021 multipleraceattendance2021 pacificislanderattendance2021 whiteattendance2021 femaleattendance2021 maleattendance2021 studentwithadisabilityattendance economicallydisadvantagedattenda englishlearnerattendance2021 afamblackattendance2022 americanindianattendance2022 asianattendance2022 hispaniclatinoattendance2022 multipleraceattendance2022 pacificislanderattendance2022 whiteattendance2022 femaleattendance2022 maleattendance2022 englishlearnerattendance2022 homelessattendance2022 homelessattendance2021

drop schoolyear compositeschoolid



foreach var in female_2022 male_2022 americanindian_2022 afamblack_2022 asian_2022 hispanic_2022 multiplerace_2022 pacificislander_2022 white_2022 economicallydisadvantaged_2022 englishlearner_2022 studentwithadisability_2022 homeless_2022 {
	gen `var'_p = `var' / totalk12_2022
}


drop female_2022 male_2022 americanindian_2022 afamblack_2022 asian_2022 hispanic_2022 multiplerace_2022 pacificislander_2022 white_2022 economicallydisadvantaged_2022 englishlearner_2022 studentwithadisability_2022 homeless_2022



order school act21 act22 english21 english22 math21 math22 reading21 reading22 science21 science22 attendance21 attendance22 


export delimited "trimmed_data.csv", replace





***************************
		*New Data
***************************

import delimited using "Gradrates.csv", clear
ren schoolname school
merge 1:1 school using act_attendance_demographics_clean.dta, nogen keep(3)

foreach var in totalk12 grade_9 grade_10 grade_11 grade_12 female male americanindian afamblack asian hispanic multiplerace pacificislander white economicallydisadvantaged englishlearner studentwithadisability homeless {
	drop `var'_2021
	drop `var'_2023
}
drop grade9attendance2021 grade10attendance2021 grade11attendance2021 grade12attendance2021
drop grade9attendance2022 grade10attendance2022 grade11attendance2022 grade12attendance2022
ren overallattendance2021 attendance21
ren overallattendance2022 attendance22

drop afamblackattendance2021 americanindianattendance2021 asianattendance2021 hispaniclatinoattendance2021 multipleraceattendance2021 pacificislanderattendance2021 whiteattendance2021 femaleattendance2021 maleattendance2021 studentwithadisabilityattendance economicallydisadvantagedattenda englishlearnerattendance2021 afamblackattendance2022 americanindianattendance2022 asianattendance2022 hispaniclatinoattendance2022 multipleraceattendance2022 pacificislanderattendance2022 whiteattendance2022 femaleattendance2022 maleattendance2022 englishlearnerattendance2022 homelessattendance2022 homelessattendance2021

drop schoolyear compositeschoolid



foreach var in female_2022 male_2022 americanindian_2022 afamblack_2022 asian_2022 hispanic_2022 multiplerace_2022 pacificislander_2022 white_2022 economicallydisadvantaged_2022 englishlearner_2022 studentwithadisability_2022 homeless_2022 {
	gen `var'_p = `var' / totalk12_2022
}

*Make some new variables
gen attendance_2022_minority_p = americanindian_2022_p + afamblack_2022_p + asian_2022_p + hispanic_2022_p + multiplerace_2022_p + pacificislander_2022_p
gen students_11_12 = grade_11 + grade_12
gen log_students = ln(students_11_12)

gen charter = leatype == "Charter"
gen district = leatype == "District"

*tabulate leaname, gen(d)
*District one hot no good - to many with only one school

drop female_2022 male_2022 americanindian_2022 afamblack_2022 asian_2022 hispanic_2022 multiplerace_2022 pacificislander_2022 white_2022 economicallydisadvantaged_2022 englishlearner_2022 studentwithadisability_2022 homeless_2022 v1

order school leatype leaname gradrate act21 act22 english21 english22 math21 math22 reading21 reading22 science21 science22 log_students students_11_12 attendance21 attendance22 attendance_2022_minority_p americanindian_2022_p afamblack_2022_p asian_2022_p hispanic_2022_p multiplerace_2022_p pacificislander_2022_p

save cleaned_all.dta, replace
export delimited using "trimmed_all.csv", replace



******************************
		*More Data
******************************

import delimited using "2022MedianClassSize_clean.csv", clear
drop localeducationagency composite districtid schoolyear leatype
merge 1:1 school using cleaned_all.dta, nogen keep(3)



import delimited using "Teacher_Admin_Salaries.csv", clear
drop v1 leateacher leatype
ren localeducation leaname
merge 1:m leaname using cleaned_all.dta, keep(3) nogen

*Rename all variables

rename meanschooladministratorsalaryind admin_sal
ren administratortoteachermeansalary admin_to_teacher
ren meanteachersalaryindollars teacher_sal
ren attendance_2022_minority_p minority
ren americanindian_2022_p american_indian
ren afamblack_2022_p black
ren asian_2022_p asian
ren hispanic_2022_p hispanic
ren multiplerace_2022_p multiple_race
ren pacificislander_2022_p pacific_islander
ren totalk12_2022 totalk12
ren  grade_9_2022 grade9
ren grade_10_2022 grade10
ren grade_11_2022 grade11
ren grade_12_2022 grade12
ren female_2022_p female
ren male_2022_p male
ren white_2022_p white
ren economicallydisadvantaged_2022_p disadvantaged
ren englishlearner_2022_p english_learner
ren studentwithadisability_2022_p disability
ren homeless_2022_p homeless

save cleaned_with_salaries.dta, replace
export delimited using "cleaned_with_salaries.csv", replace