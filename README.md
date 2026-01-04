# Geolocation Mapping and Spatial Data Analysis in R

[![R-version](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![License: CC0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)](https://creativecommons.org/publicdomain/zero/1.0/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18147414.svg)](https://doi.org/10.5281/zenodo.18147414)

## 📋 Description
This repository contains a professional R script designed to generate **multi-scalar location maps**. It automates the creation of high-resolution geographical visualizations, moving from a continental scale down to specific municipal coordinates in **Cabo de Santo Agostinho, Pernambuco, Brazil**.

## 🗺️ Visual Output
The script generates a composite map with four synchronized panels:
* **South America:** Regional context.
* **Brazil:** National localization highlighting Pernambuco.
* **Pernambuco:** State-level view optimized for continental visualization.
* **Study Area:** Detailed municipal view including neighbor municipalities and specific coordinate markers.

## 🛠️ Tech Stack & Libraries
The project utilizes the following R packages:
* `sf` & `geobr`: Geospatial data handling (IBGE 2020).
* `rnaturalearth`: Continental vector data.
* `ggplot2`, `ggspatial` & `ggrepel`: Advanced mapping and labeling.
* `cowplot`: Multi-panel composition.

## 📂 Repository Structure
* `geolocation_mapping_pe.R`: Main script with automated data acquisition and map generation.
* `.gitignore`: Configuration to prevent local temporary files (like `.Rhistory`) from being tracked.
* `LICENSE`: CC0 1.0 Universal license.

## 🚀 How to Use
1.  Clone this repository.
2.  Open `geolocation_mapping_pe.R` in RStudio.
3.  Ensure you have an active internet connection (the script fetches data directly from IBGE/Natural Earth servers).
4.  Run the script to generate a high-resolution PNG map.

## 🎓 About the Author
**Jean Firmino Cardoso**
Researcher and MSc Candidate in Energetic and Nuclear Technologies at the Federal University of Pernambuco (UFPE).
* [ORCID](https://orcid.org/0000-0001-6092-713X)
* [ResearchGate](https://www.researchgate.net/profile/Jean-Cardoso-6?ev=hdr_xprf)
