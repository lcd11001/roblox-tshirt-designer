local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Define = require(ReplicatedStorage.Define)
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)

local ProfileService = {}

function ProfileService.PrintProfile(...)
	RemoteEventManager.FireServer(Define.RemoteEvents.RE_PlayerProfilePrint, ...)
end

return ProfileService
