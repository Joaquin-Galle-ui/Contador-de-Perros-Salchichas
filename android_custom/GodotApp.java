/**************************************************************************/
/*  GodotApp.java                                                         */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

package com.godot.game;

import org.godotengine.godot.Godot;
import org.godotengine.godot.GodotActivity;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import java.util.concurrent.atomic.AtomicInteger;

import androidx.activity.EdgeToEdge;
import androidx.core.splashscreen.SplashScreen;

/**
 * Template activity for Godot Android builds.
 * Feel free to extend and modify this class for your custom logic.
 */
public class GodotApp extends GodotActivity {
	private static final String NOTIFICATION_CHANNEL_ID = "salchicha_mensajes";
	private static final AtomicInteger NOTIFICATION_IDS = new AtomicInteger(2000);
	private static GodotApp currentInstance;

	static {
		// .NET libraries.
		if (BuildConfig.FLAVOR.equals("mono")) {
			try {
				Log.v("GODOT", "Loading System.Security.Cryptography.Native.Android library");
				System.loadLibrary("System.Security.Cryptography.Native.Android");
			} catch (UnsatisfiedLinkError e) {
				Log.e("GODOT", "Unable to load System.Security.Cryptography.Native.Android library");
			}
		}
	}

	private final Runnable updateWindowAppearance = () -> {
		Godot godot = getGodot();
		if (godot != null) {
			godot.enableImmersiveMode(godot.isInImmersiveMode(), true);
			godot.enableEdgeToEdge(godot.isInEdgeToEdgeMode(), true);
			godot.setSystemBarsAppearance();
		}
	};

	@Override
	public void onCreate(Bundle savedInstanceState) {
		SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
		EdgeToEdge.enable(this);
		super.onCreate(savedInstanceState);
		currentInstance = this;

		Godot godot = getGodot();
		if (godot != null && godot.getDisableGodotSplash()) {
			splashScreen.setKeepOnScreenCondition(() -> godot.getRunStatus() != Godot.RunStatus.STARTED);
		}
	}

	/** Shows a real Android notification while Godot is in the foreground. */
	public static void showSalchichaNotification(String title, String message) {
		GodotApp activity = currentInstance;
		if (activity == null) {
			return;
		}
		activity.runOnUiThread(() -> activity.showSalchichaNotificationInternal(title, message));
	}

	private void showSalchichaNotificationInternal(String title, String message) {
		NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
		if (manager == null) {
			return;
		}

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			NotificationChannel channel = new NotificationChannel(
					NOTIFICATION_CHANNEL_ID,
					"Mensajes salchicha",
					NotificationManager.IMPORTANCE_HIGH);
			channel.setDescription("Mensajes y logros del contador de perros salchicha");
			channel.enableVibration(true);
			manager.createNotificationChannel(channel);
		}

		Intent launchIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
		PendingIntent pendingIntent = null;
		if (launchIntent != null) {
			launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
			pendingIntent = PendingIntent.getActivity(
					this,
					0,
					launchIntent,
					PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
		}

		Notification.Builder builder = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
				? new Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
				: new Notification.Builder(this);
		builder.setSmallIcon(getApplicationInfo().icon)
				.setContentTitle(title == null || title.isEmpty() ? "Mensaje salchicha" : title)
				.setContentText(message)
				.setStyle(new Notification.BigTextStyle().bigText(message))
				.setAutoCancel(true)
				.setPriority(Notification.PRIORITY_HIGH)
				.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE);
		if (pendingIntent != null) {
			builder.setContentIntent(pendingIntent);
		}
		manager.notify(NOTIFICATION_IDS.incrementAndGet(), builder.build());
	}

	@Override
	protected void onDestroy() {
		if (currentInstance == this) {
			currentInstance = null;
		}
		super.onDestroy();
	}

	@Override
	public void onResume() {
		super.onResume();
		updateWindowAppearance.run();
	}

	@Override
	public void onGodotMainLoopStarted() {
		super.onGodotMainLoopStarted();
		runOnUiThread(updateWindowAppearance);
	}

	@Override
	public void onGodotForceQuit(Godot instance) {
		if (!BuildConfig.FLAVOR.equals("instrumented")) {
			// For instrumented builds, we disable force-quitting to allow the instrumented tests to complete
			// successfully, otherwise they fail when the process crashes.
			super.onGodotForceQuit(instance);
		}
	}

	@Override
	protected boolean isPiPEnabled() {
		return true;
	}
}
