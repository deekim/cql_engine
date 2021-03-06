library AppropriateTreatmentforUpperRespiratoryInfectionURI version '9.2.000'

using QDM version '5.5'

include MATGlobalCommonFunctions version '5.0.000' called Global
include Hospice version '2.2.000' called Hospice

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Antibiotic Medications for Pharyngitis": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1001'
valueset "Comorbid Conditions for Respiratory Conditions": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1025'
valueset "Competing Conditions for Respiratory Conditions": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1017'
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1010'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Hospital Observation Care - Initial": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1002'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1022'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Preventive Care, Established Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Telephone Visits": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1080'
valueset "Upper Respiratory Infection": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1022'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"]

define "SDE Race":
  ["Patient Characteristic Race": "Race"]

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Denominator":
  "Initial Population"

define "In Hospice":
  "Initial Population" InitialPopulation
    where Hospice."Has Hospice"

define "Encounter with Upper Respiratory Infection":
  from
    "Qualifying Encounter" QualifyingEncounter,
    ["Diagnosis": "Upper Respiratory Infection"] URI
    where URI.prevalencePeriod starts during QualifyingEncounter.relevantPeriod
      or URI.prevalencePeriod overlaps before QualifyingEncounter.relevantPeriod

define "Numerator":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    without ["Medication, Order": "Antibiotic Medications for Pharyngitis"] OrderedAntibiotic
      such that OrderedAntibiotic.authorDatetime 3 days or less on or after start of EncounterWithURI.QualifyingEncounter.relevantPeriod
    return EncounterWithURI.QualifyingEncounter

define "Encounter with Upper Respiratory Infection and Antibiotics Active 30 Days Prior":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    with ["Medication, Active": "Antibiotic Medications for Pharyngitis"] ActiveAntibiotic
      such that ActiveAntibiotic.relevantPeriod overlaps Interval[Global."ToDate" ( ( start of EncounterWithURI.URI.prevalencePeriod ) - 30 days ), start of EncounterWithURI.URI.prevalencePeriod]
    return EncounterWithURI.QualifyingEncounter

define "Initial Population":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInMonthsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 3
    return EncounterWithURI.QualifyingEncounter

define "Encounter with Competing Diagnosis for Upper Respiratory Infection":
  ( "Encounter with Upper Respiratory Infection" EncounterWithURI
      with ["Diagnosis": "Competing Conditions for Respiratory Conditions"] CompetingCondition
        such that CompetingCondition.prevalencePeriod starts 3 days or less on or after day of start of EncounterWithURI.QualifyingEncounter.relevantPeriod
      return EncounterWithURI.QualifyingEncounter
  )

define "Stratification 1":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInMonthsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 3
        and Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) <= 17
    return EncounterWithURI.QualifyingEncounter

define "Stratification 2":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[18, 64]
    return EncounterWithURI.QualifyingEncounter

define "Stratification 3":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 65
    return EncounterWithURI.QualifyingEncounter

define "Denominator Exclusions":
  "In Hospice"
    union "Encounter with Upper Respiratory Infection and Antibiotics Active 30 Days Prior"
    union "Encounter with Competing Diagnosis for Upper Respiratory Infection"
    union "Encounter with Comorbid Condition for Upper Respiratory Infection Prior"

define "Encounter with Comorbid Condition for Upper Respiratory Infection Prior":
  ( "Encounter with Upper Respiratory Infection" EncounterWithURI
      with ["Diagnosis": "Comorbid Conditions for Respiratory Conditions"] ComorbidCondition
        such that start of ComorbidCondition.prevalencePeriod in Interval[start of EncounterWithURI.URI.prevalencePeriod - 1 year, start of EncounterWithURI.URI.prevalencePeriod]
      return EncounterWithURI.QualifyingEncounter
  )

define "Qualifying Encounter":
  ( ["Encounter, Performed": "Office Visit"]
    union ["Encounter, Performed": "Emergency Department Visit"]
    union ["Encounter, Performed": "Preventive Care Services, Initial Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care, Established Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Hospital Observation Care - Initial"]
    union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Telephone Visits"]
    union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"] ) ValidEncounter
    where ValidEncounter.relevantPeriod during "Measurement Period"