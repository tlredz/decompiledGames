local Players = game:GetService("Players")
local module = require("./observeCharacter")

local function observeLocalCharacter(callback)
	return module(Players.LocalPlayer, function(_, instance)
		local v = nil
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopObservingHumanoid()
			local v3 = v2
			v2 = nil
			v = nil

			if v3 ~= nil then
				task.spawn(v3)
			end
		end

		local function handleChildAdded(humanoid)
			if v ~= nil or not humanoid:IsA("Humanoid") then
				return
			end

			v = humanoid
			v2 = callback(instance, humanoid)
		end

		local function handleChildRemoved(p)
			if p == v then
				stopObservingHumanoid() -- equivalent call inferred; original call site unknown
			end
		end

		local childAddedConnection = instance.ChildAdded:Connect(handleChildAdded)
		local childRemovedConnection = instance.ChildRemoved:Connect(handleChildRemoved)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid ~= nil and v == nil and humanoid:IsA("Humanoid") then
			v = humanoid
			v2 = callback(instance, humanoid)
		end

		return function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
			stopObservingHumanoid() -- equivalent call inferred; original call site unknown
		end
	end)
end

return observeLocalCharacter