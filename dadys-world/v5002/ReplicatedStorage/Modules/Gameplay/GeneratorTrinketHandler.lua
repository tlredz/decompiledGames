local GeneratorTrinketHandler = {}

function GeneratorTrinketHandler.HandleMachineEvent(instance, p, p2)
	if not (instance and p2 and p2.Value) then
		return
	end

	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")

	if trinket1 and trinket1.Value ~= "None" then
		local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")
		local child = trinketData and trinketData:FindFirstChild(trinket1.Value)

		if child then
			local success, result = pcall(function()
				local module = require(child)

				if module.MachineEvent and typeof(module.TriggerMachineEvent) == "function" then
					module.TriggerMachineEvent(trinket1, p, p2)
				end
			end)

			if not success then
				warn("Error triggering MachineEvent for Trinket1:", result)
			end
		end
	end

	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if trinket2 and trinket2.Value ~= "None" then
		local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")
		local child = trinketData and trinketData:FindFirstChild(trinket2.Value)

		if child then
			local success, result = pcall(function()
				local module = require(child)

				if module.MachineEvent and typeof(module.TriggerMachineEvent) == "function" then
					module.TriggerMachineEvent(trinket2, p, p2)
				end
			end)

			if not success then
				warn("Error triggering MachineEvent for Trinket2:", result)
			end
		end
	end
end

function GeneratorTrinketHandler.HandleSkillCheckComplete(instance, p, p2)
	if not (instance and p2 and p2.Value) then
		return
	end

	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")

	if trinket1 and trinket1.Value ~= "None" then
		local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")
		local child = trinketData and trinketData:FindFirstChild(trinket1.Value)

		if child then
			local success, result = pcall(function()
				local module = require(child)

				if module.SkillCheckCompleteEvent and typeof(module.TriggerSkillCheckCompleteEvent) == "function" then
					module.TriggerSkillCheckCompleteEvent(trinket1, p, p2)
				end
			end)

			if not success then
				warn("Error triggering SkillCheckCompleteEvent for Trinket1:", result)
			end
		end
	end

	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if trinket2 and trinket2.Value ~= "None" then
		local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")
		local child = trinketData and trinketData:FindFirstChild(trinket2.Value)

		if child then
			local success, result = pcall(function()
				local module = require(child)

				if module.SkillCheckCompleteEvent and typeof(module.TriggerSkillCheckCompleteEvent) == "function" then
					module.TriggerSkillCheckCompleteEvent(trinket2, p, p2)
				end
			end)

			if not success then
				warn("Error triggering SkillCheckCompleteEvent for Trinket2:", result)
			end
		end
	end
end

function GeneratorTrinketHandler.HandleSkillCheckFail(instance, p, p2)
	if not (instance and p2 and p2.Value) then
		return true, nil
	end

	local v = true
	local v2 = nil
	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return true, nil
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")

	if trinket1 and trinket1.Value ~= "None" then
		local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")

		if trinketData then
			local child = trinketData:FindFirstChild(trinket1.Value)

			if child then
				local success, result, v3 = pcall(function()
					local module = require(child)

					if typeof(module.TriggerSkillCheckFailEvent) == "function" then
						return module.TriggerSkillCheckFailEvent(trinket1, p, p2), module
					end

					return false, nil
				end)

				if success and result then
					v2 = v3
					v = false
				end
			end
		end
	end

	if not v then
		return v, v2
	end

	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket2 and trinket2.Value ~= "None") then
		return v, v2
	end

	local trinketData = game.ReplicatedStorage:FindFirstChild("TrinketData")

	if trinketData then
		local child = trinketData:FindFirstChild(trinket2.Value)

		if child then
			local success, result, v3 = pcall(function()
				local module = require(child)

				if typeof(module.TriggerSkillCheckFailEvent) == "function" then
					return module.TriggerSkillCheckFailEvent(trinket2, p, p2), module
				end

				return false, nil
			end)

			if success and result then
				v2 = v3
				v = false
			end
		end
	end

	return v, v2
end

return GeneratorTrinketHandler