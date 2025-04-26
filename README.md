# Re-design of a magnetic levitation platform: from an early prototype to a working system
Bachelor Thesis in Electronic Engineering - November 2022 - Università degli Studi di Padova @unipd

## Abstract
This work documents the modelling and re-designing of a maglev platform intended to become a take-home lab for students interested in control engineering. The platform, initially designed by a team of Norwegian students, presented a series of inefficiencies and limitations that this work seeks to remove. Thus, the final goal of this project is to fully develop and test an improved maglev platform.

The thesis introduces both the theoretical framework behind the modeling of the system, and the specific frameworks for designing and analysing the various electronic subsystems that were deemed to be improvable. In doing so, this work discusses those subsystems, lists a set of potential solutions together with their pros and cons, and selects potential choices one may take, given the techno-economic constraints surrounding the project. In addition, practical implementation issues are discussed, giving in this way an overview of which parts of the systems should be further analyzed and fine tuned before arriving at a system that is ready for production. 

The most challenging part of this project has been entering into it without clear guidelines of the design choices made by the previous team. It is precisely for this reason that this work does not just aim at reporting on the project itself, but also at offering documentation that is as clear as possible, intended to help a potential future team bringing the project to its next phase.

[Click here to read the dissertation](https://github.com/albertomors/maglev22/blob/b5a09330e3dea7a6b91397591241a9633b680332/Bachelor%20Thesis%20-%20maglev22.pdf)

<img src="https://github.com/albertomors/maglev22/blob/main/model_fusion.png" width="400">

## Structure

```
maglev22/
├── code                               # C++/arduino code for the Teensy4.0 microcontroller
├── datasheets                         # details about the electronic components used in the project  
├── matlab                             # modelling scripts   
├── schematics                         # kicad, fritzing and multisim schematics
├── Bachelor Thesis - maglev22.pdf     # Dissertation
├── LICENSE                            # License information
├── README.md                          # Project documentation
└── model_fusion.png                   # Picture of the prototype built
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
