--!strict
--[=[
	@class ProfileService
	@server
	@client

	A service that provides a unified interface for accessing player profiles on both the
	server and the client. It abstracts away the underlying RemoteEvent and BindableEvent
	connections, providing a simple API for other scripts to use.

	Usage:
	```lua
	-- Server-side script
	local ProfileService = require(ReplicatedStorage.ProfileService)
	local player = game.Players.LocalPlayer or game.Players:GetPlayerByUserId(123)

	ProfileService.OnReady(player, function(profileData)
		print("Profile is ready:", profileData)
	end)

	ProfileService.OnChanged(player, function(profileData)
		print("Profile has changed:", profileData)
	end)

	-- Client-side script
	local ProfileService = require(ReplicatedStorage.ProfileService)

	ProfileService.OnReady(function(profileData)
		print("Profile is ready:", profileData)
	end)

	ProfileService.OnChanged(function(profileData)
		print("Profile has changed:", profileData)
	end)
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Define = require(ReplicatedStorage.Define)
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local BindableEventManager = require(ReplicatedStorage.BindableEvents.BindableEventManager)

local IS_CLIENT = RunService:IsClient()

local ProfileManager
if not IS_CLIENT then
	ProfileManager = require(ServerScriptService.Profile.ProfileManager)
end

local ProfileService = {}

local profiles = {}
local onReadyCallbacks = {}
local onChangedCallbacks = {}

local function invokeCallbacks(callbacks, ...)
	for _, callback in ipairs(callbacks) do
		task.spawn(callback, ...)
	end
end

--[=[
	Retrieves the profileData for the specified player.

	@param player Player | nil -- The player to get the profileData for. If nil on the client, it will use the local player.
	@return table | nil -- The player's profileData data, or nil if it's not available yet.
]=]
function ProfileService.GetProfileData(player: Player?)
	if IS_CLIENT then
		player = player or game.Players.LocalPlayer
		return profiles[player]
	else
		local profile = ProfileManager.GetProfile(player)
		return profile and profile.Data
	end
end

--[=[
	Registers a callback function to be called when a player's profileData is ready.

	@param player Player | ((profileData: table) -> ()) -- The player to listen for on server; or the callback function on the client.
	@param callback ((profileData: table) -> ()) | nil -- The callback function to be called when the profileData is ready.
]=]
function ProfileService.OnReady(player: Player | ((profileData: table) -> ()), callback: ((profileData: table) -> ())?)
	if IS_CLIENT then
		callback = player
		player = game.Players.LocalPlayer
	end

	if not onReadyCallbacks[player] then
		onReadyCallbacks[player] = {}
	end

	table.insert(onReadyCallbacks[player], callback)

	local profileData = ProfileService.GetProfileData(player)

	if profileData then
		task.spawn(callback, profileData)
	end
end

--[=[
	Registers a callback function to be called when a player's profileData changes.

	@param player Player | ((profileData: table) -> ()) -- The player to listen for on server; or the callback function on the client.
	@param callback ((profileData: table) -> ()) | nil -- The callback function to be called when the profileData changes.
]=]
function ProfileService.OnChanged(player: Player | ((profileData: table) -> ()), callback: ((profileData: table) -> ())?)
	if IS_CLIENT then
		callback = player
		player = game.Players.LocalPlayer
	end

	if not onChangedCallbacks[player] then
		onChangedCallbacks[player] = {}
	end

	table.insert(onChangedCallbacks[player], callback)
end

function ProfileService.Print(...)
	if IS_CLIENT then
		RemoteEventManager.FireServer(Define.RemoteEvents.RE_PlayerProfilePrint, ...)
		return
	end
	BindableEventManager.FireServer(Define.BindableEvents.BE_ProfilePrint, ...)
end

function ProfileService.Update(...)
	if IS_CLIENT then
		RemoteEventManager.FireServer(Define.RemoteEvents.RE_PlayerProfileUpdate, ...)
		return
	end
	BindableEventManager.FireServer(Define.BindableEvents.BE_ProfileUpdate, ...)
end

local function onProfileReady(player, profileData)
	if IS_CLIENT then
		profiles[player] = profileData
	end
	if onReadyCallbacks[player] then
		invokeCallbacks(onReadyCallbacks[player], profileData)
	end
end

local function onProfileChanged(player, profileData)
	if IS_CLIENT then
		profiles[player] = profileData
	end
	if onChangedCallbacks[player] then
		invokeCallbacks(onChangedCallbacks[player], profileData)
	end
end

local function init()
	if not IS_CLIENT then
		ProfileManager.Init()
	end
end	

local function autoExec()
	init()

	if IS_CLIENT then
		RemoteEventManager.OnClientConnect(Define.RemoteEvents.RE_PlayerProfileReady, function(profileData)
			onProfileReady(game.Players.LocalPlayer, profileData)
		end)
		RemoteEventManager.OnClientConnect(Define.RemoteEvents.RE_PlayerProfileChanged, function(profileData)
			onProfileChanged(game.Players.LocalPlayer, profileData)
		end)
	else
		BindableEventManager.OnServerConnect(Define.BindableEvents.BE_ProfileReady, onProfileReady)
		BindableEventManager.OnServerConnect(Define.BindableEvents.BE_ProfileChanged, onProfileChanged)
	end
end

-- auto execute when required on either the server or client to set up event connections
autoExec()

return ProfileService

