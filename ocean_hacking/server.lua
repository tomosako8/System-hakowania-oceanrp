ESX = nil

TriggerEvent('exilerp:getSharedObject', function(obj)
	ESX = obj
	Config.check()
end)

ESX.RegisterServerCallback('cookie_hacking:getCurrentTime', function(src, cb)
	cb(os.time())
end)

ESX.RegisterServerCallback('cookie_hacking:isPlayerHasItem', function(src, cb, itemName)
	local xPlayer = ESX.GetPlayerFromId(src)
	
	local inventory = xPlayer.getInventory()
	for k,v in pairs(inventory) do
		if v.name == itemName then
			cb(true)
		end
	end
	cb(false)
end)

RegisterServerEvent('cookie_hacking:resetDoor')
AddEventHandler('cookie_hacking:resetDoor', function(doorID)
	local xPlayers = ESX.GetExtendedPlayers()
	for _,xPlayer in pairs(xPlayers) do
		TriggerClientEvent('cookie_hacking:catchresetDoor', xPlayer.source, doorID)
	end
end)

RegisterServerEvent('cookie_hacking:updateDoor')
AddEventHandler('cookie_hacking:updateDoor', function(doorID, time)
	local xPlayers = ESX.GetExtendedPlayers()
	for _,xPlayer in pairs(xPlayers) do

		TriggerClientEvent('cookie_hacking:catchDoor', xPlayer.source, doorID, (os.time()+time))
	end
end)