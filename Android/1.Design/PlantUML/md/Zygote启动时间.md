```plantuml
@startuml
scale 500 as 40 pixels
robust "init启动" as init
robust "Zygote启动" as zy
robust "RuntimeInit启动" as ri
robust "SystemServer启动" as ss
robust "Launcher启动" as lc

@-1000
init is start

@0 <-> @+1458 : {1458ms} 
init -> zy : 启动
zy is start

@1458 <-> @+2385 : {2385ms} 
zy -> ri : 启动
ri is start

@3843 <-> @+5102 : {5102ms} 
ri -> ss : 启动
ss is start

@8945
ss -> lc : 启动
lc is start

@enduml