-- file by x170doom
-- lvar to avar script for pmdg NGXu, redirects doors, seatbelts
--dev version for integration with pmdg 777,747,DC-8
--todo:
--remake aircraftcheck to support multiple aircraft types
--build event library calls into individual functions for each aircraft type
--rewrite/new functions for other aircraft types (find best method with least overhead)
--maybe some additional feedback in debugmode
--fallbacks in situations where sim is unsure
--fix for issue #6 [no longer required. issue resolved by slc 1.6.6.9]

function initmain()
 local debugmode = true
 local seatbeltstate = "not yet set"
 local aircraftonground = true
 initarrays()
 aircraftcheck()
 --initvar()
end

function initarrays()--todo: everything
 a = {}
 a["737"] = {}
 a["747"] = {}
 a["777"] = {}
 a["dc-8"] = {}
 a["737"]["sboffset"] = 0x649F
 a["737"]["sboffset_type"] = "UB"
 a["747"]["sboffset"] = 0x6C2B
 a["747"]["sboffset_type"] = "UB"
end

-- function initvar()
	-- do stuff and things
-- end

function aircraftcheck()
 aircrafttype = ipc.readSTR("3D00", 8)
	if aircrafttype == "PMDG 737" then
		aircraft_type = "737"
		return
	elseif aircrafttype == "PMDG 747" then
		aircraft_type = "747"
		return
	-- elseif aircrafttype == "PMDG 777" then
		-- boilerplate
	-- elseif aircrafttype == "dc8 name goes here" then
		-- boilerplate
	else
		debugfunction("PMDG aircraft not detected... exiting")
		exitfunction()
	end
end
function autoseatbeltmaintain ()
	if seatbeltstate == "Auto" then
		if ipc.readSD(0x3324) < 10000 then
			seatbeltsetstate(true)
		elseif ipc.readSD(0x3324) > 10000 then
			seatbeltstate(false)
		else
			debugfunction("auto state init fail, altitude not defined")
		end
	else
		return
	end
end

function seatbeltcheck (offset, value)--initial implementation of array based offset logic, needs investigating if auto mode logic works with other types than 737
	if offset == a[aircraft_type]["sboffset"] then
		if value == 0 then
			local seatbeltstate = "off"
			event.cancel(seatbeltcheck)
			seatbeltsetstate(false)
		elseif value == 1 then
			local seatbeltstate = "Auto"
			if isaircraftonground == false then
				if ipc.readSD(0x3324) < 10000 then
					seatbeltsetstate(true)
				elseif ipc.readSD(0x3324) > 10000 then
					seatbeltstate(false)
				else
					debugfunction("auto state init fail, altitude not defined")
				end
			event.timer(1000, "autoseatbeltmaintain")
			else
				seatbeltsetstate(true)
			end
		elseif value == 2 then
			local seatbeltstate = "on" 
			event.cancel(seatbeltcheck)
			seatbeltsetstate(true)
		else
			debugfunction("seatbelt offset outside expected range")
		end
	elseif offset == 0x0366 then
		if value == 1 then
			local isaircraftonground = true
		else
			local isaircraftonground = false
		end
	else
		debugfunction("offset not valid for seatbelt check")
	end
end

function seatbeltsetstate (changeto)
	if changeto and not seatbelts then
		seatbelts = true
		ipc.setbitsUW("341D", 1)
	elseif not changeto and seatbelts then
		seatbelts = false
		ipc.clearbitsUW("341D", 1)
	else
		debugfunction("state change called to same state")
	end
end
function doorcheck (offset,value)
	if ipc.readUB(0x655C) > 0 then
		if offset == 0x6C15 then
			if value == 1 then
				ipc.setbitsUW("3367", 2)
			else
				ipc.clearbitsUW("3367", 2)
			end
		elseif offset == 0x6C1E then
			if value == 1 then
				ipc.setbitsUW("3367", 4)
			else
				ipc.clearbitsUW("3367", 4)
			end
		elseif offset == 0x6C1F then
			if value == 1 then
				ipc.setbitsUW("3367", 8)
			else
				ipc.clearbitsUW("3367", 8)
			end
		else
			debugfunction("doorcheck called without valid offset")
		end
	else
		return
	end
end

function debugfunction (errtext)
	if debugmode then
		ipc.log(errtext)
		return
	else
		return
	end
end

function exitfunction()
	a = nil
	ipc.exit()
end

initmain()
event.offset(a[aircraft_type]["sboffset"], a[aircraft_type]["sboffset_type"], "seatbeltcheck")--seatbelt light
event.offset(0x0366, "UB", "seatbeltcheck")--aircraftonground
event.offset(0x6C15, "UB", "doorcheck")--doors
event.offset(0x6C1E, "UB", "doorcheck")--doors
event.offset(0x6C1F, "UB", "doorcheck")--doors


