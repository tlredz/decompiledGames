wait(1)
local localPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

if not localPlayer.Character then
	localPlayer.CharacterAdded:Wait()
end

local TweenService = game:GetService("TweenService")

repeat
	wait()
until localPlayer:FindFirstChild("DataLoaded") and localPlayer:FindFirstChild("PlayerStats")

local playerStats = localPlayer.PlayerStats
local leveling = localPlayer:WaitForChild("Leveling")
local misc = playerStats:WaitForChild("Misc")
localPlayer:GetMouse()
local v = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local lvl = playerStats:WaitForChild("lvl")
local parent = script.Parent
local _ = parent.Parent
local armConfig = parent.ArmConfig
local skyJumpGuide = parent.SkyJumpGuide
local fishingGuide = parent.FishingGuide
local statsPage = parent.StatsPage
local passivePage = parent.PassivePage
local profilePage = parent.ProfilePage
local titlePage = parent.TitlePage
local statsPageButton = parent.StatsPageButton
local passivePageButton = parent.PassivePageButton
local profilePageButton = parent.ProfilePageButton
local titlePageButton = parent.TitlePageButton
local scrollingFrame = profilePage.ScrollingFrame
local numberBox = statsPage.NumberFrame.NumberBox
local scrollingFrame2 = statsPage.ScrollingFrame
local melee = scrollingFrame2.Melee
local defense = scrollingFrame2.Defense
local fruit = scrollingFrame2.Fruit
local sword = scrollingFrame2.Sword
local skyJump = scrollingFrame2.SkyJump
local armament = scrollingFrame2.Armament
local resetStats = statsPage["Reset Stats"]
local _ = localPlayer.PlayerStats.RaceTbl
local playerStats2 = localPlayer:WaitForChild("PlayerStats")
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local name = localPlayer.Name
local now = 0
local v2 = {}

function FindPlayer(value)
	if not value then
		return
	end

	for _, v3 in pairs(game.Players:GetPlayers()) do
		if string.lower((string.sub(v3.Name, 1, #value))) == string.lower(value) then
			return v3.Name
		end
	end

	return value
end

function GetPlayerTitleNumThatUnlockedNoSpecial(p)
	local jSONDecode = HttpService:JSONDecode(p.PlayerStats.TitleStore.Value)
	local count = 0

	for _, _ in pairs(jSONDecode) do
		count += 1
	end

	return count
end

function GetUserInfosByUserIdsAsync(p)
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(p)
	end)

	if success then
		return result[1]
	end

	warn(result)
end

function GetUserIdByUsername(p)
	local _, result = pcall(function()
		return game.Players:GetUserIdFromNameAsync(p)
	end)
	return result
end

function GetThumbnailByUserId(p)
	local _, result = pcall(function()
		return game.Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)
	end)
	return result
end

local function GetStats(name2)
	if not name2 then
		return
	end

	local v3 = string.lower(name2)

	if v2[v3] and not game.Players:FindFirstChild(name2) then
		return v2[v3]
	end

	local v4 = GetUserIdByUsername(name2)

	if not v4 then
		return
	end

	local v5 = GetUserInfosByUserIdsAsync({ v4 })

	if not v5 then
		return
	end

	local thumbnail = GetThumbnailByUserId(v4) or ""
	local v7 = game.Players:FindFirstChild(name2) or ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(
		"GetPlayerData",
		{
			PlayerName = name2
		}
	)

	if not v7 then
		return
	end

	if typeof(v7) == "Instance" then
		if not v7:FindFirstChild("DataLoaded") then
			return
		end

		local playerStats3 = v7:FindFirstChild("PlayerStats")

		if not playerStats3 then
			return
		end

		local v8 = {
			DisplayName = v5.DisplayName,
			Thumbnail = thumbnail,
			PlayerName = name2,
			Level = playerStats3.lvl.Value,
			FightingStyle = playerStats3.FightingStyle.Value,
			Fruit = playerStats3.DFName.Value,
			Misc = HttpService:JSONDecode(playerStats3.Misc.Value),
			Statistics = HttpService:JSONDecode(playerStats3.Statistics.Value),
			TitleProgression = HttpService:JSONDecode(playerStats3.TitleProgression.Value),
			RaceTbl = HttpService:JSONDecode(playerStats3.RaceTbl.Value),
			TitleStore = HttpService:JSONDecode(playerStats3.TitleStore.Value)
		}
		v2[v3] = v8
		return v8
	else
		if typeof(v7) ~= "table" then
			return
		end

		local v8 = {
			DisplayName = v5.DisplayName,
			Thumbnail = thumbnail,
			PlayerName = name2,
			Level = v7.lvl or 1,
			FightingStyle = v7.FightingStyle or "None",
			Fruit = v7.DFName or "None",
			Misc = HttpService:JSONDecode(v7.Misc or "[]"),
			Statistics = HttpService:JSONDecode(v7.Statistics or "[]"),
			TitleProgression = HttpService:JSONDecode(v7.TitleProgression or "[]"),
			RaceTbl = HttpService:JSONDecode(v7.RaceTbl or "[]"),
			TitleStore = HttpService:JSONDecode(v7.TitleStore or "[]")
		}
		v2[v3] = v8
		return v8
	end
end

function CountTable(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

function UpdateProfile()
	if name == localPlayer.Name and tick() - now < 1 then
		return
	end

	now = tick()
	local stats = GetStats(name)

	if not stats then
		return
	end

	local titleProgression = stats.TitleProgression or {}
	local titleStore = stats.TitleStore or {}
	local statistics = stats.Statistics or {}
	local raceTbl = stats.RaceTbl or {}
	local misc2 = stats.Misc or {}
	local fruit2 = stats.Fruit or "None"
	local onlineTime = statistics.OnlineTime or 0
	local race = raceTbl.Race
	local v4 = ""

	if race then
		local v5 = misc2[`{race} V2`] and " V2" or v4
		v4 = misc2[`{race} V3`] and " V3" or v5
	end

	local bountyHunter = titleProgression["Bounty Hunter"] or 0
	local seaKingHunter = titleProgression["Sea King Hunter"] or 0
	local serpentHunter = titleProgression["Serpent Hunter"] or 0
	local hydraHunter = titleProgression["Hydra Hunter"] or 0
	local abyssalTyrantHunter = titleProgression["Abyssal Tyrant Hunter"] or 0
	local drakenfyrtheInfernoKingHunter = titleProgression["Drakenfyr the Inferno King Hunter"] or 0
	local deepseaCrusherHunter = titleProgression["Deepsea Crusher Hunter"] or 0
	local chaosKrakenHunter = titleProgression["Chaos Kraken Hunter"] or 0
	local treasureHunter = titleProgression["Treasure Hunter"] or 0
	local firstSeaDungeon = statistics.FirstSeaDungeon or 0
	local secondSeaDungeon = statistics.SecondSeaDungeon or 0
	local thirdSeaDungeon = statistics.ThirdSeaDungeon or 0
	local v5 = onlineTime / 3600
	local v6 = string.format("%.2f", (tostring(v5)))
	local v7 = tonumber(v6) >= 2 and "Hours" or "Hour"
	local text = ConvertRaceName(race, nil) .. v4
	local v9 = stats.Level >= _G.LevelMaxClient and " (MAX)" or ""
	local text2 = CountTable(titleStore)
	local fightingStyle = stats.FightingStyle or "None"
	local text3

	if CustomNames[fightingStyle] then
		text3 = CustomNames[fightingStyle]
	else
		text3 = fightingStyle
	end

	local text4, image

	if fruit2 and fruit2 ~= "None" then
		local v13 = CustomNames[fruit2] or fruit2
		text4 = v13:sub(1, #v13 / 2)
		image = SwordList[fruit2] and SwordList[fruit2].Image or ""
	else
		text4 = fruit2
		image = ""
	end

	profilePage.ScrollingFrame.SerpentKills.DataText.Text = serpentHunter
	profilePage.ScrollingFrame.Fruit.Icon.Image = image
	profilePage.ScrollingFrame.Fruit.DataText.Text = text4
	profilePage.ScrollingFrame.TotalTitles.DataText.Text = text2
	profilePage.ScrollingFrame.PlayerKills.DataText.Text = bountyHunter
	profilePage.ScrollingFrame.SeaKingKills.DataText.Text = seaKingHunter
	profilePage.ScrollingFrame.HydraKills.DataText.Text = hydraHunter
	profilePage.ScrollingFrame.AbyssalTyrantKills.DataText.Text = abyssalTyrantHunter
	profilePage.ScrollingFrame.CrabKills.DataText.Text = deepseaCrusherHunter
	profilePage.ScrollingFrame.TentacleKills.DataText.Text = chaosKrakenHunter
	profilePage.ScrollingFrame.TreasureDiscovered.DataText.Text = treasureHunter
	profilePage.ScrollingFrame["3rdDragonKills"].DataText.Text = drakenfyrtheInfernoKingHunter
	profilePage.ScrollingFrame.PlayTime.DataText.Text = v6 .. " " .. v7
	profilePage.ScrollingFrame.Level.DataText.Text = stats.Level .. v9
	profilePage.ScrollingFrame.Race.DataText.Text = text
	profilePage.ScrollingFrame.Race.Icon.Image = _G.RaceButtonImages[race] or "rbxassetid://129398543561485"
	profilePage.ScrollingFrame["1stDungeon"].DataText.Text = firstSeaDungeon
	profilePage.ScrollingFrame["2ndDungeon"].DataText.Text = secondSeaDungeon
	profilePage.ScrollingFrame["3rdDungeon"].DataText.Text = thirdSeaDungeon
	profilePage.ScrollingFrame.FightingStyle.DataText.Text = text3
	profilePage.ScrollingFrame.FightingStyle.Icon.Image = SwordList[fightingStyle] and SwordList[fightingStyle].Image or ""
	profilePage.PlayerInfo.DisplayName.Text = stats.DisplayName or "N/A"
	profilePage.PlayerInfo.PlayerName.Text = "@" .. stats.PlayerName or "N/A"
	profilePage.Username.Text = (stats.DisplayName or "N/A") .. "'s Statistics"
	profilePage.PlayerInfo.PlayerIcon.Image = stats.Thumbnail or ""
end

task.delay(3, function()
	UpdateProfile()
end)
local v3 = 1

function UpdateMaxJump()
	task.spawn(function()
		local v4 = math.min(math.floor(lvl.Value / 50) + 1, 15)
		v3 = v4 + 1

		if v4 < v3 then
			v3 = v4
		end

		if _G.RaceClient == "Sky" then
			if _G.CheckAwakeClient(localPlayer, "SkyV2") then
				v3 += 2
			else
				v3 += 1
			end
		end
	end)
end

local v4 = " (MAX)"
local v5 = "Points: "
local v6 = "Lv. "

function UpdateSkyJumpText()
	UpdateMaxJump()

	if playerStats2.Language.Value == "TH" then
		v4 = " (ตัน)"
		v5 = "แต้ม: "
		v6 = "เวล. "
	end

	local v7 = v3 / 15
	skyJump.Border.Bar.Line.Size = UDim2.new(v7 * 1, 0, 1, 0)
	skyJump.ValueNum.Text = v6 .. (v3 < 15 and v3 or v3 .. v4)
end

function UpdateText()
	UpdateMaxJump()

	if playerStats2.Language.Value == "TH" then
		v4 = " (ตัน)"
		v5 = "แต้ม: "
		v6 = "เวล. "
	end

	local v7 = playerStats2.sword.Value / _G.LevelMaxClient
	sword.Border.Bar.Line.Size = UDim2.new(1 * v7, 0, 1, 0)
	local v8 = playerStats2.Melee.Value / _G.LevelMaxClient
	melee.Border.Bar.Line.Size = UDim2.new(1 * v8, 0, 1, 0)
	local v9 = playerStats2.DF.Value / _G.LevelMaxClient
	fruit.Border.Bar.Line.Size = UDim2.new(1 * v9, 0, 1, 0)
	local v10 = playerStats2.Defense.Value / _G.LevelMaxClient
	defense.Border.Bar.Line.Size = UDim2.new(1 * v10, 0, 1, 0)
	sword.ValueNum.Text = v6 .. (playerStats2.sword.Value < _G.LevelMaxClient and playerStats2.sword.Value or playerStats2.sword.Value .. v4)
	melee.ValueNum.Text = v6 .. (playerStats2.Melee.Value < _G.LevelMaxClient and playerStats2.Melee.Value or playerStats2.Melee.Value .. v4)
	fruit.ValueNum.Text = v6 .. (playerStats2.DF.Value < _G.LevelMaxClient and playerStats2.DF.Value or playerStats2.DF.Value .. v4)
	defense.ValueNum.Text = v6 .. (playerStats2.Defense.Value < _G.LevelMaxClient and playerStats2.Defense.Value or playerStats2.Defense.Value .. v4)
	statsPage.PointsFrame.PointText.Text = v5 .. playerStats2.Points.Value
	local leveling2 = localPlayer:FindFirstChild("Leveling")

	if not leveling2 then
		return
	end

	local armament2 = leveling2:FindFirstChild("Armament")
	local fishing = leveling2:FindFirstChild("Fishing")

	if not armament2 then
		return
	end

	local level = armament2:GetAttribute("Level") or 1
	local exp = armament2:GetAttribute("Exp") or 0
	local expNeed = armament2:GetAttribute("ExpNeed") or 2000
	local level2 = fishing:GetAttribute("Level") or 1
	local exp2 = fishing:GetAttribute("Exp") or 0
	local expNeed2 = fishing:GetAttribute("ExpNeed") or 2500
	local maxLevel = fishing:GetAttribute("MaxLevel")

	if playerStats2.BusoShopValue.Value == "BusoHaki" and level then
		local v11 = level / _G.ArmamentLevelMaxClient

		if not level or level ~= _G.ArmamentLevelMaxClient then
			v11 = exp / expNeed
		end

		armament.Border.Bar.Line.Size = UDim2.new(1 * v11, 0, 1, 0)
		armament.ValueNum.Text = v6 .. (level < _G.ArmamentLevelMaxClient and level or level .. v4)
	end

	if level2 and maxLevel and level2 == maxLevel then
		statsPage.ScrollingFrame.Fishing.Border.Bar.Line.Size = UDim2.new(1, 0, 1, 0)
		statsPage.ScrollingFrame.Fishing.ValueNum.Text = "Lv. " .. level2 .. v4
	else
		local v11 = math.clamp(exp2 / expNeed2, 0, 1)
		statsPage.ScrollingFrame.Fishing.Border.Bar.Line.Size = UDim2.new(v11, 0, 1, 0)
		statsPage.ScrollingFrame.Fishing.ValueNum.Text = "Lv. " .. level2
	end
end

playerStats2.Points.Changed:Connect(function()
	UpdateText()
end)
UpdateText()
UpdateSkyJumpText()

function UpdateScrolling()
	local uIGridLayout = scrollingFrame2.UIGridLayout
	uIGridLayout.CellSize = UDim2.new(
		0,
		scrollingFrame2.AbsoluteSize.X * 1 - scrollingFrame2.ScrollBarThickness,
		0,
		scrollingFrame2.AbsoluteSize.Y * 0.23809523809523808
	)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

UpdateScrolling()
scrollingFrame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateScrolling()
end)

function UpdateProfileScrolling()
	local uIGridLayout = scrollingFrame.UIGridLayout
	local v7 = scrollingFrame.AbsoluteSize.Y * 0.02
	uIGridLayout.CellPadding = UDim2.new(0, 0, 0, v7)
	uIGridLayout.CellSize = UDim2.new(
		0,
		scrollingFrame.AbsoluteSize.X * 1 - scrollingFrame.ScrollBarThickness,
		0,
		scrollingFrame.AbsoluteSize.Y * 0.13333333333333333
	)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

UpdateProfileScrolling()
scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateProfileScrolling()
end)

function ConvertRaceName(p, p2)
	if p == "Mink" then
		if p2 then
			return "สัตว์"
		end

		p = "Animal"
	elseif p == "Sky" then
		if p2 then
			return "นางฟ้า"
		end

		p = "Angel"
	elseif p == "Sea Beast" then
		if p2 then
			return "เจ้าทะเล"
		end
	else
		if p ~= "Human" then
			p = p == "Fish" and p2 and "เงือก" or p
			return p
		end

		if p2 then
			return "มนุษย์"
		end
	end

	return p
end

lvl.Changed:Connect(function()
	UpdateSkyJumpText()
end)

for _, button in pairs(scrollingFrame2:GetDescendants()) do
	if not button:IsA("TextButton") then
		continue
	end

	if button.Name == "Button" then
		local v7 = button
		button.MouseButton1Click:Connect(function()
			if not v then
				return
			end

			v = false
			task.spawn(function()
				wait(0.1)
				v = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			local value = parent.Value

			if value.Value >= 0 then
				parent.RemoteEvent:FireServer(v7.Parent.Name, value.Value)
			end
		end)
	elseif button.Name == "ArmamentButton" then
		button.MouseButton1Click:Connect(function()
			armConfig.Visible = true
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
		end)
	elseif button.Name == "SkyJumpButton" then
		button.MouseButton1Click:Connect(function()
			skyJumpGuide.Visible = true
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
		end)
	elseif button.Name == "FishingButton" then
		button.MouseButton1Click:Connect(function()
			fishingGuide.Visible = true
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
		end)
	end

	local parent2 = button
	button.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent2,
			ZIndex = 5,
			Circle = true,
			CornerRadius = UDim.new(0.15, 0),
			AntiRatio = true
		})
	end)
end

local MarketplaceService = game:GetService("MarketplaceService")
local scrollingFrameStage = armConfig.ScrollingFrameStage
local scrollingFrameColor = armConfig.ScrollingFrameColor

function UpdateScrollingFrame(instance)
	local uIGridLayout = instance:WaitForChild("UIGridLayout")
	uIGridLayout.CellSize = UDim2.new(
		0,
		(instance.AbsoluteSize.X - instance.ScrollBarThickness) * 1,
		0,
		(instance.AbsoluteSize.Y - instance.ScrollBarThickness) * 0.25
	)
	instance.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end

local flag = nil

for _, button in pairs(scrollingFrameStage:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v7 = button
	button.MouseButton1Click:Connect(function()
		if flag then
			task.spawn(function()
				local message = localPlayer.PlayerStats.Language.Value == "TH" and "โปรดรอซักครู่..." or "Please wait a moment..."
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
					Name = "Armament Stage DB",
					Message = message,
					Color = Color3.fromRGB(255, 255, 255)
				})
			end)
			return
		end

		flag = true
		task.delay(3, function()
			flag = nil
		end)
		local level = tonumber((v7.Name:gsub("Stage", "")))

		if not level then
			return
		end

		ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
			Type = "SelectArmamentLevel",
			Level = level
		})
	end)
end

function UpdateArmamentColorFrame()
	for _, button in pairs(scrollingFrameColor:GetChildren()) do
		if button:IsA("TextButton") then
			button.Visible = false
		end
	end

	local jSONDecode = HttpService:JSONDecode(misc.Value)

	for childName, _ in pairs(jSONDecode) do
		local child = scrollingFrameColor:FindFirstChild(childName)

		if child then
			child.Visible = true
		end
	end
end

misc.Changed:Connect(UpdateArmamentColorFrame)
UpdateArmamentColorFrame()
scrollingFrameStage:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	task.delay(0.1, function()
		UpdateScrollingFrame(scrollingFrameStage)
	end)
end)

for _, button in pairs(scrollingFrameColor:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v7 = button
	button.MouseButton1Click:Connect(function()
		if flag then
			task.spawn(function()
				local message = localPlayer.PlayerStats.Language.Value == "TH" and "โปรดรอซักครู่..." or "Please wait a moment..."
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
					Name = "Armament Stage DB",
					Message = message,
					Color = Color3.fromRGB(255, 255, 255)
				})
			end)
			return
		end

		flag = true
		task.delay(3, function()
			flag = nil
		end)
		_G.ClickFrameEffect({
			Sound = true
		})
		local name2 = v7.Name
		ReplicatedStorage.Chest.Remotes.Functions.ArmamentColorEquip:InvokeServer(name2)
	end)
end

scrollingFrameColor:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	task.delay(0.1, function()
		UpdateScrollingFrame(scrollingFrameColor)
	end)
end)

function UpdateEquipArmament()
	local selectLevel = leveling.Armament:GetAttribute("SelectLevel")

	for _, button in pairs(scrollingFrameStage:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v7 = tonumber((button.Name:gsub("Stage", "")))

		if selectLevel and v7 then
			local _ = selectLevel == v7
		end
	end
end

function UpdateStageArmament()
	local level = leveling.Armament:GetAttribute("Level") or 1
	local v7 = level - 1

	if playerStats2.Language.Value == "TH" then
		armConfig.Description.Text = "<font color =\"#00ff7f\">พลังป้องกัน +" .. v7 .. "%</font> <font color =\"#ff4343\">ความเสียหาย +" .. v7 .. "%</font>"
	else
		armConfig.Description.Text = "<font color =\"#00ff7f\">+" .. v7 .. "% Defense</font> <font color =\"#ff4343\">+" .. v7 .. "% Damage</font>"
	end

	for _, button in pairs(scrollingFrameStage:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		button.Visible = false
		local v8 = tonumber((button.Name:gsub("Stage", "")))

		if v8 and v8 <= level then
			button.Visible = true
		end
	end
end

leveling.Armament:GetAttributeChangedSignal("SelectLevel"):Connect(function()
	wait()
	UpdateEquipArmament()
end)
leveling.Armament:GetAttributeChangedSignal("Level"):Connect(function()
	wait()
	UpdateStageArmament()
end)
UpdateStageArmament()
UpdateEquipArmament()

function UpdateRS()
	local text = playerStats2.Language.Value == "TH" and "คืนค่า " or "Refund "

	if playerStats2.RestatsStock.Value > 0 then
		if playerStats2.Language.Value == "TH" then
			text = "คืนค่า (" .. playerStats2.RestatsStock.Value .. ")"
		else
			text = "Refund (" .. playerStats2.RestatsStock.Value .. ")"
		end
	end

	resetStats.Text = text
end

UpdateRS()
playerStats2.RestatsStock.Changed:Connect(UpdateRS)
resetStats.MouseButton1Click:Connect(function()
	if _G.CheckInCombat() or not v then
		return
	end

	v = false
	task.spawn(function()
		wait(0.1)
		v = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if playerStats2.RestatsStock.Value > 0 then
		if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("ResetStats") then
			UpdateRS()
		end
	else
		MarketplaceService:PromptProductPurchase(localPlayer, 943831127)
	end
end)
resetStats.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = resetStats,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.2, 0)
	})
end)
numberBox.Changed:Connect(function()
	parent.Value.Value = tonumber(numberBox.Text) or 10
end)
parent.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})

	if passivePage.Visible then
		if passivePage.Frame.ConfirmFrame.PassiveRateList.Visible then
			passivePage.Frame.ConfirmFrame.PassiveRateList.Visible = false
			return
		end
	elseif passivePage.Frame.ConfirmFrame.PassiveRateList.Visible then
		passivePage.Frame.ConfirmFrame.PassiveRateList.Visible = false
	end

	if armConfig.Visible then
		armConfig.Visible = nil
	elseif skyJumpGuide.Visible then
		skyJumpGuide.Visible = nil
	elseif fishingGuide.Visible then
		fishingGuide.Visible = nil
	else
		_G.ButtonClicked()
	end
end)
parent.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	parent.Close.Size = UDim2.new(0.15, 0, 0.15, 0)
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.22499999999999998, 0, 0.22499999999999998, 0)
	}):Play()
end)
parent.Close.MouseLeave:Connect(function()
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.15, 0, 0.15, 0)
	}):Play()
end)

function ButtonClick(instance)
	task.spawn(function()
		for _, button in pairs(parent:GetChildren()) do
			if not (button:IsA("ImageButton") and button:GetAttribute("FirstButton")) then
				continue
			end

			if armConfig.Visible then
				armConfig.Visible = false
			end

			if skyJumpGuide.Visible then
				skyJumpGuide.Visible = false
			end

			if fishingGuide.Visible then
				fishingGuide.Visible = false
			end

			if button == instance then
				TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(button.Position.X.Scale, 0, -0.085, 0)
				}):Play()
			else
				TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(button.Position.X.Scale, 0, -0.07, 0)
				}):Play()
			end
		end
	end)
	local uDim = UDim2.new(0.15, 0, 0.22, 0)
	local uDim2 = UDim2.new(0.1725, 0, 0.253, 0)
	instance.Size = uDim
	TweenService:Create(
		instance,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = uDim2
		}
	):Play()

	if instance:FindFirstChild("ImageLabel") then
		instance.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			instance.ImageLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()
	end
end

function UpdateStatsPage(p, p2)
	task.spawn(function()
		if p2 then
			ButtonClick(p2)
		end
	end)
	_G.ClickFrameEffect({
		Sound = true
	})

	for _, frame in pairs(parent:GetChildren()) do
		if not (frame:IsA("Frame") and frame:GetAttribute("StatsPage")) then
			continue
		end

		if frame == p then
			frame.Visible = true

			if frame.Name == "PassivePage" and frame:FindFirstChild("Frame") then
				local passiveBagFrame = frame.Frame:FindFirstChild("PassiveBagFrame")

				if passiveBagFrame then
					passiveBagFrame.Visible = nil
				end

				local slotInfoFrame = frame.Frame:FindFirstChild("SlotInfoFrame")

				if slotInfoFrame then
					slotInfoFrame.Visible = nil
				end
			end
		else
			frame.Visible = nil
		end
	end
end

statsPageButton.MouseButton1Click:Connect(function()
	UpdateStatsPage(statsPage, statsPageButton)
end)
passivePageButton.MouseButton1Click:Connect(function()
	UpdateStatsPage(passivePage, passivePageButton)
end)
profilePageButton.MouseButton1Click:Connect(function()
	UpdateStatsPage(profilePage, profilePageButton)
end)
titlePageButton.MouseButton1Click:Connect(function()
	UpdateStatsPage(titlePage, titlePageButton)
end)

for _, child in pairs(parent:GetChildren()) do
	if not child:GetAttribute("FirstButton") then
		continue
	end

	local parent2 = child
	child.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent2
		})
		parent2.TextLabel.Visible = true
	end)
	local v8 = child
	child.MouseLeave:Connect(function()
		v8.TextLabel.Visible = false
	end)
end

for _, button in pairs(parent:GetChildren()) do
	if not (button:GetAttribute("IsStatsButton") and button:IsA("ImageButton")) then
		continue
	end

	local v7 = button
	button.MouseEnter:Connect(function()
		v7.ZIndex = 1
		local textLabel = v7:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Visible = true
		end

		local imageLabel = v7:FindFirstChild("ImageLabel")

		if imageLabel then
			imageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end
	end)
	local v8 = button
	button.MouseLeave:Connect(function()
		v8.ZIndex = 0
		local textLabel = v8:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Visible = nil
		end

		local imageLabel = v8:FindFirstChild("ImageLabel")

		if imageLabel then
			imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
end

function UpdateStatsScrollingFrame()
	if playerStats2.BusoShopValue.Value == "BusoHaki" then
		scrollingFrame2.Armament.Visible = true
	end

	UpdateScrolling()
end

local busoShopValue = playerStats2:FindFirstChild("BusoShopValue")

if busoShopValue then
	UpdateStatsScrollingFrame()
	busoShopValue.Changed:Connect(function()
		UpdateStatsScrollingFrame()
	end)
end

for _, child in pairs(leveling:GetChildren()) do
	if child:GetAttribute("Exp") then
		child:GetAttributeChangedSignal("Exp"):Connect(function()
			wait(0.1)
			UpdateText()
		end)
	elseif child:GetAttribute("Level") then
		child:GetAttributeChangedSignal("Level"):Connect(function()
			wait(0.1)
			UpdateText()
		end)
	end
end

local flag2 = nil
local v7 = nil
local left = profilePage.Refresh.CanvasGroup.Left
local right = profilePage.Refresh.CanvasGroup.Right

function ResetRadial()
	right.Visible = true
	left.Visible = true
	left.UIGradient.Rotation = 0
	right.UIGradient.Rotation = 0
end

function BeginCooldown(p: number)
	ResetRadial()
	local tween = TweenService:Create(
		right.UIGradient,
		TweenInfo.new(p / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Rotation = 180
		}
	)
	local tween2 = TweenService:Create(
		left.UIGradient,
		TweenInfo.new(p / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Rotation = 180
		}
	)
	task.spawn(function()
		tween:Play()
		tween.Completed:Wait()
		right.Visible = nil
		tween2:Play()
		tween2.Completed:Wait()
		left.Visible = nil
	end)
	local lastTime = tick()

	while task.wait(0.5) and not (p < tick() - lastTime) do

	end

	right.Visible = false
	left.Visible = false
end

profilePage.Refresh.MouseButton1Click:Connect(function()
	if flag2 then
		return
	end

	flag2 = true
	_G.ClickFrameEffect({
		Sound = true
	})

	if v7 then
		v7:Pause()
	end

	profilePage.Refresh.Icon.Rotation = 0
	local tween = TweenService:Create(profilePage.Refresh.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Rotation = -360
	})
	v7 = tween
	tween:Play()
	task.spawn(function()
		tween.Completed:Wait()

		if v7 == tween then
			profilePage.Refresh.Icon.Rotation = 0
			v7 = nil
		end
	end)
	UpdateProfile()
	task.spawn(function()
		BeginCooldown(1)
	end)
	task.delay(1, function()
		flag2 = nil
	end)
end)
profilePage.Refresh.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = profilePage.Refresh,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.25, 0)
	})
end)
scrollingFrame.FightingStyle.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = scrollingFrame.FightingStyle,
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.25, 0)
	})
end)
scrollingFrame["Drop Boost"].MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = scrollingFrame["Drop Boost"],
		ZIndex = 5,
		Circle = true,
		CornerRadius = UDim.new(0.25, 0)
	})
end)
profilePage.Parent.ProfilePageButton.MouseButton1Click:Connect(function()
	name = localPlayer.Name
	UpdateProfile()
end)
profilePage.PlayerInfo.SearchBar.TextBox.FocusLost:Connect(function()
	local text = profilePage.PlayerInfo.SearchBar.TextBox.Text

	if text == "" then
		name = localPlayer.Name
		UpdateProfile()
	else
		local v8 = FindPlayer(text)

		if name ~= v8 then
			name = v8
			UpdateProfile()
		end
	end
end)