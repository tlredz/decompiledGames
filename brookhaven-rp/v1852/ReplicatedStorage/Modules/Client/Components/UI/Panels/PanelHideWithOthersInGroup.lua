local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PanelHideWithOthersInGroup"
})
local v2 = false
local v3 = false

function v:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v3 = PanelController
	local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	v2 = Panel
end

function v:Start()
	if not v3.GetPanelContextByInstance(self.Instance) then
		warn("PanelHideWithOthersInGroup has no panel context")
		return
	end

	if not self.Instance:GetAttribute("HideToGroup") then
		warn("PanelHideWithOthersInGroup has no group name", self.Instance)
		return
	end

	local parts = self.Instance:GetAttribute("HideToGroup"):split(",")
	self._Janitor:Add(v3.OnPanelOpened:Connect(function(_, p2)
		if p2 == self.Instance.Name then
			return
		end

		local total = 0

		for _, part in parts do
			total += #v3.GetOpenPanelsByGroup(part)
		end

		if total > 0 then
			self.Instance.Visible = false
		else
			self.Instance.Visible = true
		end
	end))
	self._Janitor:Add(v3.OnPanelClosed:Connect(function(_, p2)
		if p2 == self.Instance.Name then
			return
		end

		local total = 0

		for _, part in parts do
			total += #v3.GetOpenPanelsByGroup(part)
		end

		if total == 0 then
			self.Instance.Visible = true
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v