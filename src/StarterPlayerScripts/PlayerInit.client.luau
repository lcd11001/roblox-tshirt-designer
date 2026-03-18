print ("PlayerInit script running on client!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local Define = require(ReplicatedStorage.Define)
local ProfileService = require(ReplicatedStorage.ProfileService)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

RemoteEventManager.OnClientConnect(Define.RemoteEvents.RE_PlayerProfileReady, function(data)
    print(`Profile is ready on the client {player.Name}!`)

    local newData = {
        -- Update cash
        Cash = (data.Cash or 0) + 100,
        Items = {},
    }
    
    -- Add a new item
    local newItemNumber = #data.Items + 1
    table.insert(newData.Items, newItemNumber, "item" .. newItemNumber)
    
    -- Send the updated data back to the server
    -- NOTE: You should only send the updated fields to the server, not the entire profile data,
    -- to avoid overwriting other fields that may have been changed on the server.
    RemoteEventManager.FireServer(Define.RemoteEvents.RE_PlayerProfileUpdate, newData)
    print("Sent updated profile to the server!")
end)

RemoteEventManager.OnClientConnect(Define.RemoteEvents.RE_PlayerProfileChanged, function(data)
    print(`Profile has been changed on the client {player.Name}!`)

    -- You can also print the updated profile data here to verify the change
    for key, value in pairs(data) do
        if type(value) == "table" then
            if #value == 0 then
                print(`{key}: \{}`) -- Print empty tables
                continue
            end
            print(`{key}:\{`)
            for i, item in ipairs(value) do
                print(`  {i}: {item}`)
            end
            print(`}`)
        else
            print(`{key}: {value}`)
        end
    end
    print("Received updated profile from the server!")
    ProfileService.PrintProfile()
end)

