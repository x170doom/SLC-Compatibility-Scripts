scripts to enable advanced functionality for aircraft in P3D that dont have access to the fsuipc wasm module (as it did not exist for the fsuipc versions on this sim)
to install simply drop into "Documents>Prepar3D V5/6 add-ons>FSUIPC 6" then either bind a key in FSUIPC to the function "lua FILENAME" or open your fsuipc.ini file and add a new section called "[Auto]" with the body text "1=lua FILENAME"
FILENAME = the name of the script file you want to use
the scripts shouldn't intefere with other aircraft as it is set to auto-terminate if it detects that the aircraft loaded doesn't match the aircraft the script is intended for
