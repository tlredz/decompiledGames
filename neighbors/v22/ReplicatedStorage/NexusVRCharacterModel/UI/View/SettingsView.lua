local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent.Parent
local NexusButton = require(parent:WaitForChild("Packages"):WaitForChild("NexusButton"))
local CameraService = require(parent:WaitForChild("State"):WaitForChild("CameraService"))
local instance = CameraService.GetInstance()
local ControlService = require(parent:WaitForChild("State"):WaitForChild("ControlService"))
local instance2 = ControlService.GetInstance()
local DefaultCursorService = require(parent:WaitForChild("State"):WaitForChild("DefaultCursorService"))
local instance3 = DefaultCursorService.GetInstance()
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance4 = Settings.GetInstance()
local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
local instance5 = VRInputService.GetInstance()
require(parent:WaitForChild("UI"):WaitForChild("View"):WaitForChild("ApiBaseView"))
local default = NexusButton.TextButtonFactory.CreateDefault(Color3.fromRGB(0, 170, 255))
default:SetDefault("Theme", "RoundedCorners")
local SettingsView = {}
SettingsView.__index = SettingsView

function SettingsView.new(object)
	object:AddBackground()
	local object2 = setmetatable({}, SettingsView)
	local container = object:GetContainer()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
	imageLabel.Position = UDim2.new(0.3, 0, -0.075, 0)
	imageLabel.Image = "http://www.roblox.com/asset/?id=1499731139"
	imageLabel.Parent = container
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
	textLabel.Position = UDim2.new(0.1, 0, 0.225, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = "Nexus VR Character Model"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = container
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(0.8, 0, 0.11, 0)
	frame.Position = UDim2.new(0.1, 0, 0.325, 0)
	frame.Parent = container
	object2:PopulateSettingsFrame(frame, "View", function()
		if VRService.AvatarGestures then
			return { "Default" }
		end

		return instance4:GetSetting("Camera.EnabledCameraOptions") or {}
	end, function()
		return instance.ActiveCamera
	end, function(p)
		instance:SetActiveCamera(p)
	end)
	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(0.8, 0, 0.11, 0)
	frame2.Position = UDim2.new(0.1, 0, 0.475, 0)
	frame2.Parent = container
	object2:PopulateSettingsFrame(frame2, "Control", "Movement.EnabledMovementMethods", function()
		return instance2.ActiveController
	end, function(p)
		instance2:SetActiveController(p)
	end)
	local frame3 = Instance.new("Frame")
	frame3.BackgroundTransparency = 1
	frame3.Size = UDim2.new(0.8, 0, 0.11, 0)
	frame3.Position = UDim2.new(0.1, 0, 0.625, 0)
	frame3.Parent = container
	object2:PopulateSettingsFrame(frame3, "Roblox VR Cursor", function()
		return instance3.CursorOptionsList
	end, function()
		return instance3.CurrentCursorState
	end, function(p)
		instance3:SetCursorState(p)
	end)
	local v, v2 = default:Create()
	v.Size = UDim2.new(0.4, 0, 0.075, 0)
	v.Position = UDim2.new(VRService.AvatarGestures and 0.3 or 0.075, 0, 0.85, 0)
	v.SizeConstraint = Enum.SizeConstraint.RelativeYY
	v.Parent = container
	v2.Text = "Recenter"
	v.MouseButton1Down:Connect(function()
		if VRService.AvatarGestures then
			UserInputService:RecenterUserHeadCFrame()
		else
			instance5:Recenter()
		end
	end)

	if not VRService.AvatarGestures then
		local v3, v4 = default:Create()
		v3.Size = UDim2.new(0.4, 0, 0.075, 0)
		v3.Position = UDim2.new(0.525, 0, 0.85, 0)
		v3.SizeConstraint = Enum.SizeConstraint.RelativeYY
		v3.Parent = container
		v4.Text = " Set Eye Level "
		v3.MouseButton1Down:Connect(function()
			instance5:SetEyeLevel()
		end)
	end

	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.AnchorPoint = Vector2.new(0.5, 1)
	textLabel2.Size = UDim2.new(0.8, 0, 0.04, 0)
	textLabel2.Position = UDim2.new(0.5, 0, 1, 0)
	textLabel2.Font = Enum.Font.SourceSansBold
	textLabel2.Text = `Version {instance4:GetSetting("Version.Tag")} ({instance4:GetSetting("Version.Commit")})`
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel2.TextStrokeTransparency = 0
	textLabel2.Parent = container
	return SettingsView
end

function SettingsView:PopulateSettingsFrame(parent2, text: string, fn, callback, callback2)
	local v

	if typeof(fn) == "string" then
		v = fn

		fn = function()
			return instance4:GetSetting(v) or {}
		end
	else
		v = nil
	end

	local v2, v3 = default:Create()
	v2.Size = UDim2.new(1, 0, 1, 0)
	v2.Position = UDim2.new(0, 0, 0, 0)
	v2.SizeConstraint = Enum.SizeConstraint.RelativeYY
	v2.Parent = parent2
	v3.Text = "<"
	local v4, v5 = default:Create()
	v4.AnchorPoint = Vector2.new(1, 0)
	v4.Size = UDim2.new(1, 0, 1, 0)
	v4.Position = UDim2.new(1, 0, 0, 0)
	v4.SizeConstraint = Enum.SizeConstraint.RelativeYY
	v4.Parent = parent2
	v5.Text = ">"
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0.8, 0, 0.5, 0)
	textLabel.Position = UDim2.new(0.1, 0, -0.0125, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = parent2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(0.6, 0, 0.7, 0)
	textLabel2.Position = UDim2.new(0.2, 0, 0.3, 0)
	textLabel2.Font = Enum.Font.SourceSansBold
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel2.TextStrokeTransparency = 0
	textLabel2.Parent = parent2

	local function UpdateSettings(p: number?)
		local v6 = callback()
		local v7 = fn()
		local v8 = 1

		for k, v10 in v7 do
			if v10 ~= v6 then
				continue
			end

			v8 = k
			break
		end

		if p and p ~= 0 then
			local v10 = v8 + p
			local v11 = v10 <= 0 and #v7 or v10
			v8 = #v7 < v11 and 1 or v11
		end

		v2.Visible = #v7 > 1
		v4.Visible = #v7 > 1
		textLabel2.Text = v7[v8] or "(N/A)"

		if p and p ~= 0 and v7[v8] then
			callback2(v7[v8])
		end
	end

	local v6 = true

	if v then
		instance4:GetSettingsChangedSignal(v):Connect(UpdateSettings)
	end

	v2.MouseButton1Down:Connect(function()
		if not v6 then
			return
		end

		v6 = false
		UpdateSettings(-1)
		task.wait()
		v6 = true
	end)
	v4.MouseButton1Down:Connect(function()
		if not v6 then
			return
		end

		v6 = false
		UpdateSettings(1)
		task.wait()
		v6 = true
	end)
	UpdateSettings()
end

return SettingsView