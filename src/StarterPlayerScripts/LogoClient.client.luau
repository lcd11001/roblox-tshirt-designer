local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventManager = require(ReplicatedStorage.RemoteEvents.RemoteEventManager)
local Define = require(ReplicatedStorage.Define)

-- Example: send update
local function updateLogo()
    -- create a smiley face logo on the right chest of the character, with half the default size
    local data = {
        decalIndex = 1,
        offsetU = 0.25,
        offsetV = 0.25,
        scale = 2.0
    }

    RemoteEventManager.FireServer(Define.RemoteEvents.RE_UpdateLogo, data)
end

-- Test: press key to send
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        warn("T key pressed, sending update logo event to server...")
        updateLogo()
    end
end)