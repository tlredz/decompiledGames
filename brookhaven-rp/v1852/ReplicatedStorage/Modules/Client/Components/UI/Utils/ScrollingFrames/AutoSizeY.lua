local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AutoSizeY"
})

function v:Resize(instance)
	if not instance or self.deferredResize then
		return
	end

	self.deferredResize = task.defer(function()
		pcall(function()
			local Y = instance.AbsoluteCellCount.Y

			if Y == 0 then
				return
			end

			if instance.FillDirection == Enum.FillDirection.Vertical and instance.FillDirectionMaxCells > 0 then
				Y = math.min(instance.FillDirectionMaxCells, Y)
			end

			local v2 = self.originalSize.Y.Scale * self.Instance.Parent.AbsoluteSize.Y + self.originalSize.Y.Offset
			local cellSize = instance.CellSize
			local v3 = cellSize.Y.Scale * v2 + cellSize.Y.Offset
			local uIAspectRatioConstraint = instance:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint ~= nil then
				v3 = math.min(v3, instance.AbsoluteCellSize.X / uIAspectRatioConstraint.AspectRatio)
			end

			local v4 = Y * v3
			local cellPadding = instance.CellPadding
			local v5 = v4 + (Y - 1) * cellPadding.Y.Offset + 10
			local v6 = math.min(v5, v2)
			local uDim = UDim2.new(self.originalSize.X.Scale, self.originalSize.X.Offset, 0, v6)
			self.Instance.Size = uDim
			local uDim2 = UDim2.new(0, 0, 0, v5)
			self.Instance.CanvasSize = uDim2
		end)
		self.deferredResize = nil
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")

	if not uIGridLayout then
		warn("AutoSizeY requires a UIGridLayout to function properly")
		return
	end

	self.originalSize = self.Instance.Size
	self:Resize(uIGridLayout)
	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(_)
		self:Resize(uIGridLayout)
	end))
	self._Janitor:Add(self.Instance.ChildRemoved:Connect(function(_)
		self:Resize(uIGridLayout)
	end))
	local currentCamera = workspace.CurrentCamera
	self._Janitor:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		task.delay(0.05, function()
			self:Resize(uIGridLayout)
		end)
	end))
	self._Janitor:Add(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:Resize(uIGridLayout)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v