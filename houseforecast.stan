data {
  int<lower=0> I; // number of incumbent races
  int<lower=0> J; // number of open races
  int<lower=0> D; // number of races automatically conceded to democrats
  int<lower=0> R; // number of races automatically conceded to republicans
  real expswing; // expected national swing from 2016
  int dfswing; // degrees of freedom of swing in t distribution
  real expI[I]; // expected result under even national vote for incumbent races
  real expJ[J]; // expected result under even national vote for open races
  real<lower=0> sdswing; // standard deviation of expectation of national swing from 2016
  real<lower=0> sdI; // expected variance for incumbent races
  real<lower=0> sdJ; // expected variance for open races
}
parameters {
  real swing;
  real deltaI[I];
  real deltaJ[J];
}
transformed parameters {
  real resI[I];
  real resJ[J];
  for (i in 1:I) resI[i] = swing + deltaI[i];
  for (j in 1:J) resJ[j] = swing + deltaJ[j];
}
model {
  swing ~ student_t(dfswing, expswing, sdswing);
  for (i in 1:I) deltaI[i] ~ normal(expI[i], sdI);
  for (j in 1:J) deltaJ[j] ~ normal(expJ[j], sdJ);
}
generated quantities {
  int<lower=0> rseats = R;
  int<lower=0> dseats = D;
  for (i in 1:I) {
    if (resI[i] > 0) {
      dseats = dseats + 1;
    } else {
      rseats = rseats + 1;
    }
  }
  for (j in 1:J) {
    if (resJ[j] > 0) {
      dseats = dseats + 1;
    } else {
      rseats = rseats + 1;
    }
  }
}
