.class public final synthetic Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/util/concurrent/Callable;


# instance fields
.field public final synthetic f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

.field public final synthetic f$1:Ljava/util/Map;


# direct methods
.method public synthetic constructor <init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/Map;)V
    .registers 3

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;->f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    iput-object p2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;->f$1:Ljava/util/Map;

    return-void
.end method


# virtual methods
.method public final call()Ljava/lang/Object;
    .registers 2

    .line 0
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;->f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$0;->f$1:Ljava/util/Map;

    invoke-virtual {v0, p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->lambda$submit$0$com-stoicstudio-port-PortStorage$Prefs$Edit(Ljava/util/Map;)Ljava/lang/Boolean;

    move-result-object p0

    return-object p0
.end method
