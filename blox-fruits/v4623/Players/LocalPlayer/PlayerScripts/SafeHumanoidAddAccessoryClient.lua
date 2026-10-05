local ReplicatedStorage = game:GetService("ReplicatedStorage")
local safeHumanoidAddAccessory = ReplicatedStorage:WaitForChild("Util"):WaitForChild("SafeHumanoidAddAccessory")
local VerifyAccessoryAddedCorrectly = require(safeHumanoidAddAccessory:WaitForChild("VerifyAccessoryAddedCorrectly"))
local safeHumanoidAddAccessoryRemote = safeHumanoidAddAccessory:WaitForChild("SafeHumanoidAddAccessoryRemote")

safeHumanoidAddAccessoryRemote.OnClientInvoke = function(p, p2)
	local count = 0

	while count < 10 do
		if VerifyAccessoryAddedCorrectly(p, p2) == true then
			return true
		end

		count += 1

		if count < 10 then
			print("SafeHumanoidAddAccessory: Accessory attachment failed. Retrying (Attempt " .. count + 1 .. "/" .. 10 .. "): " .. debug.traceback())
			task.wait(1)
		else
			print("SafeHumanoidAddAccessory: Failed to attach accessory after " .. 10 .. " attempts: " .. debug.traceback())
			return nil
		end
	end

	return nil
end