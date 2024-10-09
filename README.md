<p align="center">
  <img src="path/to/your/logo.png" alt="Project Logo" width="200">
</p>
# Wise Reporting Project

This repository contains the code and documentation for the Wise reporting project. The project aims to provide aggregate data to regulators (R1 and R2) based on the provided Wise dataset.

## Project Directory Structure

This directory is organized into a clear and logical structure to facilitate easy navigation and understanding. Each folder corresponds to a key stage in the data processing and analysis pipeline:

* **00_Manuals**: This folder contains comprehensive documentation outlining the step-by-step processes involved in the project. This ensures the project can be easily replicated and understood in the future, even by those unfamiliar with the initial setup.
* **01_Upload_Files**: This folder houses the Python scripts responsible for uploading the `.xls` file provided by Wise and creating the corresponding tables within BigQuery. This step prepares the data for subsequent analysis.
* **02_Data_Analysis**: This folder contains two BigQuery queries:
    * An exploratory query focusing on data cleaning and preparation, including handling null values and negative values.
    * A reporting query that generates the final datasets required for the R1 and R2 reports.
* **03_Reports**: This folder contains the final outputs of the project:
    * A general report answering the specific questions posed by Wise.
    * Separate, detailed reports tailored to the requirements of R1 and R2.
    * A PowerPoint presentation summarizing the key findings and insights from the data analysis.

## Data and Methodology

The project utilizes the dataset provided by Wise, which contains information on customer transactions, demographics, and other relevant metrics. The data is processed using Python and BigQuery, leveraging their respective strengths in data manipulation and analysis.

## Key Features

* **Reproducibility**: The detailed documentation in the `00_Manuals` folder ensures that the project can be easily reproduced and the results can be independently verified.
* **Scalability**: The use of BigQuery allows for efficient processing of large datasets and enables the project to scale as the data volume grows.
* **Transparency**: The clear directory structure and well-commented code promote transparency and make it easy to understand the data processing and analysis steps.

## Getting Started

To run this project, you will need:

* Access to the Wise dataset (`.xls` file).
* A Google Cloud Project with BigQuery enabled.
* Python 3.x installed.

Please refer to the `00_Manuals` folder for detailed instructions on setting up the environment and running the code.
