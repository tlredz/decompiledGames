local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Crossed"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "RedX"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.9, 0.9)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://6893077263"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2
	imageLabel.Parent = self.Instance
	self._Janitor:Add(imageLabel)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v