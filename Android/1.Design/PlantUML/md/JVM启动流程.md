```plantuml
@startuml
actor "Zygote进程" as zg

participant "JniInvocation.cpp" as ji
note bottom : "libnativehelper/JniInvocation.cpp"

participant "java_vm_ext.cc" as jve
note bottom : "art/runtime/java_vm_ext.cc"

participant "runtime.cc" as rt
note bottom : "art/runtime/runtime.cc"
participant "logging.cc" as log
note bottom : "art/runtime/base/logging.cc"

group "Adapter 初始化"
    zg -> ji : 创建栈对象JniInvocation
    note right : 1.初始化handle_对象为NULL\n2.初始化函数指针JNI_GetDefaultJavaVMInitArgs_为NULL\n3.初始化函数指针JNI_CreateJavaVM_为NULL\n4.初始化函数指针JNI_GetCreatedJavaVMs_为NULL
    zg -> ji : 调用对象JniInvocation的init()方法
    note right : 链接libart.so并初始化3个函数指针：\n1.JNI_GetDefaultJavaVMInitArgs_ -> JNI_GetDefaultJavaVMInitArgs\n2.JNI_CreateJavaVM_ -> JNI_CreateJavaVM\n3.JNI_GetCreatedJavaVMs_ -> JNI_GetCreatedJavaVMs
    zg -> zg : 调用startVm()方法
    note right : 初始化JVM启动参数
    zg -> ji : 调用JNI_CreateJavaVM()方法
    ji -> ji : 调用JNI_CreateJavaVM()方法
    ji -> jve : 调用libart.so中的JNI_CreateJavaVM()方法
end

group “libart库”
    jve -> rt : 调用Create()方法创建Runtime对象
    note left : 单例模式，已有创建则返回false,创建则返回true
    rt -> log : 调用InitLogging()方法
end
@enduml