globals [ T_ext ;; exterior ambient temperature
  T_ext-ref  T_ext-var  T_ext-max  T_ext-min T_ext-change  ;;
  Cp_water ;;
  flows  ;; list of flow rate in the different branches of the network
  T_set-min  ;; minimal set temperature for space heating of household
  T_set-max  ;; maximal set temperature for space heating of household
  T_cold-water ;; cold water temperature
  time-step ;; min duration of time step
  Q_scale-p Q_scale-c ;; kW Maximum power on power color scale
  Q_balance   ; kW thermal power between producers and consumers
  Q_producers ; kW total thermal power of producers
  Q_consumers ; kW total thermal power of consumers
  q_list      ; kW thermal power list for plot
  Q_cumulated ; kW list of thermal power in cumulated way for plotting
  days-on-plot ; number of days displayed on plot
  time-with-needs-not-covered ; min  cumulated number of minutes in all houses that a need has not been covered

]

breed [ consumers consumer ]
breed [ producers producer ]
breed [ splitters splitter ]
breed [ mergers merger ]
breed [ turns turn ]
directed-link-breed [ pipes pipe ]
;; pipes have a direction but the flow can go in both directions:
;; the flow rate is either positive or negative

producers-own [ Q Q_new Q_aim ;; Q is the thermal power
                ;; Q_max defined by a slider
                ;; Q_step defined by a slider
                ;; Q_aim is the power that would be needed to achieve the set temperature
  T_in T_out T_out-set   ;; temperatures
  flow_p ;; L/min flow crossing the producer (fix so far...) but possibly evolutive ;)
]
consumers-own [ T_in T_out ;; °C inlet and outlet temperature from heat network
  T_set T_hot-water  ;; °C set temperatures for space heating and hot water
  H_loss ;; W/K heat loss coefficient of the house
  Q     ;; kW  total heat load
  Q_sh  ;; kW  heat load from space heating
  Q_hw  ;; kW  heat load from domestic hot water
  V_shower ;; L volume of a shower
  flow_shower ;; L/min flow rate by tapping
  flow_c ;; L/min flow crossing the consumer (fix so far...) but possibly evolutive ;)
  shower? ;; true if shower going on
  need-not-covered ;; counter of time steps when the heat needs are not covered for hot water or space heating
]
splitters-own [ T_out ]
mergers-own [ T_in flow_in Txflow T_out ]
turns-own [ T_out ]

pipes-own [ pipe-temperature pipe-flow ] ;; pipes as links, have a memory of the temperature along their length...

to setup
  clear-all
  set-environment
  build-network

  reset-ticks
end

to set-environment
  ;;Hypothesis:
  ;; * no temperature hub in heat exchangers (for space heating and hot water)
  set time-step 6 ;; min, duration of a time step
      ;;(note temperature shift in the pipes moves from 1 unit of length per time step)
  set T_ext-ref 5 ;; °C initial average temperature during the day
  set T_ext-var 10 ;; °C variation from minimum to maximum during the day
  set T_ext-min -20 ;; °C minimum exterior temperature
  set T_ext-max 20 ;; °C maximum exterior temperature
  set T_ext-change 10 ;; °C maximum random change in the temperature from 1 day to the next
  set Cp_water 4.18 ;; kJ/(kg.K) or kJ/(L.K) assuming dentsity of 1 kg/L
  set T_set-min 15 ;; °C minimal set temperature for space heating of household
  set T_set-max 25 ;; °C maximal set temperature for space heating of household
  set T_cold-water 10 ;; °C temperature of cold water
  set flows [ 100 30 70 ] ;; L/min flow rate in the different branches of the hydraulic network
  set Q_scale-p 100 ;; kW maximum power on color scale for producers
  set Q_scale-c 40 ;; kW maximum power on color scale for consumers
  ask patches [ set pcolor white ] ;; set background color
  set days-on-plot 2 ;; number of days visible on plot

end



to build-network
  create-producers 2
  create-consumers 8
  create-splitters 1
  create-mergers 1
  create-turns 3

  ;;define position of producers
  (foreach sort [who] of producers
    [0 3]
    [0 5]
    [0 2] [
      [n x y f] -> ask (producer n) [
        set xcor x
        set ycor y
        set flow_p item f flows ;; sets on which branch of the network the producer is connected
        set shape "box"
        set size 0.8
        set color red ;orange
        set label-color green - 3
        ;;the 2 next parameters are defined by sliders:
          ;;set Q_max 100 ;; kW  maximal power output of the producer
          ;;set Q_step 2 ;; kW maximal power variation in a time step
        set T_out-set 60 ;; °C   set temperature output of the producer
;;        set efficiency
      ]
  ])

  ;;define position of consumers
  (foreach sort [who] of consumers
    [0 0 0 0 0 2 7 9]
    [1 3 4 7 9 5 5 5]
    [0 0 0 1 1 2 2 2] [
      [n x y f] -> ask (consumer n) [
        set xcor x
        set ycor y
        set flow_c item f flows ;; sets on which branch of the network the consumer is connected
        set shape "house"
        set size 0.8
        set color orange ;yellow
        set label-color green - 3
        ; Each CONSUMER has a user profile with heat needs for:
        ;; space heating: set temperature for the household:
        set T_set T_set-min + random (T_set-max - T_set-min + 1)
        ;; house type: (1 = passive), 2 = efficient, 3 = inefficient
        ;;  (passive: 10 W/K) , efficient: 100 W/K , inefficient: 1000 W/K
        set H_loss  10 ^ (random 2 + 2)  ;; W/K for 100 m² house
        ;;domestic hot water:
        set T_hot-water 50 ;; °C desired temperature of the hot water
        set flow_shower 10 ;; L/min  tapping flow rate when showering
        set shower? false ;; no shower going on at start
        ]
  ])

  ;;define position of splitters
  (foreach sort [who] of splitters
    [0 ]
    [5 ] [
      [n x y] -> ask (splitter n) [
        set xcor x
        set ycor y
        set shape "dot"
        set color magenta
      ]
  ])

  ;;define position of mergers
  (foreach sort [who] of mergers
    [1 ]
    [4 ] [
      [n x y] -> ask (merger n) [
        set xcor x
        set ycor y
        set shape "dot"
        set color cyan
      ]
  ])

  ;;define position of turns
  (foreach sort [who] of turns
    [1 9 1]
    [9 4 0] [
      [n x y] -> ask (turn n) [
        set xcor x
        set ycor y
        set shape "dot"
        set size 0.5
        set color brown
      ]
  ])

  ;;define pipes as links
  (foreach
    ["p" "c" "c" "c" "s" "c" "c" "t" "m" "t" "s" "c" "p" "c" "c" "t" ]   ;; pipe from consumer "c", producer "p", pipe "t", splitter "s", merger "m"
    [ 0   2   3   4  10   5   6  12  11  14  10   7   1   8   9  13  ]   ;; who of agent
    ["c" "c" "c" "s" "c" "c" "t" "m" "t" "p" "c" "p" "c" "c" "t" "m" ]   ;; pipe to consumer "c", producer "p", pipe "t", splitter "s", merger "m"
    [ 2   3   4  10   5   6  12  11  14   0   7   1   8   9  13  11  ]   ;; who of agent
    [ 0   0   0   0   1   1   1   1   0   0   2   2   2   2   2   2  ] [  ;; branch of network for flow definition
      [breed-from who-from breed-to who-to f] ->
      ;;create link FROM corresponding agent, depending on breed:
      ifelse breed-from = "p" [ set breed-from producer who-from ]
      [ifelse breed-from = "c" [ set breed-from consumer who-from ]
        [ifelse breed-from = "s" [ set breed-from splitter who-from ]
          [ifelse breed-from = "m" [ set breed-from merger who-from ]
            [ifelse breed-from = "t" [ set breed-from turn who-from ]
              [write "error creating pipe"]]]]]
      ifelse breed-to = "p" [ set breed-to producer who-to ]
      [ifelse breed-to = "c" [ set breed-to consumer who-to ]
        [ifelse breed-to = "s" [ set breed-to splitter who-to ]
          [ifelse breed-to = "m" [ set breed-to merger who-to ]
            [ifelse breed-to = "t" [ set breed-to turn who-to ]
              [write "error creating pipe"]]]]]
;      show breed-from
;      show breed-to
      ;;create link FROM called agent TO corresponding agent, depending on breed:
      ask breed-from [ create-pipe-to breed-to [
        set pipe-temperature n-values link-length [ T_cold-water ]  ;; start network cold.
        set pipe-flow item f flows
        set color blue
        set thickness pipe-flow / max flows * 0.15 ;; thickness proportional to flow
        ;; a way to show labels ?
        ]
      ]
      ;;pipe length is an existing parameter/primitive of links
  ])

  ;; initialize thermal power list
  set Q_list n-values (count producers + count consumers) [0]
  set Q_cumulated n-values (count producers + count consumers) [0]


end


to go
  update-environment
  adjust-power-producers
  adjust-power-consumers
  calculation-outputs
  ;1 time step has elapsed: shift the temperatures in the pipes
  update-pipes-temperatures

  tick
end


to update-environment
  ;; at the beginning of a day, update temperature
  if (0 = (ticks * time-step) mod (24 * 60)) [
    set T_ext-ref min list T_ext-max max list T_ext-min  T_ext-ref + random-float (T_ext-change * 2) - T_ext-change
  ]
  ;;update exterior temperature
  set T_ext  T_ext-ref + T_ext-var / 2 * sin( ((ticks * time-step) / 60 - 9) / 12 * 180)
end

to adjust-power-producers
 ; Each PRODUCER tries to maintain its outlet temperature T_OUT to the setup temperature T_SET by
 ; adjusting its thermal power according to the variation of the return temperature T_IN. It has a
 ; maximal power Q_MAX (kW) and a maximal variation Q_STEP (kW).
  ask producers [
    ;; show T_out as a label
    set label precision T_out 1
    ;; show power on a color scale
    set color scale-color red Q (Q_scale-p * 1.2) (Q_scale-p * -0.2)

    ;;get new value of T_in from the incoming link (if flow is positive...)
      ;; note this can lead to problem is 1 producer has several links coming in...
    set T_in [last pipe-temperature] of in-pipe-from one-of in-pipe-neighbors
    set Q_aim  flow_p / 60 * Cp_water * ( T_out-set - T_in )
    set Q_new  min list Q_max (max list 0 Q_aim)
    ifelse Q_new >= Q + Q_step [
      set Q  Q + Q_step
    ][if Q_new <= Q - Q_step [
      set Q  Q - Q_step
    ]]

    ; Then the new outlet temperature should be as close as possible to the set temperature:
    set T_out  T_in + Q / ( flow_p / 60 * Cp_water )

    ;;updates the thermal power of this agent in the global list of thermal power
    set Q_list replace-item who Q_list Q
;show Q

  ]
end

to adjust-power-consumers
  ask consumers [
    ;; show T_out as a label (default label, can be temporarily replaced by "shower" e.g.)
    set label precision T_out 1
    ;; show power on a color scale
    set color scale-color orange Q (Q_scale-c * 1.2) (Q_scale-c * -0.2)

    ;;get new value of T_in from the incoming link (if flow is positive...)
      ;; note this can lead to problem is 1 consumer has several links coming in...
    set T_in [last pipe-temperature] of in-pipe-from one-of in-pipe-neighbors
    set Q_hw 0
    if mode = "Space heating + Hot water" [
      ;; calculate heat load for domestic hot water:
      ifelse shower? [ ;; if a shower has started
        set label "Shower"
        set Q_hw  min list flow_shower (V_shower / time-step)  / 60 * Cp_water * ( min list T_in T_hot-water - T_cold-water )
        ;; takes into account the reduction of flow in the last time step, to account precisely to the tapped volume chosen
        ;; takes into account the maximum available temperature T_in if below T_hot-water
        set V_shower max list 0 (V_shower - flow_shower * time-step )
        if V_shower = 0 [
          set shower? false
        ]
      ]
      [ ;; if no shower is going on: test:
        ;; probability 0.2 between 18:00 and 19:00, probability 0.01 otherwise (or 0: deactivated)
        if ((16 < ((ticks * time-step) / 60) mod 24 and 18 > ((ticks * time-step) / 60) mod 24) and random-float 1 < 0.2 ) or
        random-float 1 < 0.01 [ ;; take shower: random volume between 20 and 100 L
          set shower? true
          set label "Shower"
          set V_shower random 81 + 20
          set Q_hw  min list flow_shower  (V_shower / time-step)  / 60 * Cp_water * ( min list T_in T_hot-water - T_cold-water )
          ;; takes into account the reduction of flow in the last time step, to account precisely to the tapped volume chosen
          ;; takes into account the maximum available temperature T_in if below T_hot-water
          ;; !!! warning: here is an approximation that one can heat the water up to T_in (no DeltaT in heat exchanger)
          set V_shower max list 0 (V_shower - flow_shower * time-step)
          if V_shower = 0 [
            set shower? false
          ]
        ]
      ]
    ]
    ;; calculate temperature reduction of network flow:
    set T_out  (T_in - Q_hw / ( flow_c / 60 * Cp_water ) ) ;; °C = °C -  ( kW / ( L/min / (s/min) * kJ/(L.K) )
    if T_in < T_hot-water [ ;; need not covered
      set need-not-covered need-not-covered + 1
      ;      set label "T < T_hw"
    ]
    ;; calculate heat load for space heating:
    ;;  !!! T_out is the T_in for the space heating...
    ;;      T_out is then actualised to the real T_out !
    set Q_sh  max list 0 (H_loss * ( min list T_out T_set - T_ext ) / 1000) ;; kW
        ;; if need is negative (cooling needed) then heating power is 0
        ;; if available temperature from network is below set temperature, the heating is limited to T_in from network
    if T_out < T_set [
      set need-not-covered need-not-covered + 1
;      set label "T < T_sh"
    ]
    set T_out  (T_out - Q_sh / ( flow_c / 60 * Cp_water ) ) ;; °C = °C -  ( kW / ( L/min / (s/min) * kJ/(L.K) )

    set Q Q_sh + Q_hw  ;; total heat load for the house

    ;;updates the thermal power of this agent in the global list of thermal power
    set Q_list replace-item who Q_list Q


  ]

end

to update-pipes-temperatures
  ;; once producers and consumers have been updated,
  ;; time elapses and the water is flowing for 1 time step
  ;; splitters, mergers and turns need to transmit their temperature to the next pipe
  ask splitters [
    ;;get new value of T_out from the incoming link (if flow is positive...)
      ;; note this can lead to problem if 1 splitter has several links coming in... (which should anyway not be the case)
    set T_out [last pipe-temperature] of in-pipe-from one-of in-pipe-neighbors
  ]
  ask mergers [
    ;;get new value of T_out from the incoming linkS (if flow is positive...)
      ;; note this can lead to problem is 1 splitter has several links coming in...
      ;;(a possible extension with flow in both directions should consider the two options separately)
    set T_out 0
    set T_in [0]
    set flow_in [0]
    set Txflow [0]
    foreach sort in-pipe-neighbors [ n ->
      set T_in lput [last pipe-temperature] of in-pipe-from n T_in
      set flow_in lput [pipe-flow] of in-pipe-from n flow_in
      set Txflow lput ([last pipe-temperature] of in-pipe-from n * [pipe-flow] of in-pipe-from n) Txflow
    ]
    ;; outlet temperature is weighted average of the inflow temperatures
    set T_out  sum Txflow / sum flow_in

    ;;check flow consistency?
    if sum flow_in != [pipe-flow] of out-pipe-to one-of out-pipe-neighbors [
      write "error in flow balance (at merger)"
    ]
  ]
  ask turns [
    ;;get new value of T_out from the incoming link (if flow is positive...)
      ;; note this can lead to problem is 1 turn has several links coming in...
    set T_out [last pipe-temperature] of in-pipe-from one-of in-pipe-neighbors
  ]

  ;; the temperature at the end of "1 time step distance" in pipes is updated
  ask pipes [
    set pipe-temperature remove-item (length pipe-temperature - 1) pipe-temperature
    set pipe-temperature fput [T_out] of end1 pipe-temperature
    set color scale-color pink mean pipe-temperature 100 0
  ]


end

to calculation-outputs
  ;; cumulated list of consumer power is for plotting:
  ;; first item in Q_consumers-cumulated is the thermal power consumed by the first consumer,
  ;; second item is the sum of 1st consumer + 2nd consumer
  ;; until last item which is the sum of all consumers...
  foreach sort [who] of producers [p ->
    set Q_cumulated replace-item p Q_cumulated sum sublist Q_list 0 (p + 1)
  ]
  foreach sort [who] of consumers [c ->
    set Q_cumulated replace-item c Q_cumulated sum sublist Q_list count producers (c + 1)
  ]
  set Q_producers item (count producers - 1) Q_cumulated
  set Q_consumers item (count producers + count consumers - 1) Q_cumulated
  set Q_balance Q_producers - Q_consumers

  ;;calculates the cumulated number of minutes in all houses that a need has not been covered
  set time-with-needs-not-covered sum [need-not-covered] of consumers * time-step

end
@#$#@#$#@
GRAPHICS-WINDOW
420
10
783
374
-1
-1
22.2
1
10
1
1
1
0
1
1
1
-3
12
-3
12
0
0
1
ticks
30.0

BUTTON
5
135
78
168
NIL
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
85
135
140
168
go 1
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
145
135
208
168
NIL
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

PLOT
420
380
780
560
Thermal power balance
Time t (min)
Heat Q (kW)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Q_producers" 1.0 0 -8630108 true "" "plot Q_producers"
"Q_consumers" 1.0 0 -955883 true "" "plot Q_consumers"

PLOT
5
275
415
560
Thermal power balance of heat network
Time (time step)
Heat (kW) ; Temperature (°C)
0.0
10.0
0.0
200.0
true
true
"foreach sort [who] of producers [p ->\n;set name lput \"Q_p\" p\n  create-temporary-plot-pen word \"Q_p\" p\n  plot item p Q_cumulated\n  set-plot-pen-color blue + 2 - p\n]  \nlet n_p count producers\nforeach sort [who] of consumers [c ->\n  create-temporary-plot-pen word \"Q_c\" c\n  plot item c Q_cumulated\n  set-plot-pen-color orange + 4 - c\n]  \n" "foreach sort [who] of producers [p ->\n;set name lput \"Q_p\" p\n  create-temporary-plot-pen word \"Q_p\" p\n  plot item p Q_cumulated\n  set-plot-pen-color blue + 2 - p\n]  \nlet n_p count producers\nforeach sort [who] of consumers [c ->\n  create-temporary-plot-pen word \"Q_c\" c\n  plot item c Q_cumulated\n  set-plot-pen-color orange + 4 - c\n]  \n\n; don't change the range until we've plotted the first days\nif ticks * time-step > days-on-plot * 24 * 60\n[\n  ; scroll the range of the plot so only the last days are visible\n  set-plot-x-range (ticks - (days-on-plot * 24 * 60 / time-step) ) ticks\n]\n"
PENS
"T_ext" 1.0 0 -10899396 true "" "plot T_ext"
"" 1.0 0 -7500403 true "" "plot 0\n;plot-pen-reset\n;plotxy 0 0\n;plotxy plot-x-max 0"
"Q_bal" 1.0 0 -2064490 true "" "plot Q_balance"

MONITOR
5
225
305
270
Cumulated time (min) with unmatched needs
time-with-needs-not-covered
17
1
11

MONITOR
430
20
507
65
T_ext (°C)
T_ext
1
1
11

TEXTBOX
220
145
370
163
Time step: 6 min\n
12
0.0
1

CHOOSER
5
10
210
55
Mode
Mode
"Space heating + Hot water" "Space heating"
0

SLIDER
5
60
177
93
Q_max
Q_max
0
250
200.0
10
1
kW
HORIZONTAL

SLIDER
5
95
177
128
Q_step
Q_step
1
50
20.0
1
1
kW
HORIZONTAL

TEXTBOX
185
60
335
135
Max power of producer\n\nMax modification of producer's power per time step
12
0.0
1

MONITOR
5
175
330
220
Average percentage of time with uncovered needs (%)
time-with-needs-not-covered / (ticks * time-step) / count consumers * 100
1
1
11

@#$#@#$#@
## WHAT IS IT?

This is a simple model of a heat network for demonstration purposes.
The aim of this network is to investigate and illustrate the potential of the Agent-Based Modeling (ABM) approach for studying heat networks. ABM are already used in the energy sector, especially in the electricity sector for smart grid studies or in holistic approaches. Modeling complex systems with the use of ABM seems to gain interest in the last years and would gain to be better known. A couple of references at the end of this documentation provide a short insight to this subject.
This present demo model enables to simulate the dynamics of the heat supply and heat consumption in the network: how do the PRODUCERS (e.g. boilers...) react to match the demand of the CONSUMERS (e.g. households).
The demand is variable. It consists of space heating and/or domestic hot water.


## HOW IT WORKS

### Environment
The environment defines the climate through:

* the outside ambient temperature: each day, the temperature is fixed to a random value between -20 °C and +20 °C, varying from the previous day by +/-5 °C.

The "environment" also takes care of the balance in the hydraulic network and imposes a mass flow in the different branches of the network. The FLOW list is a global variable.

### Types of Agents
At this stage, the hydraulic network could be seen as a meta-agent. It is composed of:

* PIPES as links, with a certain length (defining the size of the temperature list along the pipe): 1 link to or 1 link from
* SPLITTERS as agents with:
	* 2 links to
	* 1 link from
* MERGERS as agents with:
	* 1 link to
	* 2 links from
* TURNS, defined for a better graphical representation, as agents with:
	* 1 link to
	* 1 link from

For the moment, pumps are integrated in the consumers/producers. Valves are not modelled. The FLOW is fixed...
In a later stage, the mass flow could be computed by an external tool (or imported module?) based on pressure losses in the hydraulic circuit and pressure heads of the pumps.

The network data could be later imported from GIS data. There are 5 types of agents (breeds): PRODUCERS, CONSUMERS, SPLITTERS, MERGERS, TURNS. The hydraulic network is defined by lists defining for each agent breed:

* its spatial position (x, y coordinates)
* its connection to the network:
	* the mass flow in the line (network branches are numbered)
	* the temperature it sees at inlet, given by the incoming pipe.

The agents are numbered according to the network definition. In the example network, several CONSUMERS are connected in series on a branch of the hydraulic circuit.

### Simulation time step
The simulation TIME-STEP (tick duration) can be adjusted. 
By default, the agents take action with a time step of 6 min. One hour is 10 steps. One day has then 240 steps.
The flow is fixed to the design value (to enable the supply of the maximum heat load). Therefore we can assume that the network has been designed to obtain a fixed flow speed in the network. The flow speed in the network is then by default 6 min per unit length (let's say 1 patch = 50 m).
For the temperature propagation in the network, the hydraulic network has a "memory" of its temperature: it is stored in a list PIPE-TEMPERATURE for each pipe. Note that the temperature propagation in the network goes by 1 unit length (1 patch) per time step. The list stores as many temperatures as the pipe's length (number of patches separating the agents). This supposes the pipe diameters are exactly adjusted, according to the design mass flow, to maintain the same speed in the entire network.
Attention: to enable variable flows, there is a need for improvement. For example to take into account actions of valves, modifying the relative mass flow in network branches. But for demonstration purposes with fixed mass flows, this current model is enough.

### Consumer behavior
Each CONSUMER has a user profile with heat needs for:

* space heating, caracterised by:
	* the desired set temperature: randomly chosen between T_SET-MIN and T_SET-MAX (for example 15 and 25 °C)
	* the heat loss coefficient of the house in W/K, calculated for a 100 m² house. 3 types are proposed to start with:
		* (passive: 10 W/K) ignored so far
		* efficient: 100 W/K
		* inefficient: 1000 W/K
* domestic hot water (showers):
	* consumption of 10 to 100 L per shower(s), randomly
	* consumption happens with a mass flow of 10 L/min.
	* it can happen several times a day:
		* with a probability of 0.01 at each time step (happening statistically 2,9 times a day with a 6 min time step...) and
		* with a probability of 0.2 between 18:00 and 19:00 to try to generate peak demand. This could be refined with more realistic profiles and some more diversity in the agents...

From the heat load in a time step, the temperature of the FLOW available to the agent is decreased accordingly:
   T_OUT = T_IN - ( HEAT-LOAD * (T_AIM - T_EXT) ) / ( FLOW * CP )

### Producer behavior
Each PRODUCER tries to maintain its outlet temperature T_OUT to the setup temperature T_SET by adjusting its thermal power according to the variation of the return temperature T_IN. It has a maximal power Q_MAX (kW) and a maximal variation Q_STEP (kW).
   HEAT-LOAD_NEW = min( Q_MAX, max( 0, FLOW * CP * ( T_OUT - T_IN ) ) )

* if HEAT-LOAD_NEW > HEAT-LOAD + Q_STEP
  then limit power: HEAT-LOAD = HEAT-LOAD + Q_STEP
* if HEAT-LOAD_NEW < HEAT-LOAD - Q_STEP
  then limit power: HEAT-LOAD = HEAT-LOAD - Q_STEP
* otherwise
  set power to calculated value: HEAT-LOAD = HEAT-LOAD_NEW

Then the new outlet temperature should be as close as possible to the set temperature:
   T_OUT = T_IN - HEAT-LOAD / ( FLOW * CP )


## HOW TO USE IT

Click SETUP to build the network.
Click GO 1  to run 1 time step
Click GO    to run the model

You can choose the mode: activate only "space heating load" or "space heating + domestic hot water" (default).

The maximum power Q_MAX of the producers can be adjusted, as well as its inertia: how fast can the power output be adjusted, or what is the maximum variation Q_STEP of the power per time step.

Further parameters can be modified directly in the code tab.

Attention:
When you create the network using the SETUP button, the consumers are given a somewhat random behavior: the house energy efficiency and the set temperature for space heating vary from one setup to the other. The consumption of each shower is chosen randomly at the beginning of each shower. Additionally, the climate is randomly determined.
As a consequence, 2 single runs with different SETUPs and parameters can not be directly compared. The use of BEHAVIOR SPACE tool is recommended to explore the band width of what can possibly happen in this network, considering the variability of load profiles and heat producers.


## THINGS TO NOTICE

You can visualize the power output of the producers (blue lines) and the power consumption of the consumers (orange lines) during the two last days simulated in the bottom left diagram. In this diagram, each line represent the power of a producer or consumer, in a cumulated way (the first line from the bottom line accounts for the power of the first producer, the difference between the first and second line on top of it shows the power of the second producer; same for consumers)
The rose line shows the current balance of thermal power in the network: if it is negative, the network is losing energy at the moment, while a positive value indicates more energy is produced than consumed at this moment.

In the bottom right diagram, the total powers of producers and consumers are plotted from the beginning of the simulation.

The "cumulated time (min) with unmatched needs" accounts for the time (TICKS * TIME-STEP) when a consumer is not able to cover its needs. This happens when the temperature in the network is too low: the required temperature can not be reached. The time is cumulated between consumers: if N consumers do not match their needs during the same time step, the time is counted N times!

The "Average percentage of time with uncovered needs" shows the percentage of time steps when needs are not covered in average over all consumers.

The current outside temperature is also indicated on the network diagram (top right).
On the network graphical representation, some information can be red:

* the thickness of the pipes is proportional to the mass flow, 
* the color of the pipes is varying with the temperature (from white at 0 °C, gradually darker until black at 100 °C)
* the color of the consumers and producers is varying with their current thermal power consumption and production respectively (the darker, the higher) 
* the value on each consumer and producer indicates the current temperature outlet (at the beginning of each time step) 
* when a consumer is taking a shower, the label is switched to "shower"


## THINGS TO TRY

You can run the model with default values (Q_MAX = 50 kW as maximum power for producers). Is the load covering the network needs?
You can increase the maximum power to 100 kW. How does this affects the "Average percentage of time with uncovered needs"?
Does increasing the reactivity of the producer (Q_STEP = 5 or 10 kW) affects the results?

Try to switch from "Space heating + Hot water" mode to "Space heating" mode. Observe the behavior with space heating load only. How does this affect the "Average percentage of time with uncovered needs"?

Using BehaviorSpace (in the tools menu) can be interesting to run several times the model and draw statistical conclusions on the bandwidth of "behavior" the network can have.


## EXTENDING THE MODEL

There are many ways one could improve the model.

### on the structure of the network:

The configuration of the network is very simple, with only two branches on which few CONSUMERS are connected in series. In most networks, consumers are connected in parallel, so that they are all supplied with the same temperature (except from inline thermal losses). Another network structure could be implemented.

### on the inputs:

The weather data could be generated based on a climate/weather model (or using standard data base).

Develop an interface to import easily network data.

The load profiles of consumers could be adjusted to more realistic user profiles, depending on the use case.

### on the physical model of phenomena:

The model could be more robust on the modelling of the hydraulic network. This would be especially interesting to implement the possibility of variable flows (effect of pumps or valves).

The control strategy could be improved. The model could actually be used to investigate and optimize control strategies. The model could help test the robustness of the control strategies in all situations the network can meet.


### on the outputs:

The variables and diagrams for the analysis could be further developed to investigate some aspects in more details.


## NETLOGO FEATURES

FOREACH is used to generate the network.

In the diagram, to plot the cumulated values of producer/consumer thermal powers, we use a FOREACH structure, calling CREATE-TEMPORARY-PLOT-PEN for each producer and consumer. This enables to generate the diagram automatically, whatever the number of producers and consumers.

A parallel simulation of all agents could be interesting. But the current feature with "parallel-like" simulation --like it is used in the termites model-- is not suitable. Indeed it does not keep track of time in a strict manner...

## RELATED MODELS

No similar model could be identified in the library.
The "diffusion in a directed network" could be the nearest model to which the present one can be related to.
Some work has already been done in the energy sector using Agent Based Modeling, especially concerning smart electricity grid. Some references are given in the following section.

## CREDITS AND REFERENCES

This model has been developed by François Veynandt in the scope of the online course <a href="https://www.complexityexplorer.org/courses/90-introduction-to-agent-based-modeling-summer-2018">"Introduction to Agent Based Modeling"</a> (summer 2018) by Bill Rand, available on the Complexity Explorer platform of the Santa Fe Institute (the course has been taken off-session for time constraints).
This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

*Versions history:*
v1 :    	"setup" creation of the network elements and their spatial location, core "go" procedures and properties of the network agents, user interface and documentation




The following references show contributions of Agent Based Modeling to think and orientate the energy transition:

* <a href="https://www.comses.net/codebases/5903/releases/1.10.0/"> Agent-based Renewables model for Integrated Sustainable Energy (ARISE)</a> (version 1.10.0)
*Summary:* "Agent-based Renewables model for Indonesia Sustainable Energy (ARISE) is a hybrid energy model integrating multi-perspectives of engineering, social, microeconomic, macroeconomic and environment to ensure a comprehensive assessment of a proposed policy.The motivation to develop ARISE is due to the absence of suitable energy model for analysing renewable energy policy in developing countries. ARISE has features of unique characteristics of developing countries, such as urban-rural analysis, income inequality, and lack of electricity access. In this version of ARISE, the analysis scope is still limited to the interaction of proposed policy to households’ decisions in investing photovoltaic (PV). In addition, ARISE estimates the impacts of the policy on macroeconomic outputs and environments."
Al Irsyad, Muhammad Indra, Halog, Anthony, Nepal, Rabindra (2018, October 05). “Agent-based Renewables model for Integrated Sustainable Energy (ARISE)” (Version 1.10.0). CoMSES Computational Model Library. 
Retrieved from: https://www.comses.net/codebases/5903/releases/1.10.0/


* <a href="https://www.comses.net/codebases/5836/releases/1.1.0/"> ACT: Agent-based model of Critical Transitions</a> (version 1.1.0)
*Summary:* "More realistic simulating of the energy transition requires the integration of human behaviour in energy system models. In this study we reflect on the use of conceptual models of human behaviour to support discussion on the evolution of the energy system. We present a simple agent-based model inspired by an existing conceptualisation based on the concept of critical transitions. The concept has been implemented in an agent-based model (ACT: Agent-Based Model of Critical Transitions) to be able to analyse the effect of actor behaviour on the energy transition. With ACT we could depart from a mean-field approach and explore the effect of leaders, social norms and interaction networks. Results from ACT show that the effect of leaders is more nuanced that what is assumed in existing literature on critical transitions; leaders can encourage a transition but can also try to stall any development till a critical transition is inevitable. We conclude with a reflection on the use of conceptual models in general in which we argue that the application of the concept of critical transitions and conceptual modelling in general has a role to play in understanding, discussing and communicating about the energy transition."
Kraan, Oscar, Dalderop, Steven, Kramer, Gert Jan, Nikolic, Igor (2018, August 27). “ACT: Agent-based model of Critical Transitions” (Version 1.1.0). CoMSES Computational Model Library. 
Retrieved from: https://www.comses.net/codebases/5836/releases/1.1.0/
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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>time-with-needs-not-covered / (ticks * time-step) / count consumers * 100</metric>
    <enumeratedValueSet variable="Mode">
      <value value="&quot;Space heating + Hot water&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q_max">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q_step">
      <value value="2"/>
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
