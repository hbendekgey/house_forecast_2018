# Harry Bendekgey, house forecast based on Bafumi, Erikson, Wlezien

options(digits=5)

# parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
paInc <- "PA-inc" %in% args
template14 <- "2014-template" %in% args
consider_vacate <- "consider-vacate" %in% args
set_exp_swing <- "expected-swing" %in% args
set_sd_swing <- "stdev-swing" %in% args
set_sd_open <- "stdev-open" %in% args
set_sd_inc <- "stdev-inc" %in% args
no_adjust <- "no-poll-adjust" %in% args
no_fix_int <- "unfix-intercept" %in% args

if (length(args) != sum(paInc, template14, consider_vacate,
                        2 * set_exp_swing, 2 * set_sd_swing,
                        2 * set_sd_open, 2 * set_sd_inc,
                        no_adjust, no_fix_int)) {
  stop("Invalid arguments")
}

parse_param <- function(flag_set, flag_str, default) {
  if(flag_set) {
    param <- as.numeric(args[which(args == flag_str) + 1])
    if (!is.numeric(param)) {
      stop("Invalid arguments")
    }
    return(param)
  } else {
    return(default)
  }
}

# set expectations and variances
sdopen <- parse_param(set_sd_open, "stdev-open", 6.133)
sdinc <- parse_param(set_sd_inc, "stdev-inc", 4.053)
expswing <- parse_param(set_exp_swing, "expected-swing", 4.129) 
sdswing <- parse_param(set_sd_swing, "stdev-swing", 1.792) 
dfswing <- 16

if ((no_adjust | no_fix_int) & set_exp_swing) {
  stop("Cannot set no-poll-adjust or unfix-intercept flags if manually setting national swing")
}

if (no_adjust & no_fix_int) {
  dfswing <- 15
  expswing <- 3.660 
} else if (no_adjust) {
  expswing <- 4.448
} else if (no_fix_int) {
  dfswing <- 15
  expswing <- 3.657
}

# alternate defaults for other template
if (template14 & !set_sd_inc) {
  sdinc <- 3.709 
}
if (template14 & !set_sd_open) {
  sdinc <- 6.124 
}

library(dplyr)
library(readr)
library(ggplot2)
library(gtools)
library(rstan)

# isolate conceded, open, and incumbent races
cd2018data <- read_csv("../data/cd2018data.csv")
Dconcede <- cd2018data %>% filter(concede == 1) %>% nrow() 
Rconcede <- cd2018data %>% filter(concede == -1) %>% nrow()

if(paInc) {
  open18 <- filter(cd2018data, concede == 0, incumbent18 == 0)
  inc18 <- filter(cd2018data, concede == 0, incumbent18 != 0)
} else {
  open18 <- filter(cd2018data, concede == 0, incumbent18 == 0 | grepl("PA",district))
  inc18 <- filter(cd2018data, concede == 0, incumbent18 != 0 & !grepl("PA",district))
}

inc18 <- mutate(inc18, frosh = incumbent18 * (incumbent16 != incumbent18))

# template params
open_pres_coef <- ifelse(template14, 0.923, 0.95)
inc_pres_coef <-ifelse(template14, 0.128, 0.46)
inc_frosh_coef <- ifelse(template14, 2.258, 2.03)
inc_prev_coef <- ifelse(template14, 0.873, 0.63)

#calculate base intercepts
openint <- mean(open18$dem16share) - open_pres_coef * mean(open18$pres16share) 
incint <- mean(inc18$dem16share) - mean(inc_prev_coef * inc18$dem16share + 
                                          inc_pres_coef * inc18$pres16share + 
                                          inc_frosh_coef * inc18$frosh)

if (consider_vacate) {
  dvacate <- open18 %>% filter(incumbent16 == 1) %>% nrow()
  rvacate <- open18 %>% filter(incumbent16 == -1) %>% nrow()
  openint <- openint + inc_frosh_coef * (rvacate - dvacate) / nrow(inc18)
  incint <- incint - inc_frosh_coef * (rvacate - dvacate) / nrow(inc18)
}

# calculate expectations if national swing is even
open18 <- mutate(open18, exp18 = openint + open_pres_coef * pres16share) 
inc18 <- mutate(inc18, exp18 = incint + inc_prev_coef * dem16share + 
                                        inc_pres_coef * pres16share + 
                                        inc_frosh_coef * frosh)

# assemble data and run stan
housedat <- list(I = nrow(inc18),
                 J = nrow(open18),
                 D = Dconcede,
                 R = Rconcede,
                 expswing = expswing,
                 sdswing = sdswing,
                 dfswing = dfswing,
                 expI = inc18$exp18,
                 expJ = open18$exp18,
                 sdI = sdinc,
                 sdJ = sdopen)
cores <- max(parallel::detectCores() - 1,1)
rstan_options(auto_write = TRUE)
options(mc.cores = cores)
cat("Beginning simulation:")
fit <- stan(file = 'forecast.stan', data = housedat, 
            iter=11000, warmup=1000, chains=cores, seed=483892929)
posterior <- as.matrix(fit) %>% data.frame()

cat("Probability of Democrats taking house:", sum(posterior$dseats > 217) / nrow(posterior) * 100, "\n")
cat("90% confidence interval for Democratic seats:", quantile(posterior$dseats, c(0.05,0.95)), "\n")

dem_win_pct <- ((colSums(posterior > 0)/nrow(posterior)) %>% head(-3))[-c(1:368)] * 100
dem_share <- ((colMeans(posterior)) %>% head(-3))[-c(1:368)] + 50
dem_share[dem_share > 100] = 100
conceded <- cd2018data %>% 
  filter(concede == 1 | concede == -1) %>% 
  mutate(dem_share = NA, dem_win_pct = ifelse(concede==1,100,0)) %>% 
  select(district, dem_share, dem_win_pct)
district <- c(inc18$district, open18$district, conceded$district)
dem_share <- c(dem_share, conceded$dem_share)
dem_win_pct <- c(dem_win_pct, conceded$dem_win_pct)
forecast <- data.frame(district, dem_share, dem_win_pct)
forecast <- forecast[order(district),]
rownames(forecast) <- c()

seats <- table(posterior$dseats) %>% 
  as.data.frame() %>% 
  mutate(seats = Var1, prob = Freq/nrow(posterior)) %>% 
  select(seats,prob) %>%
  filter(prob >= 0.001)
rownames(seats) <- c()

write.csv(forecast, "district_forecast.csv")
write.csv(seats, "house_seats.csv")
