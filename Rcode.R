
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
"log_KK2", "log_KL2"  , "log_KS2" , "log_KA2", "log_KVC2" ,             
 "log_LL" ,  "log_LS" ,  "log_LA"  ,  "log_LVC" ,                         
  "log_AA" , "log_AS" , "log_AVC" , 
"log_VCVC" ,"log_SVC" ,
"log_SS",                   #23
"tt" ,  "log_tK2" , "log_tL" ,  "log_tA", "log_tVC" , "log_tS" ,     #29         
 "logout2logout2" , "logout2t" , "logout2K2" ,"logout2L", "logout2A" ,"logout2VC" ,"logout2S" ,#36
 "FARMCODE", "jahr",#38
"cons", "log_THI", "logage", "logdens", "v_region", "h_region" ) #39-44
X <- as.matrix(dat[indVarNames]);
y <- as.matrix(dat["logout1"]);


# Dimensions of the data
N <- dim(X)[1];			# number of observations
K <- dim(X)[2]-8;			# number of independent variables
L <- max(dat["FARMCODE"]);
maxt <- max(dat["jahr"]);

m <- matrix(rep(0,K),K,1);
P <-0.01*diag(K);
m_a <- matrix(rep(0,L),L,1);

atau <-0.001;
btau <-0.001;
  
altrans<-1
bltrans<- -log(0.85);
alpers<-1
blpers<- -log(0.85);

names(dat)

myvars <- c("cons", "log_THI_TI",  "FARMCODE"  ) 
deter <- dat[myvars]
pertoo<- unique( deter[ , 1:3 ] )
 
 Deter<- read_dta("/Users/ip/Desktop/FinalRobustness18.06/K L LU A M dataset 4b Per.dta")
 names(Deter)

 total <- merge(Deter,pertoo,by="FARMCODE")
 names(total)   #"log_THI",     "logage", "logdens", "v_region", "h_region"
 myvars <- c( "cons", "log_THI_TI", "logage"  , "logdens" ,  "valley" ,  "hill" , "FARMCODE"  ) 
 Per<- total[myvars]
Nper <- dim(Per)[1];			
Kper <- dim(Per)[2]-1;		

J<-6
 mtran <- matrix(rep(0,J),J,1);
Ptran <-10*diag(J);
 mpers <- matrix(rep(0,Kper),Kper,1);
 Ppers  <-10*diag(Kper);
 
 mriskt <- matrix(rep(0,J),J,1);
 Priskt <-10*diag(J);
 mriskp <- matrix(rep(0,Kper),Kper,1);
 Priskp  <-10*diag(Kper);

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
draws <- 100000;		# number of retained draws
inits <- NULL;


GTRE<- jags( data, inits, parameters,
                      model.file=model,
                      n.burnin=burnin, n.iter=burnin+draws, 
             n.chains=1, n.thin=10 );
