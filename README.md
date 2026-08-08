# Advanced Aircraft Functionality Scripts for Prepar3D

This repository contains scripts designed to enable advanced functionality for aircraft in Prepar3D (P3D) that do not have access to the FSUIPC WebAssembly (WASM) module. This limitation arises because the WASM module was not available for the FSUIPC versions compatible with this simulator.

## Installation

To install the scripts, simply copy the script files into the following directory:

Documents\Prepar3D Vx add-ons\FSUIPC X
x= Your P3D major version (V6 and V5 supported)

## Usage

There are two ways to activate the scripts:

1. **Bind a Key in FSUIPC:**

   - Open FSUIPC.
   - Bind a key to the function:
     ```
     lua FILENAME
     ```
   - Replace `FILENAME` with the name of the script file you want to run.

2. **Automatic Startup via fsuipc.ini:**

   - Open your `fsuipc.ini` file.
   - Add a new section called `[Auto]` with the following line:
     ```
     1=lua FILENAME
     ```
   - Replace `FILENAME` with the name of the script file you want to run.

## Compatibility and Safety

- The scripts are designed to automatically terminate if the loaded aircraft does not match the intended aircraft for the script.
- This ensures that the scripts do not interfere with other aircraft or operations within Prepar3D.

---

If you have any questions or need further assistance, please feel free to open an issue.
