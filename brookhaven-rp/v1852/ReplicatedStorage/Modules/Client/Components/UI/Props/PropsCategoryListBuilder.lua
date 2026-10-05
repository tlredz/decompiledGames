local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsCategoryListBuilder"
})
local v2 = false
local TempVisibilityRoot = require(ReplicatedStorage.Modules.Client.Components.UI.TempVisibilityRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
	local PropsConfig = require(ReplicatedStorage.Modules.Shared.DB.Props.PropsConfig)
	v2 = PropsConfig
	self._TempVisibilityRoot = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"TempVisibilityRoot",
		TempVisibilityRoot
	)
	self.frames = {}
end

function v:Build()
	local TEMPLATE = self.Instance:FindFirstChild("TEMPLATE")
	local categoriesConfig = v2.GetCategoriesConfig()

	for k, v3 in categoriesConfig do
		local clone = TEMPLATE:Clone()
		clone.Visible = true
		clone.LayoutOrder = v3.LayoutOrder
		clone.Icon.Image = v3.Icon
		table.insert(self.frames, clone)
		clone.Name = k
		clone.Parent = self.Instance
	end

	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.Instance.UIGridLayout.AbsoluteContentSize.Y)
end

function v:Clear()
	for _, frame in self.frames do
		frame:Destroy()
	end

	self.frames = {}
end

function v:Start()
	self._Janitor:Add(self._TempVisibilityRoot.OnVisibleChanged:Connect(function(p)
		if p then
			self:Build()
		else
			self:Clear()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self:Clear()
end

return v