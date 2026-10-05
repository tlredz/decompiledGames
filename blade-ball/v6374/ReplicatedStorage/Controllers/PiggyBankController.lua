local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v6 = require3(ReplicatedStorage2.Shared.PiggyBanksInfo)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local v9 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local remoteFunction = v:RemoteFunction("PiggyBank/PurchaseOpen")
local remoteFunction2 = v:RemoteFunction("PiggyBank/Claim")
local v10 = nil
local playerGui = Players.LocalPlayer.PlayerGui
local huntPrivateServer = v3.isHuntPrivateServer()
local PiggyBankController = {}

function PiggyBankController.IsActive(_, p: string)
	if not v10 or huntPrivateServer or v10:Get({ "PiggyBanks", p, "Claimed" }) then
		return false
	end

	local v11 = v10:Get({ "PiggyBanks", p, "ClaimPeriodStartTime" })

	if v11 then
		return workspace:GetServerTimeNow() - v11 < v6[p].ClaimPeriodDuration
	end

	local v12 = v10:Get({ "PiggyBanks", p, "StartTime" })

	if v12 then
		return workspace:GetServerTimeNow() - v12 <= v6[p].BankDuration
	end

	return false
end

function PiggyBankController.Start(_)
	v10 = v4.Client:WaitReplion("Data")

	if huntPrivateServer then
		return
	end

	local pack = v6.Pack
	v7:OnGuiOpen("PiggyBankPack", function()
		v8.IsUICovered:SetTag("PiggyBankPack", true)
	end)
	v7:OnGuiClose("PiggyBankPack", function()
		v8.IsUICovered:SetTag("PiggyBankPack", false)
	end)
	local piggyBank = playerGui:WaitForChild("RightHUD").List.PiggyBank
	local mainFrame = playerGui:WaitForChild("PiggyBankPack").MainFrame
	local left = mainFrame.Left
	local right = mainFrame.Right
	v9(right.Openx2.Amount, pack.PaidDevProduct, "DevProduct", ":robux: %s")
	right.Close.Activated:Connect(function()
		v7:Close("PiggyBankPack")
	end)
	right.OpenButton.Activated:Connect(function()
		remoteFunction2:InvokeServer("Pack")
	end)
	right.Openx2.Activated:Connect(function()
		remoteFunction:InvokeServer("Pack")
	end)
	v5.observeReplionPath(v10, "PiggyBanks.Pack.Gains", function(value)
		local v11 = value or 0
		left.ProgressBar.CoinCounter.Desc1.Text = `<stroke color="rgb(28, 2, 54)" joins="round" thickness="2">{v2.ValueConvertor:AddCommas(v11)}/{v2.ValueConvertor:AddCommas(pack.BankCoinsLimit)}<font color="rgb(255, 75, 75)"> Max</font></stroke>`
		left.ProgressBar.Fill.Size = UDim2.fromScale(v11 / pack.BankCoinsLimit, 1)
		right.CoinCollection.CoinShower.Coins.Amount.Text = v2.ValueConvertor:AddCommas(v11 * pack.GainMultipliers.Free)
	end)
	local openButton = right.OpenButton
	local amount = openButton:WaitForChild("Amount")
	local textLabel = openButton:WaitForChild("TextLabel")
	local timerBox = mainFrame:FindFirstChild("TimerBox", true)
	local v11 = nil
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local pack2 = v10.Data.PiggyBanks.Pack

		if not pack2 then
			return
		end

		if pack2.Claimed then
			v7:Close("PiggyBankPack")
			timerBox.Visible = false
			heartbeatConnection:Disconnect()
		end

		local startTime = pack2.StartTime
		local claimPeriodStartTime = pack2.ClaimPeriodStartTime
		local serverTimeNow = workspace:GetServerTimeNow()

		if startTime and serverTimeNow - startTime > pack.BankDuration then
			startTime = nil
		end

		timerBox.Visible = startTime and true or false
		local v12

		if startTime then
			v12 = v2.ValueConvertor:FormatTime(startTime + pack.BankDuration - serverTimeNow)
			timerBox.TextLabel.Text = `Claimable in {v12}`
		end

		local active = claimPeriodStartTime and workspace:GetServerTimeNow() - claimPeriodStartTime < pack.ClaimPeriodDuration

		if v11 == false and active and not v7:IsOpen("PiggyBankPack") then
			v7:Open("PiggyBankPack")
		end

		v11 = active
		openButton.ImageTransparency = active and 0 or 0.5
		amount.TextTransparency = active and 0 or 0.5
		textLabel.TextTransparency = active and 0 or 0.5
		openButton.Active = active
		amount.Visible = active and claimPeriodStartTime

		if active and claimPeriodStartTime then
			amount.Text = `Time left: {v2.ValueConvertor:FormatTime(claimPeriodStartTime + pack.ClaimPeriodDuration - serverTimeNow)}`
		end

		piggyBank.Timer.Text = active and "CLAIM NOW!" or v12 or ""
	end)
	piggyBank.Activated:Connect(function()
		v7:Open("PiggyBankPack")
	end)
end

return PiggyBankController