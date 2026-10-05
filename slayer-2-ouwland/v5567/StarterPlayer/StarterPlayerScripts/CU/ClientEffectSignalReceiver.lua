local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local nowsByChildName = {}
local effects = game.ReplicatedStorage:WaitForChild("Effects")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)

function do_tang(childName, ...)
	if not (childName ~= nil and typeof(childName) == "string") then
		return
	end

	local child = script:FindFirstChild(childName)

	if child ~= nil and child:FindFirstChild("Perform") ~= nil then
		child.Perform:Fire(...)
	end

	if child == nil then
		if v[childName] == nil then
			local v2 = nowsByChildName[childName]

			if v2 ~= nil and os.clock() - v2 < 10 then
				return
			end

			local child2 = effects:FindFirstChild(childName, true)

			if child2 == nil then
				nowsByChildName[childName] = os.clock()
			else
				local v3 = v
				local module = require(child2)
				v3[childName] = module
			end
		end

		if v[childName] ~= nil then
			return v[childName](...)
		end
	end
end

EffectsEvent:Connect(do_tang)
game.ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("ClientEffects").Event:Connect(do_tang)