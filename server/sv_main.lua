ESX = nil
local loadPlyClothe, player = {}, {}
local saveClothe = true

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('foltone_vetement:getPlayerSkin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(users)
        local users = users[1]
        local skin = nil
        if users.skin ~= nil then
            cl = json.decode(users.skin)
        end
        cb(cl)
    end)
end)

function PlayerIdentifier(type, id)
    local identifiers = {}
    local numIdentifiers = GetNumPlayerIdentifiers(id)

    for a = 0, numIdentifiers do
        table.insert(identifiers, GetPlayerIdentifier(id, a))
    end

    for b = 1, #identifiers do
        if string.find(identifiers[b], type, 1) then
            return identifiers[b]
        end
    end
    return false
end

RegisterNetEvent('foltone_vetement:saveClothe')
AddEventHandler('foltone_vetement:saveClothe', function(name, clothe)
  local x_source = source
  local license = PlayerIdentifier('license', x_source)

    MySQL.Async.execute("INSERT INTO user_clothes (identifier, name, clothe) VALUES (@identifier, @name, @clothe)",
      {
        ['@identifier'] = license,
        ['@name'] = name,
        ['@clothe'] = json.encode(clothe)
      },
      function(result)
        player[x_source].AddClothe(name, clothe)
        TriggerClientEvent('foltone_vetement:Notification', x_source, 'Votre tenue à été ~g~sauvegarder~w~ !')
      end
    )
end)

RegisterNetEvent('foltone_vetement:loadClothe')
AddEventHandler('foltone_vetement:loadClothe', function()
  local x_source = source
  local license = PlayerIdentifier('license', x_source)

  MySQL.Async.fetchAll("SELECT name, clothe FROM user_clothes WHERE identifier = @identifier ", 
    { 
      ['@identifier'] = license
    }, 
    function(result)

      loadPlyClothe = {}

      for i=1,#result ,1 do
        local name = result[i].name
        local clothe = json.decode(result[i].clothe)
        table.insert(loadPlyClothe,{name = name, clothe = clothe})
      end
      player[x_source] = CreateClothingTable(x_source, loadPlyClothe)
      player[x_source].GetClothe(false) 
    end
  )      
end)

RegisterNetEvent('foltone_vetement:giveClothe')
AddEventHandler('foltone_vetement:giveClothe', function(name, closestPlayer)
  local x_source = source
  local license = PlayerIdentifier('license', x_source)
  local licenseOwner = PlayerIdentifier('license', closestPlayer)

  MySQL.Async.fetchAll("UPDATE user_clothes SET identifier = @owner WHERE identifier = @identifier AND name = @name", 
    {
      ['@identifier'] = license, 
      ['@owner'] = licenseOwner,
      ['@name'] = name
    },
    function(result)
      local ownerClothe = player[x_source].GetClothe(true)
      for k,v in pairs(ownerClothe) do
        if name == v.name then 
          player[x_source].DeleteClothe(name)
          player[closestPlayer].AddClothe(name, v.clothe)

          TriggerClientEvent('foltone_vetement:Notification', x_source, "Vous avez donné une tenue !")
          TriggerClientEvent('foltone_vetement:Notification', closestPlayer, "Une tenue vous à été donné !")
        end 
      end   
    end
  )
end)

RegisterNetEvent('foltone_vetement:dropClothe')
AddEventHandler('foltone_vetement:dropClothe', function(name)
  local x_source = source
  local license = PlayerIdentifier('license', x_source)
  
  MySQL.Async.execute("DELETE FROM user_clothes WHERE identifier = @identifier AND name = @name",
    {
      ['@identifier'] = license,
      ['@name'] = name
    },
    function(result)
      player[x_source].DeleteClothe(name)
      TriggerClientEvent('foltone_vetement:Notification', x_source, "Vous avez jeté une tenue !")
    end
  )
end)

function CreateClothingTable(source, clothing)
    local self = {}
    self.source = source
    self.GetClothe = clothing
    local player = {}
    player.GetClothe = function(cb)
        if cb == true then 
            return self.GetClothe
        else 
            TriggerClientEvent('foltone_vetement:loadPlayerClothe', self.source, self.GetClothe)
        end 
    end
    player.AddClothe = function(name, clothe)
        table.insert(self.GetClothe, {name = name, clothe = clothe})
        self.GetClothe = self.GetClothe
        TriggerClientEvent('foltone_vetement:refreshClothe', self.source, self.GetClothe)
    end
    player.DeleteClothe = function(name)
        for k,v in pairs(self.GetClothe) do
            if name == v.name then 
                table.remove(self.GetClothe, k)
                self.GetClothe = self.GetClothe
            end
        end 
        TriggerClientEvent('foltone_vetement:refreshClothe', self.source, self.GetClothe)
    end
    return player
end


RegisterNetEvent('foltone_vetement:achetervetement')
AddEventHandler('foltone_vetement:achetervetement', function(prix)
    local xPlayer = ESX.GetPlayerFromId(source)
    local LiquideJoueur = xPlayer.getMoney()
    if LiquideJoueur >= prix then
        xPlayer.removeMoney(prix)
        TriggerClientEvent(("foltone_vetement:yesmoney"), source)
        TriggerClientEvent('esx:showAdvancedNotification', source, 'Information!', '~g~Achat effectué!', '', 'CHAR_BANK_FLEECA', 9)
    else
        TriggerClientEvent(("foltone_vetement:nomoney"), source)
        TriggerClientEvent('esx:showAdvancedNotification', source, 'Information!', "~r~Pas assez de liquide!", '', 'CHAR_BLOCKED', 9)
    end
end)