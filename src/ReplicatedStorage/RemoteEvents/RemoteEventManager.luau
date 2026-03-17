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
	if not IS_SERVER then
		warn("RemoteEventManager should be initialized on the server only.")
		return
	end
	-- Create all remote events
	for _, eventName in pairs(Define.RemoteEvents) do
		getOrCreateEvent(eventName)
	end
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