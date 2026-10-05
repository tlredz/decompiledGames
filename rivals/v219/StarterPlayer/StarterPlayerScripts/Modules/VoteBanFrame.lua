local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local voteBanFrame = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("VoteBanFrame")
local color = Color3.fromRGB(255, 50, 50)
local color2 = Color3.fromRGB(127, 25, 25)
local VoteBanFrame = {}
VoteBanFrame.__index = VoteBanFrame

function VoteBanFrame.new(parent, p)
	local self = setmetatable({}, VoteBanFrame)
	self.CreateSound = Signal.new()
	self.Frame = voteBanFrame:Clone()
	self.Icon = self.Frame:WaitForChild("Icon")
	self.Outline = self.Frame:WaitForChild("Outline")
	self.Background = self.Frame:WaitForChild("Background")
	self._parent = parent
	self._size = p or UDim2.new(1, 0, 1, 0)
	self._played = false
	self:_Init()
	return self
end

function VoteBanFrame:Play(p, p2)
	if self._played then
		return
	end

	self._played = true
	local imageColor = not p and color or DuelLibrary:GetTeamColor(p)
	local color3 = Color3.new(imageColor.R * 0.5, imageColor.G * 0.5, imageColor.B * 0.5)
	local imageColor2 = p2 and imageColor or color
	local imageColor3 = p2 and color3 or color2

	if p2 then
		imageColor = color or imageColor
	end

	if p2 then
		color3 = color2 or color3
	end

	self.Icon.ImageColor3 = imageColor2
	self.Icon.Size = UDim2.new(1, -16, 1, -16)
	self.Icon.Position = UDim2.new(0.5, 0, 0.4, 0)
	self.Icon.Rotation = -45
	self.Outline.ImageColor3 = imageColor2
	self.Outline.SliceScale = 0
	self.Background.ImageColor3 = imageColor3
	self.Frame.Visible = true
	TweenService:Create(self.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.75, -16, 0.75, -16),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = 0
	}):Play()
	TweenService:Create(self.Icon, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
		ImageColor3 = imageColor
	}):Play()
	TweenService:Create(self.Outline, TweenInfo.new(0.125, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		SliceScale = 0.375
	}):Play()
	TweenService:Create(self.Outline, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
		ImageColor3 = imageColor
	}):Play()
	TweenService:Create(self.Background, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
		ImageColor3 = color3
	}):Play()
	self.CreateSound:Fire("rbxassetid://115599786018668", 0.75, 1.5, script, true, 5)
	self.CreateSound:Fire("rbxassetid://101678983789054", 0.5, 1, script, true, 5)
end

function VoteBanFrame:Destroy()
	self._played = true
	self.Frame:Destroy()
end

function VoteBanFrame:_Setup()
	self.Frame.Visible = false
	self.Frame.Size = self._size
	self.Frame.Parent = self._parent
end

function VoteBanFrame:_Init()
	self:_Setup()
end

return VoteBanFrame