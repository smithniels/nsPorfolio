if object_id ('tempdb..#temptable1') is not null drop table #temptable1
if object_id ('tempdb..#temptable2') is not null drop table #temptable2
if object_id ('tempdb..#temptable3') is not null drop table #temptable3
if object_id ('tempdb..#temptable4') is not null drop table #temptable4
if object_id ('tempdb..#temptable5') is not null drop table #temptable5
if object_id ('tempdb..#temptable6') is	not null drop table #temptable6
if object_id ('tempdb..#temptable7') is not null drop table #temptable7
if object_id ('tempdb..#temptableA') is not null drop table #temptableA
if object_id ('tempdb..#temptableB') is not null drop table #temptableB

-- 9/12 to 9/18
-- 9/19 to 9/25
-- 9/26 to 10/02   <<-- mon Oct 5, 2020
-- 10/03 to 10/9   <<-- tue oct 13, 2020
-- 10/10 to 10/16  <--- mon oct 19, 2020

DECLARE @startdate date
DECLARE @enddate   date
SET @STARTDATE = '2020-10-10'
SET @enddate   = '2020-10-16'
select @startdate  as 'From', @enddate as 'To'

--STEP 1
-------------------------------------------------------------------------------------------------------------
--pull Covid tests sent to LabCorp since January 1, 2020
--if pt has multiple tests, they will appear in multiple rows
--some tests will not have results yet
select
    p.controlno,
    p.pid,
    u.uFname,
    u.uLname,
    u.dob,
    u.sex,
    convert(date,e.date) as date,
    e.encounterid,
    case when e.visittype='covid' 
		then 'covid_visit_type' 
			else 'other_visit_type'	
				end as visit_type,
    d.printName,
    ld.result,
    convert(date,ld.resultdate) as resultdate,
    ldd.value,
    case when ldd.value='Detected' 
		then 1 
			else 0
				end as detected
into #temptable1
from patients p, users u, enc e, doctors d, items i, labdata ld
    left join labdatadetail ldd on ld.reportid=ldd.reportid
where p.pid=u.uid
    and u.uid=e.patientid
    and e.doctorid=d.doctorid
    and e.encounterid=ld.encounterid
    and ld.itemid=i.itemid
    and ld.deleteflag='0'
    and i.itemname like '%SARS-CoV-2, NAA'
    and u.ulname<>'Test'
    and u.ufname<>'templates'
    and ld.reason <>''
--3412
--pull race and ethnicity for pts in Step 1. Will have multiple rows for pts w more than one race
select distinct t1.controlno, t1.ufname, t1.ulname, ro.name as race, et.name as ethnicity, 1 as count
into #temptable2
from #temptable1 t1
    left join patients p on t1.pid=p.pid
    left join raceothers ro on t1.pid=ro.pid
    left join ethnicity et on p.ethnicity=et.code

--identify pts with more than one row from above
select controlno, sum(count) as count
into #temptable3
from #temptable2
group by controlno

--join the count of how many race rows the pt has into table with all tests
select t1.*, t3.count
into #temptable4
from #temptable1 t1, #temptable3 t3
where t1.controlno=t3.controlno

--for all rows in #temptable1 bring in the pt's race and ethnicity
--if the pt has more than 1 race make race 'More than 1 race'
--add the row number for the various races
--combine the 2 ways Black/African American in recorded
--this (#temptable5) is now the list of all tests ever peformed with pt race and ethnicity

select distinct t4.controlno, t4.ufname, t4.ulname, t4.dob, t4.sex, t4.date, t4.encounterid, t4.visit_type, t4.printname, t4.result, t4.resultdate, t4.value, t4.detected,
    case when (t2.ethnicity is null or t2.ethnicity='' or t2.ethnicity='Declined to specify') then 'Unreported Ethnicity' else t2.ethnicity end as ethnicity,
    case 
  	when t4.count=2 then 'f - More than one race' 
  	when t2.race = 'Asian' then 'a - Asian' 
	when t2.race like '%Hawaiian%' then 'b1 - Native Hawaiian'
	when t2.race like '%Pacific%' then 'b2 - Other Pacific Islander'
	when (t2.race='Black or African American'
        or t2.race='Black/ African American'
        or t2.race='Black/African American') 
			then 'c - Black / African American' 
	when t2.race like 'American%' then 'd - American Indian/Alaskan Native'
	when t2.race = 'White' then 'e - White'
	when (t2.race is null
        or t2.race=''
        or t2.race='Declined to specify') 
			then 'g - Unreported'
  else t2.race end as race
into #temptable5
from #temptable4 t4, #temptable3 t3, #temptable2 t2
where t4.controlno=t3.controlno
    and t3.controlno=t2.controlno

--this counts unique pts tested since Jan 1 (pts with more than 1 test counted only once)
select count(distinct t5.controlno) as num_PTS_tested_to_date
from #temptable5 t5

--this counts unique pts tested POSITIVE since Jan 1 (pts with more than 1 positive test counted only once)
select count(distinct t5.controlno) as num_PTS_with_pos_test_to_date
from #temptable5 t5
where t5.value='Detected'

--this counts all tests since Jan 1
select count(distinct t5.encounterid) as num_TESTS_to_date
from #temptable5 t5

--this counts positive tests since Jan 1
select count(distinct t5.encounterid) as num_pos_TESTS_to_date
from #temptable5 t5
where (t5.value like 'detected')

--this counts covid tests and positives from covid visits
select 'test stats by visit type for tests w results' as title
select visit_type, sum(detected) as num_positive,
    count(value) as num_tests,
    concat(floor(round(Sum(detected)*100.0/count(value),0 )),'%') as pct_pos
from #temptable5
where resultdate is not null
group by visit_type

/**/
--this counts test in reporting period (test order date is in period)
select count(t5.controlno) as num_tests_in_REPORTING_PD
from #temptable5 t5
where date between @startdate and @enddate
/**/

--this counts pts tested in reporting period (test order date is in period)
select count(distinct t5.controlno) as num_PTS_tested_in_REPORTING_PD
from #temptable5 t5
where date between @startdate and @enddate


--this counts  positive tests with RESULT date in reporting period
select count(t5.controlno) as num_pos_tests_in_REPORTING_PD
from #temptable5 t5
--note that positive results are based on **resultdate** not date
where t5.resultdate between @startdate and @enddate
    and value='Detected'


--this counts  pts w positive tests with RESULT date in reporting period
select count(distinct t5.controlno) as num_PTS_with_pos_test_in_REPORTING_PD
from #temptable5 t5
--note that positive results are based on **resultdate** not date
where t5.resultdate between @startdate and @enddate
    and value='Detected'

--this counts patients TESTED in period by ethnicity and race
select 'HISPANIC/LATINO Pts TESTED in reporting pd by race' as title
--this categorizes Hispanic/Latino pts tested in past week by race
select count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Hispanic or Latino'
    and t5.date between @startdate and @enddate
--group by t5.race
--order by race


--THIS counts TESTs in period by ethnicity and race
select '# of HISPANIC/LATINO  tests completed in reporting pd by race' as title
--this categorizes Hispanic/Latino pts tested in past week by race
select count( t5.encounterID) as num_tests
from #temptable5 t5
where t5.ethnicity='Hispanic or Latino'
    and t5.date between @startdate and @enddate
--group by t5.race
-- order by race


select 'NON-HISPANIC/LATINO Pts TESTED in reporting pd by race' as title
--this categorizes Hispanic/Latino pts tested in past week by race
select t5.race, count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Not Hispanic or Latino'
    and t5.date between @startdate and @enddate
group by t5.race
order by race

select 'UNREPORTED ETHNICITY Pts TESTED in reporting pd' as title
--this categorizes unreported ethnicity pts tested in past week by race
select count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='unreported ethnicity'
    and t5.date between @startdate and @enddate

--this counts patients with positive test and RESULT DATE in period by ethnicity and race

select 'HISPANIC/LATINO Pts with POSITIVE test in reporting pd by race' as title
--this categorizes Hispanic/Latino pts tested in past week by race
select t5.race, count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Hispanic or Latino'
    and t5.resultdate between @startdate and @enddate
    and t5.value='Detected'
group by t5.race
order by race

select 'NON-HISPANIC/LATINO Pts with POSITIVE test in reporting pd by race' as title
--this categorizes Hispanic/Latino pts tested in past week by race
select t5.race, count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Not Hispanic or Latino'
    and t5.resultdate between @startdate and @enddate
    and t5.value='Detected'
group by t5.race
order by race

select 'UNREPORTED ETHNICITY Pts with POSITIVE test in reporting pd' as title
--this categorizes unreported ethnicity pts tested in past week by race
select count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='unreported ethnicity'
    and t5.resultdate between @startdate and @enddate
    and t5.value='Detected'




--STEP 2 "count all visits in reporting period"
-----------------------------------------------------------------------
--pull all visits in reporting period, including BH, dental, vision, 
--AND the new telemedicine medical visits, audio and video
select distinct e.encounterid, 1 as counter,
    case when e.visittype in ( 'MED-TV',  'MED-AUDIO',  'BHC-AUdIO', 'BHC-tv', 'den-audio','den-tv','eye-audio','eye-tv','Mat-Audio' ) then 1 else 0 end as televisit_counter
into #temptable6
from enc e, patients p, users u
where u.uid = p.pid
    and e.patientid = p.pid
    and e.visittype in  ('adult-fu','adult-new','adult-pe','adult-urg', 'BHC-NEW', 'BHC-FU', 'BH-Therapy', 
'deaf-fu', 'deaf-new', 'ped-prenat', 'peds-fu', 'peds-pe', 'peds-urg', 'rcm-off',
'DEN-FU', 'DEN-NEW', 'DEN-PO', 'DEN-RCT', 'DEN-REC','EYE-NEW', 'eye-FU','mat',
 'MED-TV',
 'MED-Audio',
 'BHC-AUDIO',
 'BHC-TV',
 'den-audio',
 'den-tv',
 'eye-audio',
 'eye-tv','MAT-Audio'
 )
    and e.date between @startdate and @enddate
    and e.status = 'CHK'
    and u.ulname <> 'test'
    and u.ufname<>'Templates'
    and e.deleteflag <> 1

select sum(televisit_counter) as televisits_in_period,
    sum(counter) as number_of_visits_in_reporting_period,
    concat(floor(round((sum(televisit_counter)*100.0)/sum(counter),0)),'%') as percentage_televist
from #temptable6


select p.pid, e.encounterid, e.visittype, e.date
into #temptable7
from enc e, patients p, users u
where u.uid = p.pid
    and e.patientid = p.pid
    and e.visittype in  ('adult-fu','adult-new','adult-pe','adult-urg', 'BHC-NEW', 'BHC-FU', 'BH-Therapy', 
'deaf-fu', 'deaf-new', 'ped-prenat', 'peds-fu', 'peds-pe', 'peds-urg', 'rcm-off',
'DEN-FU', 'DEN-NEW', 'DEN-PO', 'DEN-RCT', 'DEN-REC','EYE-NEW', 'eye-FU','mat', 'gps-tel',
 'MED-TV',
 'MED-Audio',
 'BHC-AUDIO',
 'BHC-TV',
 'den-audio',
 'den-tv',
 'eye-audio',
 'eye-tv','MAT-Audio'
 )
    and e.date between @startdate and @enddate
    and e.status = 'CHK'
    and u.ulname <> 'test'
    and u.ufname<>'Templates'
    and e.deleteflag <> 1


select count(distinct t7.pid ) num_unique_Pts_in_reporting_period
from #temptable7 t7

select count( t7.encounterid) num_unique_BH_Tel_Visits_in_reporting_period
from #temptable7 t7
where t7.visittype = 'BHC-AUDIO'

select count( t7.encounterid) num_unique_GPS_Visits_in_reporting_period
from #temptable7 t7
where t7.visittype = 'GPS-Tel'




if object_id ('tempdb..#temptable1') is not null drop table #temptable1
if object_id ('tempdb..#temptable2') is not null drop table #temptable2
if object_id ('tempdb..#temptable3') is not null drop table #temptable3
if object_id ('tempdb..#temptable4') is not null drop table #temptable4
if object_id ('tempdb..#temptable5') is not null drop table #temptable5
if object_id ('tempdb..#temptable6') is not null drop table #temptable6
if object_id ('tempdb..#temptableA') is not null drop table #temptableA
if object_id ('te555555555mpdb..#temptableB') is not null drop table #temptableB
-- 9/12 to 9/18
-- 9/19 to 9/25
-- 9/26 to 10/02   <<-- mon Oct 5, 2020
-- 10/03 to 10/9   <<-- tue oct 13, 2020
-- 10/10 to 10/16  <--- mon oct 19, 2020

DECLARE @startdate date
DECLARE @enddate   date
SET @STARTDATE = '2020-10-10'
set @enddate   = '2020-10-16'
select @startdate  as 'From', @enddate as 'To'


--STEP 1
-------------------------------------------------------------------------------------------------------------
--pull Covid tests sent to LabCorp since January 1, 2020
--if patient has multiple tests, they will appear in multiple rows
--some tests will not have results yet
select
    p.controlno,
    p.pid,
    u.uFname,
    u.uLname,
    u.dob,
    u.sex,
    convert(date,e.date) as date,
    e.encounterid,
    case when e.visittype='covid' 
		then 'covid_visit_type' 
			else 'other_visit_type'	
				end as visit_type,
    d.printName,
    ld.result,
    convert(date,ld.resultdate) as resultdate,
    ldd.value,
    case when ldd.value='Detected' 
		then 1 
			else 0
				end as detected 
, i.itemname
into #temptable1
from patients p, users u, enc e, doctors d, items i, labdata ld
    left join labdatadetail ldd on ld.reportid=ldd.reportid
where p.pid=u.uid
    and u.uid=e.patientid
    and e.doctorid=d.doctorid
    and e.encounterid=ld.encounterid
    and ld.itemid=i.itemid
    and ld.deleteflag='0' -- Someone added L- to the testname in Sept, so I'm just switching to like %% to fix. TBH I probably should've been doing that from jump. /shrugemoji. Commented out code below is the old code:

    and i.itemname like  '%SARS-COV-2 Anti%'
    /*
  (
  --COVID Antibody Tests
  'SARS-COV-2 Antibody, IgA',
  'SARS-COV-2 Antibody, IgM',
  'SARS-COV-2 Antibody, IgG'--,

  COVID-19 Test
  --'SARS-CoV-2, NAA'
  )
  */
    and u.ulname<>'Test'
    and u.ufname<>'templates'
    and ld.reason <>''

--pull race and ethnicity for pts in Step 1. Will have multiple rows for pts w more than one race
select distinct t1.controlno, t1.ufname, t1.ulname, ro.name as race, et.name as ethnicity, 1 as count
into #temptable2
from #temptable1 t1
    left join patients p on t1.pid=p.pid
    left join raceothers ro on t1.pid=ro.pid
    left join ethnicity et on p.ethnicity=et.code

--identify pts with more than one row from above
select controlno, sum(count) as count
into #temptable3
from #temptable2
group by controlno

--join the count of how many race rows the pt has into table with all tests
select t1.*, t3.count
into #temptable4
from #temptable1 t1, #temptable3 t3
where t1.controlno=t3.controlno

--for all rows in #temptable1 bring in the pt's race and ethnicity
--if the pt has more than 1 race make race 'More than 1 race'
--add the row number for the various races
--combine the 2 ways Black/African American in recorded
--this (#temptable5) is now the list of all tests ever peformed with pt race and ethnicity
select distinct t4.controlno, t4.ufname, t4.ulname, t4.dob, t4.sex, t4.date, t4.encounterid, t4.visit_type, t4.printname, t4.result, t4.resultdate, t4.value, t4.detected,
    case when (t2.ethnicity is null or t2.ethnicity='' or t2.ethnicity='Declined to specify') then 'Unreported Ethnicity' else t2.ethnicity end as ethnicity,
    case 
  	when t4.count=2 then 'f - More than one race' 
  	when t2.race = 'Asian' then 'a - Asian' 
	when t2.race like '%Hawaiian%' then 'b1 - Native Hawaiian'
	when t2.race like '%Pacific%' then 'b2 - Other Pacific Islander'
	when (t2.race='Black or African American'
        or t2.race='Black/ African American'
        or t2.race='Black/African American') 
			then 'c - Black / African American' 
	when t2.race like 'American%' then 'd - American Indian/Alaskan Native'
	when t2.race = 'White' then 'e - White'
	when (t2.race is null
        or t2.race=''
        or t2.race='Declined to specify') 
			then 'g - Unreported'
  else t2.race end as race
into #temptable5
from #temptable4 t4, #temptable3 t3, #temptable2 t2
where t4.controlno=t3.controlno
    and t3.controlno=t2.controlno

--this counts unique pts Antibody Tested since Jan 1 (pts with more than 1 test counted only once)
select count(distinct t5.controlno) as num_PTS_Antibody_tested_to_date
from #temptable5 t5

--this counts Antibody Test results since Jan 1 (pts with more than 1 test counted only once)
select count(t5.controlno) as num_Antibody_tests_to_date
from #temptable5 t5

/*  
--this counts unique pts Antibody Tested POSITIVE since Jan 1 (pts with more than 1 positive test counted only once)
 select count(distinct t5.controlno) as num_PTS_Antibody_with_pos_test_to_date
 from #temptable5 t5
 where t5.value='Detected'
 */
--this counts all tests since Jan 1
select count(distinct t5.encounterid) as num__Antibody_TESTS_to_date
from #temptable5 t5

--this counts covid tests and positives from covid visits
select 'test stats by visit type for tests w results' as title
select visit_type
 /*
 , sum(detected) as num_positive
 */,

    count(value) as num_tests,
    concat(floor(round(Sum(detected)*100.0/count(value),0 )),'%') as pct_pos
from #temptable5
where resultdate is not null
group by visit_type

--this counts the number of Antibody Tests results in reporting period (test order date is in period)
select count(distinct t5.controlno) as num_AntiBody_test_results_in_REPORTING_PD
from #temptable5 t5
where date between @startdate and @enddate

--1
--this counts pts Antibody Tested in reporting period (test order date is in period)
select count(distinct t5.controlno) as num_pts_AntiBody_tested_in_REPORTING_PD
from #temptable5 t5
where date between @startdate and @enddate

--2
-- this counts the number of patients with positive antibody tests results in reporting period
select count(distinct t5.controlno) as num_pos_antibody_test_in_REPORTING_PD
from #temptable5 t5
where date between @startdate and @enddate
    and result='positive'
--select * from #temptable5
--3
-- This counts the number patients with positive antibody tests results was postive in the reporting period
select count(distinct t5.controlno) as num_pts_with_pos_antibody_test_in_REPORTING_PD1
from #temptable5 t5
where date between @startdate and @enddate
    and result='positive'

--this counts patients Antibody TESTED in period by ethnicity and race
select 'HISPANIC/LATINO Pts AntiBody TESTED in reporting pd by race' as title
--this categorizes Hispanic/Latino pts Antibody tested in past week by race
select t5.race, count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Hispanic or Latino'
    and t5.date between @startdate and @enddate
group by t5.race
order by race

select 'NON-HISPANIC/LATINO Pts Antibody TESTED in reporting pd by race' as title
--this categorizes Hispanic/Latino pts Antibody Tested in past week by race
select t5.race, count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='Not Hispanic or Latino'
    and t5.date between @startdate and @enddate
group by t5.race
order by race

select 'UNREPORTED ETHNICITY pts Antibody Tested in reporting pd' as title
--this categorizes unreported ethnicity pts Antibody Tested in past week by race
select count(distinct t5.controlno) as num_pts
from #temptable5 t5
where t5.ethnicity='unreported ethnicity'
    and t5.date between @startdate and @enddate

--STEP 2 "count all visits in reporting period"
-----------------------------------------------------------------------
--pull all visits in reporting period, including BH, dental, vision, 
--AND the new telemedicine medical visits, audio and video
select distinct e.encounterid, 1 as counter,
    case when e.visittype in ( 'MED-TV',  'MED-AUDIO',  'BHC-AUdIO', 'BHC-tv', 'den-audio','den-tv','eye-audio','eye-tv' ) then 1 else 0 end as televisit_counter
into #temptable6
from enc e, patients p, users u
where u.uid = p.pid
    and e.patientid = p.pid
    and e.visittype in  ('adult-fu','adult-new','adult-pe','adult-urg', 'BHC-NEW', 'BHC-FU', 'BH-Therapy', 
'deaf-fu', 'deaf-new', 'ped-prenat', 'peds-fu', 'peds-pe', 'peds-urg', 'rcm-off',
'DEN-FU', 'DEN-NEW', 'DEN-PO', 'DEN-RCT', 'DEN-REC','EYE-NEW', 'eye-FU','mat',
 'MED-TV',
 'MED-Audio',
 'BHC-AUDIO',
 'BHC-TV',
 'den-audio',
 'den-tv',
 'eye-audio',
 'eye-tv'
 )
    and e.date between @startdate and @enddate
    and e.status = 'CHK'
    and u.ulname <> 'test'
    and u.ufname<>'Templates'
    and e.deleteflag <> 1
