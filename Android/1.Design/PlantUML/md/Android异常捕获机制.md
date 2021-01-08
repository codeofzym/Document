```plantuml
@startuml
title 异常捕获机制流程
actor 进程启动 as init
actor 应用发送异常 as EX
actor 用户 as USER

participant "RuntimeInit.java" as RI
note left : "frameworks/base/core/java/com/android/internal/os/RuntimeInit.java"

participant "Thread.java" as TH
note left : "libcore/libart/src/main/java/java/lang/Thread.java"

participant "ActivityManagerService.java" as AMS
note left : "frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java"

participant "AppErrorDialog.java" as AD
note left : "frameworks/base/services/core/java/com/android/server/am/AppErrorDialog.java"

group "进程启动阶段初始化"
    init -> RI : 调用main()函数启动
    RI -> RI : 调用commonInit()函数
    RI -> TH : 调用setDefaultUncaughtExceptionHandler()函数
    note left : 设置异常捕获器，异常灭有捕获最终会调用此捕获器捕获
end 

group “Java程序抛出异常被异常不获取捕获”
    EX -> RI : 调用uncaughtException()函数
    RI -> AMS : 调用handleApplicationCrash()函数

    activate AMS
        note left : 弹出Dialog用来等待用户点击确定或发送错误报告
        AMS -> AMS : 调用handleApplicationCrashInner()函数
        AMS -> AMS : 调用addErrorToDropBox()函数
        note left : 记录Crash信息到dropbox
        AMS -> AMS : 调用crashApplication()函数
        AMS -> AMS : 调用createAppErrorIntentLocked1()函数
        note left : 创建Intent.ACTION_APP_ERROR广播
        AMS -> AMS : 调用broadcastIntentLocked()函数
        AMS --> AMS : 调用sendMessage函数
        note left : SHOW_ERROR_MSG
    deactivate AMS

    group "弹出Dialog"
        AMS -> AMS : 调用handleMessage函数
        activate AMS
            AMS -> AD : 调用new函数
            note left : 创建Dialog对象
            AMS -> AD : 调用show()函数
            note left : 弹出Dialog提示用户
        deactivate AMS
    end

    group "向应用市场发送错误报告"
        USER -> AD : 选择发送错误报告
        AMS -> AD : 获取用户选择结果
        AMS -> AMS : 调用createAppErrorIntentLocked()函数
        AMS -> AMS : 调用createAppErrorReportLocked()函数
        AMS -> AMS : 调用startActivityAsUser()函数
        note left : 打开应用市场的ReportActivity
    end


end
@enduml