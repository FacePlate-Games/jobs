------------------------------------------------------------
------------------------------------------------------------
---- Author: Dylan 'Itokoyamato' Thuillier              ----
---- Lucas Decker 'FacePlate_Games'                     ----
----                                                    ----
---- Email: itokoyamato@hotmail.fr                      ----
---- lucas.d.200501@gmail.com                           ----
----                                                    ----
---- Resource: Job system with police commands and jail ----
----                                                    ----
---- File: client.lua                                   ----
------------------------------------------------------------
------------------------------------------------------------

------------------------------------------------------------
-- Global variables
------------------------------------------------------------

Jobs = setmetatable({}, Jobs);
Jobs.__index = Jobs;

Jobs.myJob = false;

Jobs.mdt = {};
Jobs.mdt.charges = {};
Jobs.mdt.bolos = {};
Jobs.mdt.plate = {};

Jobs.cuffed = false;
Jobs.jailed = false;
Jobs.jail = {};
Jobs.jail.pos = {x = 1690.0, y = 2535.0, z = 46.0};
Jobs.jail.pos_entry = {x = 1691.7, y = 2564.94, z = 46.0};
Jobs.jail.pos_release = {x = 1846.48, y = 2586.04, z = 46.0};
Jobs.jail.distance = 80.0;

------------------------------------------------------------
-- Client: head-tag functions
------------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1);

		-- MDT display
		if (#Jobs.mdt.charges > 0) then
			drawTxt(0.505, 0.890, 1.0,1.0,0.45, "~b~Charges:", 255, 255, 255, 200);
			for i = 1, #Jobs.mdt.charges do
				drawTxt(0.505, 0.890 + i*0.021, 1.0,1.0,0.45, "[" .. Jobs.mdt.charges[i].timestamp .. "] " .. Jobs.mdt.charges[i].charge .. " (by " .. Jobs.mdt.charges[i].officer_username .. " - " .. Jobs.mdt.charges[i].officer_steamID .. ")", 255, 255, 255, 200);
				if (i == #Jobs.mdt.charges) then
					drawTxt(0.505, 0.890 + (i + 2)*0.021, 1.0,1.0,0.35, "Press ~r~DEL ~w~to close the MDT", 255, 255, 255, 200);
				end
			end
			if (IsControlJustPressed(0, 178)) then
				Jobs.mdt.charges = {};
				Jobs.mdt.playerName = nil;
			end
		end
		if (#Jobs.mdt.bolos > 0) then
			drawTxt(0.505, 0.890, 1.0,1.0,0.45, "~b~Bolos:", 255, 255, 255, 200);
			for i = 1, #Jobs.mdt.bolos do
				drawTxt(0.505, 0.890 + i*0.021, 1.0,1.0,0.45, "[" .. Jobs.mdt.bolos[i].timestamp .. "] " .. Jobs.mdt.bolos[i].message .. " (by " .. Jobs.mdt.bolos[i].username .. " - " .. Jobs.mdt.bolos[i].steamID .. ")", 255, 255, 255, 200);
				if (i == #Jobs.mdt.bolos) then
					drawTxt(0.505, 0.890 + (i + 2)*0.021, 1.0,1.0,0.35, "Press ~r~DEL ~w~to close the MDT", 255, 255, 255, 200);
				end
			end
			if (IsControlJustPressed(0, 178)) then
				Jobs.mdt.bolos = {};
			end
		end
		if (Jobs.mdt.plate.number) then
			drawTxt(0.505, 0.890, 1.0,1.0,0.45, "~b~Vehicle:", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 0.021, 1.0,1.0,0.45, "Plate: " .. Jobs.mdt.plate.number, 255, 255, 255, 200);
			if (Jobs.mdt.plate.number ~= "Invalid plate number") then
				drawTxt(0.505, 0.890 + 2*0.021, 1.0,1.0,0.45, "Owner: " .. Jobs.mdt.plate.owner, 255, 255, 255, 200);
				drawTxt(0.505, 0.890 + 3*0.021, 1.0,1.0,0.45, "Stolen: " .. Jobs.mdt.plate.stolen, 255, 255, 255, 200);
				drawTxt(0.505, 0.890 + 5*0.021, 1.0,1.0,0.35, "Press ~r~DEL ~w~to close the MDT", 255, 255, 255, 200);
			else
				drawTxt(0.505, 0.890 + 3*0.021, 1.0,1.0,0.35, "Press ~r~DEL ~w~to close the MDT", 255, 255, 255, 200);
			end
			if (IsControlJustPressed(0, 178)) then
				Jobs.mdt.plate = {};
			end
		end
		if (Jobs.mdt.display) then
			drawTxt(0.505, 0.890, 1.0,1.0,0.45, "~b~MDT:", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 0.021, 1.0,1.0,0.45, "/mdt platec [plate]", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 2*0.021, 1.0,1.0,0.45, "/mdt priorsc [playerID]", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 3*0.021, 1.0,1.0,0.45, "/mdt bolo [msg]", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 4*0.021, 1.0,1.0,0.45, "/mdt bolos", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 5*0.021, 1.0,1.0,0.45, "/mdt charge [playerID] [msg]", 255, 255, 255, 200);
			drawTxt(0.505, 0.890 + 7*0.021, 1.0,1.0,0.35, "Press ~r~DEL ~w~to close the MDT", 255, 255, 255, 200);
			if (IsControlJustPressed(0, 178)) then
				Jobs.mdt.display = false;
			end
		end
		--

		-- Handcuffs system
		if (Jobs.cuffed) then
			DisableControlAction(1, 18, true);
			DisableControlAction(1, 24, true);
			DisableControlAction(1, 69, true);
			DisableControlAction(1, 92, true);
			DisableControlAction(1, 106, true);
			DisableControlAction(1, 122, true);
			DisableControlAction(1, 135, true);
			DisableControlAction(1, 142, true);
			DisableControlAction(1, 144, true);
			DisableControlAction(1, 176, true);
			DisableControlAction(1, 223, true);
			DisableControlAction(1, 229, true);
			DisableControlAction(1, 237, true);
			DisableControlAction(1, 257, true);
			DisableControlAction(1, 329, true);
			DisableControlAction(1, 80, true);
			DisableControlAction(1, 140, true);
			DisableControlAction(1, 250, true);
			DisableControlAction(1, 263, true);
			DisableControlAction(1, 310, true);

			DisableControlAction(1, 22, true);
			DisableControlAction(1, 55, true);
			DisableControlAction(1, 76, true);
			DisableControlAction(1, 102, true);
			DisableControlAction(1, 114, true);
			DisableControlAction(1, 143, true);
			DisableControlAction(1, 179, true);
			DisableControlAction(1, 193, true);
			DisableControlAction(1, 203, true);
			DisableControlAction(1, 216, true);
			DisableControlAction(1, 255, true);
			DisableControlAction(1, 298, true);
			DisableControlAction(1, 321, true);
			DisableControlAction(1, 328, true);
			DisableControlAction(1, 331, true);
			DisableControlAction(0, 63, false);
			DisableControlAction(0, 64, false);
			DisableControlAction(0, 59, false);
			DisableControlAction(0, 278, false);
			DisableControlAction(0, 279, false);
			DisableControlAction(0, 68, false);
			DisableControlAction(0, 69, false);
			DisableControlAction(0, 75, false);
			DisableControlAction(0, 76, false);
			DisableControlAction(0, 102, false);
			DisableControlAction(0, 81, false);
			DisableControlAction(0, 82, false);
			DisableControlAction(0, 83, false);
			DisableControlAction(0, 84, false);
			DisableControlAction(0, 85, false);
			DisableControlAction(0, 86, false);
			DisableControlAction(0, 106, false);
			DisableControlAction(0, 25, false);

			while not HasAnimDictLoaded('mp_arresting') do
				RequestAnimDict('mp_arresting')
				Citizen.Wait(5)
			end

			if not IsEntityPlayingAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 3) then
				TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 1.0, 0, 0, 0)
			end
		end
		--

		-- Jail system
		if (Jobs.jailed) then
			if (GetDistanceBetweenCoords(Jobs.jail.pos.x, Jobs.jail.pos.y, Jobs.jail.pos.z, GetEntityCoords(GetPlayerPed(-1)), false) >= Jobs.jail.distance) then
				SetEntityCoords(GetPlayerPed(-1), Jobs.jail.pos_entry.x, Jobs.jail.pos_entry.y, Jobs.jail.pos_entry.z, 0.0, 0.0, 0.0);
			end
		end
		--

		-- Handsup system
		if (IsControlPressed(1, 323)) then
			TaskHandsUp(GetPlayerPed(-1), 100, -1, -1, true)
		end
		--
	end
end);


------------------------------------------------------------
-- Client: Job functions
------------------------------------------------------------

function Jobs.join(job)
	Jobs.myJob = job;
	if (job == "police") then
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PUMPSHOTGUN"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_STUNGUN"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_FLASHLIGHT"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_NIGHTSTICK"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_COMBATPISTOL"), 500, true, false);
	elseif (job == "fire" or job == "ems") then
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_FIREEXTINGUISHER"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HATCHET"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_FLASHLIGHT"), 500, true, false);
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_STUNGUN"), 500, true, false);
	end
end
RegisterNetEvent("Jobs:join");
AddEventHandler("Jobs:join", Jobs.join);

function Jobs.leave()
	Jobs.myJob = false;
end
RegisterNetEvent("Jobs:leave");
AddEventHandler("Jobs:leave", Jobs.leave);


------------------------------------------------------------
-- Client: Police functions
------------------------------------------------------------

function Jobs.checkPlate(plateNumber)
	for i = 0, 256 do
		if (NetworkIsPlayerActive(i) and IsPedInAnyVehicle(GetPlayerPed(i), false)) then
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(i), false);
			local plate = string.gsub(GetVehicleNumberPlateText(vehicle), " ", "");
			if (plate == plateNumber) then
				local rand = math.random(0, 1);
				local owner = rand == 0 and getRandomName() or GetPlayerName(i);
				Jobs.mdt.plate.number = plate;
				Jobs.mdt.plate.owner = owner;
				Jobs.mdt.plate.stolen = (rand == 0 and "No" or "Yes");
				if (Jobs.mdt.plate.owner == GetPlayerName(i)) then
					Jobs.mdt.plate.stolen = "No";
				end
			end
		end
	end
	Jobs.mdt.charges = {};
	Jobs.mdt.playerName = nil;
	Jobs.mdt.bolos = {};
	Jobs.mdt.display = false;
	if (not Jobs.mdt.plate.number) then
		Jobs.mdt.plate = {number = "Invalid plate number"};
	end
end
RegisterNetEvent("Jobs:checkPlate");
AddEventHandler("Jobs:checkPlate", Jobs.checkPlate);

function Jobs.displayCharges(playerName, charges)
	Jobs.mdt.charges = charges;
	Jobs.mdt.playerName = playerName;
	Jobs.mdt.bolos = {};
	Jobs.mdt.plate = {};
	Jobs.mdt.display = false;
end
RegisterNetEvent("Jobs:displayCharges");
AddEventHandler("Jobs:displayCharges", Jobs.displayCharges);

function Jobs.displayBolos(bolos)
	Jobs.mdt.charges = {};
	Jobs.mdt.playerName = nil;
	Jobs.mdt.bolos = bolos;
	Jobs.mdt.plate = {};
	Jobs.mdt.display = false;
end
RegisterNetEvent("Jobs:displayBolos");
AddEventHandler("Jobs:displayBolos", Jobs.displayBolos);

function Jobs.displayMDT()
	Jobs.mdt.charges = {};
	Jobs.mdt.playerName = nil;
	Jobs.mdt.bolos = {};
	Jobs.mdt.plate = {};
	Jobs.mdt.display = true;
end
RegisterNetEvent("Jobs:displayMDT");
AddEventHandler("Jobs:displayMDT", Jobs.displayMDT);

function Jobs.cuff(state)
	Jobs.cuffed = state;
	if (state) then
		SetPedCanSwitchWeapon(GetPlayerPed(-1), false);
	else
		StopAnimTask(GetPlayerPed(-1), 'mp_arresting', 'idle', 1.0);
		SetPedCanSwitchWeapon(GetPlayerPed(-1), true);
	end
end
RegisterNetEvent("Jobs:cuff");
AddEventHandler("Jobs:cuff", Jobs.cuff);

function Jobs.do_jail(state, time)
	Citizen.Trace("hi");
	if (state) then
		if (GetDistanceBetweenCoords(Jobs.jail.pos.x, Jobs.jail.pos.y, Jobs.jail.pos.z, GetEntityCoords(GetPlayerPed(-1)), false) >= Jobs.jail.distance) then
			SetEntityCoords(GetPlayerPed(-1), Jobs.jail.pos_entry.x, Jobs.jail.pos_entry.y, Jobs.jail.pos_entry.z, 0.0, 0.0, 0.0);
		end
		drawNotification("You are in jail. You have " .. time .. " minutes remaining.");
	else
		SetEntityCoords(GetPlayerPed(-1), Jobs.jail.pos_release.x, Jobs.jail.pos_release.y, Jobs.jail.pos_release.z, 0.0, 0.0, 0.0);
		drawNotification("You have served your time in jail. You are free !");
	end
	Jobs.jailed = state;
end
RegisterNetEvent("Jobs:jail");
AddEventHandler("Jobs:jail", Jobs.do_jail);


------------------------------------------------------------
-- Client: Utils
------------------------------------------------------------

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
	SetTextFont(4)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(2, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, true)
end

function getRandomName()
	local firstNames = {"Marvin", "Dexter", "Hilda", "Denise", "Roxanne", "Tricia", "Emanuel", "Tyler", "Hannah", "Marsha", "Derrick", "Jeremy", "Ross", "Sheri", "Fred", "Sonia", "Bertha", "Jack", "Fredrick", "Dwayne"};
	local lastNames = {"Washington", "Watts", "Armstrong", "Hughes", "Anderson", "Santiago", "Ferguson", "Elliott", "Summers", "Brooks", "Harrington", "Evans", "Holmes", "Delgado", "Klein", "Jones", "Stevenson", "Lopez", "Mckinney", "Hill"}
	return ("" .. firstNames[math.random(1, #firstNames)] .. " " .. lastNames[math.random(1, #lastNames)]);
end
