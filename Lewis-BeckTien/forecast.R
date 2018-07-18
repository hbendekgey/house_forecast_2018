# Harry Bendekgey, house forecast based on Lewis-Beck and Tien

options(digits=5)

# parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
disapproval <- "disapproval" %in% args
approval <- "approval" %in% args
net_approval <- "net-approval" %in% args
set_rdi_growth <- "set-rdig" %in% args
set_approval <- "set-approval" %in% args
set_disapproval <- "set-disapproval" %in% args
only_structure <- "only-structure" %in% args
shift_pred <- "shift-pred" %in% args

if (length(args) != sum(disapproval, approval, net_approval,
                        2 * set_rdi_growth, 2 * set_approval,
                        2 * set_disapproval, only_structure,
                        shift_pred)) {
  stop("Invalid arguments")
}

if (sum(approval, disapproval, net_approval) > 1) {
  stop("Pick only one Presidential metric to regress on")
}

if (only_structure & shift_pred) {
  stop("Cannot shift prediction without expect half of the model")
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
rdi_growth <- parse_param(set_rdi_growth, "set-rdig", 1.47)
trump_app <- parse_param(set_approval, "set-approval", 42)
trump_dis <- parse_param(set_disapproval, "set-disapproval", 52) 
trump_net <- trump_app - trump_dis
trump_share <- trump_app/(trump_app+trump_dis) * 100 - 50

library(dplyr)
library(readr)
library(ggplot2)

set.seed(474747)
structurex <- read_csv("../data/structurex.csv") %>%
  mutate(pres_net = pres_app - pres_dis, pres_share = pres_app/(pres_app + pres_dis) * 100 - 50) %>%
  filter(year >= 1950)

if (approval) {
  fit <- lm(chiseats ~ midterm + rdi_growth + pres_app, data=structurex)
} else if (disapproval) {
  fit <- lm(chiseats ~ midterm + rdi_growth + pres_dis, data=structurex)
} else if (net_approval) {
  fit <- lm(chiseats ~ midterm + rdi_growth + pres_net, data=structurex)
} else {
  fit <- lm(chiseats ~ midterm + rdi_growth + pres_share, data=structurex)
}

params <- data.frame(rdi_growth=rdi_growth, pres_dis = trump_dis, 
                     midterm = 1, pres_app=trump_app, pres_net=trump_net, 
                     pres_share = trump_share)
interval <- predict.lm(fit, params, interval = "prediction", se.fit = TRUE, level=0.9)

if(only_structure) {
  t.cutoff <- qt(0.95, df=interval$df)
  se <- (interval$fit[1] - interval$fit[2])/t.cutoff
  dem_win_pct <- pt((-24-interval$fit[1])/se,df=interval$df)
  cat("Probability of Democrats taking house:", dem_win_pct * 100, "\n")
  cat("90% confidence interval for Democratic seats:", round(194 - interval$fit[2:3]), "\n")
  cat("Estimated number of seats:", round(194 - interval$fit[1]), "\n")
} else {
  structurex <- filter(structurex, year >= 2006)
  roth <- c(-31,-16,-64,17,2,46)
  structure <- fit$fitted.values[29:34]
  pred <- (structure + roth)/2
  actual <- structurex$chiseats
  sxpred <- data.frame(pred, actual)
  if (shift_pred) {
    comb_fit <- lm(actual ~ offset(1 *pred), data=sxpred) %>% summary()
    sigma <- comb_fit$sigma
    mu <- (interval$fit[1] - 59)/2 + comb_fit$coefficients[1,1]
  } else {
    comb_fit <- lm(actual ~ 0 + offset(1 *pred), data=sxpred) %>% summary()
    sigma <- comb_fit$sigma
    mu <- (interval$fit[1] - 59)/2
  }
  t.cutoff <- qt(0.95, df=6)
  dem_win_pct <- pt((-24-mu)/sigma,df=6)
  cat("Probability of Democrats taking house:", dem_win_pct * 100, "\n")
  cat("90% confidence interval for Democratic seats:", round(194 - mu - c(t.cutoff * sigma, -1 * t.cutoff * sigma)), "\n")
  cat("Estimated number of seats:", round(194 - mu), "\n")
}