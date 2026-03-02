--slc FSL a320 man in the middle compatiblitiy script
--written by x170doom
--debug mode can be enabled by setting the "debugmode" variable to true
--var innit
LeftLL = false
Rightll = false
debugmode = false
aircrafttype = ipc.readSTR("3D00", 11)
function aircraftcheck()
	if aircrafttype == "FSLabs A321" or "FSLabs A320" or "FSLabs A319" and checkran == false then
		local checkran = true
		return
	elseif checkran == true then
		return
	else
		debugingmode("fsl a320 not detected. exiting")
		ipc.exit()
	end
end

aircraftcheck()


function seatbeltcheck (varname, value)
	if value == 20 then
		ipc.setbitsUW("341D", 1)
		debugingmode("seatbelts set to 1")
	elseif value == 0 then
		ipc.clearbitsUW("341D", 1)
		debugingmode("seatbelts set to 0")
	else
		error("invalid LVAR value")
	end
end

function LLcheck (varname, value)
	if varname == "VC_OVHD_EXTLT_Land_L_Switch" then
		if value == 20 then
			LeftLL = true
			debugingmode("left landing light switch on")
		elseif value < 11 then
			LeftLL = false
			debugingmode("left landing light switch off")
		else
			error("left landing light switch lvar outside of expected range")
		end
	elseif varname == "VC_OVHD_EXTLT_Land_R_Switch" then
		if value == 20 then
			RightLL = true
			debugingmode("Rightlanding light switch on")
		elseif value < 11 then
			RightLL = false
			debugingmode("Right landing light switch off")
		else
			error("Right landing light switch lvar outside of expected range")
		end
	else
		return
	end
	if LeftLL or RightLL then
		ipc.setbitsUW("0D0C", 4)
		debugingmode("LL variable set")
	elseif not LeftLL and not RightLL then
		ipc.clearbitsUW("0D0C", 4)
		debugingmode("LL variable cleared")
	else
		return
	end
end

function noselightcheck (varname, value)
	if value > 9  then
		ipc.setbitsUW("0D0C", 8)
		debugingmode("taxi set to 1")
	elseif value == 0 then
		ipc.clearbitsUW("0D0C", 8)
		debugingmode("taxi set to 0")
	else
		error("invalid LVAR value")
	end
end

function strobelightcheck (varname, value)
	if value == 20  then
		ipc.setbitsUW("0D0C", 16)
		debugingmode("strobe set to 1")
	elseif value < 11 then
		ipc.clearbitsUW("0D0C", 16)
		debugingmode("strobe set to 0")
	else
		error("invalid LVAR value")
	end
end
function beaconlightcheck (varname, value)
	if value == 10  then
		ipc.setbitsUW("0D0C", 2)
		debugingmode("beacon set to 1")
	elseif value == 0 then
		ipc.clearbitsUW("0D0C", 2)
		debugingmode("beacon to 0")
	else
		error("invalid LVAR value")
	end
end
function WingInspectLightCheck (varname, value)
	if value == 10  then
		ipc.setbitsUW("0D0C", 128)
		debugingmode("taxi set to 1")
	elseif value == 0 then
		ipc.clearbitsUW("0D0C", 128)
		debugingmode("taxi set to 0")
	else
		error("invalid LVAR value")
	end
end
function A320Doorcheck (varname, value)
	if varname == "FSLA320_pax_door1" then
		if value == 3000 then
			ipc.setbitsUW("3367", 1)
			debugingmode("door 1 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 1)
			debugingmode("door 1 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 1)
			debugingmode("door 1 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door2" then
		if value == 3000 then
			ipc.setbitsUW("3367", 2)
			debugingmode("door 2 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 2)
			debugingmode("door 2 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 2)
			debugingmode("door 2 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door3" then
		if value == 3000 then
			ipc.setbitsUW("3367", 4)
			debugingmode("door 3 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 4)
			debugingmode("door 3 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 4)
			debugingmode("door 3 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door4" then
		if value == 3000 then
			ipc.setbitsUW("3367", 8)
			debugingmode("door 4 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 8)
			debugingmode("door 4 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 8)
			debugingmode("door 4 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door5" then
		if value == 3000 then
			ipc.setbitsUW("3367", 16)
			debugingmode("door 5 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 16)
			debugingmode("door 5 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 16)
			debugingmode("door 5 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door6" then
		if value == 3000 then
			ipc.setbitsUW("3367", 32)
			debugingmode("door 6 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 32)
			debugingmode("door 6 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 32)
			debugingmode("door 6 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door7" then
		if value == 3000 then
			ipc.setbitsUW("3367", 64)
			debugingmode("door 7 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 64)
			debugingmode("door 7 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 64)
			debugingmode("door 7 closed, 320assumed")
		end
	elseif varname == "FSLA320_pax_door8" then
		if value == 3000 then
			ipc.setbitsUW("3367", 128)
			debugingmode("door 8 open, 320detected")
		elseif value == 0 then
			ipc.clearbitsUW("3367", 128)
			debugingmode("door 8 closed, 320detected")
		else
			ipc.clearbitsUW("3367", 128)
			debugingmode("door 8 closed, 320assumed")
		end
	else
		error("FSL A321 using wrong door lvars, a320 was detected")
	end
end
function debugingmode (logtext)
	if debugmode == true then
		ipc.log(logtext)
	else
		return
	end
end

event.Lvar("VC_OVHD_SIGNS_SeatBelts_Switch", 100, "seatbeltcheck")--seatbelt light
event.Lvar("VC_OVHD_EXTLT_Land_L_Switch", 100, "LLcheck")--landing left
event.Lvar("VC_OVHD_EXTLT_Land_R_Switch", 150, "LLcheck")--landing right
event.Lvar("VC_OVHD_EXTLT_Nose_Switch", 100, "noselightcheck")--nose light(considers taxi and TO settings as on)
event.Lvar("VC_OVHD_EXTLT_Strobe_Switch", 100, "strobelightcheck")--strobe light
event.Lvar("VC_OVHD_EXTLT_Beacon_Switch", 100, "beaconlightcheck")--beacon light
event.Lvar("VC_OVHD_EXTLT_Wing_Switch", 100, "WingInspectLightCheck")--wing light
event.Lvar("FSLA320_pax_door1", 10000, "A320Doorcheck")--doorfl
event.Lvar("FSLA320_pax_door2", 10000, "A320Doorcheck")--doorfr
event.Lvar("FSLA320_pax_door3", 10000, "A320Doorcheck")--doorrl
event.Lvar("FSLA320_pax_door4", 10000, "A320Doorcheck")--doorrr
event.Lvar("FSLA320_pax_door5", 10000, "A320Doorcheck")--doorfr2a321
event.Lvar("FSLA320_pax_door6", 10000, "A320Doorcheck")--doorfl2a321
event.Lvar("FSLA320_pax_door7", 10000, "A320Doorcheck")--doorrr2a321
event.Lvar("FSLA320_pax_door8", 10000, "A320Doorcheck")--doorrl2a321