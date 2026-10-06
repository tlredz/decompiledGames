local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local EmoteMountService = require(ReplicatedStorage.Engine.Service.EmoteMountService)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local localPlayer = Players.LocalPlayer
local parent = script.Parent

local function readDisplaySpot(childName: string)
	local child = parent:WaitForChild(childName)
	local humanoidRootPart = child:WaitForChild("HumanoidRootPart")
	local humanoid = child:FindFirstChildOfClass("Humanoid")
	local bodyHeightScale = humanoid and humanoid:FindFirstChild("BodyHeightScale")
	local v = {
		cframe = humanoidRootPart.CFrame,
		scale = bodyHeightScale and bodyHeightScale:IsA("NumberValue") and bodyHeightScale.Value or 1
	}
	child:Destroy()
	return v
end

local spot2 = readDisplaySpot("左侧Rig")
local spot3 = readDisplaySpot("右侧Rig")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

if not localPlayer:HasAppearanceLoaded() then
	localPlayer.CharacterAppearanceLoaded:Wait()
end

local appliedDescription = character:WaitForChild("Humanoid"):GetAppliedDescription()

local function buildDisplayClone(spot)
	local clone = appliedDescription:Clone()
	clone.HeightScale = spot.scale
	clone.WidthScale = spot.scale
	clone.DepthScale = spot.scale
	clone.HeadScale = spot.scale
	local folder = Players:CreateHumanoidModelFromDescriptionAsync(clone, Enum.HumanoidRigType.R15)
	clone:Destroy()
	folder.Name = "飞行器展示人形"
	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayDistance = 0
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end

	folder.Parent = parent
	folder:PivotTo(spot.cframe)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.Anchored = true
	return folder
end

local v3 = {
	{
		spot = spot2,
		clone = nil,
		mountFolder = nil,
		track = nil
	},
	{
		spot = spot3,
		clone = nil,
		mountFolder = nil,
		track = nil
	}
}

for _, v4 in ipairs(v3) do
	v4.clone = buildDisplayClone(v4.spot)
end

local v4 = {}

for _, v5 in GachaPool.getAllEntries() do
	if v5.itemType == "飞行器" and v5.weight > 0 then
		v4[v5.targetId] = true
	end
end

local function pickTwoDistinctSkins()
	local v5 = Config.skin.bySkinType["飞行器"] or {}
	local v6 = {}

	for _, v7 in ipairs(v5) do
		if v4[v7.cnId] then
			table.insert(v6, v7)
		end
	end

	if #v6 == 0 then
		return nil, nil
	end

	local v7 = v6[math.random(1, #v6)]

	if #v6 == 1 then
		return v7, v7
	end

	local v8

	repeat
		v8 = v6[math.random(1, #v6)]
	until v8 ~= v7

	return v7, v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySkin(state, p)
	if state.track or state.mountFolder then
		EmoteMountService.client.unmountLocal(state.mountFolder, state.track)
		state.mountFolder = nil
		state.track = nil
	end

	if not p then
		return
	end

	local mountFolder, track = EmoteMountService.client.mountLocal(state.clone, p.assetName)
	state.mountFolder = mountFolder
	state.track = track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function switchSkins()
	local v5, v6 = pickTwoDistinctSkins()
	applySkin(v3[1], v5) -- equivalent call inferred; original call site unknown
	applySkin(v3[2], v6) -- equivalent call inferred; original call site unknown
end

switchSkins() -- equivalent call inferred; original call site unknown

while true do
	task.wait(5)
	switchSkins() -- equivalent call inferred; original call site unknown
end