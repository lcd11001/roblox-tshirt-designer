print("PlayerInit script running on client!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileService = require(ReplicatedStorage.ProfileService)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

ProfileService.OnReady(function(data)
	warn(`Profile is ready on the client {player.Name}!`)

	local newData = {
		-- Update cash
		Cash = (data.Cash or 0) + 100,
		Items = {},
        Count = (data.Count or 0) + 1,
	}

	-- Add a new item
	-- local newItemNumber = #data.Items + 1
	-- table.insert(newData.Items, newItemNumber, "item" .. newItemNumber)

	-- Send the updated data back to the server
	-- NOTE: You should only send the updated fields to the server, not the entire profile data,
	-- to avoid overwriting other fields that may have been changed on the server.
	ProfileService.Update(newData)
	warn("Sent updated profile to the server!")
end)

ProfileService.OnChanged(function(data)
	warn(`Profile has been changed on the client {player.Name}!`)

	-- You can also print the updated profile data here to verify the change
	for key, value in pairs(data) do
		if type(value) == "table" then
			if #value == 0 then
				print(`{key}: \{}`) -- Print empty tables
				continue
			end
			print(`{key}:\{`)
			for i, item in ipairs(value) do
				print(`  {i}: {item}`)
			end
			print(`}`)
		else
			print(`{key}: {value}`)
		end
	end
	print("Received updated profile from the server!")
	ProfileService.Print(data)
end)


