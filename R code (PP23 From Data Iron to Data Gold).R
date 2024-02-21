#installing remotes package
install.packages("remotes")


#installing FeatureExtraction and PatientLevelPrediction packages
remotes::install_github("OHDSI/FeatureExtraction")
remotes::install_github("OHDSI/PatientLevelPrediction")


#loading required packages
library(FeatureExtraction)
library(PatientLevelPrediction)


#connecting to PostgreSQL, defining the database containing the raw data tables, the cohort table, and the version of OMOP CDM being used
connectionDetails <- createConnectionDetails(server="localhost/postgres", port=5433, dbms="postgresql", user="postgres", password="PGSpwd", pathToDriver ="c:/temp/jdbcDrivers")
cdmDatabaseSchema <- "public"
cohortsDatabaseSchema <- "results"
cdmVersion <- "5"


#creating covariates using a function of 'FeatureExtraction' package
covariateSettings <- createCovariateSettings(useDemographicsGender = TRUE, useDemographicsAge = TRUE, useDemographicsRace = TRUE)


#defining database details i.e conncection details, where CDM data, target and outcome cohorts are stored and what the version of CDM used is
databaseDetails <- createDatabaseDetails(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseName = 'CMS',
  cohortDatabaseSchema = cohortsDatabaseSchema,
  cohortTable = 'dmcohorts',
  targetId = 1,
  outcomeDatabaseSchema = cohortsDatabaseSchema,
  outcomeTable = 'dmcohorts',
  outcomeIds = 2,
  cdmVersion = 5
)


#defining any additional restrictions and creating plpData object. getPlpData function will extract all the data defined 
restrictPlpDataSettings <- createRestrictPlpDataSettings(sampleSize = NULL)

plpData <- getPlpData(
  databaseDetails = databaseDetails,
  covariateSettings = covariateSettings,
  restrictPlpDataSettings = restrictPlpDataSettings
)


#saving plp data
savePlpData(plpData, 'ca_in_dm_data')


#defining additional inclusion criteria
populationSettings <- createStudyPopulationSettings(
  removeSubjectsWithPriorOutcome = TRUE,
  priorOutcomeLookback = 730,
  riskWindowStart = 1,
  riskWindowEnd = 730,
  minTimeAtRisk = 729,
  includeAllOutcomes = TRUE
)


#splitting data into training and test datasets
splitSettings <- createDefaultSplitSetting(
  testFraction = 0.2,
  trainFraction = 0.8,
  splitSeed = 23,
  nfold = 10,
  type = "stratified"
)


#defining sample and feature engineering settings. Default settings were used for this study
sampleSettings <- createSampleSettings()
featureEngineeringSettings <- createFeatureEngineeringSettings()


# defining preprocessing settings
preprocessSettings <- createPreprocessSettings(
  minFraction = 0.01,
  normalize = TRUE,
  removeRedundancy = TRUE
)


#creating settings for a LASSO Logistic regression model. Default settings were used for this study
lrModel <- setLassoLogisticRegression()


#running Patient level prediction and saving it in 'lrResults' object
lrResults <- runPlp(
  plpData = plpData,
  outcomeId = 2,
  analysisId = 'PP23',
  analysisName = 'CA in DM from CMS synthetic data',
  populationSettings = populationSettings,
  splitSettings = splitSettings,
  sampleSettings = sampleSettings,
  featureEngineeringSettings = featureEngineeringSettings,
  preprocessSettings = preprocessSettings,
  modelSettings = lrModel,
  logSettings = createLogSettings(),
  executeSettings = createExecuteSettings(
    runSplitData = T,
    runSampleData = T,
    runfeatureEngineering = T,
    runPreprocessData = T,
    runModelDevelopment = T,
    runCovariateSummary = T
  ),
  saveDirectory = file.path(getwd(), 'pp23')
)


#saving model
savePlpModel(lrResults$model, dirPath = file.path(getwd(), "model"))


#saving full results structure
savePlpResult(lrResults, file.path(getwd(), "lr"))


#viewing prediction details including 'value' column, which is predicted risk of outcome
View(lrResults$prediction)


#viewing results in a Shiny app
viewPlp(lrResults)
