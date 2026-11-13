.class public final synthetic Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

.field public final synthetic f$1:Ljava/util/List;

.field public final synthetic f$2:Z

.field public final synthetic f$3:Ljava/util/Set;


# direct methods
.method public synthetic constructor <init>(Lcom/stoicstudio/port/PortStorage$Prefs$Edit;Ljava/util/List;ZLjava/util/Set;)V
    .registers 5

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    iput-object p2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$1:Ljava/util/List;

    iput-boolean p3, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$2:Z

    iput-object p4, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$3:Ljava/util/Set;

    return-void
.end method


# virtual methods
.method public final run()V
    .registers 4

    .line 0
    iget-object v0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$0:Lcom/stoicstudio/port/PortStorage$Prefs$Edit;

    iget-object v1, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$1:Ljava/util/List;

    iget-boolean v2, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$2:Z

    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$Prefs$Edit$1;->f$3:Ljava/util/Set;

    invoke-virtual {v0, v1, v2, p0}, Lcom/stoicstudio/port/PortStorage$Prefs$Edit;->lambda$submit$1$com-stoicstudio-port-PortStorage$Prefs$Edit(Ljava/util/List;ZLjava/util/Set;)V

    return-void
.end method
