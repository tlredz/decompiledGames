local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local parent = script.Parent.Parent
local NexusButton = require(parent:WaitForChild("Packages"):WaitForChild("NexusButton"))
local NexusVRCore = require(parent:WaitForChild("Packages"):WaitForChild("NexusVRCore"))
local default = NexusButton.TextButtonFactory.CreateDefault(Color3.fromRGB(0, 170, 255))
default:SetDefault("Theme", "RoundedCorners")
local screenGui3D = NexusVRCore.ScreenGui3D
local R6Message = {}
R6Message.__index = R6Message

function R6Message.new()
	local screenGui = screenGui3D.new()
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.CanvasSize = Vector2.new(500, 500)
	screenGui.FieldOfView = 0
	screenGui.Easing = 0.25
	local object = setmetatable({
		ScreenGui = screenGui
	}, R6Message)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
	imageLabel.Position = UDim2.new(0.3, 0, -0.1, 0)
	imageLabel.Image = "http://www.roblox.com/asset/?id=1499731139"
	imageLabel.Parent = screenGui:GetContainer()
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
	textLabel.Position = UDim2.new(0.1, 0, 0.25, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = "R6 Not Supported"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = screenGui:GetContainer()
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(0.8, 0, 0.25, 0)
	textLabel2.Position = UDim2.new(0.1, 0, 0.4, 0)
	textLabel2.Font = Enum.Font.SourceSansBold
	textLabel2.Text = "Nexus VR Character Model does not support using R6. Use R15 instead."
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel2.TextStrokeTransparency = 0
	textLabel2.Parent = screenGui:GetContainer()
	local v2, v3 = default:Create()
	v2.Size = UDim2.new(0.3, 0, 0.1, 0)
	v2.Position = UDim2.new(0.35, 0, 0.7, 0)
	v2.Parent = screenGui:GetContainer()
	v3.Text = "Ok"
	v2.MouseButton1Down:Connect(function()
		object:SetOpen(false)
		screenGui:Destroy()
	end)
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return object
end

function R6Message:SetOpen(flag: boolean)
	local v = flag and 0 or 0.6981317007977318
	local v2 = flag and 0.6981317007977318 or 0

	if flag then
		self.ScreenGui.Enabled = true
	end

	local lastTime = tick()

	while tick() - lastTime < 0.25 do
		local v3 = math.sin(((tick() - lastTime) / 0.25 - 0.5) * 3.141592653589793) / 2 + 0.5
		self.ScreenGui.FieldOfView = v + (v2 - v) * v3
		RunService.RenderStepped:Wait()
	end

	if v2 == 0 then
		self.ScreenGui.Enabled = false
	end
end

function R6Message:Open()
	self:SetOpen(true)
end

return R6Message