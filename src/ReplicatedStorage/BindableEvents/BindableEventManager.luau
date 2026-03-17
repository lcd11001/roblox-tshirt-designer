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
    if not IS_SERVER then
		warn("BindableEventManager should be initialized on the server only.")
		return
	end
	-- Create all bindable events
    for _, eventName in pairs(Define.BindableEvents) do
        getOrCreateEvent(eventName)
    end
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