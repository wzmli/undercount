

Thanks to the editors and reviewers for valuable comments.

Based on both reviewer's comments, and with the editor's permission, we have gone beyond the 750-word limit to include a new section showing a simple mathematical illustration of the problem. 

## Reviewer 1

### Comments to the Author (blind)

**This is a responsa to the paper by Maruotti et al. (2022) in the same Journal and to similar paper by the same group appeared in 2020 in the Intarnational Journal of Infectious Dieseases. the argument is sound but, in my perspective, the real reson for the method proposed by Maruotti et al. (2022) not working properly is not fully exploited.**

We have amplified the arguments in our logical critique,  and have added a section showing a simple mathematical argument that refutes Maruotti *et al*'s method in a particular case (exponential growth without bias correction).

**In this respect the logical argument is much more sound than the simulation experiment which is not commented at all. Usually, simulation experiments are built to match some real situations but this step, and the choice of parameters used, isnot explained by the authors, so one may not aundferstand what is going on. This should be better posed in a clear argument to describe which kind of disease we are thinking of, which kind of geogrphical/temporal spread and so on.**

We have added more detail on the simulation parameters, which broadly capture the range of expected patterns from an emerging disease outbreak. However, we also argue that the problems with Maruotti *et al*'s methods are fundamental and largely independent of the details of an epidemic disease outbreak. We explain that we constructed simulations to match the situation where the original authors suggest that their method is most appropriate -- during the the exponential-growth phase of the epidemic.

**The logical argument is not fully exploited as mark-recapture techniques are based on multiple sources, often assumed to be independent, and on the availability of individual records that may help estimate whether the same unt is recorded by more than one source. This is not possible in this context, and the idea of working with $\Delta N(t)$ is, in my perspective, not giving the result we expect to give. So, these methods may not be helpful in this context, but the argument should clearly erxplain why. A single simulation experiment is not enough, as a lowerbound estimator may not necessarily give a lower bound for any observed sample. Tthe authors should work more to develop their logical argument.**

We already expressed this idea (that mark-recapture techniques require multiple, usually independent, sources of data) in section 3.1, "logical argument". We agree that this logical argument should be sufficient by itself to convince a thoughtful reader; however, we have now (1) explained the logical argument in more detail; (2) included a mathematical derivation to show precisely how the method fails during the exponential phase of an epidemic, and (3, as before) included a set of simulations for readers who want a practical demonstration.

## Reviewer 2

### Comments to the Author (blind)

**The article is obviously important. It is a big challenge to find a single thru way for a forecasting.**

**"some algebra shows that during the exponential growth phase of an epidemic, the (simplified) lower bound on $\hat{a}$ is exactly equal to $1/(1+ exp(r \Delta t))$." should have a reference for a source.**

We have include a section showing the algebra in the revised version. 

**It is a too broad conclusion "These methods should not be used.". For what? Please clarify. Because these methods may exist as an exercise to understand an initial stage of the infections' spreading.**

The authors of the original method have presented these methods as a way to estimate undercounts, especially during the initial stages of an epidemic. We argue here that the method is simply not fit for this purpose, or any other purpose (we have qualified "should not be used" to "should not be applied to estimate ascertainment ratios from disease outbreak incidence data").

## EDITORIAL OFFICE COMMENTS

When submitting your revision, please note that we will require some extra information from you. If this information is not supplied at revision, it may result in the delay in processing of your manuscript:

### Data Availability Statement

No data are used in the paper; all code for simulations is available at https://github.com/wzmli/undercount

### Conflict of Interest statement

We declare that none of the authors have conflicts of interest.

### Author contribution statement

All authors contributed to the conceptual development of the paper. ML and BMB wrote computer code for simulations and figures. BMB wrote the first draft of the paper. All authors commented and edited to produce the final version.

