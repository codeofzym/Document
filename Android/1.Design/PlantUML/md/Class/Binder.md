```plantuml
@startuml

namespace android {

    class RefBase { 

    }
    note right : "引用计数 类似GC"

    class BBinder {
        -atomic_uintptr_t mExtras
        -void* mReserved0
    }

    class BpRefBase {
        -IBinder* const mRemote
        -RefBase::weakref_type*  mRefs
        -volatile int32_t        mState

        #BpRefBase(const sp<IBinder>& o)
        #virtual ~BpRefBase()
        #virtual void onFirstRef()
        #virtual void onLastStrongRef(const void* id)
        #virtual bool onIncStrongAttempted(uint32_t flags, const void* id)
        #inline IBinder* remote() { return mRemote; }
        #inline IBinder* remote() const { return mRemote; }
    }

    class BpBinder {
        -const int32_t mHandle

        +inline int32_t handle() const { return mHandle; }
        +virtual BpBinder* remoteBinder()
        +status_t setConstantData(const void* data, size_t size)
        +void sendObituary()

        #virtual ~BpBinder()
        #virtual void onFirstRef()
        #virtual void onLastStrongRef(const void* id)
        #virtual bool onIncStrongAttempted(uint32_t flags, const void* id)
    }

    class ObjectManager {
        +ObjectManager()
        +~ObjectManager()
        +void attach (const void* objectID, void* object, void* cleanupCookie, IBinder::object_cleanup_func func)
        +void* find(const void* objectID) const
        +void detach(const void* objectID)
        +void kill()

        -KeyedVector<const void*, entry_t> mObjects;
    }

    class IInterface {
        +IInterface()
        +static sp<IBinder> asBinder(const IInterface*)
        +static sp<IBinder> asBinder(const sp<IInterface>&)

        #virtual ~IInterface()
        #virtual IBinder* onAsBinder() = 0; 
    }

    class Parcel {

    }

    class IBinder {
        +IBinder()
        +virtual sp<IInterface>  queryLocalInterface(const String16& descriptor)
        +virtual const String16& getInterfaceDescriptor()
        +virtual bool isBinderAlive() const
        +virtual status_t pingBinder()
        +virtual status_t dump(int fd, const Vector<String16>& args)
        +virtual status_t transact(uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags = 0);

        +virtual status_t linkToDeath(const sp<DeathRecipient>& recipient, void* cookie = NULL, uint32_t flags = 0);
        +virtual status_t unlinkToDeath(const wp<DeathRecipient>& recipient, void* cookie = NULL, uint32_t flags = 0, wp<DeathRecipient>* outRecipient = NULL)

        +virtual void attachObject(const void* objectID, oid* object, void* cleanupCookie, object_cleanup_func func)
        +virtual void detachObject(const void* objectID)
        +virtual void* findObject(const void* objectID) const

        +virtual bool checkSubclass(const void* subclassID) const;
        +typedef void (*object_cleanup_func)(const void* id, void* obj, void* cleanupCookie)

        +virtual BBinder* localBinder()
        +virtual BpBinder* remoteBinder()

        #virtual ~IBinder()
    }

    class IPCThreadState {
        +static IPCThreadState* self();
        +static IPCThreadState* selfOrNull()

        +sp<ProcessState> process()

        +status_t clearLastError()

        +pid_t getCallingPid() const
        +uid_t getCallingUid() const

        +void setStrictModePolicy(int32_t policy)
        +int32_t getStrictModePolicy() const

        +void setLastTransactionBinderFlags(int32_t flags)
        +int32_t getLastTransactionBinderFlags() const

        +int64_t clearCallingIdentity()
        +void restoreCallingIdentity(int64_t token)

        +int setupPolling(int* fd)
        +status_t handlePolledCommands()
        +void flushCommands()

        +void joinThreadPool(bool isMain = true)

        +void stopProcess(bool immediate = true)

        +status_t transact(int32_t handle, uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags);

        +void incStrongHandle(int32_t handle)
        +void decStrongHandle(int32_t handle)
        +void incWeakHandle(int32_t handle)
        +void decWeakHandle(int32_t handle)
        +status_t attemptIncStrongHandle(int32_t handle)
        +static void expungeHandle(int32_t handle, IBinder* binder)
        +status_t requestDeathNotification(int32_t handle, BpBinder* proxy);
        +status_t clearDeathNotification(int32_t handle, BpBinder* proxy);

        +static void shutdown()

        +static void disableBackgroundScheduling(bool disable)

        +void blockUntilThreadAvailable()

        -IPCThreadState()
        -~IPCThreadState()

        -status_t sendReply(const Parcel& reply, uint32_t flags)
        -status_t aitForResponse(Parcel *reply, status_t *acquireResult=NULL)

        -status_t talkWithDriver(bool doReceive=true)
        -status_t writeTransactionData(int32_t cmd, uint32_t binderFlags, int32_t handle, uint32_t code, const Parcel& data, status_t* statusBuffer);
        -status_t getAndExecuteCommand()
        -status_t executeCommand(int32_t command)
        -void processPendingDerefs()

        -void clearCaller()

        -static void threadDestructor(void *st)
        -static void freeBuffer(Parcel* parcel, const uint8_t* data, size_t dataSize, const binder_size_t* objects, size_t objectsSize, void* cookie)

        -const sp<ProcessState> mProcess
        -const pid_t mMyThreadId
        -Vector<BBinder*> mPendingStrongDerefs
        -Vector<RefBase::weakref_type*> mPendingWeakDerefs

        -Parcel mIn
        -Parcel mOut
        -status_t mLastError
        -pid_t mCallingPid
        -uid_t mCallingUid
        -int32_t mStrictModePolicy
        -int32_t mLastTransactionBinderFlags
    }

    class INTERFACE {
        inline sp<INTERFACE> interface_cast(const sp<IBinder>& obj)
    }

    class BnInterface <INTERFACE> {
        #virtual IBinder* onAsBinder()
    }

    class BpInterface <INTERFACE> {
        +BpInterface(const sp<IBinder>& remote)
        #virtual IBinder* onAsBinder()
    }

    RefBase <-- IInterface
    RefBase <-- IBinder
    RefBase <-- BpRefBase
    IBinder <-- BpBinder
    BpBinder +-- ObjectManager
    IBinder <-- BBinder

    INTERFACE <-- BpInterface
    INTERFACE <-- BnInterface

    BBinder <-- BnInterface
    BpRefBase <-- BpInterface
}

@enduml