# Value context influences going but not stopping

Background:
-----------
Cognitive control describes a set of processes, often associated with the frontal cortex and related brain networks, recruited to override habitual or inappropriate responses, and to facilitate stopping, switching, and updating [(Miller & Cohen, 2001).](https://pubmed.ncbi.nlm.nih.gov/11283309/). Previous work has proposed that response inhibition occurs in two modes: reactive and proactive [(Braver, 2012).](https://pubmed.ncbi.nlm.nih.gov/22245618/) These two processes are thought to be utilized reciprocally to enact goal-directed behavior. Whilst reactive inhibition functions as a late-acting correction mechanism, proactive inhibition is considered to be a more fluid process that occurs in the context of a given environment which can influence the response process. This form of control is thought to be important in the allocation of cognitive resources ahead of cognitively demanding events.  

Proactive control can be observed when manipulating a subject's motivational state; this can be achieved through varying expected reward outcomes. Such control manifests behaviorally through systematic changes in response latencies and accuracy, dependent on the motivational context. Through this work, we examined how expected reward values influenced stopping behaviors (such as SSRT, p(respond|stop-signal), etc...) and response latencies in a saccade countermanding task.

Summary and requirements:
-------------------------
This repository contains MATLAB, R, & Python scripts developed to examine the influence of value context (high or low reward) on going and stopping in a saccade countermanding task. They have been tested using MATLAB R2018b.

In this work, we have used several toolboxes which will be required to run parts of our code.

* [Gramm - GRAMmar of graphics for Matlab (Morel, 2018)](https://github.com/piermorel/gramm)

This code requires data available [here](https://canlabweb.colorado.edu/publications-v1/47-published-in-2018/4950-kragel-pa-kano-m-van-oudenhove-l-ly-hg-dupont-p-rubio-a-delon-martin-c-bonaz-b-manuck-s-gianaros-pj-ceko-m-losin-ear-woo-cw-wager-td-accepted-generalizable-representations-of-pain-cognitive-control-and-negative-emotion-in-medial-frontal-cortex-nature-neuroscience.html).

To run the scripts, add the repository and the dependent toolboxes (with their respective subdirectories) to the MATLAB path. A guide through the analyses within this study is provided in a MATLAB live notebook (2021_cmand_value.mlx) within this directory.

Test environment(s):
--------------------
- MATLAB Version: 9.5.0.1586782 (R2018b)
- Operating System: Microsoft Windows 10 Education Version 10.0 (Build 14393)
