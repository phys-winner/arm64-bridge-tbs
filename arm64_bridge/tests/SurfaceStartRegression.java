import android.graphics.SurfaceTexture;
import android.view.Surface;
import android.view.SurfaceHolder;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Proxy;

// Runs against the installed APK in a separate ART shell process, without AIR/JNI startup.
public final class SurfaceStartRegression {
    private static int checks;

    private static void check(boolean value) {
        if (!value) throw new AssertionError("surface start check " + checks);
        checks++;
    }

    private static Field field(Object object, String name) throws Exception {
        Field result = object.getClass().getDeclaredField(name);
        result.setAccessible(true);
        return result;
    }

    private static void pending(Object object, Object view, SurfaceHolder holder,
                                int format, int width, int height) throws Exception {
        check(field(object, "view").get(object) == view);
        check(field(object, "holder").get(object) == holder);
        check(field(object, "format").getInt(object) == format);
        check(field(object, "width").getInt(object) == width);
        check(field(object, "height").getInt(object) == height);
    }

    public static void main(String[] args) throws Exception {
        Class<?> unsafeClass = Class.forName("sun.misc.Unsafe");
        Object unsafe = null;
        for (Field candidate : unsafeClass.getDeclaredFields()) {
            if (Modifier.isStatic(candidate.getModifiers()) && candidate.getType() == unsafeClass) {
                candidate.setAccessible(true);
                unsafe = candidate.get(null);
                break;
            }
        }
        check(unsafe != null);
        Class<?> viewClass = Class.forName("com.adobe.air.AIRWindowSurfaceView");
        Object view = unsafeClass.getMethod("allocateInstance", Class.class).invoke(unsafe, viewClass);
        Method changed = viewClass.getMethod("surfaceChanged", SurfaceHolder.class,
                                            int.class, int.class, int.class);
        Method focus = viewClass.getMethod("onWindowFocusChanged", boolean.class);
        Field queued = field(view, "mPortSurfaceStart");
        SurfaceTexture texture = new SurfaceTexture(true);
        Surface invalid = new Surface(texture);
        invalid.release();
        check(!invalid.isValid());
        Surface valid = null;
        Surface[] current = {invalid};
        SurfaceHolder holder = (SurfaceHolder) Proxy.newProxyInstance(
            viewClass.getClassLoader(), new Class<?>[]{SurfaceHolder.class},
            (proxy, method, arguments) -> method.getName().equals("getSurface") ? current[0] : null);
        try {
            changed.invoke(view, holder, 1, 2400, 1080);
            Object first = queued.get(view);
            pending(first, view, holder, 1, 2400, 1080);
            check(!field(view, "mSurfaceValid").getBoolean(view));
            changed.invoke(view, holder, 4, 1080, 2400);
            Object latest = queued.get(view);
            check(first != latest);
            ((Runnable) first).run();
            check(queued.get(view) == latest);
            pending(latest, view, holder, 4, 1080, 2400);
            focus.invoke(view, false);
            check(queued.get(view) == latest);
            focus.invoke(view, true);
            check(field(view, "mWindowHasFocus").getBoolean(view));
            check(queued.get(view) == latest);
            check(!field(view, "mSurfaceValid").getBoolean(view));
            ((Runnable) latest).run();
            check(queued.get(view) == null);
            check(!field(view, "mSurfaceValid").getBoolean(view));

            focus.invoke(view, false);
            changed.invoke(view, holder, 1, 2400, 1080);
            Object canceled = queued.get(view);
            queued.set(view, null);
            ((Runnable) canceled).run();
            check(queued.get(view) == null);

            valid = new Surface(texture);
            current[0] = valid;
            check(valid.isValid());
            changed.invoke(view, holder, 4, 1080, 2400);
            Object lostFocus = queued.get(view);
            ((Runnable) lostFocus).run();
            Object rearmed = queued.get(view);
            check(rearmed != null && rearmed != lostFocus);
            pending(rearmed, view, holder, 4, 1080, 2400);
            check(!field(view, "mSurfaceValid").getBoolean(view));
            check(!field(view, "mPortSurfaceStartReplaying").getBoolean(view));

            focus.invoke(view, true);
            changed.invoke(view, holder, 1, 2400, 1080);
            Object focused = queued.get(view);
            pending(focused, view, holder, 1, 2400, 1080);
            check(!field(view, "mSurfaceValid").getBoolean(view));
            check(!field(view, "mPortSurfaceStartReplaying").getBoolean(view));
            try {
                // The synthetic view lacks its wrapper; original startup must throw.
                ((Runnable) focused).run();
                throw new AssertionError("original startup exception was swallowed");
            } catch (NullPointerException expected) {
                check(queued.get(view) == null);
                check(!field(view, "mPortSurfaceStartReplaying").getBoolean(view));
                check(!field(view, "mSurfaceValid").getBoolean(view));
            }
            System.out.println("Surface start ART checks PASS: " + checks);
        } finally {
            if (valid != null) valid.release();
            if (texture != null) texture.release();
            invalid.release();
        }
    }
}
