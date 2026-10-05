local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local spring = v4.Spring
local v5 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v6 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassDailyLogin = playerGui:WaitForChild("BattlepassDailyLogin")
local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassWanted = playerGui:WaitForChild("BattlepassWanted")
local main = battlepass.Main
local background = main.Background
local topButtons = background.TopButtons
local v7

if v5 == "ShowRoom" then
	v7 = {
		DailyLogin = background.Views.DailyLogin,
		MyTeam = background.Views.MyTeam,
		SpinGacha = background.Views.SpinGacha,
		Battlepass = background.Views.Battlepass,
		ExplosionCrate = background.Views.ExplosionCrate,
		Merchant = background.Views.Merchant,
		Quests = background.Views.Quests
	}
else
	v7 = {
		DailyLogin = playerGui:WaitForChild("BattlepassDailyLogin"),
		MyTeam = playerGui:WaitForChild("BattlepassMyTeam"),
		SpinGacha = playerGui:WaitForChild("BattlepassSpinGacha"),
		Battlepass = playerGui:WaitForChild("Battlepass"),
		ExplosionCrate = playerGui:WaitForChild("BattlepassExplosionCrate"),
		Merchant = playerGui:WaitForChild("BattlepassMerchant"),
		Quests = battlepass.QuestsFrame,
		TopTiers = playerGui:WaitForChild("BattlepassTopTierLeaderboard"),
		TopTiersRewards = playerGui:WaitForChild("TopTiersRewards")
	}
end

local battlepassHelp = playerGui:WaitForChild("BattlepassHelp")
local battlepassDailyLogin2 = playerGui:WaitForChild("BattlepassDailyLogin")
local _ = RunService:IsStudio() or game.GameId ~= 4777817887
local flag = false
local v8 = require3(script.Parent.BattlepassViewController)
local v9 = {
	DailyLogin = "Blue",
	ExplosionCrate = "Blue",
	Merchant = "Blue",
	Crate = "Blue",
	AbilitySpin = "Blue",
	Battlepass = "Blue",
	Quests = "Blue",
	SpinGacha = "Blue",
	MyTeam = "Blue"
}
local v10 = {
	Selected = {
		Image = "rbxassetid://122944110429617",
		HoverImage = "rbxassetid://132122699949451",
		UIStrokeColor = Color3.fromRGB(26, 50, 157),
		Size = UDim2.fromScale(0.183, 1.2)
	},
	Blue = {
		Image = "rbxassetid://106581965796647",
		HoverImage = "rbxassetid://120417348511134",
		UIStrokeColor = Color3.fromRGB(26, 50, 157),
		Size = UDim2.fromScale(0.16, 1.047)
	}
}
local v11 = nil
local v12 = {}
local BattlepassController = {
	Init = function(_)
		local dailyLogin = topButtons:FindFirstChild("DailyLogin")
		dailyLogin.Activated:Connect(function()
			battlepassDailyLogin2.Enabled = true
		end)
		local _selectedView = v8._selectedView
		local _selectedView2 = v8._selectedView

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeDailyLogin()
			if v5 == "ShowRoom" then
				battlepassDailyLogin.Enabled = false
			else
				v2:Close(battlepassDailyLogin.Name)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function openDailyLogin()
			if not v4.FFlag.GetFFlag("BattlepassDailyLoginEnabled", false) then
				return
			end

			if v5 == "ShowRoom" then
				battlepassDailyLogin.Enabled = true
			else
				v2:Open(battlepassDailyLogin.Name)
			end
		end

		local function updateDailyLoginVisibility()
			dailyLogin.Visible = v4.FFlag.GetFFlag("BattlepassDailyLoginEnabled", false)
		end

		task.spawn(updateDailyLoginVisibility)
		v4.FFlag.OnChange(updateDailyLoginVisibility)
		battlepassDailyLogin:GetPropertyChangedSignal("Enabled"):Connect(function()
			if battlepassDailyLogin.Enabled then
				_selectedView = "DailyLogin"
			else
				_selectedView = _selectedView2
			end

			for _, v13 in v12 do
				v13()
			end
		end)

		for childName, v13 in v7 do
			local v14 = v9[childName]

			if childName ~= "DailyLogin" or v5 == "Window" then
				v8:CreateView(childName, v13)
			end

			local quests

			if childName == "Quests" and v5 == "Window" then
				quests = background.Quests
			else
				quests = topButtons:FindFirstChild(childName)
			end

			if quests then
				local v15 = childName
				quests.Activated:Connect(function()
					if v15 == "Battlepass" and v5 == "Window" then
						return
					end

					if v15 == "DailyLogin" and v5 == "ShowRoom" then
						if battlepassDailyLogin.Enabled then
							closeDailyLogin() -- equivalent call inferred; original call site unknown
						else
							openDailyLogin() -- equivalent call inferred; original call site unknown
						end
					else
						if v15 == "Quests" and v5 == "Window" then
							battlepass.QuestsFrame.Visible = not battlepass.QuestsFrame.Visible
							return
						end

						_selectedView = v15

						if v15 == "DailyLogin" or v15 == "SpinGacha" then
							local view = v8:GetView(v15)
							local _instance = view and view._instance

							if _instance then
								_instance:SetAttribute("OpenBattlePass", true)
							end
						end

						v8:OpenView(v15)

						for k, v16 in v12 do
							v16()
						end

						_selectedView2 = v15
					end
				end)
			end

			local v15 = v8:OnViewOpen(childName)

			if v15 then
				local v16 = childName
				v15:Connect(function()
					_selectedView = v16

					for k, v17 in v12 do
						v17()
					end
				end)
			end

			local v16 = v8:OnViewClosed(childName)

			if v16 then
				v16:Connect(function()
					for _, v17 in v12 do
						v17()
					end
				end)
			end

			local v18 = childName
			table.insert(v12, function()
				if not (quests and v5 ~= "Window") then
					return
				end

				local selected

				if _selectedView == v18 then
					selected = v10.Selected
				else
					selected = v10[v14]
				end

				quests.Image = selected.Image
				quests.HoverImage = selected.HoverImage
				quests.Size = selected.Size
				local uIStroke = quests:WaitForChild("TextLabel"):WaitForChild("UIStroke")

				if uIStroke then
					uIStroke.Color = selected.UIStrokeColor
				end
			end)
		end
	end
}

local function _countdown(endTimestamp: number)
	local v13 = endTimestamp - workspace:GetServerTimeNow()

	if v13 < 0 then
		return {
			Unit = "Days",
			Value = 0
		}
	end

	local v14 = math.floor(v13 / 86400)
	local v15 = math.floor(v13 % 86400 / 3600)
	local v16 = math.floor(v13 % 3600 / 60)
	local v17 = v13 % 60

	if v14 > 0 then
		return {
			Unit = "Days",
			Value = v14
		}
	end

	if v15 > 0 then
		return {
			Unit = "Hours",
			Value = v15
		}
	end

	if v16 > 0 then
		return {
			Unit = "Minutes",
			Value = v16
		}
	end

	return {
		Unit = "Seconds",
		Value = v17
	}
end

function BattlepassController.Start(_)
	v11 = v3.Client:WaitReplion("Data")

	if v5 == "ShowRoom" then
		v8:OpenView("Battlepass")
	end

	if flag then
		v.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Z and not gameProcessed then
				v8:Open()
			end
		end)
	end

	local battlepassButton = playerGui:WaitForChild("RightHUD"):WaitForChild("List"):WaitForChild("BattlepassButton")
	local endsIn

	if v5 == "Window" then
		endsIn = playerGui.BattlepassSpinGacha.Main.Background.Spin.Fade.EndsIn
	else
		endsIn = main.Background.Views.SpinGacha.Background.Spin.Fade.EndsIn
	end

	local time = playerGui:WaitForChild("BattlepassBuyLevels").BuyLevels.Time
	battlepassButton.Activated:Connect(function()
		if v2:IsOpen("Battlepass") then
			v8:Close()
			return
		end

		v8:OpenView("Battlepass")
		v8:Open()
	end)
	v4.Thread.Every(1, function()
		local timestamps = v6.getTimestamps()
		local enabled = v6.isEnabled()
		local v13 = _countdown(timestamps.endTimestamp)

		if v5 == "Window" then
			main.Background.Ended.Visible = not enabled
		end

		battlepassButton.Timer.Text = not enabled and "ENDED!" or string.format("%d %s", v13.Value, v13.Unit) or "ENDED!"
		time.Text = not enabled and "ENDED!" or string.format("%d %s", v13.Value, v13.Unit) or "ENDED!"

		if endsIn then
			endsIn.Clock.Timer.Text = enabled and string.format("%d %s", v13.Value, v13.Unit) or "ENDED!"
		end

		if not enabled and v2:IsOpen("Battlepass") then
			v8:Close()
		end
	end)
	battlepassHelp.RaffleRules.Close.Activated:Connect(function()
		v2:Close(battlepassHelp.Name, true)
		battlepassHelp.Enabled = false
	end)
	battlepassHelp.RaffleRules.Claim.Activated:Connect(function()
		v2:Close(battlepassHelp.Name, true)
		battlepassHelp.Enabled = false
	end)
	local counter = battlepassDailyLogin:FindFirstChild("Counter", true)

	if counter and counter:FindFirstChild("Amount") then
		if counter:FindFirstChild("Add") then
			counter.Add.Activated:Connect(function()
				if v5 == "ShowRoom" then
					battlepassCurrencyShop.Enabled = true
				else
					v2:Open(battlepassCurrencyShop.Name, nil, true)
				end
			end)
		end

		local function updateCurrency()
			local v13 = v11:Get("InfiniteBattlepass.Currency") or 0
			counter.Amount.Text = v4.ValueConvertor:AddCommas(v13)
			counter.Icon.Image = v6.SeasonData.Currency.Icon
		end

		v11:OnChange("InfiniteBattlepass.Currency", updateCurrency)
		task.spawn(updateCurrency)
	end

	local function updateBounty()
		local battlepassBountyTarget = localPlayer:GetAttribute("BattlepassBountyTarget")
		local playerByUserId = battlepassBountyTarget and Players:GetPlayerByUserId(battlepassBountyTarget)

		if battlepassBountyTarget == nil or not playerByUserId then
			return
		end

		battlepassWanted.WantedPoster.Poster.PlayerName.Text = playerByUserId.DisplayName
		battlepassWanted.WantedPoster.Poster.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={playerByUserId.userId}&w=150&h=150`
		battlepassWanted.Enabled = true
		spring.target(battlepassWanted.WantedPoster, 0.85, 1.5, {
			Position = UDim2.fromScale(0.885, 0.5)
		})
		task.wait(3)
		spring.target(battlepassWanted.WantedPoster, 0.85, 1.5, {
			Position = UDim2.fromScale(1.25, 0.5)
		})
		spring.completed(battlepassWanted, function()
			battlepassWanted.Enabled = false
		end)
	end

	task.spawn(updateBounty)
	localPlayer:GetAttributeChangedSignal("BattlepassBountyTarget"):Connect(updateBounty)
end

return BattlepassController