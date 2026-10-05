local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v2 = require3(ReplicatedStorage2.Controllers.PromptController)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.InfinityTrial)
local v5 = require3(ReplicatedStorage2.Packages.Replion)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local remoteEvent = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("InfinityTrialRestart")
local infinityTrial = Players.LocalPlayer.PlayerGui.InfinityTrial
local main = infinityTrial.Main
local v7 = nil
local InfinityTrialController = {}

function InfinityTrialController:Update()
	if not v7 then
		return
	end

	local infinityTrialV = v7:Get("InfinityTrialV3")

	if not infinityTrialV then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local failed = infinityTrialV.Failed == true
	local claimed = infinityTrialV.Claimed == true
	local resetTime = infinityTrialV.ResetTime
	local v8 = claimed or failed

	for i = 1, v4.Hours do
		local child = main.Content:FindFirstChild((tostring(i)))

		if not child then
			continue
		end

		local v9 = infinityTrialV.StartTime + (i - 1) * 3600
		local visible = table.find(infinityTrialV.CompletedHours, i) ~= nil
		child.Claimed.Visible = visible
		child.Title.Text = DateTime.fromUnixTimestamp(v9):FormatLocalTime("LT", LocalizationService.SystemLocaleId)

		if i == v4.Hours then
			child.Cross.Visible = failed
			child.Cancel.Visible = failed
			child.Buy.Visible = failed
			child.TimeLeft.Visible = not v8
		end

		if not v8 then
			child.TimeLeft.Text = v6.ValueConvertor:FormatTimeWithDays((math.max(math.floor(v9 - serverTimeNow), 0)))
		end
	end

	main.Gold.Cross.Visible = failed
	main.Gold.Claimed.Visible = claimed
	main.Completed.Visible = claimed

	if claimed then
		if resetTime then
			main.Completed.Info.Text = `Come back in {v6.ValueConvertor:FormatTimeWithDays((math.floor(resetTime - serverTimeNow)))} to try again`
		end

		local visible = not infinityTrialV.ResetPurchased or infinityTrialV.ResetPurchased + 86400 <= serverTimeNow
		main.Completed.ResetNow.Visible = visible
		main.Completed.Buy.Visible = visible
	end
end

function InfinityTrialController:Start()
	v7 = v5.Client:WaitReplion("Data")
	assert(v7)
	v7:OnChange("InfinityTrialV3", function()
		self:Update()
	end)
	v7:OnDescendantChange("InfinityTrialV3", function()
		self:Update()
	end)
	local connection = nil
	v3:OnGuiOpen(infinityTrial.Name, function()
		if connection then
			return
		end

		connection = v6.Thread.Every(1, function()
			self:Update()
		end)
	end)
	v3:OnGuiClose(infinityTrial.Name, function()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)
	main.Close.Activated:Connect(function()
		v3:Close(infinityTrial.Name)
	end)
	main.Completed.Buy.Activated:Connect(function()
		v:PromptPurchase(2707630774, Enum.InfoType.Product)
	end)
	local child = main.Content:FindFirstChild((tostring(v4.Hours)))

	if child and child:FindFirstChild("Buy") then
		child.Buy.Activated:Connect(function()
			v:PromptPurchase(2707630775, Enum.InfoType.Product)
		end)
		child.Cancel.Activated:Connect(function()
			v2:CreatePrompt({
				PromptType = "Accept",
				Description = "You sure you want to restart?",
				AcceptButtonText = "Yes",
				DeclineButtonText = "No"
			}, function(flag: boolean)
				if flag then
					remoteEvent:FireServer()
				end
			end)
		end)
	end
end

return InfinityTrialController