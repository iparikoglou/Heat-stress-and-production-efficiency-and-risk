
rm(list=ls())
set.seed(123456)
options(digits=3)
options(scipen=999)

library(stats)
library(base)
library(haven);
library(frontier);
library(dplyr);
library('stringr')
library('reshape2')
library('dplyr') 
library('rjags')
library('foreign')

# Load required packages
require("MASS");		# to sample from multivariate-Normal densities
require("coda");		# to summarize the draws from the posterior
require("R2jags");	# to call JAGS


dat <-    read_dta("dataset.dta")
dat$cons<-1

# Define the data matrices
indVarNames <- c(
  "cons", "log_Capital2", "log_Labour",   "log_LU",  "log_uaa" , "log_VCCHF" , "t", "logout2",#8
.... # rest of interaction terms for the translog specification
 "FARMCODE", "jahr",#38  # farm code and year
"cons", "THI", "age", "dens", "v_region", "h_region" ) #39-44
X <- as.matrix(dat[indVarNames]);
y <- as.matrix(dat["logout1"]);


# Dimensions of the data
N <- dim(X)[1];			# number of observations
K <- dim(X)[2]-8;			# number of independent variables
L <- max(dat["FARMCODE"]);
maxt <- max(dat["jahr"]);



names(dat)
 
 Deter<- read_dta("Deter Per.dta")  #persistent determinants of inefficiency and risk
 myvars <- c( "cons", "THI_TI", "age"  , "dens" ,  "valley" ,  "hill" , "FARMCODE"  )   #this is time invariant
 Per <- as.matrix(Deter[myvars]);

Nper <- dim(Per)[1];			
Kper <- dim(Per)[2]-1;		

J<-6

# THESE ARE THE PRIORS: See appendfix of the paper
# BETAS
m <- matrix(rep(0,K),K,1);
P <-0.01*diag(K);
m_a <- matrix(rep(0,L),L,1);

atau <-0.001;
btau <-0.001;

# priors for efficiency and risk:  
altrans<-1
bltrans<- -log(0.85);
alpers<-1
blpers<- -log(0.85);

 mtran <-  
Ptran <- 
 mpers <-  
 Ppers  <- 
 
 mriskt <- 
 Priskt <- 
 mriskp <-  
 Priskp  <- 

rm(indVarNames, myvars, deter)#, Tran1 
# data for jags, data & param
data <- list("y"=y, "X"=X,  "N"=N,   "K"=K, "L"=L,  
             "m"=m, "P"=P,     "atau"=atau, "btau"=btau,  
             "mpers"= mpers , "Ppers"=  Ppers, 
             "mtran"= mtran , "Ptran"=  Ptran, 
             "Per"=Per,   "Kper"=Kper,
             "mriskt"=mriskt,   "Priskt"=Priskt,
             "mriskp"=mriskp,   "Priskp"=Priskp );   

inits <- NULL;
parameters <- c("beta", "sigmasq", "tau", "tau_a", "meanTE", "meanLRTE", "transeff", "perseff",   "riskp",     "riskt");
model = paste("model.txt");

# Set the values of the Gibbs-sampler parameters to be used later on
burnin <-120000;		# number of burnin draws
draws <- 120000;		# number of retained draws
inits <- NULL;


GTRE<- jags( data, inits, parameters,
                      model.file=model,
                      n.burnin=burnin, n.iter=burnin+draws, 
             n.chains=1, n.thin=10 );
