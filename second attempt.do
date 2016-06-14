/* not using now

di "$start"
display "$S_TIME" 

*/

clear all
global start = "$S_TIME"
set more off
cd /Users/danielschwab/Dropbox/Dan_Mike_HS/IntermediateDTAs
global classes = `" "Druid" "Hunter" "Mage" "Paladin" "Priest" "Rogue" "Shaman" "Warlock" "Warrior" "'


// format day/time:
if 1==0 {
insheet using ../data/wog_games.csv, clear
egen dayTime = concat(date time)
gen double dt = clock(dayTime, "MDY hms") //one day apart -> dt is 86400000 apart
sum dt
replace dt = (dt - r(min))/86400000
sort dt
}

//make dummies for opponent class
if 1==0 {
foreach c in $classes {
	gen d_`c' = opponent == "`c'"
}
}

//figure out what's happened in the last 24 and 48 hours
if 1==0 {
foreach c in $classes {
	gen count01_`c' = 0 // number of class `c' observed between 0 -> 1 days
	gen count02_`c' = 0 // 0 -> 2 days
}
gen total01 = 0 // number of total opponents between 0 -> 1 days
gen total02 = 0
global N = _N
local n 1
while `n' < $N { // step through every game. If game n is against druid, increment every counter that is 24 (or 48) hours or less later
	global c = opponent[`n']
	global dt = dt[`n']
	replace count01_$c = count01_$c + 1 if $dt - dt < 1 & dt < $dt
	replace total01 = total01 + 1 if $dt - dt < 1 & dt < $dt
	replace count02_$c = count02_$c + 1 if $dt - dt < 2 & dt < $dt
	replace total02 = total02 + 1 if $dt - dt < 2 & dt < $dt
	local n = `n' + 1	
} 
save recent, replace
}

use recent, clear
keep if month == 5

//make predictions
if 1==1 { // 0->24, 24->48, 0->48 hours
gen total12 = total02 - total01 //24-48 hours
foreach c in $classes {
	replace count01_`c' = . if dt < 2 //don't have 48 hours of data
	replace count02_`c' = . if dt < 2
	gen count12_`c' = count02_`c' - count01_`c'
	gen p01_`c' = count01_`c' / total01
	gen p02_`c' = count02_`c' / total02
	gen p12_`c' = count12_`c' / total12
}
}			

//score predictions
if 1==1 {
gen score01 = 0
gen score02 = 0
gen score12 = 0
foreach c in $classes {	
	replace score01 = score01 + ln(p01_`c')*d_`c'
	replace score02 = score02 + ln(p02_`c')*d_`c'
	replace score12 = score12 + ln(p12_`c')*d_`c'
}

}

global scores = "score01 score02 score12"
global best = -1000000
foreach p in $scores {
qui	sum `p'
	global `p' = r(mean)
	if $`p' > $best {
		global best $`p'
		global bestPred "`p'"
	}
}
di _n
foreach p in $scores {
qui	sum `p'
	global `p' = r(mean)
	di "`p':  " `=$`p' - $best'
}

/*

So 0-24 hours beats 0-48 slightly and they both crush 24-48

score01:  0
score02:  -.00004734
score12:  -.00724639

*/

	
	


