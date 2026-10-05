local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function GetScale()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 1
	end

	local viewportSize = currentCamera.ViewportSize
	return (math.min(viewportSize.X / 1920, viewportSize.Y / 1080))
end

local function ApplyLabel(instance, p: number)
	local authoredTextSize = instance:GetAttribute("AuthoredTextSize")

	if not authoredTextSize then
		authoredTextSize = instance.TextSize
		instance:SetAttribute("AuthoredTextSize", authoredTextSize)
	end

	instance.TextScaled = false
	local v = math.max(1, (math.floor(authoredTextSize * p)))
	instance.TextSize = v * 1.37
	local X = instance.AbsoluteSize.X
	local X2 = instance.TextBounds.X

	if X > 0 and X * 0.95 < X2 then
		instance.TextSize = math.max(1, (math.floor(v * (X * 0.95) / X2)))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyAll()
	local scale = GetScale() -- equivalent call inferred; original call site unknown

	for k in object do
		if k.Parent then
			ApplyLabel(k, scale)
		end
	end
end

local function Track(instance)
	if not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
		return
	end

	if not instance:IsDescendantOf(playerGui) or object[instance] then
		return
	end

	object[instance] = true
	local scale = GetScale() -- equivalent call inferred; original call site unknown
	ApplyLabel(instance, scale)
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		local scale2 = GetScale() -- equivalent call inferred; original call site unknown
		ApplyLabel(instance, scale2)
	end)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local scale2 = GetScale() -- equivalent call inferred; original call site unknown
		ApplyLabel(instance, scale2)
	end)
end

for _, v in CollectionService:GetTagged("UniversalTextSize") do
	Track(v)
end

CollectionService:GetInstanceAddedSignal("UniversalTextSize"):Connect(Track)
playerGui.DescendantAdded:Connect(function(descendant)
	if descendant:HasTag("UniversalTextSize") then
		Track(descendant)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchCamera(currentCamera)
	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyAll)
	end
end

WatchCamera(workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	WatchCamera(workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
	ApplyAll() -- equivalent call inferred; original call site unknown
end)