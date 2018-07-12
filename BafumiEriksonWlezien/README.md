# Bafumi, Erikson, and Wlezien

Bafumi, Erikson, and Wlezien propose a model for forecasting US house midterm elections based on data available by early July. They content that forecasts are primarily useful when submitted long enough in advance that stakeholders can respond appropriately. 

forecast.pdf contains a report in which I recreate their methodology to predict the results of the 2018 midterm elections in the house of representatives. Key pitfalls and parameter choices are outlined. All code for this report can be found in forecast.Rnw.

forecast.R contains an executable R script in which individual parameters and flags can be set. It produces a distribution of Democratic house seats and a point estimate and win percentage for each individual district, according to the parameters chosen.

### Usage
First make sure [Stan](http://mc-stan.org/) is installed. (I know, Stan is a bit overkill for such a simple model, but I wanted practice and by compiling the sampler into C code and running on multiple cores it becomes much more scalable) Note that the first time you run it, it can take a minute to compile the C code. Explanations for all choices and all defaults can be found in the report forecast.pdf

```console
Usage: Rscript [R options] forecast.R [Program options]
```

The district-by-district forecast will be written to a file named "district_forecast.csv" if no file of that name already exists in the directory (otherwise it won't write it). It will also write a probability of Democrats holding each number of seats under a file named "house_seats.csv" if no file of that name already exists.

R options:
  -Standard R command line options ([read more here](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html))

Program options:
* PA-inc
    * Treat current Pennsylvanian congressmen who are running in one of the newly created districts as incumbents. By default, due to redistricting all Pennsylvanian seats are considered open seats.
* 2014-template
    * Uses the 2014 prediction template for individual races, as opposed to the default 2010 template. This puts a lot more weight on incumbent performance in the previous election, and much less on Presidential performance. Use this if believe the 2018 Republican party is more the party of the establishment than the party of Trump. 
* consider-vacate
    * Allows the mean open seat and mean incumbent seat to swing by different amounts from 2016 to 2018, by considering the fact that a majority of open seats were vacated by Republicans. This gives Democrats an advantage in open seats and just slightly penalizes them in incumbent seats. (The math being done here is very simple and could be made much more sophisticated)
* expected-swing x
    * Manually set the expected 2016 to 2018 national vote swing to x, measured in percentage points. Defaults to 4.476. This model is based on the generic congressional ballot, which has been demonstrated a much more modest swing to Democrats than the special election results this past year. If you trust those few results more, increase this value. 
* stdev-swing x
    * Manually set the standard deviation of the swing prediction to x, measured in percentage points. Defaults to 1.842. A higher value indicates less certainty that the nation will swing the way this model predicts. If you believe that regressing on previous elections will not give a result that is reflective of this election (i.e. you think something about this election is never-before-seen) then increase this value. 
* stdev-open x
    * Manually set the standard deviation of open congressional district results to x, measured in percentage points from how they are predicted to behave. Defaults to 6.133, or 6.124 in the 2014 template. A small value here indicates that these districts can be largely predicted by national trends, i.e. "all politics is national"
* stdev-inc x
    * Manually set the standard deviation of incumbent congressional district results to x, measured in percentage points from how they are predicted to behave. Defaults to 4.493, or 3.709 in the 2014 template. A small value here indicates that these districts can be largely predicted by national trends, i.e. "all politics is national"
* no-poll-adjust
    * removes the adjustment of historic registered voter polls to the right to conform with likely voter populations. This cannot be set if you manually set the exptected swing.
* unfix-intercept
    * removes the fixed intercept from the linear model predicting vote population. The fixed intercept reflects the believe that polls (once the registered voter adjustment is taken into account) are no more likely to be biased one way than the other. Setting this flag means you do not believe that. This cannot be set if you manually set the expected swing.

examples:
```console
  Rscript --vanilla forecast.R 2014-template expected-swing 5.9
  Rscript forecast.R expected-swing 3.9 consider-vacate stdev-swing 3
```

### Repos and Resources used:

* [Forecasting model paper](https://www.cambridge.org/core/journals/ps-political-science-and-politics/article/div-classtitlenational-polls-district-information-and-house-seats-forecasting-the-2014-midterm-electiondiv/30AA4C783033BC766ADC110C9317EB33)
* [2016 election data](https://github.com/Prooffreader/election_2016_data)
* [2000-2014 election data](https://github.com/timothyrenner/fec-election-results)
* [Fivethirtyeight's 2018 generic ballot data](https://github.com/fivethirtyeight/data/tree/master/congress-generic-ballot)
* [Stan](http://mc-stan.org/)
