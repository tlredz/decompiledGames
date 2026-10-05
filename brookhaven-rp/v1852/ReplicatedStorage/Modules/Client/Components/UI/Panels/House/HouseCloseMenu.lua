local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local v = Component.new({
	Tag = "HouseCloseMenu"
})

local function onActivated(p)
	local panel = PanelController.GetPanelByInstance(p.Instance)

	if panel == nil then
		warn("HouseCloseMenu: Panel not found", p.Instance)
	elseif LotController.GetCurrentHouse() == nil then
		for _, frame in panel:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		local leaveConfirmation = panel:WaitForChild("LeaveConfirmation")
		leaveConfirmation.Visible = true
	else
		local name = PanelController.GetPanelContextByInstance(p.Instance).Name
		local name2 = panel.Name
		PanelController.Close(name, name2)
	end
end

function v:Construct()
	self._janitor = Janitor.new()
end

function v:Start()
	self._janitor:Add(self.Instance.Activated:Connect(function()
		onActivated(self)
	end))
end

function v:Stop()
	self._janitor:Destroy()
end

return v