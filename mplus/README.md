## MPLUS Modeling

This directory contains data and syntax files for all SEM run for the Additive Redundant Manuscript. The analysis Proceeds in the following order:

Step 1: Determining the Necessity of Multilevel Modeling
- Following the method of Jak et al. 2013, a series of models were run to determine if multilevel modeling was necessary for our data.
  -  Two "null" models were run: the first testing whether a completely zero variance/covariance model fits the between subjects (level 2) data and the second testing whether a compeltely zero covariance matrix (i.e., freely estimating variance) model fits the between subjects (level 2) data
- "Null" modeling was run seperately for the neural data and the behavioral data.  
**Neural Data**  
- See: `neural_null_between_model.inp` and `neural_null_between_model.out`  
- See: `neural_null_between_model_cov.inp` and `neural_null_between_model_cov.out`  
**Behavioral Data**  
- See: `behav_null_between_model.inp` and `behav_null_between_model.out`  
- See: `behav_null_between_cov.inp` and `behav_null_between_cov.out`  

Step 2: Determine if crosslevel invariance holds
- Following the methodology of Jak et al. 2013
- Fitting a model with the same measurement model at level 1 and level 2 with zero residual variance at level 2 AND the loadings fixed to be equal across levels  
**Neural Data**  
- See: `neural_crosslevel_invariance.inp` and `neural_crosslevel_invariance.out`  
**Behavioral Data**  
- See: `behav_crosslevel_invariance.inp` and `behav_crosslevel_invariance.out`  

Step 3: Fit an appropriate measurement model
- Following the methodology of Bolt et al. 2018, find an appropriate measurement model
- I fit a measurement model for the neural and beahvioral data seperately, then combined them into a joint model  
**Neural**
- See: `neural_measurement_model_within.inp` and `neural_measurement_model_within.out`  
**Behavioral**
- See: `behav_measurement_model.inp` and `behav_measurement_model.out`  
**Joint**
- See: `joint_measurement_model.inp` and `joint_measurement_model.out`  

Step 4: Determine if any of the PM Network nodes have unique information with respect to Memory Quality  
- Following the methodology of Bolt et al. 2018  
- Each ROI was tested for unique information by first fitting a "baseline" structural model (`Model 0`) and comparing various nested models to this baseline model (`Models 1-8`). Statistical significance was determined via a likelihood ratio test.  
- See `model0.out`, `model1.out`, `model2.out`, `model3.out`, `model4.out`, `model5.out`, `model6.out`, `model7.out`, `model8.out`  

# References

Bolt, T., Prince, E. B., Nomi, J. S., Messinger, D., Llabre, M. M., & Uddin, L. Q. (2018). Combining region- and network-level brain-behavior relationships in a structural equation model. NeuroImage, 165, 158–169. https://doi.org/10.1016/j.neuroimage.2017.10.007  

Jak, S., Oort, F. J., & Dolan, C. V. (2013). A Test for Cluster Bias: Detecting Violations of Measurement Invariance Across Clusters in Multilevel Data. Structural Equation Modeling: A Multidisciplinary Journal, 20(2), 265–282. https://doi.org/10.1080/10705511.2013.769392  
