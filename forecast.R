# Harry Bendekgey, house forecast based on Bafumi, Erikson, Wlezien

# parse command-line arguments

args <- commandArgs(trailingOnly = TRUE)

print(args)

#if ("PA-inc" %in% args) {
#  print("bla")
#}


library(dplyr)
library(readr)
library(ggplot2)
library(gtools)
library(rstan)

# explanation for the following values can be found in the rnw/pdf files. 
# because I am not allowing these numbers to be altered for now, they are fixed
expswing <- 4.493
sdswing <- 1.842
dfswing <- 15

cd2018data <- read_csv("data/cd2018data.csv")
Dconcede <- cd2018data %>% filter(concede == 1) %>% nrow() 
Rconcede <- cd2018data %>% filter(concede == -1) %>% nrow()

open18 <- filter(cd2018data, concede == 0, incumbent18 == 0)
inc18 <- filter(cd2018data, concede == 0, incumbent18 != 0)

dvacate <- open18 %>% filter(incumbent16 == 1) %>% nrow()
rvacate <- open18 %>% filter(incumbent16 == -1) %>% nrow()

openint <- mean(open18$dem16share) - 0.95 * mean(open18$pres16share) 

inc18 <- mutate(inc18, frosh = incumbent18 * (incumbent16 != incumbent18))
incint <- mean(inc18$dem16share) - mean(0.63 * inc18$dem16share + 0.46 * inc18$pres16share + 2.03 * inc18$frosh) #- 2.03 * (rvacate - dvacate) / nrow(open18)

# expectations if national swing is even
open18 <- mutate(open18, exp18 = openint + 0.95 * pres16share) 
inc18 <- mutate(inc18, exp18 = incint + 0.63 * dem16share + 0.46 * pres16share + 2.03 * frosh)

incvar <- 4.053
openvar <- 6.133

housedat <- list(I = nrow(inc18),
                 J = nrow(open18),
                 D = Dconcede,
                 R = Rconcede,
                 expswing = expswing,
                 sdswing = sdswing,
                 dfswing = dfswing,
                 expI = inc18$exp18,
                 expJ = open18$exp18,
                 sdI = 4.0,
                 sdJ = 6.2)

cores <- parallel::detectCores() - 1 
options(mc.cores = cores)

fit <- stan(file = 'houseforecast.stan', data = housedat, 
            iter=11000, warmup=1000, chains=cores, seed=483892929)
posterior <- as.matrix(fit) %>% data.frame()

print(sum(posterior$dseats > 217) / nrow(posterior))