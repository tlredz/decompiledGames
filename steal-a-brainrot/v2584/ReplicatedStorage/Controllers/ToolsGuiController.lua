local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local frozen = table.freeze({
	"QuantumCloner",
	"SantasSleighPresent",
	"CupidsWingsInvisibility",
	"WaveriderBoost",
	"FlyingBeeAttack",
	"EditSign"
})
local v = {}
local connection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldEnlarge()
	if UserInputService.TouchEnabled then
		return true
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local viewportSize = currentCamera.ViewportSize
	return viewportSize.X < 700 or viewportSize.Y < 500
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScales()
	local v2 = shouldEnlarge() -- equivalent call inferred; original call site unknown
	local scale = v2 and 1.5 or 1

	for _, v4 in v do
		if v4.Parent then
			v4.Scale = scale
		end
	end
end

local function bindToolsGui(screenGui)
	if not screenGui:IsA("ScreenGui") then
		return
	end

	table.clear(v)

	for _, childName in ipairs(frozen) do
		local guiObject = screenGui:FindFirstChild(childName)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		local v2 = guiObject:FindFirstChild("ResponsiveGearScale")

		if not (v2 and v2:IsA("UIScale")) then
			v2 = Instance.new("UIScale")
			v2.Name = "ResponsiveGearScale"
			v2.Parent = guiObject
		end

		table.insert(v, v2)
	end

	updateScales() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindCamera()
	if connection then
		connection:Disconnect()
	end

	local currentCamera = workspace.CurrentCamera
	local v2

	if currentCamera then
		v2 = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScales)
	end

	connection = v2
	updateScales() -- equivalent call inferred; original call site unknown
end

return {
	Start = function(_)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local toolsFrames = playerGui:FindFirstChild("ToolsFrames")

		if toolsFrames then
			bindToolsGui(toolsFrames)
		end

		playerGui.ChildAdded:Connect(function(child)
			if child.Name == "ToolsFrames" then
				bindToolsGui(child)
			end
		end)
		UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(updateScales)
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
		bindCamera() -- equivalent call inferred; original call site unknown
	end
}