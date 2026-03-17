local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Define = require(ReplicatedStorage.Define)

local RemoteFolder = script.Parent
local RemoteEventManager = {}

local function getOrCreateEvent(name)
	local event = RemoteFolder:FindFirstChild(name)
	if not event and IS_SERVER then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = RemoteFolder
	end
	return event
end

function RemoteEventManager.Init()
	-- Create event when call on client before server
	getOrCreateEvent(Define.RemoteEvents.RE_PlayerProfileReady)
end

function RemoteEventManager.OnServerConnect(name, callback)
	local event = getOrCreateEvent(name)
	if not event then return end
	event.OnServerEvent:Connect(function(player, ...)
		callback(player, ...)
	end)
end

function RemoteEventManager.OnClientConnect(name, callback)
	local event = getOrCreateEvent(name)
	if not event then return end
	event.OnClientEvent:Connect(function(...)
		callback(...)
	end)
end

function RemoteEventManager.FireClient(name, player, ...)
	local event = getOrCreateEvent(name)
	if not event then return end
	event:FireClient(player, ...)
end

function RemoteEventManager.FireAllClients(name, ...)
	local event = getOrCreateEvent(name)
	if not event then return end
	event:FireAllClients(...)
end

function RemoteEventManager.FireServer(name, ...)
	local event = getOrCreateEvent(name)
	if not event then return end
	event:FireServer(...)
end

return RemoteEventManager