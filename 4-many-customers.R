```
""" bank03: Many non-random Customers """
from SimPy.Simulation import *

## Model components ------------------------

class Source(Process):                              
    """ Source generates customers regularly """

    def generate(self,number,TBA):                  
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(timeInBank=12.0))
            yield hold,self,TBA                     

class Customer(Process):
    """ Customer arrives, looks around and leaves """
        
    def visit(self,timeInBank):       
        print "%7.4f %s: Here I am"%(now(),self.name)
        yield hold,self,timeInBank
        print "%7.4f %s: I must leave"%(now(),self.name)

## Experiment data -------------------------

maxNumber = 5
maxTime = 400.0 # minutes                                    
ARRint = 10.0   # time between arrivals, minutes 

## Model/Experiment ------------------------------

initialize()
s = Source()                                             
activate(s,s.generate(number=maxNumber,                   
                      TBA=ARRint),at=0.0)             
simulate(until=maxTime)
```

# bank03: Many non-random customers
library(simmer)

## Experiment data ------------------------------

maxNumber <- 5
maxTime <- 400 # minutes                            
ARRint <- 10   # time between arrivals, minutes

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  timeout(function() {12}) 

## Model/Experiment ------------------------------

bank <- simmer("bank")
bank %>% add_generator("Customer",
                       customer, 
                       # every_n_from(ARRint, from = 0, n = 5)) 
                       at(cumsum(c(0, rep(ARRint, maxNumber - 1)))))
bank %>% run(until = maxTime) 
bank %>% get_mon_arrivals
