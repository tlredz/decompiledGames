local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local color = Color3.fromRGB(255, 255, 255)
local numberSequence = NumberSequence.new(1)
local numberSequence2 = NumberSequence.new(0)
local v = Component.new({
	Tag = "Radial"
})

function v:Construct()
	self._janitor = Janitor.new()
	self._progress = 0
	self._stroke = nil
	self._gradient = nil
end

function v:Start()
	if not self.Instance:IsA("GuiObject") then
		warn((`[Radial] Expected GuiObject, got {self.Instance.ClassName} at {self.Instance:GetFullName()}`))
		return
	end

	local radialColor = self.Instance:GetAttribute("RadialColor")
	local radialThickness = self.Instance:GetAttribute("RadialThickness")
	local radialBaseTransparency = self.Instance:GetAttribute("RadialBaseTransparency")
	local radialStartAngle = self.Instance:GetAttribute("RadialStartAngle")
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "RadialStroke"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	if typeof(radialColor) ~= "Color3" then
		radialColor = color
	end

	uIStroke.Color = radialColor
	uIStroke.Thickness = typeof(radialThickness) ~= "number" and 4 or radialThickness
	uIStroke.Transparency = typeof(radialBaseTransparency) ~= "number" and 0 or radialBaseTransparency
	uIStroke.Parent = self.Instance
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "RadialGradient"
	uIGradient.Rotation = typeof(radialStartAngle) ~= "number" and -90 or radialStartAngle
	uIGradient.Parent = uIStroke
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = self.Instance
	self._stroke = uIStroke
	self._gradient = uIGradient
	self._janitor:Add(uIStroke)
	self._janitor:Add(uIGradient)
	self._janitor:Add(uICorner)
	local radialInitialProgress = self.Instance:GetAttribute("RadialInitialProgress")
	self:SetProgress(typeof(radialInitialProgress) ~= "number" and 0 or radialInitialProgress)
end

function v:SetProgress(value: number)
	local progress = math.clamp(value, 0, 1)
	self._progress = progress
	local _gradient = self._gradient

	if _gradient == nil then
		return
	end

	if progress <= 0 then
		_gradient.Transparency = numberSequence
		return
	end

	if progress >= 1 then
		_gradient.Transparency = numberSequence2
		return
	end

	local v3 = math.clamp(progress, 0.0001, 0.9998)
	_gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(v3, 0),
		NumberSequenceKeypoint.new(v3 + 0.0001, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
end

function v:GetProgress()
	return self._progress
end

function v:Stop()
	self._janitor:Destroy()
	self._stroke = nil
	self._gradient = nil
end

return v