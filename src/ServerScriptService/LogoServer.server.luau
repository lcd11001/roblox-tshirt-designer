local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local Define = require(ReplicatedStorage.Define)

local ServerScriptService = game:GetService("ServerScriptService")
local WhiteList = require(ServerScriptService.WhiteList)

local playerData = {}

local function applyLogo(character, data)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then
        warn(`Could not find torso for character ${character.Name}, cannot apply logo.`)
		return
	end

	-- remove old
	for _, v in pairs(torso:GetChildren()) do
		if v.Name == "DynamicLogo" then
			v:Destroy()
		end
	end

    -- https://create.roblox.com/docs/reference/engine/classes/Decal
	local decal = Instance.new("Decal")
	decal.Name = "DynamicLogo"
    decal.Face = Enum.NormalId.Front
    local decalId = WhiteList.DECALS[data.decalIndex]
	-- decal.ColorMapContent = decalId
    decal.Texture = decalId
	decal.UVOffset = Vector2.new(data.offsetU, data.offsetV)
	decal.UVScale = Vector2.new(data.scale, data.scale)

	decal.Parent = torso
end

local function validate(data)
	if typeof(data.offsetU) ~= "number" then
		return false
	end
	if typeof(data.offsetV) ~= "number" then
		return false
	end
	if typeof(data.scale) ~= "number" then
		return false
	end
	if typeof(data.decalIndex) ~= "number" then
		return false
	end
	if data.decalIndex < 1 or data.decalIndex > #WhiteList.DECALS then
		return false
	end

	-- clamp values
	data.offsetU = math.clamp(data.offsetU, -2, 2)
	data.offsetV = math.clamp(data.offsetV, -2, 2)
	data.scale = math.clamp(data.scale, 0.5, 3)

	return true
end

RemoteEventManager.OnServerConnect(Define.RemoteEvents.RE_UpdateLogo, function(player, data)
	if not validate(data) then
		warn(`Received invalid logo data from player {player.Name}, ignoring.`)
		return
	end

	playerData[player] = data

	if player.Character then
		applyLogo(player.Character, data)
	end
end)
