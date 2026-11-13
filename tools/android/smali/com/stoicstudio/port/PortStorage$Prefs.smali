.class final Lcom/stoicstudio/port/PortStorage$Prefs;
.super Ljava/lang/Object;
.source "PortStorage.java"

# interfaces
.implements Landroid/content/SharedPreferences;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Prefs"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/stoicstudio/port/PortStorage$Prefs$Edit;
    }
.end annotation


# instance fields
.field private final file:Ljava/io/File;

.field private final listeners:Ljava/util/WeakHashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/WeakHashMap<",
            "Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field

.field private values:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field

.field private volatile writeFailure:Ljava/io/IOException;


# direct methods
.method constructor <init>(Ljava/io/File;)V
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 775
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 773
    new-instance v0, Ljava/util/WeakHashMap;

    invoke-direct {v0}, Ljava/util/WeakHashMap;-><init>()V

    iput-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->listeners:Ljava/util/WeakHashMap;

    .line 775
    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->file:Ljava/io/File;

    const/4 v0, 0x1

    invoke-static {p1, v0}, Lcom/stoicstudio/port/PortStorage;->readXml(Ljava/io/File;Z)Ljava/util/Map;

    move-result-object p1

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    return-void
.end method

.method static synthetic access$000(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/IOException;
    .registers 1

    .line 769
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;

    return-object p0
.end method

.method static synthetic access$002(Lcom/stoicstudio/port/PortStorage$Prefs;Ljava/io/IOException;)Ljava/io/IOException;
    .registers 2

    .line 769
    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->writeFailure:Ljava/io/IOException;

    return-object p1
.end method

.method static synthetic access$700(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/util/Map;
    .registers 1

    .line 769
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    return-object p0
.end method

.method static synthetic access$702(Lcom/stoicstudio/port/PortStorage$Prefs;Ljava/util/Map;)Ljava/util/Map;
    .registers 2

    .line 769
    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    return-object p1
.end method

.method static synthetic access$800(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/util/WeakHashMap;
    .registers 1

    .line 769
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->listeners:Ljava/util/WeakHashMap;

    return-object p0
.end method

.method static synthetic access$900(Lcom/stoicstudio/port/PortStorage$Prefs;)Ljava/io/File;
    .registers 1

    .line 769
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->file:Ljava/io/File;

    return-object p0
.end method


# virtual methods
.method public declared-synchronized contains(Ljava/lang/String;)Z
    .registers 3

    monitor-enter p0

    .line 777
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p1
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_9

    monitor-exit p0

    return p1

    :catchall_9
    move-exception p1

    :try_start_a
    monitor-exit p0
    :try_end_b
    .catchall {:try_start_a .. :try_end_b} :catchall_9

    throw p1
.end method

.method public edit()Landroid/content/SharedPreferences$Editor;
    .registers 3

    .line 798
    new-instance v0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    const/4 v1, 0x0

    invoke-direct {v0, p0, v1}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;-><init>(Lcom/stoicstudio/port/PortStorage$Prefs;Lcom/stoicstudio/port/PortStorage$1;)V

    return-object v0
.end method

.method public declared-synchronized getAll()Ljava/util/Map;
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "*>;"
        }
    .end annotation

    monitor-enter p0

    .line 776
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->cloneValues(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_9

    monitor-exit p0

    return-object v0

    :catchall_9
    move-exception v0

    :try_start_a
    monitor-exit p0
    :try_end_b
    .catchall {:try_start_a .. :try_end_b} :catchall_9

    throw v0
.end method

.method public declared-synchronized getBoolean(Ljava/lang/String;Z)Z
    .registers 4

    monitor-enter p0

    .line 796
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-static {p2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p2

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Boolean;

    invoke-virtual {p1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p1
    :try_end_11
    .catchall {:try_start_1 .. :try_end_11} :catchall_13

    monitor-exit p0

    return p1

    :catchall_13
    move-exception p1

    :try_start_14
    monitor-exit p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw p1
.end method

.method public declared-synchronized getFloat(Ljava/lang/String;F)F
    .registers 4

    monitor-enter p0

    .line 793
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-static {p2}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p2

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Float;

    invoke-virtual {p1}, Ljava/lang/Float;->floatValue()F

    move-result p1
    :try_end_11
    .catchall {:try_start_1 .. :try_end_11} :catchall_13

    monitor-exit p0

    return p1

    :catchall_13
    move-exception p1

    :try_start_14
    monitor-exit p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw p1
.end method

.method public declared-synchronized getInt(Ljava/lang/String;I)I
    .registers 4

    monitor-enter p0

    .line 787
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1
    :try_end_11
    .catchall {:try_start_1 .. :try_end_11} :catchall_13

    monitor-exit p0

    return p1

    :catchall_13
    move-exception p1

    :try_start_14
    monitor-exit p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw p1
.end method

.method public declared-synchronized getLong(Ljava/lang/String;J)J
    .registers 5

    monitor-enter p0

    .line 790
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-static {p2, p3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p2

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->longValue()J

    move-result-wide p1
    :try_end_11
    .catchall {:try_start_1 .. :try_end_11} :catchall_13

    monitor-exit p0

    return-wide p1

    :catchall_13
    move-exception p1

    :try_start_14
    monitor-exit p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw p1
.end method

.method public declared-synchronized getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 4

    monitor-enter p0

    .line 779
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->getOrDefault(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;
    :try_end_9
    .catchall {:try_start_1 .. :try_end_9} :catchall_b

    monitor-exit p0

    return-object p1

    :catchall_b
    move-exception p1

    :try_start_c
    monitor-exit p0
    :try_end_d
    .catchall {:try_start_c .. :try_end_d} :catchall_b

    throw p1
.end method

.method public declared-synchronized getStringSet(Ljava/lang/String;Ljava/util/Set;)Ljava/util/Set;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    monitor-enter p0

    .line 783
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->values:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_a

    goto :goto_11

    .line 784
    :cond_a
    new-instance p2, Ljava/util/HashSet;

    check-cast p1, Ljava/util/Set;

    invoke-direct {p2, p1}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V
    :try_end_11
    .catchall {:try_start_1 .. :try_end_11} :catchall_13

    :goto_11
    monitor-exit p0

    return-object p2

    :catchall_13
    move-exception p1

    :try_start_14
    monitor-exit p0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw p1
.end method

.method public declared-synchronized registerOnSharedPreferenceChangeListener(Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;)V
    .registers 4

    monitor-enter p0

    .line 800
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->listeners:Ljava/util/WeakHashMap;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v0, p1, v1}, Ljava/util/WeakHashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_b
    .catchall {:try_start_1 .. :try_end_b} :catchall_d

    monitor-exit p0

    return-void

    :catchall_d
    move-exception p1

    :try_start_e
    monitor-exit p0
    :try_end_f
    .catchall {:try_start_e .. :try_end_f} :catchall_d

    throw p1
.end method

.method public declared-synchronized unregisterOnSharedPreferenceChangeListener(Landroid/content/SharedPreferences$OnSharedPreferenceChangeListener;)V
    .registers 3

    monitor-enter p0

    .line 802
    :try_start_1
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs;->listeners:Ljava/util/WeakHashMap;

    invoke-virtual {v0, p1}, Ljava/util/WeakHashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_6
    .catchall {:try_start_1 .. :try_end_6} :catchall_8

    monitor-exit p0

    return-void

    :catchall_8
    move-exception p1

    :try_start_9
    monitor-exit p0
    :try_end_a
    .catchall {:try_start_9 .. :try_end_a} :catchall_8

    throw p1
.end method
