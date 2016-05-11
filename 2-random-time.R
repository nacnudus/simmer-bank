```
""" bank05: The single Random Customer """
from SimPy.Simulation import *
from random import expovariate, seed                     
from rpy2 import robjects

## Model components ------------------------           

class Customer(Process):
    """ Customer arrives at a random time,
        looks around and then leaves """
    
    def visit(self,timeInBank):       
        print now(), self.name," Here I am"             
        yield hold,self,timeInBank
        print now(), self.name," I must leave"          

## Experiment data -------------------------

maxTime = 100.0    # minutes                                    
timeInBank = 10.0

## Model/Experiment ------------------------------

r = robjects.r
r('set.seed(99999)')
initialize()
c = Customer(name = "Klaus")
t = r.rexp(1, 1.0/5)[0]
activate(c,c.visit(timeInBank),at=t)                 
simulate(until=maxTime)
```

# bank05: The single random customer
library(simmer)

## Experiment data ------------------------------

maxTime <- 100    # minutes                            
timeInBank <- 10  # minutes

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  timeout(function() {timeInBank}) 

## Model/Experiment ------------------------------

set.seed(99999)
bank <- simmer("bank")
bank %>% add_generator("Customer", customer, at(rexp(1, 1/5)))
bank %>% run(until = maxTime) 
bank %>% get_mon_arrivals
