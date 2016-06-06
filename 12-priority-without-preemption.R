```
""" bank20: One counter with a priority customer """
from SimPy.Simulation import *
from random import expovariate, seed

## Model components ------------------------

class Source(Process):
    """ Source generates customers randomly """

    def generate(self,number,interval,resource):       
        for i in range(number):
            c = Customer(name = "Customer%02d"%(i,))
            activate(c,c.visit(timeInBank=12.0,
                               res=resource,P=0))           
            t = expovariate(1.0/interval)
            yield hold,self,t

class Customer(Process):
    """ Customer arrives, is served and  leaves """
        
    def visit(self,timeInBank=0,res=None,P=0):              
        arrive = now()       # arrival time                 
        Nwaiting = len(res.waitQ)
        print "%8.3f %s: Queue is %d on arrival"%(now(),self.name,Nwaiting)

        yield request,self,res,P                            
        wait = now()-arrive  # waiting time                 
        print "%8.3f %s: Waited %6.3f"%(now(),self.name,wait)
        yield hold,self,timeInBank
        yield release,self,res                              

        print "%8.3f %s: Completed"%(now(),self.name)

## Experiment data -------------------------

maxTime = 400.0  # minutes                                
k = Resource(name="Counter",unitName="Karen",               
             qType=PriorityQ)                               

## Model/Experiment ------------------------------
seed(98989)
initialize()
s = Source('Source')
activate(s,s.generate(number=5, interval=10.0,              
                      resource=k),at=0.0)                   
guido = Customer(name="Guido     ")                         
activate(guido,guido.visit(timeInBank=12.0,res=k,
                           P=100),at=23.0)                  
simulate(until=maxTime)
```

# bank20: One counter with a priority customer
library(simmer)
library(dplyr)

## Experiment data ------------------------------

maxTime <- 400  # minutes                            
theseed <- 34567

## Model components -----------------------------        

customer <- 
  create_trajectory("Customer's path") %>%
  seize("counter") %>%
  timeout(function() {rexp(1, 1/10)}) %>%
  release("counter")
guido <- 
  create_trajectory("Customer's path") %>%
  seize("counter", priority = 1, preemptible = 1) %>%
  timeout(function() {rexp(1, 1/12)}) %>%
  release("counter")

## Model/Experiment ------------------------------

set.seed(02345)
bank <- simmer("bank")
bank %>% 
  add_resource("counter",  preemptive = FALSE) %>%
  add_generator("Customer",
                customer, 
                at(seq(0, by = 10, length.out = 5))) %>%
  add_generator("Guido",
                guido,
                at(23))
bank %>% run(until = maxTime)
bank %>% 
  get_mon_arrivals %>%
  mutate(waiting_time = end_time - start_time - activity_time)
# At time=10 Customer2 arrived at a busy server, with Customer1 ahead in the queue.
# At time=22.14623 the Customer1 began being served, so Customer2 reached
# the front of the queue.
# At time=23 Guido0 arrived.
# At time=50.89759, Customer1 finished being served, and Guido0 began being
# served, ahead of Customer2, who had arrived before Guido0.
# At time=61.66212, Guido0 finished being served, and Customer2 finally began
# being served.
# Hence Customer2's waiting time is 2.146226 (time remaining of Customer0's
# service on arrival) +28.751359 (whole of Customer1's service) +10.764531
# (whole of Guido0's service) = 41.66212.
