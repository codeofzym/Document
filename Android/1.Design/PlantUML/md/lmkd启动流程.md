```plantuml
@startuml
actor "init进程" as init

participant "lmkd.c" as lmkd
note bottom : "system/core/lmkd/lmkd.c"

participant "sched.h" as sched
note bottom : "/sys/sched.h"

participant "unistd.h" as unistd
note bottom : "/sys/unistd.h"

participant "epoll.h" as epoll
note bottom : "sys/epoll.h"

participant "sockets.h" as sockets
note bottom : "system/core/include/cutils/sockets.h"

participant "socket.h" as socket
note bottom : "sys/socket.h"

participant "inet.h" as inet
note bottom : "arpa/inet.h"

group "init进程"
    init -> lmkd : 通过调用lmkd的main()方法启动
    lmkd -> lmkd : 调用mlock(MCL_FUTURE)
    note left : 功能未知，需要学习
    lmkd -> sched : 调用sched_setscheduler()方法设置调度策略
    note left : 参数pid为0 为调用进程设置调度策略和调度参数
    lmkd -> lmkd : 调用init()方法进行初始化
    lmkd -> unistd : 调用sysconf()方法获取_SC_PAGESIZE变量值
    note left : 若_SC_PAGESIZE变量未初始化则进行初始化
    lmkd -> epoll : 调用epoll_create()方法创建socket监听
    lmkd -> sockets : 调用android_get_control_socket()创建sokect
    note left : 创建名称为“lmkd”的socket
    lmkd -> socket : 调用listen()方法对socket进行连接
    lmkd -> epoll : 调用epoll_ctl()方法对socket进行读监听
    note left : 注册回调函数ctrl_connect_handler()
    group "新Socket连接"
        lmkd -> lmkd : 调用回调函数ctrl_connect_handler()
        lmkd -> socket : 调用accept()函数建立连接
        lmkd -> epoll : 调用epoll_ctl()方法对读进行监听
        note left : 注册回调函数ctrl_data_handler()
        group "数据处理"
            lmkd -> lmkd : 调用ctrl_command_handler()函数
            lmkd -> lmkd : 调用ctrl_data_read()函数读取socket数据
            lmkd -> inet : 调用ntohl()函数格式化内容识别cmd，并根据cmd执行对于函数
            note left : enum lmk_cmd {\n    LMK_TARGET 设置最小空闲内存和建议内存\n    LMK_PROCPRIO 增加或修改proc文件\n    LKM_PROCREMOVE 删除proc文件\n}\nproc文件："/proc/pid/oom_score_adj"
        end
    end
    
    group "/dev/memcg/"
        lmkd -> lmkd : 调用init_mp()方法进行初始化
    end
    note left : 根据文件节点"/sys/module/lowmemorykiller/parameters/minfree"\n是否存在来区分使用内核的lowmemerykiller还是使用用户态的

end
@enduml