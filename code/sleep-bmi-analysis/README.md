# Sleep–BMI Moderation Analysis

Logistic regression of sleep trouble as a function of BMI and physical activity using NHANES data for adults 30+.

## Setup

cd code/sleep-bmi-analysis  
conda env create -f environment.yml  
conda activate sleep-bmi  

## Usage

Rscript analysis.R  

After running this, you’ll see:  
- Regression tables printed in your console  
- Three PNGs saved in figures/:  
  - fig1_predicted-probability.png  
  - fig2_bmi-distribution.png  
  - fig3_activity-interaction.png  

## Files

- analysis.R – full R script  
- environment.yml – Conda dependencies  
- figures/ – output plots  
- SleepBMI_Adults30_PhysActivity_Final.pdf – final report in ../reports/  

## License

All rights reserved — for viewing purposes only.
