.class Lcom/stoicstudio/port/PortApplication$1;
.super Ljava/lang/Object;
.source "PortApplication.java"

# interfaces
.implements Landroid/app/Application$ActivityLifecycleCallbacks;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/stoicstudio/port/PortApplication;->onCreate()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/stoicstudio/port/PortApplication;


# direct methods
.method constructor <init>(Lcom/stoicstudio/port/PortApplication;)V
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010
        }
        names = {
            null
        }
    .end annotation

    .line 101
    iput-object p1, p0, Lcom/stoicstudio/port/PortApplication$1;->this$0:Lcom/stoicstudio/port/PortApplication;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private drain()V
    .registers 1

    .line 107
    iget-object p0, p0, Lcom/stoicstudio/port/PortApplication$1;->this$0:Lcom/stoicstudio/port/PortApplication;

    invoke-static {p0}, Lcom/stoicstudio/port/PortApplication;->flushIfReady(Landroid/content/Context;)V

    return-void
.end method


# virtual methods
.method public onActivityCreated(Landroid/app/Activity;Landroid/os/Bundle;)V
    .registers 3

    return-void
.end method

.method public onActivityDestroyed(Landroid/app/Activity;)V
    .registers 2

    .line 111
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$1;->drain()V

    return-void
.end method

.method public onActivityPaused(Landroid/app/Activity;)V
    .registers 2

    .line 109
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$1;->drain()V

    return-void
.end method

.method public onActivityResumed(Landroid/app/Activity;)V
    .registers 2

    return-void
.end method

.method public onActivitySaveInstanceState(Landroid/app/Activity;Landroid/os/Bundle;)V
    .registers 3

    return-void
.end method

.method public onActivityStarted(Landroid/app/Activity;)V
    .registers 2

    return-void
.end method

.method public onActivityStopped(Landroid/app/Activity;)V
    .registers 2

    .line 110
    invoke-direct {p0}, Lcom/stoicstudio/port/PortApplication$1;->drain()V

    return-void
.end method
