package com.instapp.nat.alipay;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import android.content.Context;
import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alipay.sdk.app.AuthTask;
import com.alipay.sdk.app.PayTask;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Acathur on 17/10/1.
 * Copyright (c) 2017 Instapp. All rights reserved.
 */

public class AlipayModule {

    private Context mContext;
    private static volatile AlipayModule instance = null;

    private static final int SDK_PAY_FLAG = 1;
    private static final int SDK_AUTH_FLAG = 2;

    private AlipayModule(Context context){
        mContext = context;
    }

    public static AlipayModule getInstance(Context context) {
        if (instance == null) {
            synchronized (AlipayModule.class) {
                if (instance == null) {
                    instance = new AlipayModule(context);
                }
            }
        }

        return instance;
    }

    // pay

    public void pay(final Activity activity, final HashMap<String, Object> params, final ModuleResultListener listener)  {

        final String orderInfo = (String) params.get("info");
        final Boolean showLoading = params.containsKey("showLoading") ? (Boolean) params.get("showLoading") : true;

        final Handler mHandler = new Handler() {
            public void handleMessage(Message msg) {
                PayResult payResult = new PayResult((Map<String, String>) msg.obj);

                String resultInfo = payResult.getResult();
                String resultStatus = payResult.getResultStatus();
                String memo = payResult.getMemo();

                if (TextUtils.equals(resultStatus, "9000")) {
                    // callback result object
                    Map<String, Object> result = (Map<String, Object>) JSON.parse(resultInfo);
                    listener.onResult(result);
                } else {
                    HashMap<String, Object> result = new HashMap<>();
                    HashMap<String, String> error = new HashMap<>();
                    error.put("code", resultStatus);
                    error.put("msg", memo);
                    result.put("error", error);
                    listener.onResult(result);
                }
            }
        };

        Runnable payRunnable = new Runnable() {
            @Override
            public void run() {
                PayTask alipay = new PayTask(activity);
                Map<String, String> result = alipay.payV2(orderInfo, showLoading);

                Message msg = new Message();
                msg.what = SDK_PAY_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

    // auth

    public void auth(final Activity activity, final HashMap<String, Object> params, final ModuleResultListener listener)  {

        final String authInfo = (String) params.get("info");
        final Boolean showLoading = params.containsKey("showLoading") ? (Boolean) params.get("showLoading") : true;

        final Handler mHandler = new Handler() {
            public void handleMessage(Message msg) {
                AuthResult authResult = new AuthResult((Map<String, String>) msg.obj, true);

                String resultStatus = authResult.getResultStatus();
                String memo = authResult.getMemo();

                if (TextUtils.equals(resultStatus, "9000") && TextUtils.equals(authResult.getResultCode(), "200")) {
                    // callback result object
                    HashMap<String, String> result = new HashMap<>();
                    result.put("alipayOpenId", authResult.getAlipayOpenId());
                    result.put("authCode", authResult.getAuthCode());
                    listener.onResult(result);
                } else {
                    HashMap<String, Object> result = new HashMap<>();
                    HashMap<String, String> error = new HashMap<>();
                    error.put("code", resultStatus);
                    error.put("msg", memo);
                    result.put("error", error);
                    listener.onResult(result);
                }
            }
        };

        Runnable authRunnable = new Runnable() {

            @Override
            public void run() {
                AuthTask authTask = new AuthTask(activity);
                Map<String, String> result = authTask.authV2(authInfo, showLoading);

                Message msg = new Message();
                msg.what = SDK_AUTH_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };

        // 必须异步调用
        Thread authThread = new Thread(authRunnable);
        authThread.start();
    }
}
