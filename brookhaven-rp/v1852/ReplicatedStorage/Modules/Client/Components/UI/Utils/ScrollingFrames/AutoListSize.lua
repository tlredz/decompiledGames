local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AutoListSize"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local uIListLayout = self.Instance:WaitForChild("UIListLayout")

	local function onContentSizeChanged()
		local absoluteContentSize = uIListLayout.AbsoluteContentSize
		local v2 = uIListLayout.FillDirection == Enum.FillDirection.Horizontal
		local uIPadding = self.Instance:WaitForChild("UIPadding")

		if v2 then
			local v3 = not uIPadding and 0 or uIPadding.PaddingLeft.Offset + uIPadding.PaddingRight.Offset
			self.Instance.CanvasSize = UDim2.new(0, absoluteContentSize.X + v3, 0, 0)
		else
			local v3 = not uIPadding and 0 or uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, absoluteContentSize.Y + v3)
		end

		local scale = self.Instance:GetAttribute("Scale")

		for _, guiObject in self.Instance:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if v2 then
				guiObject.Size = UDim2.new(0, scale * self.Instance.AbsoluteWindowSize.X, 1, 0)
			else
				guiObject.Size = UDim2.new(1, 0, 0, scale * self.Instance.AbsoluteWindowSize.Y)
			end
		end
	end

	local flag = false

	local function deferContentSizeChanged()
		if flag then
			return
		end

		flag = true
		task.delay(0, function()
			flag = false
			onContentSizeChanged()
		end)
	end

	onContentSizeChanged()
	self._Janitor:Add(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(deferContentSizeChanged))
	self._Janitor:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(deferContentSizeChanged))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v