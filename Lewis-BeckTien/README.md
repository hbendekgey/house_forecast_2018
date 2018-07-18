# Lewis-Beck and Tien

Michael Lewis-Beck and Charles Tien propose a simple model, called the Structure-X model, to forecast house elections. The authors mix a structural model and an expert model to produce their forecast, hence the name. 

forecast.pdf contains a report in which I recreate their methodology to predict the results of the 2018 midterm elections in the house of representatives. Key pitfalls and parameter choices are outlined. All code for this report can be found in forecast.Rnw.

forecast.R contains an executable R script in which individual parameters and flags can be set. It produces a point estimate and 90% confidence interval for Democratic seats in the house, as well as a probability of the Democrats gaining control of the chamber.

### Usage

```console
Usage: Rscript [R options] forecast.R [Program options]
```

R options:
* Standard R command line options ([read more here](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html))

Program options:
* disapproval | approval | net-approval
    * set the variable to run regression on in the structural model. Each predictor has the same predictive power: June Presidential disapproval, June Presidential approval, June Presidential net approval, or the default value, June Presidential approval share (approval/approval + disapproval)
* only-structure
    * only run the structural half of the model and do not incorporate Rothenberg expert opinion.
* shift-pred
    * Try to fit the previous elections as well as possible by shifting predictions 7.5 seats away from the incumbent party, and reduce standard error accordingly. This risks overconfidence. Only do this if you believe the methodology outlined here is systematically biased towards incumbent parties (you must believe it ideologically, not by looking at 5 data points)
* set-approval x
    * Manually set Trump's June approval rating to x, measured in percentage points. What proportion of Americans would need to support Trump for Republicans to gain seats? Try that out here.
* set-disapproval x
    * Manually set Trump's June disapproval rating to x, measured in percentage points. What proportion of Americans would need to disapprove of Trump for Republicans to gain seats? Try that out here.
* set-rdig x
    * Manually set the Real Disposible Income growth between December 2017 and June 2018 to x, measured in percentage points. How good would the economy have to be doing for Republicans to gain seats? Try that out here.

examples:
```console
  Rscript --vanilla forecast.R disapproval set-rdig 3.9
  Rscript forecast.R set-approval 50 set-disapproval 50 net-approval only-structure
```

### Resources used:

* [Forecasting model paper](https://www.cambridge.org/core/journals/ps-political-science-and-politics/article/congressional-election-forecasting-structurex-models-for-2014/4C2505035EF87C2D32B20DA668E95577)