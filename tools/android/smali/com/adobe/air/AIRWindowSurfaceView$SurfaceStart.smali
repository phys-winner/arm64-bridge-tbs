.class final Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final view:Lcom/adobe/air/AIRWindowSurfaceView;
.field private final holder:Landroid/view/SurfaceHolder;
.field private final format:I
.field private final width:I
.field private final height:I

.method constructor <init>(Lcom/adobe/air/AIRWindowSurfaceView;Landroid/view/SurfaceHolder;III)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->view:Lcom/adobe/air/AIRWindowSurfaceView;
    iput-object p2, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->holder:Landroid/view/SurfaceHolder;
    iput p3, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->format:I
    iput p4, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->width:I
    iput p5, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->height:I
    return-void
.end method

.method public run()V
    .locals 5
    iget-object v0, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->view:Lcom/adobe/air/AIRWindowSurfaceView;
    iget-object v1, v0, Lcom/adobe/air/AIRWindowSurfaceView;->mPortSurfaceStart:Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;
    if-ne v1, p0, :done

    const/4 v1, 0x0
    iput-object v1, v0, Lcom/adobe/air/AIRWindowSurfaceView;->mPortSurfaceStart:Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;
    iget-object v1, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->holder:Landroid/view/SurfaceHolder;
    invoke-interface {v1}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;
    move-result-object v2
    invoke-virtual {v2}, Landroid/view/Surface;->isValid()Z
    move-result v2
    if-eqz v2, :done

    const-string v2, "BannerSagaBridge"
    const-string v3, "AIR surface start replay after window focus"
    invoke-static {v2, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    iget v3, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->width:I
    iget v4, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->height:I
    const/4 v2, 0x1
    iput-boolean v2, v0, Lcom/adobe/air/AIRWindowSurfaceView;->mPortSurfaceStartReplaying:Z
    iget v2, p0, Lcom/adobe/air/AIRWindowSurfaceView$SurfaceStart;->format:I
    :replay_start
    invoke-virtual/range {v0 .. v4}, Lcom/adobe/air/AIRWindowSurfaceView;->surfaceChanged(Landroid/view/SurfaceHolder;III)V
    :replay_end
    .catchall {:replay_start .. :replay_end} :replay_failed
    const/4 v2, 0x0
    iput-boolean v2, v0, Lcom/adobe/air/AIRWindowSurfaceView;->mPortSurfaceStartReplaying:Z
    :done
    return-void

    :replay_failed
    move-exception v2
    const/4 v1, 0x0
    iput-boolean v1, v0, Lcom/adobe/air/AIRWindowSurfaceView;->mPortSurfaceStartReplaying:Z
    throw v2
.end method
