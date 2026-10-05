local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ListAutoSizeY"
})

local function getContentWidth(instance)
	local X = instance.AbsoluteCanvasSize.X
	local uIPadding = instance:FindFirstChildOfClass("UIPadding")

	if uIPadding ~= nil then
		X = X - uIPadding.PaddingLeft.Offset - uIPadding.PaddingRight.Offset
	end

	return (math.max(X, 0))
end

local function getChildHeight(guiObject, p: number)
	local uIAspectRatioConstraint = guiObject:FindFirstChildOfClass("UIAspectRatioConstraint")

	if uIAspectRatioConstraint == nil or uIAspectRatioConstraint.AspectRatio <= 0 then
		return guiObject.AbsoluteSize.Y
	end

	if uIAspectRatioConstraint.DominantAxis == Enum.DominantAxis.Width then
		return (guiObject.Size.X.Scale * p + guiObject.Size.X.Offset) / uIAspectRatioConstraint.AspectRatio
	end

	return guiObject.AbsoluteSize.Y
end

function v:_ComputeContentHeight(p2)
	local instance = self.Instance
	local X = instance.AbsoluteCanvasSize.X
	local uIPadding = instance:FindFirstChildOfClass("UIPadding")

	if uIPadding ~= nil then
		X = X - uIPadding.PaddingLeft.Offset - uIPadding.PaddingRight.Offset
	end

	local v2 = math.max(X, 0)
	local count = 0
	local total = 0

	for _, guiObject in self.Instance:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible ~= false) then
			continue
		end

		count += 1
		total += getChildHeight(guiObject, v2)
	end

	if count == 0 then
		return 0
	end

	local v3 = total + (count - 1) * p2.Padding.Offset
	local uIPadding2 = self.Instance:FindFirstChildOfClass("UIPadding")

	if uIPadding2 ~= nil then
		return v3 + uIPadding2.PaddingTop.Offset + uIPadding2.PaddingBottom.Offset
	end

	return v3
end

function v:Resize(p)
	if p == nil or self.deferredResize then
		return
	end

	self.deferredResize = task.defer(function()
		pcall(function()
			local _ComputeContentHeight = self:_ComputeContentHeight(p)

			if _ComputeContentHeight <= 0 then
				self.deferredResize = nil
			else
				self.Instance.CanvasSize = UDim2.new(0, 0, 0, _ComputeContentHeight)
			end
		end)
		self.deferredResize = nil
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local uIListLayout = self.Instance:FindFirstChildOfClass("UIListLayout")

	if uIListLayout == nil then
		warn("ListAutoSizeY requires a UIListLayout to function properly")
		return
	end

	self.originalSize = self.Instance.Size
	self:Resize(uIListLayout)
	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(guiObject)
		self:Resize(uIListLayout)

		if guiObject:IsA("GuiObject") then
			self._Janitor:Add(guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
				self:Resize(uIListLayout)
			end))
		end
	end))
	self._Janitor:Add(self.Instance.ChildRemoved:Connect(function()
		self:Resize(uIListLayout)
	end))

	for _, guiObject in self.Instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			self._Janitor:Add(guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
				self:Resize(uIListLayout)
			end))
		end
	end

	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Resize(uIListLayout)
	end))
	local currentCamera = workspace.CurrentCamera

	if currentCamera ~= nil then
		self._Janitor:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			task.delay(0.05, function()
				self:Resize(uIListLayout)
			end)
		end))
	end

	self._Janitor:Add(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:Resize(uIListLayout)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v