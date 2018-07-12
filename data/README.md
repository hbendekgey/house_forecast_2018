# House 2018 Data

### cd2018data.csv
Compiled using the [Presidential results from DailyKos](https://docs.google.com/spreadsheets/d/1VfkHtzBTP5gf4jAu8tcVQgsBJ1IDvXEHjuMqYlOgYbA) and [Prooffreader's 2016 election data](https://github.com/Prooffreader/election_2016_data)

Note: Pennsylvania was redistricted due to a court ruling in February 2018. In order to estimate how these districts voted for President and representative in 2016, I referred to [this analysis](https://www.cookpolitical.com/analysis/house/pennsylvania-house/new-pennsylvania-map-major-boost-democrats) by Cook Political, treating each new district as a successor of a previous district (not necessarily of the same number). I shifted every seat's results according to the change in Cook PVI for that district. For the three districts uncontested in 2016 (new districts PA 04, 14, 16) I set their 2016 representative results to be the same as their adjusted Presidential results. 

Column Name | Explanation
------------- | -------------
`district` | Congressional district, in format "AB ##" with at-large districts numbered 00. 
`dem16share` | percentage of two-party vote won by Democratic house candidate in 2016, meansured in percentage points from 50. Set to 0 in conceded races.
`incumbent16` | -1 if a Republican incumbent ran in 2016, 1 if a Democratic incumbent ran, 0 otherwise.
`pres16share` | percentage of two-party vote won by Hillary Clinton in 2016, meansured in percentage points from 50. Set to 0 in conceded races.
`incumbent18` | -1 if a Republican incumbent is running in 2018, 1 if a Democratic incumbent is running, 0 otherwise. Pennsylvania is treated to have no incumbents due to redistricting
`concede` | 1 if race should be automatically assumed Democratic win according to Bafumi et al's model, -1 if it should be automatically assumed to be a Republican win. 

### presresults.csv
[Data obtained from DailyKos](https://docs.google.com/spreadsheets/d/1VfkHtzBTP5gf4jAu8tcVQgsBJ1IDvXEHjuMqYlOgYbA) reformatted by me. Contains Presidential election results 2008-2016 by congressional district.

Column Name | Explanation
------------- | -------------
`district` | Congressional district, in format "AB ##" with at-large districts numbered 00. 
`incumbent` | Current (2018) incumbent in congress
`party` | Party of current incumbent
`candidate####` | percentage of votes from that district won by candidate in the given year. 

### seatchange.csv
Compiled by me.

Column Name | Explanation
------------- | -------------
`year` | Year of election
`chrseats` | change in Republican seats due to this election
`prevrseats` | Republicans seats before election
`midterm` | -1  if Democrat in white house, 1 if Republican in white house. 
`nat_vote_dem` | percentage of national house vote that went to Democrats that year
`nat_vote_rep` | percentage of national house vote that went to Republicans that year

Note that the convention for the `midterm` variable is opposite of how it appears elsewhere, because this dataset was created to be used with Abramowitz's model.



