local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(ReplicatedStorage2.Controllers.StPatricksDayEventController)
local v6 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v7 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local gachaLuckIncrease = localPlayer.PlayerGui:WaitForChild("GachaLuckIncrease")
require3(ReplicatedStorage2.Common.GachaItemsData)
return {
	Start = function(_)
		local v8 = v2.Client:WaitReplion("Data")
		v4:WaitForData()
		local textLabel = gachaLuckIncrease:WaitForChild("LuckIncreaseEvent"):WaitForChild("Timer"):WaitForChild("TextLabel")

		local function updateTimer()
			if not v3:IsOpen(gachaLuckIncrease.Name) then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v9 = math.max(
				(v4:GetKey("BattlepassGachaLuckEndTime") or 0) - serverTimeNow,
				v5:HasLuck() and v5:GetRemaining() or 0
			)

			if v9 > 0 and v7.isEnabled() then
				textLabel.Text = `X2 LUCK - {v.ValueConvertor:FormatTimeHHMMSS(v9)}`
				return
			end

			textLabel.Text = "EVENT ENDED"
			v3:Close(gachaLuckIncrease.Name)
		end

		if v8:Get("BattlepassGachaLuckId") ~= v4:GetKey("BattlepassGachaLuckId") and ((v8:Get((`InfGachaTimesSpun{v7.Season}`)) or 0) > 0 or v8:Get((`HaveOpenedInfGacha{v7.Season}`))) and workspace:GetServerTimeNow() < (v4:GetKey("BattlepassGachaLuckEndTime") or 0) and v4:GetKey("BattlepassGachaSpinAmountForChest") then
			task.delay(10, function()
				while v3._currentGui or not localPlayer.Character or localPlayer.Character.Parent ~= workspace.Dead do
					task.wait(0.1)
				end

				v3:Open(gachaLuckIncrease.Name)
				v.Network:Fire("GachaLuckPopup")
			end)
			pcall(function()
				local textLabel = gachaLuckIncrease:WaitForChild("LuckIncreaseEvent"):WaitForChild("Frame"):WaitForChild("TextLabel")
				textLabel.Text = `Every {v4:GetKey("BattlepassGachaSpinAmountForChest")} rolls is guaranteed\nto open the grand chest\nwith high tier rewards!`
			end)
		end

		v.Thread.Every(1, updateTimer)
		v3:OnGuiOpen(gachaLuckIncrease.Name, updateTimer)
		task.spawn(updateTimer)
		gachaLuckIncrease.LuckIncreaseEvent.Close.MouseButton1Click:Connect(function()
			v3:Close(gachaLuckIncrease.Name)
		end)
		gachaLuckIncrease.LuckIncreaseEvent.GetNow.MouseButton1Click:Connect(function()
			v6:OpenView("SpinGacha")
			v6:Open()
		end)
	end
}