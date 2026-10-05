local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local currentCamera = workspace.CurrentCamera
local v = 1
local v2 = {}
local thread = nil
local v3 = {}
local v4 = 0

local function getThicknessSize(p: number)
	local v5 = v2[p]

	if v5 then
		return v5
	end

	local v6 = p * v
	v2[p] = v6
	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStrokeThickness(instance)
	local strokeThickness = instance:GetAttribute("StrokeThickness") or 1
	local thickness = v2[strokeThickness]

	if not thickness then
		thickness = strokeThickness * v
		v2[strokeThickness] = thickness
	end

	instance.Thickness = thickness
end

local function updateStrokes()
	local viewportSize = currentCamera.ViewportSize
	v = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)

	for _, v5 in v3 do
		updateStrokeThickness(v5) -- equivalent call inferred; original call site unknown
	end

	v2 = {}
	thread = nil
end

currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if thread then
		task.cancel(thread)
	end

	thread = task.delay(1, updateStrokes)
end)
return Observers.observeTagNoAncestry("UI_DynamicUIStroke", function(instance)
	if instance:IsDescendantOf(ReplicatedStorage) then
		return
	end

	instance:SetAttribute("StrokeThickness", instance.Thickness)
	updateStrokeThickness(instance) -- equivalent call inferred; original call site unknown
	local strokeThicknessChangedConnection = instance:GetAttributeChangedSignal("StrokeThickness"):Connect(function()
		updateStrokeThickness(instance) -- equivalent call inferred; original call site unknown
	end)
	local v5 = v4 + 1
	v4 = v5
	v3[v5] = instance
	return function()
		strokeThicknessChangedConnection:Disconnect()
		v3[v5] = nil
	end
end)