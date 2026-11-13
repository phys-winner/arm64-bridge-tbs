.class final Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;
.super Ljava/lang/Object;
.source "PortStorage.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage$Prefs$Edit;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "Pending"
.end annotation


# instance fields
.field final callbacks:Ljava/lang/Runnable;

.field final synthetic this$1:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

.field final writing:Ljava/util/concurrent/Future;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/Future<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/concurrent/Future;Ljava/lang/Runnable;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1010,
            0x0,
            0x0
        }
        names = {
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/concurrent/Future<",
            "Ljava/lang/Boolean;",
            ">;",
            "Ljava/lang/Runnable;",
            ")V"
        }
    .end annotation

    .line 827
    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->this$1:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 828
    iput-object p2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->writing:Ljava/util/concurrent/Future;

    .line 829
    iput-object p3, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->callbacks:Ljava/lang/Runnable;

    return-void
.end method


# virtual methods
.method notifyListeners()V
    .registers 3

    .line 832
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->callbacks:Ljava/lang/Runnable;

    if-nez v0, :cond_5

    return-void

    .line 833
    :cond_5
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    if-ne v0, v1, :cond_15

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->callbacks:Ljava/lang/Runnable;

    invoke-interface {p0}, Ljava/lang/Runnable;->run()V

    return-void

    .line 834
    :cond_15
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$Pending;->callbacks:Ljava/lang/Runnable;

    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method
