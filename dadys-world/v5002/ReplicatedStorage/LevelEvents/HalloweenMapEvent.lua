local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local HalloweenMapEvent = {}
HalloweenMapEvent.properties = {
	HasDialogueTriggers = true,
	RequiresGourdyCharacter = true,
	TriggerDuration = 5
}

function HalloweenMapEvent.onRoomLoad(instance, _)
	print("[HalloweenMapEvent] Setting up HalloweenMap special features")
	local triggerZones = instance:FindFirstChild("TriggerZones")

	if triggerZones then
		for _, instance2 in pairs(triggerZones:GetChildren()) do
			if not (instance2.Name:find("Dialogue") or instance2.Name:find("Story") or instance2.Name:find("Bedroom")) then
				continue
			end

			CollectionService:AddTag(instance2, "StoryTrigger")
		end
	end
end

function HalloweenMapEvent.setupBehaviors(ancestor, _)
	local SimpleZone = require(ReplicatedStorage.Modules:WaitForChild("SimpleZone"))
	local dialogueEvent = ReplicatedStorage:FindFirstChild("StoryEvents") and ReplicatedStorage.StoryEvents:FindFirstChild("DialogueEvent")

	if not dialogueEvent then
		warn("[HalloweenMapEvent] DialogueEvent not found!")
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isPlayerGourdy(player)
		if not (player and player.Character) then
			return false
		end

		local config = player.Character:FindFirstChild("Config")

		if config and config:FindFirstChild("ModuleName") and config.ModuleName.Value == "Gourdy" then
			return true
		end

		return false
	end

	local tagged = CollectionService:GetTagged("StoryTrigger")
	local v = {}
	local v2 = {}
	local v3 = {}

	for _, part in pairs(tagged) do
		if not (part:IsDescendantOf(ancestor) and part:IsA("BasePart")) then
			continue
		end

		local v4 = SimpleZone.fromPart(part)
		local v5 = part
		v4.ItemEntered:Connect(function(player)
			if not player:IsA("Player") then
				return
			end

			-- equivalent call inferred; original call site unknown
			if not isPlayerGourdy(player) or v[player] then
				return
			end

			local v6 = player.UserId .. "_" .. v5:GetFullName()

			if not v2[v6] then
				v2[v6] = task.spawn(function()
					task.wait(5)

					if player and player.Parent then
						v[player] = true
						dialogueEvent:Fire(player.Character, "Gourdy", "I shouldn't stay here much longer…", 3)
						v2[v6] = nil
					end
				end)
			end
		end)
		local v6 = part
		v4.ItemExited:Connect(function(player)
			if not player:IsA("Player") then
				return
			end

			local v7 = player.UserId .. "_" .. v6:GetFullName()

			if v2[v7] then
				task.cancel(v2[v7])
				v2[v7] = nil
			end
		end)
		v4:BindToHeartbeat()
		table.insert(v3, v4)
	end

	return function()
		for _, v4 in ipairs(v3) do
			v4:UnbindFromHeartbeat()
		end

		table.clear(v3)
		table.clear(v)

		for _, v4 in pairs(v2) do
			if v4 then
				task.cancel(v4)
			end
		end

		table.clear(v2)
	end
end

return HalloweenMapEvent