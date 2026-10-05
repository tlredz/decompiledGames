local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.Policy)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v6 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v8 = require3(ReplicatedStorage2.Shared.ValentinesBundle)
local v9 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local valentinesBundle = playerGui:WaitForChild("RightHUD").List:WaitForChild("ValentinesBundle")
local timer = valentinesBundle.Timer.Timer
local valentinesBundle2 = playerGui:WaitForChild("ValentinesBundle")
local v10 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function Countdown(expireTime: number)
	local v11 = expireTime - workspace:GetServerTimeNow()
	return v3.ValueConvertor:FormatTimeWithDays(v11)
end

local ValentinesBundleController = {}

function ValentinesBundleController:GetExpireTime()
	return v8.EndTime.UnixTimestamp
end

function ValentinesBundleController:IsActive()
	return not v2.isLTMServer() and workspace:GetServerTimeNow() < self:GetExpireTime()
end

function ValentinesBundleController:StartHUD()
	local connection = nil

	local function updateTimer()
		if self:IsActive() then
			timer.Text = Countdown(self:GetExpireTime())
		else
			timer.Text = "EXPIRED!"

			if connection and connection.Connected then
				connection:Disconnect()
				connection = nil
			end
		end
	end

	local function createOrUpdateTimer()
		if connection then
			task.spawn(updateTimer)
		elseif self:IsActive() then
			connection = v3.Thread.Every(1, updateTimer)
		end
	end

	v4:OnGuiOpen("ValentinesBundle", updateTimer)
	v10:OnChange("ValentinesBundleFirstJoinTime", createOrUpdateTimer)
	task.spawn(createOrUpdateTimer)
	valentinesBundle.Activated:Connect(function()
		v4:Open("ValentinesBundle")
	end)
end

function ValentinesBundleController:StartMenu()
	local title = valentinesBundle2.Main.Timer.Title
	local titleShadow = valentinesBundle2.Main.Timer.TitleShadow
	local connection = nil

	local function updateTimer()
		if not v4:IsOpen("ValentinesBundle") then
			return
		end

		if self:IsActive() then
			title.Text = Countdown(self:GetExpireTime())
			titleShadow.Text = title.Text
		else
			title.Text = "EXPIRED!"
			titleShadow.Text = title.Text

			if connection and connection.Connected then
				connection:Disconnect()
				connection = nil
			end

			v4:Close("ValentinesBundle")
		end
	end

	local function createOrUpdateTimer()
		if connection then
			task.spawn(updateTimer)
		elseif self:IsActive() then
			connection = v3.Thread.Every(1, updateTimer)
		end
	end

	v4:OnGuiOpen("ValentinesBundle", updateTimer)
	v10:OnChange("ValentinesBundleFirstJoinTime", createOrUpdateTimer)
	task.spawn(createOrUpdateTimer)

	for k, bundle in v8.Bundles do
		local child = valentinesBundle2.Main.Bundles:FindFirstChild((tostring(k)))
		local buy = child.ButtonsBottom.Buy
		v9(buy.Amount, bundle.ProductId, "DevProduct")
		local v11 = bundle
		buy.Activated:Connect(function()
			if self:IsActive() then
				v7:PromptPurchase(v11.ProductId, Enum.InfoType.Product)
			end
		end)
		local v12 = bundle
		child.ButtonsBottom.Gift.Activated:Connect(function()
			if self:IsActive() then
				v6:SetGift(v12.GiftName)
			end
		end)

		for _, child2 in child.Items:GetChildren() do
			local name = tonumber(child2.Name)

			if not name then
				continue
			end

			local reward = bundle.Rewards[name]

			if not reward then
				continue
			end

			child2.Vector.Image = reward.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
			local name2 = child2.Vector.SakuraLabel:FindFirstChild("Name")

			if name2 then
				name2.Text = reward.DisplayName or "TBD"
			end
		end
	end

	valentinesBundle2.Main.Close.Activated:Connect(function()
		v4:Close("ValentinesBundle")
	end)

	if not v10:Get("ValentinesBundleAppear") then
		v10:OnChange("ValentinesBundleAppear", function(p)
			while true do
				local character = localPlayer.Character

				if character and character.Parent ~= workspace.Alive and not (workspace:GetAttribute("GameActive") or v4._currentGui) then
					break
				end

				task.wait(0.5)
			end

			if self:IsActive() and not v4._currentGui and not v4:IsOpen("ValentinesBundle") and p ~= nil then
				v4:Open("ValentinesBundle")
			end
		end)
	end
end

function ValentinesBundleController:Start()
	v10 = v.Client:WaitReplion("Data")
	self:StartHUD()
	self:StartMenu()
	v4:OnGuiOpen("ValentinesBundle", function()
		v5(Enum.CoreGuiType.PlayerList, false)
	end)
	v4:OnGuiClose("ValentinesBundle", function()
		v5(Enum.CoreGuiType.PlayerList, true)
	end)
end

return ValentinesBundleController