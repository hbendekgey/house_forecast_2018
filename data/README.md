# House 2018 Data

### cd2018data.csv
Compiled using the [Presidential results from DailyKos](https://docs.google.com/spreadsheets/d/1VfkHtzBTP5gf4jAu8tcVQgsBJ1IDvXEHjuMqYlOgYbA) and [Prooffreader's 2016 election data](https://github.com/Prooffreader/election_2016_data)

Column Name | Explanation
------------- | -------------
`district` | Congressional district, in format "AB ##" with at-large districts numbered 00. 
`dem16share` | percentage of two-party vote won by Democratic house candidate in 2016, meansured in percentage points from 50. Set to 0 in conceded races.
`incumbent16` | -1 if a Republican incumbent ran in 2016, 1 if a Democratic incumbent ran, 0 otherwise.
`pres16share` | percentage of two-party vote won by Hillary Clinton in 2016, meansured in percentage points from 50. Set to 0 in conceded races.
`incumbent18` | -1 if a Republican incumbent is running in 2018, 1 if a Democratic incumbent is running, 0 otherwise. Pennsylvania is treated to have no incumbents due to redistricting
`concede` | 1 if race should be automatically assumed Democratic win according to Bafumi et al's model, -1 if it should be automatically assumed to be a Republican win. 

### genpollsmayjune.csv
Data obtained from Roper Archive's poll searching database, compiled by hand.

Column Name | Explanation
------------- | -------------
`start_date` | first day poll was conducted
`end_date` | last day poll was conducted
`year` | year of poll
`pollster` | pollster who conducted poll
`population` | RV for Registered Voters and LV for Likely Voters
`sample_size` | number of people polled
`method` | PI for personal interview, TI for telephone interview
`dem` | percentage respondents who indicated Democratic	
`rep` | percentage respondents who indicated Republican	
`dem_lean` | percentage respondents who were undecided but leaned Democratic	
`rep_lean` | percentage respondents who were undecided but leaned Republican	
`nat_vote_dem` | percentage of national house vote that went to Democrats that year
`nat_vote_rep` | percentage of national house vote that went to Republicans that year


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

Note that the convention for the `midterm` variable is opposite of how it appears elsewhere, because this dataset was created to be used with Abramowitz's model.



