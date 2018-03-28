package com.example.attendance;

import android.os.Bundle;
import android.content.Intent;
import android.accounts.AccountManager;
import android.provider.Settings.Secure;


import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "attendance.student";
    MethodChannel.Result resultE;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if (methodCall.method.equals("getStudentSelectedAccount")) {
                    resultE = result;
                    getStudentSelectedAccount();

                } else if (methodCall.method.equals("getAndroidID")) {
                    result.success(getAndroidID());
                } else {
                    result.notImplemented();
                }
            }
        });
    }

    private String getAndroidID() {
        return Secure.getString(this.getContentResolver(),
                Secure.ANDROID_ID);
    }

    private void getStudentSelectedAccount() {
        Intent intent = AccountManager.newChooseAccountIntent(null, null,
                new String[]{"com.google"}, true, null, null,
                null, null);
        startActivityForResult(intent, 111);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        switch (requestCode) {
            case 111:
                if (data != null)
                    this.resultE.success(data.getStringExtra(AccountManager.KEY_ACCOUNT_NAME));
                break;
        }

    }
}
