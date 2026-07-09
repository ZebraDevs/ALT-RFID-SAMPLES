package com.example.newgen2xplay.ui.InventoryProtocol;

import static com.example.newgen2xplay.RFIDHandler.mConnectedRfidReader;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.newgen2xplay.RFIDHandler;
import com.example.newgen2xplay.databinding.FragmentInventoryProtocolBinding;
import com.example.newgen2xplay.R;
import com.google.android.material.snackbar.Snackbar;
import com.zebra.rfid.api3.ENUM_INVENTORY_PROTOCOL;
import com.zebra.rfid.api3.InvalidUsageException;
import com.zebra.rfid.api3.OperationFailureException;

import java.util.HashMap;
import java.util.Map;


public class InventoryProtocolFragment extends Fragment {

    private static final String TAG = "INVENTORY_PROTOCOL_FRAGMENT";
    private FragmentInventoryProtocolBinding binding;
    private static final Map<Integer, ENUM_INVENTORY_PROTOCOL> PROTOCOL_MAP = new HashMap<>();

    static {
        PROTOCOL_MAP.put(R.id.rbProtocolGen2, ENUM_INVENTORY_PROTOCOL.GEN2);
        PROTOCOL_MAP.put(R.id.rbProtocolGen2X, ENUM_INVENTORY_PROTOCOL.GEN2X);
        PROTOCOL_MAP.put(R.id.rbProtocolHybrid, ENUM_INVENTORY_PROTOCOL.HYBRID);
    }

    private static Integer getButtonIdForProtocol(ENUM_INVENTORY_PROTOCOL protocol) {
        for (Map.Entry<Integer, ENUM_INVENTORY_PROTOCOL> entry : PROTOCOL_MAP.entrySet()) {
            if (entry.getValue() == protocol) return entry.getKey();
        }
        return null;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentInventoryProtocolBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        boolean isSupported = mConnectedRfidReader != null && RFIDHandler.isInventoryProtocolSupported();
        if (!isSupported) {
            // Show "not supported" message and disable protocol controls
            binding.tvNotSupported.setVisibility(View.VISIBLE);
            binding.toggleGroupProtocol.setEnabled(false);
            binding.buttonSave.setEnabled(false);
            binding.tvCurrentProtocol.setVisibility(View.GONE);
            return;
        } else {
            // Hide "not supported" message and enable protocol controls
            binding.tvNotSupported.setVisibility(View.GONE);
            binding.toggleGroupProtocol.setEnabled(true);
            binding.buttonSave.setEnabled(true);
        }

        // Load current protocol and select the correct toggle button
        ENUM_INVENTORY_PROTOCOL currentProtocol = getInventoryProtocol();
        if (currentProtocol != null) {
            Integer buttonId = getButtonIdForProtocol(currentProtocol);
            if (buttonId != null) {
                binding.toggleGroupProtocol.check(buttonId);
            }
            binding.tvCurrentProtocol.setText("Current: " + currentProtocol.toString());
            binding.tvCurrentProtocol.setVisibility(View.VISIBLE);
        }

        // Save button click
        binding.buttonSave.setOnClickListener(v -> {
            int checkedId = binding.toggleGroupProtocol.getCheckedButtonId();
            if (checkedId == View.NO_ID) {
                Snackbar.make(v, "Please select a protocol", Snackbar.LENGTH_SHORT).show();
                return;
            }
            ENUM_INVENTORY_PROTOCOL selectedProtocol = PROTOCOL_MAP.get(checkedId);
            if (selectedProtocol != null) {
                saveInventoryProtocol(selectedProtocol, v);
                binding.tvCurrentProtocol.setText("Current: " + selectedProtocol.toString());
                binding.tvCurrentProtocol.setVisibility(View.VISIBLE);
            }
        });
    }

    public void saveInventoryProtocol(ENUM_INVENTORY_PROTOCOL protocol, View v) {
        try {
            mConnectedRfidReader.Config.setInventoryProtocol(protocol);
            Snackbar.make(v, "Inventory Protocol set to " + protocol.toString(), Snackbar.LENGTH_SHORT).show();
        } catch (InvalidUsageException e) {
            Log.d(TAG, "Returned SDK Exception");
            Snackbar.make(v, "Failed to set Inventory Protocol: " + e.getMessage(), Snackbar.LENGTH_SHORT).show();
        } catch (OperationFailureException e) {
            Log.d(TAG, "Returned SDK Operation Failure Exception");
            Snackbar.make(v, "Failed to set Inventory Protocol: " + e.getVendorMessage(), Snackbar.LENGTH_SHORT).show();
        }
    }

    public ENUM_INVENTORY_PROTOCOL getInventoryProtocol() {
        ENUM_INVENTORY_PROTOCOL inventoryProtocol = null;
        if (mConnectedRfidReader == null || !mConnectedRfidReader.isConnected()) {
            Snackbar.make(binding.getRoot(), "No reader connected", Snackbar.LENGTH_SHORT).show();
            return inventoryProtocol;
        }
        try {
            inventoryProtocol = mConnectedRfidReader.Config.getInventoryProtocol();
        } catch (InvalidUsageException e) {
            Log.d(TAG, "Returned SDK Exception");
        } catch (OperationFailureException e) {
            Log.d(TAG, "Returned SDK Operation Failure Exception");
        }
        return inventoryProtocol;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}