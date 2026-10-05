local createVector = vector.create
local vector2 = Vector2.new(1920, 1080)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
Players.LocalPlayer:WaitForChild("PlayerGui", 100)
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function getBox(viewportSize: Vector2)
	return (math.min(viewportSize.X, viewportSize.Y))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScreenRatio()
	local box = getBox(currentCamera.ViewportSize) -- equivalent call inferred; original call site unknown
	local v = vector2
	return box / math.min(v.X, v.Y)
end

local function tagRecursive(folder, className: string, tag: string)
	if folder:IsA(className) then
		folder:AddTag(tag)
	end

	folder.DescendantAdded:Connect(function(descendant)
		if descendant:IsA(className) then
			descendant:AddTag(tag)
		end
	end)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA(className) then
			descendant:AddTag(tag)
		end
	end
end

local function getInstancePosition(instance)
	if instance:IsA("Part") then
		return instance.Position
	end

	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	return createVector(0, 0, 0)
end

local function initTaggedUIStroke(uIStroke)
	if uIStroke:IsA("UIStroke") and uIStroke.StrokeSizingMode ~= Enum.StrokeSizingMode.ScaledSize then
		local originalThickness = uIStroke:GetAttribute("OriginalThickness")

		if not originalThickness then
			originalThickness = uIStroke.Thickness
			uIStroke:SetAttribute("OriginalThickness", originalThickness)
		end

		if uIStroke:HasTag("ScreenStroke") then
			uIStroke.Thickness = originalThickness * getScreenRatio()
		end
	else
		uIStroke:RemoveTag("ScreenStroke")
		uIStroke:RemoveTag("UIStroke")
	end
end

for _, v in CollectionService:GetTagged("UIStroke") do
	initTaggedUIStroke(v)
end

CollectionService:GetInstanceAddedSignal("UIStroke"):Connect(initTaggedUIStroke)

for _, v in CollectionService:GetTagged("ScreenStroke") do
	v:AddTag("UIStroke")
end

CollectionService:GetInstanceAddedSignal("ScreenStroke"):Connect(function(instance)
	instance:AddTag("UIStroke")
end)

for _, screenGui in CollectionService:GetTagged("ScreenGui") do
	if screenGui:IsA("ScreenGui") then
		tagRecursive(screenGui, "UIStroke", "ScreenStroke")
	else
		screenGui:RemoveTag("ScreenGui")
	end
end

CollectionService:GetInstanceAddedSignal("ScreenGui"):Connect(function(screenGui)
	if not screenGui:IsA("ScreenGui") then
		return
	end

	tagRecursive(screenGui, "UIStroke", "ScreenStroke")
end)

local function updateScreenGuiStrokes()
	for _, v in CollectionService:GetTagged("ScreenStroke") do
		local originalThickness = v:GetAttribute("OriginalThickness")

		if originalThickness then
			v.Thickness = originalThickness * getScreenRatio()
		end
	end
end

currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScreenGuiStrokes)
local v = {}
local recurseGetUIStrokes

recurseGetUIStrokes = function(uIStroke, p)
	if uIStroke:IsA("UIStroke") then
		uIStroke:AddTag("UIStroke")
		table.insert(v[p], uIStroke)
	end

	for _, child in uIStroke:GetChildren() do
		recurseGetUIStrokes(child, p)
	end

	uIStroke.ChildAdded:Connect(function(child)
		recurseGetUIStrokes(child, p)
	end)
end

local function initBillboard(billboardGui)
	if not billboardGui:IsA("BillboardGui") then
		billboardGui:RemoveTag("Billboard")
		return
	end

	v[billboardGui] = {}
	billboardGui.Destroying:Once(function()
		v[billboardGui] = nil
	end)
	recurseGetUIStrokes(billboardGui, billboardGui)
end

for _, v2 in CollectionService:GetTagged("Billboard") do
	initBillboard(v2)
end

CollectionService:GetInstanceAddedSignal("Billboard"):Connect(initBillboard)
local lastTime = tick()
RunService.Heartbeat:Connect(function()
	if tick() - lastTime < 1 then
		return
	end

	lastTime = tick()
	debug.profilebegin("Update UIStrokes")

	for k, list in v do
		local adornee = k.Adornee
		local position = nil

		if adornee then
			if adornee:IsA("Part") then
				position = adornee.Position
			else
				position = not adornee:IsA("Model") and createVector(0, 0, 0) or adornee:GetPivot().Position
			end
		elseif k.Parent then
			local parent = k.Parent

			if parent:IsA("Part") then
				position = parent.Position
			else
				position = not parent:IsA("Model") and createVector(0, 0, 0) or parent:GetPivot().Position
			end
		end

		if not position then
			continue
		end

		local magnitude = (currentCamera.CFrame.Position - position).Magnitude

		if k.MaxDistance < magnitude then
			continue
		end

		local v2 = (k:GetAttribute("Distance") or 10) / magnitude

		for _, v3 in list do
			if not v3:IsDescendantOf(k) then
				table.remove(list, table.find(list, v3))
			end

			local originalThickness = v3:GetAttribute("OriginalThickness")

			if originalThickness then
				v3.Thickness = originalThickness * v2 * getScreenRatio()
			end
		end
	end

	debug.profileend()
end)
local UIStrokeAdjuster = {}

function UIStrokeAdjuster.TagScreenGui(_, screenGui)
	if screenGui:IsA("ScreenGui") then
		CollectionService:AddTag(screenGui, "ScreenGui")
	end
end

function UIStrokeAdjuster.TagBillboardGui(_, billboardGui)
	if billboardGui:IsA("BillboardGui") then
		CollectionService:AddTag(billboardGui, "Billboard")
	end
end

return UIStrokeAdjuster