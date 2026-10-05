local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangableColorPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Props.ChangableColorPanel)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ChangableColor"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local clickDetector = self.Instance:FindFirstChild("ClickDetector")

	if not clickDetector then
		warn("No ClickDetector found for " .. self.Instance:GetFullName())
		return
	end

	clickDetector.Parent = self.Instance
	self.clickDetector = clickDetector
	self._Janitor:Add(clickDetector)
	self.labelValue = self.Instance:WaitForChild("LabelValue").Value
end

function v:Start()
	self._Janitor:Add(self.clickDetector.MouseClick:Connect(function(_)
		PanelController.OpenPanelByContext("MainGUIHandler", "ChangableColorPanel")

		for _, v2 in ChangableColorPanel:GetAll() do
			v2:SetCallbacks(self.labelValue.Text, function(p)
				Remotes.fireServerComponent(self.Instance, "ChangableColorText", p)
			end, function(p)
				Remotes.fireServerComponent(self.Instance, "ChangableColorColor", p)
			end)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v