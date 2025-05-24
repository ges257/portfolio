# SVD Image Compression

This project implements manual SVD–based compression on color image channels:
- Avoids built-in svd() or eigen-decomposition functions
- Compresses each RGB channel separately
- Quantifies reconstruction error and memory savings

## Setup

cd code/svd-image-compression  
conda env create -f environment.yml

## Usage

conda activate svd-image-compression  
jupyter notebook SVD_image_compression.ipynb

## Files

- `environment.yml` — Conda dependencies  
- `SVD_image_compression.ipynb` — compression notebook  
- `original_image.jpg` — input image  
- `SVD_image_compression.pdf` — project report  
- `README.md` — this file

## License

All rights reserved — for viewing purposes only.
