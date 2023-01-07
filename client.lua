function LocalPed()
	return GetPlayerPed(-1)
end

local visits = 1
local l = 0
local area = 0
local onjob = false

local destination = {
{ x = -11, y = -303, z = 45,},
}

function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

RegisterNetEvent("yesdelivery")
AddEventHandler("yesdelivery", function()
    SpawnVan()
	SetNotificationTextEntry("STRING");
	AddTextComponentString("~g~Have a good route" );
	DrawNotification(false, true);
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		DrawMarker(1, 64.247, 118.531, 79.1050 - 1, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 255, 165, 0,165, 0, 0, 0,0) 
		if GetDistanceBetweenCoords(64.247, 118.531, 79.1050, GetEntityCoords(LocalPed())) < 2.0 then
			basiccheck()
		end
		if onjob == true then 
			if GetDistanceBetweenCoords(destination.x,destination.y,destination.z, GetEntityCoords(GetPlayerPed(-1))) < 3.0 then
				if IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("boxville2"))  then
					drawTxt('Press ~g~E~s~ to deliver your ~b~ package', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
					if (IsControlJustReleased(1, 38)) then
						deliverysucces()
					end
				end
			end
		end
	end
end)


function basiccheck()
	if onjob == false then 
		if (IsInVehicle()) then
			if IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("boxville2")) then
				drawTxt('Press ~g~E~s~ to restock your~b~ van', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
				if (IsControlJustReleased(1, 38)) then
					TriggerEvent('yesdelivery')
				end
			else
				drawTxt('Press ~g~E~s~ to get your~b~ van', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
				if (IsControlJustReleased(1, 38)) then
					TriggerEvent('yesdelivery')
				end
			end	
		else
			drawTxt('Press ~g~E~s~ to get your~b~ van', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
			if (IsControlJustReleased(1, 38)) then
				TriggerEvent('yesdelivery')
			end
		end
	else
		drawTxt('Press ~g~H~s~ to cancel the last job', 2, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
		if (IsControlJustReleased(1, 74)) then
			onjob = false
			RemoveBlip(deliveryblip)
			SetWaypointOff()
			DeleteVehicle()
			visits = 1
		end
	end
end

function IsInVehicle()
 local ply = GetPlayerPed(-1)
 if IsPedSittingInAnyVehicle(ply) then
 return true
 else
 return false
 end
end

function startjob()
	TriggerEvent("mt:missiontext", "Drive to the marked ~g~destination~w~.", 10000)
	onjob = true
deliveryblip = (AddBlipForCoord(destination.x,destination.y,destination.z))
SetBlipSprite(deliveryblip, 280)
SetNewWaypoint(destination.x,destination.y)
end

function SpawnVan()
	if (IsInVehicle()) then
		if IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("boxville2")) then
			startjob()
		end
	else
	Citizen.Wait(0)
	local myPed = GetPlayerPed(-1)
	local player = PlayerId()
	local vehicle = GetHashKey('boxville2')

	RequestModel(vehicle)

	while not HasModelLoaded(vehicle) do
		Wait(1)
	end

	local plate = math.random(100, 900)
	local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0, 5.0, 0)
	local spawned_car = CreateVehicle(vehicle, coords, 180, true, false)
	SetVehicleOnGroundProperly(spawned_car)
	SetVehicleNumberPlateText(spawned_car, "DELIVER"..plate)
	SetPedIntoVehicle(myPed, spawned_car, - 1)
	SetModelAsNoLongerNeeded(vehicle)
	netMissionEntity(1)
	Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
	startjob()
	end
end

function deliverysucces()
TriggerServerEvent('delivery:success',destination[l])
						if visits == 3 then 
							RemoveBlip(deliveryblip)
							onjob = false
							visits = 1
							TriggerEvent("mt:missiontext", "you can return to the ~g~depot~w~ to pick up more packages.", 10000)
						else
							RemoveBlip(deliveryblip)
							startjob()
							visits = visits + 1
						end
end


local blips = {
	{title="Depot", colour=18, id=411, x=63.463, y=126.00, z=79.1902},
}

Citizen.CreateThread(function()
    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.9)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)