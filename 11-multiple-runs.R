```
""" bank12: Multiple runs of the bank with a Monitor""" 
from SimPy.Simulation import * 
from random import expovariate,seed

## Model components ------------------------

class Source(Process):
    """ Source generates customers randomly"""

    def generate(self,number,interval,resource,mon):       
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(b=resource,M=mon))          
            t = expovariate(1.0/interval)
            yield hold,self,t

class Customer(Process):
    """ Customer arrives, is served and leaves """
        
    def visit(self,b,M):       
        arrive = now()
        yield request,self,b
        wait = now()-arrive
        M.observe(wait)                                
        tib = expovariate(1.0/timeInBank)
        yield hold,self,tib
        yield release,self,b
 
## Experiment data -------------------------

maxNumber <- 50
maxTime <- 1000  # minutes                            
timeInBank <- 12 # mean, minutes                            
ARRint <- 10     # mean, minutes
theseed <- 12345

## Model  ----------------------------------

def model(runSeed=theSeed):                            
    seed(runSeed)
    k = Resource(capacity=Nc,name="Clerk")  
    wM = Monitor()                                   

    initialize()
    s = Source('Source')
    activate(s,s.generate(number=maxNumber,interval=ARRint, 
                          resource=k,mon=wM),at=0.0)         
    simulate(until=maxTime)
    return (wM.count(),wM.mean())                     

## Experiment/Result  ----------------------------------

theseeds = [393939,31555999,777999555,319999771]         
for Sd in theseeds:
    result = model(Sd)
    print "Average wait for %3d completions was %6.2f minutes."% result 
```

# bank12: Multiple runs of the bank with a Monitor
library(simmer)
library(dplyr)

## Experiment data ------------------------------

maxNumber <- 50
maxTime <- 1000  # minutes                            
timeInBank <- 12 # mean, minutes                            
ARRint <- 10     # mean, minutes

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  seize("counter") %>%
  timeout(function() {rexp(1, 1/timeInBank)}) %>%
  release("counter")

## Model/Experiment ------------------------------

library(parallel)

mclapply(c(393939,31555999,777999555,319999771), function(theseed) {
  set.seed(theseed)
  bank <- simmer("bank")
  bank %>%
    add_resource("counter", 2) %>%
    add_generator("Customer",
                  customer,
                  at(c(0, cumsum(rexp(maxNumber - 1, 1/ARRint)))))
  bank %>% run(until = maxTime)
  result <-
    bank %>% 
    get_mon_arrivals %>%
    mutate(waiting_time = end_time - start_time - activity_time)
  paste("Average wait for ", sum(result$finished), " completions was ",
        mean(result$waiting_time), "minutes.")
})
