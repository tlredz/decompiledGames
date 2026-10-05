local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local Global = require(ReplicatedStorage:WaitForChild("Global"))
local v = {}
local fastMode = Global.FastMode == true

-- equivalent calls inferred from this helper; original call sites unknown
local function forceDisabled(p, p2)
	if not p.Enabled then
		return
	end

	p2.isForcing = true
	p.Enabled = false
	p2.isForcing = false
end

local function disableDepthOfField(depthOfFieldEffect)
	if v[depthOfFieldEffect] then
		return
	end

	local v2 = {
		enabled = depthOfFieldEffect.Enabled,
		isForcing = false
	}
	v2.enabledConnection = depthOfFieldEffect:GetPropertyChangedSignal("Enabled"):Connect(function()
		if v2.isForcing then
			return
		end

		v2.enabled = depthOfFieldEffect.Enabled

		if Global.FastMode == true then
			forceDisabled(depthOfFieldEffect, v2) -- equivalent call inferred; original call site unknown
		end
	end)
	v2.destroyingConnection = depthOfFieldEffect.Destroying:Connect(function()
		v2.enabledConnection:Disconnect()
		v[depthOfFieldEffect] = nil
	end)
	v[depthOfFieldEffect] = v2
	forceDisabled(depthOfFieldEffect, v2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreDepthOfField(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v2.enabledConnection:Disconnect()
	v2.destroyingConnection:Disconnect()
	v[p] = nil

	if p.Parent then
		p.Enabled = v2.enabled
	end
end

local function restoreDepthOfFields()
	local v2 = {}

	for k in v do
		table.insert(v2, k)
	end

	for _, v3 in v2 do
		restoreDepthOfField(v3) -- equivalent call inferred; original call site unknown
	end
end

local function isActiveDepthOfField(instance)
	if instance:IsDescendantOf(Lighting) then
		return true
	end

	local currentCamera = workspace.CurrentCamera
	return currentCamera ~= nil and instance:IsDescendantOf(currentCamera)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onTaggedAdded(depthOfFieldEffect)
	if Global.FastMode == true and depthOfFieldEffect:IsA("DepthOfFieldEffect") then
		local v2

		if depthOfFieldEffect:IsDescendantOf(Lighting) then
			v2 = true
		else
			local currentCamera = workspace.CurrentCamera

			if currentCamera == nil then
				v2 = false
			else
				v2 = depthOfFieldEffect:IsDescendantOf(currentCamera)
			end
		end

		if v2 then
			disableDepthOfField(depthOfFieldEffect)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableTaggedDepthOfFields()
	for _, v2 in CollectionService:GetTagged("FastModeDepthOfField") do
		onTaggedAdded(v2) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFastModeEnabled(fastMode2: boolean)
	if not fastMode2 then
		restoreDepthOfFields()
		return
	end

	disableTaggedDepthOfFields() -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("FastModeDepthOfField"):Connect(onTaggedAdded)
CollectionService:GetInstanceRemovedSignal("FastModeDepthOfField"):Connect(function(depthOfFieldEffect)
	if depthOfFieldEffect:IsA("DepthOfFieldEffect") and not CollectionService:HasTag(
		depthOfFieldEffect,
		"FastModeDepthOfField"
	) then
		restoreDepthOfField(depthOfFieldEffect) -- equivalent call inferred; original call site unknown
	end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if Global.FastMode == true then
		disableTaggedDepthOfFields() -- equivalent call inferred; original call site unknown
	end
end)
RunService:BindToRenderStep("FastModeDepthOfField", Enum.RenderPriority.Last.Value, function()
	local fastMode2 = Global.FastMode == true

	if fastMode2 == fastMode then
		return
	end

	fastMode = fastMode2
	setFastModeEnabled(fastMode) -- equivalent call inferred; original call site unknown
end)

if fastMode then
	disableTaggedDepthOfFields() -- equivalent call inferred; original call site unknown
end