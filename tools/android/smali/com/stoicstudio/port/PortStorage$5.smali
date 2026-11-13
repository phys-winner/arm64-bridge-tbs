.class public final synthetic Lcom/stoicstudio/port/PortStorage$5;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lcom/stoicstudio/port/PortStorage$WriteBody;


# instance fields
.field public final synthetic f$0:Ljava/io/File;


# direct methods
.method public synthetic constructor <init>(Ljava/io/File;)V
    .registers 2

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/stoicstudio/port/PortStorage$5;->f$0:Ljava/io/File;

    return-void
.end method


# virtual methods
.method public final write(Ljava/io/OutputStream;)V
    .registers 2

    .line 0
    iget-object p0, p0, Lcom/stoicstudio/port/PortStorage$5;->f$0:Ljava/io/File;

    invoke-static {p0, p1}, Lcom/stoicstudio/port/PortStorage;->lambda$copyVerified$0(Ljava/io/File;Ljava/io/OutputStream;)V

    return-void
.end method
