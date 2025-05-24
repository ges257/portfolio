# GPS Positioning

This project implements two tasks:
1. A Newton-based solver to compute receiver position and clock bias from satellite signals.
2. A conditioning analysis by perturbing satellite travel times (±1×10⁻⁸ s) and examining solution sensitivity.

## Setup

cd code/gps-positioning  
conda env create -f environment.yml

## Usage

conda activate gps-positioning  
jupyter notebook task1_solution.ipynb  
jupyter notebook task2_solution.ipynb

## Files

- environment.yml — Conda environment specification  
- task1_solution.ipynb — Newton’s method solver for GPS positioning  
- task2_solution.ipynb — GPS conditioning analysis notebook  
- README.md — this file

## License

All rights reserved — for viewing purposes only.
