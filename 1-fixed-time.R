```python
""" bank01: The single non-random Customer """           
from SimPy.Simulation import *                           

## Model components -----------------------------        

class Customer(Process):                                 
    """ Customer arrives, looks around and leaves """
        
    def visit(self,timeInBank):                          
        print now(),self.name," Here I am"               
        yield hold,self,timeInBank                       
        print now(),self.name," I must leave"            

## Experiment data ------------------------------

maxTime = 100.0     # minutes                            
timeInBank = 10.0   # minutes

## Model/Experiment ------------------------------

initialize()                                             
c = Customer(name="Klaus")                               
activate(c,c.visit(timeInBank),at=5.0)                   
simulate(until=maxTime)   
```

# bank01: The single non-random customer
library(simmer)

## Experiment data ------------------------------

maxTime <- 100     # minutes                            
timeInBank <- 10   # minutes

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  timeout(function() {timeInBank}) 

## Model/Experiment ------------------------------

bank <- simmer("bank")
bank %>% add_generator("Customer", customer, at(5))
bank %>% run(until = maxTime) 
bank %>% get_mon_arrivals
