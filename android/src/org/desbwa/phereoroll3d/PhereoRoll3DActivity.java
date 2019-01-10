package org.desbwa.phereoroll3d;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.os.*;
import android.content.*;
import android.app.*;
import java.lang.UnsatisfiedLinkError;
import java.io.FileWriter;

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

    @Override
    public void onResume() {
        super.onResume();

        // Try to enable 3D barrier (NEO3DO?)
        try {
            FileWriter fstream = new FileWriter("/sys/class/enable3d/enable-3d");
            fstream.write("1");
            fstream.close();
        } catch (Exception e) {
            // pass
        }

        // Try to enable 3D barrier (MasterImage?)
        try {
            FileWriter fstream = new FileWriter("/dev/mi3d_tn_ctrl");
            fstream.write(0x20);
            fstream.close();
        } catch (Exception e) {
            // pass
        }
    }

    @Override
    public void onPause() {
        super.onPause();

        // Try to disable 3D barrier (NEO3DO?)
        try {
            FileWriter fstream = new FileWriter("/sys/class/enable3d/enable-3d");
            fstream.write("0");
            fstream.close();
        } catch (Exception e) {
            // pass
        }

        // Try to disable 3D barrier (MasterImage?)
        try {
            FileWriter fstream = new FileWriter("/dev/mi3d_tn_ctrl");
            fstream.write(0x10);
            fstream.close();
        } catch (Exception e) {
            // pass
        }
    }
}
