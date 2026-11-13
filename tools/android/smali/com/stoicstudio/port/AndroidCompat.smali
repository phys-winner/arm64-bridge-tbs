.class public final Lcom/stoicstudio/port/AndroidCompat;
.super Ljava/lang/Object;
.source "AndroidCompat.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/stoicstudio/port/AndroidCompat$Api33;
    }
.end annotation


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    .registers 4

    .line 26
    invoke-static {p3}, Lcom/stoicstudio/port/AndroidCompat;->immutableFlags(I)I

    move-result p3

    invoke-static {p0, p1, p2, p3}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object p0

    return-object p0
.end method

.method public static getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;
    .registers 4

    .line 30
    invoke-static {p3}, Lcom/stoicstudio/port/AndroidCompat;->immutableFlags(I)I

    move-result p3

    invoke-static {p0, p1, p2, p3}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object p0

    return-object p0
.end method

.method private static immutableFlags(I)I
    .registers 3

    const/high16 v0, 0x6000000

    and-int v1, p0, v0

    if-eq v1, v0, :cond_c

    if-nez v1, :cond_b

    const/high16 v0, 0x4000000

    or-int/2addr p0, v0

    :cond_b
    return p0

    .line 19
    :cond_c
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Contradictory PendingIntent mutability flags"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static registerExternal(Landroid/content/Context;Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;
    .registers 5

    .line 41
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_e

    if-eqz p1, :cond_e

    const/4 v0, 0x1

    invoke-static {p0, p1, p2, v0}, Lcom/stoicstudio/port/AndroidCompat$Api33;->register(Landroid/content/Context;Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Z)Landroid/content/Intent;

    move-result-object p0

    return-object p0

    .line 42
    :cond_e
    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    move-result-object p0

    return-object p0
.end method

.method public static registerPrivate(Landroid/content/Context;Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;
    .registers 5

    .line 35
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_e

    if-eqz p1, :cond_e

    const/4 v0, 0x0

    invoke-static {p0, p1, p2, v0}, Lcom/stoicstudio/port/AndroidCompat$Api33;->register(Landroid/content/Context;Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Z)Landroid/content/Intent;

    move-result-object p0

    return-object p0

    .line 36
    :cond_e
    invoke-virtual {p0, p1, p2}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    move-result-object p0

    return-object p0
.end method
