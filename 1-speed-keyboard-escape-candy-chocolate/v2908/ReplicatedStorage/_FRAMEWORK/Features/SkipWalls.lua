local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local ClientState = require(ReplicatedStorage.ClientState)
local v = {}

local function updateWall(folder)
	local level = folder:GetAttribute("Level")

	if type(level) ~= "number" then
		warn("[SkipWalls] L'attribut 'Level' (Number) est manquant sur:", folder:GetFullName())
		return
	end

	local v2 = level <= (ClientState:Get().Level or 0)

	if folder:IsA("BasePart") then
		folder.CanCollide = not v2
	elseif folder:IsA("Model") or folder:IsA("Folder") then
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not v2
			end
		end
	end

	local skipGui = folder:FindFirstChild("SkipGui", true)

	if skipGui then
		local levelText = skipGui:FindFirstChild("LevelText", true)

		if levelText and levelText:IsA("TextLabel") then
			levelText.Text = "(Level " .. level .. " Only)"
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onWallAdded(instance)
	if instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Folder") then
		v[instance] = true
		updateWall(instance)
	end
end

local function onWallRemoved(p)
	v[p] = nil
end

local function onLevelChanged()
	for k in pairs(v) do
		updateWall(k)
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnStart = function()
		if not RunService:IsClient() then
			return
		end

		local tagged = CollectionService:GetTagged("SkipWall")

		for _, v2 in ipairs(tagged) do
			onWallAdded(v2) -- equivalent call inferred; original call site unknown
		end

		CollectionService:GetInstanceAddedSignal("SkipWall"):Connect(onWallAdded)
		CollectionService:GetInstanceRemovedSignal("SkipWall"):Connect(onWallRemoved)
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateUI").OnClientEvent:Connect(function(p)
			if p and p.Level then
				task.defer(onLevelChanged)
			end
		end)
	end
})
return {}