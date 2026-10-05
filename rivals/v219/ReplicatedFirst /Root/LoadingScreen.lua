local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RenderstepForLoop = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"):WaitForChild("RenderstepForLoop"))
local BetterDebris = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BetterDebris"))
local EventLibrary = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventLibrary"))
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Signal"))
local GlowyBackground = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"):WaitForChild("GlowyBackground"))
local ChickenFooter = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"):WaitForChild("ChickenFooter"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.DeviceSelected = Signal.new()
	self.LoadingScreen = script:WaitForChild("LoadingScreen")
	self.MainFrame = self.LoadingScreen:WaitForChild("MainFrame")
	self.Device = self.MainFrame:WaitForChild("Device")
	self.DeviceTitle = self.Device:WaitForChild("Title")
	self.ConfirmDeviceButton = self.Device:WaitForChild("Confirm")
	self.Controls = self.Device:WaitForChild("Controls")
	self.DesktopButton = self.Controls:WaitForChild("Desktop")
	self.ConsoleButton = self.Controls:WaitForChild("Console")
	self.MobileButton = self.Controls:WaitForChild("Mobile")
	self.GameLogo = self.MainFrame:WaitForChild("GameLogo")
	self.Logo = self.MainFrame:WaitForChild("Logo")
	self.LogoN = self.Logo:WaitForChild("N")
	self.ContainerN = self.LogoN:WaitForChild("Container")
	self.WhiteN = self.ContainerN:WaitForChild("White")
	self.BlackN = self.ContainerN:WaitForChild("Black")
	self.LogoG = self.Logo:WaitForChild("G")
	self.ContainerG = self.LogoG:WaitForChild("Container")
	self.WhiteG = self.ContainerG:WaitForChild("White")
	self.BlackG = self.ContainerG:WaitForChild("Black")
	self._blur = Instance.new("BlurEffect")
	self._connection = nil
	self._chosen_device = nil
	self._chicken_footer = ChickenFooter.new()
	self._glowy_background = GlowyBackground.new("LoadingScreen")
	self:_Init()
	return self
end

function class:Activate()
	self.LoadingScreen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._blur.Parent = Lighting
end

function class:PlayLogoAnimation(value)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	self:_ResetLogo()
	self.Logo.Visible = true
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6384899588"
	sound.Volume = 1
	sound.Parent = script
	sound:Play()
	BetterDebris:AddItem(sound, 20)
	self:_SpiralAnimation(value)
end

function class.SplitLogo(data)
	data.Logo:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.75, true)
	data.LogoN:TweenPosition(UDim2.new(-0.5, 0, 0.5, 0), "InOut", "Sine", 1.5, true)
	data.LogoG:TweenPosition(UDim2.new(1.5, 0, 0.5, 0), "InOut", "Sine", 1.5, true)
	RenderstepForLoop(0, 100, 2, function(p)
		local rotation = (0 + 720 * (p / 100) ^ 2) % 360
		data.LogoN.Rotation = -rotation
		data.LogoG.Rotation = rotation
	end)
end

function class.SetProgress(data, value, value2)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	assert(typeof(value2) == "number", "Argument 2 invalid, expected a number, got " .. tostring(value2))
	local uDim = UDim2.new(1, 0, value, 0)
	local uDim2 = UDim2.new(1, 0, 1 - value, 0)
	data.WhiteN:TweenSize(uDim, "Out", "Quint", value2, true)
	data.BlackN:TweenSize(uDim2, "Out", "Quint", value2, true)
	data.WhiteG:TweenSize(uDim, "Out", "Quint", value2, true)
	data.BlackG:TweenSize(uDim2, "Out", "Quint", value2, true)
end

function class.PickDevice(data, list)
	assert(typeof(list) == "table", "Argument 1 invalid, expected a table, got " .. tostring(list))
	data.Device.Position = UDim2.new(0.5, 0, -0.5, 0)
	data.Device:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 1, true)
	data.Device.Visible = true
	data.DesktopButton.Visible = table.find(list, "Desktop")
	data.ConsoleButton.Visible = table.find(list, "Console")
	data.MobileButton.Visible = table.find(list, "Mobile")
	local v = GuiService
	local selectedObject

	if data.ConsoleButton.Visible then
		selectedObject = data.ConsoleButton or nil
	end

	v.SelectedObject = selectedObject
	local v3 = data.DeviceSelected:Wait()
	GuiService.SelectedObject = nil
	data.Device.Visible = false
	return v3
end

function class.PreRequireClient(p)
	p.GameLogo.Visible = true
	p.GameLogo.Size = UDim2.new(1, 0, 1, 0)
	p.GameLogo:TweenSize(UDim2.new(0.6, 0, 0.6, 0), "Out", "Back", 0.5, true)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://8483887957"
	sound.Volume = 1
	sound.Parent = script
	sound:Play()
	BetterDebris:AddItem(sound, 20)
	wait(0.5)
end

function class:Close()
	self._connection:Disconnect()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	self.MainFrame.Active = false
	self.GameLogo:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quint", 1.5, true)
	self.GameLogo:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Quint", 1.5, true)
	ReplicatedStorage.Remotes.Data.LoadingScreenDone:FireServer()
	self._chicken_footer:Hide()
	self._glowy_background:SetEnabled(false)
	wait(0.5)
	RenderstepForLoop(0, 100, 2, function(p)
		local v = 1 - (1 - p / 100) ^ 3
		self.GameLogo.ImageTransparency = (p / 100) ^ 3
		self._blur.Size = 56 * (1 - v)
	end)
	self:Destroy()
end

function class.Update(p, _)
	local v = tick() * 2 % 6.283185307179586
	local v2 = math.sin(v) * 0.05
	local v3 = math.sin(v - 0.7853981633974483) * 0.05
	p.ContainerN.Position = UDim2.new(0.5, 0, v2 + 0.5, 0)
	p.ContainerG.Position = UDim2.new(0.5, 0, v3 + 0.5, 0)
end

function class:Destroy()
	self._blur:Destroy()
	self._chicken_footer:Destroy()
	self._glowy_background:Destroy()
	self.LoadingScreen:Destroy()
	self.DeviceSelected:Destroy()
end

function class._ClientAlert(_)
	Players.LocalPlayer:WaitForChild("ClientAlert"):FireServer()
end

function class:_ChooseDevice(chosen_device)
	self._chosen_device = chosen_device

	for _, v in pairs({ "Desktop", "Mobile", "Console" }) do
		self[v .. "Button"].Chosen.Visible = v == self._chosen_device
		self[v .. "Button"].Icon.ImageColor3 = v == self._chosen_device and Color3.fromRGB(60, 226, 31) or Color3.fromRGB(
			255,
			255,
			255
		)
	end

	self.ConfirmDeviceButton.Visible = true
end

function class:_SpiralAnimation(value)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	self.LogoN:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", value * 1.5, true)
	self.LogoG:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", value * 1.5, true)
	RenderstepForLoop(0, 100, 1.667 / value, function(p)
		local rotation = (math.sqrt(1 - (p / 100 - 1) ^ 2) * 540 + 180) % 360
		self.Logo.Rotation = rotation
		self.LogoN.Rotation = -rotation
		self.LogoG.Rotation = -rotation
	end)
end

function class:_ResetLogo()
	self.LogoN.Position = UDim2.new(-1, 0, 0.5, 0)
	self.LogoG.Position = UDim2.new(2, 0, 0.5, 0)
	self.WhiteN.Size = UDim2.new(1, 0, 0, 0)
	self.BlackN.Size = UDim2.new(1, 0, 1, 0)
	self.WhiteG.Size = UDim2.new(1, 0, 0, 0)
	self.BlackG.Size = UDim2.new(1, 0, 1, 0)
end

function class:_Setup()
	self._blur.Name = "LoadingScreen"
	self._blur.Size = 56
	self._chicken_footer:Show()
	self._chicken_footer:EnableTimer()
	self._chicken_footer:EnableFunFacts()
	self._chicken_footer:SetStatus("Loading")
	self._chicken_footer:SetParent(self.MainFrame)
	self._glowy_background:SetParent(self.MainFrame)
	self._glowy_background:SetEnabled(true, true)
	self.GameLogo.Image = EventLibrary.IS_ACTIVE and EventLibrary.EVENT_DETAILS.LOADING_SCREEN_LOGO or self.GameLogo.Image
end

function class:_Init()
	self.DesktopButton.MouseButton1Click:Connect(function()
		self:_ChooseDevice("Desktop")
	end)
	self.MobileButton.MouseButton1Click:Connect(function()
		self:_ChooseDevice("Mobile")
	end)
	self.ConsoleButton.MouseButton1Click:Connect(function()
		self:_ChooseDevice("Console")
	end)
	self.ConfirmDeviceButton.MouseButton1Click:Connect(function()
		self.DeviceSelected:Fire(self._chosen_device)
	end)
	self._connection = RunService.RenderStepped:Connect(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	end)
	self:_Setup()
	self:_ResetLogo()
	task.defer(self._ClientAlert, self)
end

return class._new()