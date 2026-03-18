local ProfileStore = require(script.Parent.ProfileStore)

local PROFILE_TEMPLATE = require(script.Parent.ProfileTemplate)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Define = require(ReplicatedStorage.Define)
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local BindableEventManager = require(ReplicatedStorage.BindableEvents.BindableEventManager)

local Players = game:GetService("Players")

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

local ProfileManager = {}

function ProfileManager.GetProfile(player: Player)
	return Profiles[player]
end

local function UpdateProfile(player:Player, data: table)
	local profile = Profiles[player]
	if profile then
		-- update timestamp to show that the profile has been updated
		data.LastUpdated = os.time()

		profile.Data = data
		profile:Save() -- Save the updated profile data to the data store

		-- Notify the client that the profile has been changed
		RemoteEventManager.FireClient(Define.RemoteEvents.RE_PlayerProfileChanged, player, profile.Data)
		BindableEventManager.FireServer(Define.BindableEvents.BE_ProfileChanged, player, profile.Data)
	end
end

local function PlayerAdded(player)
	-- Start a profile session for this player's data:

	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = profile
			-- warn(`Profile loaded for {player.DisplayName}!`)
			-- Notify the client that the profile is ready
			-- Fire the client-side event:FireClient(player, profile.Data)
			RemoteEventManager.FireClient(Define.RemoteEvents.RE_PlayerProfileReady, player, profile.Data)
			RemoteEventManager.OnServerConnect(Define.RemoteEvents.RE_PlayerProfileUpdate, UpdateProfile)
			RemoteEventManager.OnServerConnect(Define.RemoteEvents.RE_PlayerProfilePrint, ProfileManager.PrintProfile)
			-- Fire the server-side event to unblock other scripts
			BindableEventManager.FireServer(Define.BindableEvents.BE_ProfileReady, player, profile.Data)
			BindableEventManager.OnServerConnect(Define.BindableEvents.BE_ProfileUpdate, UpdateProfile)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function ProfileManager.Init()
	-- In case Players have joined the server earlier than this script ran:
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

function ProfileManager.PrintProfile(player: Player, data: table, indent: number)
    -- default indent to 0 if not provided
    indent = indent or 0
	-- default data to Profiles[player].Data if not provided
	data = data or Profiles[player].Data
    
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
            ProfileManager.PrintProfile(player, value, indent + 2) -- Recursively print nested tables
            print(`{string.rep(" ", indent)}}`)
        else
            print(`{string.rep(" ", indent)}{key}: {value}`)
        end
    end
end

return ProfileManager
