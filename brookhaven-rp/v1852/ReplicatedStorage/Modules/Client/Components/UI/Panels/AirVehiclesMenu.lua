local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadableAirVehicleEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableAirVehicleEntriesFilter)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "AirVehiclesMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._airVehicleEntriesJanitor = self._Janitor:AddObject(Janitor, "Destroy")
	self._scrollingFrame = self.Instance.Catalog.Container.ScrollingFrame
	self._spawner = nil
end

function v:Start()
	for _, button in self.Instance.Catalog.Header.CategoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	self._loadableAirVehicleEntries = ComponentUtil.GetComponentFromInstance(
		self._scrollingFrame,
		LoadableAirVehicleEntriesFilter
	)
	local backButton = self.Instance.Catalog.Header.CategoryTabs.BackButton
	local v2 = nil

	local function unbindBackAction()
		if not v2 then
			return
		end

		v2()
		v2 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v2 then
			return
		end

		v2 = BackActionRouter.Bind(function()
			self._loadableAirVehicleEntries:SetCategory(nil)
		end)
	end

	local function updateBackActionBinding()
		if self.Instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v2 then
				return
			end

			v2()
			v2 = nil
		end
	end

	self._updateBackActionBinding = updateBackActionBinding
	self._Janitor:Add(unbindBackAction)
	self._Janitor:Add(self.Instance.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:Connect(function()
		self._loadableAirVehicleEntries:SetCategory(nil)
	end))
	self:SetupLoadable()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v2 then
				return
			end

			v2()
			v2 = nil
		end
	end))

	if self.Instance.Visible and backButton.Visible then
		if not v2 then
			v2 = BackActionRouter.Bind(function()
				self._loadableAirVehicleEntries:SetCategory(nil)
			end)
		end
	elseif v2 then
		v2()
		v2 = nil
	end
end

function v:SetupLoadable()
	self._Janitor:Add(self._loadableAirVehicleEntries.EntryClicked:Connect(function(p)
		self:EntryClicked(p)
	end))
	self._Janitor:Add(self._loadableAirVehicleEntries.CategoryChanged:Connect(function(p)
		self:CategoryChanged(p)
	end))
end

function v:EntryClicked(p2)
	if self._spawner and self._spawner:SpawnVehicle(p2.Name) then
		PanelController.Close("MainGUIHandler", "MainAirVehicleMenu")
	end
end

function v:Open(spawner)
	self._spawner = spawner
	PanelController.OpenPanelByContext("MainGUIHandler", "MainAirVehicleMenu")
	PanelController.Close("MainGUIHandler", "StarterInstructions")
end

function v:CategoryChanged(p2: string?)
	self.Instance.Catalog.Header.CategoryTabs.BackButton.Visible = p2 ~= nil

	if self._updateBackActionBinding then
		self._updateBackActionBinding()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v