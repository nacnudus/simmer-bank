```
""" bank06: Many Random Customers """
from SimPy.Simulation import *
from random import expovariate,seed            

## Model components ------------------------

class Source(Process):
    """ Source generates customers at random """

    def generate(self,number,meanTBA):       
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(timeInBank=12.0)) 
            t = r.rexp(1, 1.0/meanTBA)[0]
            yield hold,self,t                  

class Customer(Process):
    """ Customer arrives, looks around and leaves """
        
    def visit(self,timeInBank=0):       
        print "%7.4f %s: Here I am"%(now(),self.name)
        yield hold,self,timeInBank
        print "%7.4f %s: I must leave"%(now(),self.name)

## Experiment data -------------------------

maxNumber = 5
maxTime = 400.0 # minutes                                   
ARRint = 10.0   # mean arrival interval, minutes  

## Model/Experiment ------------------------------

r('set.seed(99999)')
initialize()
s = Source(name='Source')                      
activate(s,s.generate(number=maxNumber,
                      meanTBA=ARRint),at=0.0)  
simulate(until=maxTime)
```

# bank06: Many non-random customers
library(simmer)

## Experiment data ------------------------------

maxNumber <- 5
maxTime <- 400 # minutes                            
ARRint <- 10   # mean arrival interval, minutes  

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  timeout(function() {12})

## Model/Experiment ------------------------------

set.seed(99999)
bank <- simmer("bank")
bank %>% add_generator("Customer",
                       customer,
                       at(c(0, cumsum(rexp(maxNumber - 1, 1/ARRint)))))
bank %>% run(until = maxTime)
bank %>% get_mon_arrivals
