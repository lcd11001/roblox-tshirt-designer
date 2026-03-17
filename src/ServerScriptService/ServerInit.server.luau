print("Server scripts initialized!")

-- Prevent auto-creation of the player's starter character
-- until player profile is loaded
local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local BindableEventManager = require(ReplicatedStorage.BindableEvents.BindableEventManager)
local Define = require(ReplicatedStorage.Define)
local ProfileManager = require(script.Parent.Profile.ProfileManager)

local function PrintPlayerProfile(player: Player, data: table, indent: number)
    -- default indent to 0 if not provided
    indent = indent or 0
    
    if indent == 0 then
        warn(`Player profile data for player: {player.Name}`)
    end
    for key, value in pairs(data) do
        if type(value) == "table" then
            if #value == 0 then
                print(`{string.rep(" ", indent)}{key}: \{}`) -- Print empty tables
                continue
            end
            print(`{string.rep(" ", indent)}{key}:\{`)
            PrintPlayerProfile(player, value, indent + 2) -- Recursively print nested tables
            print(`{string.rep(" ", indent)}}`)
        else
            print(`{string.rep(" ", indent)}{key}: {value}`)
        end
    end
end

local function OnPlayerAdded(player: Player)
	-- Set up a listener for when the player's character is added
	player.CharacterAdded:Connect(function(character: Model)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			local health = humanoid:WaitForChild("Health", 10)
			if health then
				print(`Character added for player: {player.Name} {character.Name} Health: {health.Value}`)
			end
		end
	end)

	-- if the player has a profile ready, load the character immediately
    local data = ProfileManager.GetProfile(player)
	if data then
        print(`Profile already ready for player: {player.Name}, loading character immediately.`)
        PrintPlayerProfile(player, data)
		player:LoadCharacterAsync()
		return
	end

	-- else, wait for the profile ready event before loading the character
	BindableEventManager.OnServerConnect(Define.BindableEvents.BE_ProfileReady, function(readyPlayer, playerData)
		if readyPlayer == player then
			print(`Profile ready for player: {player.Name}, loading character now.`)
			PrintPlayerProfile(player, playerData)
			-- you can load the character immediately
			player:LoadCharacterAsync()
		end
	end)
end

local function ServerInit()
	-- Initialize RemoteEventManager and BindableEventManager to ensure events are created
	RemoteEventManager.Init()
	BindableEventManager.Init()

	-- Load the ProfileManager to handle player profiles
	ProfileManager.Init()

	-- In case Players have joined the server earlier than this script ran:
	for _, player in Players:GetPlayers() do
		OnPlayerAdded(player)
	end
	-- Set up the PlayerAdded event listener
	Players.PlayerAdded:Connect(OnPlayerAdded)
end

-- Call the ServerInit function to set everything up
ServerInit()
