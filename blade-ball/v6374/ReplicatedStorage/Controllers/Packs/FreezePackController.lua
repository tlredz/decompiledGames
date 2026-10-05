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
require3(ReplicatedStorage2.Common.MarketplaceService)
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v7 = nil
ReplicatedStorage2:WaitForChild("Remotes")
local v8 = nil
local huntPrivateServer = v.isHuntPrivateServer()
local freezePack = playerGui:WaitForChild("FreezePack")
local rightHUD = playerGui:WaitForChild("RightHUD")

-- equivalent calls inferred from this helper; original call sites unknown
local function Countdown(timeLeft: number)
	if timeLeft < 0 then
		return "0 Days"
	end

	local v9 = timeLeft % 3600 // 60
	local v10 = timeLeft % 60

	if v9 > 0 then
		return (`{v9} Minute{v9 > 1 and "s" or ""}`)
	end

	return (`{string.format("%0.2f", v10)} Second{v10 > 1 and "s" or ""}`)
end

local FreezePackController = {}

function FreezePackController:GetTimeLeft()
	if huntPrivateServer or not v8 then
		return 0
	end

	local freezePackTimer = v8 and v8:Get("FreezePackTimer")
	local freezePackTimer2 = localPlayer:GetAttribute("FreezePackTimer")

	if freezePackTimer then
		return freezePackTimer - (not freezePackTimer2 and 0 or workspace:GetServerTimeNow() - freezePackTimer2)
	end

	return 0
end

function FreezePackController:HasPack()
	if huntPrivateServer then
		return false
	end

	return not not v8 and #client:FindItems("Ability", "Freeze") > 0 and v8:Find("GamePasses", "VIP") ~= nil
end

function FreezePackController:IsActive()
	return not huntPrivateServer and not self:HasPack() and self:GetTimeLeft() > 0
end

function FreezePackController.Init(_)
	v7 = require3(ReplicatedStorage2.Controllers.NotificationController)
end

function FreezePackController:Start()
	v8 = v4.Client:WaitReplion("Data")

	if huntPrivateServer then
		return
	end

	rightHUD.List.FreezePack.Activated:Connect(function()
		if v3:IsOpen("FreezePack") then
			v3:Close("FreezePack")
		else
			v3:Open("FreezePack")
		end
	end)
	v5(freezePack.Frame.Buy.Label, 1811437896, "DevProduct", ":robux:%s")
	freezePack.Frame.Buy.Activated:Connect(function()
		if not self:HasPack() then
			v6:PromptPurchase(1811437896, Enum.InfoType.Product)
		end
	end)
	freezePack.Frame.Close.Activated:Connect(function()
		v3:Close("FreezePack")
	end)
	localPlayer:GetAttributeChangedSignal("FreezePackShow"):Connect(function()
		if localPlayer:GetAttribute("FreezePackShow") then
			while true do
				local character = localPlayer.Character

				if character and character.Parent ~= workspace.Alive and not (workspace:GetAttribute("GameActive") or v3._currentGui) then
					break
				end

				task.wait(0.5)
			end

			v3:Open("FreezePack")
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkIfBought()
		local hasPack = self:HasPack()
		freezePack.Frame.Buy.Active = not hasPack

		if hasPack and v3:IsOpen("FreezePack") then
			v3:Close("FreezePack")
		end
	end

	v3:OnGuiOpen("FrozenPack", function()
		freezePack.Frame.Desc1.Visible = self:IsActive()
	end)
	client:OnChange("Sword", checkIfBought)
	client:OnChange("Explosion", checkIfBought)
	client:OnChange("Ability", checkIfBought)
	checkIfBought() -- equivalent call inferred; original call site unknown
	v2.Thread.Every(1, function()
		local timeLeft = self:GetTimeLeft()
		local countdown = Countdown(timeLeft) -- equivalent call inferred; original call site unknown
		rightHUD.List.FreezePack.Timer.Text = string.format("%02i:%02i", timeLeft / 60, timeLeft % 60)

		if timeLeft > 0 then
			freezePack.Frame.Desc1.Clock.Desc2.Text = `{countdown}`

			if timeLeft - 1 <= 0 and v3:IsOpen("FreezePack") then
				v3:Close("FreezePack")
			end
		end
	end)
end

return FreezePackController