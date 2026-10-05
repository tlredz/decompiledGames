local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HideOnPanelActive"
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

function v.Start(p)
	local panelToHideTo = p.Instance:GetAttribute("PanelToHideTo")

	if not panelToHideTo then
		warn("HideOnPanelActive has no PanelToHideTo attribute")
		return
	end

	local panelContext = p.Instance:GetAttribute("PanelContext")

	if panelContext == nil then
		local panelContext2 = v3.GetPanelContextByInstance(p.Instance)

		if panelContext2 then
			panelContext = panelContext2.Name
		else
			warn("HideOnPanelActive has no panel context")
			return
		end
	end

	local v4 = v3.WaitForPanel(panelContext, panelToHideTo)

	if not v4 then
		warn("HideOnPanelActive has no panel")
		return
	end

	v4:RegisterListener(p, v4.Events.Opening, function(_)
		p.Instance.Visible = false
	end)
	v4:RegisterListener(p, v4.Events.Closing, function(_)
		p.Instance.Visible = true
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v