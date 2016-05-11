```
""" bank10: Several Counters with individual queues"""
from SimPy.Simulation import *
from random import expovariate,seed

## Model components ------------------------

class Source(Process):
    """ Source generates customers randomly"""

    def generate(self,number,interval,counters):                   
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(counters))
            t = expovariate(1.0/interval)
            yield hold,self,t

def NoInSystem(R):                                                  
    """ Total number of customers in the resource R"""
    return (len(R.waitQ)+len(R.activeQ))                            

class Customer(Process):
    """ Customer arrives, chooses the shortest queue
        is served and leaves
    """
        
    def visit(self,counters):       
        arrive = now()
        Qlength = [NoInSystem(counters[i]) for i in range(Nc)]      
        print "%7.4f %s: Here I am. %s"%(now(),self.name,Qlength)   
        for i in range(Nc):                                         
            if Qlength[i] == 0 or Qlength[i] == min(Qlength):
                choice = i  # the chosen queue number                
                break
                
        yield request,self,counters[choice]
        wait = now()-arrive
        print "%7.4f %s: Waited %6.3f"%(now(),self.name,wait)
        tib = expovariate(1.0/timeInBank)
        yield hold,self,tib
        yield release,self,counters[choice]

        print "%7.4f %s: Finished"%(now(),self.name)

## Experiment data -------------------------

maxNumber = 5
maxTime = 400.0 # minutes                                     
timeInBank = 12.0 # mean, minutes                          
ARRint = 10.0   # mean, minutes                          
Nc = 2          # number of counters
theseed = 12345                                           
                                    
## Model/Experiment ------------------------------

seed(theseed)
kk = [Resource(name="Clerk0"),Resource(name="Clerk1")]   
initialize()    
s = Source('Source')
activate(s,s.generate(number=maxNumber,interval=ARRint,
                      counters=kk),at=0.0)
simulate(until=maxTime)
```

# bank10: Several counters with individual queues
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
    branch(function() {
             which.min(c(bank %>% get_server_count("counter1") +
                           bank %>% get_queue_count("counter1"),
                         bank %>% get_server_count("counter2") +
                           bank %>% get_queue_count("counter2")))
         },
         merge = rep(TRUE, 2),
         create_trajectory("branch1") %>%
           seize("counter1") %>%
           timeout(function() {rexp(1, 1/timeInBank)}) %>%
           release("counter1"),
         create_trajectory("branch2") %>%
           seize("counter2") %>%
           timeout(function() {rexp(1, 1/timeInBank)}) %>%
           release("counter2"))

# # This doesn't work:
# customer <- 
#   create_trajectory("Customer's path") %>%
#     set_attribute("counter",
#                   function() {
#                     which.min(c(bank %>% get_server_count("counter1") +
#                                   bank %>% get_queue_count("counter1"),
#                                 bank %>% get_server_count("counter2") +
#                                   bank %>% get_queue_count("counter2")))}) %>%
#     seize(function(attrs) {paste0("counter", attrs["counter"])}) %>%
#     timeout(function() {rexp(1, 1/timeInBank)}) %>%
#     release(function(attrs) {paste0("counter", attrs["counter"])})

## Model/Experiment ------------------------------

set.seed(theseed)
bank <- simmer("bank")
bank %>% 
  add_resource("counter1", 1) %>%
  add_resource("counter2", 1) %>%
  add_generator("Customer",
                customer, 
                at(c(0, cumsum(rexp(maxNumber - 1, 1/ARRint)))))
bank %>% run(until = maxTime)
bank %>% 
  get_mon_arrivals(per_resource = TRUE) %>%
  mutate(waiting_time = end_time - start_time - activity_time)
