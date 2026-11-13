.class final Lcom/stoicstudio/port/PortStorage$PortContext;
.super Landroid/content/ContextWrapper;
.source "PortStorage.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "PortContext"
.end annotation


# direct methods
.method constructor <init>(Landroid/content/Context;)V
    .registers 2

    .line 616
    invoke-direct {p0, p1}, Landroid/content/ContextWrapper;-><init>(Landroid/content/Context;)V

    return-void
.end method


# virtual methods
.method public createPackageContext(Ljava/lang/String;I)Landroid/content/Context;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/content/pm/PackageManager$NameNotFoundException;
        }
    .end annotation

    .line 627
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getBaseContext()Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    move-result-object p0

    .line 628
    # invokes: Lcom/stoicstudio/port/PortStorage;->requireInitialized()Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->access$400()Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p1

    iget-object p1, p1, Lcom/stoicstudio/port/PortStorage$State;->owner:Ljava/lang/String;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_1c

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->wrap(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    :cond_1c
    return-object p0
.end method

.method public deleteFile(Ljava/lang/String;)Z
    .registers 2

    .line 651
    invoke-virtual {p0, p1}, Lcom/stoicstudio/port/PortStorage$PortContext;->getFileStreamPath(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    invoke-virtual {p0}, Ljava/io/File;->delete()Z

    move-result p0

    return p0
.end method

.method public deleteSharedPreferences(Ljava/lang/String;)Z
    .registers 2

    .line 660
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "No audited runtime deleteSharedPreferences consumer"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public fileList()[Ljava/lang/String;
    .registers 1

    .line 653
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getFilesDir()Ljava/io/File;

    move-result-object p0

    invoke-virtual {p0}, Ljava/io/File;->list()[Ljava/lang/String;

    move-result-object p0

    if-nez p0, :cond_d

    const/4 p0, 0x0

    .line 654
    new-array p0, p0, [Ljava/lang/String;

    :cond_d
    return-object p0
.end method

.method public getApplicationContext()Landroid/content/Context;
    .registers 2

    .line 622
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    if-nez v0, :cond_e

    .line 623
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    :cond_e
    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->wrap(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    return-object p0
.end method

.method public getCacheDir()Ljava/io/File;
    .registers 2

    .line 635
    new-instance v0, Ljava/io/File;

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->cachePath(Landroid/content/Context;)Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    return-object v0
.end method

.method public getDataDir()Ljava/io/File;
    .registers 1

    .line 630
    # invokes: Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->access$500(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    return-object p0
.end method

.method public getDatabasePath(Ljava/lang/String;)Ljava/io/File;
    .registers 2

    .line 663
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "No audited persistent database owner"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public getDir(Ljava/lang/String;I)Ljava/io/File;
    .registers 5

    const-string p2, "app_"

    .line 641
    :try_start_2
    new-instance v0, Ljava/io/File;

    # invokes: Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->access$500(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->fileName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p0
    :try_end_21
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_21} :catch_22

    return-object p0

    :catch_22
    move-exception p0

    .line 642
    new-instance p1, Ljava/lang/IllegalStateException;

    invoke-direct {p1, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/Throwable;)V

    throw p1
.end method

.method public getFileStreamPath(Ljava/lang/String;)Ljava/io/File;
    .registers 3

    .line 644
    new-instance v0, Ljava/io/File;

    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getFilesDir()Ljava/io/File;

    move-result-object p0

    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->fileName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    return-object v0
.end method

.method public getFilesDir()Ljava/io/File;
    .registers 3

    .line 632
    :try_start_0
    new-instance v0, Ljava/io/File;

    # invokes: Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->access$500(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    const-string v1, "files"

    invoke-direct {v0, p0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p0
    :try_end_11
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_11} :catch_12

    return-object p0

    :catch_12
    move-exception p0

    .line 633
    new-instance v0, Ljava/lang/IllegalStateException;

    invoke-direct {v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/Throwable;)V

    throw v0
.end method

.method public getNoBackupFilesDir()Ljava/io/File;
    .registers 3

    .line 637
    :try_start_0
    new-instance v0, Ljava/io/File;

    # invokes: Lcom/stoicstudio/port/PortStorage;->requireOwner(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->access$500(Landroid/content/Context;)Lcom/stoicstudio/port/PortStorage$State;

    move-result-object p0

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$State;->root:Ljava/io/File;

    const-string v1, "no_backup"

    invoke-direct {v0, p0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-static {v0}, Lcom/stoicstudio/port/PortStorage;->directory(Ljava/io/File;)Ljava/io/File;

    move-result-object p0
    :try_end_11
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_11} :catch_12

    return-object p0

    :catch_12
    move-exception p0

    .line 638
    new-instance v0, Ljava/lang/IllegalStateException;

    invoke-direct {v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/Throwable;)V

    throw v0
.end method

.method public getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    .registers 3

    .line 619
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortStorage$PortContext;->getBaseContext()Landroid/content/Context;

    move-result-object p0

    invoke-static {p0, p1, p2}, Lcom/stoicstudio/port/PortStorage;->preferences(Landroid/content/Context;Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object p0

    return-object p0
.end method

.method public moveSharedPreferencesFrom(Landroid/content/Context;Ljava/lang/String;)Z
    .registers 3

    .line 657
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "Use reviewed pre-start migration"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public openFileInput(Ljava/lang/String;)Ljava/io/FileInputStream;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 646
    new-instance v0, Ljava/io/FileInputStream;

    invoke-virtual {p0, p1}, Lcom/stoicstudio/port/PortStorage$PortContext;->getFileStreamPath(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    return-object v0
.end method

.method public openFileOutput(Ljava/lang/String;I)Ljava/io/FileOutputStream;
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 649
    new-instance v0, Ljava/io/FileOutputStream;

    invoke-virtual {p0, p1}, Lcom/stoicstudio/port/PortStorage$PortContext;->getFileStreamPath(Ljava/lang/String;)Ljava/io/File;

    move-result-object p0

    const p1, 0x8000

    and-int/2addr p1, p2

    if-eqz p1, :cond_e

    const/4 p1, 0x1

    goto :goto_f

    :cond_e
    const/4 p1, 0x0

    :goto_f
    invoke-direct {v0, p0, p1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    return-object v0
.end method

.method public openOrCreateDatabase(Ljava/lang/String;ILandroid/database/sqlite/SQLiteDatabase$CursorFactory;)Landroid/database/sqlite/SQLiteDatabase;
    .registers 4

    .line 667
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "No audited persistent database owner"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public openOrCreateDatabase(Ljava/lang/String;ILandroid/database/sqlite/SQLiteDatabase$CursorFactory;Landroid/database/DatabaseErrorHandler;)Landroid/database/sqlite/SQLiteDatabase;
    .registers 5

    .line 671
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "No audited persistent database owner"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
