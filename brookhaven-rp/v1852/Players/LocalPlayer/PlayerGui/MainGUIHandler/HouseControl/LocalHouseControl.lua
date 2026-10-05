local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player8Handler = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler")
local Game8Settings = require(player8Handler:WaitForChild("Game8Settings"))
local playersHouse = Game8Settings.PlayersHouse
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
playersHouse.OnClientEvent:Connect(function(p)
	if p == "OpenHouseControl" then
		PanelController.Toggle("MainGUIHandler", "HouseControlPanel")
	elseif p == "AskPlayerIfWantsFire" then
		PanelController.ToggleGroup("HouseModal", false)
		PanelController.Open("MainGUIHandler", "ModalFireAsk")
	elseif p == "OpenHouseControlFire" then
		PanelController.ToggleGroup("HouseModal", false)
		PanelController.Open("MainGUIHandler", "ModalFireAskFirePass")
	elseif p == "OpenHouseBabyOption" then
		PanelController.ToggleGroup("HouseModal", false)
		PanelController.Open("MainGUIHandler", "ModalBabyAsk")
	elseif p == "OpenHouseControlDisaster" then
		PanelController.ToggleGroup("HouseModal", false)
		PanelController.Open("MainGUIHandler", "ModalDisasterControls")
	end
end)