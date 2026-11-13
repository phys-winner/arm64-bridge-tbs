.class final Lcom/stoicstudio/port/PortApplication$FailedContext;
.super Landroid/content/ContextWrapper;
.source "PortApplication.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortApplication;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "FailedContext"
.end annotation


# direct methods
.method constructor <init>(Landroid/content/Context;)V
    .registers 2

    .line 121
    invoke-direct {p0, p1}, Landroid/content/ContextWrapper;-><init>(Landroid/content/Context;)V

    return-void
.end method

.method private unavailable()Ljava/lang/IllegalStateException;
    .registers 3

    .line 123
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string v0, "Game persistent storage is unavailable"

    # getter for: Lcom/stoicstudio/port/PortApplication;->startupFailure:Ljava/lang/RuntimeException;
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->access$000()Ljava/lang/RuntimeException;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    return-object p0
.end method


# virtual methods
.method public createPackageContext(Ljava/lang/String;I)Landroid/content/Context;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/content/pm/PackageManager$NameNotFoundException;
        }
    .end annotation

    .line 128
    invoke-super {p0, p1, p2}, Landroid/content/ContextWrapper;->createPackageContext(Ljava/lang/String;I)Landroid/content/Context;

    move-result-object p2

    .line 129
    invoke-virtual {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->getPackageName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_14

    new-instance p0, Lcom/stoicstudio/port/PortApplication$FailedContext;

    invoke-direct {p0, p2}, Lcom/stoicstudio/port/PortApplication$FailedContext;-><init>(Landroid/content/Context;)V

    return-object p0

    :cond_14
    return-object p2
.end method

.method public deleteFile(Ljava/lang/String;)Z
    .registers 2

    const/4 p0, 0x0

    return p0
.end method

.method public deleteSharedPreferences(Ljava/lang/String;)Z
    .registers 2

    const/4 p0, 0x0

    return p0
.end method

.method public fileList()[Ljava/lang/String;
    .registers 1

    const/4 p0, 0x0

    .line 142
    new-array p0, p0, [Ljava/lang/String;

    return-object p0
.end method

.method public getApplicationContext()Landroid/content/Context;
    .registers 1

    return-object p0
.end method

.method public getDatabasePath(Ljava/lang/String;)Ljava/io/File;
    .registers 2

    .line 146
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public getDir(Ljava/lang/String;I)Ljava/io/File;
    .registers 3

    .line 134
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public getFileStreamPath(Ljava/lang/String;)Ljava/io/File;
    .registers 2

    .line 135
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public getFilesDir()Ljava/io/File;
    .registers 1

    .line 132
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public getNoBackupFilesDir()Ljava/io/File;
    .registers 1

    .line 133
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    .registers 3

    .line 131
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public moveSharedPreferencesFrom(Landroid/content/Context;Ljava/lang/String;)Z
    .registers 3

    const/4 p0, 0x0

    return p0
.end method

.method public openFileInput(Ljava/lang/String;)Ljava/io/FileInputStream;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 137
    new-instance p0, Ljava/io/FileNotFoundException;

    const-string p1, "Game persistent storage is unavailable"

    invoke-direct {p0, p1}, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public openFileOutput(Ljava/lang/String;I)Ljava/io/FileOutputStream;
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 140
    new-instance p0, Ljava/io/FileNotFoundException;

    const-string p1, "Game persistent storage is unavailable"

    invoke-direct {p0, p1}, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public openOrCreateDatabase(Ljava/lang/String;ILandroid/database/sqlite/SQLiteDatabase$CursorFactory;)Landroid/database/sqlite/SQLiteDatabase;
    .registers 4

    .line 148
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method

.method public openOrCreateDatabase(Ljava/lang/String;ILandroid/database/sqlite/SQLiteDatabase$CursorFactory;Landroid/database/DatabaseErrorHandler;)Landroid/database/sqlite/SQLiteDatabase;
    .registers 5

    .line 150
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;->unavailable()Ljava/lang/IllegalStateException;

    move-result-object p0

    throw p0
.end method
