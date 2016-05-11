```
""" bank02: More Customers """
from SimPy.Simulation import *

## Model components ------------------------             

class Customer(Process):
    """ Customer arrives, looks around and leaves """
        
    def visit(self,timeInBank):       
        print "%7.4f %s: Here I am"%(now(),self.name)   
        yield hold,self,timeInBank
        print "%7.4f %s: I must leave"%(now(),self.name) 

## Experiment data -------------------------

maxTime = 400.0  # minutes                             

## Model/Experiment ------------------------------

initialize()

c1 = Customer(name="Klaus")                              
activate(c1,c1.visit(timeInBank=10.0),at=5.0)
c2 = Customer(name="Tony")
activate(c2,c2.visit(timeInBank=7.0),at=2.0)
c3 = Customer(name="Evelyn")
activate(c3,c3.visit(timeInBank=20.0),at=12.0)         

simulate(until=maxTime)    
```

# bank02: More customers 
library(simmer)

## Experiment data ------------------------------

maxTime <- 400  # minutes                            

## Model components -----------------------------        

# We need a function to set different timeouts for each customer.  The function
# `simmer::every()` happens to do what we need.

customer <- 
  create_trajectory("Customer's path") %>%
  timeout(every(10, 7, 20)) 

## Model/Experiment ------------------------------

bank <- simmer("bank")
bank %>% add_generator("Customer", customer, at(2, 5, 12)) # contents of at() must be ordered
bank %>% run(until = maxTime) 
bank %>% get_mon_arrivals

