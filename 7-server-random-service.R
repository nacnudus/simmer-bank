```
""" bank08: A counter with a random service time """
from SimPy.Simulation import *
from random import expovariate, seed

## Model components ------------------------           

class Source(Process):
    """ Source generates customers randomly """

    def generate(self,number,meanTBA,resource):         
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(b=resource))              
            t = r.rexp(1, 1.0/meanTBA)[0]
            yield hold,self,t

class Customer(Process):
    """ Customer arrives, is served and leaves """
        
    def visit(self,b):                                
        arrive = now()
        print "%8.4f %s: Here I am     "%(now(),self.name)
        yield request,self,b                          
        wait = now()-arrive
        print "%8.4f %s: Waited %6.3f"%(now(),self.name,wait)
        tib = expovariate(1.0/timeInBank)            
        yield hold,self,tib                          
        yield release,self,b                         
        print "%8.4f %s: Finished      "%(now(),self.name)

## Experiment data -------------------------         

maxNumber = 5
maxTime = 400.0 # minutes                                     
timeInBank=12.0 # mean, minutes                      
ARRint = 10.0   # mean, minutes                      
theseed= 12345                                       

## Model/Experiment ------------------------------

r('set.seed(' + str(theseed) + ')')
k = Resource(name="Counter",unitName="Clerk")       

initialize()
s = Source('Source')
activate(s,s.generate(number=maxNumber,meanTBA=ARRint, 
                      resource=k),at=0.0)           
simulate(until=maxTime)
```

# bank08: A counter with a random service time
library(simmer)
library(dplyr)

## Experiment data ------------------------------

maxNumber <- 5
maxTime <- 400   # minutes                            
timeInBank <- 12 # mean, minutes                            
ARRint <- 10     # mean, minutes
theseed <- 12345

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  seize("counter") %>%
  timeout(function() {rexp(1, 1/timeInBank)}) %>%
  release("counter")

## Model/Experiment ------------------------------

set.seed(theseed)
bank <- simmer("bank")
bank %>% 
  add_resource("counter") %>%
  add_generator("Customer",
                customer, 
                at(c(0, cumsum(rexp(maxNumber - 1, 1/ARRint)))))
bank %>% run(until = maxTime) 
bank %>% 
  get_mon_arrivals %>%
  mutate(waiting_time = end_time - start_time - activity_time)
