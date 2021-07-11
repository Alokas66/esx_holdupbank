local holdingup = false
local bank = ""
local blipRobbery = nil
arp = nil


Citizen.CreateThread(function()
	while arp == nil do
		TriggerEvent('esx:getSharedObject', function(obj) arp = obj end)
		Citizen.Wait(0)
	end
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	if outline then SetTextOutline() end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText2(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_holdupbank:currentlyrobbing')
AddEventHandler('esx_holdupbank:currentlyrobbing', function(robb)
	holdingup = true
	bank = robb
end)

RegisterNetEvent('esx_holdupbank:killblip')
AddEventHandler('esx_holdupbank:killblip', function()
    RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_holdupbank:lopetaanimaatio')
AddEventHandler('esx_holdupbank:lopetaanimaatio', function()
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('esx_holdupbank:setblip')
AddEventHandler('esx_holdupbank:setblip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
	SetBlipSprite(blipRobbery , 487)
	SetBlipScale(blipRobbery , 2.0)
	SetBlipDisplay(blipRobbery, 4)
	SetBlipColour(blipRobbery, 0)
	SetBlipFlashes(blipRobbery, true)

	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(('Pankkiryöstö'))
    EndTextCommandSetBlipName(blipRobbery)
end)

RegisterNetEvent('esx_holdupbank:toofar')
AddEventHandler('esx_holdupbank:toofar', function()
	holdingup = false
	arp.ShowNotification('Ryöstö keskeytyi!')
	robbingName = ""
	incircle = false
end)


RegisterNetEvent('esx_holdupbank:robberycomplete')
AddEventHandler('esx_holdupbank:robberycomplete', function(award)
	holdingup = false
	arp.ShowNotification('~r~Ryöstö onnistui~g~ '..award.."~s~ €")
	bank = ""
	incircle = false
end)



RegisterNetEvent('esx_holdupbank:starttimer')
AddEventHandler('esx_holdupbank:starttimer', function()
	timer = (Config.secondsRemaining)
	Citizen.CreateThread(function()
		while timer > 0 do
			Citizen.Wait(0)
			Citizen.Wait(1000)
			if (timer > 0) then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if holdingup then
				drawTxt(0.66, 1.4, 1.0,1.0,0.4, ('pankkiryöstö: ~r~'..timer.."~s~ sekunttia jäljellä"), 255, 255, 255, 255)
			else
				Citizen.Wait(1000)
			end
		end
	end)
end)



Citizen.CreateThread(function()
	for k,v in pairs(Banks) do
		local ve = v.position

		local blip = AddBlipForCoord(ve.x, ve.y, ve.z)
		SetBlipSprite(blip, 255)
		SetBlipColour(blip, 2)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Pankkiryöstö')
		EndTextCommandSetBlipName(blip)
	end
end)
incircle = false



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local pos = GetEntityCoords(PlayerPedId(), true)
		local liianlaheljatkajo = false
		for k,v in pairs(Banks)do
			local pos2 = v.position

			if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 15.0 then
				liianlaheljatkajo = true
				if not holdingup then
					DrawMarker(1, v.position.x, v.position.y, v.position.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 1555, 0, 0,255, 0, 0, 0,0)

					if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 1.0 then
						if not incirle then
							arp.ShowHelpNotification('Paina ~INPUT_CONTEXT~ ~o~ryöstääksesi~s~ pankki!')
						end

						incircle = true
						if IsControlJustReleased(0, 38) then
							TriggerServerEvent('esx_holdupbank:rob', k)
						end

					elseif(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 1.0)then
						incircle = false
					end
				end
			end
		end
		if not liianlaheljatkajo then
			Citizen.Wait(500)
		end
		if holdingup then

			local pos2 = Banks[bank].position
			
			arp.ShowHelpNotification('Paina ~INPUT_VEH_DUCK~ keskeyttääksesi ryöstö')
			
			if Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > Config.MaxDistance then
			
				TriggerServerEvent('esx_holdupbank:toofar')
				
			elseif IsControlPressed(0, 73) then
			
				TriggerServerEvent('esx_holdupbank:toofar')
				
				TriggerEvent('esx_holdupbank:lopetaanimaatio')
				
			elseif IsPedDeadOrDying(PlayerPedId()) then
			
				TriggerServerEvent('esx_holdupbank:toofar')
				
				TriggerEvent('esx_holdupbank:lopetaanimaatio')
				

			end
		end
	end
end)





RegisterNetEvent('esx_JOKUIHMEPORAJOHONKINPANKKIRYOSTOON:alotaporaus')

AddEventHandler('esx_JOKUIHMEPORAJOHONKINPANKKIRYOSTOON:alotaporaus', function(source)

	Animation()

end)



function Animation()

	local playerPed = GetPlayerPed(-1)

	

	Citizen.CreateThread(function()

		ClearPedSecondaryTask(playerPed)

		SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)

		Citizen.Wait(10) 

		if IsPedUsingAnyScenario(PlayerPedId()) == false then

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CONST_DRILL", 0, false)

		end

	end)

end