local Players = game:GetService("Players")
Players.LocalPlayer:WaitForChild("PlayerGui")
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function GetScale()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return (math.clamp(currentCamera.ViewportSize.Y / 1080, 0.35, 1))
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyStroke(instance, p: number)
	local authoredThickness = instance:GetAttribute("AuthoredThickness")

	if not authoredThickness then
		authoredThickness = instance.Thickness
		instance:SetAttribute("AuthoredThickness", authoredThickness)
	end

	if instance:FindFirstAncestorOfClass("SurfaceGui") then
		return
	end

	instance.Thickness = authoredThickness * p * 1.73
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyAll()
	local scale = GetScale() -- equivalent call inferred; original call site unknown

	for k in object do
		if not k.Parent then
			continue
		end

		ApplyStroke(k, scale) -- equivalent call inferred; original call site unknown
	end
end

local function Track(uIStroke)
	if uIStroke:IsA("UIStroke") then
		object[uIStroke] = true
		local scale = GetScale() -- equivalent call inferred; original call site unknown
		local authoredThickness = uIStroke:GetAttribute("AuthoredThickness")

		if not authoredThickness then
			authoredThickness = uIStroke.Thickness
			uIStroke:SetAttribute("AuthoredThickness", authoredThickness)
		end

		if uIStroke:FindFirstAncestorOfClass("SurfaceGui") then
			return
		else
			uIStroke.Thickness = authoredThickness * scale * 1.73
		end
	end
end

for _, uIStroke in game:GetDescendants() do
	if not uIStroke:IsA("UIStroke") then
		continue
	end

	object[uIStroke] = true
	local scale = GetScale() -- equivalent call inferred; original call site unknown
	ApplyStroke(uIStroke, scale) -- equivalent call inferred; original call site unknown
end

game.DescendantAdded:Connect(Track)

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
ApplyAll() -- equivalent call inferred; original call site unknown