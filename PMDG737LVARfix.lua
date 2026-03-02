-- file by x170doom
-- lvar to avar script for pmdg NGXu, redirects doors, seatbelts

debugmode = false
aircrafttype = ipc.readSTR("3D00", 8)
seatbeltstate = "not yet set"
aircraftonground = true

function aircraftcheck()
	if aircrafttype =="PMDG 737" and not checkran then
		local checkran = true
		return
	elseif checkran then
		return
	else
		debugfunction("PMDG 737 not detected... exiting")
		ipc.exit()
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
	if offset == 0x649F then
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
aircraftcheck()
event.offset(0x649F, "UB", "seatbeltcheck")--seatbelt light
event.offset(0x0366, "UB", "seatbeltcheck")--aircraftonground
event.offset(0x6C15, "UB", "doorcheck")--doors
event.offset(0x6C1E, "UB", "doorcheck")--doors
event.offset(0x6C1F, "UB", "doorcheck")--doors


