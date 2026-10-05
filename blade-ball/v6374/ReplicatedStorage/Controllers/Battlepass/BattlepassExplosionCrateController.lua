local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.Policy)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v4 = require3(script.Parent.BattlepassViewController)
local v5 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassExplosionCrate)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v8 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v9 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v10 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local playerGui = Players.LocalPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassExplosionCrate

if v9 == "Window" then
	battlepassExplosionCrate = playerGui:WaitForChild("BattlepassExplosionCrate")
else
	battlepassExplosionCrate = nil
end

local main

if v9 == "Window" then
	main = battlepassExplosionCrate.Main
else
	main = battlepass.Main.Background.Views.ExplosionCrate
end

local crates = main.Crates
local v11 = require3(script.GalaxyCrateAnim)(main)
local v12 = { "CrateKeys", v10.SeasonData.Crate.Id }
return {
	Start = function(_)
		main.Counter.Icon.Image = v10.SeasonData.Currency.Icon
		main.Crates.Buy.List.Icon.Image = v10.SeasonData.Currency.Icon
		local v13 = v3.Client:WaitReplion("Data")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateVisibilityTracker()
			local setVisible = v11.setVisible
			local v14

			if v9 == "ShowRoom" then
				v14 = main.Visible and v6:IsOpen("Battlepass")
			else
				v14 = main.Visible and battlepassExplosionCrate.Enabled
			end

			setVisible(v14)
		end

		main:GetPropertyChangedSignal("Visible"):Connect(function()
			updateVisibilityTracker() -- equivalent call inferred; original call site unknown
		end)
		v6:OnGuiOpen("Battlepass", updateVisibilityTracker)
		v6:OnGuiClose("Battlepass", updateVisibilityTracker)

		if v9 == "Window" then
			v6:OnGuiOpen(battlepassExplosionCrate.Name, updateVisibilityTracker)
			v6:OnGuiClose(battlepassExplosionCrate.Name, updateVisibilityTracker)
		end

		local v14 = false
		local policyInfo = nil
		crates.Buy.Activated:Connect(function()
			if v11.getIsRolling() or v14 then
				return
			end

			v14 = true

			if (v13:Get(v12) or 0) > 0 then
				xpcall(function()
					v.Network:Invoke("OpenBattlepassExplosionCrate")
				end, function(p)
					task.spawn(error, p)
				end)
			elseif (v13:Get("InfiniteBattlepass.Currency") or 0) >= v10.SeasonData.Crate.Price then
				xpcall(function()
					v.Network:Invoke("OpenBattlepassExplosionCrate")
				end, function(p)
					task.spawn(error, p)
				end)
			end

			v14 = false
		end)

		local function update()
			main.Counter.Amount.Text = v.ValueConvertor:AddCommas(v13:Get("InfiniteBattlepass.Currency") or 0)
			crates.Buy.Visible = true

			if policyInfo and policyInfo.ArePaidRandomItemsRestricted then
				crates.Top.About.Visible = false
			end

			local v15 = v13:Get(v12) or 0
			crates.Buy.List.Icon.Visible = v15 == 0

			if v15 > 0 then
				crates.Buy.List.Amount.Text = `Spin ({v.ValueConvertor:AddCommas(v15)})`
			else
				crates.Buy.List.Amount.Text = `{v10.SeasonData.Crate.Price}`
			end
		end

		v13:OnChange(v12, update)
		v13:OnChange("InfiniteBattlepass.Currency", update)
		update()

		if battlepassExplosionCrate then
			main.Close.Activated:Connect(function()
				v4:OpenView("Battlepass")
			end)
		end

		main.Counter.Add.MouseButton1Click:Connect(function()
			local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")

			if v9 == "ShowRoom" then
				battlepassCurrencyShop.Enabled = true
			else
				v6:Open(battlepassCurrencyShop.Name, nil, true)
			end
		end)
		task.spawn(function()
			policyInfo = v2:GetPolicyInfo()
			update()
		end)

		function v.Network.Events.BattlepassExplosionStart(p: number)
			v11.addToQueue(p)
		end

		function v.Network.Events.BattlepassExplosionEnd() end

		local visible = false
		crates.Top.About.Activated:Connect(function()
			visible = not visible

			for _, guiObject in crates.Grid:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject.Canvas.Button.Percentage.Visible = visible
				end
			end
		end)

		for i = 1, 8 do
			local guiObject = crates.Grid:FindFirstChild((`Slot{i}`))

			if not (guiObject and guiObject:IsA("GuiObject")) then
				continue
			end

			local reward = v5.Rewards[i]
			local text = reward.Reward.DisplayName:gsub(" Explosion Explosion", " Explosion")
			guiObject.Canvas.Button.Percentage.Text = `{v.ValueConvertor:AddCommas(reward.Chance)}%`
			guiObject.Canvas.Button.ItemName.Text = text
			guiObject.Canvas.Button.Vector.Image = reward.Reward.Icon or ""
			guiObject.Canvas.Button.Inspect.Activated:Connect(function()
				v4:CloseView("ExplosionCrate")
				v4:Close()
				v7:PreviewReward(reward.Reward, nil, function()
					v4:Open()
					v4:OpenView("ExplosionCrate")
				end)
			end)
			v8:AddFromRewardInfo(guiObject.Canvas.Button, reward.Reward)
		end
	end
}