local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent.Parent
local NexusButton = require(parent:WaitForChild("Packages"):WaitForChild("NexusButton"))
local NexusVRCore = require(parent:WaitForChild("Packages"):WaitForChild("NexusVRCore"))
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
local instance2 = VRInputService.GetInstance()
local ApiBaseView = require(parent:WaitForChild("UI"):WaitForChild("View"):WaitForChild("ApiBaseView"))
local EnigmaView = require(parent:WaitForChild("UI"):WaitForChild("View"):WaitForChild("EnigmaView"))
local SettingsView = require(parent:WaitForChild("UI"):WaitForChild("View"):WaitForChild("SettingsView"))
local default = NexusButton.TextButtonFactory.CreateDefault(Color3.fromRGB(0, 170, 255))
default:SetDefault("Theme", "RoundedCorners")
local screenGui3D = NexusVRCore.ScreenGui3D
local MainMenu = {}
MainMenu.__index = MainMenu
local v = nil

function MainMenu.new()
	local object = setmetatable({}, MainMenu)
	local screenGui = screenGui3D.new()
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.CanvasSize = Vector2.new(500, 605)
	screenGui.FieldOfView = 0
	screenGui.Easing = 0.25
	object.ScreenGui = screenGui
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(0, 500, 0, 500)
	frame.Parent = screenGui:GetContainer()
	object.ViewAdornFrame = frame
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame2.BackgroundTransparency = 0.6 * GuiService.PreferredTransparency
	frame2.Position = UDim2.new(0, 0, 0, 505)
	frame2.Size = UDim2.new(1, 0, 0, 100)
	frame2.Parent = frame
	GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		frame2.BackgroundTransparency = 0.6 * GuiService.PreferredTransparency
	end)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.25, 0)
	uICorner.Parent = frame2
	local leftButton, v4 = default:Create()
	leftButton.BorderSize = UDim.new(0.075, 0)
	leftButton.Size = UDim2.new(0, 80, 0, 80)
	leftButton.Position = UDim2.new(0, 10, 0, 10)
	leftButton.Parent = frame2
	v4.Text = "<"
	object.LeftButton = leftButton
	local rightButton, v6 = default:Create()
	rightButton.BorderSize = UDim.new(0.075, 0)
	rightButton.Size = UDim2.new(0, 80, 0, 80)
	rightButton.Position = UDim2.new(0, 410, 0, 10)
	rightButton.Parent = frame2
	v6.Text = ">"
	object.RightButton = rightButton
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0, 300, 0, 60)
	textLabel.Position = UDim2.new(0, 100, 0, 20)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = frame2
	object.ViewTextLabel = textLabel
	object.CurrentView = 1
	object.Views = {}
	SettingsView.new(object:CreateView("Settings"))
	EnigmaView.new(object:CreateView("Enigma"), object)
	object:UpdateVisibleView()
	local v7 = true
	leftButton.MouseButton1Down:Connect(function()
		if not v7 then
			return
		end

		v7 = false
		object.CurrentView -= 1

		if object.CurrentView == 0 then
			object.CurrentView = #object.Views
		end

		object:UpdateVisibleView()
		task.wait()
		v7 = true
	end)
	rightButton.MouseButton1Down:Connect(function()
		if not v7 then
			return
		end

		v7 = false
		object.CurrentView += 1

		if object.CurrentView > #object.Views then
			object.CurrentView = 1
		end

		object:UpdateVisibleView()
		task.wait()
		v7 = true
	end)
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return object
end

function MainMenu.GetInstance()
	if not v then
		v = MainMenu.new()
	end

	return v
end

function MainMenu:SetUpOpening()
	local IMAGE_ID = "rbxassetid://6537091378"
	local setting = instance:GetSetting("Menu.MenuToggleGestureActive")
	local enabled = setting == nil or setting
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = Vector3.new()
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Parent = Workspace.CurrentCamera
	local boxHandleAdornment = Instance.new("BoxHandleAdornment")
	boxHandleAdornment.Color3 = Color3.fromRGB(0, 170, 255)
	boxHandleAdornment.AlwaysOnTop = true
	boxHandleAdornment.ZIndex = 0
	boxHandleAdornment.Adornee = part
	boxHandleAdornment.Parent = part
	local part2 = Instance.new("Part")
	part2.Transparency = 1
	part2.Size = Vector3.new()
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.Parent = Workspace.CurrentCamera
	local boxHandleAdornment2 = Instance.new("BoxHandleAdornment")
	boxHandleAdornment2.Color3 = Color3.fromRGB(0, 170, 255)
	boxHandleAdornment2.AlwaysOnTop = true
	boxHandleAdornment2.ZIndex = 0
	boxHandleAdornment2.Adornee = part2
	boxHandleAdornment2.Parent = part2
	local part3 = Instance.new("Part")
	part3.Transparency = 1
	part3.Size = createVector(1, 1, 0)
	part3.Anchored = true
	part3.CanCollide = false
	part3.CanQuery = false
	part3.Parent = Workspace.CurrentCamera
	local part4 = Instance.new("Part")
	part4.Transparency = 1
	part4.Size = createVector(1, 1, 0)
	part4.Anchored = true
	part4.CanCollide = false
	part4.CanQuery = false
	part4.Parent = Workspace.CurrentCamera
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Active = false
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(500, 500)
	surfaceGui.LightInfluence = 0
	surfaceGui.Enabled = enabled
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Adornee = part3
	surfaceGui.Parent = part3
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.ImageTransparency = 1
	imageLabel.BackgroundTransparency = 1
	imageLabel.Rotation = 180
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.Image = IMAGE_ID
	imageLabel.ImageRectSize = Vector2.new(512, 512)
	imageLabel.ImageRectOffset = Vector2.new(0, 0)
	imageLabel.Parent = surfaceGui
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.ImageTransparency = 1
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = UDim2.new(1, 0, 1, 0)
	imageLabel2.ZIndex = 2
	imageLabel2.Image = IMAGE_ID
	imageLabel2.ImageRectSize = Vector2.new(512, 512)
	imageLabel2.ImageRectOffset = Vector2.new(0, 512)
	imageLabel2.Parent = surfaceGui
	local surfaceGui2 = Instance.new("SurfaceGui")
	surfaceGui2.Active = false
	surfaceGui2.Face = Enum.NormalId.Back
	surfaceGui2.CanvasSize = Vector2.new(500, 500)
	surfaceGui2.LightInfluence = 0
	surfaceGui2.Enabled = enabled
	surfaceGui2.AlwaysOnTop = true
	surfaceGui2.Adornee = part3
	surfaceGui2.Parent = part3
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.ImageTransparency = 1
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Size = UDim2.new(1, 0, 1, 0)
	imageLabel3.Image = IMAGE_ID
	imageLabel3.ImageRectSize = Vector2.new(512, 512)
	imageLabel3.ImageRectOffset = Vector2.new(512, 0)
	imageLabel3.Parent = surfaceGui2
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.ImageTransparency = 1
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.Size = UDim2.new(1, 0, 1, 0)
	imageLabel4.ZIndex = 2
	imageLabel4.Image = IMAGE_ID
	imageLabel4.ImageRectSize = Vector2.new(512, 512)
	imageLabel4.ImageRectOffset = Vector2.new(0, 512)
	imageLabel4.Parent = surfaceGui2
	local surfaceGui3 = Instance.new("SurfaceGui")
	surfaceGui3.Active = false
	surfaceGui3.Face = Enum.NormalId.Front
	surfaceGui3.CanvasSize = Vector2.new(500, 500)
	surfaceGui3.LightInfluence = 0
	surfaceGui3.Enabled = enabled
	surfaceGui3.AlwaysOnTop = true
	surfaceGui3.Adornee = part4
	surfaceGui3.Parent = part4
	local imageLabel5 = Instance.new("ImageLabel")
	imageLabel5.ImageTransparency = 1
	imageLabel5.BackgroundTransparency = 1
	imageLabel5.Size = UDim2.new(1, 0, 1, 0)
	imageLabel5.Image = IMAGE_ID
	imageLabel5.ImageRectSize = Vector2.new(512, 512)
	imageLabel5.ImageRectOffset = Vector2.new(512, 0)
	imageLabel5.Parent = surfaceGui3
	local imageLabel6 = Instance.new("ImageLabel")
	imageLabel6.ImageTransparency = 1
	imageLabel6.BackgroundTransparency = 1
	imageLabel6.Size = UDim2.new(1, 0, 1, 0)
	imageLabel6.ZIndex = 2
	imageLabel6.Image = IMAGE_ID
	imageLabel6.ImageRectSize = Vector2.new(512, 512)
	imageLabel6.ImageRectOffset = Vector2.new(0, 512)
	imageLabel6.Parent = surfaceGui3
	local surfaceGui4 = Instance.new("SurfaceGui")
	surfaceGui4.Active = false
	surfaceGui4.Face = Enum.NormalId.Back
	surfaceGui4.CanvasSize = Vector2.new(500, 500)
	surfaceGui4.LightInfluence = 0
	surfaceGui4.Enabled = enabled
	surfaceGui4.AlwaysOnTop = true
	surfaceGui4.Adornee = part4
	surfaceGui4.Parent = part4
	local imageLabel7 = Instance.new("ImageLabel")
	imageLabel7.ImageTransparency = 1
	imageLabel7.BackgroundTransparency = 1
	imageLabel7.Size = UDim2.new(1, 0, 1, 0)
	imageLabel7.Image = IMAGE_ID
	imageLabel7.ImageRectSize = Vector2.new(512, 512)
	imageLabel7.ImageRectOffset = Vector2.new(0, 0)
	imageLabel7.Parent = surfaceGui4
	local imageLabel8 = Instance.new("ImageLabel")
	imageLabel8.BackgroundTransparency = 1
	imageLabel8.Rotation = 180
	imageLabel8.ImageTransparency = 1
	imageLabel8.Size = UDim2.new(1, 0, 1, 0)
	imageLabel8.ZIndex = 2
	imageLabel8.Image = IMAGE_ID
	imageLabel8.ImageRectSize = Vector2.new(512, 512)
	imageLabel8.ImageRectOffset = Vector2.new(0, 512)
	imageLabel8.Parent = surfaceGui4
	instance:GetSettingsChangedSignal("Menu.MenuToggleGestureActive"):Connect(function()
		local setting2 = instance:GetSetting("Menu.MenuToggleGestureActive")
		local enabled2 = setting2 == nil or setting2
		surfaceGui.Enabled = enabled2
		surfaceGui2.Enabled = enabled2
		surfaceGui3.Enabled = enabled2
		surfaceGui4.Enabled = enabled2
	end)
	local v3 = nil
	local v4 = false
	task.spawn(function()
		while true do
			local setting2 = instance:GetSetting("Menu.MenuToggleGestureActive")
			local v5 = setting2 == nil or setting2
			local vRInputs = instance2:GetVRInputs()
			local v6 = vRInputs[Enum.UserCFrame.Head]:Inverse() * vRInputs[Enum.UserCFrame.LeftHand]
			local v7 = vRInputs[Enum.UserCFrame.Head]:Inverse() * vRInputs[Enum.UserCFrame.RightHand]
			local v8 = v6.UpVector.Y < 0
			local v9 = v7.UpVector.Y < 0
			local v10 = v6.LookVector.Z < 0
			local v11 = v7.LookVector.Z < 0
			local v12 = v8 and v10
			local v13 = v9 and v11

			if v5 and v12 and v13 then
				v3 = v3 or tick()
			else
				v3 = nil
				v4 = false
			end

			local v14 = Workspace.CurrentCamera:GetRenderCFrame() * vRInputs[Enum.UserCFrame.Head]:Inverse()
			part.CFrame = v14 * vRInputs[Enum.UserCFrame.LeftHand] * CFrame.new(0, -0.25, 0.25)
			part2.CFrame = v14 * vRInputs[Enum.UserCFrame.RightHand] * CFrame.new(0, -0.25, 0.25)
			part3.CFrame = v14 * vRInputs[Enum.UserCFrame.LeftHand]
			part4.CFrame = v14 * vRInputs[Enum.UserCFrame.RightHand]

			if v3 and not v4 then
				local v15 = (tick() - v3) / 1
				boxHandleAdornment.Size = Vector3.new(0.1, 0, 0.25 * v15)
				boxHandleAdornment2.Size = Vector3.new(0.1, 0, 0.25 * v15)
				boxHandleAdornment.Visible = true
				boxHandleAdornment2.Visible = true

				if v15 >= 1 then
					v4 = true
					task.spawn(function()
						self:Toggle()
					end)
				end
			else
				boxHandleAdornment.Visible = false
				boxHandleAdornment2.Visible = false
			end

			local function UpdateHintParts(p, part5, imageLabel9, imageLabel10, imageLabel11, imageLabel12)
				local tweenInfo = TweenInfo.new(0.25)
				TweenService:Create(part5, tweenInfo, {
					Size = p and createVector(1, 1, 0) or createVector(1.5, 1.5, 0)
				}):Play()
				TweenService:Create(imageLabel9, tweenInfo, {
					ImageTransparency = p and 0 or 1
				}):Play()
				TweenService:Create(imageLabel10, tweenInfo, {
					ImageTransparency = p and 0 or 1
				}):Play()
				TweenService:Create(imageLabel11, tweenInfo, {
					ImageTransparency = p and 0 or 1
				}):Play()
				TweenService:Create(imageLabel12, tweenInfo, {
					ImageTransparency = p and 0 or 1
				}):Play()
			end

			local leftHandHintVisible = self.ScreenGui.Enabled and not v12
			local rightHandHintVisible = self.ScreenGui.Enabled and not v13

			if self.LeftHandHintVisible ~= leftHandHintVisible then
				self.LeftHandHintVisible = leftHandHintVisible
				UpdateHintParts(leftHandHintVisible, part3, imageLabel, imageLabel3, imageLabel2, imageLabel4)
			end

			if self.RightHandHintVisible ~= rightHandHintVisible then
				self.RightHandHintVisible = rightHandHintVisible
				UpdateHintParts(rightHandHintVisible, part4, imageLabel5, imageLabel7, imageLabel6, imageLabel8)
			end

			local rotation = tick() * 10 % 360
			imageLabel.Rotation = rotation
			imageLabel3.Rotation = -rotation
			imageLabel5.Rotation = -rotation
			imageLabel7.Rotation = rotation
			RunService.RenderStepped:Wait()
		end
	end)
end

function MainMenu:Toggle(flag: boolean?)
	if self.ScreenGui.Enabled == flag then
		return
	end

	local v2 = self.ScreenGui.Enabled and 0.6981317007977318 or 0
	local v3 = self.ScreenGui.Enabled and 0 or 0.6981317007977318

	if not self.ScreenGui.Enabled then
		self.ScreenGui.Enabled = true
	end

	local lastTime = tick()

	while tick() - lastTime < 0.25 do
		local v4 = math.sin(((tick() - lastTime) / 0.25 - 0.5) * 3.141592653589793) / 2 + 0.5
		self.ScreenGui.FieldOfView = v2 + (v3 - v2) * v4
		RunService.RenderStepped:Wait()
	end

	if v3 == 0 then
		self.ScreenGui.Enabled = false
	end
end

function MainMenu.RegisterView(p, name: string, p2)
	warn("MainMenu::RegisterView is deprecated and may be removed in the future. Use MainMenu::CreateView instead.")
	p2.Visible = false
	p2.Name = name
	p2.Parent = p.ViewAdornFrame
	table.insert(p.Views, p2)
end

function MainMenu:CreateView(p: string)
	local v2 = ApiBaseView.new(p)
	v2.Frame.Parent = self.ViewAdornFrame
	table.insert(self.Views, v2)
	v2:GetPropertyChangedSignal("Name"):Connect(function()
		self:UpdateVisibleView()
	end)
	v2.Destroyed:Connect(function()
		for i = 1, #self.Views do
			if self.Views[i] ~= v2 then
				continue
			end

			table.remove(self.Views, i)

			if i < self.CurrentView then
				self.CurrentView += -1
				break
			else
				break
			end
		end

		self:UpdateVisibleView()
	end)
	return v2
end

function MainMenu:UpdateVisibleView(p: string?)
	self.LeftButton.Visible = #self.Views > 1
	self.RightButton.Visible = #self.Views > 1

	if p then
		for k, view in self.Views do
			if view.Name ~= p then
				continue
			end

			self.CurrentView = k
			break
		end
	end

	self.ViewTextLabel.Text = self.Views[self.CurrentView].Name

	for k, view in self.Views do
		view.Visible = k == self.CurrentView
	end
end

return MainMenu