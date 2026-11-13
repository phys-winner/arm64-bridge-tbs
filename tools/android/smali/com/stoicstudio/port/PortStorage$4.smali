.class public final synthetic Lcom/stoicstudio/port/PortStorage$4;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lcom/stoicstudio/port/PortStorage$WriteBody;


# instance fields
.field public final synthetic f$0:Ljava/util/Map;


# direct methods
.method public synthetic constructor <init>(Ljava/util/Map;)V
    .registers 2

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$4;->f$0:Ljava/util/Map;

    return-void
.end method


# virtual methods
.method public final write(Ljava/io/OutputStream;)V
    .registers 2

    .line 0
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$4;->f$0:Ljava/util/Map;

    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->lambda$writeXml$0(Ljava/util/Map;Ljava/io/OutputStream;)V

    return-void
.end method
