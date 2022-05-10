breed [ empresas empresa ]
breed [ agentes agente ]
globals [ porc-sanos ] ;;Calculo matemático del porcentaje de sanos
turtles-own [
wealth ;;capa de riqueza de los agentes
health ;;capa de salud de los agentes
price ;;precio establecido
ingresos ;; sumatorio de los ingresos de cada empresa
colorzona
mi-sede  ;; la sede elegida en cada momento por los agentes
]

patches-own [
sede-inicial ;;Servirá para colorear las zonas iniciales
]

to setup
  clear-all
  setup-agentes ;;se crean los agentes de esta simulación
  setup-empresas ;;las empresas, en este caso, se crean como turtles
  zona ;;En un primer momento, es importante colorear las zonas asignadas a cada empresa
  reset-ticks
  set porc-sanos count turtles with [health >= 800] / count turtles * 100
end

to setup-agentes
   create-agentes numero-de-agentes [ ;;creamos los agentes como breeds
        setxy random-xcor random-ycor ;;aleatoriamente distribuidos por el mundo
        set shape "person"
        set wealth 1000 ;;heterogeneidad en la distribución de la riqueza
        set health 1000 ;;todos los agentes parten con la misma salud
        set size 1
        set color black
   ]
end

to setup-empresas
   create-empresas numero-de-empresas [
      setxy random-pxcor random-pycor ;;aleatoriamente ubicadas *información asimétrica y heterogeneidad*
      set shape "house"
      set price precios
      set size 2 ;; la empresa tendrá un tamaño mayor para facilitar su localización
      set colorzona one-of base-colors
      set color colorzona + 2
   ]
end

to zona
   ask patches [
      set sede-inicial min-one-of empresas [distance myself]
      set pcolor ([colorzona] of sede-inicial)
   ]
end

to go

 if not any? agentes [ stop ];; cuando no queden agentes, la simulación se detiene

 ask agentes [
    ifelse wealth >= salario and health >= pasaje  ;; su riqueza le permitirá recuperarse (y asumir salario, precios>=salario) y su salud moverse

        [
        ifelse health > 32 * pasaje
            [ rt random-float 360
              lt random-float 360 ]
            [ set mi-sede min-one-of empresas [distance myself]
              facexy ([xcor] of mi-sede) ([ycor] of mi-sede)
            ]
        fd 0.5
        set health health - pasaje
        set wealth wealth - salario
        ask one-of agentes [set wealth wealth + salario]
        if any? empresas-here
           [ let sede empresas-here
             set wealth wealth - precios
             ask sede [set ingresos ingresos + precios]
             set health 1000
           ]
       ]
       [
       if wealth > 0 [
         let aux wealth
         let heredero one-of agentes
         ask heredero [set wealth wealth + aux]
         ]
         die
       ]
 ]
 tick

end
@#$#@#$#@
GRAPHICS-WINDOW
242
62
676
497
-1
-1
12.91
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
38
181
101
214
setup
setup\n
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
147
181
210
214
go
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
38
225
210
258
pasaje
pasaje
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
38
269
210
302
salario
salario
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
38
311
210
344
precios
precios
10
100
10.0
10
1
NIL
HORIZONTAL

SLIDER
38
95
210
128
numero-de-agentes
numero-de-agentes
1
2000
1001.0
1
1
NIL
HORIZONTAL

SLIDER
38
135
210
168
numero-de-empresas
numero-de-empresas
1
9
5.0
1
1
NIL
HORIZONTAL

PLOT
708
342
958
492
Relación de Agentes
Tiempo
Población
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Sanos" 1.0 0 -13791810 true "" "plot count turtles with [health >= 800] / count turtles * 100"

MONITOR
907
389
957
434
%
count turtles with [health >= 800] / count turtles * 100
2
1
11

PLOT
709
85
957
287
Reparto
tiempo
% Ingresos
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"sede 1" 1.0 0 -2674135 true "" "plot [ingresos] of empresa (numero-de-agentes) / sum [ingresos + 0.1] of empresas * 100"
"sede 2" 1.0 0 -955883 true "" "plot [ingresos] of empresa (numero-de-agentes + 1) / sum [ingresos + 0.1] of empresas * 100"
"sede 3" 1.0 0 -1184463 true "" "plot [ingresos] of empresa (numero-de-agentes + 2) / sum [ingresos + 0.1] of empresas * 100"
"sede 4" 1.0 0 -10899396 true "" "plot [ingresos] of empresa (numero-de-agentes + 3) / sum [ingresos + 0.1] of empresas * 100"
"sede 5" 1.0 0 -13791810 true "" "plot [ingresos] of empresa (numero-de-agentes + 4) / sum [ingresos + 0.1] of empresas * 100"
"sede 6" 1.0 0 -7500403 true "" "if numero-de-empresas = 6 [plot [ingresos] of empresa (numero-de-agentes + 5) / sum [ingresos + 0.1] of empresas * 100]"
"sede 7" 1.0 0 -6459832 true "" "if numero-de-empresas = 7 [plot [ingresos] of empresa (numero-de-agentes + 6) / sum [ingresos + 0.1] of empresas * 100]"
"sede 8" 1.0 0 -13840069 true "" "if numero-de-empresas = 8 [plot [ingresos] of empresa (numero-de-agentes + 7) / sum [ingresos + 0.1] of empresas * 100]"
"sede 9" 1.0 0 -14835848 true "" "if numero-de-empresas = 9 [plot [ingresos] of empresa (numero-de-agentes + 8) / sum [ingresos + 0.1] of empresas * 100]"

MONITOR
987
64
1069
109
Zona Sede 1
count patches with [sede-inicial = empresa (numero-de-agentes)  ] / count patches * 100
4
1
11

MONITOR
987
116
1069
161
Zona Sede 2
count patches with [sede-inicial = empresa (numero-de-agentes + 1)] / count patches * 100
4
1
11

MONITOR
987
166
1069
211
Zona Sede 3
count patches with [sede-inicial = empresa (numero-de-agentes + 2)] / count patches * 100
4
1
11

MONITOR
989
218
1071
263
Zona Sede 4
count patches with [sede-inicial = empresa (numero-de-agentes + 3)] / count patches * 100
4
1
11

MONITOR
989
268
1071
313
Zona Sede 5
count patches with [sede-inicial = empresa (numero-de-agentes + 4)] / count patches * 100
4
1
11

MONITOR
1074
64
1177
109
Ingresos Sede 1
[ingresos] of empresa (numero-de-agentes)
2
1
11

MONITOR
1075
116
1178
161
Ingresos Sede 2
[ingresos] of empresa (numero-de-agentes + 1)
2
1
11

MONITOR
1075
167
1178
212
Ingresos Sede 3
[ingresos] of empresa (numero-de-agentes + 2)
2
1
11

MONITOR
1075
218
1178
263
Ingresos Sede 4
[ingresos] of empresa (numero-de-agentes + 3)
2
1
11

MONITOR
1075
268
1178
313
Ingresos Sede 5
[ingresos] of empresa (numero-de-agentes + 4)
2
1
11

MONITOR
1182
64
1242
109
Desvío 1
([ingresos] of empresa (numero-de-agentes) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes)] / count patches) * 100
4
1
11

MONITOR
1183
116
1243
161
Desvío 2
([ingresos] of empresa (numero-de-agentes + 1) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 1)] / count patches) * 100
4
1
11

MONITOR
1183
166
1243
211
Desvío 3
([ingresos] of empresa (numero-de-agentes + 2) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 2)] / count patches) * 100
4
1
11

MONITOR
1183
217
1243
262
Desvío 4
([ingresos] of empresa (numero-de-agentes + 3) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 3)] / count patches) * 100
4
1
11

MONITOR
1183
268
1243
313
Desvío 5
([ingresos] of empresa (numero-de-agentes + 4) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 4)] / count patches) * 100
4
1
11

MONITOR
989
318
1071
363
Zona Sede 6
count patches with [sede-inicial = empresa (numero-de-agentes + 5)] / count patches * 100
4
1
11

MONITOR
989
370
1071
415
Zona Sede 7
count patches with [sede-inicial = empresa (numero-de-agentes + 6)] / count patches * 100
4
1
11

MONITOR
989
422
1071
467
Zona Sede 8
count patches with [sede-inicial = empresa (numero-de-agentes + 7)] / count patches * 100
4
1
11

MONITOR
989
474
1071
519
Zona Sede 9
count patches with [sede-inicial = empresa (numero-de-agentes + 8)] / count patches * 100
4
1
11

MONITOR
1183
318
1243
363
Desvío 6
([ingresos] of empresa (numero-de-agentes + 5) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 5)] / count patches) * 100
4
1
11

MONITOR
1183
370
1243
415
Desvío 7
([ingresos] of empresa (numero-de-agentes + 6) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 6)] / count patches) * 100
4
1
11

MONITOR
1183
422
1243
467
Desvío 8
([ingresos] of empresa (numero-de-agentes + 7) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 7)] / count patches) * 100
4
1
11

MONITOR
1183
474
1243
519
Desvío 9
([ingresos] of empresa (numero-de-agentes + 8) / sum [ingresos + 0.1] of empresas - count patches with [sede-inicial = empresa (numero-de-agentes + 8)] / count patches) * 100
4
1
11

MONITOR
1075
318
1178
363
Ingresos Sede 6
[ingresos] of empresa (numero-de-agentes + 6)
4
1
11

MONITOR
1075
370
1178
415
Ingresos Sede 7
[ingresos] of empresa (numero-de-agentes + 6)
4
1
11

MONITOR
1075
422
1178
467
Ingresos Sede 8
[ingresos] of empresa (numero-de-agentes + 7)
4
1
11

MONITOR
1075
474
1178
519
Ingresos Sede 9
[ingresos] of empresa (numero-de-agentes + 8)
4
1
11

@#$#@#$#@
## QUÉ ES?

Este modelo representa una antítesis del conocido "Dilema de Hotelling" (1929). En el modelo original, diversas empresas compiten en precio y espacio por un mercado determinado compuesto por agentes (clientes) homogéneos. Sin embargo, el modelo siguiente utiliza empresas estáticas (tanto en precio como en espacio) y agentes heterogéneos (se mueven libremente por el espacio y no deciden realizar una transacción a partir del criterio del precio y distancia. 
El modelo, así, permite comprobar la validez del dilema mediante una aproximación más fiel a la realidad económica, además de suponer una contraposición total a los principios del modelo.

## CÓMO FUNCIONA

Cada agente (personas) tiene una dotación inicial de dinero y salud. Moverse cuesta salud (como un próxy de energía, por ejemplo), por lo que en cada movimiento se paga un #PASAJE. Los agentes interactúan unos con otros, se prestan servicios a cambio de un #SALARIO y así la economía se mueve. Cuando los agentes se cruzan con una SEDE, siempre y cuando se lo pueden permitir, pagan un #PRECIO para adquirir salud y volver a los valores iniciales (1000).

Las empresas (sedes) prestan el servicio de reiniciar los valores de la salud a niveles de dotación inicial. El objetivo de las empresas es prestar el servicio a la mayor cantidad de agentes posible. Se puede observar cómo aumentan los ingresos a partir de los gráficos.
 

## CÓMO UTILIZARLO

Pulsar SETUP para crear el mundo, con las empresas y agentes, que se situan en el espacio en una localización aleatoria.
Pulsar GO para que el modelo comience a funcionar. Una segunda pulsación detendrá el modelo. Se puede reanudar y parar siempre que se desee.

Con los deslizadores se puede decidir el numero de agentes, el numero de empresas, el coste del pasaje, el nivel de los salarios y los precios que establecen las empresas.


## ASPECTOS A OBSERVAR

Los agentes se mueven con un patrón aleatorio, de ahí que se consideren heterogéneos. Cambiarán de color tal que deciden qué SEDE es su favorita, lo cual ayudará a dilucidar el poder de mercado que le correspondería a cada Sede.

Dependiendo del número de empresas, el porcentaje de personas sanas dentro del mundo cambia, existiendo una relación positiva entre el numero de empresas y de personas sanas

Si aumenta el numero de empresas, el nivel total de ingresos de las empresas aumenta, relacionandose tambien el número de empresas con el nivel de transmisión de riqueza desde agentes a empresas. 

Se puede observar que la localización de una SEDE repercute en su nivel de ingresos, se puede intuir que las empresas más centradas obtienen unos ingresos mayores. Como la localización inicial de una empresa es aleatoria, la SEDE con mayores ingresos será diferente cada vez que se pulse el botón SETUP.

El nivel de ingresos de cada sede se puede observar en los MONITORES, así como el porcentaje de ingresos que corresponde a cada una de las empresas. 

El desvío es una "distancia" entre el nivel de ingresos que correspondería a esta empresa si todos sus clientes en cada momento le contrataran, respecto de la cantidad real que acaban contratando sus servicios.

## PARA INTENTAR

Intenta encontrar la relación entre el Dilema de Hotelling y una situación como la del modelo.

El poder de mercarcado y el nivel relativo de ingresos es una información muy importante para sacar conclusiones.

A partir de este modelo se pueden discutir implicaciones económicas tales como; la competencia en el mercado mejora la situación de agentes así como la de empresas, la localización de las empresas influye positivamente sobre los ingresos,las conductas y preferencias de los agentes económicos pueden no ser calculadas en muchos contextos, en mercados reales es muy común que las empresas compitan por el espacio y no tanto en precios, en el corto plazo, las diferencias entre las empresas mejor y peor situadas pueden ser muy significativas y crucial en el poder real de mercado... 

## FUTUROS MODELOS
En este modelo se supone información asimétrica, rigidez de precios y elevados costes de relocalización; se pueden proponer versiones en los que se suavicen estas rigideces y extraer conclusiones a partir de nuevos supuestos.

## CARACTERÍSTICAS DE NETLOGO 

Este modelo es puramente basado en agentes. La concepción misma del modelo invita a utilizar turtles en vez de patches. 

Se ha utilizado el comando base-colors, aún sabiendo que dos empresas podrían escoger aleatoriamente el mismo color, porque aportaba agilidad al código y es el inconveniente es puramente estético.

Se ha optado por utilizar breeds debido a la la flexibilidad que permite este comando, pudiendose haber utilizado otras vías, era la que mejor se adaptaba a las exigencias del modelo.



## MODELOS RELACIONADOS


*Hotelling´s Law
*Wolves and sheep
*Ants
*El Farol


## CREDITS AND REFERENCES

Este modelo forma parte del proyecto fin de máster de DAVID ACEVEDO BRITEZ
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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="primera" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>([ingresos] of empresa 1001 / sum [ingresos + 0.1] of empresas - count patches with [sede-elegida = empresa 1001] / count patches) * 100</metric>
    <metric>([ingresos] of empresa 1002 / sum [ingresos + 0.1] of empresas - count patches with [sede-elegida = empresa 1002] / count patches) * 100</metric>
    <metric>([ingresos] of empresa 1003 / sum [ingresos + 0.1] of empresas - count patches with [sede-elegida = empresa 1003] / count patches) * 100</metric>
    <metric>([ingresos] of empresa 1004 / sum [ingresos + 0.1] of empresas - count patches with [sede-elegida = empresa 1004] / count patches) * 100</metric>
    <metric>([ingresos] of empresa 1005 / sum [ingresos + 0.1] of empresas - count patches with [sede-elegida = empresa 1005] / count patches) * 100</metric>
    <enumeratedValueSet variable="precios">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-empresas">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-agentes">
      <value value="1001"/>
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
0
@#$#@#$#@
