```
"""bank15: Monitoring a Resource"""
from SimPy.Simulation import *
from random import expovariate,seed

## Model components ------------------------

class Source(Process):                                        
    """ Source generates customers randomly"""
    def generate(self,number,rate):       
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(timeInBank=12.0))
            yield hold,self,expovariate(rate)

class Customer(Process):                                      
    """ Customer arrives, is served and leaves """
    def visit(self,timeInBank):       
        arrive = now()
        print "%8.4f %s: Arrived     "%(now(),self.name)

        yield request,self,counter
        print "%8.4f %s: Got counter "%(now(),self.name)
        tib = expovariate(1.0/timeInBank)
        yield hold,self,tib
        yield release,self,counter

        print "%8.4f %s: Finished    "%(now(),self.name)

## Experiment data -------------------------

maxTime = 400.0    # minutes                                     
counter = Resource(1,name="Clerk",monitored=True)            

## Model  ----------------------------------

def model(SEED=393939):
    seed(SEED)

    initialize()
    source = Source()                                                         
    activate(source,
             source.generate(number=5,rate=0.1),at=0.0)    
    simulate(until=maxTime)

    return (counter.waitMon.timeAverage(),counter.actMon.timeAverage()) 

## Experiment  ----------------------------------

print 'Average waiting = %6.4f\nAverage active  = %6.4f\n'%model() 
```

### bank15: Monitoring a Resource
library(simmer)
library(dplyr)
library(ggplot2)

## Experiment data -------------------------

maxTime = 400   # The value actually used by the python model (rather than the variable)

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  seize("counter") %>%
  timeout(12) %>%
  release("counter")

## Model/Experiment ------------------------------

set.seed(393939)
bank <- simmer("bank")
bank %>% 
  add_resource("counter") %>%
  add_generator("Customer",
                customer, 
                at(c(0, cumsum(rexp(20 - 1, 0.1)))))
bank %>% run(until = maxTime)
bank %>% 
  get_mon_resources %>%
  mutate(duration = lead(time) - time) %>%
  summarise(avg_queue_length = sum(queue * duration, na.rm = TRUE) / sum(duration, na.rm = TRUE))
