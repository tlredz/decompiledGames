local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local GuiHandler = require(game.ReplicatedStorage.ClientGameModules.GuiHandler)
local Replion = require(game.ReplicatedStorage.Packages.Replion)
local v = Replion.Client:WaitReplion("Data")
require(ReplicatedStorage.Common.MarketplaceService)
local CreatePriceLabel = require(ReplicatedStorage.ClientGameModules.CreatePriceLabel)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
Inventory = Inventory.Client
local TradeTokensController = require(ReplicatedStorage.Controllers.Trading.TradeTokensController)
script.Parent.Frame.Exit.Activated:Connect(function()
	GuiHandler:Close("PlaystationPack")
end)
CreatePriceLabel(script.Parent.Frame.Buy.Cost, 1668606901)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not script.Parent.Enabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.ButtonB then
		GuiHandler:Close("PlaystationPack")
	elseif UserInputService:GetStringForKeyCode(input.KeyCode) == "ButtonSquare" then
		TradeTokensController:PromptPurchase(1668606901, Enum.InfoType.Product)
	end
end)
script.Parent.Frame.Buy.Activated:Connect(function()
	TradeTokensController:PromptPurchase(1668606901, Enum.InfoType.Product)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function reflect()
	if v:Get("OwnsPlaystationPack") then
		GuiHandler:Close("PlaystationPack")
	end
end

v:OnChange("OwnsPlaystationPack", reflect)
reflect() -- equivalent call inferred; original call site unknown