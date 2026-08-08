-- file by x170doom
-- lvar to avar script for pmdg NGXu, redirects doors, seatbelts
--dev version for integration with pmdg 777,747,DC-8
--todo:
--remake aircraftcheck to support multiple aircraft types -done
--build event library calls into individual functions for each aircraft type -done...ish
--rewrite/new functions for other aircraft types (find best method with least overhead)- like that was ever going to happen, its as clean as i can get it
--maybe some additional feedback in debugmode
--fallbacks in situations where sim is unsure
--fix for issue #6 -[no longer required. issue resolved by slc 1.6.6.9]
--see if i can make the 747 and 777 work with slc door arm/disarm behaviour (and cabin ready if possible)

function initmain()
	local debugmode = true
	local seatbeltstate = "not yet set"
	local aircraftonground = true
	initarrays()
	aircraftcheck()
	initarray2()
end


function initarrays()--todo: 747 stuff
	aircraftoffset = {}
	aircraftoffset["737"] = {}
	--aircraftoffset["747"] = {}
	aircraftoffset["777"] = {} 
	aircraftoffset["dc-8"] = {}
	aircraftoffset["737"]["sboffset"] = 0x649F
	aircraftoffset["737"]["door2"] = 0x6C15
	aircraftoffset["737"]["door3"] = 0x6C1E
	aircraftoffset["737"]["door4"] = 0x6C1F
	--aircraftoffset["747"]["sboffset"] = 0x6C2B
	aircraftoffset["777"]["sboffset"] = 0x647B
	aircraftoffset["777"]["taxioffset"] = 0x648E
	aircraftoffset["777"]["door2"] = 0x65DD
	aircraftoffset["777"]["door3"] = 0x65DE
	aircraftoffset["777"]["door4"] = 0x65DC--technically door 1 but the 777 door logic is cursed, see below in initarray2 for why
	aircraftoffset["777"]["door5"] = 0x65E0
	aircraftoffset["777"]["door6"] = 0x65E1
	aircraftoffset["777"]["door7"] = 0x65E2
	aircraftoffset["777"]["door8"] = 0x65E3
	aircraftoffset["777"]["door9"] = 0x65E4
	aircraftoffset["777"]["door10"] = 0x65E5
	-----------------------------------above this line: aircraft offsets from sdk, below this line: other shit
	aircraft_typelist = {
		["PMDG 737"] = "737",
		--["PMDG 747"] = "747",
		["PMDG 777"] = "777",
		--["PMDG DC-8"] = "DC-8"
	}
end

function initarray2()-- function based arrays go here
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
			elseif offset == 0x65DC then-- door 2l is technically exit 1 in sim. and it checks correctly. so to fix this 1L and 2L are treated as opposits, so on your layout door 2l should be door 0 and door 1l should be door 3. because doing this the easy way was never an option apparently
				if value == 0 then
					ipc.setbitsUW("3367", 8)
				else
					ipc.clearbitsUW("3367", 8)
				end
			elseif offset == 0x65E4 and fivedoor then
				local fivedoor = true
				if value == 0 then
					ipc.setbitsUW("3367", 64)
				else
					ipc.clearbitsUW("3367",64)
				end
			elseif offset == 0x65E5 and fivedoor then
				local fivedoor = true
				if value == 0 then
					ipc.setbitsUW("3367", 128)
				else
					ipc.clearbitsUW("3367",128)
				end
			elseif offset == 0x65E0 and not fivedoor then
				if value == 0 then
					ipc.setbitsUW("3367", 16)
				else
					ipc.clearbitsUW("3367",16)
				end
			elseif offset == 0x65E1 and not fivedoor then
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
			elseif offset == 0x65E2 and fivedoor then
				if value == 0 then
					ipc.setbitsUW("3367", 16)
				else
					ipc.clearbitsUW("3367",16)
				end
			elseif offset == 0x65E3 and fivedoor then
				if value == 0 then
					ipc.setbitsUW("3367", 32)
				else
					ipc.clearbitsUW("3367",32)
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

function seatbeltcheck (offset, value)
	if aircraft_type ~= "777" then
		if offset == aircraftoffset[aircraft_type]["sboffset"] then
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
	else
		debugfunction("777 actually uses the seatbelt avar correctly, ignoring")
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

function taxistate (offset,value)-- the random only light on the t7 that doesnt set its avar correctly
	if value then
		ipc.setbitsUW("0D0C", 8)
	elseif not value then
		ipc.clearbitsUW("0D0C", 8)
	else
		debugfunction("taxi light value was neither true or false...WTF?!?")
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
	event.offset(aircraftoffset[aircraft_type]["sboffset"], "UB", "seatbeltcheck")--seatbelt light
	event.offset(0x0366, "UB", "seatbeltcheck")--aircraftonground
	event.offset(aircraftoffset[aircraft_type]["door2"], "UB", "doorcheck")--door2	
	event.offset(aircraftoffset[aircraft_type]["door3"], "UB", "doorcheck")--door3
	event.offset(aircraftoffset[aircraft_type]["door4"], "UB", "doorcheck")--door4
	if aircraft_type = "777" then --ofc the bloody t7 doesnt set the taxi AVAR, that would just make my life too easy wouldn't it
		event.offset(aircraftoffset[aircraft_type]["taxioffset"], "UB", "taxistate")
	end
	--these should run regardless of aircraft
	if largedoorcount then
		event.offset(aircraftoffset[aircraft_type]["door5"], "UB", "doorcheck")--door5
		event.offset(aircraftoffset[aircraft_type]["door6"], "UB", "doorcheck")--door6
		event.offset(aircraftoffset[aircraft_type]["door7"], "UB", "doorcheck")--door7
		event.offset(aircraftoffset[aircraft_type]["door8"], "UB", "doorcheck")--door8
		event.offset(aircraftoffset[aircraft_type]["door9"], "UB", "doorcheck")--door9
		event.offset(aircraftoffset[aircraft_type]["door10"], "UB", "doorcheck")--door10
	end
end
--only run on aircraft with 5+ doors