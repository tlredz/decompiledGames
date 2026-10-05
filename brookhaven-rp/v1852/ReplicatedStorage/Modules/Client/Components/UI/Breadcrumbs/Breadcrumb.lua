local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Breadcrumb"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local BreadcrumbListTracker = require(ReplicatedStorage.Modules.Client.Components.UI.Breadcrumbs.BreadcrumbListTracker)

function v:Construct()
	self._Janitor = Janitor.new()
	local parent = self.Instance.Parent

	if not parent then
		return
	end

	local scrollingFrame = parent:FindFirstAncestorOfClass("ScrollingFrame")
	local imageButton = parent:FindFirstAncestorOfClass("ImageButton")
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"BreadcrumbListTracker",
		BreadcrumbListTracker
	)

	if waitForAncestorComponent then
		self._Janitor:Add(waitForAncestorComponent.OnValidateBreadcrumbs:Connect(function()
			local v2

			if scrollingFrame.AbsolutePosition.Y <= self.Instance.AbsolutePosition.Y and scrollingFrame.AbsolutePosition.Y + scrollingFrame.AbsoluteSize.Y >= self.Instance.AbsolutePosition.Y then
				v2 = scrollingFrame.AbsolutePosition.Y + scrollingFrame.AbsoluteSize.Y >= self.Instance.AbsolutePosition.Y + self.Instance.AbsoluteSize.Y
			else
				v2 = false
			end

			if v2 then
				waitForAncestorComponent:MarkItemViewed(self.Instance.Name)
			end
		end))

		if imageButton then
			self._Janitor:Add(imageButton.Activated:Connect(function()
				waitForAncestorComponent:MarkItemViewed(self.Instance.Name)
			end))
		end
	end
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v