local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local _ = workspace.CurrentCamera
local v = Component.new({
	Tag = "ScaledTextSizeConstraint"
})

function v:Construct()
	self.trove = Trove.new()
	self._lastAbsSize = Vector2.zero
end

function v:UpdateScale()
	local parent = self.Instance.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	local maxPixelSize = self.Instance:GetAttribute("MaxPixelSize") or 100
	local maxScaledSize = self.Instance:GetAttribute("MaxScaledSize") or 1
	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.Y == self._lastAbsSize.Y then
		return
	end

	self._lastAbsSize = absoluteSize
	self.Instance.MaxTextSize = math.clamp(
		math.floor(absoluteSize.Y * maxScaledSize),
		self.Instance.MinTextSize,
		maxPixelSize
	)
end

function v:Start()
	if not self.Instance:IsA("UITextSizeConstraint") then
		warn((`ScaledTextSizeConstraint component applied to non-UITextSizeConstraint {self.Instance:GetFullName()}`))
		return
	end

	local parent = self.Instance.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	if parent.AutomaticSize == Enum.AutomaticSize.Y or parent.AutomaticSize == Enum.AutomaticSize.XY then
		warn((`ScaledTextSizeConstraint component does not support AutomaticSize values of Y or XY! {self.Instance:GetFullName()}`))
		return
	end

	self.trove:Add(parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdateScale()
	end))
	self:UpdateScale()
end

function v.Stop(p)
	p.trove:Destroy()
end

return v