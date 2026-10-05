local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PrivateServerControlsButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.dbPrivateServer = false
	local instance = self.Instance
	local panelContext = self.Instance:GetAttribute("PanelContext") or "PrivateServerControlsGUI"
	local panelName = self.Instance:GetAttribute("PanelName") or "PrivateServerControlsPanel"
	self._Janitor:Add(instance.Activated:Connect(function()
		if self.dbPrivateServer == false then
			self.dbPrivateServer = true
			task.delay(0.5, function()
				self.dbPrivateServer = false
			end)

			if PanelController.IsOpen(panelContext, panelName) then
				PanelController.Close(panelContext, panelName)
			else
				PanelController.OpenPanelByContext(panelContext, panelName)
			end
		end
	end))
	local v2 = false
	local enabled = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		self.Instance.Visible = v2 and enabled
	end

	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "PS_GUIVisibility", function(p)
		v2 = p
		updateVisibility() -- equivalent call inferred; original call site unknown
	end))
	local mainGUIHandler = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler")
	self._Janitor:Add(mainGUIHandler:GetPropertyChangedSignal("Enabled"):Connect(function()
		enabled = mainGUIHandler.Enabled
		updateVisibility() -- equivalent call inferred; original call site unknown
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v