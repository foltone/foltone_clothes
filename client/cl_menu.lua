Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

local stylevide = { BackgroundColor={255, 255, 255, 0}, Line = {250, 250 ,250, 250}, Line2 = {250, 250 ,250, 250}}

local tshirt_1c, torso_1c, torso_2c, pants_1c, tshirt_2c, pants_2c, shoes_1c, shoes_2c, plyClothe = {}, {}, {}, {}, {}, {}, {}, {}, {}
local decals_1c, decals_2c, arms_1c, arms_2c, bags_1c, bags_2c, chain_1c, chain_2c, PlayerClothe  = {}, {}, {}, {}, {}, {}, {}, {}, {}
local firstSpawn, debug = true, false
local index = { tshirt_1 = 1,  tshirt_2 = 1, torso_1  = 1, torso_2  = 1, decals_1 = 1, decals_2 = 1, arms = 1, chain_1 = 1, chain_2 = 1, arms_2 = 0, bags_1 = 1, bags_2 = 1, pants_1  = 1, pants_2  = 1, shoes_1  = 1, shoes_2  = 1, utils = 1}

local function GetPlayers()
    local players = {}
    for _,player in ipairs(GetActivePlayers()) do
    local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end
  
local function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
    local target = GetPlayerPed(value)
    if(target ~= ply) then
        local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
        local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
        if(closestDistance == -1 or closestDistance > distance) then
            closestPlayer = value
            closestDistance = distance
        end
        end
    end
    return closestPlayer, closestDistance
end

function OpenKeyboard()
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 100)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Citizen.Wait(1)
    end
    if (GetOnscreenKeyboardResult()) then
        result = GetOnscreenKeyboardResult()
        if result == nil or result == '' then
            ESX.ShowNotification("Valeur incorrect !.")
        else 
            return result  
        end     
    end 
end

RegisterNetEvent('foltone_vetement:loadPlayerClothe')
AddEventHandler('foltone_vetement:loadPlayerClothe', function(data)
    PlayerClothe = data
end)

RegisterNetEvent('foltone_vetement:Notification')
AddEventHandler('foltone_vetement:Notification', function(text)
    ESX.ShowNotification(""..text.."")
end)

RegisterNetEvent('foltone_vetement:refreshClothe')
AddEventHandler('foltone_vetement:refreshClothe', function(data)
    PlayerClothe = data
end)

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerServerEvent('foltone_vetement:loadClothe')
end)


local utils = {
    'Mettre',
    'Jeter',
    'Donner',
   }

function GetComponent()
    local tshirt_1Comp = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
    local torso_1Comp  = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
    local decals_1Comp = GetNumberOfPedDrawableVariations(PlayerPedId(), 10)
    local chain_1Comp  = GetNumberOfPedDrawableVariations(PlayerPedId(), 7)
    local arms_1Comp   = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
    local pants_1Comp  = GetNumberOfPedDrawableVariations(PlayerPedId(), 4) 
    local shoes_1Comp  = GetNumberOfPedDrawableVariations(PlayerPedId(), 6) 
    local bags_1Comp   = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
    for i=0, tshirt_1Comp, 1 do
        table.insert(tshirt_1c, i)
    end
    for i=0, torso_1Comp, 1 do
        table.insert(torso_1c, i)
    end
    for i=0, decals_1Comp, 1 do
        table.insert(decals_1c, i)
    end
    for i=0, chain_1Comp, 1 do
        table.insert(chain_1c, i)
    end
    for i=0, arms_1Comp, 1 do
    table.insert(arms_1c, i)
    end
    for i=0, pants_1Comp, 1 do
        table.insert(pants_1c, i)
    end 
    for i=0, shoes_1Comp, 1 do
    table.insert(shoes_1c, i)
    end
    for i=0, bags_1Comp, 1 do
        table.insert(bags_1c, i)
    end
end  

local MenuVetement = RageUI.CreateMenu("Vetement", 'Vetement');
local magasin = RageUI.CreateSubMenu(MenuVetement, "Vetement", "Vetement")
local tenu = RageUI.CreateSubMenu(MenuVetement, "Tenu", "Tenu")
local open = false
function MenuVetement.Closed()
	open = false
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

function RageUI.PoolMenus:Foltone()
	MenuVetement:IsVisible(function(Items)
        Items:AddButton("Magasin de vetement", nil, { IsDisabled = false }, function(onSelected)
            FreezeEntityPosition(PlayerPedId(), false)
            if (onSelected) then
                FreezeEntityPosition(PlayerPedId(), true)
            end
        end, magasin)
        Items:AddButton("Tenu", nil, { IsDisabled = false }, function(onSelected)
            FreezeEntityPosition(PlayerPedId(), false)
        end, tenu)
	end, function(Panels)
	end)

    magasin:IsVisible(function(Items)
        Items:AddButton("Payer", nil, { IsDisabled = false, RightLabel = "~g~" .. FoltoneVetement.Prix .. "$" }, function(onSelected)
            if (onSelected) then
                TriggerServerEvent('foltone_vetement:achetervetement', FoltoneVetement.Prix)
            end
        end)
        ------------------- T-shirt -------------------
        Items:AddList("T-shirt n°1 :", tshirt_1c, index.tshirt_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.tshirt_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 8, Index-1, ptshirt_2 or 0, 2)
                local tshirt_2Comp = 1 
                tshirt_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 8, Index-1)
                tshirt_2c = {}
                if debug then 
                end 
                for i=0, tshirt_2Comp, 1 do
                table.insert(tshirt_2c,i)
                end
                ptshirt_1 = Index-1
            end
        end)
        Items:AddList("T-shirt n°2 :", tshirt_2c, index.tshirt_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.tshirt_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 8, ptshirt_1, Index-1, 2)
                ptshirt_2 = Index-1
            end
        end)
        ------------------- Torse -------------------
        Items:AddList("Torse n°1 :", torso_1c, index.torso_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.torso_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 11, Index-1, ptorso_2 or 0, 2)
                local torso_2Comp = 1 
                torso_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 11, Index-1)
                torso_2c = {}
                if debug then 
                end 
                for i=0, torso_2Comp, 1 do
                table.insert(torso_2c,i)
                end
                ptorso_1 = Index-1
            end
        end)
        Items:AddList("Torse n°2 :", torso_2c, index.torso_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.torso_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 11, ptorso_1, Index-1, 2)
                ptorso_2 = Index-1
            end
        end)
        ------------------- Calque -------------------
        Items:AddList("Calque n°1 :", decals_1c, index.decals_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.decals_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 10, Index-1, 0, 2)
                local decals_2Comp = 1 
                decals_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 10, Index-1)
                decals_2c = {}
                if debug then 
                end 
                for i=0, decals_2Comp, 1 do
                table.insert(decals_2c,i)
                end
                pdecals_1 = Index-1
            end
        end)
        Items:AddList("Calque n°2 :", decals_2c, index.decals_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.decals_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 10, pdecals_1, Index-1, 2)
                pdecals_2 = Index-1
            end
        end)
        ------------------- Bras -------------------
        Items:AddList("Bras n°1 :", arms_1c, index.arms, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.arms = Index 
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 3, Index-1, parms_2 or 0, 2)

                local arms_2Comp = 1 
                arms_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 3, Index-1)
                arms_2c = {}
    
                if debug then 
                end  
    
                for i=0, arms_2Comp, 1 do
                  table.insert(arms_2c, i)
                end
    
                parms_1 = Index-1
            end
        end)
        Items:AddList("Bras n°2 :", arms_2c, index.arms_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.arms_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 3, parms_1, Index-1, 2)
                arms_2 = Index-1
            end
        end)
        ------------------- Chaine -------------------
        Items:AddList("Chaine n°1 :", chain_1c, index.chain_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.chain_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 7, Index-1, pchain_2 or 0, 2)
                local chain_2Comp = 1 
                chain_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 7, Index-1)
                chain_2c = {}
                if debug then 
                end 
                for i=0, chain_2Comp, 1 do
                table.insert(chain_2c,i)
                end
                pchain_1 = Index-1
            end
        end)
        Items:AddList("Chaine n°2 :", chain_2c, index.chain_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.chain_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 7, pchain_1, Index-1, 2)
                pchain_2 = Index-1
            end
        end)
        ------------------- Pantalon -------------------
        Items:AddList("Pantalon n°1 :", pants_1c, index.pants_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.pants_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 4, Index-1, ppants_2 or 0, 2)
                local pants_2Comp = 1 
                pants_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 4, Index-1)
                pants_2c = {}
                if debug then 
                end 
                for i=0, pants_2Comp, 1 do
                table.insert(pants_2c,i)
                end
                ppants_1 = Index-1
            end
        end)
        Items:AddList("Pantalon n°2 :", pants_2c, index.pants_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.pants_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 4, ppants_1, Index-1, 2)
                ppants_2 = Index-1
            end
        end)
        ------------------- Chaussure -------------------
        Items:AddList("Chaussure n°1 :", shoes_1c, index.shoes_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.shoes_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 6, Index-1, pshoes_2 or 0, 2)
                local shoes_2Comp = 1 
                shoes_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 6, Index-1)
                shoes_2c = {}
                if debug then 
                end 
                for i=0, shoes_2Comp, 1 do
                table.insert(shoes_2c,i)
                end
                pshoes_1 = Index-1
            end
        end)
        Items:AddList("Chaussure n°2 :", shoes_2c, index.shoes_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.shoes_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 6, pshoes_1, Index-1, 2)
                pshoes_2 = Index-1
            end
        end)
        ------------------- Sac -------------------
        Items:AddList("Sac n°1 :", bags_1c, index.bags_1, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.bags_1 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 5, Index-1, pbags_2 or 0, 2)
                local bags_2Comp = 1 
                bags_2Comp = GetNumberOfPedTextureVariations(PlayerPedId(), 5, Index-1)
                bags_2c = {}
                if debug then 
                end 
                for i=0, bags_2Comp, 1 do
                table.insert(bags_2c,i)
                end
                pbags_1 = Index-1
            end
        end)
        Items:AddList("Sac n°2 :", bags_2c, index.bags_2, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
            if (onListChange) then
                index.bags_2 = Index
            end
            if (Index) == Index then
                SetPedComponentVariation(PlayerPedId(), 5, pbags_1, Index-1, 2)
                pbags_2 = Index-1
            end
        end)

    end, function()
    end)

    tenu:IsVisible(function(Items)
        Menufoltone_vetement()
    end, function()
    end)
end

function Menufoltone_vetement()
    if PlayerClothe == nil or #PlayerClothe == 0 then 
        RageUI.Line(stylevide, "~r~Aucune tenue")
    else 
        for k,v in pairs(PlayerClothe) do
            Items:AddList(v.name, utils, index.utils, nil, { IsDisabled = false }, function(Index, onSelected, onListChange)
                if (onListChange) then
                    index.utils = Index
                end
                if (onSelected) then
                    if (Index) == 1 then                  
                        LoadClothe(v.clothe)
                    elseif (Index) == 2 then 
                        TriggerServerEvent('foltone_vetement:dropClothe', v.name)
                    elseif (Index) == 3 then
                        local ClosestPlayer, ClosestDistance = GetClosestPlayer()
                        if ClosestPlayer ~= -1 and ClosestDistance <= 3.0 then 
                            TriggerServerEvent('foltone_vetement:giveClothe', v.name, GetPlayerServerId(ClosestPlayer))
                        else
                            ESX.ShowNotification("Personne à proximité")
                        end 
                    end
                end 
            end)
        end
    end
end

Citizen.CreateThread(function()
	while true do
		local wait = 500
		local playerCoords = GetEntityCoords(PlayerPedId())
		for k, v in pairs(FoltoneVetement.Position) do
			local distance = GetDistanceBetweenCoords(playerCoords, v.x, v.y, v.z, true)
            if distance <= 8.0 then
                wait= 0
                DrawMarker(6, v.x, v.y, v.z-1, 0.0, 0.0, 9.0, 0.0, 0.0, 0.0, 0.5, 1.0, 0.5, 255, 165, 0, 255, false, false, 2, false, false, false, false)
            end
            if distance <= 1.0 then
				wait = 0
                if not open then
                    ESX.ShowHelpNotification("Appuyer sur ~o~[E]~s~ pour accéder au ~o~magasin", 1)
                    FreezeEntityPosition(PlayerPedId(), false)
                end
                if IsControlJustPressed(1, 51) then
                    GetComponent()
                    open = true
					RageUI.Visible(MenuVetement, not RageUI.Visible(MenuVetement))
                end
            end
        end
        Citizen.Wait(wait)
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(FoltoneVetement.Position) do
        --blip
		local BlipVetement = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(BlipVetement, 73)
		SetBlipScale (BlipVetement, 0.7)
		SetBlipColour(BlipVetement, 47)
		SetBlipAsShortRange(BlipVetement, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Magasin de Vetement')
		EndTextCommandSetBlipName(BlipVetement)
	end
end)

function LoadClothe(clothe)
    Citizen.CreateThread(function()
        RequestAnimDict('clothingtie')
	    while not HasAnimDictLoaded('clothingtie') do
	      Citizen.Wait(1)
	    end
	    TaskPlayAnim(PlayerPedId(), 'clothingtie', 'try_tie_neutral_a', 1.0, -1.0, 2667, 0, 1, true, true, true)
        Wait(2667)
        for _,v in pairs(clothe) do
            ESX.TriggerServerCallback('foltone_vetement:getPlayerSkin', function(cb)
                comp = cb
                comp.tshirt_1 = v.tshirt_1 or 15
                comp.tshirt_2 = v.tshirt_2 
                comp.torso_1  = v.torso_1
                comp.torso_2  = v.torso_2
                comp.chain_1  = v.chain_1
                comp.arms     = v.arms or v.arms_1 or 5
                comp.bags_1   = v.bags_1
                comp.pants_1  = v.pants_1
                comp.pants_2  = v.pants_2
                comp.shoes_1  = v.shoes_1 
                comp.shoes_2  = v.shoes_2

                TriggerEvent('skinchanger:loadSkin', comp)
                TriggerServerEvent('esx_skin:save', comp)
            end)
        end
    end)
end

RegisterNetEvent("foltone_vetement:yesmoney")
AddEventHandler(("foltone_vetement:yesmoney"), function()
    local name = OpenKeyboard()
    if name == nil or name == '' then 
        ESX.ShowNotification("Vous devez ENTRER un nom pour votre tenue!")
    else  
        table.insert(plyClothe, {
        tshirt_1 = ptshirt_1 ,
        tshirt_2 = ptshirt_2 ,
        torso_1  = ptorso_1,
        torso_2  = ptorso_2 ,
        decals_1 = pdecals_1 ,
        chain_1 = pchain_1 ,
        chain_2 = pchain_2 ,
        arms = parms_1 ,
        arms_2 = parms_2,
        bags_1 = pbags_1 ,
        bags_2 = pbags_2 ,
        pants_1  = ppants_1,
        pants_2  = ppants_2,
        shoes_1  = pshoes_1,
        shoes_2  = pshoes_2,
        })
        ESX.TriggerServerCallback('foltone_vetement:getPlayerSkin', function(cb)
            comp = cb
            if ptshirt_1 ~= nil then 
                comp.tshirt_1 = ptshirt_1
            end  
            if ptshirt_2 ~= nil then  
                comp.tshirt_2 = ptshirt_2
            end
            if ptorso_1 ~= nil then 
                comp.torso_1  = ptorso_1
            end
            if ptorso_2 ~= nil then 
                comp.torso_2  = ptorso_2
            end
            if pdecals_1 ~= nil then 
                comp.decals_1 = pdecals_1
            end
            if pchain_1 ~= nil then 
                comp.chain_1  = pchain_1
            end

            if parms_1 ~= nil then
                comp.arms     = parms_1
            end
            if parms_2 ~= nil then
                comp.arms_2  = parms_2
            end
            if pbags_1 ~= nil then 
                comp.bags_1   = pbags_1
            end
            if pbags_2 ~= nil then 
                comp.bags_2   = pbags_2
            end
            if ppants_1 ~= nil then 
                comp.pants_1  = ppants_1
            end
            if ppants_2 ~= nil then 
                comp.pants_2  = ppants_2
            end
            if pshoes_1 ~= nil then 
                comp.shoes_1  = pshoes_1 
            end
            if pshoes_2 ~= nil then 
                comp.shoes_2  = pshoes_2
            end
            TriggerEvent('skinchanger:loadSkin', comp)
        end)
        TriggerServerEvent('foltone_vetement:saveClothe', name, plyClothe)
    end
end)

RegisterNetEvent("foltone_vetement:nomoney")
AddEventHandler(("foltone_vetement:nomoney"), function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end)