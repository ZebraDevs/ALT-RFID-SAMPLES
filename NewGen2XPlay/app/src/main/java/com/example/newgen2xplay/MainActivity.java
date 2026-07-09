package com.example.newgen2xplay;

import android.Manifest;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Menu;
import android.widget.Toast;

import com.example.newgen2xplay.ui.Inventory.TagDataViewModel;
import com.google.android.material.snackbar.Snackbar;
import com.google.android.material.navigation.NavigationView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.NavOptions;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.appcompat.app.AppCompatActivity;

import com.example.newgen2xplay.databinding.ActivityMainBinding;


public class MainActivity extends AppCompatActivity {

    private AppBarConfiguration mAppBarConfiguration;
    private ActivityMainBinding binding;
    final static String TAG = "MAIN_ACTIVITY";
    private static final String[] PERMISSIONS = new String[]{Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_ADVERTISE };
    private static final int REQUEST_CODE_BLUETOOTH_CONNECT = 1;
    private static final int BLUETOOTH_PERMISSION_REQUEST_CODE = 100;
    RFIDHandler rfidHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this,
                    Manifest.permission.BLUETOOTH_CONNECT)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT}, BLUETOOTH_PERMISSION_REQUEST_CODE);
                return;
            } else {
                initializeApp();
            }
        }
        else {
          initializeApp();
        }
    }

    private void initializeApp(){
        if(binding != null){
            return;
        }

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        rfidHandler = getRfidHandler();

        setSupportActionBar(binding.appBarMain.toolbar);

        DrawerLayout drawer = binding.drawerLayout;
        NavigationView navigationView = binding.navView;

        mAppBarConfiguration = new AppBarConfiguration.Builder(
                R.id.nav_connect,R.id.nav_inventory, R.id.nav_prefilter, R.id.nav_singulation, R.id.nav_custom_tagquiet, R.id.nav_tag_protect)
                .setOpenableLayout(drawer)
                .build();
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment_content_main);
        NavigationUI.setupActionBarWithNavController(this, navController, mAppBarConfiguration);
        NavigationUI.setupWithNavController(navigationView, navController);
        RFIDHandler.tagDataViewModel = new ViewModelProvider(this).get(TagDataViewModel.class);

        // Observe connection status to dynamically add/remove Inventory Protocol nav item
        rfidHandler.connectionStatus.observe(this, isConnected -> {
            Menu menu = navigationView.getMenu();
            if (Boolean.TRUE.equals(isConnected) && RFIDHandler.isInventoryProtocolSupported()) {
                if (menu.findItem(R.id.nav_inventory_protocol) == null) {
                    menu.add(R.id.nav_group, R.id.nav_inventory_protocol, Menu.NONE, R.string.title_inv_protocol)
                            .setIcon(R.drawable.ic_launcher_foreground)
                            .setCheckable(true);
                    Log.d(TAG, "Inventory Protocol nav item added");
                }
            } else {
                menu.removeItem(R.id.nav_inventory_protocol);
                Log.d(TAG, "Inventory Protocol nav item removed");
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_version) {
            String versionName = "";
            String sdk = "";
            try {
                versionName = BuildConfig.VERSION_NAME;
                sdk = com.zebra.rfid.api3.BuildConfig.VERSION_NAME;

            } catch (Exception e) {
                versionName = "Unknown";
                sdk = "Unknown";
            }
            new AlertDialog.Builder(this)
                    .setTitle("Version Info")
                    .setMessage("App Version: " + versionName + "\nSDK Version: " + sdk)
                    .setPositiveButton("OK", null)
                    .show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment_content_main);
        if (navController.getCurrentDestination() != null
                && navController.getCurrentDestination().getId() == R.id.nav_inventory_protocol) {
            NavOptions navOptions = new NavOptions.Builder()
                    .setPopUpTo(R.id.nav_inventory_protocol, true)
                    .build();
            navController.navigate(R.id.nav_inventory, null, navOptions);
            return true;
        }
        return NavigationUI.navigateUp(navController, mAppBarConfiguration)
                || super.onSupportNavigateUp();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == BLUETOOTH_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                initializeApp();

            } else {
                Toast.makeText(getApplicationContext(), "Bluetooth permission is required for the app to function properly.", Toast.LENGTH_LONG).show();
                // The user has denied the permission.
                finish();
            }
        }
    }

    public RFIDHandler getRfidHandler() {
        if (rfidHandler == null) {
            Log.d(TAG, "RFIDHandler is null, creating a new instance");
            rfidHandler = new RFIDHandler();
            rfidHandler.onCreate(this);
        }
        return rfidHandler;
    }
}