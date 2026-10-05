local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AvatarEditorAutoSizeY"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)

function v:Resize(p)
	if self.deferredResize then
		return
	end

	self.deferredResize = task.defer(function()
		local absoluteContentSize = p.AbsoluteContentSize
		local uDim = UDim2.new(0, 0, 0, absoluteContentSize.Y)
		self.Instance.CanvasSize = uDim
		self.deferredResize = nil
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local uIGridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self:Resize(uIGridLayout)
	self._Janitor:Add(self.Instance.ChildAdded:Connect(function(_)
		self:Resize(uIGridLayout)
	end))
	self._Janitor:Add(self.Instance.ChildRemoved:Connect(function(_)
		self:Resize(uIGridLayout)
	end))
	local instance = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel):GetInstance()
	self._Janitor:Add(instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Resize(uIGridLayout)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v