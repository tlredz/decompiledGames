local GamepassNeededController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local thread = nil

function GamepassNeededController.FrameworkInit() end

function GamepassNeededController.FrameworkStart() end

function GamepassNeededController.Show(object, p: string?)
	local infoClient = object:GetInfoClient()

	if infoClient == nil then
		return
	end

	local instance = PanelController.WaitForPanel("NoResetGUIHandler", "GamepassNeeded"):GetInstance()
	local text = instance:WaitForChild("OuterBox"):WaitForChild("Text")
	text.Text = p or instance:GetAttribute("GamepassNeeded_Text"):format(infoClient.Name)

	if not PanelController.IsOpen("NoResetGUIHandler", "GamepassNeeded") then
		PanelController.Open("NoResetGUIHandler", "GamepassNeeded")
	end

	if thread ~= nil then
		task.cancel(thread)
	end

	thread = task.delay(3, function()
		thread = nil
		text.Text = ""
		PanelController.Close("NoResetGUIHandler", "GamepassNeeded")
	end)
end

return GamepassNeededController