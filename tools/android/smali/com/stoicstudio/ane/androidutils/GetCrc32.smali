.class public final Lcom/stoicstudio/ane/androidutils/GetCrc32;
.super Ljava/lang/Object;
.source "GetCrc32.java"

# interfaces
.implements Lcom/adobe/fre/FREFunction;


# static fields
.field static final CHUNK:I = 0x10000

.field static final MASK:J = 0xffffffffL

.field private static successLogged:Z


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static checksum(Ljava/nio/ByteBuffer;IJ)J
    .registers 18

    if-ltz p1, :cond_48

    .line 65
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->capacity()I

    move-result v1

    if-gt p1, v1, :cond_48

    const-wide v1, 0xffffffffL

    and-long v3, p2, v1

    cmp-long v3, v3, p2

    if-nez v3, :cond_48

    .line 67
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->duplicate()Ljava/nio/ByteBuffer;

    move-result-object p0

    .line 68
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->clear()Ljava/nio/Buffer;

    .line 69
    invoke-virtual {p0, p1}, Ljava/nio/ByteBuffer;->limit(I)Ljava/nio/Buffer;

    .line 70
    new-instance v3, Ljava/util/zip/CRC32;

    invoke-direct {v3}, Ljava/util/zip/CRC32;-><init>()V

    const/high16 v4, 0x10000

    .line 71
    new-array v5, v4, [B

    .line 72
    :goto_26
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->hasRemaining()Z

    move-result v6

    if-eqz v6, :cond_3c

    .line 73
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->remaining()I

    move-result v6

    invoke-static {v6, v4}, Ljava/lang/Math;->min(II)I

    move-result v6

    const/4 v7, 0x0

    .line 74
    invoke-virtual {p0, v5, v7, v6}, Ljava/nio/ByteBuffer;->get([BII)Ljava/nio/ByteBuffer;

    .line 75
    invoke-virtual {v3, v5, v7, v6}, Ljava/util/zip/CRC32;->update([BII)V

    goto :goto_26

    :cond_3c
    xor-long v8, p2, v1

    .line 77
    invoke-virtual {v3}, Ljava/util/zip/CRC32;->getValue()J

    move-result-wide v10

    int-to-long v12, p1

    invoke-static/range {v8 .. v13}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->combineFinal(JJJ)J

    move-result-wide v0

    return-wide v0

    .line 66
    :cond_48
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "CRC bounds/seed"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static combineFinal(JJJ)J
    .registers 22

    const-wide/16 v0, 0x0

    cmp-long v2, p4, v0

    if-ltz v2, :cond_6e

    const-wide v3, 0xffffffffL

    and-long v5, p0, v3

    cmp-long v5, v5, p0

    if-nez v5, :cond_6e

    and-long v5, p2, v3

    cmp-long v5, v5, p2

    if-nez v5, :cond_6e

    if-nez v2, :cond_1a

    return-wide p0

    :cond_1a
    cmp-long v2, p0, v0

    if-nez v2, :cond_1f

    return-wide p2

    :cond_1f
    const/16 v2, 0x20

    .line 87
    new-array v5, v2, [J

    .line 88
    new-array v6, v2, [J

    const/4 v7, 0x0

    const-wide v8, 0xedb88320L

    .line 89
    aput-wide v8, v5, v7

    const-wide/16 v7, 0x1

    const/4 v9, 0x1

    move-wide v11, v7

    move v10, v9

    :goto_32
    if-ge v10, v2, :cond_3a

    .line 91
    aput-wide v11, v5, v10

    shl-long/2addr v11, v9

    add-int/lit8 v10, v10, 0x1

    goto :goto_32

    .line 92
    :cond_3a
    invoke-static {v6, v5}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->square([J[J)V

    .line 93
    invoke-static {v5, v6}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->square([J[J)V

    move-wide/from16 v10, p0

    move-wide/from16 v12, p4

    .line 95
    :cond_44
    invoke-static {v6, v5}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->square([J[J)V

    and-long v14, v12, v7

    cmp-long v2, v14, v0

    if-eqz v2, :cond_51

    .line 96
    invoke-static {v6, v10, v11}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->times([JJ)J

    move-result-wide v10

    :cond_51
    ushr-long v14, v12, v9

    cmp-long v2, v14, v0

    if-nez v2, :cond_58

    goto :goto_6a

    .line 99
    :cond_58
    invoke-static {v5, v6}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->square([J[J)V

    and-long/2addr v14, v7

    cmp-long v2, v14, v0

    if-eqz v2, :cond_64

    .line 100
    invoke-static {v5, v10, v11}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->times([JJ)J

    move-result-wide v10

    :cond_64
    const/4 v2, 0x2

    ushr-long/2addr v12, v2

    cmp-long v2, v12, v0

    if-nez v2, :cond_44

    :goto_6a
    xor-long v0, v10, p2

    and-long/2addr v0, v3

    return-wide v0

    .line 83
    :cond_6e
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "CRC combine bounds"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static declared-synchronized reportNativeSuccess()V
    .registers 3

    const-class v0, Lcom/stoicstudio/ane/androidutils/GetCrc32;

    monitor-enter v0

    .line 18
    :try_start_3
    sget-boolean v1, Lcom/stoicstudio/ane/androidutils/GetCrc32;->successLogged:Z

    if-nez v1, :cond_11

    .line 19
    const-string v1, "FilePaths"

    const-string v2, "PORT_CRC32_NATIVE_OK"

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    const/4 v1, 0x1

    .line 20
    sput-boolean v1, Lcom/stoicstudio/ane/androidutils/GetCrc32;->successLogged:Z
    :try_end_11
    .catchall {:try_start_3 .. :try_end_11} :catchall_13

    .line 22
    :cond_11
    monitor-exit v0

    return-void

    :catchall_13
    move-exception v1

    :try_start_14
    monitor-exit v0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_13

    throw v1
.end method

.method private static square([J[J)V
    .registers 5

    const/4 v0, 0x0

    :goto_1
    const/16 v1, 0x20

    if-ge v0, v1, :cond_10

    .line 118
    aget-wide v1, p1, v0

    invoke-static {p1, v1, v2}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->times([JJ)J

    move-result-wide v1

    aput-wide v1, p0, v0

    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    :cond_10
    return-void
.end method

.method private static times([JJ)J
    .registers 10

    const-wide/16 v0, 0x0

    const/4 v2, 0x0

    move-wide v3, v0

    :goto_4
    cmp-long v5, p1, v0

    if-eqz v5, :cond_17

    const-wide/16 v5, 0x1

    and-long/2addr v5, p1

    cmp-long v5, v5, v0

    if-eqz v5, :cond_12

    .line 110
    aget-wide v5, p0, v2

    xor-long/2addr v3, v5

    :cond_12
    const/4 v5, 0x1

    ushr-long/2addr p1, v5

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    :cond_17
    const-wide p0, 0xffffffffL

    and-long/2addr p0, v3

    return-wide p0
.end method


# virtual methods
.method public call(Lcom/adobe/fre/FREContext;[Lcom/adobe/fre/FREObject;)Lcom/adobe/fre/FREObject;
    .registers 10

    if-eqz p2, :cond_9e

    .line 26
    :try_start_2
    array-length p0, p2

    const/4 p1, 0x1

    if-lt p0, p1, :cond_9e

    array-length p0, p2

    const/4 v0, 0x2

    if-gt p0, v0, :cond_9e

    const/4 p0, 0x0

    aget-object v1, p2, p0

    instance-of v1, v1, Lcom/adobe/fre/FREByteArray;

    if-eqz v1, :cond_9e

    .line 31
    array-length v1, p2

    const-wide v2, 0x41efffffffe00000L    # 4.294967295E9

    if-ne v1, v0, :cond_20

    aget-object v0, p2, p1

    invoke-virtual {v0}, Lcom/adobe/fre/FREObject;->getAsDouble()D

    move-result-wide v0

    goto :goto_21

    :cond_20
    move-wide v0, v2

    .line 32
    :goto_21
    invoke-static {v0, v1}, Ljava/lang/Double;->isNaN(D)Z

    move-result v4

    if-nez v4, :cond_96

    invoke-static {v0, v1}, Ljava/lang/Double;->isInfinite(D)Z

    move-result v4

    if-nez v4, :cond_96

    const-wide/16 v4, 0x0

    cmpg-double v4, v0, v4

    if-ltz v4, :cond_96

    cmpl-double v2, v0, v2

    if-gtz v2, :cond_96

    .line 33
    invoke-static {v0, v1}, Ljava/lang/Math;->floor(D)D

    move-result-wide v2

    cmpl-double v2, v0, v2

    if-nez v2, :cond_96

    .line 36
    aget-object p2, p2, p0

    check-cast p2, Lcom/adobe/fre/FREByteArray;
    :try_end_43
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_43} :catch_a6

    .line 40
    :try_start_43
    invoke-virtual {p2}, Lcom/adobe/fre/FREByteArray;->acquire()V
    :try_end_46
    .catchall {:try_start_43 .. :try_end_46} :catchall_8c

    .line 42
    :try_start_46
    invoke-virtual {p2}, Lcom/adobe/fre/FREByteArray;->getLength()J

    move-result-wide v2

    .line 43
    invoke-virtual {p2}, Lcom/adobe/fre/FREByteArray;->getBytes()Ljava/nio/ByteBuffer;

    move-result-object p0

    const-wide/16 v4, 0x0

    cmp-long v4, v2, v4

    if-ltz v4, :cond_82

    const-wide/32 v4, 0x7fffffff

    cmp-long v4, v2, v4

    if-gtz v4, :cond_82

    if-eqz p0, :cond_82

    .line 45
    invoke-virtual {p0}, Ljava/nio/ByteBuffer;->capacity()I

    move-result v4

    int-to-long v4, v4

    cmp-long v4, v2, v4

    if-gtz v4, :cond_82

    long-to-int v2, v2

    double-to-long v0, v0

    .line 48
    invoke-static {p0, v2, v0, v1}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->checksum(Ljava/nio/ByteBuffer;IJ)J

    move-result-wide p0
    :try_end_6c
    .catchall {:try_start_46 .. :try_end_6c} :catchall_8a

    .line 50
    :try_start_6c
    invoke-virtual {p2}, Lcom/adobe/fre/FREByteArray;->release()V

    long-to-double p0, p0

    .line 53
    invoke-static {p0, p1}, Lcom/adobe/fre/FREObject;->newObject(D)Lcom/adobe/fre/FREObject;

    move-result-object p0

    if-eqz p0, :cond_7a

    .line 55
    invoke-static {}, Lcom/stoicstudio/ane/androidutils/GetCrc32;->reportNativeSuccess()V

    return-object p0

    .line 54
    :cond_7a
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string p1, "CRC result"

    invoke-direct {p0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_82
    .catch Ljava/lang/Exception; {:try_start_6c .. :try_end_82} :catch_a6

    .line 46
    :cond_82
    :try_start_82
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "CRC ByteArray bounds"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_8a
    .catchall {:try_start_82 .. :try_end_8a} :catchall_8a

    :catchall_8a
    move-exception p0

    goto :goto_90

    :catchall_8c
    move-exception p1

    move-object v6, p1

    move p1, p0

    move-object p0, v6

    :goto_90
    if-eqz p1, :cond_95

    .line 50
    :try_start_92
    invoke-virtual {p2}, Lcom/adobe/fre/FREByteArray;->release()V

    .line 51
    :cond_95
    throw p0

    .line 34
    :cond_96
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "CRC seed"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 28
    :cond_9e
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "CRC arguments"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
    :try_end_a6
    .catch Ljava/lang/Exception; {:try_start_92 .. :try_end_a6} :catch_a6

    :catch_a6
    move-exception p0

    .line 59
    new-instance p1, Ljava/lang/StringBuilder;

    const-string p2, "getCrc32 failed: "

    invoke-direct {p1, p2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string p1, "FilePaths"

    invoke-static {p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    const/4 p0, 0x0

    return-object p0
.end method
