local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MeleeRagdollTool = require(ReplicatedStorage._FRAMEWORK.Libraries.MeleeRagdollTool)
require(script.Parent.Parent.Types)
local wandererCrowd = require(ReplicatedStorage._FRAMEWORK.Libraries.wandererCrowd)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {
	[2006] = true,
	[2008] = true,
	[2009] = true
}
local v2 = {
	[2011] = "rbxassetid://132978820052538"
}
local v3 = {
	[2011] = 1.5
}

local function collectTemplates(p, p2: number)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local wanderers

	if child then
		wanderers = child:FindFirstChild("Wanderers")
	end

	local models = {}

	if not wanderers then
		return models
	end

	for _, model in wanderers:GetChildren() do
		if not (model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		table.insert(models, model)
	end

	return models
end

local function collectZones(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local zones

	if scriptables then
		zones = scriptables:FindFirstChild("Zones")
	end

	local wandererZones

	if zones then
		wandererZones = zones:FindFirstChild("WandererZones")
	end

	local parts = {}

	if wandererZones then
		for _, part in wandererZones:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end
	end

	return parts
end

local function checkWanderersReady(p, p2: number, p3)
	local v4 = collectTemplates(p, p2)
	local v5 = collectZones(p3)

	if #v4 == 0 then
		return
			false,
			v4,
			v5,
			string.format(
				"20th Anniversary Year %d needs a Wanderers folder of rigs (Model with Humanoid and HumanoidRootPart)",
				p2
			)
	end

	if #v5 == 0 then
		return
			false,
			v4,
			v5,
			string.format(
				"20th Anniversary Year %d map requires Scriptables.Zones.WandererZones (Folder of BaseParts)",
				p2
			)
	end

	return true, v4, v5, nil
end

local function getKillers(p, instance)
	local result = {}

	for _, objectValue in instance:GetChildren() do
		if not objectValue:IsA("ObjectValue") then
			continue
		end

		local value = objectValue.Value

		if not value or not value:IsA("Player") or not p.isParticipant(value) or table.find(result, value) then
			continue
		end

		table.insert(result, value)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createKillHandler(p)
	local winReward = MeleeRagdollTool.createWinReward("TwentyYearsEvent:Wanderer", 5)
	return function(p2)
		for _, v4 in getKillers(p, p2) do
			local success, result = pcall(winReward, v4)

			if not success then
				logger:warn(string.format("Wanderer kill reward failed for %s: %s", v4.Name, (tostring(result))))
			end
		end
	end
end

local WandererSupport = {}

function WandererSupport.start(p, p2: number, parent)
	local v4, templates, zones, v7 = checkWanderersReady(p, p2, parent)

	if not v4 then
		logger:warn(v7)
		return function() end
	end

	local startServer = wandererCrowd.startServer
	local v8 = {
		count = 40,
		topUpIntervalSeconds = 1.5,
		templates = templates,
		zones = zones,
		parent = parent,
		walkSpeedMultiplier = v3[p2] or 1,
		onKilled = 0
	}
	local onKilled

	if v[p2] then
		onKilled = createKillHandler(p)
	end

	v8.onKilled = onKilled
	return startServer(v8)
end

function WandererSupport.startClient(p: number)
	return wandererCrowd.startClient({
		walkAnimationId = v2[p] or "rbxassetid://94227411435202"
	})
end

return WandererSupport