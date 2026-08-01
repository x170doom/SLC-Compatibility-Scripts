-- file by x170doom
-- lvar to avar script for pmdg NGXu, redirects doors, seatbelts
--dev version for integration with pmdg 777,747,DC-8
--todo:
--remake aircraftcheck to support multiple aircraft types -done
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
 initvar()
end


function initarrays()--todo: 747 stuff
 local a = {}
 a["737"] = {}
 --a["747"] = {}
 a["777"] = {}
 a["dc-8"] = {}
 a["737"]["sboffset"] = 0x649F
 a["737"]["door2"] = 0x6C15
 a["737"]["door3"] = 0x6C1E
 a["737"]["door4"] = 0x6C1F
 --a["747"]["sboffset"] = 0x6C2B
 a["777"]["sboffset"] = 0x647B
 a["777"]["door2"] = 0x65DD
 a["777"]["door3"] = 0x65DE
 a["777"]["door4"] = 0x65DF
 a["777"]["door5"] = 0x65E0
 a["777"]["door6"] = 0x65E1
 a["777"]["door7"] = 0x65E2
 a["777"]["door8"] = 0x65E3
 a["777"]["door9"] = 0x65E4
 a["777"]["door10"] = 0x65E5
end

function initvar()
	aircraft_typelist = {
		["PMDG 737"] = "737",
		--["PMDG 747"] = "747",
		["PMDG 777"] = "777",
		--["PMDG DC-8"] = "DC-8"
	}
	doorlayout = {
		"737" = function(offset,value)
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
		end,
		--"747" = function(offset,value)
		--end
		"777" = function(offset,value)
			if offset == 0x65DD then
				if value == 0 then
					ipc.setbitsUW("3367", 2)
				else
					ipc.clearbitsUW("3367", 2)
				end
			elseif offset == 0x65DE then
				if value == 0 then
					ipc.setbitsUW("3367", 4)
				else
					ipc.clearbitsUW("3367", 4)
				end
			elseif offset == 0x65DF then
				if value == 0 then
					ipc.setbitsUW("3367", 8)
				else
					ipc.clearbitsUW("3367", 8)
				end
			elseif offset == 0x65E4 then
				local fivedoor = true
				if value == 0 then
					ipc.setbitsUW("3367", 64)
				else
					ipc.clearbitsUW("3367",64)
				end
			elseif offset == 0x65E5 then
				local fivedoor = true
				if value == 0 then
					ipc.setbitsUW("3367", 128)
				else
					ipc.clearbitsUW("3367",128)
				end
			elseif offset == 0x65E0 then
				if value == 0 then
					ipc.setbitsUW("3367", 16)
				else
					ipc.clearbitsUW("3367",16)
				end
			elseif offset == 0x65E1 then
				if value == 0 then
					ipc.setbitsUW("3367", 32)
				else
					ipc.clearbitsUW("3367",32)
				end
			elseif offset == 0x65E2 and not fivedoor then
				if value == 0 then
					ipc.setbitsUW("3367", 64)
				else
					ipc.clearbitsUW("3367",64)
				end
			elseif offset == 0x65E3 and not fivedoor then
				if value == 0 then
					ipc.setbitsUW("3367", 128)
				else
					ipc.clearbitsUW("3367",128)
				end
			else
				debugfunction("doorcheck called without valid offset")
			end
		end
	}
end

function aircraftcheck()
 aircrafttype = ipc.readSTR("3D00", 8)
	local ac_type = ipc.readSTR("3D00",8)
	aircraft_type = aircraft_typelist[ac_type]
	if aircraft_type == "747" or aircraft_type == "777" then
		largedoorcount = true
	elseif not aircraft_type then
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
			seatbeltstate = "off"
			event.cancel(seatbeltcheck)
			seatbeltsetstate(false)
		elseif value == 1 then
			seatbeltstate = "Auto"
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
			seatbeltstate = "on" 
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
-- function doorcheck (offset,value)
	-- if ipc.readUB(0x655C) > 0 then
		-- if offset == 0x6C15 then
			-- if value == 1 then
				-- ipc.setbitsUW("3367", 2)
			-- else
				-- ipc.clearbitsUW("3367", 2)
			-- end
		-- elseif offset == 0x6C1E then
			-- if value == 1 then
				-- ipc.setbitsUW("3367", 4)
			-- else
				-- ipc.clearbitsUW("3367", 4)
			-- end
		-- elseif offset == 0x6C1F then
			-- if value == 1 then
				-- ipc.setbitsUW("3367", 8)
			-- else
				-- ipc.clearbitsUW("3367", 8)
			-- end
		-- else
			-- debugfunction("doorcheck called without valid offset")
		-- end
	-- else
		-- return
	-- end
-- end
--old doorcheck method for the 737 only, no longer used but preserved for refference
function doorcheck (offset,value)--much cleaner
	if aircraft_type == "737" and ipc.readUB(0x655C) > 0 or aircraft_type ~= "737" then
		doorlayout [aircrafttype] (offset,value)
	else
		debugfunction("door state cannot be determined due to invalid lights test switch position, offset ignored for now")
	end

function debugfunction (errtext)
	if debugmode then
		ipc.log(errtext)
		return
	else
		return
	end
end
--new debug mode goes here
--function debugfunction (errtext,ecode)
--	if debugmode then
--		debugmenu
--stuff
function exitfunction()
	a = nil
	ipc.exit()
end--dont know if this is needed. but here anyway just in case

initmain()
initevents()

function initevents
	event.offset(a[aircraft_type]["sboffset"], "UB", "seatbeltcheck")--seatbelt light
	event.offset(0x0366, "UB", "seatbeltcheck")--aircraftonground
	event.offset(a[aircraft_type]["door2"], "UB", "doorcheck")--door2	
	event.offset(a[aircraft_type]["door3"], "UB", "doorcheck")--door3
	event.offset(a[aircraft_type]["door4"], "UB", "doorcheck")--door4
	--these should run regardless of aircraft
	if largedoorcount then
		event.offset(a[aircraft_type]["door5"], "UB", "doorcheck")--door5
		event.offset(a[aircraft_type]["door6"], "UB", "doorcheck")--door6
		event.offset(a[aircraft_type]["door7"], "UB", "doorcheck")--door7
		event.offset(a[aircraft_type]["door8"], "UB", "doorcheck")--door8
		event.offset(a[aircraft_type]["door9"], "UB", "doorcheck")--door9
		event.offset(a[aircraft_type]["door10"], "UB", "doorcheck")--door10
	end
end
--only run on aircraft with 5+ doors
-- these need adding to specialised function, first 3 should allways start and use the array for variables. the rest should only be called if enough doors are present

