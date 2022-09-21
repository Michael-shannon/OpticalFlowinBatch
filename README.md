<!-- Your title -->

# Welcome to the easy Lucas-Kanade PIV GitHub Page! 👋

This is a SUPER EASY TO USE version of a previously used and published method to do optical flow analysis in cells.

I got a version from **_Ivan Rey-Suarez_** and **_Arpita Upadhyaya_**, "Nanotopography modulates cytoskeletal organization and dynamics during T cell activation" by Brittany A. Wheatley, Ivan Rey-Suarez, Matt J. Hourwitz, Sarah Kerr, Hari Shroff, John T. Fourkas, and Arpita Upadhyaya. That version was adapted by them from one made by the @LosertLab at https://github.com/losertlab/flowclustertracking as per the manuscript: "Quantifying topography-guided actin dynamics across scales using optical flow" by Lee*, Campanello*, Hourwitz, Alvarez, Omidvar, Fourkas and Losert.

What I did, is to make a 'one-click' version that:

1) Calculates optical flow on all your data in batch, making a vector map
2) Applies masks to your data, and extracts the following information in the form of a big statistical table of all your conditions and replicates over time:
    a) Flow speed
    b) Immobile/mobile fraction
    c) Von Mises kappa parameter - a measure of the change of flow directionality.
3) Exports all of this data in tidy format csvs (for software agnostic plotting) and makes and exports violin plots and timeplots.

Your input files are assumed to be timelapse movies from some kind of fluorescent microscope. I used this to track actin labelled with lifeact-mScarlett, imaged using a confocal microscope.

Contact me if you need help using it

[![Gmail](https://img.shields.io/badge/-Gmail-critical?style=flat-square&logo=Gmail&logoColor=white&link=mailto:mkjshan@gmail.com)](mailto:mkjshan@gmail.com)
[![Outlook](https://img.shields.io/badge/-Outlook-0078D4?style=flat&logo=Microsoft-Outlook&logoColor=white)](mailto:mjs2399@cumc.columbia.edu)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https://twitter.com/mshanj)](https://twitter.com/mshanj)
[![GoogleScholar](https://img.shields.io/badge/-Google%20Scholar-9cf?style=flat&logo=Google&logoColor=white)](https://scholar.google.com/citations?user=pv7PczwAAAAJ&hl=en&authuser=1)


## How to run this? 🤔

Two steps: 1) Order your files into condition and replicate folders. 2) Change the directory names to your local master folders and run three scripts one by one.

### Order your files 💻

Folder hierarchy required:

MasterFolder  .> Condition 1
              .> Condition 2  .> Replicate folder 1
                              .> Replicate folder 2
                              .> Replicate folder 3 .> Replicate3Tiffstack.tif

Input format is a single tiff stack for each replicate. Save each tiff stack in its own folder with the same name as the TIFF stack. Repeat this for as many
replicates as exist. All replicates must be saved within a condition folder. Condition folders must be saved within a masterfolder.

### Run the scripts 🌱

Clone or download this repository. Open Matlab (I did this analysis in Matlab 2021a).

Add all folders and subfolders to path in Matlab - to do this right select all of the folders, right click and select add folders and subfolders to path.

Open **_SCRIPT1_BatchControlScript.m_** change lines 14 to 19 to reflect the settings of your microscope.

Other settings can stay similar, if you acquired your images at 100 x magnification.

Change line 98 to the directory path of your master folder.

Hit run - this takes a long time, so come back tomorrow.

Open **_SCRIPT2_Batch_flow_immobile_vonmises_PostCommands_OpticalFlow.m_** , change lines 8 and 9 to reflect your input and output directories respectively.

Two settings highly effect the output and need to be changed for your data:

1) The reliability value. Line 60: relVal = 0.01*max(rel(:));
2) The magnitude threshold (under which things are considered immobile). Line 74:  magMask = mag > 1.0;

Hit run. For 100 replicates, 1024x1024 pixels, 120 frames each, this took me 4 hours.

Finally, open **_SCRIPT3_Batch_makeplots.m_**

Set the input directory to the output directory of script 2. Run this section to import the statstable containing means of all of the metrics per timepoint.

Set MetricOfInterest to whatever metric you are interested in plotting. You can see what metrics were extracted by opening up the statstable. This will make and export tidy format csvs for you, depending on what you are interested in.

Run the next sections to make violin and timeplots. Note that the plots require download of the relevant packages and addition of them to matlab path.

- 💬 Ask me about anything -> [I am happy to answer your questions](mailto:mjs2399@cumc.columbia.edu) & help you out;
- 📫 How to reach me: check the banners on top / bottom of this page!

### Getting in Touch 💬

I know how tricky it is to get things to work properly when time is of the essence! Please contact me if you need help.

[![Gmail](https://img.shields.io/badge/-Gmail-critical?style=flat-square&logo=Gmail&logoColor=white&link=mailto:mkjshan@gmail.com)](mailto:mkjshan@gmail.com)
[![Outlook](https://img.shields.io/badge/-Outlook-0078D4?style=flat&logo=Microsoft-Outlook&logoColor=white)](mailto:mjs2399@cumc.columbia.edu)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https://twitter.com/mshanj)](https://twitter.com/mshanj)
[![GoogleScholar](https://img.shields.io/badge/-Google%20Scholar-9cf?style=flat&logo=Google&logoColor=white)](https://scholar.google.com/citations?user=pv7PczwAAAAJ&hl=en&authuser=1)
