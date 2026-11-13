.class interface abstract Lcom/stoicstudio/port/PortStorage$WriteBody;
.super Ljava/lang/Object;
.source "PortStorage.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/stoicstudio/port/PortStorage;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x608
    name = "WriteBody"
.end annotation


# virtual methods
.method public abstract write(Ljava/io/OutputStream;)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation
.end method
