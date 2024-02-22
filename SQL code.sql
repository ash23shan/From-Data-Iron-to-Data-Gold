INSERT INTO results.dmcohorts (cohort_definition_id,
							subject_id,
							cohort_start_date,
							cohort_end_date)							
SELECT 1 AS cohort_definition_id,
DM.person_id AS subject_id,
DM.condition_start_date AS cohort_start_date,
observation_period.observation_period_end_date AS cohort_end_date
FROM
(
	SELECT person_id, MIN(condition_start_date) AS condition_start_date
	FROM public.condition_occurrence
	WHERE condition_concept_id= 201826 /* Type 2 diabetes mellitus */
	GROUP BY person_id
) DM
INNER JOIN public.observation_period
ON DM.person_id= observation_period.person_id
AND DM.condition_start_date >= observation_period.observation_period_start_date
AND DM.condition_start_date <= observation_period.observation_period_end_date;


INSERT INTO results.dmcohorts (cohort_definition_id,
							subject_id,
							cohort_start_date,
							cohort_end_date)							
SELECT 2 AS cohort_definition_id,
CA.person_id AS subject_id,
CA.condition_start_date AS cohort_start_date,
observation_period.observation_period_end_date AS cohort_end_date
FROM
(
	SELECT person_id, MIN(condition_start_date) AS condition_start_date
	FROM public.condition_occurrence
	WHERE condition_concept_id= 42872402 /* Coronary arteriosclerosis in native artery */
	GROUP BY person_id
) CA
INNER JOIN public.observation_period
ON CA.person_id= observation_period.person_id
AND CA.condition_start_date >= observation_period.observation_period_start_date
AND CA.condition_start_date <= observation_period.observation_period_end_date;



