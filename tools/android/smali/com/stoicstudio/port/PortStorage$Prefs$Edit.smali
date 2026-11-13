.class final Lcom/stoicstudio/port/PortStorage$Prefs$Edit;
.super Ljava/lang/Object;
.source "PortStorage.java"

# interfaces
.implements Landroid/content/SharedPreferences$Editor;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage$Prefs;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "Edit"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;
    }
.end annotation


# instance fields
.field private final changes:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field private clear:Z

.field private final removed:Ljava/lang/Object;

.field final synthetic this$0:Lcom/stoicstudio/port/PortStorage$Prefs;


# direct methods
.method private constructor <init>(Lcom/stoicstudio/port/PortStorage$Prefs;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1010
        }
        names = {
            null
        }
    .end annotation

    .line 804
    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 805
    new-instance p1, Ljava/lang/Object;

    invoke-direct {p1}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->removed:Ljava/lang/Object;

    .line 806
    new-instance p1, Ljava/util/LinkedHashMap;

    invoke-direct {p1}, Ljava/util/LinkedHashMap;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->changes:Ljava/util/Map;

    return-void
.end method

.method synthetic constructor <init>(Lcom/stoicstudio/port/PortStorage$Prefs;Lcom/stoicstudio/port/PortStorage$1;)V
    .registers 3

    .line 804
    invoke-direct {p0, p1}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;-><init>(Lcom/stoicstudio/port/PortStorage$Prefs;)V

    return-void
.end method

.method private declared-synchronized put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;
    .registers 4

    monitor-enter p0

    if-eqz p1, :cond_10

    .line 810
    :try_start_3
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->changes:Ljava/util/Map;

    if-nez p2, :cond_9

    iget-object p2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->removed:Ljava/lang/Object;

    :cond_9
    invoke-interface {v0, p1, p2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_c
    .catchall {:try_start_3 .. :try_end_c} :catchall_e

    .line 811
    monitor-exit p0

    return-object p0

    :catchall_e
    move-exception p1

    goto :goto_18

    .line 809
    :cond_10
    :try_start_10
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "Null preference key"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    :goto_18
    monitor-exit p0
    :try_end_19
    .catchall {:try_start_10 .. :try_end_19} :catchall_e

    throw p1
.end method

.method private submit()Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;
    .registers 9

    .line 841
    monitor-enter p0

    .line 842
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->changes:Ljava/util/Map;

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->cloneValues(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    .line 843
    iget-boolean v1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->clear:Z

    .line 844
    iget-object v2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->changes:Ljava/util/Map;

    invoke-interface {v2}, Ljava/util/Map;->clear()V

    const/4 v2, 0x0

    .line 845
    iput-boolean v2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->clear:Z

    .line 846
    monitor-exit p0
    :try_end_12
    .catchall {:try_start_1 .. :try_end_12} :catchall_e7

    .line 848
    new-instance v3, Ljava/util/HashSet;

    invoke-direct {v3}, Ljava/util/HashSet;-><init>()V

    if-eqz v1, :cond_28

    .line 850
    sget v4, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v5, 0x1e

    if-lt v4, v5, :cond_28

    .line 851
    # invokes: Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->access$400()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object v4

    iget v4, v4, Lcom/stoicstudio/port/PortStorage$State;->targetSdk:I

    if-lt v4, v5, :cond_28

    const/4 v2, 0x1

    .line 852
    :cond_28
    iget-object v4, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    monitor-enter v4

    if-eqz v1, :cond_33

    .line 853
    :try_start_2d
    new-instance v1, Ljava/util/LinkedHashMap;

    invoke-direct {v1}, Ljava/util/LinkedHashMap;-><init>()V

    goto :goto_3d

    :cond_33
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;
    invoke-static {v1}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$700(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/util/Map;

    move-result-object v1

    invoke-static {v1}, Lcom/stoicstudio/port/PortStorage;->cloneValues(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v1

    .line 854
    :goto_3d
    invoke-interface {v0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :cond_45
    :goto_45
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_a7

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/Map$Entry;

    .line 855
    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v6

    iget-object v7, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->removed:Ljava/lang/Object;

    if-ne v6, v7, :cond_74

    .line 856
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    invoke-interface {v1, v6}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_6c

    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    invoke-interface {v3, v6}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    .line 857
    :cond_6c
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v5

    invoke-interface {v1, v5}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_45

    .line 858
    :cond_74
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    invoke-interface {v1, v6}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_90

    .line 859
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    invoke-interface {v1, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6

    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v7

    invoke-static {v6, v7}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v6

    if-nez v6, :cond_45

    .line 860
    :cond_90
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    invoke-interface {v3, v6}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    .line 861
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v5

    invoke-interface {v1, v6, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_45

    .line 864
    :cond_a7
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # setter for: Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;
    invoke-static {v0, v1}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$702(Lcom/stoicstudio/port/PortStorage$Prefs;Ljava/util/Map;)Ljava/util/Map;

    .line 865
    invoke-static {v1}, Lcom/stoicstudio/port/PortStorage;->cloneValues(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    .line 866
    new-instance v1, Ljava/util/ArrayList;

    iget-object v5, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->listeners:Ljava/util/WeakHashMap;
    invoke-static {v5}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$800(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/util/WeakHashMap;

    move-result-object v5

    invoke-virtual {v5}, Ljava/util/WeakHashMap;->keySet()Ljava/util/Set;

    move-result-object v5

    invoke-direct {v1, v5}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 867
    # getter for: Lcom/stoicstudio/port/PortStorage;->WRITER:Ljava/util/concurrent/ExecutorService;
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->access$1000()Ljava/util/concurrent/ExecutorService;

    move-result-object v5

    new-instance v6, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;

    invoke-direct {v6, p0, v0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;-><init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/Map;)V

    invoke-interface {v5, v6}, Ljava/util/concurrent/ExecutorService;->submit(Ljava/util/concurrent/Callable;)Ljava/util/concurrent/Future;

    move-result-object v0

    .line 879
    monitor-exit v4
    :try_end_cd
    .catchall {:try_start_2d .. :try_end_cd} :catchall_e4

    .line 881
    invoke-interface {v3}, Ljava/util/Set;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_d8

    if-eqz v2, :cond_d6

    goto :goto_d8

    :cond_d6
    const/4 v1, 0x0

    goto :goto_de

    .line 882
    :cond_d8
    :goto_d8
    new-instance v4, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;

    invoke-direct {v4, p0, v1, v2, v3}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;-><init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/List;ZLjava/util/Set;)V

    move-object v1, v4

    .line 893
    :goto_de
    new-instance v2, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;

    invoke-direct {v2, p0, v0, v1}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;-><init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/concurrent/Future;Ljava/lang/Runnable;)V

    return-object v2

    :catchall_e4
    move-exception p0

    .line 879
    :try_start_e5
    monitor-exit v4
    :try_end_e6
    .catchall {:try_start_e5 .. :try_end_e6} :catchall_e4

    throw p0

    :catchall_e7
    move-exception v0

    .line 846
    :try_start_e8
    monitor-exit p0
    :try_end_e9
    .catchall {:try_start_e8 .. :try_end_e9} :catchall_e7

    throw v0
.end method


# virtual methods
.method public apply()V
    .registers 1

    .line 902
    invoke-direct {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->submit()Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;

    move-result-object p0

    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->notifyListeners()V

    return-void
.end method

.method public declared-synchronized clear()Landroid/content/SharedPreferences$Editor;
    .registers 2

    monitor-enter p0

    const/4 v0, 0x1

    .line 822
    :try_start_2
    iput-boolean v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->clear:Z
    :try_end_4
    .catchall {:try_start_2 .. :try_end_4} :catchall_6

    monitor-exit p0

    return-object p0

    :catchall_6
    move-exception v0

    :try_start_7
    monitor-exit p0
    :try_end_8
    .catchall {:try_start_7 .. :try_end_8} :catchall_6

    throw v0
.end method

.method public commit()Z
    .registers 5

    .line 896
    invoke-direct {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->submit()Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;

    move-result-object p0

    const/4 v0, 0x0

    .line 897
    :try_start_5
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->writing:Ljava/util/concurrent/Future;

    invoke-interface {v1}, Ljava/util/concurrent/Future;->get()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0
    :try_end_11
    .catch Ljava/lang/InterruptedException; {:try_start_5 .. :try_end_11} :catch_23
    .catch Ljava/util/concurrent/ExecutionException; {:try_start_5 .. :try_end_11} :catch_17
    .catchall {:try_start_5 .. :try_end_11} :catchall_15

    .line 900
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->notifyListeners()V

    return v0

    :catchall_15
    move-exception v0

    goto :goto_2e

    :catch_17
    move-exception v1

    .line 899
    :try_start_18
    const-string v2, "PortStorage"

    const-string v3, "Preference commit failed"

    invoke-static {v2, v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_1f
    .catchall {:try_start_18 .. :try_end_1f} :catchall_15

    .line 900
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->notifyListeners()V

    return v0

    .line 898
    :catch_23
    :try_start_23
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Thread;->interrupt()V
    :try_end_2a
    .catchall {:try_start_23 .. :try_end_2a} :catchall_15

    .line 900
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->notifyListeners()V

    return v0

    :goto_2e
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->notifyListeners()V

    throw v0
.end method

.method synthetic lambda$submit$0$com-stoicstudio-port-PortStorage$Prefs$Edit(Ljava/util/Map;)Ljava/lang/Boolean;
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 869
    :try_start_0
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->file:Ljava/io/File;
    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$900(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/File;

    move-result-object v0

    invoke-static {v0, p1}, Lcom/stoicstudio/port/PortStorage;->writeXml(Ljava/io/File;Ljava/util/Map;)V

    .line 870
    iget-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    const/4 v0, 0x0

    # setter for: Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;
    invoke-static {p1, v0}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$002(Lcom/stoicstudio/port/PortStorage$Prefs;Ljava/io/IOException;)Ljava/io/IOException;

    const/4 p1, 0x1

    .line 871
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p0
    :try_end_14
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_14} :catch_17
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_14} :catch_15

    return-object p0

    :catch_15
    move-exception p1

    goto :goto_18

    :catch_17
    move-exception p1

    .line 874
    :goto_18
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    new-instance v1, Ljava/io/IOException;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "Preference persistence failed: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v3, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->file:Ljava/io/File;
    invoke-static {v3}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$900(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/File;

    move-result-object v3

    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    # setter for: Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;
    invoke-static {v0, v1}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$002(Lcom/stoicstudio/port/PortStorage$Prefs;Ljava/io/IOException;)Ljava/io/IOException;

    .line 875
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Preference write failed: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    # getter for: Lcom/stoicstudio/port/PortStorage$Prefs;->file:Ljava/io/File;
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage$Prefs;->access$900(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/File;

    move-result-object p0

    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "PortStorage"

    invoke-static {v0, p0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    const/4 p0, 0x0

    .line 876
    invoke-static {p0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p0

    return-object p0
.end method

.method synthetic lambda$submit$1$com-stoicstudio-port-PortStorage$Prefs$Edit(Ljava/util/List;ZLjava/util/Set;)V
    .registers 8

    .line 883
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :cond_4
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_30

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;

    if-eqz v0, :cond_4

    if-eqz p2, :cond_1a

    .line 885
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    const/4 v2, 0x0

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;->onSharedPreferenceChanged(Landroid/content/SharedPreferences;Ljava/lang/String;)V

    .line 886
    :cond_1a
    invoke-interface {p3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_1e
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_4

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 887
    iget-object v3, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->this$0:Lcom/stoicstudio/port/PortStorage$Prefs;

    invoke-interface {v0, v3, v2}, Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;->onSharedPreferenceChanged(Landroid/content/SharedPreferences;Ljava/lang/String;)V

    goto :goto_1e

    :cond_30
    return-void
.end method

.method public putBoolean(Ljava/lang/String;Z)Landroid/content/SharedPreferences$Editor;
    .registers 3

    .line 820
    invoke-static {p2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p2

    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public putFloat(Ljava/lang/String;F)Landroid/content/SharedPreferences$Editor;
    .registers 3

    .line 819
    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p2

    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;
    .registers 3

    .line 817
    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public putLong(Ljava/lang/String;J)Landroid/content/SharedPreferences$Editor;
    .registers 4

    .line 818
    invoke-static {p2, p3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p2

    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    .registers 3

    .line 813
    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public putStringSet(Ljava/lang/String;Ljava/util/Set;)Landroid/content/SharedPreferences$Editor;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;)",
            "Landroid/content/SharedPreferences$Editor;"
        }
    .end annotation

    if-nez p2, :cond_4

    const/4 p2, 0x0

    goto :goto_a

    .line 815
    :cond_4
    new-instance v0, Ljava/util/HashSet;

    invoke-direct {v0, p2}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    move-object p2, v0

    :goto_a
    invoke-direct {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method

.method public remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    .registers 3

    const/4 v0, 0x0

    .line 821
    invoke-direct {p0, p1, v0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->put(Ljava/lang/String;Ljava/lang/Object;)Landroid/content/SharedPreferences$Editor;

    move-result-object p0

    return-object p0
.end method
