print ("PlayerInit script running on client!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local Define = require(ReplicatedStorage.Define)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

RemoteEventManager.OnClientConnect(Define.RemoteEvents.RE_PlayerProfileReady, function(data)
    print(`Profile is ready on the client {player.Name}!`)

    -- Update cash
    data.Cash = (data.Cash or 0) + 100

    -- create items table if it doesn't exist
    if not data.Items then
        data.Items = {}
    end

    -- Add a new item
    -- local newItemNumber = #data.Items + 1
    -- table.insert(data.Items, "item" .. newItemNumber)

    -- Send the updated data back to the server
    RemoteEventManager.FireServer(Define.RemoteEvents.RE_PlayerProfileUpdate, data)
    print("Sent updated profile to the server!")
end)

