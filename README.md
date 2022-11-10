# NCONSC_ParesPujolras_Matic_Haggard

This repository contains high-level DATA and analysis SCRIPTS for the following paper: 
Parés-Pujolràs, E., Matic, K., & Haggard, P. 

The scripts and data files included in the repository enable the replication of the data analysis and figures reported in the paper.
Raw & preprocessed EEG data can be found at the following OSF repository: https://osf.io/dh8j9/

The folder SCRIPTS contains four main scripts:

      • Expt1_EEGAnalysis.m -Matlab master script for Experiment 1 EEG processing. It relies on the functions under the /Exp1_functions/ folder.Outputs: high-level files for processing in R & figures, saved locally. It relies on the functions under the Exp1_functions folder. 
      • Expt1_Analysis.R - R script for Experiment 1 postprocessing, plotting & statistical analysis. Input: high-level data provided in the DATA/ folder. Outputs: statistical results & figures, saved locally. 
  
      • Expt2_EEGAnalysis.m - this is a Matlab master script for Experiment 2 EEG processing. It relies on the functions under the /Exp2_functions/ folder.Outputs: high-level files for processing in R & figures, saved locally.
      • Expt2_Analysis.R - R script for Experiment 1 postprocessing, plotting & statistical analysis. Input: high-level data provided in the DATA/ folder. Outputs: statistical results & figures, saved locally. 
   

The folder DATA contains several data high-level files in various formats that allow the replication of all the results and figures reported in the paper from preprocessed data, available at OSF.  

      • Exp1_R_burstData_orangeLetter_X.csv - contains summary data for orange letter epoch (channel X) for statistical analysis in R.
      • Exp1_R_burstData_selfPaced_X.csv - contains summary data for orange letter epoch (channel X) for plotting in Matlab.
      • Exp1_R_RPdata_orangeLetter_forR.csv - contains averaged Cz amplitude 100 ms pre-orange letter (channel CZ) for statistical analysis in R.

      • Exp2_R_burstData_OL_X.csv - contains summary data for orange letter epoch (channel X) for statistical analysis in R.

