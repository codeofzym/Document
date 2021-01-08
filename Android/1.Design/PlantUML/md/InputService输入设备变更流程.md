```plantuml
@startuml
actor "native通知Java设备变更" as na

participant "InputManagerService.java" as is

group "native"
    na -> is : 调用notifyInputDevicesChanged()函数
    note right : 发送MSG_DELIVER_INPUT_DEVICES_CHANGED消息并更新mInputDevices设备表
end

group "System进程处理"
    is --// is : handle处理MSG_DELIVER_INPUT_DEVICES_CHANGED消息
    note left : obj参数为InputServices中缓存的旧设备表
    is -> is : 调用deliverInputDevicesChanged()函数
    is -> is : 调用showMissingKeyboardLayoutNotification()函数
end
@enduml