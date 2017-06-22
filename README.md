## baby_connectivity
Baby connectivity is a collection of Matlab functions to be used to analyze connectivity of (baby) EEG data. All analyses are done using [Fieldtrip](https://github.com/fieldtrip/fieldtrip). 

### Core scripts (and run order)
**0a) createSubjectFolders.m**  
Only run once, creates individual subjectfolders in a 'Subjects' directory with the raw data for each subject  
**0b) makeSubjectFile.m**  
Only run once, creates a starting template of the Subject.mat file in each individual subject folder. Certain variables will be added to this Subject.mat file later in the analysis. Therefore, don't run more than once  
**1) removeChannels.m**  
First step, load in data (both notched filter and highpass 1Hz filtered) to check for bad channels that could influence the average rereferencing later on. This will start up an interactive process in which bad channels are rejected through the function ft_rejectvisual (method: 'summary'). Bad channels will be added to the individual Subject.mat file  
**2) preprocessFilterAndReref.m**  
Step 2, filters and average rereferences the data. Only the good channels (from step 1) will be added to this filtering + rereferencing step  
**2a) preprocessEOGChannels.m**  
Possible addon to step 2, preprocesses the EOG channels and adds them to the original data file  
**2b) interpolateChannels.m**  
Only necessary if interpolated PLI matrices are wanted (this is not recommended since it will create artificial correlations between channels)  
**3) preprocessICA.m**  
Run an ICA on the data  
**4) ICAComponentRemoval.m**  
starts and interactive process to remove bad components (blinks and muscle artifacts)  
**5) visualArtefactRemoval.m**  
all trial data will be cut into 2 second pieces and an interactive process will be started based on ft_rejectvisual (method: 'summary') in which you will be asked to remove bad channels based on several characteristics.   
**6) createPLIMatrices.m**  
results creating step. Creates PLIMatrices, based on cleaned data. Please add the type of data-analyses.   
* 'nanbadchannels' will add rows of NaNs for bad channels (recommended)
* 'interpolated' will used interpolated data  
* 'goodchannelspersubject' will only add the channels for each subject  that were good.  
* 'goodchannelspergroup' will only add the channels that were good for  the entire group  

### Support scripts
**findCorrectChannels.m**  
find the channels used for all subject and determines which channels contain data for each subject. This script is necessary for the _interpolateChannels.m_ script and the _createPLIMatrices.m_ script.  
**magnitudeResponse.m**  
Visualizes the frequency response for the given data file. Used in _visualizeData.m_  
**trialfun_gratings.m**  
Function necessary if data is cut into epochs in stead of analyzed continuously. Please change this function to fit your study variables  
**visualizeData.m**  
Visualizes data according to type of data  
**visualizeResults.m**  
Visualizes results according to type of results 

### Example run
#### Setup  
Put all raw-files in 'RAW' folder  
**1) run makeSubjectFolders.m**  
run _makeSubjectFolders.m_ from the parent directory of your RAW folder with the name of the raw-folder and the preferenced string that will be infront of each subjectnumber for each individual subject folder (default: 'pp'). Directory of all subjects will be named './Subjects'. Creates _subjectConversionCell.mat_ in the **admin** folder (will be created if not present), in which you will find the conversion of subject directory name (e.g. '_pp001_') to filename (e.g. '*KvDpp_42gratings.eeg*'). Use this conversionCell to create a condition '.csv' file in the admin folder with the subjectdir name in column one, condition in column two and orig-filename in column three.  
**2) run createSubjectFile.m**  
run _createSubjectFile.m_ with the before chosen subjectString (e.g. 'pp') and the name of the Subjects folder (e.g. 'Subjects'). This will create a _Subject.mat_ file for each subject and put it in the individual subject folder. The standard _Subject.mat_ file contains a struct 'subjectdata':
* a subjectdirectory name ('subjectdir') 
* the path to the subjectdirectory ('subjectpath')
* the name of the datafile ('datafile')
* the general filename ('filename')
* the subjectnumber ('subjectnr')
* the stm-file ('stm'), if no stm-file is found, subject is moved to removed folder
* the trial numbers of watched trials (from stm) ('watched')
* the trial numbers of not-watched trials (from stm) ('notwatched')
* the condition based on the .csv file in the admin folder (default: '_AutismData.csv_') 
 
saves a _subjectSummary.csv_ file with the subjectdirectory name, filename, condition and total amount of watched. Please add any subjectdata variables to this script to add them to your standard Subject.mat file  

#### Preprocessing
**3) run removeChannels.m**  
run _removeChannels.m_ with the subjectdirectory name (e.g. 'Subjects') and subjectString (e.g. 'pp'). Starts and interactive process based on the *ft_rejectvisual.m* GUI. Will add the channels to be removed to _Subject.mat_ file. This will be used in the next steps.  
**4) run preprocessFilterAndReref.m**  
run _preprocessFilterAndReref.m_ with as input variables a boolean for whether the data needs to be cut in epochs based on trial presentation (if turned on, please add your own type of trialfun_gratings to your subfunctions folder), the frequency range (default: [1 inf]), a boolean for whether the data needs to be rereferenced (default: 1 and average rereference) and a boolean for whether the data needs to be notched filtered (default: 1). Data will be notch filtered for all multiplicates of 50Hz under the nyquist frequency (please turn off in the script if using active electrodes). Data will be read in for each individual subject based on the subjectdata.removedchannel variable of each subject. Will output and save the preprocessed data file of *ft_preprocessing* with two extra variables: 
* data.preprocessOrder: preprocess steps taken so far
* data.filterused: frequency range of the data 

saves data file as *[subjectdirname]_filter[freqrange]+reref(if rerefbool=yes).mat*  
#### Remove artifacts
**5) _optional_: run preprocessEOGChannels.m**  
run _preprocessEOGChannels.m_. This is an optional step. Only run when EOG channels are present in dataset. This script will look for channel names with a variant of the 'EOG' string and will rereference the up electrode to the down electrode and the left electrode to the right electrode. The original channels will be removed from the dataset and the rereferenced EOG channels will be added (reduces the amount of EOG channels from 4 to 2). Give as input the previous data file. Saves the new data file as *[previousfilename]_eogchannels.mat* with an added entry to the data.preprocessOrder variable.  
**6) run preprocessICA.m**  
run _preprocessICA.m_. Will run an independent component analysis on the individual data. Needs as input the previous data and outputs and saves a component file as *[previousfilename]_ICA*.  
**7) run ICAComponentRemoval.m**  
run _ICAComponentRemoval.m_. Will run an interactive process. Showing for each subject the components the component timeline (through *ft_databrowser.m*) and component topoplot (through *ft_topoplotIC.m*). Asks the operator to indicate which components need to be removed. Try to remove blinks and muscle artifacts this way. The new data file without the bad components will be automatically saved as *[previousFileName]_compRemoved.mat*.   
**8) _optional_: run interpolate channels**  
run _interpolateChannels.m_. This is an optional step. Only run if the bad channels need to be interpolated. This is generally not recommended since it will induce a higher connectivity between channels in the data. The function requires as input the name of the subjectdirectory (e.g. 'Subjects') and a non-unique subject directory string ('pp'). Will save a datafile with interpolated channels called *[previousfilename]_interpolated.mat*.  
**9) run visualArtefactRemoval.m**  
run _visualArtefactRemoval.m_. Will run an interactive process cutting the data into 2s parts and showing the characteristics of each trial in *ft_rejectvisual.m*. Needs as input the subjectdir (e.g. 'Subjects'), the non-unique subject string (e.g. 'pp'), a boolean for whether the data needs to be overwritten and the string for the type of data to be analyzed (e.g. 'compRemoved'). A GUI will be started up in which individual trials can be selected by drawing a box around the dots in the lower left graph (please don't remove channels of the upper right graph, they should've already be removed in step 3). Select different characteristics based on which the channels will be viewed in the bottom left graph. Removes the trials automatically when clicking quit and saves the datafile as *[subjectdirname]_cleaned.mat*. Adds a '_cleaned' part to the data.preprocessOrder.  

#### Do connectivity analysis
**10) run createPLIMatrices.m**  
run _createPLIMatrices.m_. Will create PLI matrices based on the '\_cleaned.mat' file.  
Takes as input:
* freqrange:  [vector] frequency range
* dataType:
  - 'nanbadchannels' (default): creates PLI matrices based on good channels per subject. Adds bad channels as NaN in the correlation matrix
  - 'interpolated': creates PLI matrices based on interpolated data (please run _interpolateChannels.m_ first). This is not recommended if more than one channel for a subject is missing.
  - 'goodchannelspersubject': analyzes all good channels for each subject, this will cause the resulting correlation matrices to not be the same size.
  - 'goodchannelspergroup': analyzes only the channels that are good for every subject. This will usually result in smaller correlation matrices
* overwrite boolean
* method: 'wpli_debiased' or 'pli'
* subjectDir (e.g. 'Subjects')
* non-unique subject dir string (e.g. 'pp')

Outputs an individual pli matrix to the individual results folder (will be created if not present). Will also create a summary struct of all subjects in the rootdir results folder (will be created if not present), saved as *[dataType]_[freqrange]_allCorrelationMatrices.mat*. In this file a allSubjectResults struct contains a cell with the directory names of all analyzed subjects, a cell of the condition of all subjects, a cell with the original filenames of all subject, a cell with the channel names used in the plit matrices and a 3-dimensional matrix with all the pliCorrelation matrices.

![alt-text](https://i.imgur.com/vyU1q7a.jpg)


