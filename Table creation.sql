create database healthcare;
use healthcare;

CREATE Table Diagnoses
		(
		DiagnosesID int primary key,
		DiagnosesName varchar(255)
		);
        
CREATE TABLE Outcomes 
		(
		OutcomeID int primary key,
		OutcomeName varchar(255)
		);

CREATE TABLE Patients
		(
		PatientID int primary key,
		Name varchar(255),
		Age	int,
		Gender	char(1),
		DiagnosesID	int,
		AdmissionDate date,
		DischargeDate date,
		OutcomeID int,
		TreatmentCost decimal(10,2),
        Foreign Key (DiagnosesID) references Diagnoses(DiagnosesID),
		Foreign Key (OutcomeID) references Outcomes(OutcomeID)
		);

CREATE TABLE Labs
		(        
		LabID int primary key,	
		PatientID int,	
		TestName varchar(255),
		Result decimal(10,2),
		NormalRange varchar(255),
		foreign key (PatientID) references Patients(PatientID)
		);
        
SELECT * FROM Diagnoses;
SELECT * FROM Outcomes;
SELECT * FROM Patients;
SELECT * FROM Labs;

-- Retrieve Detailed Patient Lab History

SELECT p.PatientID,p.Name,d.DiagnosisName,o.OutcomeName,l.TestName,l.result,l.NormalRange
FROM patients p
join Diagnoses d on p.DiagnosisID = d.diagnosisID
join outcomes o on p.OutcomeID = o.OutcomeID
join labs l on p.PatientID=l.PatientID
order by p.PatientID,l.TestName;

-- Average Lab results by Diagnosis

SELECT d.diagnosisName,l.TestName,AVG(l.result) as Average_result 
FROM patients p
JOIN diagnoses d ON p.diagnosisID=d.diagnosisID
JOIN labs l ON p.PatientID=l.patientID
GROUP BY d.DiagnosisName,l.TestName;

-- Count of Abnormal Lab Results

SELECT p.patientID, p.name, count(*) as Abnormal_count 
FROM patients p 
JOIN labs l ON p.patientID = l.patientID
WHERE (l.TestName='Blood Pressure' AND l.Result < 150)
OR (l.TestName= 'Blood Sugar' AND l.Result>120)
OR (l.testname= 'Cholestrol' AND l.Result>200)
GROUP BY p.PatientID,p.Name
ORDER BY Abnormal_count DESC;


-- Diagnosis with the Highest Treatment Cost

SELECT p.DiagnosisID, d.diagnosisname ,AVG(p.treatmentcost) AS AvgTreatment_Cost
FROM patients p
JOIN diagnoses d ON p.DiagnosisID=d.DiagnosisID
GROUP BY d.DiagnosisID
ORDER BY AvgTreatment_Cost DESC;

-- Patients at risk by age and gender

SELECT p.PatientID,p.name,p.Age,d.diagnosisname,o.outcomename
FROM patients p
JOIN diagnoses d ON p.DiagnosisID=d.DiagnosisID
JOIN outcomes o ON p.OutcomeID=o.OutcomeID
WHERE p.age>65 and p.gender='M' and o.outcomename != 'Recovered' AND o.OutcomeName !='Deceased';

-- Lab trends over a time for specific patient

SELECT l.testname, l.result, p.admissiondate
FROM labs l
JOIN patients p ON l.PatientID=p.PatientID
WHERE p.PatientID='102'
ORDER BY p.AdmissionDate;

-- Distribution of outcomes by diagnoses 

SELECT d.diagnosisname, o.outcomename, count(*) AS OutcomeCount
FROM patients p
JOIN diagnoses d ON p.DiagnosisID=d.DiagnosisID
JOIN outcomes o ON p.OutcomeID=o.OutcomeID
GROUP BY d.DiagnosisName,o.OutcomeName
ORDER BY d.DiagnosisName,o.OutcomeName;

-- Rank of Treatment Costs

WITH DiagnosisCosts AS (
    SELECT 
        d.DiagnosisName, 
        p.TreatmentCost,
        AVG(p.TreatmentCost) OVER(PARTITION BY d.DiagnosisName) as AvgCostPerDiagnosis
    FROM Patients p
    JOIN Diagnoses d ON p.DiagnosisID = d.DiagnosisID
)
SELECT 
    DiagnosisName,
    TreatmentCost,
    AvgCostPerDiagnosis,
    RANK() OVER(ORDER BY AvgCostPerDiagnosis DESC) as CostRank
FROM DiagnosisCosts;

-- Cumulative Lab History

SELECT p.PatientID, l.TestName, l.Result, 
ROUND(AVG(Result) OVER(PARTITION BY PatientID, TestName ORDER BY AdmissionDate),2) as RunningAvgResult
FROM Labs l
JOIN Patients p ON l.PatientID = p.PatientID;
