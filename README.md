# Re-design of a magnetic levitation platform: from an early prototype to a working system
repo for myy Bachelor Thesis in Electronic Engineering - November 2022 - Università degli Studi di Padova @unipd

[Download the paper](https://github.com/albertomors/maglev22/blob/b5a09330e3dea7a6b91397591241a9633b680332/Bachelor%20Thesis%20-%20maglev22.pdf)

## Repository Structure

code : c++/arduino code for the Teensy4.0 microcontroller  
datasheets : details about the electronic components used in the project  
matlab : modelling scripts    
schematics : kicad, fritzing and multisim schematics  

```
Aurora/
├── Aurora_architecture.ipynb      # Jupyter Notebook detailing the model architecture
├── Aurora_paper.pdf               # Research paper describing the project
├── dataset_augmentation_offline.py# Script for offline dataset augmentation
├── npy_to_hdf5.py                 # Script to convert .npy files to .hdf5 format
├── LICENSE                        # License information
└── README.md                      # Project documentation
```

<img src="https://github.com/albertomors/maglev22/blob/main/model_fusion.png" width="400">

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
