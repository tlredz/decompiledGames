local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GuiService")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Packages.Replion)
local v6 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v8 = nil
local huntPrivateServer = v2.isHuntPrivateServer()
local hellfirePack = playerGui:WaitForChild("HellfirePack")
local rightHUD = playerGui:WaitForChild("RightHUD")
local HellfirePackController = {}

function HellfirePackController:GetTimeLeft()
	if huntPrivateServer then
		return 0
	end

	if v8 then
		return (v8:Get("LimitedPacks.Hellfire Blade Level 1") or 0) - workspace:GetServerTimeNow()
	end

	return 0
end

function HellfirePackController:HasPack()
	if huntPrivateServer then
		return false
	end

	if v8 then
		return #client:FindItems("Sword", "Hellfire Blade Level 1") > 0 or #client:FindItems(
			"Sword",
			"Hellfire Blade Level 2"
		) > 0
	end

	return false
end

function HellfirePackController:IsActive()
	return not self:HasPack() and self:GetTimeLeft() > 0
end

function HellfirePackController:Start()
	v8 = v5.Client:WaitReplion("Data")

	if huntPrivateServer then
		return
	end

	hellfirePack.Window.Visible = true
	rightHUD.List.HellfirePack.Activated:Connect(function()
		if v4:IsOpen(hellfirePack.Name) then
			v4:Close(hellfirePack.Name)
		else
			v4:Open(hellfirePack.Name)
		end
	end)
	hellfirePack.Window.CloseButton.Activated:Connect(function()
		v4:Close(hellfirePack.Name)
	end)
	hellfirePack.Window.PurchaseButton.Activated:Connect(function()
		if not self:HasPack() then
			v7:PromptPurchase(1660027104, Enum.InfoType.Product)
		end
	end)
	local maid = v.new()
	local v9 = nil
	local v10 = v8:Get("LimitedPacks.Hellfire Blade Level 1")

	local function update()
		local isActive = self:IsActive()

		if isActive or not v4:IsOpen(hellfirePack.Name) then
			if isActive and v10 == nil then
				v4:Open(hellfirePack.Name)
			end
		else
			v4:Close(hellfirePack.Name)
		end

		if v9 then
			maid:Remove(v9)
			v9 = nil
		end

		if isActive then
			v9 = maid:Add(v3.Thread.Every(1, function()
				local timeLeft = self:GetTimeLeft()
				rightHUD.List.HellfirePack.ItemTimer.Text = v3.ValueConvertor:FormatTimeWithDays(timeLeft)
				hellfirePack.Window.ItemTimer.Text = `{v3.ValueConvertor:FormatTime(timeLeft)} Left`
			end))
			v6(hellfirePack.Window.PurchaseButton.TextLabel, 1660027104)
		end
	end

	v8:OnChange("LimitedPacks.Hellfire Blade Level 1", update)
	client:OnChange("Sword", update)
	task.spawn(update)
end

return HellfirePackController