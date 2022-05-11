extensions [dialog workspace widget sound export-the import-a store send-to fetch] globals [commands cdm code data copydata] patches-own [pid id typ sta pdata density]
;typ:-1:固定,0:无重力,1:有重力
;sta:0:固体,1:液体,2:气体
to net
  ;error "<iframe width=16px height=16px src=\"http://dan-ball.jp/en/javagame/dust/\">iframe not support.</iframe>"
  end
to startup
  ca
  set cdm "存档1"
  set place-size 0.1
  set place "粉末"
  set pause? false
  workspace:pause
  widget:toast "正在等待控制台响应初始化..."
  workspace:execute-command "widget:toast \"控制台已响应初始化\" workspace:hide \"code\" workspace:play"
  ;set code "<style> iframe {position: absolute; transform-origin: 0 0 0; transform: scale(3);} div.command {background-image:url('http://dan-ball.jp/images/m/dust_icon.png?1') ; background-size: 32px auto; background-repeat: repeat-y; background-attachment: scrolling; text-shadow: 1px 1px 100px #123456; } div.wrapper {background-image:url('http://dan-ball.jp/images/m/m_dustviewer.png') ; background-size: auto 100% ; text-shadow: 1px 1px 100px #123456; } </style><audio controls autoplay loop><source src=\"https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/Podington_Bear/Background/Podington_Bear_-_Graduation.mp3\" type=\"audio/mpeg\">audio not support.</audio>"
  ;set commands [-> workspace:execute-command "while [timer < 5] [] workspace:hide \"code\"" error code]
  ;workspace:execute-command "workspace:clear-commands print \" preparing for loading...\" carefully [(run commands)] [ifelse error-message != code [print \"failed to load, retry...\" startup setup] [print \"loading...\" (run commands)]]"
  end
to-report ext2 [i] report word (item ((i / 16) mod 16) "0123456789abcdef")(item (i mod 16) "0123456789abcdef") end
to-report apt [i] report position (item 0 i) "0123456789abcdef" * 16 + position (item 1 i) "0123456789abcdef" end
to showall
  let txt (word "<b>所有元素</b>·非空气元素数量：" count patches with [id != "空气"] "个·<run=showall><color=#513>刷新</color></run>\n")
  foreach range length gfdata 0 [n -> let col (item n gfdata 4) let rgbcol extract-rgb col set txt (word txt "·<color=#" ext2 first rgbcol ext2 item 1 rgbcol ext2 last rgbcol ">■</color>" (item n gfdata 0) "    " ifelse-value place != item n gfdata 0 [(word "<run=sel " n " showall><color=#531>选择</color></run>")]  ["<color=#0a0>已选</color>      "] "   <run=info " n "><color=#153>详细信息</color></run>\n")]
  user-message txt
  end
to sel [n] let col (item n gfdata 4) let rgbcol extract-rgb col set place item n gfdata 0 widget:toast (word "你选择了 <b><color=#" ext2 first rgbcol ext2 item 1 rgbcol ext2 last rgbcol ">■</color>" (item n gfdata 0) "</b>") end
to info [n]
  let col (item n gfdata 4) let rgbcol extract-rgb col 
  user-message (word "<b><color=#" ext2 first rgbcol ext2 item 1 rgbcol ext2 last rgbcol ">■</color>" (item n gfdata 0) "</b>·" ifelse-value place != item n gfdata 0 [(word "<run=sel " n " info " n"><color=#531>选择</color></run>")]  ["<color=#0a0>已选</color>"] "·<run=showall>返回</run>\n·固定状态：" ifelse-value item n gfdata 1 < 1 [""] ["不"] "固定\n·物质状态：" item item n gfdata 3 ["固""液""气"] "体\n·密度：" item n gfdata 2 "kg/m³\n·显示颜色：Netlogo-color:" col ",rgb:" rgbcol ",display:<color=#" ext2 first rgbcol ext2 item 1 rgbcol ext2 last rgbcol ">■</color>\n·已有数量：" count patches with [id = item n gfdata 0] "个")
  end
to setup
  cp ct cd reset-ticks
  ;数据格式：id typ density sta pcolor pdata ;density: xx kg/m³
  set data [
    ["空气" 1 1.29 2 0 0]
    ["墙" -1 99999 0 5 0]
    ["粉末" 1 900 0 36 0]
    ["水" 1 1000 1 blue 0]
    ["盐水" 1 1030 1 sky 0]
    ["盐" 1 800 0 9 0]
    ["油" 1 900 1 11 0]
    ["冰" -1 900 0 98 0]
    ["雪" 1 100 0 9.9 0]
    ["水蒸气" 1 1 2 8 0]
    ["易燃气体" 1 0.74 2 7 0]
    ["岩浆" 1 2000 1 orange 0]
    ["火" 1 1 1 red 0]
    ["石" 1 2200 0 4 0]
    ["钢铁" -1 7800 0 2 0]
    ["木头" -1 500 0 33 0]
    ["种子" 1 800 0 54 0]
    ["酸" 1 1840 1 57 0]
    ["水银" 1 13600 1 6 0]
    ["火炬" -1 99999 0 27 0]
    ["火花" 1 1.28 2 44 0]
    ["导火索" -1 99999 0 32 0]
    ["克隆" -1 99999 0 35 0]
  ]
  ask patches [set id "空气"]
  __change-topology false false
  ask patches with [count neighbors4 < 4] [set id "墙"]
  __change-topology true true
  ref
  go
  widget:toast "已重载资源"
  end
to go
  if not pause? and ticks mod round(4 / tsp) = 0 [ask patches with [id != "空气"] [
    set pid id
    if tc "酸" bf bf bl remove-item position "酸" gfdata 0 gfdata 0 [ask one-of neighbors4 with [member? id bf bf bl remove-item position "酸" gfdata 0 gfdata 0] [set id "空气" pref] set id "空气" pref]
    if tc "火炬" "水,盐水,岩浆" [set id "空气"]
    if tc "水" "盐" [ask one-of neighbors4 with [id = "盐"] [set id "空气"] set id "盐水"]
    if tc "盐" "岩浆" [set id "空气"]
    if tc "盐水" "火,火炬" [set id "盐"]
    if tc "种子" "水" and (tc "种子" "粉末" or tc "种子" "木头") [set pdata 1 + random 5]
    if id = "种子" and pdata > 0 and any? neighbors4 with [id = "空气"] [ask one-of neighbors4 with [id = "空气"] [set id "种子" set pdata [pdata - 1] of myself] set id "木头" set pdata 0]
    if tc "木头" "水" and random (10 / max list 1 (count neighbors4 with [id = "水"])) = 0 and any? neighbors4 with [id = "空气"] [ask one-of neighbors4 with [id = "空气"] [set id "种子"] if random 4 = 0 [ask one-of neighbors4 with [id = "水"] [set id "空气"]]]
    if tc "粉末" "火,岩浆,火炬" or tc "种子" "火,岩浆,火炬"[set id "火"]
    if tc "雪" "冰" [set id "冰"]
    if tc "雪" bf bf remove-item position "雪" gfdata 0 gfdata 0 [set id "水"]
    if tc "水" "冰" and random 2 = 0 [set id "冰"]
    if tc "冰" "岩浆,火炬" or (tc "冰" "火" and random (10 / max list 1 (count neighbors4 with [id = "火"])) = 0) [set id "水"]
    if tc "水" "岩浆" [ask one-of neighbors4 with [id = "岩浆"] [set id "石"] ifelse random 4 = 0 [set id "水蒸气"] [set id "空气"]]
    if tc "盐水" "岩浆" [ask neighbors4 with [id = "岩浆"] [set id "石"] ifelse random 4 = 0 [set id "水蒸气"] [set id "盐"]]
    if id = "水蒸气" and random 10 = 0 [set id "空气"]
    if id = "火花" and random 4 = 0 [set id "空气"]
    if tc "石" "岩浆" and random 100 / max list 1 (count neighbors4 with [id = "岩浆"]) = 0 [set id "岩浆"]
    if (tc "钢铁" "岩浆" or tc "水银" "岩浆") and random 500 / max list 1 (count neighbors4 with [id = "岩浆"]) = 0 [set id "岩浆"]
    if tc "钢铁" "水,盐水" and random 1000 / max list 1 (count neighbors4 with [id = "水" or id = "盐水"]) = 0 [set id "粉末"]
    if id = "火" and (random 10 = 0 or any? neighbors4 with [id = "水" or id = "雪" or id = "冰"]) [set id "空气"]
    if id = "木头" and pdata = 1 [if random 4 = 0 and any? neighbors with [id = "空气"] [ask one-of neighbors with [id = "空气"] [set id "火"]] if random 10 = 0 [set id "粉末" set pdata 0]]
    if member? id "油,易燃气体" and pdata = 1 [if random 4 = 0 and any? neighbors with [id = "空气"] [ask one-of neighbors with [id = "空气"] [set id "火"]] if random 10 = 0 [set id "火" set pdata 0]]
    if tc "木头" "火,岩浆,火炬" or tc "油" "火,岩浆,火炬,火花" or tc "易燃气体" "火,岩浆,火炬,火花" [set pdata 1]
    if tc "导火索" "火,岩浆,火炬,火花" [if any? neighbors with [id = "空气"] [ask n-of random count neighbors with [id = "空气"] neighbors with [id = "空气"] [set id "火花"]] set id "火花"]
    if id = "克隆" and pdata = 0 and any? neighbors with [not member? id "空气,墙,克隆"] [set pdata [id] of one-of neighbors with [not member? id "空气,墙,克隆"]]
    if id = "克隆" and pdata != 0 and any? neighbors with [id = "空气"] [ask one-of neighbors with [id = "空气"] [set id [pdata] of myself]]
    if id != pid [pref]
]
    ref
  ask patches with [typ = 1 and random ceiling(10 / abs(1 + density - [density] of patch-at-heading-and-distance 180 1)) = 0] [
    if random 2 = 0 and sta != 0 [
    let cid id let dtx pdata
    ask min-one-of neighbors4 with [typ != -1 and density < [density] of myself and sta != 0] [pycor] [set cid id set id [id] of myself set dtx pdata set pdata [pdata] of myself set typ [typ] of myself set density [density] of myself set sta [sta] of myself set pcolor [pcolor] of myself ask myself [set pdata dtx set id cid pref]]]
    if [typ] of patch-at-heading-and-distance 180 1 != -1 and [density] of patch-at-heading-and-distance 180 1 < density and random (1000 / max list 1 (density - [density] of patch-at-heading-and-distance 180 1)) = 0 and (sta != 0 or [sta] of patch-at-heading-and-distance 180 1 != 0) [
    let cid id let dtx pdata
    ask patch-at-heading-and-distance 180 1 [set dtx pdata set cid id set id [id] of myself set pdata [pdata] of myself set typ [typ] of myself set density [density] of myself set sta [sta] of myself set pcolor [pcolor] of myself]
    set pdata dtx
    set id cid
    pref
  ]]]
  ct cd if mouse-down? [crt 1 [setxy mouse-xcor mouse-ycor set shape "circle" set color lput 100 extract-rgb red set size 2 * place-size] ask patches with [dstxy mouse-xcor mouse-ycor - 0.5 <= place-size and ((id = "空气" and place != "空气") or place = "空气")] [set id place set typ item position id gfdata 0 gfdata 1 set density item position id gfdata 0 gfdata 2 set sta item position id gfdata 0 gfdata 3 set pcolor item position id gfdata 0 gfdata 4]]
  every asvsp [if ticks > 10 [autosv]]
  tick
  end
to-report gfdata [itm]
  report map [i -> item itm i] data
  end
to ref
  ask patches with [id != pid] [
    pref
  ]
  end
to pref 
  set typ item position id gfdata 0 gfdata 1
  set density item position id gfdata 0 gfdata 2
  set sta item position id gfdata 0 gfdata 3
  set pcolor item position id gfdata 0 gfdata 4
  set pid id
  end
to-report tc [cid pnid] report id = cid and any? neighbors4 with [member? id pnid] end
to-report dstxy [x y]
  report sqrt ((pxcor - x) ^ 2 + (pycor - y) ^ 2)
  end
to sv
  widget:toast "保存中......."
  store:switch-store "save"
  store:put cdm export-the:world
  widget:toast "保存完成!"
  sound:play-note "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 108 100 0.05
  showc
  end
to autosv
  widget:toast "自动保存中......."
  store:switch-store "save"
  store:put "自动保存" export-the:world
  widget:toast "自动保存完成!"
  sound:play-note "BASS AND LEAD" 108 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 108 100 0.05
  end
to dq [fil]
  widget:toast "导入中......"
  carefully [store:get fil import-a:world
  widget:toast "导入完成!"
  sound:play-note "BASS AND LEAD" 108 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 88 100 0.05] [widget:toast "存档损坏！"]
  end
to imp [inp]
  ifelse inp != 0 [import-a:world inp sound:play-note "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 108 100 0.05
  sound:play-note-later 0.2 "BASS AND LEAD" 108 100 0.05
  sound:play-note-later 0.3 "BASS AND LEAD" 88 100 0.05
  widget:toast "导入完成!"] [widget:toast "你导入了空文件"]
end
to imptxt
  widget:toast "导入中......"
  carefully [run "fetch:user-file-async imp"]
    [widget:toast word "你的海龟实验室版本过低，不支持导入操作\n" error-message]
  end
to sc [fil]
  dialog:user-yes-or-no? (word "确定删除存档：" fil "？\n<color=red>此操作无法撤销！</color>") [->
  widget:toast "删除中......"
  store:remove fil
  widget:toast "删除完毕!"
  sound:play-note "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 88 100 0.05
  showc]
  end
to dc
  widget:toast "导出中......"
  export-world (word cdm "-" (ext 12))
  widget:toast "导出完成!"
  sound:play-note "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.1 "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.2 "BASS AND LEAD" 88 100 0.05
  sound:play-note-later 0.3 "BASS AND LEAD" 88 100 0.05
  end
to showc
  let yx ""
  store:get-keys [i -> set yx (word "<b>存档列表：</b><size=20>存档总数：" (length i) "</size>") let yi "" foreach i [u -> set yi (word yi "\n·<color=blue>" u "</color>\t<run=dq \"" u "\"></run><color=green>读取</color>\t<run=sc \"" u "\"></run><color=red>删除</color>")] set yx (word yx yi "<run=></run>\n<size=20>已显示全部</size>")]
  user-message yx
end
to-report ext [i]
  let txt "" repeat i [set txt word (item (random 62)"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz") txt] report txt
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13
1
10
1
1
1
0
1
1
1
0
31
0
31
0
0
1
ticks
30

BUTTON
16
19
82
52
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
89
19
152
52
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
0

CHOOSER
-1
-1
-1
-1
快捷元素选择
place
"空气" "粉末" "水" "冰" "雪" "水蒸气" "易燃气体" "油" "火" "岩浆" "石" "盐" "盐水" "钢铁" "种子" "木头" "酸" "水银" "火炬" "火花" "导火索" "克隆" "墙"
1

SLIDER
-1
-1
-1
-1
大小
place-size
0.1
10
0.1
0.1
1
（半径）
HORIZONTAL

BUTTON
-1
-1
-1
-1
列出所有存档
showc
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
-1
-1
-1
-1
存档名称
cdm
1
1
11

BUTTON
-1
-1
-1
-1
设置存档名
dialog:user-input \"输入存档名\" [inp -> ifelse length inp != 0 [set cdm inp][widget:toast \"你取消了存档名输入操作\"]]
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
-1
-1
-1
-1
保存
sv
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
-1
-1
-1
-1
把当前世界导出为txt
dc
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
-1
-1
-1
-1
从txt导入存档
imptxt
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
-1
-1
-1
-1
非空气元素量
count patches with [id != \"空气\"]
1
1
11

SLIDER
-1
-1
-1
-1
自动保存频率
asvsp
1
600
60
1
1
s
HORIZONTAL

SWITCH
-1
-1
-1
-1
暂停
pause?
1
1
-1000

SLIDER
-1
-1
-1
-1
运行速度
tsp
1
4
2
1
1
NIL
HORIZONTAL

BUTTON
-1
-1
-1
-1
进入官方网页版
workspace:execute-command \"net\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
-1
-1
-1
-1
已选放置元素
place
17
1
11

BUTTON
-1
-1
-1
-1
元素列表
showall
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
-1
-1
-1
-1
set plabel (word "<size=20>" id "</size>")
set plabel (word \"<size=20>\" id \"</size>\")
T
1
T
PATCH
NIL
NIL
NIL
NIL
1

BUTTON
-1
-1
-1
-1
快捷元素选择2
dialog:user-one-of \"选择放置的元素\" gfdata 0 [i -> set place i]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1
@#$#@#$#@

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
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
