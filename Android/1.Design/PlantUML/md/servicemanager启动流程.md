```plantuml
@startuml
title servicemanager启动流程
actor "init进程" as init

participant "servicemanager.c" as sm
note bottom : "frameworks/native/cmds/servicemanager/service_manager.c"

participant "binder.c" as binder
note bottom : "frameworks/native/cmds/servicemanager/binder.c"

participant "fcntl.h" as fl

participant "ioctl.h" as il
note bottom : "sys/ioctl.h"

participant "mman.h" as mm
note bottom : "sys/mman.h"

participant "stdlib.h" as std

group "init进程"
    init -> sm : 启动servicemanager
    sm -> binder : 调用binder_open()方法
    binder -> fl : 调用open()函数
    note left : 打开设备节点/dev/binder
    binder -> il : 调用ioctl()方法发送BINDER_VERSION请求
    note left : 获取binder版本号
    binder -> mm : 调用mmap函数映射到/dev/binder设备节点上
    note left : 映射128K的长度到内存上
    sm -> binder : 调用binder_become_context_manager()方法
    binder -> il : 调用ioctl()方法发送BINDER_SET_CONTEXT_MGR请求
    sm -> binder : 调用binder_loop()方法
    binder -> binder : 调用binder_write()方法
    binder -> il : 调用ioctl()方法发送BINDER_WRITE_READ请求
    loop "无限循环"
        binder -> il : 调用ioctl()方法发送BINDER_WRITE_READ请求
        binder -> binder : 调用binder_parse()方法
        group "传输消息"
            binder -> binder : 调用binder_dump_txn()方法
            binder -> binder : 调用hexdump方法
            binder -> binder : 调用bio_init()方法
            note left : 初始化binder_io数据
            binder -> binder : 调用bio_init_from_txn()方法
            binder --> sm : 调用svcmgr_handler()方法
            note right : 注册的回调函数func()
            sm -> binder : 调用bio_get_uint32()方法
            binder -> binder : 调用bio_get()方法
            sm -> binder : 调用bio_get_string16()方法

            group "get/check service"
                sm -> sm : 调用do_find_service()方法
                sm -> sm : 调用find_svc()方法
                sm -> sm : 调用svc_can_find()方法
                sm -> sm : 调用check_mac_perms_from_lookup()方法
                note right : SELinux是否开启校验
                sm -> sm : 调用check_mac_perms()方法
                note right : SELinux权限校验
            end

            group "add service"
                sm -> binder : 调用bio_get_string16()方法
                sm -> binder : 调用bio_get_ref()方法
                sm -> binder : 调用bio_get_uint32()方法
                sm -> sm : 调用do_add_service()方法
                sm -> sm : 调用svc_can_register()方法
                note right : SELinux校验
                sm -> sm : 调用find_svc()函数
                note right : 校验是否已经添加
                group "added"
                    sm -> sm : 调用svcinfo_death()函数
                end

                group "unadded"
                    sm -> std : 调用malloc()函数
                end
                sm -> binder : 调用binder_acquire()函数
                binder -> binder : 调用binder_wirte()函数
                binder -> il : 调用ioctl()函数发送BINDER_WRITE_READ请求
                sm -> binder : 调用binder_link_to_death()函数
                binder -> binder : 调用binder_acquire()函数
            end

            group "list service"
                sm -> sm : 调用svc_can_list()函数
                note right : SELinux校验
            end
            binder -> binder : 调用binder_send_reply()函数
        end
    end
end
@enduml