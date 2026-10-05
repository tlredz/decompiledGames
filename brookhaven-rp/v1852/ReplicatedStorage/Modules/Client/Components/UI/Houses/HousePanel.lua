local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HousePanel"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v2 = false

function v:SetCurrentOpenPanel(currentOpenPanel)
	if self.currentOpenPanel == currentOpenPanel and self.currentOpenPanel.Visible then
		self:CloseCurrentOpenPanel()
		return
	end

	self:CloseCurrentOpenPanel()
	self.currentOpenPanel = currentOpenPanel
	local name = v2.GetPanelContextByInstance(currentOpenPanel).Name
	v2.Open(name, currentOpenPanel.Name)
end

function v:CloseCurrentOpenPanel()
	if self.currentOpenPanel then
		local name = v2.GetPanelContextByInstance(self.currentOpenPanel).Name
		v2.Close(name, self.currentOpenPanel.Name)
		self.currentOpenPanel = nil
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v2 = PanelController
end

function v:Start()
	local _1Gettin1gHous1e = ReplicatedStorage.RE:FindFirstChild("1Gettin1gHous1e")
	self._Janitor:Add(_1Gettin1gHous1e.OnClientEvent:Connect(function(p)
		if p == "HouseSold" then
			self.Instance:Destroy()
		end
	end))

	local function EvaluateOpenPanels(p)
		if p == self.Instance.Name then
			return
		end

		local openPanels = v2.GetOpenPanelsByGroup(self.Instance:GetAttribute("HideToGroup"))

		if #openPanels > 0 then
			self.Instance.Visible = false
		elseif #openPanels == 0 and self.currentOpenPanel then
			self.Instance.Visible = true
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function EvaluateClosedPanels()
		if #v2.GetOpenPanelsByGroup(self.Instance:GetAttribute("HideToGroup")) == 0 and self.currentOpenPanel then
			self.Instance.Visible = true
		end
	end

	self._Janitor:Add(v2.OnPanelOpened:Connect(function(_, p)
		if p == self.Instance.Name then
			return
		end

		local openPanels = v2.GetOpenPanelsByGroup(self.Instance:GetAttribute("HideToGroup"))

		if #openPanels > 0 then
			self.Instance.Visible = false
		elseif #openPanels == 0 and self.currentOpenPanel then
			self.Instance.Visible = true
		end
	end))
	self._Janitor:Add(v2.OnPanelClosed:Connect(function(_, _)
		EvaluateClosedPanels() -- equivalent call inferred; original call site unknown
	end))
	local openPanels = v2.GetOpenPanelsByGroup(self.Instance:GetAttribute("HideToGroup"))

	if #openPanels > 0 then
		self.Instance.Visible = false
	elseif #openPanels == 0 and self.currentOpenPanel then
		self.Instance.Visible = true
	end

	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		self.Instance.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v