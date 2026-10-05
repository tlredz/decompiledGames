local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NewUserUpsell = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.NewUserUpsell)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NewUserUpsellController = {}
local v = Purchasable.ofGamepass(Gamepasses.PREMIUM)

function NewUserUpsellController.FrameworkInit() end

function NewUserUpsellController.FrameworkStart()
	Remotes.connect("PromptUpsell", function(flag: boolean, p: string)
		NewUserUpsellController.PromptPremiumUpsell(flag, p)
	end)
end

function NewUserUpsellController.PromptPremiumUpsell(visible: boolean, p: string)
	PopupQueue.RegisterHandler("MainGUIHandler", p, function() end)
	local instance = assert(PanelController.WaitForPanel("MainGUIHandler", p)).Instance

	if not NewUserUpsell:WaitForInstance(instance):expect():SetPurchasable(v) then
		return
	end

	local textValue = instance:FindFirstChild("TextValue")

	if textValue ~= nil then
		textValue.Value.Visible = visible
	end

	PopupQueue.Dispatch("MainGUIHandler", p)
end

return NewUserUpsellController