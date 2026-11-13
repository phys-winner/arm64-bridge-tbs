.class public final Lcom/stoicstudio/port/PortStorage;
.super Ljava/lang/Object;
.source "PortStorage.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/stoicstudio/port/PortStorage$State;,
        Lcom/stoicstudio/port/PortStorage$PortContext;,
        Lcom/stoicstudio/port/PortStorage$Prefs;,
        Lcom/stoicstudio/port/PortStorage$WriteBody;
    }
.end annotation


# static fields
.field private static final RUN:Ljava/lang/String;

.field private static final TAG:Ljava/lang/String; = "PortStorage"

.field private static final WRITER:Ljava/util/concurrent/ExecutorService;

.field private static state:Lcom/stoicstudio/port/PortStorage$State;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 59
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/stoicstudio/port/PortStorage;->RUN:Ljava/lang/String;

    .line 60
    new-instance v0, Lcom/stoicstudio/port/PortStorage$0;

    invoke-direct {v0}, Lcom/stoicstudio/port/PortStorage$0;-><init>()V

    invoke-static {v0}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor(Ljava/util/concurrent/ThreadFactory;)Ljava/util/concurrent/ExecutorService;

    move-result-object v0

    sput-object v0, Lcom/stoicstudio/port/PortStorage;->WRITER:Ljava/util/concurrent/ExecutorService;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 64
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$100([Ljava/lang/String;)Ljava/util/List;
    .registers 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 57
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->validateRoots([Ljava/lang/String;)Ljava/util/List;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$1000()Ljava/util/concurrent/ExecutorService;
    .registers 1

    .line 57
    sget-object v0, Lcom/stoicstudio/port/PortStorage;->WRITER:Ljava/util/concurrent/ExecutorService;

    return-object v0
.end method

.method static synthetic access$200(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 57
    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$300()Ljava/lang/String;
    .registers 1

    .line 57
    sget-object v0, Lcom/stoicstudio/port/PortStorage;->RUN:Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$400()Lcom/stoicstudio/port/PortStorage$State;
    .registers 1

    .line 57
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$500(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    .registers 1

    .line 57
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    return-object p0
.end method

.method static assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 379
    invoke-virtual {p0}, Lorg/json/JSONObject;->length()I

    move-result v0

    invoke-virtual {p1}, Lorg/json/JSONObject;->length()I

    move-result v1

    if-ne v0, v1, :cond_53

    .line 380
    invoke-virtual {p0}, Lorg/json/JSONObject;->keys()Ljava/util/Iterator;

    move-result-object v0

    .line 382
    :goto_e
    :try_start_e
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_49

    .line 383
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 384
    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2f

    invoke-virtual {p0, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2f

    goto :goto_e

    .line 385
    :cond_2f
    new-instance p0, Ljava/io/IOException;

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p2, ": "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_49
    .catch Lorg/json/JSONException; {:try_start_e .. :try_end_49} :catch_4a

    :cond_49
    return-void

    :catch_4a
    move-exception p0

    .line 389
    new-instance p1, Ljava/io/IOException;

    const-string p2, "Malformed hash inventory"

    invoke-direct {p1, p2, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1

    .line 379
    :cond_53
    new-instance p0, Ljava/io/IOException;

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p2, ": file count"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static atomicWrite(Ljava/io/File;Lcom/stoicstudio/port/PortStorage$WriteBody;)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const-string v0, "Cannot publish atomic file: "

    .line 396
    invoke-virtual {p0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v1

    invoke-static {v1}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    .line 398
    invoke-virtual {p0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v3, ".port-new"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    .line 399
    new-instance v2, Landroid/util/AtomicFile;

    invoke-direct {v2, v1}, Landroid/util/AtomicFile;-><init>(Ljava/io/File;)V

    const/4 v3, 0x0

    .line 402
    :try_start_2c
    invoke-virtual {v2}, Landroid/util/AtomicFile;->startWrite()Ljava/io/FileOutputStream;

    move-result-object v4
    :try_end_30
    .catchall {:try_start_2c .. :try_end_30} :catchall_5c

    .line 403
    :try_start_30
    invoke-interface {p1, v4}, Lcom/stoicstudio/port/PortStorage$WriteBody;->write(Ljava/io/OutputStream;)V

    .line 404
    invoke-virtual {v4}, Ljava/io/FileOutputStream;->flush()V

    .line 405
    invoke-virtual {v4}, Ljava/io/FileOutputStream;->getFD()Ljava/io/FileDescriptor;

    move-result-object p1

    invoke-virtual {p1}, Ljava/io/FileDescriptor;->sync()V

    .line 406
    invoke-virtual {v2, v4}, Landroid/util/AtomicFile;->finishWrite(Ljava/io/FileOutputStream;)V
    :try_end_40
    .catchall {:try_start_30 .. :try_end_40} :catchall_59

    .line 409
    :try_start_40
    invoke-virtual {v1, p0}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result p1

    if-eqz p1, :cond_47

    return-void

    :cond_47
    new-instance p1, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
    :try_end_59
    .catchall {:try_start_40 .. :try_end_59} :catchall_5c

    :catchall_59
    move-exception p0

    move-object v3, v4

    goto :goto_5d

    :catchall_5c
    move-exception p0

    :goto_5d
    if-eqz v3, :cond_62

    .line 411
    invoke-virtual {v2, v3}, Landroid/util/AtomicFile;->failWrite(Ljava/io/FileOutputStream;)V

    .line 412
    :cond_62
    throw p0
.end method

.method private static awaitWrites()V
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 476
    :try_start_0
    sget-object v0, Lcom/stoicstudio/port/PortStorage;->WRITER:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/stoicstudio/port/PortStorage$2;

    invoke-direct {v1}, Lcom/stoicstudio/port/PortStorage$2;-><init>()V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->submit(Ljava/util/concurrent/Callable;)Ljava/util/concurrent/Future;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/concurrent/Future;->get()Ljava/lang/Object;

    .line 477
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v0

    .line 478
    iget-object v1, v0, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    monitor-enter v1
    :try_end_15
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_15} :catch_50
    .catch Ljava/util/concurrent/ExecutionException; {:try_start_0 .. :try_end_15} :catch_43

    .line 479
    :try_start_15
    iget-object v0, v0, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1f
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_3e

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/stoicstudio/port/PortStorage$Prefs;

    .line 480
    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;
    invoke-static {v2}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$000(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/IOException;

    move-result-object v3

    if-nez v3, :cond_32

    goto :goto_1f

    :cond_32
    new-instance v0, Ljava/io/IOException;

    const-string v3, "Unresolved preference disk failure"

    .line 481
    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;
    invoke-static {v2}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$000(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/IOException;

    move-result-object v2

    invoke-direct {v0, v3, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v0

    .line 483
    :cond_3e
    monitor-exit v1

    return-void

    :catchall_40
    move-exception v0

    monitor-exit v1
    :try_end_42
    .catchall {:try_start_15 .. :try_end_42} :catchall_40

    :try_start_42
    throw v0
    :try_end_43
    .catch Ljava/lang/InterruptedException; {:try_start_42 .. :try_end_43} :catch_50
    .catch Ljava/util/concurrent/ExecutionException; {:try_start_42 .. :try_end_43} :catch_43

    :catch_43
    move-exception v0

    .line 488
    new-instance v1, Ljava/io/IOException;

    const-string v2, "Preference flush failed"

    invoke-virtual {v0}, Ljava/util/concurrent/ExecutionException;->getCause()Ljava/lang/Throwable;

    move-result-object v0

    invoke-direct {v1, v2, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1

    :catch_50
    move-exception v0

    .line 485
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Thread;->interrupt()V

    .line 486
    new-instance v1, Ljava/io/IOException;

    const-string v2, "Interrupted while flushing preferences"

    invoke-direct {v1, v2, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1
.end method

.method public static cache(Landroid/content/Context;)Ljava/io/File;
    .registers 1

    .line 117
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object p0

    return-object p0
.end method

.method public static cachePath(Landroid/content/Context;)Ljava/lang/String;
    .registers 3

    .line 99
    :try_start_0
    new-instance v0, Ljava/io/File;

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    const-string v1, "cache"

    invoke-direct {v0, p0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p0

    invoke-virtual {p0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object p0
    :try_end_15
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_15} :catch_16

    return-object p0

    :catch_16
    move-exception p0

    .line 101
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "External cache unavailable"

    invoke-direct {v0, v1, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v0
.end method

.method public static declared-synchronized checkpoint(Landroid/content/Context;)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const-class v0, Lcom/stoicstudio/port/PortStorage;

    monitor-enter v0

    .line 194
    :try_start_3
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    .line 195
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->awaitWrites()V
    :try_end_a
    .catchall {:try_start_3 .. :try_end_a} :catchall_3c

    .line 197
    :try_start_a
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$State;->identity()Lorg/json/JSONObject;

    move-result-object v1

    .line 198
    const-string v2, "run"

    sget-object v3, Lcom/stoicstudio/port/PortStorage;->RUN:Ljava/lang/String;

    invoke-virtual {v1, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 199
    const-string v2, "pid"

    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v3

    invoke-virtual {v1, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 200
    const-string v2, "files"

    iget-object v3, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    iget-object v4, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    const/4 v5, 0x0

    invoke-static {v3, v4, v5}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 201
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->checkpoint:Ljava/io/File;

    invoke-static {p0, v1}, Lcom/stoicstudio/port/PortStorage;->writeJson(Ljava/io/File;Lorg/json/JSONObject;)V
    :try_end_31
    .catch Lorg/json/JSONException; {:try_start_a .. :try_end_31} :catch_33
    .catchall {:try_start_a .. :try_end_31} :catchall_3c

    .line 205
    monitor-exit v0

    return-void

    :catch_33
    move-exception p0

    .line 203
    :try_start_34
    new-instance v1, Ljava/io/IOException;

    const-string v2, "Cannot write restart checkpoint"

    invoke-direct {v1, v2, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1

    :catchall_3c
    move-exception p0

    monitor-exit v0
    :try_end_3e
    .catchall {:try_start_34 .. :try_end_3e} :catchall_3c

    throw p0
.end method

.method static cloneValues(Ljava/util/Map;)Ljava/util/Map;
    .registers 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "*>;)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 761
    new-instance v0, Ljava/util/LinkedHashMap;

    invoke-direct {v0}, Ljava/util/LinkedHashMap;-><init>()V

    .line 762
    invoke-interface {p0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_d
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_33

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/util/Map$Entry;

    .line 763
    invoke-interface {v1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    .line 764
    invoke-interface {v1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    instance-of v3, v2, Ljava/util/Set;

    if-eqz v3, :cond_2f

    new-instance v3, Ljava/util/HashSet;

    check-cast v2, Ljava/util/Set;

    invoke-direct {v3, v2}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    move-object v2, v3

    :cond_2f
    invoke-virtual {v0, v1, v2}, Ljava/util/LinkedHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_d

    :cond_33
    return-object v0
.end method

.method private static collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/io/File;",
            ">;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 319
    new-instance v0, Ljava/util/TreeMap;

    invoke-direct {v0}, Ljava/util/TreeMap;-><init>()V

    .line 320
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_9
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_19

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-static {p0, v1, v0}, Lcom/stoicstudio/port/PortStorage;->collectAt(Ljava/io/File;Ljava/lang/String;Ljava/util/Map;)V

    goto :goto_9

    :cond_19
    return-object v0
.end method

.method private static collectAt(Ljava/io/File;Ljava/lang/String;Ljava/util/Map;)V
    .registers 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/lang/String;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/io/File;",
            ">;)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 325
    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->excluded(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_7

    goto :goto_42

    .line 326
    :cond_7
    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 327
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_12

    goto :goto_42

    .line 328
    :cond_12
    invoke-virtual {v0}, Ljava/io/File;->isDirectory()Z

    move-result v1

    if-eqz v1, :cond_57

    .line 329
    invoke-virtual {v0}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v0

    if-eqz v0, :cond_43

    .line 331
    array-length v1, v0

    const/4 v2, 0x0

    :goto_20
    if-ge v2, v1, :cond_42

    aget-object v3, v0, v2

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "/"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {p0, v3, p2}, Lcom/stoicstudio/port/PortStorage;->collectAt(Ljava/io/File;Ljava/lang/String;Ljava/util/Map;)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_20

    :cond_42
    :goto_42
    return-void

    .line 330
    :cond_43
    new-instance p0, Ljava/io/IOException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "Cannot list owned data: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 332
    :cond_57
    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result p0

    if-eqz p0, :cond_61

    .line 333
    invoke-interface {p2, p1, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void

    .line 334
    :cond_61
    new-instance p0, Ljava/io/IOException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "Unsupported data entry: "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 295
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 296
    invoke-virtual {v0}, Ljava/io/File;->getCanonicalFile()Ljava/io/File;

    move-result-object p1

    .line 297
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Ljava/io/File;->getCanonicalPath()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    sget-object p0, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 298
    invoke-virtual {p1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_3b

    .line 299
    invoke-virtual {v0}, Ljava/io/File;->getAbsoluteFile()Ljava/io/File;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/io/File;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_33

    return-object p1

    :cond_33
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Symlink/alias in data path"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 298
    :cond_3b
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Path escaped owned directory"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static copyLegacy(Ljava/io/File;Ljava/io/File;)V
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 437
    const-string v0, "save"

    const-string v1, "log"

    filled-new-array {v0, v1}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    const/4 v1, 0x1

    .line 438
    invoke-static {p0, v0, v1}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v2

    .line 439
    invoke-static {p0, v0}, Lcom/stoicstudio/port/PortStorage;->collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_1d
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_3d

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/util/Map$Entry;

    .line 440
    invoke-interface {v4}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/io/File;

    invoke-interface {v4}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-static {p1, v4}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object v4

    invoke-static {v5, v4}, Lcom/stoicstudio/port/PortStorage;->copyVerified(Ljava/io/File;Ljava/io/File;)V

    goto :goto_1d

    .line 442
    :cond_3d
    invoke-static {p0, v0, v1}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object p0

    const-string p1, "Legacy original changed during copy"

    invoke-static {v2, p0, p1}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    return-void
.end method

.method static copyVerified(Ljava/io/File;Ljava/io/File;)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 416
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object v0

    .line 417
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v1

    .line 418
    invoke-virtual {p1}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_39

    .line 419
    invoke-virtual {p1}, Ljava/io/File;->length()J

    move-result-wide v3

    cmp-long p0, v1, v3

    if-nez p0, :cond_21

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_21

    goto :goto_65

    .line 420
    :cond_21
    new-instance p0, Ljava/io/IOException;

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Destination conflicts with original: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 422
    :cond_39
    new-instance v3, Lcom/stoicstudio/port/PortStorage$5;

    invoke-direct {v3, p0}, Lcom/stoicstudio/port/PortStorage$5;-><init>(Ljava/io/File;)V

    invoke-static {p1, v3}, Lcom/stoicstudio/port/PortStorage;->atomicWrite(Ljava/io/File;Lcom/stoicstudio/port/PortStorage$WriteBody;)V

    .line 429
    invoke-virtual {p1}, Ljava/io/File;->length()J

    move-result-wide v3

    cmp-long v3, v1, v3

    if-nez v3, :cond_66

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_66

    .line 430
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v3

    cmp-long p1, v1, v3

    if-nez p1, :cond_66

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_66

    :goto_65
    return-void

    .line 431
    :cond_66
    new-instance p1, Ljava/io/IOException;

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Migration copy/hash mismatch: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {p1, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public static dataPath(Landroid/content/Context;)Ljava/lang/String;
    .registers 1

    .line 93
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-virtual {p0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public static deleteFile(Landroid/content/Context;Ljava/lang/String;)Z
    .registers 2

    .line 126
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0, p1}, Landroid/content/Context;->deleteFile(Ljava/lang/String;)Z

    move-result p0

    return p0
.end method

.method static directory(Ljava/io/File;)Ljava/io/File;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 287
    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z

    move-result v0

    if-nez v0, :cond_27

    invoke-virtual {p0}, Ljava/io/File;->mkdirs()Z

    move-result v0

    if-nez v0, :cond_27

    invoke-virtual {p0}, Ljava/io/File;->isDirectory()Z

    move-result v0

    if-eqz v0, :cond_13

    goto :goto_27

    .line 288
    :cond_13
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Cannot create directory: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 290
    :cond_27
    :goto_27
    invoke-virtual {p0}, Ljava/io/File;->canRead()Z

    move-result v0

    if-eqz v0, :cond_34

    invoke-virtual {p0}, Ljava/io/File;->canWrite()Z

    move-result v0

    if-eqz v0, :cond_34

    return-object p0

    :cond_34
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Directory inaccessible: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static excluded(Ljava/lang/String;)Z
    .registers 24

    move-object/from16 v0, p0

    .line 304
    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "/"

    invoke-virtual {v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    array-length v2, v1

    const/4 v3, 0x0

    move v4, v3

    :goto_11
    const/4 v5, 0x1

    if-ge v4, v2, :cond_3e

    aget-object v6, v1, v4

    .line 305
    const-string v16, "temporaryvideostorage"

    const-string v17, ".port-storage"

    const-string v7, "cache"

    const-string v8, "code_cache"

    const-string v9, "lib"

    const-string v10, "no_backup"

    const-string v11, "app_webview"

    const-string v12, "app_plugins"

    const-string v13, "obb"

    const-string v14, "media"

    const-string v15, "assets"

    filled-new-array/range {v7 .. v17}, [Ljava/lang/String;

    move-result-object v7

    invoke-static {v7}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v7

    .line 307
    invoke-interface {v7, v6}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_3b

    return v5

    :cond_3b
    add-int/lit8 v4, v4, 0x1

    goto :goto_11

    .line 309
    :cond_3e
    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    .line 311
    const-string v2, "save/"

    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_5d

    const-string v0, ".png"

    invoke-virtual {v1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_5c

    const-string v0, ".bmpzip"

    invoke-virtual {v1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_5d

    :cond_5c
    return v3

    .line 312
    :cond_5d
    const-string v21, ".jpeg"

    const-string v22, ".webp"

    const-string v6, ".obb"

    const-string v7, ".apk"

    const-string v8, ".so"

    const-string v9, ".jar"

    const-string v10, ".dex"

    const-string v11, ".swf"

    const-string v12, ".flv"

    const-string v13, ".mp4"

    const-string v14, ".mp3"

    const-string v15, ".ogg"

    const-string v16, ".wav"

    const-string v17, ".fsb"

    const-string v18, ".fev"

    const-string v19, ".png"

    const-string v20, ".jpg"

    filled-new-array/range {v6 .. v22}, [Ljava/lang/String;

    move-result-object v0

    move v2, v3

    :goto_84
    const/16 v4, 0x11

    if-ge v2, v4, :cond_94

    aget-object v4, v0, v2

    .line 314
    invoke-virtual {v1, v4}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_91

    return v5

    :cond_91
    add-int/lit8 v2, v2, 0x1

    goto :goto_84

    :cond_94
    return v3
.end method

.method public static externalFileRoots(Landroid/content/Context;Ljava/lang/String;)[Ljava/io/File;
    .registers 4

    .line 135
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    const/4 v0, 0x0

    const/4 v1, 0x1

    if-nez p1, :cond_f

    .line 136
    new-array p1, v1, [Ljava/io/File;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    aput-object p0, p1, v0

    return-object p1

    .line 137
    :cond_f
    :try_start_f
    new-array v1, v1, [Ljava/io/File;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->fileName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p0

    aput-object p0, v1, v0
    :try_end_21
    .catch Ljava/io/IOException; {:try_start_f .. :try_end_21} :catch_22

    return-object v1

    :catch_22
    move-exception p0

    .line 138
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "External file root unavailable"

    invoke-direct {p1, v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1
.end method

.method static fileName(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    if-eqz p0, :cond_30

    .line 279
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_30

    const-string v0, "."

    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_30

    const-string v0, ".."

    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_30

    const-string v0, "/"

    .line 280
    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_30

    const-string v0, "\\"

    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_30

    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    if-gez v0, :cond_30

    return-object p0

    .line 281
    :cond_30
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Invalid preference/file name"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static filePath(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;
    .registers 2

    .line 119
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0, p1}, Landroid/content/Context;->getFileStreamPath(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    return-object p0
.end method

.method public static files(Landroid/content/Context;)Ljava/io/File;
    .registers 1

    .line 116
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object p0

    return-object p0
.end method

.method public static flush(Landroid/content/Context;)V
    .registers 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 160
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    .line 161
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->awaitWrites()V

    return-void
.end method

.method static hash(Ljava/io/File;)Ljava/lang/String;
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 338
    :try_start_0
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_5
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_0 .. :try_end_5} :catch_55

    .line 339
    :try_start_5
    const-string p0, "SHA-256"

    invoke-static {p0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object p0

    const/high16 v1, 0x10000

    .line 340
    new-array v1, v1, [B

    .line 342
    :goto_f
    invoke-virtual {v0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v2

    const/4 v3, -0x1

    const/4 v4, 0x0

    if-eq v2, v3, :cond_1b

    invoke-virtual {p0, v1, v4, v2}, Ljava/security/MessageDigest;->update([BII)V

    goto :goto_f

    .line 343
    :cond_1b
    new-instance v1, Ljava/lang/StringBuilder;

    const/16 v2, 0x40

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(I)V

    .line 344
    invoke-virtual {p0}, Ljava/security/MessageDigest;->digest()[B

    move-result-object p0

    array-length v2, p0

    :goto_27
    if-ge v4, v2, :cond_43

    aget-byte v3, p0, v4

    sget-object v5, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    const-string v6, "%02x"

    and-int/lit16 v3, v3, 0xff

    .line 345
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    filled-new-array {v3}, [Ljava/lang/Object;

    move-result-object v3

    .line 344
    invoke-static {v5, v6, v3}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    add-int/lit8 v4, v4, 0x1

    goto :goto_27

    .line 346
    :cond_43
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0
    :try_end_47
    .catchall {:try_start_5 .. :try_end_47} :catchall_4b

    .line 347
    :try_start_47
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    :try_end_4a
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_47 .. :try_end_4a} :catch_55

    return-object p0

    :catchall_4b
    move-exception p0

    .line 338
    :try_start_4c
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    :try_end_4f
    .catchall {:try_start_4c .. :try_end_4f} :catchall_50

    goto :goto_54

    :catchall_50
    move-exception v0

    :try_start_51
    invoke-virtual {p0, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_54
    throw p0
    :try_end_55
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_51 .. :try_end_55} :catch_55

    :catch_55
    move-exception p0

    .line 348
    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw v0
.end method

.method public static initialize(Landroid/content/Context;)V
    .registers 6

    .line 70
    const-string v0, "save"

    const-string v1, "log"

    const-string v2, "files"

    const-string v3, "shared_prefs"

    const-string v4, "com.stoicstudio.BannerSaga"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0}, Lcom/stoicstudio/port/PortStorage;->initialize(Landroid/content/Context;[Ljava/lang/String;)V

    return-void
.end method

.method public static declared-synchronized initialize(Landroid/content/Context;[Ljava/lang/String;)V
    .registers 4

    const-class v0, Lcom/stoicstudio/port/PortStorage;

    monitor-enter v0

    .line 76
    :try_start_3
    sget-object v1, Lcom/stoicstudio/port/PortStorage;->state:Lcom/stoicstudio/port/PortStorage$State;

    if-eqz v1, :cond_22

    .line 77
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    .line 78
    sget-object p0, Lcom/stoicstudio/port/PortStorage;->state:Lcom/stoicstudio/port/PortStorage$State;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->validateRoots([Ljava/lang/String;)Ljava/util/List;

    move-result-object p1

    invoke-interface {p0, p1}, Ljava/util/List;->equals(Ljava/lang/Object;)Z

    move-result p0
    :try_end_16
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_16} :catch_32
    .catch Lorg/json/JSONException; {:try_start_3 .. :try_end_16} :catch_30
    .catchall {:try_start_3 .. :try_end_16} :catchall_2e

    if-eqz p0, :cond_1a

    .line 81
    monitor-exit v0

    return-void

    .line 79
    :cond_1a
    :try_start_1a
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Migration roots changed in the same process"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 83
    :cond_22
    new-instance v1, Lcom/stoicstudio/port/PortStorage$State;

    invoke-direct {v1, p0, p1}, Lcom/stoicstudio/port/PortStorage$State;-><init>(Landroid/content/Context;[Ljava/lang/String;)V

    .line 84
    invoke-virtual {v1}, Lcom/stoicstudio/port/PortStorage$State;->migrate()V

    .line 85
    sput-object v1, Lcom/stoicstudio/port/PortStorage;->state:Lcom/stoicstudio/port/PortStorage$State;
    :try_end_2c
    .catch Ljava/io/IOException; {:try_start_1a .. :try_end_2c} :catch_32
    .catch Lorg/json/JSONException; {:try_start_1a .. :try_end_2c} :catch_30
    .catchall {:try_start_1a .. :try_end_2c} :catchall_2e

    .line 89
    monitor-exit v0

    return-void

    :catchall_2e
    move-exception p0

    goto :goto_3b

    :catch_30
    move-exception p0

    goto :goto_33

    :catch_32
    move-exception p0

    .line 87
    :goto_33
    :try_start_33
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v1, "PortStorage initialization failed"

    invoke-direct {p1, v1, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1

    :goto_3b
    monitor-exit v0
    :try_end_3c
    .catchall {:try_start_33 .. :try_end_3c} :catchall_2e

    throw p0
.end method

.method public static input(Landroid/content/Context;Ljava/lang/String;)Ljava/io/FileInputStream;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 121
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0, p1}, Landroid/content/Context;->openFileInput(Ljava/lang/String;)Ljava/io/FileInputStream;

    move-result-object p0

    return-object p0
.end method

.method public static inventory(Landroid/content/Context;[Ljava/lang/String;)Lorg/json/JSONObject;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 233
    new-instance v0, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object p0

    iget-object p0, p0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->getCanonicalFile()Ljava/io/File;

    move-result-object p0

    .line 234
    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->validateRoots([Ljava/lang/String;)Ljava/util/List;

    move-result-object p1

    const/4 v0, 0x0

    invoke-static {p0, p1, v0}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object p0

    return-object p0
.end method

.method private static isDatabase(Ljava/lang/String;Ljava/io/File;)Z
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 368
    sget-object v0, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p0, v0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v0

    .line 369
    const-string v1, "databases/"

    invoke-virtual {p0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result p0

    const/4 v1, 0x1

    if-nez p0, :cond_5e

    const-string p0, ".db"

    invoke-virtual {v0, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-nez p0, :cond_5e

    const-string p0, ".sqlite"

    invoke-virtual {v0, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-nez p0, :cond_5e

    const-string p0, "-wal"

    .line 370
    invoke-virtual {v0, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-nez p0, :cond_5e

    const-string p0, "-shm"

    invoke-virtual {v0, p0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_30

    goto :goto_5e

    :cond_30
    const/16 p0, 0x10

    .line 371
    new-array v0, p0, [B

    .line 372
    new-instance v2, Ljava/io/FileInputStream;

    invoke-direct {v2, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 373
    :try_start_39
    invoke-virtual {v2, v0}, Ljava/io/InputStream;->read([B)I

    move-result p1

    if-ne p1, p0, :cond_4f

    .line 374
    const-string p0, "SQLite format 3\u0000"

    new-instance p1, Ljava/lang/String;

    sget-object v3, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;

    invoke-direct {p1, v0, v3}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    invoke-virtual {p0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0
    :try_end_4c
    .catchall {:try_start_39 .. :try_end_4c} :catchall_54

    if-eqz p0, :cond_4f

    goto :goto_50

    :cond_4f
    const/4 v1, 0x0

    .line 375
    :goto_50
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V

    return v1

    :catchall_54
    move-exception p0

    .line 372
    :try_start_55
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V
    :try_end_58
    .catchall {:try_start_55 .. :try_end_58} :catchall_59

    goto :goto_5d

    :catchall_59
    move-exception p1

    invoke-virtual {p0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_5d
    throw p0

    :cond_5e
    :goto_5e
    return v1
.end method

.method public static declared-synchronized isReady()Z
    .registers 2

    const-class v0, Lcom/stoicstudio/port/PortStorage;

    monitor-enter v0

    .line 66
    :try_start_3
    sget-object v1, Lcom/stoicstudio/port/PortStorage;->state:Lcom/stoicstudio/port/PortStorage$State;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_c

    if-eqz v1, :cond_9

    const/4 v1, 0x1

    goto :goto_a

    :cond_9
    const/4 v1, 0x0

    :goto_a
    monitor-exit v0

    return v1

    :catchall_c
    move-exception v1

    :try_start_d
    monitor-exit v0
    :try_end_e
    .catchall {:try_start_d .. :try_end_e} :catchall_c

    throw v1
.end method

.method static synthetic lambda$awaitWrites$0()Ljava/lang/Boolean;
    .registers 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const/4 v0, 0x1

    .line 476
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    return-object v0
.end method

.method static synthetic lambda$copyVerified$0(Ljava/io/File;Ljava/io/OutputStream;)V
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 423
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    const/high16 p0, 0x10000

    .line 424
    :try_start_7
    new-array p0, p0, [B

    .line 426
    :goto_9
    invoke-virtual {v0, p0}, Ljava/io/InputStream;->read([B)I

    move-result v1

    const/4 v2, -0x1

    if-eq v1, v2, :cond_15

    const/4 v2, 0x0

    invoke-virtual {p1, p0, v2, v1}, Ljava/io/OutputStream;->write([BII)V
    :try_end_14
    .catchall {:try_start_7 .. :try_end_14} :catchall_19

    goto :goto_9

    .line 427
    :cond_15
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    return-void

    :catchall_19
    move-exception p0

    .line 423
    :try_start_1a
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    :try_end_1d
    .catchall {:try_start_1a .. :try_end_1d} :catchall_1e

    goto :goto_22

    :catchall_1e
    move-exception p1

    invoke-virtual {p0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_22
    throw p0
.end method

.method static synthetic lambda$static$0(Ljava/lang/Runnable;)Ljava/lang/Thread;
    .registers 3

    .line 61
    new-instance v0, Ljava/lang/Thread;

    const-string v1, "PortStorage-prefs"

    invoke-direct {v0, p0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    return-object v0
.end method

.method static synthetic lambda$writeJson$0([BLjava/io/OutputStream;)V
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 447
    invoke-virtual {p1, p0}, Ljava/io/OutputStream;->write([B)V

    return-void
.end method

.method static synthetic lambda$writeXml$0(Ljava/util/Map;Ljava/io/OutputStream;)V
    .registers 11
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 733
    invoke-static {}, Landroid/util/Xml;->newSerializer()Lorg/xmlpull/v1/XmlSerializer;

    move-result-object v0

    .line 734
    const-string v1, "UTF-8"

    invoke-interface {v0, p1, v1}, Lorg/xmlpull/v1/XmlSerializer;->setOutput(Ljava/io/OutputStream;Ljava/lang/String;)V

    const/4 p1, 0x1

    .line 735
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    invoke-interface {v0, v1, p1}, Lorg/xmlpull/v1/XmlSerializer;->startDocument(Ljava/lang/String;Ljava/lang/Boolean;)V

    const/4 p1, 0x0

    .line 736
    const-string v1, "map"

    invoke-interface {v0, p1, v1}, Lorg/xmlpull/v1/XmlSerializer;->startTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    .line 737
    new-instance v2, Ljava/util/TreeMap;

    invoke-direct {v2, p0}, Ljava/util/TreeMap;-><init>(Ljava/util/Map;)V

    invoke-virtual {v2}, Ljava/util/TreeMap;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_24
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_b6

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/Map$Entry;

    .line 738
    invoke-interface {v2}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    .line 739
    instance-of v4, v3, Ljava/lang/String;

    const-string v5, "string"

    if-eqz v4, :cond_3c

    move-object v6, v5

    goto :goto_60

    :cond_3c
    instance-of v6, v3, Ljava/util/Set;

    if-eqz v6, :cond_43

    const-string v6, "set"

    goto :goto_60

    .line 740
    :cond_43
    instance-of v6, v3, Ljava/lang/Integer;

    if-eqz v6, :cond_4a

    const-string v6, "int"

    goto :goto_60

    :cond_4a
    instance-of v6, v3, Ljava/lang/Long;

    if-eqz v6, :cond_51

    const-string v6, "long"

    goto :goto_60

    .line 741
    :cond_51
    instance-of v6, v3, Ljava/lang/Float;

    if-eqz v6, :cond_58

    const-string v6, "float"

    goto :goto_60

    :cond_58
    instance-of v6, v3, Ljava/lang/Boolean;

    if-eqz v6, :cond_5f

    const-string v6, "boolean"

    goto :goto_60

    :cond_5f
    move-object v6, p1

    :goto_60
    if-eqz v6, :cond_ae

    .line 743
    invoke-interface {v0, p1, v6}, Lorg/xmlpull/v1/XmlSerializer;->startTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    move-result-object v7

    invoke-interface {v2}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    const-string v8, "name"

    invoke-interface {v7, p1, v8, v2}, Lorg/xmlpull/v1/XmlSerializer;->attribute(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    if-eqz v4, :cond_79

    .line 744
    check-cast v3, Ljava/lang/String;

    invoke-interface {v0, v3}, Lorg/xmlpull/v1/XmlSerializer;->text(Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    goto :goto_a9

    .line 745
    :cond_79
    instance-of v2, v3, Ljava/util/Set;

    if-eqz v2, :cond_a0

    .line 746
    check-cast v3, Ljava/util/Set;

    .line 747
    new-instance v2, Ljava/util/TreeSet;

    invoke-direct {v2, v3}, Ljava/util/TreeSet;-><init>(Ljava/util/Collection;)V

    invoke-virtual {v2}, Ljava/util/TreeSet;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_88
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_a9

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .line 748
    invoke-interface {v0, p1, v5}, Lorg/xmlpull/v1/XmlSerializer;->startTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    move-result-object v4

    invoke-interface {v4, v3}, Lorg/xmlpull/v1/XmlSerializer;->text(Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    move-result-object v3

    invoke-interface {v3, p1, v5}, Lorg/xmlpull/v1/XmlSerializer;->endTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    goto :goto_88

    .line 750
    :cond_a0
    const-string v2, "value"

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-interface {v0, p1, v2, v3}, Lorg/xmlpull/v1/XmlSerializer;->attribute(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    .line 751
    :cond_a9
    :goto_a9
    invoke-interface {v0, p1, v6}, Lorg/xmlpull/v1/XmlSerializer;->endTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    goto/16 :goto_24

    .line 742
    :cond_ae
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Unsupported preference value"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 753
    :cond_b6
    invoke-interface {v0, p1, v1}, Lorg/xmlpull/v1/XmlSerializer;->endTag(Ljava/lang/String;Ljava/lang/String;)Lorg/xmlpull/v1/XmlSerializer;

    .line 754
    invoke-interface {v0}, Lorg/xmlpull/v1/XmlSerializer;->endDocument()V

    .line 755
    invoke-interface {v0}, Lorg/xmlpull/v1/XmlSerializer;->flush()V

    return-void
.end method

.method public static noBackupFiles(Landroid/content/Context;)Ljava/io/File;
    .registers 1

    .line 118
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getNoBackupFilesDir()Ljava/io/File;

    move-result-object p0

    return-object p0
.end method

.method public static output(Landroid/content/Context;Ljava/lang/String;I)Ljava/io/FileOutputStream;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 124
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->openFileOutput(Ljava/lang/String;I)Ljava/io/FileOutputStream;

    move-result-object p0

    return-object p0
.end method

.method private static ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;
    .registers 3

    .line 112
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v0

    iget-object v0, v0, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_14

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->wrap(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    :cond_14
    return-object p0
.end method

.method public static packageContext(Landroid/content/Context;Ljava/lang/String;I)Landroid/content/Context;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/content/pm/PackageManager$NameNotFoundException;
        }
    .end annotation

    .line 129
    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    move-result-object p0

    .line 130
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->ownedOrForeign(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    return-object p0
.end method

.method public static preferences(Landroid/content/Context;Ljava/lang/String;I)Landroid/content/SharedPreferences;
    .registers 9

    const-string v0, "Cannot read external preferences: "

    .line 166
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v1

    .line 167
    iget-object v2, v1, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_17

    .line 168
    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object p0

    return-object p0

    :cond_17
    and-int/lit8 p0, p2, 0x4

    if-nez p0, :cond_73

    .line 174
    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->fileName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 175
    iget-object p1, v1, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    monitor-enter p1

    .line 176
    :try_start_22
    iget-object p2, v1, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    invoke-interface {p2, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p2

    check-cast p2, Lcom/stoicstudio/port/PortStorage$Prefs;

    if-eqz p2, :cond_2e

    .line 177
    monitor-exit p1
    :try_end_2d
    .catchall {:try_start_22 .. :try_end_2d} :catchall_70

    return-object p2

    .line 179
    :cond_2e
    :try_start_2e
    new-instance p2, Ljava/io/File;

    iget-object v2, v1, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    const-string v3, "shared_prefs"

    invoke-direct {p2, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {p2}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p2

    .line 180
    new-instance v2, Lcom/stoicstudio/port/PortStorage$Prefs;

    new-instance v3, Ljava/io/File;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, ".xml"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v3, p2, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-direct {v2, v3}, Lcom/stoicstudio/port/PortStorage$Prefs;-><init>(Ljava/io/File;)V

    .line 181
    iget-object p2, v1, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    invoke-interface {p2, p0, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_5b
    .catch Ljava/io/IOException; {:try_start_2e .. :try_end_5b} :catch_5d
    .catchall {:try_start_2e .. :try_end_5b} :catchall_70

    .line 182
    :try_start_5b
    monitor-exit p1

    return-object v2

    :catch_5d
    move-exception p2

    .line 184
    new-instance v1, Ljava/lang/IllegalStateException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v1, p0, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1

    :catchall_70
    move-exception p0

    .line 186
    monitor-exit p1
    :try_end_72
    .catchall {:try_start_5b .. :try_end_72} :catchall_70

    throw p0

    .line 172
    :cond_73
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "No verified multi-process preference consumer"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static readJson(Ljava/io/File;)Lorg/json/JSONObject;
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;,
            Lorg/json/JSONException;
        }
    .end annotation

    .line 465
    new-instance v0, Landroid/util/AtomicFile;

    invoke-direct {v0, p0}, Landroid/util/AtomicFile;-><init>(Ljava/io/File;)V

    invoke-virtual {v0}, Landroid/util/AtomicFile;->openRead()Ljava/io/FileInputStream;

    move-result-object p0

    .line 466
    :try_start_9
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V
    :try_end_e
    .catchall {:try_start_9 .. :try_end_e} :catchall_41

    const/16 v1, 0x2000

    .line 467
    :try_start_10
    new-array v1, v1, [B

    .line 469
    :goto_12
    invoke-virtual {p0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v2

    const/4 v3, -0x1

    if-eq v2, v3, :cond_1e

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_12

    .line 470
    :cond_1e
    new-instance v1, Lorg/json/JSONObject;

    new-instance v2, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v3

    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v2, v3, v4}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    invoke-direct {v1, v2}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    :try_end_2e
    .catchall {:try_start_10 .. :try_end_2e} :catchall_37

    .line 471
    :try_start_2e
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->close()V
    :try_end_31
    .catchall {:try_start_2e .. :try_end_31} :catchall_41

    if-eqz p0, :cond_36

    invoke-virtual {p0}, Ljava/io/InputStream;->close()V

    :cond_36
    return-object v1

    :catchall_37
    move-exception v1

    .line 465
    :try_start_38
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->close()V
    :try_end_3b
    .catchall {:try_start_38 .. :try_end_3b} :catchall_3c

    goto :goto_40

    :catchall_3c
    move-exception v0

    :try_start_3d
    invoke-virtual {v1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_40
    throw v1
    :try_end_41
    .catchall {:try_start_3d .. :try_end_41} :catchall_41

    :catchall_41
    move-exception v0

    if-eqz p0, :cond_4c

    :try_start_44
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V
    :try_end_47
    .catchall {:try_start_44 .. :try_end_47} :catchall_48

    goto :goto_4c

    :catchall_48
    move-exception p0

    invoke-virtual {v0, p0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_4c
    :goto_4c
    throw v0
.end method

.method static readXml(Ljava/io/File;Z)Ljava/util/Map;
    .registers 13
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Z)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 677
    const-string v0, "set"

    const-string v1, "string"

    const-string v2, "map"

    invoke-virtual {p0}, Ljava/io/File;->exists()Z

    move-result v3

    if-nez v3, :cond_34

    if-eqz p1, :cond_2e

    new-instance v3, Ljava/io/File;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, ".bak"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v3, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    move-result v3

    if-nez v3, :cond_34

    .line 678
    :cond_2e
    new-instance p0, Ljava/util/LinkedHashMap;

    invoke-direct {p0}, Ljava/util/LinkedHashMap;-><init>()V

    return-object p0

    :cond_34
    if-eqz p1, :cond_40

    .line 680
    :try_start_36
    new-instance p1, Landroid/util/AtomicFile;

    invoke-direct {p1, p0}, Landroid/util/AtomicFile;-><init>(Ljava/io/File;)V

    invoke-virtual {p1}, Landroid/util/AtomicFile;->openRead()Ljava/io/FileInputStream;

    move-result-object p1

    goto :goto_45

    :cond_40
    new-instance p1, Ljava/io/FileInputStream;

    invoke-direct {p1, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_45
    .catch Lorg/xmlpull/v1/XmlPullParserException; {:try_start_36 .. :try_end_45} :catch_1ab
    .catch Ljava/lang/NumberFormatException; {:try_start_36 .. :try_end_45} :catch_1a9

    .line 681
    :goto_45
    :try_start_45
    invoke-static {}, Landroid/util/Xml;->newPullParser()Lorg/xmlpull/v1/XmlPullParser;

    move-result-object v3

    .line 682
    const-string v4, "UTF-8"

    invoke-interface {v3, p1, v4}, Lorg/xmlpull/v1/XmlPullParser;->setInput(Ljava/io/InputStream;Ljava/lang/String;)V

    .line 683
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextTag()I

    move-result v4

    const/4 v5, 0x2

    if-ne v4, v5, :cond_195

    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_195

    .line 686
    new-instance v4, Ljava/util/LinkedHashMap;

    invoke-direct {v4}, Ljava/util/LinkedHashMap;-><init>()V

    .line 687
    :goto_64
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextTag()I

    move-result v6

    if-ne v6, v5, :cond_162

    .line 688
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v6

    .line 689
    const-string v7, "name"

    const/4 v8, 0x0

    invoke-interface {v3, v8, v7}, Lorg/xmlpull/v1/XmlPullParser;->getAttributeValue(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    if-eqz v7, :cond_15a

    .line 690
    invoke-virtual {v4, v7}, Ljava/util/LinkedHashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v9

    if-nez v9, :cond_15a

    .line 692
    invoke-virtual {v1, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_89

    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextText()Ljava/lang/String;

    move-result-object v6

    goto/16 :goto_12e

    .line 693
    :cond_89
    invoke-virtual {v0, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_c8

    .line 694
    new-instance v6, Ljava/util/HashSet;

    invoke-direct {v6}, Ljava/util/HashSet;-><init>()V

    .line 695
    :goto_94
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextTag()I

    move-result v8

    if-ne v8, v5, :cond_b4

    .line 696
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v1, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_ac

    .line 697
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextText()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v8}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    goto :goto_94

    .line 696
    :cond_ac
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Bad StringSet member"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 699
    :cond_b4
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v0, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_c0

    goto/16 :goto_12e

    :cond_c0
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Bad StringSet terminator"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 702
    :cond_c8
    const-string v9, "value"

    invoke-interface {v3, v8, v9}, Lorg/xmlpull/v1/XmlPullParser;->getAttributeValue(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    if-eqz v8, :cond_152

    .line 704
    const-string v9, "boolean"

    invoke-virtual {v9, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_f6

    .line 705
    const-string v9, "true"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-nez v9, :cond_f1

    const-string v9, "false"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_e9

    goto :goto_f1

    .line 706
    :cond_e9
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Bad preference boolean"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 708
    :cond_f1
    :goto_f1
    invoke-static {v8}, Ljava/lang/Boolean;->valueOf(Ljava/lang/String;)Ljava/lang/Boolean;

    move-result-object v8

    goto :goto_11c

    .line 709
    :cond_f6
    const-string v9, "int"

    invoke-virtual {v9, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_103

    invoke-static {v8}, Ljava/lang/Integer;->valueOf(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v8

    goto :goto_11c

    .line 710
    :cond_103
    const-string v9, "long"

    invoke-virtual {v9, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_110

    invoke-static {v8}, Ljava/lang/Long;->valueOf(Ljava/lang/String;)Ljava/lang/Long;

    move-result-object v8

    goto :goto_11c

    .line 711
    :cond_110
    const-string v9, "float"

    invoke-virtual {v9, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_13b

    invoke-static {v8}, Ljava/lang/Float;->valueOf(Ljava/lang/String;)Ljava/lang/Float;

    move-result-object v8

    .line 713
    :goto_11c
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->nextTag()I

    move-result v9

    const/4 v10, 0x3

    if-ne v9, v10, :cond_133

    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v6, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_133

    move-object v6, v8

    .line 717
    :goto_12e
    invoke-virtual {v4, v7, v6}, Ljava/util/LinkedHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto/16 :goto_64

    .line 714
    :cond_133
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Bad preference terminator"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 712
    :cond_13b
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Unknown preference XML type: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 703
    :cond_152
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Missing primitive preference value"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 690
    :cond_15a
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Missing/duplicate preference key"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 719
    :cond_162
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->getName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_18d

    .line 721
    :cond_16c
    :goto_16c
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->next()I

    move-result v0

    const/4 v1, 0x1

    if-eq v0, v1, :cond_187

    if-eq v0, v5, :cond_17f

    const/4 v1, 0x4

    if-ne v0, v1, :cond_16c

    .line 723
    invoke-interface {v3}, Lorg/xmlpull/v1/XmlPullParser;->isWhitespace()Z

    move-result v0

    if-eqz v0, :cond_17f

    goto :goto_16c

    :cond_17f
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Trailing preference content"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_187
    .catchall {:try_start_45 .. :try_end_187} :catchall_19d

    :cond_187
    if-eqz p1, :cond_18c

    .line 726
    :try_start_189
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V
    :try_end_18c
    .catch Lorg/xmlpull/v1/XmlPullParserException; {:try_start_189 .. :try_end_18c} :catch_1ab
    .catch Ljava/lang/NumberFormatException; {:try_start_189 .. :try_end_18c} :catch_1a9

    :cond_18c
    return-object v4

    .line 719
    :cond_18d
    :try_start_18d
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Bad map terminator"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 684
    :cond_195
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Preference XML is not a map"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_19d
    .catchall {:try_start_18d .. :try_end_19d} :catchall_19d

    :catchall_19d
    move-exception v0

    if-eqz p1, :cond_1a8

    .line 680
    :try_start_1a0
    invoke-virtual {p1}, Ljava/io/InputStream;->close()V
    :try_end_1a3
    .catchall {:try_start_1a0 .. :try_end_1a3} :catchall_1a4

    goto :goto_1a8

    :catchall_1a4
    move-exception p1

    :try_start_1a5
    invoke-virtual {v0, p1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_1a8
    :goto_1a8
    throw v0
    :try_end_1a9
    .catch Lorg/xmlpull/v1/XmlPullParserException; {:try_start_1a5 .. :try_end_1a9} :catch_1ab
    .catch Ljava/lang/NumberFormatException; {:try_start_1a5 .. :try_end_1a9} :catch_1a9

    :catch_1a9
    move-exception p1

    goto :goto_1ac

    :catch_1ab
    move-exception p1

    .line 727
    :goto_1ac
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Malformed preference XML: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v0
.end method

.method private static declared-synchronized requireInitialized()Lcom/stoicstudio/port/PortStorage$State;
    .registers 3

    const-class v0, Lcom/stoicstudio/port/PortStorage;

    monitor-enter v0

    .line 238
    :try_start_3
    sget-object v1, Lcom/stoicstudio/port/PortStorage;->state:Lcom/stoicstudio/port/PortStorage$State;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_11

    if-eqz v1, :cond_9

    .line 239
    monitor-exit v0

    return-object v1

    .line 238
    :cond_9
    :try_start_9
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "PortStorage must run before AIR/SDK startup"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    :catchall_11
    move-exception v1

    monitor-exit v0
    :try_end_13
    .catchall {:try_start_9 .. :try_end_13} :catchall_11

    throw v1
.end method

.method private static requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    .registers 3

    .line 243
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v0

    .line 244
    iget-object v1, v0, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_11

    return-object v0

    .line 245
    :cond_11
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Context belongs to a different package"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static saveRoot(Landroid/content/Context;)Ljava/io/File;
    .registers 1

    .line 141
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    return-object p0
.end method

.method public static savedGame(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;
    .registers 7

    if-eqz p1, :cond_64

    .line 145
    const-string v0, "save/"

    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_64

    const-string v0, ".save.json"

    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_64

    const-string v0, "\\"

    .line 146
    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_64

    const-string v0, ":"

    invoke-virtual {p1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_64

    .line 149
    const-string v0, "/"

    const/4 v1, -0x1

    invoke-virtual {p1, v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_2b
    if-ge v2, v1, :cond_50

    aget-object v3, v0, v2

    .line 150
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-nez v4, :cond_48

    const-string v4, "."

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_48

    const-string v4, ".."

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_48

    add-int/lit8 v2, v2, 0x1

    goto :goto_2b

    .line 151
    :cond_48
    new-instance p0, Ljava/lang/SecurityException;

    const-string p1, "Invalid SavedGames path component"

    invoke-direct {p0, p1}, Ljava/lang/SecurityException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 154
    :cond_50
    :try_start_50
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object p0
    :try_end_5a
    .catch Ljava/io/IOException; {:try_start_50 .. :try_end_5a} :catch_5b

    return-object p0

    :catch_5b
    move-exception p0

    .line 155
    new-instance p1, Ljava/lang/SecurityException;

    const-string v0, "SavedGames path escaped owned storage"

    invoke-direct {p1, v0, p0}, Ljava/lang/SecurityException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1

    .line 147
    :cond_64
    new-instance p0, Ljava/lang/SecurityException;

    const-string p1, "SavedGames path is outside the save scope"

    invoke-direct {p0, p1}, Ljava/lang/SecurityException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;
    .registers 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;Z)",
            "Lorg/json/JSONObject;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 353
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V

    .line 355
    :try_start_5
    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_11
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result p1

    if-eqz p1, :cond_81

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/Map$Entry;

    if-eqz p2, :cond_4f

    .line 356
    invoke-interface {p1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-interface {p1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/io/File;

    invoke-static {v1, v2}, Lcom/stoicstudio/port/PortStorage;->isDatabase(Ljava/lang/String;Ljava/io/File;)Z

    move-result v1

    if-nez v1, :cond_32

    goto :goto_4f

    .line 357
    :cond_32
    new-instance p0, Ljava/io/IOException;

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Database owner must be closed/routed first: "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-interface {p1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 359
    :cond_4f
    :goto_4f
    invoke-interface {p1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-interface {p1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/io/File;

    invoke-virtual {v3}, Ljava/io/File;->length()J

    move-result-wide v3

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v3, ":"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-interface {p1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/io/File;

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :try_end_80
    .catch Lorg/json/JSONException; {:try_start_5 .. :try_end_80} :catch_82

    goto :goto_11

    :cond_81
    return-object v0

    :catch_82
    move-exception p0

    .line 362
    new-instance p1, Ljava/io/IOException;

    invoke-direct {p1, p0}, Ljava/io/IOException;-><init>(Ljava/lang/Throwable;)V

    throw p1
.end method

.method private static validateRoots([Ljava/lang/String;)Ljava/util/List;
    .registers 11
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([",
            "Ljava/lang/String;",
            ")",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-eqz p0, :cond_cc

    .line 251
    array-length v0, p0

    if-eqz v0, :cond_cc

    .line 254
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 255
    array-length v1, p0

    const/4 v2, 0x0

    move v3, v2

    :goto_d
    const-string v4, "/"

    if-ge v3, v1, :cond_87

    aget-object v5, p0, v3

    if-eqz v5, :cond_7f

    .line 256
    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-nez v6, :cond_7f

    invoke-virtual {v5, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_7f

    const-string v6, "\\"

    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-nez v6, :cond_7f

    const-string v6, ":"

    .line 257
    invoke-virtual {v5, v6}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-nez v6, :cond_7f

    const/4 v6, -0x1

    .line 258
    invoke-virtual {v5, v4, v6}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v4

    array-length v6, v4

    move v7, v2

    :goto_38
    if-ge v7, v6, :cond_5d

    aget-object v8, v4, v7

    .line 259
    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v9

    if-nez v9, :cond_55

    const-string v9, "."

    invoke-virtual {v8, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-nez v9, :cond_55

    const-string v9, ".."

    invoke-virtual {v8, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-nez v8, :cond_55

    add-int/lit8 v7, v7, 0x1

    goto :goto_38

    .line 260
    :cond_55
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Invalid migration path component"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 263
    :cond_5d
    invoke-static {v5}, Lcom/stoicstudio/port/PortStorage;->excluded(Ljava/lang/String;)Z

    move-result v4

    if-nez v4, :cond_77

    .line 264
    invoke-virtual {v0, v5}, Ljava/util/ArrayList;->contains(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_6f

    .line 265
    invoke-virtual {v0, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    add-int/lit8 v3, v3, 0x1

    goto :goto_d

    .line 264
    :cond_6f
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Duplicate migration root"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 263
    :cond_77
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Migration root is runtime/cache/media"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 257
    :cond_7f
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Invalid migration root"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 267
    :cond_87
    invoke-static {v0}, Ljava/util/Collections;->sort(Ljava/util/List;)V

    .line 268
    :goto_8a
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result p0

    if-ge v2, p0, :cond_c7

    add-int/lit8 p0, v2, 0x1

    move v1, p0

    .line 269
    :goto_93
    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v3

    if-ge v1, v3, :cond_c5

    .line 270
    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v3

    if-nez v3, :cond_bd

    add-int/lit8 v1, v1, 0x1

    goto :goto_93

    .line 271
    :cond_bd
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Overlapping migration roots"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_c5
    move v2, p0

    goto :goto_8a

    .line 275
    :cond_c7
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableList(Ljava/util/List;)Ljava/util/List;

    move-result-object p0

    return-object p0

    .line 252
    :cond_cc
    new-instance p0, Ljava/io/IOException;

    const-string v0, "Reviewed migration roots are required"

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static declared-synchronized verifyAfterRestart(Landroid/content/Context;)V
    .registers 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const-class v0, Lcom/stoicstudio/port/PortStorage;

    monitor-enter v0

    .line 209
    :try_start_3
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0
    :try_end_7
    .catchall {:try_start_3 .. :try_end_7} :catchall_90

    .line 211
    :try_start_7
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$State;->checkpoint:Ljava/io/File;

    invoke-static {v1}, Lcom/stoicstudio/port/PortStorage;->readJson(Ljava/io/File;)Lorg/json/JSONObject;

    move-result-object v1

    .line 212
    invoke-virtual {p0, v1}, Lcom/stoicstudio/port/PortStorage$State;->checkIdentity(Lorg/json/JSONObject;)V

    .line 213
    sget-object v2, Lcom/stoicstudio/port/PortStorage;->RUN:Ljava/lang/String;

    const-string v3, "run"

    invoke-virtual {v1, v3}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_7f

    const-string v3, "pid"

    .line 214
    invoke-virtual {v1, v3}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v3

    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v4

    if-eq v3, v4, :cond_7f

    .line 217
    const-string v3, "files"

    invoke-virtual {v1, v3}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v3

    iget-object v4, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    iget-object v5, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    const/4 v6, 0x0

    .line 218
    invoke-static {v4, v5, v6}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v4

    const-string v5, "External data changed since checkpoint"

    .line 217
    invoke-static {v3, v4, v5}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    .line 219
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$State;->identity()Lorg/json/JSONObject;

    move-result-object v3

    .line 220
    const-string v4, "run"

    invoke-virtual {v3, v4, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 221
    const-string v2, "pid"

    invoke-static {}, Landroid/os/Process;->myPid()I

    move-result v4

    invoke-virtual {v3, v2, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 222
    const-string v2, "checkpointPid"

    const-string v4, "pid"

    invoke-virtual {v1, v4}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v4

    invoke-virtual {v3, v2, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 223
    const-string v2, "checkpointRun"

    const-string v4, "run"

    invoke-virtual {v1, v4}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v2, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 224
    const-string v2, "files"

    const-string v4, "files"

    invoke-virtual {v1, v4}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v1

    invoke-virtual {v3, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 225
    new-instance v1, Ljava/io/File;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->control:Ljava/io/File;

    const-string v2, "restart-proof.json"

    invoke-direct {v1, p0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v1, v3}, Lcom/stoicstudio/port/PortStorage;->writeJson(Ljava/io/File;Lorg/json/JSONObject;)V
    :try_end_7d
    .catch Lorg/json/JSONException; {:try_start_7 .. :try_end_7d} :catch_87
    .catchall {:try_start_7 .. :try_end_7d} :catchall_90

    .line 229
    monitor-exit v0

    return-void

    .line 215
    :cond_7f
    :try_start_7f
    new-instance p0, Ljava/io/IOException;

    const-string v1, "Restart checkpoint belongs to this process"

    invoke-direct {p0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_87
    .catch Lorg/json/JSONException; {:try_start_7f .. :try_end_87} :catch_87
    .catchall {:try_start_7f .. :try_end_87} :catchall_90

    :catch_87
    move-exception p0

    .line 227
    :try_start_88
    new-instance v1, Ljava/io/IOException;

    const-string v2, "Invalid restart checkpoint"

    invoke-direct {v1, v2, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1

    :catchall_90
    move-exception p0

    monitor-exit v0
    :try_end_92
    .catchall {:try_start_88 .. :try_end_92} :catchall_90

    throw p0
.end method

.method public static wrap(Landroid/content/Context;)Landroid/content/Context;
    .registers 2

    .line 107
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    .line 108
    instance-of v0, p0, Lcom/stoicstudio/port/PortStorage$PortContext;

    if-eqz v0, :cond_8

    return-object p0

    :cond_8
    new-instance v0, Lcom/stoicstudio/port/PortStorage$PortContext;

    invoke-direct {v0, p0}, Lcom/stoicstudio/port/PortStorage$PortContext;-><init>(Landroid/content/Context;)V

    return-object v0
.end method

.method static writeJson(Ljava/io/File;Lorg/json/JSONObject;)V
    .registers 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 446
    const-string v0, "Control file verification failed"

    invoke-virtual {p1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object p1

    sget-object v1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {p1, v1}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object p1

    .line 447
    new-instance v1, Lcom/stoicstudio/port/PortStorage$3;

    invoke-direct {v1, p1}, Lcom/stoicstudio/port/PortStorage$3;-><init>([B)V

    invoke-static {p0, v1}, Lcom/stoicstudio/port/PortStorage;->atomicWrite(Ljava/io/File;Lcom/stoicstudio/port/PortStorage$WriteBody;)V

    .line 449
    :try_start_14
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->readJson(Ljava/io/File;)Lorg/json/JSONObject;

    .line 450
    const-string v1, "SHA-256"

    invoke-static {v1}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v1

    .line 451
    new-instance v2, Ljava/lang/StringBuilder;

    const/16 v3, 0x40

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(I)V

    .line 452
    invoke-virtual {v1, p1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v1

    array-length v3, v1

    const/4 v4, 0x0

    :goto_2a
    if-ge v4, v3, :cond_46

    aget-byte v5, v1, v4

    sget-object v6, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    const-string v7, "%02x"

    and-int/lit16 v5, v5, 0xff

    .line 453
    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    filled-new-array {v5}, [Ljava/lang/Object;

    move-result-object v5

    .line 452
    invoke-static {v6, v7, v5}, Ljava/lang/String;->format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v2, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    add-int/lit8 v4, v4, 0x1

    goto :goto_2a

    .line 454
    :cond_46
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v3

    array-length p1, p1

    int-to-long v5, p1

    cmp-long p1, v3, v5

    if-nez p1, :cond_5f

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->hash(Ljava/io/File;)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_5f

    return-void

    .line 455
    :cond_5f
    new-instance p0, Ljava/io/IOException;

    invoke-direct {p0, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_65
    .catch Lorg/json/JSONException; {:try_start_14 .. :try_end_65} :catch_6c
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_14 .. :try_end_65} :catch_65

    :catch_65
    move-exception p0

    .line 460
    new-instance p1, Ljava/lang/AssertionError;

    invoke-direct {p1, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V

    throw p1

    :catch_6c
    move-exception p0

    .line 458
    new-instance p1, Ljava/io/IOException;

    invoke-direct {p1, v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1
.end method

.method static writeXml(Ljava/io/File;Ljava/util/Map;)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 732
    new-instance v0, Lcom/stoicstudio/port/PortStorage$4;

    invoke-direct {v0, p1}, Lcom/stoicstudio/port/PortStorage$4;-><init>(Ljava/util/Map;)V

    invoke-static {p0, v0}, Lcom/stoicstudio/port/PortStorage;->atomicWrite(Ljava/io/File;Lcom/stoicstudio/port/PortStorage$WriteBody;)V

    const/4 v0, 0x1

    .line 757
    invoke-static {p0, v0}, Lcom/stoicstudio/port/PortStorage;->readXml(Ljava/io/File;Z)Ljava/util/Map;

    move-result-object p0

    invoke-interface {p1, p0}, Ljava/util/Map;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_14

    return-void

    :cond_14
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Preference verification failed"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
