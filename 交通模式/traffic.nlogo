globals [
  lanes
  selected-car
  ticks-at-last-change
  ticks-at-last-change-1
  ticks-at-last-change-2
  ticks-at-last-change-3
  ticks-at-last-change-4
  ticks-at-last-change-5
  green-sequence
  flow-time-change
  average-waiting-time
  dead-cars
  total-cars-0
  total-cars-1
  total-cars-2
  total-cars-3
  flow-cars-0
  flow-cars-1
  flow-cars-2
  flow-cars-3
  flow-x
  flow-y
  total-flow-x
  total-flow-y
  total-patches-x
  total-patches-y
  intersection-width
  min-distance
  max-capacity
  critical-capacity
  x-waiting-cars
  y-waiting-cars
  x-turning-waiting-cars
  y-turning-waiting-cars
  pedestrians-waiting
  red-direction
  total-lifts
  waiting-taxi-pedestrians
  average-waiting-taxi
  mouse-was-down?
  total-waiting-taxi
  ambulance-counter
  ambulance-freq
  yellow-length
  collisions
  ticks-to-remove-collided
  max-waiting-car
  x-times
  y-times
  x-t-times
  y-t-times
  p-times
]

breed [ cars car ]
breed [ lights light ]
breed [ pedestrians pedestrian ]

lights-own [
  light-direction
  time-to-go
  turn-left
  cars-light
]

cars-own [
  speed         ; the current speed of the car
  top-speed     ; the maximum speed of the car (different for all cars)
  target-lane   ; the desired lane of the car
  patience      ; the driver's current level of patience
  direction
  current-lane
  lanecor
  turn
  wanna-turn
  wanna-turn-left
  first-stop-time
  waiting-time
  pass-intersection
  swapping-lanes
  sensed
  analyzed
  dead
  taxi         ; bool used to know if vehicule is taxi
  ambulance    ; bool used to know if vehicule is ambulance
  is-free         ; bool used for taxi and ambulance
  lifting      ;bool getting in people in the car
  lifting-time
  collided ; bool true if collided
  collision-on-ticks ; saves the ticks when the collision ocurred
]

pedestrians-own [
  speed
  top-speed
  direction
  current-lane
  lanecor
  turn
  wanna-turn-before
  wanna-turn-after
  wanna-turn-left
  wanna-turn-right
  waiting-time
  pass-intersection
  dead
  waiting-taxi  ; bool true if is waiting

]


to setup
  clear-all
  set dead-cars 0
  set average-waiting-time 0
  set-default-shape lights "circle"
  set-default-shape cars "car top"
  set-default-shape pedestrians "person"
  set collisions 0
  set ticks-to-remove-collided 50
  set ambulance-freq 0
  decorate
  draw-lines
  start-lights
  create-lanes
  start-variables
  reset-ticks
end

to start-variables
  set green-sequence 1
  set min-distance 1.1
  set flow-x 0
  set flow-y 0
  set total-flow-x 0
  set total-flow-y 0
  set total-cars-0 0
  set total-cars-1 0
  set total-cars-2 0
  set total-cars-3 0
  set flow-cars-0 0
  set flow-cars-1 0
  set flow-cars-2 0
  set flow-cars-3 0
  set max-waiting-car 0
  set intersection-width 6
  set total-patches-x (max-pxcor * 2) + 1
  set total-patches-y (max-pycor * 2) + 1
  set max-capacity floor (((total-patches-x * 4) + (total-patches-y * 4 - 4) - (intersection-width * 4)) / min-distance )
  set total-lifts 0
  set waiting-taxi-pedestrians 0
  set total-waiting-taxi 0
  set ambulance-counter 0
  set x-times 0
  set y-times 0
  set x-t-times 0
  set y-t-times 0
  set p-times 0
end

to draw-lines
  create-turtles 1
  draw-line-x 2 white 0.5
  draw-line-x -2 white 0.5
  draw-line-y -2 white 0.5
  draw-line-y 2 white 0.5
  ask turtle 0 [
   die
  ]
end

to start-lights
  ;go ahead lights
  ask patch 0 -4 [ sprout-lights 1 [
    set color green
    set light-direction 0
    set turn-left false
    set cars-light true
  ] ]
  ask patch 4 0 [ sprout-lights 1 [
    set color red
    set light-direction 1
    set turn-left false
    set cars-light true
  ] ]
  ask patch 0 4 [ sprout-lights 1 [
    set color green
    set light-direction 2
    set turn-left false
    set cars-light true
  ] ]
  ask patch -4 0 [ sprout-lights 1 [
    set color red
    set light-direction 3
    set turn-left false
    set cars-light true
  ] ]
  ;turn left lights
  ask patch 0 -6 [ sprout-lights 1 [
    set color red
    set light-direction 0
    set turn-left true
    set cars-light true
  ] ]
  ask patch 6 0 [ sprout-lights 1 [
    set color red
    set light-direction 1
    set turn-left true
    set cars-light true
  ] ]
  ask patch 0 6 [ sprout-lights 1 [
    set color red
    set light-direction 2
    set turn-left true
    set cars-light true
  ] ]
  ask patch -6 0 [ sprout-lights 1 [
    set color red
    set light-direction 3
    set turn-left true
    set cars-light true
  ] ]
  ask patch 6 6 [ sprout-lights 1 [
    set color red
    set light-direction 4
    set turn-left false
    set cars-light false
  ]]
  ask patch -6 6 [ sprout-lights 1 [
    set color red
    set light-direction 4
    set turn-left false
    set cars-light false
  ]]
  ask patch 6 -6 [ sprout-lights 1 [
    set color red
    set light-direction 4
    set turn-left false
    set cars-light false
  ]]
  ask patch -6 -6 [ sprout-lights 1 [
    set color red
    set light-direction 4
    set turn-left false
    set cars-light false
  ]]
end

to decorate
 ask patches [
    ifelse abs pxcor <= 3 or abs pycor <= 3
      [
        ifelse (pxcor = -4 or pxcor = 4 or pycor = 4 or pycor = -4 or pxcor = -5 or pxcor = 5 or pycor = -5 or pycor = 5)[set pcolor white] [set pcolor black]
      ]     ; the roads are black
      [ set pcolor green - random-float 0.5 ] ; and the grass is green
    if ((pxcor = 0 and abs pycor > 3) or (pycor = 0 and abs pxcor > 3)) ;street division
      [ set pcolor yellow ]
    if (((abs pxcor = 4 or abs pxcor = 5 )and abs pycor >= 4) or ((abs pycor = 4 or abs pycor = 5)and abs pxcor >= 4)) ;painting sidewalks
      [ set pcolor grey ]
    if ((abs pxcor = 6 and pycor = 6) or (pxcor = -6 and pycor = -6) or (pxcor = 6 and pycor = -6))
      [ set pcolor black ]
  ]
end

to create-lanes
  set lanes n-values number-of-lanes [ n -> number-of-lanes - (n * 2) - 3 ]
end

to draw-line-x [ y line-color gap ]
  ; We use a temporary turtle to draw the line:
  ; - with a gap of zero, we get a continuous line;
  ; - with a gap greater than zero, we get a dasshed line.
  ask turtle 0 [
    setxy (min-pxcor - 0.5) y
    hide-turtle
    set color line-color
    set heading 90
    repeat world-width [
      pen-up
      forward gap
      if (abs ([xcor] of turtle 0) > 3)
        [pen-down]
      forward (1 - gap)
      pen-up
    ]
  ]
end

to draw-line-y [ x line-color gap ]
  ask turtle 0 [
    setxy x (min-pycor - 0.5)
    hide-turtle
    set color line-color
    set heading 0
    repeat world-width [
      pen-up
      forward gap
      if (abs ([ycor] of turtle 0) > 3)
        [pen-down]
      forward (1 - gap)
      pen-up
    ]
  ]
end

to go
  if-else (intelligent) [
    change-lights-intelligent
  ][
    change-lights-simple
  ]

  start-cars

  start-pedestrians

  sense-flow

  move-cars

  move-pedestrians

  ;check-ambulance-procedure

  if mouse-down? [ set mouse-was-down? true ]

  if mouse-clicked? [
    set mouse-was-down? false
    create-remove-dead-car mouse-xcor mouse-ycor
  ]

  tick
end

to-report mouse-clicked?
  report (mouse-was-down? = true and not mouse-down?)
end

to sense-flow
  if (elapsed-flow? flow-time)[
    set flow-cars-0 0
    set flow-cars-1 0
    set flow-cars-2 0
    set flow-cars-3 0
    set flow-time-change ticks
  ]

  ; direction 0
  ask patches with [pycor = 4 and (pxcor = -1 or pxcor = -3)] [
    let new-cars (cars-here with [sensed = false])

    ask new-cars [
      set sensed true
    ]
    set total-cars-0 (total-cars-0 + (count new-cars))
    set flow-cars-0 (flow-cars-0 + (count new-cars))
  ]

  ;direction 1
  ask patches with [pxcor = -4 and (pycor = -1 or pycor = -3)] [
    let new-cars (cars-here with [sensed = false])

    ask new-cars [
      set sensed true
    ]
    set total-cars-1 (total-cars-1 + (count new-cars))
    set flow-cars-1 (flow-cars-1 + (count new-cars))
  ]

  ;direction 2
  ask patches with [pycor = -4 and (pxcor = 1 or pxcor = 3)] [
    let new-cars (cars-here with [sensed = false])

    ask new-cars [
      set sensed true
    ]
    set total-cars-2 (total-cars-2 + (count new-cars))
    set flow-cars-2 (flow-cars-2 + (count new-cars))
  ]

  ;direction 3
  ask patches with [pxcor = 4 and (pycor = 1 or pycor = 3)] [
    let new-cars (cars-here with [sensed = false])

    ask new-cars [
      set sensed true
    ]
    set total-cars-3 (total-cars-3 + (count new-cars))
    set flow-cars-3 (flow-cars-3 + (count new-cars))
  ]



  let divider (ticks - flow-time-change)
  set flow-y ((flow-cars-0 + flow-cars-2) / (divider + 1))
  set flow-x ((flow-cars-1 + flow-cars-3) / (divider + 1))
  set total-flow-y ((total-cars-0 + total-cars-2) / (ticks + 1))
  set total-flow-x ((total-cars-1 + total-cars-3) / (ticks + 1))
end

to move-cars
  ask cars [
    if not can-move? 1 [
      set average-waiting-time ((average-waiting-time * dead-cars + waiting-time) / (dead-cars + 1))
      if (max-waiting-car < waiting-time) [ set max-waiting-car waiting-time ]
      set dead-cars (dead-cars + 1)
      die
    ]
    if not dead [
      move-forward
      if patience <= 0 and not swapping-lanes[ choose-new-lane ]
      if current-lane != target-lane [ move-to-target-lane ]
    ]
    if collided  [
      if (ticks - collision-on-ticks) > ticks-to-remove-collided[
        die
      ]
    ]
  ]
end

to move-pedestrians
  ask pedestrians [
    if not can-move? 1 [
      set dead true
      die
    ]
    if not dead[
      move-pedestrian
    ]
  ]
end


to start-cars
  create-car 0 0 freq-south
  create-car 0 1 freq-south
  create-car 1 0 freq-east
  create-car 1 1 freq-east
  create-car 2 0 freq-north
  create-car 2 1 freq-north
  create-car 3 0 freq-west
  create-car 3 1 freq-west
end

to start-pedestrians
  create-pedestrian 0 0
  create-pedestrian 0 1
  create-pedestrian 1 0
  create-pedestrian 1 1
  create-pedestrian 2 0
  create-pedestrian 2 1
  create-pedestrian 3 0
  create-pedestrian 3 1
end

to change-lights-simple
  if elapsed? green-length [change-to-yellow]
  let turned-light-pedestrian lights with [ color = green + 0.1 and cars-light = false ]
  let turned-light-left lights with [ color = green + 0.1 and turn-left = true and green-sequence = 4]
  if any? turned-light-pedestrian [set yellow-length 100]
  if any? turned-light-left [set yellow-length 50]
  if elapsed? yellow-length  and any? lights with [ color = green + 0.1 ] [
    change-to-red
    ifelse green-sequence = 5 [ set green-sequence 1 ]
    [set green-sequence green-sequence + 1]
  ]
  if any? turned-light-pedestrian [set yellow-length 0]
  if any? turned-light-left [set yellow-length 0]
end

to change-to-red
  ask lights [
    set color red
    if green-sequence = 1 [
      if (turn-left = false and (light-direction = 1 or light-direction = 3) and cars-light) [set color green]
      ;show "hello"
      set ticks-at-last-change-1 ticks
      set x-times (x-times + 1)
    ]
    if green-sequence = 2 [
      if (turn-left = false and (light-direction = 0 or light-direction = 2) and cars-light) [set color green]
      set ticks-at-last-change-2 ticks
      set y-times (y-times + 1)
    ]
    if green-sequence = 3 [
      ifelse (color = red and turn-left = true and (light-direction = 1 or light-direction = 3) and cars-light) [set color green]
      [set color red]
      set ticks-at-last-change-3 ticks
      set x-t-times (x-t-times + 1)
    ]
    if green-sequence = 4 [
      ifelse (color = red and turn-left = true and (light-direction = 0 or light-direction = 2) and cars-light) [set color green]
      [set color red]
      set ticks-at-last-change-4 ticks
      set y-t-times (y-t-times + 1)
    ]
    if green-sequence = 5 [
      ifelse (cars-light) [ set color red]
      [set color green]
      set ticks-at-last-change-5 ticks
      set p-times (p-times + 1)
    ]
  ]
  set ticks-at-last-change ticks

end

to change-to-yellow
  ask lights [
    if (color = green) [set color green + 0.1]
    set ticks-at-last-change ticks
  ]
end

to-report elapsed? [ time-length ]
  report (ticks - ticks-at-last-change) > time-length
end

to change-lights-intelligent
  if elapsed? green-length [
    ;Cars heading east and west that did't reach the critic zone yet
    set x-waiting-cars count cars with [(direction = 1 or direction = 3) and not pass-intersection? and out-of-intersection]
    ;Cars heading north and south that did't reach the critic zone yet
    set y-waiting-cars count cars with [(direction = 0 or direction = 2) and not pass-intersection? and out-of-intersection]
    ;Cars heading east and west that want to turn and did't reach the critic zone yet
    set x-turning-waiting-cars count cars with [(direction = 1 or direction = 3) and not pass-intersection? and out-of-intersection and not dead and wanna-turn-left]
    ;Cars heading north and south that want to turn and did't reach the critic zone yet
    set y-turning-waiting-cars count cars with [(direction = 0 or direction = 2) and not pass-intersection? and out-of-intersection and not dead and wanna-turn-left]
    ;Pedestrians wanting to cross that did't reach the critic zone
    set pedestrians-waiting count pedestrians with [not pass-intersection? and out-of-intersection]

    ;Sets the direction of the red light to the correct direction
    ask one-of lights with [color = red or color = green + 0.1] [
      set red-direction light-direction
    ]

    ;Ticks since last light change
    let red-time (ticks - ticks-at-last-change)
    ;If is the lights are red to north and south

    set x-waiting-cars (x-waiting-cars + (ticks - ticks-at-last-change-1) * x-factor)
    set y-waiting-cars (y-waiting-cars + (ticks - ticks-at-last-change-2) * y-factor)
    set x-turning-waiting-cars (x-turning-waiting-cars + (ticks - ticks-at-last-change-3) * x-turn-factor)
    set y-turning-waiting-cars (y-turning-waiting-cars + (ticks - ticks-at-last-change-4) * y-turn-factor)
    set pedestrians-waiting (pedestrians-waiting + (ticks - ticks-at-last-change-5) * pedestrian-factor)

    ;The direction with the bigger weigth of waiting agents
    let max-waiting-direction 0
    ;Thw weigth of that direction
    let weight-winning-direction 0

    if weight-winning-direction < x-waiting-cars [
      set max-waiting-direction 1
      set weight-winning-direction x-waiting-cars
    ]
    if weight-winning-direction < y-waiting-cars [
      set max-waiting-direction 2
      set weight-winning-direction y-waiting-cars
    ]
    if weight-winning-direction < x-turning-waiting-cars [
      set max-waiting-direction 3
      set weight-winning-direction x-turning-waiting-cars
    ]
    if weight-winning-direction < y-turning-waiting-cars [
      set max-waiting-direction 4
      set weight-winning-direction y-turning-waiting-cars
    ]
    if weight-winning-direction < pedestrians-waiting [
      set max-waiting-direction 5
      set weight-winning-direction pedestrians-waiting
    ]
    ;If the green sequence change, change the lights to yellow
    if max-waiting-direction != green-sequence [
      ifelse (green-sequence = 3 or green-sequence = 4 or green-sequence = 5)[
        set yellow-length 50
      ][
        set yellow-length 0
      ]
      set green-sequence max-waiting-direction
      change-to-yellow
    ]

  ]

  if elapsed? yellow-length  and any? lights with [ color = green + 0.1 ] [change-to-red]

;  ;If there are more cars waiting on the x axis than on the y axis and it is red on the x axis
;  ;and its been in red for more time than the bottom limit it changes the light to yellow and then to green
;  if(x-waiting-cars > y-waiting-cars and (red-direction != 0 and red-direction != 2) and elapsed? green-length )[
;    change-to-yellow
;  ]
;  if(y-waiting-cars > x-waiting-cars and (red-direction != 1 and red-direction != 3) and elapsed? green-length )[
;    change-to-yellow
;  ]
;  ;If the yellow time is over and there are any lights in yellow it changes them to red
;  if elapsed? yellow-length  and any? lights with [ color = green + 0.1 ] [change-to-red]

end

to-report waiting-weight-factor [red-time]


  report red-time * 0.001

end

to move-pedestrian

  let red-lights (lights with [light-direction = 4 and cars-light = false and (color = red or color = green + 0.1)])

  ifelse (stop-on-pedestrian-red?) and (any? red-lights) and not crossed? or waiting-taxi[
    set speed 0
   ; set-proper-position
  ][
    let blocking-pedestrian other pedestrians in-cone (ceiling 1) 15
    let blocking-man min-one-of blocking-pedestrian [ distance myself ]

    ifelse blocking-man != nobody [

      ifelse ((distance blocking-man) <= 1.5 and direction != [direction] of blocking-man)[
         ;set speed 0
      ][
        if ((distance blocking-man) <= 1.5) and (speed >  [speed] of blocking-man) and (direction = [direction] of blocking-man) and (not [waiting-taxi] of blocking-man)[
          set speed 0
        ]

        if ((distance blocking-man) <= speed + min-distance ) and (not [waiting-taxi] of blocking-man)[
          set speed [speed] of blocking-man
        ]


        if([speed] of blocking-man = 0 and (distance blocking-man) <= 1.5 ) and (direction = [direction] of blocking-man) and (not [waiting-taxi] of blocking-man)[
          set speed [speed] of blocking-man
        ]
      ]
    ]
    [if speed = 0 [set speed random-float (0.075 - 0.045) + 0.045]
    ]
  ]
  if near-sidewalk? and random 100 < waiting-for-taxi-freq [
    if not waiting-taxi[
      set waiting-taxi-pedestrians (waiting-taxi-pedestrians + 1)
      set total-waiting-taxi (total-lifts + waiting-taxi-pedestrians)
    ]
    set waiting-taxi true
    set color black
    set speed 0
  ]
  if not turn and wanna-turn-left or wanna-turn-right [
    if pedestrian-on-turn-position? direction wanna-turn-before xcor ycor [
      if wanna-turn-left [
        pedestrian-turn-left
      ]
      if wanna-turn-right [
        pedestrian-turn-right
      ]
    ]
  ]

  forward speed
end

to move-forward ; car procedure


  let d direction

  let red-lights (lights with [light-direction = d and cars-light = true and turn-left = false and (color = red or color = green + 0.1)])
  let red-turn-lights (lights with [light-direction = d and cars-light = true and turn-left = true and (color = red or color = green + 0.1)])

  if stop-on-red? and not analyzed[turning-setup]

  if wanna-turn-left and not turn [ complete-turn-left ]

  if taxi [
    taxi-procedure
  ]

  if collisions-enabled [
    ask other cars in-radius (size / 2) [
      if not dead [
        set collisions (collisions + 1)
        set dead true
        set collided true
        set collision-on-ticks ticks
        set color white
      ]
    ]
  ]

  ifelse ((stop-on-red?) and ( ((any? red-lights) and (not wanna-turn-left)) or ((any? red-turn-lights) and (wanna-turn-left)) ) )or lifting [
    set speed 0
  ][
    if(first-stop-time > 0 and pass-intersection? and not pass-intersection)[
      set waiting-time (ticks - first-stop-time)
    ]
    let security-distance (speed / deceleration) * speed


    ; check for cars ahead in a range
    let blocking-cars other cars in-cone (ceiling security-distance + min-distance) 25
    ; get the closest car
    let blocking-car min-one-of blocking-cars [ distance myself ]

    ; if there is a car act
    ifelse blocking-car != nobody [
      ; match the speed of the car ahead of you and then slow
      ; down so you are driving a bit slower than that car.

      ifelse ((distance blocking-car) <= security-distance + min-distance + speed and direction != [direction] of blocking-car)[
         set speed 0
      ][
        if ((distance blocking-car) <= security-distance + min-distance + speed) and (speed >  [speed] of blocking-car)[
          slow-down-car
        ]
        let myDir direction
        let trouble-cars []
        ask cars[
          set trouble-cars other cars with [ swapping-lanes and direction = myDir ]
        ]
        if count trouble-cars > 0 [
          slow-down-car
        ]
        if ((distance blocking-car) <= speed + min-distance )[
          slow-down-car
          set speed [speed] of blocking-car
        ]


        if([speed] of blocking-car = 0 and (distance blocking-car) <= speed + min-distance )[
          slow-down-car
          set speed [speed] of blocking-car
        ]
        if ([dead] of blocking-car) [
          set speed 0
          set patience 0
        ]
      ]
    ][
      ; if there is not a blocking car
      if taxi [
        taxi-procedure
      ]
      if wanna-turn [
      ; prepare to turn
      prepare-to-turn
      ;turn
      turn-ifturn
      ]
      if wanna-turn-left [
        prepare-to-turn-left
        turn-left-ifturn
      ]
      ; accelerate if it is not in red
      ifelse (any? red-lights and distance-to-red < security-distance  and out-of-intersection and not pass-intersection?) [
        ifelse (speed <= 0) [
          speed-up-car
        ][
          slow-down-car
        ]
      ][
        speed-up-car
      ]
    ]
  ]

  if(first-stop-time = 0 and speed = 0)[ set first-stop-time ticks ]
  forward speed
end

to check-ambulance-procedure
  ask cars with [ambulance] [
    ifelse direction = 0 or direction = 2[
      ifelse not wanna-turn-left [
        set green-sequence 2
        ;show "force change 2"
      ][
        set green-sequence 4
        ;show "force change 4"
      ]
    ][
      ifelse not wanna-turn-left [
        set green-sequence 1
        ;show "force change 1"
      ][
        set green-sequence 3
        ;show "force change 3"
      ]
    ]
  ]
end

to-report near-sidewalk?
  if direction = 0 [
    ;if current-lane = 0 [
    ;  if xcor < 4.1 and xcor > 3 [ report true ]
   ; ]
    if current-lane = 1 [
      if xcor > -4.1 and xcor < -3 and (ycor < -6 or ycor > 6) [ report true ]
    ]
  ]
  if direction = 1 [
    ;if current-lane = 0 [
     ; if ycor < 4.1 and ycor > 3 [ report true ]
    ;]
    if current-lane = 1 [
      if ycor > -4.1 and ycor < -3 and (xcor < -6 or xcor > 6 )[ report true ]
    ]
  ]
  if direction = 2 [
    ;if current-lane = 0 [
     ; if xcor < 4.1 and xcor > 3 [ report true ]
    ;]
    if current-lane = 1 [
      if xcor > -4.1 and xcor < -3  and (ycor < -6 or ycor > 6)[ report true ]
    ]
  ]
  if direction = 3 [
    if current-lane = 1 [
      if ycor < 4.1 and ycor > 3  and (xcor < -6 or xcor > 6)[ report true ]
    ]
    ;if current-lane = 0 [
     ; if ycor > -4.1 and ycor < -3 [ report true ]
    ;]
  ]
  report false
end

to taxi-procedure
  if is-free [
    ifelse direction = 0 or direction = 2 [
      if check-waiting-pedestrians-y [
       ; ifelse direction = 0 [ set ycor ycor - 0.5 ] [set ycor ycor + 0.5]
        set speed 0
        set lifting true
        set total-lifts (total-lifts + 1)
        set waiting-taxi-pedestrians (waiting-taxi-pedestrians - 1)
        set total-waiting-taxi (total-lifts + waiting-taxi-pedestrians)
        set lifting-time ticks
      ]
    ][
      if check-waiting-pedestrians-x [
        ;ifelse direction = 3 [ set ycor xcor - 0.5 ] [set ycor ycor + 0.5]
        set speed 0
        set lifting true
        set total-lifts (total-lifts + 1)
        set waiting-taxi-pedestrians (waiting-taxi-pedestrians - 1)
        set total-waiting-taxi (total-lifts + waiting-taxi-pedestrians)
        set lifting-time ticks
      ]
    ]
  ]
  if lifting [
    let difticks (ticks - lifting-time)
    if (ticks - lifting-time) > 25 [
      set speed 0.5
      set lifting false
      set is-free false
    ]
  ]
end

to-report check-waiting-pedestrians-x
  let taxi-dir direction
  let xpos xcor
  let answer false
  ask pedestrians with [direction = taxi-dir and waiting-taxi][
    if round xpos = round xcor [
      set waiting-taxi false
      set answer true
      die
    ]
  ]
  report answer
end

to-report check-waiting-pedestrians-y
  let taxi-dir direction
  let ypos ycor
  let answer false
  ask pedestrians with [direction = taxi-dir and waiting-taxi][
    if round ypos = round ycor [
      set answer true
      die
    ]
  ]
  report answer
end
;a donde mira \ para donde se va a mover si cambia \ desde donde arranca a moverse \ cuanto delta de a donde se mueve en y para ver \ en que punto de x arranco
;\ para donde arranco mirando \ cuanto mira de min \ cuanto mira de max
to y-lane-seeker [look-heading move-heading move-xcor move-ycor other-lane-xcor current-xcor current-heading ymin ymax]
  if not wanna-turn and y-can-swap ymin ymax direction target-lane[
    if floor ycor != min-pycor [set ycor ycor - 1]
    set heading look-heading
    set xcor other-lane-xcor
    ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
      set ycor ycor + 1
      ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
        if ceiling ycor != max-pycor [set ycor ycor + 1]
        ;if not any? other turtles-on patch-ahead 0[set pcolor car-color]
        ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
          ;show "swap"
          set xcor move-xcor
          set current-xcor xcor
          set ycor ycor - 1
          set heading move-heading
          set swapping-lanes true
          move-forward
          set target-lane ifelse-value (target-lane = 0) [1][0]
        ] [set heading current-heading
           set xcor current-xcor
           set ycor ycor - 1
         ]
      ] [set heading current-heading
           set xcor current-xcor
         ]
    ][set heading current-heading
      set xcor current-xcor
      set ycor ycor + 1
    ]
  ]
  if round abs xcor = 2 [ set xcor current-xcor]
end

to x-lane-seeker [look-heading move-heading move-ycor move-xcor other-lane-ycor current-ycor current-heading xmin xmax]
  if not wanna-turn and x-can-swap xmin xmax direction target-lane[
    if floor xcor != min-pxcor [set xcor xcor - 1]
    set heading look-heading
    set ycor other-lane-ycor
    ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
      set xcor xcor + 1
      ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
        if ceiling xcor != max-pxcor [set xcor xcor + 1]
        ;if not any? other turtles-on patch-ahead 0[set pcolor car-color]
        ifelse not any? other turtles-on patch-ahead 0[; se fija que no haya ningun auto al lado
          ;show "swap"
          set ycor move-ycor
          set current-ycor ycor
          set xcor xcor - 1
          set heading move-heading
          set swapping-lanes true
          move-forward
          set target-lane ifelse-value (target-lane = 0) [1][0]
        ] [set heading current-heading
           set ycor current-ycor
           set xcor xcor - 1
         ]
      ] [set heading current-heading
           set ycor current-ycor
         ]
    ][set heading current-heading
      set ycor current-ycor
      set xcor xcor + 1
    ]
  ]
  if round abs ycor = 2 [ set ycor current-ycor]
end

to-report y-can-swap [ymin ymax currentDir targetLane]
  let can? true
  let trouble-cars other cars with [ycor < ymax and ycor > ymin and direction = currentDir and targetLane = current-lane and swapping-lanes]
  let trouble-cars2 other cars with [ direction = currentDir and swapping-lanes]
  if count trouble-cars > 0  or count trouble-cars2 > 0 [ set can? false]
  report can?
end

to-report x-can-swap [xmin xmax currentDir targetLane]
  let can? true
  let trouble-cars other cars with [ xcor < xmax and xcor > xmin and direction = currentDir and targetLane = current-lane]
  let trouble-cars2 other cars with [ direction = currentDir and swapping-lanes]
  if count trouble-cars > 0  or count trouble-cars2 > 0 [ set can? false]
  report can?
end

to choose-new-lane ; turtle procedure
  ; Choose a new lane among those with the minimum
  ; distance to your current lane (i.e., your ycor).
  if direction = 0 and ycor > 7[
    let current-xcor xcor
    set xcor -2
    ifelse not any? other turtles-on patch-ahead 0 [
      ifelse target-lane = 0 [
        y-lane-seeker 270 245 -1.8 1 -3 -1 180 (ycor - 2) (ycor + 100)
      ][
        y-lane-seeker 90 120 -2.2 1 -1 -3 180 (ycor - 2) (ycor + 100)
      ]
    ][
      set xcor current-xcor
    ]
  ]
  if direction = 1 and xcor < 7[
    let current-ycor ycor
    set ycor -2
    ifelse not any? other turtles-on patch-ahead 0 [
      ifelse target-lane = 0 [
        x-lane-seeker 180 115 -1.8 1 -3 -1 90 (xcor - 100) (xcor + 2)
      ][
        x-lane-seeker 0 50 -2.2 1 -1 -3 90 (xcor - 100) (xcor + 2)
      ]
    ][
      set ycor current-ycor
    ]
  ]
  if direction = 2 and ycor < 7[
    let current-xcor xcor
    set xcor 2
    ifelse not any? other turtles-on patch-ahead 0 [
      ifelse target-lane = 0 [
        y-lane-seeker 90 60 1.8 1 3 1 0 (ycor - 100) (ycor + 2)
      ][
        y-lane-seeker 270 300 2.2 1 1 3 0 (ycor - 100) (ycor + 2)
        ]
    ][set xcor current-xcor ]
  ]
  if direction = 3 and xcor > 7[
    let current-ycor ycor
    set ycor 2
    ifelse not any? other turtles-on patch-ahead 0 [
      ifelse target-lane = 0 [
        x-lane-seeker 0 315 1.8 1 3 1 270 (xcor - 2) (xcor + 100)
      ][
        x-lane-seeker 180 225 2.2 1 1 3 270 (xcor - 2) (xcor + 100)
      ]
    ][
      set ycor current-ycor
    ]
  ]
  set patience max-patience
end

to move-to-target-lane
  if (direction = 0)[
    if target-lane = 1 and swapping-lanes and xcor < -2.5 [
      set xcor -3
      set heading 180
      set swapping-lanes false
      set current-lane 1
    ]
    if target-lane = 0 and swapping-lanes and xcor > -1.5 [
      set xcor -1
      set heading 180
      set swapping-lanes false
      set current-lane 0
    ]
  ]
  if (direction = 1)[
    if target-lane = 1 and swapping-lanes and ycor < -2.5 [
      set ycor -3
      set heading 90
      set swapping-lanes false
      set current-lane 1
    ]
    if target-lane = 0 and swapping-lanes and ycor > -1.5 [
      show "swaper"
      set ycor -1
      set heading 90
      set swapping-lanes false
      set current-lane 0
    ]
  ]
  if (direction = 2)[
    if target-lane = 1 and swapping-lanes and xcor > 2.5 [
      set xcor 3
      set heading 0
      set swapping-lanes false
      set current-lane 1
    ]
    if target-lane = 0 and swapping-lanes and xcor < 1.5 [
      set xcor 1
      set heading 0
      set swapping-lanes false
      set current-lane 0
    ]
  ]
  if (direction = 3)[
    if target-lane = 1 and swapping-lanes and ycor > 2.5 [
      set ycor 3
      set heading 270
      set swapping-lanes false
      set current-lane 1
    ]
    if target-lane = 0 and swapping-lanes and ycor < 1.5 [
      set ycor 1
      set heading 270
      set swapping-lanes false
      set current-lane 0
    ]
  ]
  set patience max-patience
end

to turning-setup
  if (current-lane = 1 and wanna-turn-left) [
    set wanna-turn-left false
  ]
  if (current-lane = 0 and wanna-turn) [
    set wanna-turn false
  ]
  set analyzed true
end

to prepare-to-turn
  let turning-speed 0.1
  if (turn = false and wanna-turn = true and direction = 0 and floor ycor = 4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn = true and direction = 1 and ceiling xcor = -4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn = true and direction = 2 and ceiling ycor = -4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn = true and direction = 3 and floor xcor = 4)[if(speed > turning-speed)[slow-down-car]]
end

to turn-ifturn
  if (turn = false and wanna-turn = true and direction = 0 and round ycor = 3) [
    turn-right false 3
    set direction 3
  ]
  if (turn = false and wanna-turn = true and direction = 1 and round xcor = -3) [
    turn-right true -3
    set direction 0
  ]
  if (turn = false and wanna-turn = true and direction = 2 and round ycor = -3) [
    turn-right false -3
    set direction 1
  ]
  if (turn = false and wanna-turn = true and direction = 3 and round xcor = 3) [
    turn-right true 3
    set direction 2
  ]
end

to turn-right [x-or-y? cor]
  set heading (heading + 45)
  set heading (heading + 45)
  ifelse (x-or-y? = true) [setxy cor ycor] [setxy xcor cor]
  set turn true
  set wanna-turn false
  set pass-intersection true
end

to pedestrian-turn-right
  ifelse heading = 270
  [set heading 0
  ][
    set heading (heading + 90)
  ]
  set turn true
  ;set color black
  set direction get-correct-heading
end

to pedestrian-turn-left
  set heading (heading - 90)
  set turn true
  ;set color cyan
  set direction get-correct-heading
end

to-report get-correct-heading
  if heading = 0 [
    report 2
  ] if heading = 90 [
    report 1
  ] if heading = 180 [
    report 0
  ] if heading = 270 [
   report 3
  ]
 report 4
end

to prepare-to-turn-left
  let turning-speed 0.1
  if (turn = false and wanna-turn-left = true and direction = 0 and floor ycor = 4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn-left = true and direction = 1 and ceiling xcor = -4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn-left = true and direction = 2 and ceiling ycor = -4)[if(speed > turning-speed)[slow-down-car]]
  if (turn = false and wanna-turn-left = true and direction = 3 and floor xcor = 4)[if(speed > turning-speed)[slow-down-car]]
end

to turn-left-ifturn
  if (turn = false and wanna-turn-left = true and direction = 0 and round ycor = 3) [set heading 135]
  if (turn = false and wanna-turn-left = true and direction = 1 and round xcor = -3) [set heading 45]
  if (turn = false and wanna-turn-left = true and direction = 2 and round ycor = -3) [set heading 315]
  if (turn = false and wanna-turn-left = true and direction = 3 and round xcor = 3) [set heading 225]
end

to turn-left-movement [x-or-y? cor]
  show heading
  set heading (heading - 45)
  show heading
  ;ifelse (x-or-y? = true) [setxy cor ycor] [setxy xcor cor]
end

to complete-turn-left
  if (direction = 0 and round ycor = -1 and wanna-turn-left and not turn) [
    set heading 90
    set ycor -1.25
    set turn true
  ]
  if (direction = 1 and round xcor = 1 and not turn) [
    set heading 0
    set xcor 1.25
    set turn true
  ]
  if (direction = 2 and round ycor = 1 and not turn) [
    set heading 270
    set ycor 1.25
    set turn true
  ]
  if (direction = 3 and round xcor = -1 and not turn) [
    set heading 180
    set xcor -1.25
    set turn true
  ]
end

to-report stop-on-red?
  if (direction = 0 and (round ycor = 6)) [
    report true
  ]
  if (direction = 1 and (round xcor = -6)) [
    report true
  ]
  if (direction = 2 and (round ycor = -6)) [
    report true
  ]
  if (direction = 3 and (round xcor = 6)) [
    report true
  ]
  report false
end

to-report stop-on-pedestrian-red?
  if (direction = 0 and (round ycor = 4)) [
    report true
  ]
  if (direction = 1 and (round xcor = -4)) [
    report true
  ]
  if (direction = 2 and (round ycor = -4)) [
    report true
  ]
  if (direction = 3 and (round xcor = 4)) [
    report true
  ]
  report false
end

to set-proper-position
  if direction = 0 and (round ycor = 3) [set ycor 3.5]
  if direction = 1 and (round xcor = -3) [set xcor -3.5]
  if direction = 2 and (round ycor = -3) [set ycor -3.5]
  if direction = 3 and (round xcor = 3) [set xcor 3.5]
end

to-report crossed?
  if (direction = 0 and (round ycor < 3)) [
    report true
  ]
  if (direction = 1 and (round xcor > -3)) [
    report true
  ]
  if (direction = 2 and (round ycor > -3)) [
    report true
  ]
  if (direction = 3 and (round xcor < 3)) [
    report true
  ]
  report false
end

to-report distance-to-red
  if (direction = 0) [
    report distancexy -3 5
  ]
  if (direction = 1) [
    report distancexy -5 -3
  ]
  if (direction = 2) [
    report distancexy -3 -5
  ]
  if (direction = 3) [
    report distancexy 5 3
  ]
end

to-report pass-intersection?
  if (turn = true)[
    report true
  ]
  if (direction = 0 and (round ycor < -5)) [
    report true
  ]
  if (direction = 1 and (round xcor > 5)) [
    report true
  ]
  if (direction = 2 and (round ycor > 5)) [
    report true
  ]
  if (direction = 3 and (round xcor < -5)) [
    report true
  ]
  report false
end

to-report inside-of-intersection?
  if(xcor > -3 or xcor < 3)[report true]
  if(ycor > -3 or ycor < 3)[report true]
  report false

end

to-report out-of-intersection
  if(xcor < -3 or xcor > 3)[report true]
  if(ycor < -3 or ycor > 3)[report true]
  report false

end

to slow-down-car ; turtle procedure
  set speed (speed - deceleration)
  if speed < 0 [ set speed 0 ]
  ; every time you hit the brakes, you loose a little patience
  set patience patience - 1
end

to speed-up-car ; turtle procedure
  set speed (speed + acceleration)
  if speed > top-speed [ set speed top-speed ]
end

to-report direction-distance
  ifelse (direction = 0 or direction = 2)[
   report y-distance
  ][
   report x-distance
  ]
end

to-report toogle-distance
  ifelse (direction = 1 or direction = 3)[
   report y-distance
  ][
   report x-distance
  ]
end


to-report x-distance
  report distancexy [ xcor ] of myself ycor
end

to-report y-distance
  report distancexy xcor [ ycor ] of myself
end


to-report elapsed-flow? [ time-length ]
  report (ticks - flow-time-change) > time-length
end

to create-remove-dead-car [x-position y-position]
  let before count cars with [dead]
  ask cars with [ dead ] [
    if round xcor = round x-position and round ycor = round y-position[
      die
    ]
  ]
  let after count cars with [dead]
  if (after - before) = 0 [
    let h 0
    let d 0
    if x-position < 5 and x-position > 0 [
      set h 0
      set d 2
    ]
    if x-position > -5 and x-position < 0 [
      set h 180
      set d 0
    ]
    if y-position < 5 and y-position > 0 [
      set h 270
      set d 3
    ]
    if y-position > -5 and y-position < 0 [
      set h 90
      set d 1
    ]
    ask patch x-position y-position [
      if (pcolor = black) [
        sprout-cars 1 [
          set heading h
          set color white
          set size 1
          setxy round x-position round y-position
          set target-lane 0
          set first-stop-time 0
          set waiting-time 0
          set pass-intersection false
          set top-speed 0
          set speed 0
          set patience 60
          set direction d
          set lanecor 0
          set current-lane 0
          set swapping-lanes false
          set turn false
          set sensed false
          set ambulance false
          set taxi false
          set dead true
          set collided false
        ]
      ]
    ]
  ]

end

to create-pedestrian [pedestrian-direction lane]
  if (random 2500 < pedestrian-freq) [
    let x 0
    let y 0
    let h 0
    let lanecor2 0

    if pedestrian-direction = 0
    [
      ifelse lane = 0 [set x get-random-position 4 5.5]
      [set x get-random-position -5.5 -4]
      set y max-pycor
      set lanecor2 x
      set h 180
    ]
    if pedestrian-direction = 1
    [ set x min-pxcor
      ifelse lane = 0 [set y get-random-position 4 5.5]
      [set y get-random-position -5.5 -4]
      set lanecor2 y
      set h 90
    ]
    if pedestrian-direction = 2
    [ ifelse lane = 0 [set x get-random-position -5.5 -4]
      [set x get-random-position 4 5.5]
      set y min-pycor
      set lanecor2 x
      set h 0
    ]
    if pedestrian-direction = 3[
      set x max-pxcor
      ifelse lane = 0 [set y get-random-position -5.5 -4]
      [set y get-random-position 4 5.5]
      set lanecor2 y
      set h 270
    ]

    if pedestrians-on-creation-area? x y pedestrian-direction [
      create-pedestrians 1 [
        set heading h
        set color pink
        set size 0.8
        setxy x y
        ;set target-lane lane
        ;set first-stop-time 0
        set waiting-time 0
        set pass-intersection false
        set top-speed max-speed
        set speed random-float (0.075 - 0.045) + 0.045
        ;set patience 60
        set direction pedestrian-direction
        set lanecor lanecor2
        set current-lane lane
        ;set swapping-lanes false
        set turn false
        ;set sensed false
        set dead false
        set wanna-turn-right false
        set wanna-turn-left false
        set wanna-turn-before false
        set wanna-turn-after false
        set waiting-taxi false
        if pedestrian-wanna-turn?[
          ifelse random 100 < 50 [
            set wanna-turn-right pedestrian-wanna-turn?
            set color brown + 12
          ][ set wanna-turn-left pedestrian-wanna-turn?
            set color brown - 12
          ]
          ifelse random 100 < 50 [
            set wanna-turn-before pedestrian-wanna-turn?
          ][ set wanna-turn-after pedestrian-wanna-turn?]
        ]
      ]
    ]
  ]
end

to create-car [car-direction lane freq]
  if (random 800 < freq) [
    let x 0
    let y 0
    let h 0
    let lanecor2 0

    if car-direction = 0
    [ set x -1 + lane * (-2)
      set y max-pycor
      set lanecor2 x
      set h 180
    ]
    if car-direction = 1
    [ set x min-pxcor
      set y -1 + lane * (-2)
      set lanecor2 y
      set h 90
    ]
    if car-direction = 2
    [ set x 1 + lane * (2)
      set y min-pycor
      set lanecor2 x
      set h 0
    ]
    if car-direction = 3[
      set x max-pxcor
      set y 1 + lane * (2)
      set lanecor2 y
      set h 270
    ]

    if cars-on-creation-area? x y car-direction [
      create-cars 1 [
        set heading h
        set color car-color
        set size 1
        setxy x y
        set target-lane lane
        set first-stop-time 0
        set waiting-time 0
        set pass-intersection false
        set top-speed max-speed
        set speed top-speed / 2
        set patience 60
        set direction car-direction
        set lanecor lanecor2
        set current-lane lane
        set swapping-lanes false
        set turn false
        set sensed false
        set dead false
        set wanna-turn false
        set wanna-turn-left false
        set analyzed false
        set ambulance false
        set taxi false
        set is-free true
        set lifting false
        set lifting-time ticks
        set collided false
        if (current-lane = 1 and random 800 < taxi-freq) [
          set taxi true
          set color yellow
        ]
        if (not taxi and check-if-ambulance and current-lane = 1 and random 800 < ambulance-freq) [
          set ambulance true
          set color green
          set ambulance-counter (ambulance-counter + 1)
        ]
        ifelse (current-lane = 1 and not wanna-turn-left) [
          set wanna-turn ifelse-value (random 100 < turn-freq) [true] [false]
        ][
          set wanna-turn false
        ]
        ifelse (current-lane = 0 and not wanna-turn and not swapping-lanes) [
          set wanna-turn-left true
          set wanna-turn-left ifelse-value (random 50 < turn-left-freq) [true] [false]
        ][
          set wanna-turn-left false
        ]
      ]
    ]
  ]
end

to-report get-random-position [p1 p2]
  report random-float (p2 - p1) + p1
end

to-report check-if-ambulance
  let myDir direction
  let ambulances other cars with [ambulance and not (direction = myDir)]
  ifelse count ambulances > 0 [ report false ] [report true]
end

to-report pedestrian-on-turn-position? [dir before posx posy]
  if direction = 0 [
    ifelse before = true [
      if posy <= 5 and posy >= 4 [
        report true
      ]
    ][
      if posy <= -4 and posy >= -5 [
        report true
      ]
    ]
  ]
  if direction = 1 [
    ifelse before = true [
      if posx <= -5 and posx >= -4 [
        report true
      ]
    ][
      if posx <= 5 and posx >= 4 [
        report true
      ]
    ]
  ]
  if direction = 2 [
    ifelse before = true [
      if posy <= -4 and posy >= -5 [
        report true
      ]
    ][
      if posy <= 5 and posy >= 4 [
        report true
      ]
    ]
  ]
  if direction = 3 [
    ifelse before = true [
      if posx <= 5 and posx >= 4 [
        report true
      ]
    ][
      if posx <= -4 and posx >= -5 [
        report true
      ]
    ]
  ]
  report false
end

to-report cars-on-creation-area? [xa ya dir]
  if dir = 0 and ( (not any? cars-on patch xa ya) and (not any? cars-on patch xa (ya - 1)))[
    report true
  ]
  if dir = 1 and ( (not any? cars-on patch xa ya) and (not any? cars-on patch (xa + 1) ya))[
    report true
  ]
  if dir = 2 and ( (not any? cars-on patch xa ya) and (not any? cars-on patch xa (ya + 1)) )[
    report true
  ]
  if dir = 3 and ( (not any? cars-on patch xa ya) and (not any? cars-on patch (xa - 1) ya))[
    report true
  ]
  report false
end

to-report pedestrian-wanna-turn?
  if random 100 < pedestrian-turn-freq [
    report true
  ]
  report false
end

to-report pedestrians-on-creation-area? [xa ya dir]
  if dir = 0 and ( (not any? pedestrians-on patch xa ya) and (not any? pedestrians-on patch xa (ya - 1)))[
    report true
  ]
  if dir = 1 and ( (not any? pedestrians-on patch xa ya) and (not any? pedestrians-on patch (xa + 1) ya))[
    report true
  ]
  if dir = 2 and ( (not any? pedestrians-on patch xa ya) and (not any? pedestrians-on patch xa (ya + 1)) )[
    report true
  ]
  if dir = 3 and ( (not any? pedestrians-on patch xa ya) and (not any? pedestrians-on patch (xa - 1) ya))[
    report true
  ]
  report false
end

to-report car-color
  ; give all cars a blueish color, but still make them distinguishable
  report one-of [ blue red cyan pink ] + 1.5 + random-float 1.0
end

to-report free [ road-patches ] ; turtle procedure
  let this-car self
  report road-patches with [
    not any? cars-here with [ self != this-car ]
  ]
end

to-report number-of-lanes
  ; To make the number of lanes easily adjustable, remove this
  ; reporter and create a slider on the interface with the same
  ; name. 8 lanes is the maximum that currently fit in the view.
  report 2
end

to select-car
  ; allow the user to select a different car by clicking on it with the mouse
  if mouse-down? [
    let mx mouse-xcor
    let my mouse-ycor
    if any? turtles-on patch mx my [
      set selected-car one-of turtles-on patch mx my
      ask selected-car [ set color red ]
;      show [speed] of selected-car
      show [xcor] of selected-car
      show [ycor] of selected-car
      show [speed] of selected-car
      show [top-speed] of selected-car
      show [target-lane] of selected-car
      show [patience] of selected-car
      show [direction] of selected-car
      show [current-lane] of selected-car
      show [lanecor] of selected-car
      show [turn] of selected-car
      show [wanna-turn] of selected-car
      show [wanna-turn-left] of selected-car
      show [first-stop-time] of selected-car
      show [waiting-time] of selected-car
      show [pass-intersection] of selected-car
      show [swapping-lanes] of selected-car
      show [sensed] of selected-car
      show [analyzed] of selected-car
      show [dead] of selected-car

;      show [is-free] of selected-car
;      show [lifting] of selected-car
;      show [lifting-time] of selected-car
;      ask selected-car [
;        let security-distance (speed / deceleration) * speed
;        show security-distance
;
;        let blocking-car nobody
;        let blocking-cars other cars in-cone (ceiling security-distance + min-distance) 30
;        set blocking-car min-one-of blocking-cars [ distance myself ]
;
;
;        if(blocking-car != nobody) [
;          show "blocking-car"
;          show [speed] of blocking-car
;          show [wanna-turn] of blocking-car
;          if ((distance blocking-car) <= security-distance + min-distance + speed) and (speed >  [speed] of blocking-car)[
;            show "slow-down-car"
;            show distance blocking-car
;          ]
;          if ((distance blocking-car) <= speed + min-distance )[
;            show "equal velocity 1"
;            show distance blocking-car
;          ]
;
;          if([speed] of blocking-car = 0 and (distance blocking-car) <= speed + min-distance )[
;            show "equal velocity 2"
;            show distance blocking-car
;          ]
;          show blocking-car
;          ask blocking-car [
;            set color cyan
;            show xcor
;            show ycor
;          ]
;          show [speed] of blocking-car
;        ]
;        show wanna-turn
;        show wanna-turn-left
;
;      ]
      display
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
215
10
988
784
-1
-1
15.0
1
12
1
1
1
0
0
0
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
13
22
79
55
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
12
65
79
98
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

SLIDER
7
219
184
252
green-length
green-length
1
500
194.0
1
1
NIL
HORIZONTAL

SLIDER
8
272
180
305
freq-east
freq-east
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
8
322
180
355
freq-north
freq-north
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
7
371
179
404
freq-south
freq-south
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
8
420
180
453
freq-west
freq-west
0
100
1.0
1
1
NIL
HORIZONTAL

BUTTON
95
21
176
54
go once
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

SLIDER
9
512
181
545
acceleration
acceleration
0.001
0.01
0.008
0.001
1
NIL
HORIZONTAL

SLIDER
8
555
180
588
max-speed
max-speed
0.1
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
602
182
635
deceleration
deceleration
0.01
0.1
0.06
0.01
1
NIL
HORIZONTAL

SLIDER
11
648
183
681
max-patience
max-patience
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
93
66
177
101
NIL
select-car
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
8
469
181
502
turn-freq
turn-freq
0
100
38.0
1
1
NIL
HORIZONTAL

MONITOR
1006
15
1132
60
cars waiting south
count cars with [direction = 0 and not pass-intersection? and out-of-intersection]
17
1
11

MONITOR
1006
79
1131
124
cars waiting east
count cars with [direction = 1 and not pass-intersection? and out-of-intersection]
17
1
11

MONITOR
1008
142
1133
187
cars waiting north
count cars with [direction = 2 and not pass-intersection? and out-of-intersection]
17
1
11

MONITOR
1009
203
1133
248
cars waiting west
count cars with [direction = 1 and not pass-intersection? and out-of-intersection]
17
1
11

PLOT
1008
412
1774
781
average waiting-time in time
la
NIL
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" "plot average-waiting-time"

MONITOR
1496
799
1628
844
average-waiting-time
average-waiting-time
17
1
11

MONITOR
1345
19
1404
64
NIL
flow-x
17
1
11

MONITOR
1345
83
1406
128
NIL
flow-y
17
1
11

MONITOR
1146
15
1243
60
NIL
total-cars-0
17
1
11

MONITOR
1150
78
1239
123
NIL
total-cars-1
17
1
11

MONITOR
1149
142
1238
187
NIL
total-cars-2
17
1
11

MONITOR
1149
203
1238
248
NIL
total-cars-3
17
1
11

SLIDER
1520
96
1692
129
flow-time
flow-time
0
4000
1700.0
50
1
ticks
HORIZONTAL

MONITOR
1249
16
1331
61
NIL
flow-cars-0
17
1
11

MONITOR
1255
78
1338
123
NIL
flow-cars-1
17
1
11

MONITOR
1256
139
1339
184
NIL
flow-cars-2
17
1
11

MONITOR
1253
202
1339
247
NIL
flow-cars-3
17
1
11

MONITOR
1418
19
1506
64
NIL
total-flow-x
17
1
11

MONITOR
1419
82
1507
127
NIL
total-flow-y
17
1
11

MONITOR
1008
793
1119
838
NIL
total-patches-x
17
1
11

MONITOR
1262
796
1372
841
NIL
total-patches-y
17
1
11

MONITOR
1126
796
1253
841
NIL
intersection-width
17
1
11

MONITOR
1379
799
1477
844
NIL
max-capacity
17
1
11

MONITOR
1011
315
1116
360
NIL
x-waiting-cars
17
1
11

MONITOR
1126
315
1230
360
NIL
y-waiting-cars
17
1
11

SWITCH
33
117
151
150
intelligent
intelligent
0
1
-1000

MONITOR
1652
800
1767
845
NIL
green-sequence
17
1
11

SLIDER
8
695
184
728
pedestrian-turn-freq
pedestrian-turn-freq
0
100
86.0
1
1
NIL
HORIZONTAL

SLIDER
10
743
183
776
pedestrian-freq
pedestrian-freq
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
10
790
183
823
turn-left-freq
turn-left-freq
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
10
835
183
868
taxi-freq
taxi-freq
0
100
78.0
1
1
NIL
HORIZONTAL

SLIDER
216
836
392
869
waiting-for-taxi-freq
waiting-for-taxi-freq
0
100
29.0
1
1
NIL
HORIZONTAL

MONITOR
1369
352
1537
397
waiting-taxi-pedestrians
waiting-taxi-pedestrians
1711
1
11

MONITOR
1369
255
1441
300
total-lifts
total-lifts
17
1
11

MONITOR
1248
313
1323
358
Collisions
collisions
17
1
11

MONITOR
1011
260
1119
305
NIL
x-turning-waiting-cars
17
1
11

MONITOR
1126
260
1229
305
NIL
y-turning-waiting-cars
17
1
11

MONITOR
1246
260
1326
305
NIL
pedestrians-waiting
17
1
11

SLIDER
6
172
214
205
set-ticks-to-remove-collided
set-ticks-to-remove-collided
0
500
320.0
1
1
NIL
HORIZONTAL

SLIDER
419
792
592
825
x-factor
x-factor
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
605
792
778
825
y-factor
y-factor
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
420
835
593
868
x-turn-factor
x-turn-factor
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
606
836
779
869
y-turn-factor
y-turn-factor
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SLIDER
785
838
958
871
pedestrian-factor
pedestrian-factor
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

SWITCH
789
795
955
828
collisions-enabled
collisions-enabled
0
1
-1000

MONITOR
1368
200
1510
245
ticks in green
ticks - ticks-at-last-change
17
1
11

MONITOR
1369
303
1487
349
NIL
max-waiting-car
17
1
11

MONITOR
1590
145
1683
191
NIL
x-times / 12
17
1
11

MONITOR
1592
198
1682
244
NIL
y-times / 12
17
1
11

MONITOR
1592
252
1697
298
NIL
x-t-times / 12
17
1
11

MONITOR
1592
305
1695
351
NIL
y-t-times / 12
17
1
11

MONITOR
1593
359
1695
405
NIL
(p-times) / 12
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 false 210 165 195 165
Line -7500403 false 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

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
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
