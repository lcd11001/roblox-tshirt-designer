local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Define = require(ReplicatedStorage.Define)

local RemoteFolder = script.Parent
local BindableEventManager = {}

local function getOrCreateEvent(name)
	local event = RemoteFolder:FindFirstChild(name)
	if not event and IS_SERVER then
		event = Instance.new("BindableEvent")
		event.Name = name
		event.Parent = RemoteFolder
	end
	return event
end

function BindableEventManager.Init()
	-- Create event when call on client before server
	getOrCreateEvent(Define.BindableEvents.BE_ProfileReady)
end

function BindableEventManager.OnServerConnect(name, callback)
	local event = getOrCreateEvent(name)
	if not event then return end
	event.Event:Connect(function(player, ...)
		callback(player, ...)
	end)
end

function BindableEventManager.FireServer(name, ...)
	local event = getOrCreateEvent(name)
	if not event then return end
	event:Fire(...)
end

return BindableEventManager