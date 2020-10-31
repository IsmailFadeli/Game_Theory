globals
[
  depreciation
]

turtles-own
[

  age-remaining
  wealth
  current-asset
  income
  living-cost
  ability-to-buy
  probability-to-buy
  utility-of-buying-a-car
  own-car
  car-cost
  current-car-value
  risk-buy
  risk-sell
]


;; Initialization
to setup
  clear-all                                              ;; clear the world

  set depreciation 0.9                                   ;; set depreciation value of car

  ask patches
  [
    set pcolor grey
    sprout 1                                             ;; create turtles on every patch
  ]


  ask turtles
  [
    set age-remaining (10 + random 60)
    set risk-buy 1.5                                     ;; set turtles braveness of taking risk to buy a car
    set risk-sell precision random-float 1.0 2           ;; set turtles braveness of taking risk to sell her car
    set current-asset precision random-float 1.0 2       ;; set turtles asset [0,1]
    set living-cost precision random-float 1.0 2
    set wealth current-asset
    set income precision (random-float 1.0) 2            ;; set turtles income [0,1] uniformly distributed
    set own-car 0                                        ;; all turtles do not have car in the beginning
    display-agent
  ]

  reset-ticks
end


;; Start Simulation
to go
  if ticks >= 300 [ stop]
  ask turtles
  [
    ifelse (own-car = 1)
    [
      ifelse (current-car-value < risk-sell * buy-price )
      [ sell-car]
      [ keep-car]
    ]

    [
      let average-asset ((sum [current-asset] of turtles-on neighbors + current-asset) / (count turtles-on neighbors + 1))
      set ability-to-buy (current-asset - risk-buy * buy-price)
      set probability-to-buy (1 - exp (- (current-asset - average-asset)))
      ifelse probability-to-buy < 0
      [ set probability-to-buy 0]
      [ set probability-to-buy probability-to-buy]
      set utility-of-buying-a-car ability-to-buy * probability-to-buy

      ifelse (utility-of-buying-a-car < threshold)                 ;; threshold = utility of not buying a car i.e utility of using public transportation
      [ use-public-transport]
      [ buy-car]
    ]

    set age-remaining (age-remaining - 1)
    if (wealth <= fare) or (age-remaining <= 0)
    [
      ;; agent died and new agent is born i.e reset agent properties
      set age-remaining (10 + random 60)
      set risk-sell precision random-float 1.0 2
      set current-asset precision random-float 1.0 2
      set living-cost precision random-float 1.0 2
      set wealth current-asset
      set income precision (random-float 1.0) 2
      set own-car 0
    ]
  ]
  ask turtles [display-agent]
  tick
end

to sell-car
  set own-car own-car - 1
  let sell-price (0.1 + random-float 0.61) * buy-price
  set wealth (current-asset + sell-price - current-car-value)
  set current-asset (current-asset + income + sell-price - living-cost)
  set current-car-value ""
end

to keep-car
  set own-car own-car
  set current-car-value (depreciation * current-car-value)
  set wealth current-asset + current-car-value
  set current-asset (current-asset + income - car-cost - living-cost)
end

to use-public-transport
  set own-car own-car
  set wealth current-asset
  set current-asset (current-asset + income - fare - living-cost)
end

to buy-car
  set own-car own-car + 1
  set current-car-value (depreciation * buy-price)
  set wealth (current-asset + current-car-value)
  set car-cost 0.3 * buy-price
  set current-asset (current-asset + income - buy-price - living-cost)
end


to display-agent
  set shape "circle"
  set size 1

  ifelse (own-car = 1)
  [ set color 94]
  [ ifelse (current-asset < fare)
    [set color 98]
    [set color 96]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
975
10
1263
299
-1
-1
4.6
1
10
1
1
1
0
1
1
1
-30
30
-30
30
1
1
1
ticks
30.0

BUTTON
15
20
152
53
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
15
55
150
88
Go Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
15
90
150
123
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
160
20
332
53
fare
fare
0
0.99
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
160
55
332
88
buy-price
buy-price
0
5
3.0
0.1
1
NIL
HORIZONTAL

PLOT
0
245
245
445
Distribution of Agents
Time
Number of Agents
0.0
300.0
0.0
100.0
true
true
"" ""
PENS
"Car" 1.0 0 -14454117 true "" "plot count turtles with [own-car = 1]"
"Public" 1.0 0 -11033397 true "" "plot count turtles with [own-car = 0 and wealth > fare]"

MONITOR
5
450
117
503
Number of cars
count turtles with [own-car = 1]
0
1
13

MONITOR
80
450
202
503
Number of public
count turtles with [own-car = 0 and wealth > fare]
0
1
13

PLOT
250
245
470
445
Mode Profile
Time
Profile
0.0
300.0
0.0
5.0
true
true
"" ""
PENS
"Car" 1.0 0 -4699768 true "" "ifelse (count turtles with [own-car = 1] = 0)\n[plot 0]\n[plot mean [wealth] of turtles with [own-car = 1]]"
"Public" 1.0 0 -612749 true "" "plot mean [wealth] of turtles with [own-car = 0 and wealth > fare]"

MONITOR
250
450
354
503
Car Profile
mean [wealth] of turtles with [own-car = 1]
3
1
13

MONITOR
370
449
467
502
Public Profile
mean [wealth] of turtles with [own-car = 0 and wealth > fare]
3
1
13

SLIDER
160
90
332
123
threshold
threshold
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
380
15
552
48
bus_fare
bus_fare
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
380
75
462
120
Total agents
count turtles with [own-car = 0 and wealth > fare] + count turtles with [own-car = 1]
17
1
11

PLOT
490
245
690
445
Public Transport Strategists
NIL
NIL
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count turtles with [own-car = 0 and wealth > fare])/((count turtles with [own-car = 0 and wealth > fare])+(count turtles with [own-car = 1]))"

PLOT
700
245
910
445
Car strategists Proportions
NIL
NIL
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count turtles with [own-car = 1])/((count turtles with [own-car = 0 and wealth > fare])+(count turtles with [own-car = 1]))"

@#$#@#$#@
## ABOUT THE MODEL

This is a transport mode choice behavior. The idea is simple. It is evident that public transportations are developed to reduce transport cost, which in result generates additional income for the user (agents). The interesting part of this phenomenon is what do agents do with the additional income? 

Common mode-choice models developed under the assumption that one will behave rationally to maximize her utility. We argued that this model failed to address two key factors: additional income and local interaction. It is evident that most, if not all, public transportation aims to reduce transport cost, which in result generates additional income. Moreover, the use of additional income is highly affected by agent’s social interaction and, obviously, people interacts with each other within their social networks. Therefore, the possible existence of a phase in which people purchase automobile because of the additional income and social prestige is an attractive proposition. In simpler words, there is a long-term effect that public transportation could actually become the cause of traffic congestion.

This model is an agent-based model of artificial agents who lives in an artificial world of patches. Each agent occupies a single patch and interact with theier neighbors. They will then update their state, either purchasing a car or using public transportation, according to a probability function. The higher the difference between an agent’s wealth to her neighbors’, the higher the probability of the agent to purchase a car. 


## MODEL OUTPUT

Our model suggests that transportation system is an ever-moving system of three states: transit-oriented, automobile-oriented, and equilibrium. Moreover, the model also shows inverse relation between the state of the system and its social implications. Transit-oriented system is widely known to favor the poor over the rich. However, our model shows that by favoring the poor, it encourages people to view automobile much more prestigious than public transport. Therefore, prestige-driven behavior emerged, hence automobile-oriented system arises. Additionally, the model could also be viewed as a generalized form of the conventional model. The model shows that rational behavior and utility maximization only occurs when purchasing automobiles is considered costly, thus, functionality and degree of necessity becomes critical.

**NOTE:**
To produce this output, you need to use the _Behavior Space_ from the _Tools_ option. 

> What needs to be done:
>
>  - set FARE = 0
>  - set THRESHOLD = 0
>  - vary BUY-PRICE from 0.0 to 5.0 (actually, there is nothing interesting happening from BUY-PRICE >= 3.5)
>  - set REPETITION = 100
>  - compute average value for each output:
>     - number of turtles who buy a car
>     - number of turtles who use public transportation
>     - car profile
>     - public transportation profile
>  - plot in a graph (I suggest you to make two graphs)
>     - BUY-PRICE (x-axis) vs number of turtles who buy a car (y-axis-1) and number of turtles who use public transportation (y-axis-2)
>     - BUY-PRICE (x-axis) vs car profile (y-axis-1) and public transportation profile (y-axis-2)


## MODEL PROPERTIES

Each agent has these properties

> **FARE**    				= the cost of using public transport mode
> **DEPRECIATION**			= the decline of the value of a car over time
> **THRESHOLD**				= perceived utility of using public transport mode
> **AGE-REMAINING**			= agent's remaining life
> **RISK-BUY**				= agent's risk aversion of buying a car
> **RISK-SELL**				= agent's tolerance toward selling her car
> **CURRENT-ASSET**			= agent's asset at time t (excluding car ownership)
> **LIVING-COST**			= agent's average cost of living
> **INCOME**				= agent's average income
> **WEALTH**				= agent's total economic asset (including car ownership)
> **OWN-CAR**				= agent's car ownership
> **ABILITY-TO-BUY**			= agent's ability to purchase a new car
> **PROBABILITY-TO-BUY**		= agent's probability to buy a new car
> **AVERAGE-ASSET**			= average asset value of agent's neighbors (including the agent itself). Imagine the agent ask herself "What kind of pattern emerged if I live in this neighborhood?"
> **UTILITY-OF-BUYING-A-CAR**		= perceived benefit of buying and/or having a car



## THE BASIC IDEA OF THE MODEL

The basic rule is agents will have to choose between using public transportation or buying an automobile which is as follows:
>**if** expected utility of purchasing a car is less than the perceived utility of using public transportation **then** use public transportation, **otherwise** purchase a car


## MODEL INITIALIZATION (SETUP PROCEDURE)

First, in the initialization (Setup), we create the environment (world), the agents, and its properties:

**Step 1** set world wraps vertically and horizontally
**Step 2** set global variables

> ```
> set depreciation 0.9
> ```

**Step 3** set patches pcolor to grey

> ```
> ask patches [ set pcolor grey]
> ```

**Step 4** sprout one agent in every patch

> ```
> ask patches [ sprout 1]
> ```

**Step 5** set agents' properties

> ```
> ask turtles [ 
>   set age-remaining (10 + random 60)
>   set risk-buy 1.5                          
>   set risk-sell precision random-float 1.0 2 
>   set current-asset precision random-float 1.0 2       
>   set living-cost precision random-float 1.0 2
>   set wealth current-asset
>   set income precision (random-float 1.0) 2            
>   set own-car 0]]
> ```

**Step 6** display agent

> ```
> ask turtles [
>   set shape "circle"
>   set size 1
>
>   ifelse (own-car = 1)
>   [ set color 94]
>   [ ifelse (current-asset < fare)
>     [set color 98]
>     [set color 96]]
> ```

## INTERACTION RULES AND ITERATION PROCESS (GO PROCEDURE)

After we initialize all the components of the model, then we setup the interaction rules (Go):

**Step 1** set maximum iteration at TICKS = 300

> ```
> if ticks >= 300 [ stop]  
> ```

**Step 2** if the Agent already have a car (depends randomly on the initialization), she will have to decide if she wants to keep the car or sell the car

> ```
> ifelse (CURRENT-CAR-VALUE < RISK-SELL * BUY-PRICE)[
>   [ sell-car]
>   [ keep-car]]
> ```

**Step 2.a** if she decided to sell her car (sell-car)

> ```
> set OWN-CAR OWN-CAR - 1
>   let SELL-PRICE (0.1 + random-float 0.61) * BUY-PRICE
>   set WEALTH (CURRENT-ASSET + SELL-PRICE - CURRENT-CAR-VALUE)
>   set CURRENT-ASSET (CURRENT-ASSET + INCOME + SELL-PRICE - LIVING-COST)
>   set CURRENT-CAR-VALUE ""
> ```

**Step 2.B** if she decided to keep her car (keep-car)

> ```
> set OWN-CAR OWN-CAR
>   set CURRENT-CAR-VALUE (DEPRECIATION * CURRENT-CAR-VALUE)
>   set WEALTH CURRENT-ASSET + CURRENT-CAR-VALUE
>   set CURRENT-ASSET (CURRENT-ASSET + INCOME - CAR-COST - LIVING-COST)
> ```


**Step 3** if the agent does not have a car (depends randomly on the initialization) then she will have to decide whether she wants to use the public transportation or buy a car

> ```
> set ABILITY-TO-BUY CURRENT-ASSET RISK-BUY * BUY-PRICE
> ```


**Step 3.a** compute her ability to buy a car

> ```
> set ABILITY-TO-BUY CURRENT-ASSET RISK-BUY * BUY-PRICE
> ```

**Step 3.b** compute her probability to buy a car

> ```
> set PROBABILITY-TO-BUY 1 - exp (- (CURRENT-ASSET - AVERAGE-ASSET))
> ```

**Step 3.c** compute her expected utility of purchasing a car

> ```
> set UTILITY-OF-BUYING-A-CAR ABILITY-TO-BUY * PROBABILITY-TO-BUY
> ```

**Step 3.d** compare her expected utility of purchasing a car with the perceived utility of using public transportation and update her state

> ```
> ifelse (UTILITY-OF-BUYING-A-CAR < THRESHOLD) [
>   [ use-public-transport]
>   [ buy-car]]
> ```

**Step 3.d.1** if she decided to use public transportation (use-public-transport)

> ```
> set OWN-CAR OWN-CAR
>   set WEALTH CURRENT-ASSET
>   set CURRENT-ASSET (CURRENT-ASSET + INCOME - PUBLIC-TRANSPORT-FARE - LIVING-COST)
> ```

**Step 3.d.2** if she decided to buy a car (buy-car)

> ```  
> set OWN-CAR OWN-CAR + 1
>   set CURRENT-CAR-VALUE (DEPRECIATION * BUY-PRICE)
>   set WEALTH (CURRENT-ASSET + CURRENT-CAR-VALUE)
>   set CAR-COST 0.3 * BUY-PRICE
>   set CURRENT-ASSET (CURRENT-ASSET + INCOME - BUY-PRICE - LIVING-COST)
> ```

**Step 4** display agents

**Step 5** update agent's life

> ```
> set AGE-REMAINING AGE-REMAINING - 1
>   if (WEALTH <= FARE) or (AGE-REMAINING <= 0) [
>   [ reset agent properties]
> ```


## HOW TO USE IT

The FARE slider controls how much an agent should pay to use a public transportation mode
The BUY-PRICE slider controls how much an agent should pay to purchase a new car
The THRESHOLD slider controls the critical point of agent's decision making by comparing agent's UTILITY-OF-BUYING-A-CAR to the THRESHOLD value. A value of UTILITY-OF-BUYING-A-CAR less than THRESHOLD will result in agent buying a car and a value of UTILITY-OF-BUYING-A-CAR greater than or equal to THRESHOLD will result in agent using public transportation.
The # OF CAR monitor shows how many of agents buy a car
The # OF PUBLIC monitor shows how many of agents use public transportation
CAR PROFILE monitor shows the prestige value of buying a car
PUBLIC PROFILE monitor shows the prestige value of using public transportation


## THINGS TO NOTICE

With parameters FARE and THRESHOLD fixed at 0, there is two critical value of BUY-PRICE that switches the state of the system.

  - BUY-PRICE approximately at 0.4 marks the system changing from public transport dominant to car user dominant
  - BUY-PRICE approximately at 2.5 marks the system changing from car user dominant to public transport dominant


## THINGS TO TRY

Try to vary the parameters (FARE, BUY-PRICE, THRESHOLD) using the sliders to see different simulation results


## CREDITS AND REFERENCES

The PROBABILITY-TO-BUY function is adopted from Modeling Civil Violence: An Agent-based computational approach (Epstein, 2002) which also accesible in Rebellion.nlogo in the _Models Library_ 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="fare">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buy-price">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="public transport" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>(count turtles with [own-car = 0 and wealth &gt; fare])/((count turtles with [own-car = 0 and wealth &gt; fare])+(count turtles with [own-car = 1]))</metric>
    <enumeratedValueSet variable="fare">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus_fare">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buy-price">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="cars" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>(count turtles with [own-car = 1])/((count turtles with [own-car = 0 and wealth &gt; fare])+(count turtles with [own-car = 1]))</metric>
    <enumeratedValueSet variable="fare">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus_fare">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buy-price">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
