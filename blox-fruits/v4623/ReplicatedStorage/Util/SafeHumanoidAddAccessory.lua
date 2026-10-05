local VerifyAccessoryAddedCorrectly = require(script:WaitForChild("VerifyAccessoryAddedCorrectly"))
local safeHumanoidAddAccessoryRemote = script:WaitForChild("SafeHumanoidAddAccessoryRemote")

local function pcallWarn(fn, ...)
	return xpcall(fn, function(p)
		warn("pcallWarn caught an error: " .. tostring(p) .. "\n" .. debug.traceback())
		return false, p
	end, ...)
end

local function SafeHumanoidAddAccessory(object, instance)
	local parent = object.Parent

	if not (parent and parent:IsA("Model")) then
		error("Humanoid has no parent. " .. debug.traceback())
	end

	local count = 0

	while count < 10 do
		object:AddAccessory(instance)
		local accessoryRigidConstraint = instance:FindFirstChild("AccessoryRigidConstraint", true)

		if accessoryRigidConstraint then
			local v = assert(accessoryRigidConstraint.Attachment0, "RigidConstraint missing Attachment0")
			local v2 = assert(accessoryRigidConstraint.Attachment1, "RigidConstraint missing Attachment1")
			local part = assert(v.Parent, "Attachment0 has no parent part")
			local part2 = assert(v2.Parent, "Attachment1 has no parent part")
			local weld = Instance.new("Weld")
			weld.Name = "AccessoryWeld"
			weld.Part0 = part
			weld.Part1 = part2
			weld.C0 = v.CFrame
			weld.C1 = v2.CFrame
			weld.Parent = instance:FindFirstChild("Handle")
			accessoryRigidConstraint:Destroy()
		end

		local verifyAccessoryAddedCorrectly = VerifyAccessoryAddedCorrectly(object, instance)

		if verifyAccessoryAddedCorrectly ~= true then
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("Accessory attachment failed on server. " .. debug.traceback())
		end

		local Players = game:GetService("Players")
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter == nil then
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("player is nil" .. debug.traceback())
			break
		else
			local v2 = nil
			local v3 = playerFromCharacter
			pcallWarn(function()
				task.spawn(function()
					v2 = safeHumanoidAddAccessoryRemote:InvokeClient(v3, object, instance)

					if v2 == true then
						local Global = require(game.ReplicatedStorage.Global)
						Global.TestGamePrint("SafeHumanoidAddAccessory: Safely added Humanoid Accessory (on client of input Humanoid) to " .. parent:GetFullName())
					else
						local Global = require(game.ReplicatedStorage.Global)
						Global.TestGameWarn("Accessory attachment failed on client. " .. debug.traceback())
					end
				end)
			end)

			if verifyAccessoryAddedCorrectly == true then
				local Global = require(game.ReplicatedStorage.Global)
				Global.TestGamePrint("SafeHumanoidAddAccessory: Safely added Humanoid Accessory (on server) to " .. parent:GetFullName())
				break
			else
				count += 1

				if count < 10 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.TestGameWarn("Accessory attachment failed. Retrying (Attempt " .. count + 1 .. "/" .. 10 .. "): " .. debug.traceback())
					task.wait(0.1)
				else
					error("Failed to attach accessory after " .. 10 .. " attempts: " .. debug.traceback())
				end
			end
		end
	end
end

return SafeHumanoidAddAccessory