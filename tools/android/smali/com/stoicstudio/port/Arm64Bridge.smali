.class public final Lcom/stoicstudio/port/Arm64Bridge;
.super Ljava/lang/Object;
.source "Arm64Bridge.java"

.method public static initialize(Landroid/content/Context;)V
    .locals 3
    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v1
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v1
    const-string v2, "TMPDIR"
    const/4 v0, 0x1
    invoke-static {v2, v1, v0}, Landroid/system/Os;->setenv(Ljava/lang/String;Ljava/lang/String;Z)V
    const-string v0, "Core"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    invoke-static {p0}, Lcom/stoicstudio/port/Arm64Bridge;->nativeBootstrap(Landroid/content/Context;)V
    return-void
.end method

.method private static native nativeBootstrap(Landroid/content/Context;)V
.end method

.method public static native loadLibrary(Ljava/lang/String;)V
.end method
