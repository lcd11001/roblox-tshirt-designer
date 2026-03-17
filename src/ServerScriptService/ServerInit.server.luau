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
        ProfileManager.PrintProfile(player, data)
		player:LoadCharacterAsync()
		return
	end

	-- else, wait for the profile ready event before loading the character
	BindableEventManager.OnServerConnect(Define.BindableEvents.BE_ProfileReady, function(readyPlayer, playerData)
		if readyPlayer == player then
			print(`Profile ready for player: {player.Name}, loading character now.`)
			ProfileManager.PrintProfile(player, playerData)

            -- simulate change in profile data after loading
            -- this is just for testing, you can remove it later
            task.delay(5, function()
                local updatedData = table.clone(ProfileManager.GetProfile(player).Data)
                updatedData.Cash = (updatedData.Cash or 0) + 50 -- Add 50 cash as an example update
                BindableEventManager.FireServer(Define.BindableEvents.BE_ProfileUpdate, player, updatedData)
            end)

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
