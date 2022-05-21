# Value context influences going but not stopping

Background
-----------
Cognitive control describes a set of processes, often associated with the frontal cortex and related brain networks, recruited to override habitual or inappropriate responses, and to facilitate stopping, switching, and updating [(Miller & Cohen, 2001)](https://pubmed.ncbi.nlm.nih.gov/11283309/). Previous work has proposed that response inhibition occurs in two modes: reactive and proactive [(Braver, 2012)](https://pubmed.ncbi.nlm.nih.gov/22245618/). These two processes are thought to be utilized reciprocally to enact goal-directed behavior. Whilst reactive inhibition functions as a late-acting correction mechanism, proactive inhibition is considered to be a more fluid process that occurs in the context of a given environment which can influence the response process. This form of control is thought to be important in the allocation of cognitive resources ahead of cognitively demanding events.  

Proactive control can be observed when manipulating a subject's motivational state; this can be achieved through varying expected reward outcomes. Such control manifests behaviorally through systematic changes in response latencies and accuracy, dependent on the motivational context. Through this work, we examined how expected reward values influenced stopping behaviors (such as SSRT, p(respond|stop-signal), etc...) and response latencies in a saccade countermanding task.

Summary and requirements
-------------------------
This repository contains MATLAB scripts developed to examine the influence of value context (high or low reward) on going and stopping in a saccade countermanding task. They have been tested using MATLAB R2018b.

In this work, we have used several toolboxes which will be required to run parts of our code.

* [Gramm - GRAMmar of graphics for Matlab (Morel, 2018)](https://github.com/piermorel/gramm)
* [Donut Plot](https://www.mathworks.com/matlabcentral/fileexchange/56833-donut)

Once complete, data required for this code will be available on OSF.

To run the scripts, add the repository and the dependent toolboxes (with their respective subdirectories) to the MATLAB path. A guide through the analyses within this study is provided in a MATLAB live notebook (2021_cmand_value.mlx) within this directory.

There are also R & Python scripts within this directory that were used during the analysis development; however, these were not used in the final analyses. Nevertheless, they are included here.

Test environment(s)
--------------------
- MATLAB Version: 9.5.0.1586782 (R2018b)
- Operating System: Microsoft Windows 10 Education Version 10.0 (Build 14393)

Key scripts
------------
Details for each analyses and their output are provided within the MATLAB notebook (2021_cmand_value.mlx).

### Figure 2

| **Figure panel** | *Script* | Description |
| ---------------- | ---------- | ----------- |
| Fig 2A | fig2_inhFunc_value | Inhibition function |
| Fig 2B | insert | Probability density function - wdPSE |
| Fig 2C | fig2_zrftFunc_value | ZRFT function |
| Fig 2D | fig2_zrftFunc_value | Probability density function - ZRFT slope |

### Figure 3

| **Figure panel** | *Script* | Description |
| ---------------- | ---------- | ----------- |
| Fig 3A | fig2_cdf_value | Cumulative density function - RT |
| Fig 3B | insert | Probability density function - wdPSE |
| Fig 3C | fig2_pSession_racemodel | Proportion of race model violations |
| Fig 3D | fig2_ssrt_boxplot | Boxplot of SSRT estimates |
| Fig 3E | fig2_delta_ssrtRT_boxplot | Context difference in SSRT and GO RT |




Readme last updated: 2022-05-20, 0950, S P Errington
