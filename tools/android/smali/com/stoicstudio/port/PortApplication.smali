.class public final Lcom/stoicstudio/port/PortApplication;
.super Landroid/app/Application;
.source "PortApplication.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/stoicstudio/port/PortApplication$FailedContext;
    }
.end annotation


# static fields
.field private static volatile startupFailure:Ljava/lang/RuntimeException;


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 23
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    return-void
.end method

.method static synthetic access$000()Ljava/lang/RuntimeException;
    .registers 1

    .line 23
    sget-object v0, Lcom/stoicstudio/port/PortApplication;->startupFailure:Ljava/lang/RuntimeException;

    return-object v0
.end method

.method public static flushIfReady(Landroid/content/Context;)V
    .registers 3

    .line 66
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 67
    :cond_7
    :try_start_7
    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->flush(Landroid/content/Context;)V
    :try_end_a
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_a} :catch_b
    .catch Ljava/lang/RuntimeException; {:try_start_7 .. :try_end_a} :catch_b

    return-void

    :catch_b
    move-exception p0

    .line 69
    const-string v0, "PortStorage"

    const-string v1, "Preference lifecycle flush failed"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    return-void
.end method

.method public static guardService(Landroid/app/Service;)Z
    .registers 2

    .line 59
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-eqz v0, :cond_8

    const/4 p0, 0x1

    return p0

    .line 60
    :cond_8
    invoke-virtual {p0}, Landroid/app/Service;->stopSelf()V

    const/4 p0, 0x0

    return p0
.end method

.method public static guardStartup(Landroid/app/Activity;)Z
    .registers 6

    .line 78
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-eqz v0, :cond_8

    const/4 p0, 0x1

    return p0

    .line 79
    :cond_8
    invoke-virtual {p0}, Landroid/app/Activity;->isFinishing()Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_67

    invoke-virtual {p0}, Landroid/app/Activity;->isDestroyed()Z

    move-result v0

    if-eqz v0, :cond_16

    goto :goto_67

    .line 80
    :cond_16
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    move-result-object v0

    const-string v2, "ru"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_29

    .line 81
    const-string v2, "\u0414\u0430\u043d\u043d\u044b\u0435 \u0438\u0433\u0440\u044b \u043d\u0435\u0434\u043e\u0441\u0442\u0443\u043f\u043d\u044b"

    goto :goto_2b

    :cond_29
    const-string v2, "Game data unavailable"

    :goto_2b
    if-eqz v0, :cond_30

    .line 83
    const-string v3, "\u041f\u0440\u043e\u0432\u0435\u0440\u044c\u0442\u0435 \u0445\u0440\u0430\u043d\u0438\u043b\u0438\u0449\u0435 \u0438 \u043f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u0435 \u0437\u0430\u043f\u0443\u0441\u043a \u0438\u0433\u0440\u044b."

    goto :goto_32

    .line 84
    :cond_30
    const-string v3, "Check available storage and start the game again."

    :goto_32
    if-eqz v0, :cond_37

    .line 85
    const-string v0, "\u0417\u0430\u043a\u0440\u044b\u0442\u044c"

    goto :goto_39

    :cond_37
    const-string v0, "Close"

    .line 87
    :goto_39
    :try_start_39
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v4, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    new-instance v3, Lcom/stoicstudio/port/PortApplication$0;

    invoke-direct {v3, p0}, Lcom/stoicstudio/port/PortApplication$0;-><init>(Landroid/app/Activity;)V

    .line 88
    invoke-virtual {v2, v0, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v2, Lcom/stoicstudio/port/PortApplication$2;

    invoke-direct {v2, p0}, Lcom/stoicstudio/port/PortApplication$2;-><init>(Landroid/app/Activity;)V

    .line 89
    invoke-virtual {v0, v2}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;
    :try_end_5b
    .catch Ljava/lang/RuntimeException; {:try_start_39 .. :try_end_5b} :catch_5c

    goto :goto_67

    :catch_5c
    move-exception v0

    .line 91
    const-string v2, "PortStorage"

    const-string v3, "Cannot show storage failure dialog"

    invoke-static {v2, v3, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 92
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V

    :cond_67
    :goto_67
    return v1
.end method

.method public static isStorageReady()Z
    .registers 1

    .line 41
    sget-object v0, Lcom/stoicstudio/port/PortApplication;->startupFailure:Ljava/lang/RuntimeException;

    if-nez v0, :cond_c

    invoke-static {}, Lcom/stoicstudio/port/PortStorage;->isReady()Z

    move-result v0

    if-eqz v0, :cond_c

    const/4 v0, 0x1

    return v0

    :cond_c
    const/4 v0, 0x0

    return v0
.end method

.method static synthetic lambda$guardStartup$0(Landroid/app/Activity;Landroid/content/DialogInterface;I)V
    .registers 3

    .line 88
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V

    return-void
.end method

.method static synthetic lambda$guardStartup$1(Landroid/app/Activity;Landroid/content/DialogInterface;)V
    .registers 2

    .line 89
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V

    return-void
.end method

.method public static requireProviderStorage()V
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 54
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-eqz v0, :cond_7

    return-void

    :cond_7
    new-instance v0, Ljava/io/FileNotFoundException;

    const-string v1, "Game persistent storage is unavailable"

    invoke-direct {v0, v1}, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public static requireStorage()V
    .registers 3

    .line 50
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-eqz v0, :cond_7

    return-void

    :cond_7
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "Game persistent storage is unavailable"

    sget-object v2, Lcom/stoicstudio/port/PortApplication;->startupFailure:Ljava/lang/RuntimeException;

    invoke-direct {v0, v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v0
.end method

.method public static wrapForStartup(Landroid/content/Context;)Landroid/content/Context;
    .registers 2

    .line 46
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-eqz v0, :cond_b

    invoke-static {p0}, Lcom/stoicstudio/port/PortStorage;->wrap(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p0

    return-object p0

    :cond_b
    new-instance v0, Lcom/stoicstudio/port/PortApplication$FailedContext;

    invoke-direct {v0, p0}, Lcom/stoicstudio/port/PortApplication$FailedContext;-><init>(Landroid/content/Context;)V

    return-object v0
.end method


# virtual methods
.method protected attachBaseContext(Landroid/content/Context;)V
    .registers 5

    .line 29
    :try_start_0
    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->initialize(Landroid/content/Context;)V

    .line 30
    invoke-static {p1}, Lcom/stoicstudio/port/PortStorage;->wrap(Landroid/content/Context;)Landroid/content/Context;

    move-result-object p1
    :try_end_7
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_7} :catch_8

    goto :goto_18

    :catch_8
    move-exception v0

    .line 32
    sput-object v0, Lcom/stoicstudio/port/PortApplication;->startupFailure:Ljava/lang/RuntimeException;

    .line 33
    const-string v1, "PortStorage"

    const-string v2, "Storage initialization refused; native launch is blocked"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 34
    new-instance v0, Lcom/stoicstudio/port/PortApplication$FailedContext;

    invoke-direct {v0, p1}, Lcom/stoicstudio/port/PortApplication$FailedContext;-><init>(Landroid/content/Context;)V

    move-object p1, v0

    .line 36
    :goto_18
    invoke-super {p0, p1}, Landroid/app/Application;->attachBaseContext(Landroid/content/Context;)V

    return-void
.end method

.method public onCreate()V
    .registers 2

    .line 98
    invoke-super {p0}, Landroid/app/Application;->onCreate()V

    .line 99
    invoke-static {}, Lcom/stoicstudio/port/PortApplication;->isStorageReady()Z

    move-result v0

    if-nez v0, :cond_a

    return-void

    .line 101
    :cond_a
    new-instance v0, Lcom/stoicstudio/port/PortApplication$1;

    invoke-direct {v0, p0}, Lcom/stoicstudio/port/PortApplication$1;-><init>(Lcom/stoicstudio/port/PortApplication;)V

    invoke-virtual {p0, v0}, Lcom/stoicstudio/port/PortApplication;->registerActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    return-void
.end method
