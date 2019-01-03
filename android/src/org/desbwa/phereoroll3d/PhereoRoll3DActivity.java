package org.desbwa.phereoroll3d;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.os.*;
import android.content.*;
import android.app.*;
import java.lang.UnsatisfiedLinkError;

public class PhereoRoll3DActivity extends QtActivity {
    public static native void openedUri(String url);

    private void processIntent(Intent intent) {
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            String uri = intent.getDataString();
            if (uri != null) {
                setIntent(intent);
                try {
                    openedUri(uri);
                } catch (UnsatisfiedLinkError e) {
                    System.loadLibrary("PhereoRoll3D"); // Force early load if needed
                    openedUri(uri);
                }
            }
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        processIntent(getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        processIntent(intent);
    }
}
