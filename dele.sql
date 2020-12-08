
DECLARE @start date
DECLARE @end   date
set @start = '2020/01/01'
set @end   = '2020/12/04'

select COUNT(DISTINCT e.encounterid) AS 'vision visit count', COUNT(DISTINCT p.controlno) AS 'vision patient count'
from enc e
    left join patients p on e.patientID=p.pid
    left join users u on p.pid=u.uid
    left join doctors d on e.doctorid=d.doctorID
where e.STATUS = 'chk'
    and u.ulname <> 'test'
    and e.VisitType like 'eye%'
    and e.deleteflag <> 1
    and e.date between @start and @end 

/*
and ( e.visittype in ('adult-fu','adult-new','adult-pe','adult-urg',
'deaf-fu','deaf-new',
'gyn-fu','gyn-new','gyn-urg',
'MAT',
'ped-prenat','peds-fu','peds-pe','peds-urg','rcm-off',
'MED-AUDIO',
'MAT-AUDIO')
or e.visittype like 'BH%'
or e.visittype like 'EYE%'
or e.visittype like 'MAT%'
or e.visittype like 'EXCH%'
or e.visittype like 'DEN%'
)
*/