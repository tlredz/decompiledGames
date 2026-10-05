local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local v = Component.new({
	Tag = "HouseLeaveConfirmation"
})

local function openCatalog(panel)
	for _, frame in panel:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	local catalog = panel:WaitForChild("Catalog")
	catalog.Visible = true
	local menu = panel:WaitForChild("Menu")
	menu.Visible = true
end

local function onYesActivated(p)
	local name = PanelController.GetPanelContextByInstance(p.Instance).Name
	local panel = PanelController.GetPanelByInstance(p.Instance)
	local name2 = panel.Name

	if name2 == nil then
		warn("No panel name found for button", p.Instance)
		return
	end

	openCatalog(panel)
	PanelController.Close(name, name2)
	LotController.Unclaim()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onNoActivated(p)
	local panel = PanelController.GetPanelByInstance(p.Instance)

	if panel == nil then
		warn("HouseLeaveConfirmation: Panel not found", p.Instance)
	else
		openCatalog(panel)
	end
end

function v:Construct()
	self._janitor = Janitor.new()
end

function v:Start()
	self._janitor:Add(self.Instance.Yes.Activated:Connect(function()
		onYesActivated(self)
	end))
	self._janitor:Add(self.Instance.No.Activated:Connect(function()
		onNoActivated(self) -- equivalent call inferred; original call site unknown
	end))
end

function v:Stop()
	self._janitor:Destroy()
end

return v