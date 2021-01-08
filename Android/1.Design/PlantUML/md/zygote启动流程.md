```plantuml
@startuml
title Zygote进程启动流程(Android M)

actor "init进程" as init #red
note bottom : "system/core/init/init.cpp"

participant "app_main.cpp" as appm
note bottom : "frameworks/base/cmds/app_process/app_main.cpp"

participant "AndroidRuntime.cpp" as nar
note bottom : "frameworks/base/core/jni/AndroidRuntime.cpp"

participant "ZygoteInit.java" as zi
note bottom : "frameworks/base/core/java/com/android/internal/os/ZygoteInit.java"

participant "stdlib.h" as std

participant "JniInvocation.cpp" as ji
note bottom : "libnativehelper/JniInvocation.cpp"

participant "Threads.cpp" as th
note bottom : "system/core/libutils/Threads.cpp"

participant "RuntimeInit.java" as ri
note bottom : "frameworks/base/core/java/com/android/internal/os/RuntimeInit.java"

participant "ZygoteConnection.java" as zc
note bottom : "frameworks/base/core/java/com/android/internal/os/ZygoteConnection.java"

participant "Zygote.java" as zygote
note bottom : "frameworks/base/core/java/com/android/internal/os/Zygote.java"

participant "com_android_internal_os_Zygote.cpp" as jzygote
note bottom : "frameworks/base/core/jni/com_android_internal_os_Zygote.cpp"

participant "WrapperInit.java" as wi
note bottom : ""

participant "ProcessState" as ps


group "Zygote native启动流程"
autonumber "<b>0."
    init -> appm : 启动zygote进程
    appm -> nar : 创建Runtime对象
    appm -> nar : 调用addOption启动选项
    appm -> appm : 调用maybeCreateDalvikCache()方法
    note right : 创建DVM的cache目录:/data/dalvik-cache/cpu类型\nroot:root 0771权限
    appm -> nar : 调用start方法启动
    note right: 启动的Java类是ZygoteInit
    group "初始化Java VM"
        nar -> std : getenv()方法获取rootDir
        group "初始化jni"
            nar -> ji : 创建JniInvocation对象
            ji --> nar : 返回jni_invocation对象
            nar -> ji : 调用init()方法
        end

        group "启动VM"
            nar -> nar : 调用startVm方法启动VM
            nar -> ji : 调用JNI_CreateJavaVM()方法创建VM
            nar --> appm : 调用onVmCreated()方法
            note right : 启动Zygote时直接返回
        end

        group "注册Native Functions"
            nar -> nar : 调用startReg()
            nar -> th : 注册javaCreateThreadEtc()回调函数
            nar -> nar : 调用register_jni_procs()方法注册Native方法
            note right : 调用方法表批量注册
        end
    nar -> ri : 启动ZygoteInit
    note right : 通过反射机制调用ZygoteInit中的main()方法
    end
end

group "Zygote Java启动流程"
    zi -> ri : 调用enableDdms()方法打开Ddms
    note left : 调用DdmRegister.registerHandlers()方法进行注册
    zi -> zi : 调用registerZygoteSocket()
    note left : SocketName:ANDROID_SOCKET_zygote
    zi -> zi : 调用preload()函数加载资源
    note left : 1.加载classes\n2.加载资源文件\n3.加载OpenGL\n4.加载动态库\n5.加载文字资源\n6.初始化WebView
    zi -> zi : 调用gcAndFinalize()函数
    note left : fork()新进程之前先调用gc
    zi -> zi : 调用startSystemServer()方法
    zi -> zc : 创建ZygoteConnection.Argements(),并解析
    zi -> zc : 调用applyDebuggerSystemProperty()方法
    note left : 根据系统属性ro.debuggable更新Arguments
    zi -> zc : 调用applyInvokeWithSystemProperty()方法
    note left : 将系统属性装入到Argsuments参数中
    zi -> zygote : 调用forkSystemServer方法启动SystemServer进程
    zygote -> jzygote : 调用nativeForkSystemServer()方法
    group "jni调用"
        jzygote -> jzygote : 调用ForkAndSpecializeCommon()方法
        jzygote -> jzygote : 调用SetSigChldHandler函数
        note left : 注册signal监控机制
        note left : 调用fork方法新建子进程，并初始化子进程属性
    end

    group "启动Runtime"
        zi -> zi : 调用hasSecondZygote()方法
        zi -> zi : 调用handlerSystemServerProcess()方法
        zi -> zi : 调用closeServerSocket()方法
        zi -> wi : 调用exceApplication()方法
        wi -> zygote : 调用appendQuotedShellArgs()方法
        wi -> zygote : 调用execShell()方法
        note left : 执行app_process命令，根据系统是否支持64位来决定执行哪一个
    end
end

group "RuntimeInit启动"
autonumber "<b>[0]"
    zygote -> appm : 在zygote子进程中执行
    appm -> nar : 创建Runtime对象
    nar --> appm : 返回Runtime对象
    appm -> nar : 调用addOption启动选项
    appm -> appm : 调用setClassNameAndArgs()方法
    appm -> nar : 调用start方法启动RuntimeInit
    nar -> std : getenv()方法获取rootDir
    group "初始化Java VM"
        group "初始化jni"
            nar -> ji : 创建JniInvocation对象
            ji --> nar : 返回jni_invocation对象
            nar -> ji : 调用init()方法
        end

        group "启动VM"
            nar -> nar : 调用startVm方法启动VM
            nar -> ji : 调用JNI_CreateJavaVM()方法创建VM
            nar --> appm : 调用onVmCreated()方法
            note right : 初始化SystemServer的class对象
        end

        group "注册Native Functions"
            nar -> nar : 调用startReg()
            nar -> th : 注册javaCreateThreadEtc()回调函数
            nar -> nar : 调用register_jni_procs()方法注册Native方法
            note right : 调用方法表批量注册
        end
    nar -> ri : 启动Runtime
    note right : 通过反射机制调用RuntimeInit中的main()方法
    end
end

group "Java 服务启动流程"
    ri -> ri : 调用enableDdms()方法打开Ddms
    note left : 调用DdmRegister.registerHandlers()方法进行注册
    ri -> ri : 调用redirectLogStreams()方法重定向日志输出
    ri -> ri : 调用commonInit()方法进行初始化
    note left : 1.设置DefaultUncaughtExceptionHandler\n2.初始化TimeZone、LogManager、UserAgent和trace\n3.NetworkManagementSocketTagger(流量统计)
    ri -> nar : 调用nativeFininshInit方法
end

group "native"
    nar --> appm : 调用onStarted()方法
    appm -> ps : 调用self()方法获取ProcessState对象
    note left : 线程锁保持同步，单例模式
    appm -> ps : 调用startThreadPool()启动主线程
    appm -> nar : 调用callMain()方法
    note right : 通过反射机制调用main方法启动SystemService
end

@enduml