local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local debugModeEnabled = false
pcall(function()
	if workspace:GetAttribute("DebugModeEnabled") then
		debugModeEnabled = workspace:GetAttribute("DebugModeEnabled")
	end
end)

local function debugPrint(...)
	if debugModeEnabled then
		print(...)
	end
end

workspace:GetAttributeChangedSignal("DebugModeEnabled"):Connect(function()
	debugModeEnabled = workspace:GetAttribute("DebugModeEnabled") or false
end)
local specialLevelEventRemote = ReplicatedStorage:WaitForChild("SpecialLevelEventRemote", 30)

if not specialLevelEventRemote then
	warn("[LocalLevelEvents] SpecialLevelEventRemote not found after 30 seconds")
	return
end

local v = {}
local v2 = {}
local levelEvents = ReplicatedStorage:WaitForChild("LevelEvents", 5)

if levelEvents then
	for _, moduleScript in pairs(levelEvents:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if not (success and result.localBehaviors) then
			continue
		end

		local v3 = moduleScript.Name:gsub("Event$", "")
		v2[v3] = result
		debugPrint("[LocalLevelEvents] Loaded local events for:", v3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupLocalEvents(p)
	local v3 = v[p]

	if v3 then
		if type(v3) == "function" then
			local success, result = pcall(v3)

			if not success then
				warn("[LocalLevelEvents] Cleanup error:", result)
			end
		end

		v[p] = nil
	end
end

specialLevelEventRemote.OnClientEvent:Connect(function(p, p2, instance, p3)
	print("[LocalLevelEvents] Received event:", p, "for level:", p2)

	if p == "ExecuteLocalEvent" then
		local v3 = v2[p2]

		if not v3 then
			warn("[LocalLevelEvents] No event config found for level:", p2)
			return
		end

		print("[LocalLevelEvents] Executing local events for:", p2)
		cleanupLocalEvents(instance) -- equivalent call inferred; original call site unknown

		if v3.localBehaviors then
			local success, result = pcall(function()
				return v3.localBehaviors(instance, p3)
			end)

			if success and result then
				v[instance] = result
				instance.AncestryChanged:Connect(function()
					if not instance.Parent then
						cleanupLocalEvents(instance) -- equivalent call inferred; original call site unknown
					end
				end)
			elseif not success then
				warn("[LocalLevelEvents] Error executing local behaviors:", result)
			end
		end
	else
		local v3 = p == "CleanupLocalEvent" and v[instance]

		if v3 then
			if type(v3) == "function" then
				local success, result = pcall(v3)

				if not success then
					warn("[LocalLevelEvents] Cleanup error:", result)
				end
			end

			v[instance] = nil
		end
	end
end)
game.Players.LocalPlayer.AncestryChanged:Connect(function()
	if not game.Players.LocalPlayer.Parent then
		for k, _ in pairs(v) do
			cleanupLocalEvents(k) -- equivalent call inferred; original call site unknown
		end
	end
end)