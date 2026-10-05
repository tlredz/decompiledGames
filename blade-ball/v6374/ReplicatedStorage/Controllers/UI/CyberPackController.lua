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
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v7 = nil
ReplicatedStorage2:WaitForChild("Remotes")
local v8 = nil
local huntPrivateServer = v.isHuntPrivateServer()
local cyberPack = playerGui:WaitForChild("CyberPack")
local rightHUD = playerGui:WaitForChild("RightHUD")
local maid = v2.Maid.new()
local CyberPackController = {
	Maid = maid
}
local RunService = game:GetService("RunService")

if RunService:IsStudio() or game.GameId ~= 4777817887 then
	local Players2 = game:GetService("Players")

	if Players2.LocalPlayer.UserId == 812993282 then
		local _ = print
	end
end

function CyberPackController:GetTimeLeft()
	if huntPrivateServer or not v8 then
		return 0
	end

	local procedStarterPack = v8 and v8:Get("procedStarterPack2")
	local starterPack2 = localPlayer:GetAttribute("starterPack2")

	if procedStarterPack then
		return procedStarterPack - (not starterPack2 and 0 or workspace:GetServerTimeNow() - starterPack2)
	end

	return 0
end

function CyberPackController:HasPack()
	if huntPrivateServer then
		return false
	end

	if v8 then
		return v8:Get("OwnsCyberPack")
	end

	return false
end

function CyberPackController:IsActive()
	return not huntPrivateServer and not self:HasPack() and self:GetTimeLeft() > 0
end

function CyberPackController.Init(_)
	v7 = require3(ReplicatedStorage2.Controllers.NotificationController)
end

function CyberPackController:Start()
	v8 = v4.Client:WaitReplion("Data")

	if huntPrivateServer then
		return
	end

	rightHUD.List.CyberPack.Activated:Connect(function()
		if v3:IsOpen("CyberPack") then
			v3:Close("CyberPack")
		else
			v3:Open("CyberPack")
		end
	end)
	v5(cyberPack.Frame.Buy.Label, 1644634154)
	cyberPack.Frame.Buy.Activated:Connect(function()
		if not self:HasPack() then
			v6:PromptPurchase(1644634154, Enum.InfoType.Product)
		end
	end)
	cyberPack.Frame.X.Activated:Connect(function()
		v3:Close("CyberPack")
	end)
	maid:GiveTask(localPlayer:GetAttributeChangedSignal("starterPack2popup"):Connect(function(...)
		if localPlayer:GetAttribute("starterPack2popup") then
			while true do
				local character = localPlayer.Character

				if character and character.Parent ~= workspace.Alive and not (workspace:GetAttribute("GameActive") or v3._currentGui) then
					break
				end

				task.wait(0.5)
			end

			v3:Open("CyberPack")
		end
	end))

	local function countdown()
		maid.UpdateThread = v2.Thread.Every(1, function()
			local timeLeft = self:GetTimeLeft()
			rightHUD.List.CyberPack.Fade.Timer.Text = string.format("%02i:%02i", timeLeft / 60, timeLeft % 60)

			if timeLeft > 0 then
				local character = localPlayer.Character
				cyberPack.Frame.TimerBox.Timer.Text = "<stroke color=\"rgb(89, 0, 0)\" joins=\"round\" thickness=\"2\"><font color=\"rgb(235, 174, 94)\">Offer ends: </font> " .. v2.ValueConvertor:FormatTimeWithDays(timeLeft) .. "</stroke>"

				if (timeLeft - 1 <= 0 or character and character.Parent == workspace.Alive) and v3:IsOpen("CyberPack") then
					v3:Close("CyberPack")
				end
			end
		end)
	end

	maid:GiveTask(v8:OnChange("procedStarterPack2", countdown))
	task.spawn(countdown)

	local function checkIfBought()
		local hasPack = self:HasPack()
		cyberPack.Frame.Buy.Active = not hasPack
		cyberPack.Frame.Buy.Label.Text = hasPack and "OWNED" or 399
		cyberPack.Frame.Buy.ImageColor3 = hasPack and Color3.new(0.5, 0.5, 0.5) or Color3.new(1, 1, 1)
		cyberPack.Frame.Buy.Icon.Visible = not hasPack
	end

	v3:OnGuiOpen("CyberPack", function()
		cyberPack.Frame.TimerBox.Visible = self:IsActive()
	end)
	v8:OnChange("OwnsCyberPack", checkIfBought)
	checkIfBought()
end

return CyberPackController