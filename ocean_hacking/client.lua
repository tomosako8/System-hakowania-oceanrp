local Keys = {
    ["ESC"]=322,["F1"]=288,["F2"]=289,["F3"]=170,["F5"]=166,["F6"]=167,["F7"]=168,["F8"]=169,["F9"]=56,
    ["F10"]=57,["~"]=243,["1"]=157,["2"]=158,["3"]=160,["4"]=164,["5"]=165,["6"]=159,["7"]=161,["8"]=162,
    ["9"]=163,["-"]=84,["="]=83,["BACKSPACE"]=177,["TAB"]=37,["Q"]=44,["W"]=32,["E"]=38,["R"]=45,["T"]=245,
    ["Y"]=246,["U"]=303,["P"]=199,["["]=39,["]"]=40,["ENTER"]=18,["CAPS"]=137,["A"]=34,["S"]=8,["D"]=9,["F"]=23,
    ["G"]=47,["H"]=74,["K"]=311,["L"]=182,["LEFTSHIFT"]=21,["Z"]=20,["X"]=73,["C"]=26,["V"]=0,["B"]=29,["N"]=249,
    ["M"]=244,[","]=82,["."]=81,["LEFTCTRL"]=36,["LEFTALT"]=19,["SPACE"]=22,["RIGHTCTRL"]=70,["HOME"]=213,["PAGEUP"]=10,
    ["PAGEDOWN"]=11,["DELETE"]=178,["LEFT"]=174,["RIGHT"]=175,["TOP"]=27,["DOWN"]=173,["NENTER"]=201,["N4"]=108,["N5"]=60,
    ["N6"]=107,["N+"]=96,["N-"]=97,["N7"]=117,["N8"]=61,["N9"]=118 
}

local PlayerData = {}
local isHacking = false

Citizen.CreateThread(function()
    print("Loaded ocean_hacking")
end)

function DrawText3Ds(x,y,z, text)

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then

        SetTextScale(0.35, 0.35)

        SetTextFont(0)

        SetTextProportional(1)

        SetTextColour(255, 255, 255, 255)

        SetTextDropshadow(0, 0, 0, 0, 55)

        SetTextEdge(2, 0, 0, 0, 150)

        SetTextDropShadow()

        SetTextOutline()

        SetTextEntry("STRING")

        SetTextCentre(1)

        AddTextComponentString(text)

        DrawText(_x, _y)

    end

end

RegisterNetEvent('cookie_hacking:catchDoor')
AddEventHandler('cookie_hacking:catchDoor', function(doorID, time)
    print("Przechwycono "..doorID.."/"..time)
    Config.Doors[doorID].hacked = true
    Config.Doors[doorID].openTime = time
end)

RegisterNetEvent('cookie_hacking:catchresetDoor')
AddEventHandler('cookie_hacking:catchresetDoor', function(doorID)
    Config.Doors[doorID].hacked = false
    Config.Doors[doorID].openTime = 0
    print("Executed reset door")
end)

RegisterNetEvent('cookie_hacking:setHacking')
AddEventHandler('cookie_hacking:setHacking', function(bool)
    isHacking = bool
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        for i=1, #Config.Doors, 1 do
            local door = Config.Doors[i]
            if door.hacked then
                ESX.TriggerServerCallback('cookie_hacking:getCurrentTime', function(time)
                    if door.openTime < time then
                        TriggerServerEvent('cookie_hacking:resetDoor', i)
                    end
                end)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPed = GetPlayerPed(PlayerId())
        local pCoords = GetEntityCoords(playerPed)
        for i=1, #Config.Doors, 1 do
            local door = Config.Doors[i]
            local interiorIn = GetInteriorFromEntity(playerPed)
            local position, nameHash = GetInteriorLocationAndNamehash(interiorIn)
            if nameHash == door.InteriorID and not isHacking then
                local obj = GetClosestObjectOfType(pCoords.x, pCoords.y, pCoords.z, 10.0, door.DoorID, false, false, false)
                local coords = GetEntityCoords(obj)
                local distance = GetDistanceBetweenCoords(pCoords, coords, false)
                if not door.hacked then
                    if distance < 40.0 then
                        if door.startRotation == nil then
                            door.startRotation = GetEntityRotation(obj)
                            print(door.startRotation.z)
                            SetEntityRotation(obj, door.startRotation)
                        end
                        if not IsEntityPositionFrozen(obj) then
                            SetEntityRotation(obj, door.startRotation)
                        end
                        if door.startRotation ~= GetEntityRotation(obj) then
                            SetEntityRotation(obj, door.startRotation)
                        end
                        FreezeEntityPosition(obj, true)
                    end
                    if distance < 3.0 then
                        DrawText3Ds(coords.x,coords.y,coords.z, "Kliknij [E], aby rozpoczac otwieranie")
                    end
                    if distance < 1.0 then
                        if IsControlJustReleased(0, Keys['E']) and not isHacking then
                            if door.type == "fingerprint" then
                                if door.needItem ~= nil then
                                    ESX.TriggerServerCallback('cookie_hacking:isPlayerHasItem', function(bool)
                                        if bool == true then
                                            TriggerEvent('cookie_hacking:setHacking', true)
                                            TriggerEvent("utk_fingerprint:Start", 4, 6, 2, function(outcome, reason)
                                                if outcome == true then
                                                    TriggerServerEvent('cookie_hacking:updateDoor', i, 1000*60*30)
                                                    TriggerEvent('cookie_hacking:setHacking', false)
                                                elseif outcome == false then
                                                    print(" "..reason)
                                                    TriggerEvent('cookie_hacking:setHacking', false)
                                                end
                                            end)
                                        else
                                            ESX.ShowNotification("Nie posiadasz przedmiotu "..door.needItem, 3000, "success")
                                        end
                                    end, door.needItem)
                                end
                            elseif door.type == "drill" then
                                if door.needItem ~= nil then
                                    ESX.TriggerServerCallback('cookie_hacking:isPlayerHasItem', function(bool)
                                        if bool == true then
                                            TriggerEvent('cookie_hacking:setHacking', true)
                                            TriggerEvent("Drilling:Start", function(success)
                                                if success == true then
                                                    TriggerServerEvent('cookie_hacking:updateDoor', i, 1000*60*30)
                                                    TriggerEvent('cookie_hacking:setHacking', false)
                                                elseif success == false then
                                                    TriggerEvent('cookie_hacking:setHacking', false)
                                                end
                                            end)
                                        else
                                            ESX.ShowNotification("Nie posiadasz przedmiotu "..door.needItem, 3000, "success")
                                        end
                                    end, door.needItem)
                                end
                            end
                        end
                    end
                else
                    if IsEntityPositionFrozen(obj) then
                        if door.DoorID == 2121050683 then
                            SetEntityRotation(obj, 0.0, 0.0, (door.startRotation.z+100.0), true, false)
                        else
                            SetEntityRotation(obj, 0.0, 0.0, (door.startRotation.z+15.0), true, false)
                            FreezeEntityPosition(obj, false)
                        end
                    end
                end
            end
        end
    end
end)

RegisterCommand('debughacking', function(args,source,raw)
    local playerPed = GetPlayerPed(PlayerId())
    local position, nameHash = GetInteriorLocationAndNamehash(GetInteriorFromEntity(playerPed))
    print(nameHash)
end)