.class final Lcom/stoicstudio/port/PortStorage$State;
.super Ljava/lang/Object;
.source "PortStorage.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "State"
.end annotation


# instance fields
.field final checkpoint:Ljava/io/File;

.field final control:Ljava/io/File;

.field final internal:Ljava/io/File;

.field final legacyExternal:Ljava/io/File;

.field final legacyRoots:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field final migration:Ljava/io/File;

.field final owner:Ljava/lang/String;

.field final prefs:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/stoicstudio/port/PortStorage$Prefs;",
            ">;"
        }
    .end annotation
.end field

.field final root:Ljava/io/File;

.field final roots:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field final targetSdk:I


# direct methods
.method constructor <init>(Landroid/content/Context;[Ljava/lang/String;)V
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 501
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 498
    const-string v0, "save"

    const-string v1, "log"

    filled-new-array {v0, v1}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    iput-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    .line 499
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->prefs:Ljava/util/Map;

    .line 502
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    .line 503
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v1

    iget v1, v1, Landroid/content/pm/ApplicationInfo;->uid:I

    invoke-static {}, Landroid/os/Process;->myUid()I

    move-result v2

    if-ne v1, v2, :cond_125

    .line 506
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v1

    iget v1, v1, Landroid/content/pm/ApplicationInfo;->targetSdkVersion:I

    iput v1, p0, Lcom/stoicstudio/port/PortStorage$State;->targetSdk:I

    .line 507
    new-instance v1, Ljava/io/File;

    invoke-virtual {p1}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v2

    iget-object v2, v2, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->getCanonicalFile()Ljava/io/File;

    move-result-object v1

    iput-object v1, p0, Lcom/stoicstudio/port/PortStorage$State;->internal:Ljava/io/File;

    const/4 v2, 0x0

    .line 508
    invoke-virtual {p1, v2}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object p1

    if-eqz p1, :cond_11d

    .line 510
    invoke-virtual {p1}, Ljava/io/File;->getCanonicalFile()Ljava/io/File;

    move-result-object p1

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p1

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    .line 511
    invoke-virtual {p1}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v2

    if-eqz v2, :cond_115

    .line 512
    invoke-virtual {v2}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_115

    .line 513
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v0

    const-string v3, "files"

    invoke-virtual {v3, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_115

    .line 516
    invoke-virtual {v2}, Ljava/io/File;->getCanonicalFile()Ljava/io/File;

    move-result-object v0

    iput-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    .line 517
    invoke-virtual {v2}, Ljava/io/File;->getAbsoluteFile()Ljava/io/File;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/io/File;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_10d

    .line 520
    invoke-virtual {v0}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-eqz v2, :cond_105

    invoke-virtual {v0}, Ljava/io/File;->canRead()Z

    move-result v0

    if-eqz v0, :cond_105

    .line 523
    invoke-virtual {p1, v1}, Ljava/io/File;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_fd

    invoke-virtual {p1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    sget-object v1, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_fd

    .line 526
    # invokes: Lcom/stoicstudio/port/PortStorage;->validateRoots([Ljava/lang/String;)Ljava/util/List;
    invoke-static {p2}, Lcom/stoicstudio/port/PortStorage;->access$100([Ljava/lang/String;)Ljava/util/List;

    move-result-object p2

    iput-object p2, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    .line 527
    new-instance p2, Ljava/io/File;

    const-string v0, ".port-storage"

    invoke-direct {p2, p1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {p2}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p2

    iput-object p2, p0, Lcom/stoicstudio/port/PortStorage$State;->control:Ljava/io/File;

    .line 529
    new-instance v0, Ljava/io/File;

    const-string v1, "cache"

    invoke-direct {v0, p1, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    .line 530
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    .line 531
    new-instance v0, Ljava/io/File;

    const-string v1, "shared_prefs"

    invoke-direct {v0, p1, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    .line 532
    new-instance v0, Ljava/io/File;

    const-string v1, "Documents"

    invoke-direct {v0, p1, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    .line 533
    new-instance p1, Ljava/io/File;

    const-string v0, "migration.json"

    invoke-direct {p1, p2, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$State;->migration:Ljava/io/File;

    .line 534
    new-instance p1, Ljava/io/File;

    const-string v0, "checkpoint.json"

    invoke-direct {p1, p2, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$State;->checkpoint:Ljava/io/File;

    return-void

    .line 524
    :cond_fd
    new-instance p0, Ljava/io/IOException;

    const-string p1, "External root unexpectedly resolves into private data"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 521
    :cond_105
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Cannot inspect reviewed legacy save/log sources"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 518
    :cond_10d
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Legacy external owner folder alias/symlink"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 514
    :cond_115
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Unexpected API external files layout; legacy sources not inferred"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 509
    :cond_11d
    new-instance p0, Ljava/io/IOException;

    const-string p1, "External files root is null"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 504
    :cond_125
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Migration Context is not owned by this process UID"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method


# virtual methods
.method checkIdentity(Lorg/json/JSONObject;)V
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;,
            Lorg/json/JSONException;
        }
    .end annotation

    .line 549
    const-string v0, "version"

    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v0

    const/4 v1, 0x2

    if-ne v0, v1, :cond_72

    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    const-string v1, "owner"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_72

    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    .line 550
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    const-string v1, "root"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_72

    new-instance v0, Lorg/json/JSONArray;

    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    invoke-direct {v0, v1}, Lorg/json/JSONArray;-><init>(Ljava/util/Collection;)V

    .line 551
    invoke-virtual {v0}, Lorg/json/JSONArray;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "roots"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v1

    invoke-virtual {v1}, Lorg/json/JSONArray;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_72

    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    .line 552
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    const-string v1, "legacyExternal"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_72

    new-instance v0, Lorg/json/JSONArray;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    invoke-direct {v0, p0}, Lorg/json/JSONArray;-><init>(Ljava/util/Collection;)V

    .line 553
    invoke-virtual {v0}, Lorg/json/JSONArray;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "legacyRoots"

    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p1

    invoke-virtual {p1}, Lorg/json/JSONArray;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_72

    return-void

    .line 554
    :cond_72
    new-instance p0, Ljava/io/IOException;

    const-string p1, "Storage marker identity/root mismatch"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method identity()Lorg/json/JSONObject;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lorg/json/JSONException;
        }
    .end annotation

    .line 538
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V

    .line 539
    const-string v1, "version"

    const/4 v2, 0x2

    invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 540
    const-string v1, "owner"

    iget-object v2, p0, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 541
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-virtual {v1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    const-string v2, "root"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 542
    new-instance v1, Lorg/json/JSONArray;

    iget-object v2, p0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    invoke-direct {v1, v2}, Lorg/json/JSONArray;-><init>(Ljava/util/Collection;)V

    const-string v2, "roots"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 543
    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    invoke-virtual {v1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    const-string v2, "legacyExternal"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 544
    new-instance v1, Lorg/json/JSONArray;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    invoke-direct {v1, p0}, Lorg/json/JSONArray;-><init>(Ljava/util/Collection;)V

    const-string p0, "legacyRoots"

    invoke-virtual {v0, p0, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    return-object v0
.end method

.method migrate()V
    .registers 21
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;,
            Lorg/json/JSONException;
        }
    .end annotation

    move-object/from16 v0, p0

    .line 559
    iget-object v1, v0, Lcom/stoicstudio/port/PortStorage$State;->internal:Ljava/io/File;

    iget-object v2, v0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    const/4 v3, 0x1

    invoke-static {v1, v2, v3}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v1

    .line 560
    iget-object v2, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    invoke-static {v2, v4, v3}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v2

    .line 561
    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->migration:Ljava/io/File;

    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v4

    const-string v5, "legacySources"

    const-string v6, "sources"

    if-nez v4, :cond_1b7

    new-instance v4, Ljava/io/File;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v8, v0, Lcom/stoicstudio/port/PortStorage$State;->migration:Ljava/io/File;

    invoke-virtual {v8}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v8, ".bak"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v4, v7}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v4

    if-eqz v4, :cond_43

    goto/16 :goto_1b7

    .line 570
    :cond_43
    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->internal:Ljava/io/File;

    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    # invokes: Lcom/stoicstudio/port/PortStorage;->collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;
    invoke-static {v4, v7}, Lcom/stoicstudio/port/PortStorage;->access$200(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;

    move-result-object v4

    .line 571
    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    iget-object v9, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    # invokes: Lcom/stoicstudio/port/PortStorage;->collect(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;
    invoke-static {v7, v9}, Lcom/stoicstudio/port/PortStorage;->access$200(Ljava/io/File;Ljava/util/List;)Ljava/util/Map;

    move-result-object v7

    .line 573
    invoke-interface {v4}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v9

    invoke-interface {v9}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v9

    const-wide/32 v10, 0x10000

    :goto_5e
    invoke-interface {v9}, Ljava/util/Iterator;->hasNext()Z

    move-result v12

    const-string v13, "Data size overflow"

    const-wide v14, 0x7fffffffffffffffL

    if-eqz v12, :cond_86

    invoke-interface {v9}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/io/File;

    sub-long/2addr v14, v10

    .line 574
    invoke-virtual {v12}, Ljava/io/File;->length()J

    move-result-wide v16

    cmp-long v14, v14, v16

    if-ltz v14, :cond_80

    .line 575
    invoke-virtual {v12}, Ljava/io/File;->length()J

    move-result-wide v12

    add-long/2addr v10, v12

    goto :goto_5e

    .line 574
    :cond_80
    new-instance v0, Ljava/io/IOException;

    invoke-direct {v0, v13}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 577
    :cond_86
    invoke-interface {v7}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v7

    invoke-interface {v7}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v7

    :goto_8e
    invoke-interface {v7}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_b1

    invoke-interface {v7}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Ljava/io/File;

    sub-long v16, v14, v10

    .line 578
    invoke-virtual {v9}, Ljava/io/File;->length()J

    move-result-wide v18

    cmp-long v12, v16, v18

    if-ltz v12, :cond_ab

    .line 579
    invoke-virtual {v9}, Ljava/io/File;->length()J

    move-result-wide v16

    add-long v10, v10, v16

    goto :goto_8e

    .line 578
    :cond_ab
    new-instance v0, Ljava/io/IOException;

    invoke-direct {v0, v13}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 581
    :cond_b1
    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-virtual {v7}, Ljava/io/File;->getUsableSpace()J

    move-result-wide v12

    cmp-long v7, v12, v10

    if-ltz v7, :cond_1af

    .line 582
    new-instance v7, Ljava/util/HashSet;

    invoke-direct {v7}, Ljava/util/HashSet;-><init>()V

    .line 583
    invoke-interface {v4}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v9

    invoke-interface {v9}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v9

    :goto_c8
    invoke-interface {v9}, Ljava/util/Iterator;->hasNext()Z

    move-result v10

    const/4 v11, 0x0

    if-eqz v10, :cond_168

    invoke-interface {v9}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/util/Map$Entry;

    .line 584
    invoke-interface {v10}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/lang/String;

    .line 585
    const-string v13, "shared_prefs/"

    invoke-virtual {v12, v13}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v13

    if-eqz v13, :cond_157

    .line 586
    const-string v10, ".xml"

    invoke-virtual {v12, v10}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v10

    if-nez v10, :cond_f3

    const-string v10, ".xml.bak"

    invoke-virtual {v12, v10}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v10

    if-eqz v10, :cond_143

    :cond_f3
    const/16 v10, 0xd

    .line 587
    invoke-virtual {v12, v10}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v10

    const-string v13, "/"

    invoke-virtual {v10, v13}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v10

    if-nez v10, :cond_143

    .line 590
    invoke-virtual {v12, v8}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v10

    if-eqz v10, :cond_111

    .line 591
    invoke-virtual {v12}, Ljava/lang/String;->length()I

    move-result v10

    add-int/lit8 v10, v10, -0x4

    invoke-virtual {v12, v11, v10}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v12

    .line 592
    :cond_111
    invoke-interface {v7, v12}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_118

    goto :goto_c8

    .line 593
    :cond_118
    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-interface {v4, v10}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/io/File;

    if-eqz v10, :cond_130

    goto :goto_136

    .line 594
    :cond_130
    invoke-interface {v4, v12}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/io/File;

    .line 596
    :goto_136
    invoke-static {v10, v11}, Lcom/stoicstudio/port/PortStorage;->readXml(Ljava/io/File;Z)Ljava/util/Map;

    .line 597
    iget-object v11, v0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-static {v11, v12}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object v11

    invoke-static {v10, v11}, Lcom/stoicstudio/port/PortStorage;->copyVerified(Ljava/io/File;Ljava/io/File;)V

    goto :goto_c8

    .line 588
    :cond_143
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Unexpected preference entry: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 599
    :cond_157
    invoke-interface {v10}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/io/File;

    iget-object v11, v0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-static {v11, v12}, Lcom/stoicstudio/port/PortStorage;->contained(Ljava/io/File;Ljava/lang/String;)Ljava/io/File;

    move-result-object v11

    invoke-static {v10, v11}, Lcom/stoicstudio/port/PortStorage;->copyVerified(Ljava/io/File;Ljava/io/File;)V

    goto/16 :goto_c8

    .line 602
    :cond_168
    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    invoke-static {v4, v7}, Lcom/stoicstudio/port/PortStorage;->copyLegacy(Ljava/io/File;Ljava/io/File;)V

    .line 603
    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->internal:Ljava/io/File;

    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    invoke-static {v4, v7, v3}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v4

    const-string v7, "Original changed during migration"

    invoke-static {v1, v4, v7}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    .line 604
    iget-object v4, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyExternal:Ljava/io/File;

    iget-object v7, v0, Lcom/stoicstudio/port/PortStorage$State;->legacyRoots:Ljava/util/List;

    invoke-static {v4, v7, v3}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v3

    const-string v4, "Legacy original changed during migration"

    invoke-static {v2, v3, v4}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    .line 605
    invoke-virtual {v0}, Lcom/stoicstudio/port/PortStorage$State;->identity()Lorg/json/JSONObject;

    move-result-object v3

    .line 606
    const-string v4, "run"

    # getter for: Lcom/stoicstudio/port/PortStorage;->RUN:Ljava/lang/String;
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->access$300()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v3, v4, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 607
    invoke-virtual {v3, v6, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 608
    invoke-virtual {v3, v5, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 609
    iget-object v1, v0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    iget-object v2, v0, Lcom/stoicstudio/port/PortStorage$State;->roots:Ljava/util/List;

    invoke-static {v1, v2, v11}, Lcom/stoicstudio/port/PortStorage;->snapshot(Ljava/io/File;Ljava/util/List;Z)Lorg/json/JSONObject;

    move-result-object v1

    const-string v2, "copied"

    invoke-virtual {v3, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 610
    iget-object v0, v0, Lcom/stoicstudio/port/PortStorage$State;->migration:Ljava/io/File;

    invoke-static {v0, v3}, Lcom/stoicstudio/port/PortStorage;->writeJson(Ljava/io/File;Lorg/json/JSONObject;)V

    return-void

    .line 581
    :cond_1af
    new-instance v0, Ljava/io/IOException;

    const-string v1, "Insufficient external free space"

    invoke-direct {v0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 562
    :cond_1b7
    :goto_1b7
    iget-object v3, v0, Lcom/stoicstudio/port/PortStorage$State;->migration:Ljava/io/File;

    invoke-static {v3}, Lcom/stoicstudio/port/PortStorage;->readJson(Ljava/io/File;)Lorg/json/JSONObject;

    move-result-object v3

    .line 563
    invoke-virtual {v0, v3}, Lcom/stoicstudio/port/PortStorage$State;->checkIdentity(Lorg/json/JSONObject;)V

    .line 564
    invoke-virtual {v3, v6}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v0

    const-string v4, "Original data changed after migration; stale internal writer"

    invoke-static {v0, v1, v4}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    .line 566
    invoke-virtual {v3, v5}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v0

    const-string v1, "Legacy external data changed after migration; stale external writer"

    invoke-static {v0, v2, v1}, Lcom/stoicstudio/port/PortStorage;->assertSnapshot(Lorg/json/JSONObject;Lorg/json/JSONObject;Ljava/lang/String;)V

    return-void
.end method
