local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.Policy)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v4 = require3(script.Parent.BattlepassViewController)
require3(ReplicatedStorage2.Shared.Battlepass.BattlepassExplosionCrate)
local v5 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassGachaProducts)
local v6 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v7 = require3(ReplicatedStorage2.Common.GachaItemsData)
local v8 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v9 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v10 = require3(ReplicatedStorage2.Common.RewardInfo)
local v11 = require3(ReplicatedStorage2.Shared.Statable)
local v12 = require3(ReplicatedStorage2.Packages.Net)
local v13 = require3(ReplicatedStorage2.Packages.Freeze)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v14 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v15 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v16 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v17 = require3(ReplicatedStorage2.Packages.Trove)
local v18 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v19 = require3(ReplicatedStorage2.Controllers.AutoDeleteItemController)
local v20 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v21 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local playerGui = Players.LocalPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassSpinGacha

if v16 == "Window" then
	battlepassSpinGacha = playerGui:WaitForChild("BattlepassSpinGacha")
else
	battlepassSpinGacha = nil
end

local main

if v16 == "Window" then
	main = battlepassSpinGacha.Main
else
	main = battlepass.Main.Background.Views.SpinGacha
end

local battlepassBulkSpin = playerGui:WaitForChild("BattlepassBulkSpin")
playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassHelp = playerGui:WaitForChild("BattlepassHelp")
local battlepassOdds = playerGui:WaitForChild("BattlepassOdds")
local scrollingFrame = battlepassOdds.Odds.Odds.ScrollingFrame
local remoteEvent = v12:RemoteEvent("GachaUpdateBestAbilityPrize")
local v22 = require3(script["BattlepassSpinner.story"])
local season = tostring(v21.Season)
local v23 = false
local visible = false
local v25 = false
local v26 = nil
local BattlepassSpinGachaController = {}
BattlepassSpinGachaController._isInvoking = false

function BattlepassSpinGachaController:Spin(flag: boolean?)
	if self._isInvoking then
		return
	end

	local v27 = {}

	while true do
		self._isInvoking = true
		v23 = true
		local v28, v29 = xpcall(function()
			if flag then
				return v.Network:Invoke(`PurchaseInfGachaRounds{v21.Season}DailyExtra`, v25)
			end

			return v.Network:Invoke("GachaSpin", v25)
		end, warn)
		v23 = false
		self._isInvoking = false

		if not (v28 and v29) then
			break
		end

		if not flag then
			table.insert(v27, v29)
		end
	end
end

function BattlepassSpinGachaController:TrySpin()
	local policyInfo = v2:GetPolicyInfo()
	local v27 = v26:Get((`CanPurchaseInfGachaRounds{v21.Season}DailyExtra`))
	local v28 = v26:Get((`InfGachaRounds{v21.Season}`)) or 0
	main.Background.Spin.CountdownHolder.Countdown.Visible = v28 <= 0 and not v27

	if v28 <= 0 then
		if v27 then
			if (v26:Get("InfiniteBattlepass.Currency") or 0) >= 400 then
				self:Spin(true)
				return
			end

			ReplicatedStorage2.Misc.error:Play()
			v20:SendNotification((`Not enough {v21.SeasonData.Currency.Name}!`))
		elseif not policyInfo.ArePaidRandomItemsRestricted then
			return v18:PromptPurchase(v5.Round1, Enum.InfoType.Product)
		end
	else
		self:Spin(false)
	end
end

function BattlepassSpinGachaController:_extraRewards()
	local corner = main.Background.Spin.Corner
	local bar = corner.Progress.Bar
	local label = corner.Label
	local v27 = {
		[10] = 1,
		[30] = 1,
		[50] = 2,
		[70] = 2,
		[100] = 3
	}

	local function getCurrentRewardStage(p)
		local v28 = {}

		for k in v27 do
			table.insert(v28, k)
		end

		table.sort(v28)

		for _, v29 in v28 do
			if p < v29 then
				return v29 - p
			end
		end

		return nil
	end

	local function updateRounds()
		local v28 = v26:Get((`TotalPurchasedInfGachaRounds{v21.Season}`)) or 0
		local v29 = math.clamp(v28 / 100, 0, 1)
		bar:TweenSize(UDim2.fromScale(v29, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.4)
		bar.UIStroke.Enabled = v29 > 0.04
		local currentRewardStage = getCurrentRewardStage(v28)
		label.Text = currentRewardStage and `There are still rewards for the next stage {currentRewardStage}` or ""

		for _, frame in corner.Progress.Lines:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local name = tonumber(frame.Name)
			local v30 = name and v27[name]

			if not (name and v30) then
				continue
			end

			frame.Amount.Text = `x{v30}`
			frame.Amount.ImageLabel.Check.Visible = name <= v28
		end
	end

	v26:OnChange(`TotalPurchasedInfGachaRounds{v21.Season}`, updateRounds)
	task.spawn(updateRounds)
end

function BattlepassSpinGachaController:Update()
	if not v26 then
		v26 = v3.Client:WaitReplion("Data")
	end

	local v27 = v26:Get("BattlepassGacha.SelectedAbility")
	local abilitiesReward = v7.AbilitiesRewards[v27]

	if not abilitiesReward then
		return
	end

	local spin = main.Background.Spin
	v10.createAbilityReward(abilitiesReward.DisplayName)
	local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(abilitiesReward.DisplayName)
	local icon

	if child then
		if abilitiesReward.NoUpgrade or not v7.CheckIfPlayersOwnsBestPrizeAbility(v26) then
			icon = child:GetAttribute("Icon")
		else
			icon = child:GetAttribute("Icon1") or child:GetAttribute("Icon")
		end
	end

	spin.Center.Vector.Image = icon or v.Icons:GetIcon("DEFAULT_MISSING")
	spin.Center.Label.Text = abilitiesReward.DisplayName

	for _, guiObject in spin.BestPrizes.BestPrize.Grid:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local _ = guiObject.Name == v27
		guiObject.Image = "rbxassetid://76751900159885"
		local imageColor

		if guiObject.Name == v27 then
			imageColor = Color3.fromRGB(229, 255, 0)
		else
			imageColor = Color3.fromRGB(255, 255, 255)
		end

		guiObject.ImageColor3 = imageColor
	end
end

function BattlepassSpinGachaController:Start()
	local visible2 = v13.Dictionary.count(v7.AbilitiesRewards) > 1
	main.Background.Spin.Fade.Label.Text = v21.SeasonData.Gacha
	local count = 0

	for k, abilitiesReward in v7.AbilitiesRewards do
		count += 1
		local child = main.Background.Spin.BestPrizes.BestPrize.Grid:FindFirstChild((`Item{count}`))
		local abilityReward = v10.createAbilityReward(abilitiesReward.DisplayName)
		child.Name = k
		child.Vector.Image = abilityReward.Icon or ""
		child.ItemName.Text = abilitiesReward.DisplayName
		local v28 = k
		child.Activated:Connect(function()
			remoteEvent:FireServer(v28)
		end)
		v14:AddFromRewardInfo(child, abilityReward)
	end

	require3(script["BattlepassGachaBack.story"])(main)
	v26 = v3.Client:WaitReplion("Data")

	local function openAutoDelete()
		v19:Prompt("BattlepassGacha", main.Background.Spin.AutoDelete.ItemsList.ScrollingFrame)
		main.Background.Spin.AutoDelete.Visible = true
		main.Background.Spin.BestPrizes.Visible = false
		v19.Trove:Add(function()
			main.Background.Spin.AutoDelete.Visible = false
			main.Background.Spin.BestPrizes.Visible = visible2
		end)
	end

	main.Background.Spin.AutoDelete.Visible = false
	main.Background.Spin.BestPrizes.Visible = visible2
	main.Background.Spin.AutoDelete.Close.Activated:Connect(function()
		v19.Trove:Destroy()
	end)
	main.AutoDelete.Activated:Connect(function()
		if v19.Current == "BattlepassGacha" then
			return v19.Trove:Destroy()
		end

		openAutoDelete()
	end)
	self:Update()
	v26:OnChange("BattlepassGacha.SelectedAbility", function()
		if v19.Current == "BattlepassGacha" then
			openAutoDelete()
		end

		self:Update()
	end)
	client:OnInventoryChange("Ability", function()
		self:Update()
	end)
	main.Background.Spin.Odds.Activated:Connect(function()
		battlepassOdds.Enabled = true
	end)
	battlepassOdds.Odds.Close.Activated:Connect(function()
		battlepassOdds.Enabled = false
	end)
	battlepassOdds.Black.SinkInput.Activated:Connect(function()
		battlepassOdds.Enabled = false
	end)

	local function updateVisibility()
		local enabled

		if v16 == "ShowRoom" then
			enabled = battlepass.Enabled
		else
			enabled = battlepassSpinGacha.Enabled
		end

		if main.Visible and enabled then
			main.Wave:Resume()
		else
			main.Wave:Pause()
		end

		if main.Visible and enabled and not v26:Get((`HaveOpenedInfGacha{v21.Season}`)) then
			battlepassHelp.Enabled = true
			v.Network:Fire("UpdateHaveOpenedGacha")
		end
	end

	main:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
	battlepass:GetPropertyChangedSignal("Enabled"):Connect(updateVisibility)

	if v16 == "Window" then
		battlepassSpinGacha:GetPropertyChangedSignal("Enabled"):Connect(updateVisibility)
	end

	task.spawn(updateVisibility)
	main.Background.Spin.Close.Activated:Connect(function()
		battlepassHelp.Enabled = false

		if battlepassSpinGacha then
			v9:Close(battlepassSpinGacha.Name)
		end

		if battlepassSpinGacha and battlepassSpinGacha:GetAttribute("OpenBattlePass") then
			battlepassSpinGacha:SetAttribute("OpenBattlePass", nil)
			v4:OpenView("Battlepass")
		elseif main:GetAttribute("ForceClose") then
			main:SetAttribute("ForceClose", false)
			v4:Close()
		elseif v16 == "ShowRoom" then
			v4:OpenView("Battlepass")
		end
	end)
	local spin = main.Background.Spin

	for i = 1, 5 do
		local bottomReward = v7.BottomRewards[i]
		local child = spin.Items:FindFirstChild((`SmallItem{i}`))

		if child then
			local item = child:FindFirstChild("Item")

			if item and bottomReward.Icon then
				item.Image = bottomReward.Icon
			end
		end

		local item = scrollingFrame.Normal.Items[`Slot{i}`]
		item.Vector.Image = bottomReward.Icon or ""
		item.Label.Text = `{v.ValueConvertor:AddCommas(bottomReward.Probability)}%`

		if bottomReward.RewardInfo and v14:CanShowRewardInfo(bottomReward.RewardInfo) then
			v14:AddFromRewardInfo(item, bottomReward.RewardInfo)
			v14:AddFromRewardInfo(child, bottomReward.RewardInfo)
		else
			v14:Remove(item)
			v14:Remove(child)
		end

		local inspect = child:FindFirstChild("Inspect")

		if inspect then
			if bottomReward.RewardInfo and v15:CanPreview(bottomReward.RewardInfo) then
				inspect.Visible = true
				local v28 = bottomReward
				inspect.Activated:Connect(function()
					v15:PreviewReward(v28.RewardInfo, nil)
				end)
			else
				inspect.Visible = false
			end
		end

		if bottomReward.ItemName ~= "Magic Token" then
			continue
		end

		local v28 = item
		local v29 = i

		local function updateChestIcon()
			local expect = v26:GetExpect("BattlepassGacha.SelectedAbility")
			local abilitiesReward = v7.AbilitiesRewards[expect]
			v28.Vector.Image = abilitiesReward.ChestIcon
			battlepassOdds.Odds.Odds.CrateIcon.Image = abilitiesReward.ChestIcon
			local child2 = spin.Items:FindFirstChild((`SmallItem{v29}`))
			local item2

			if child2 then
				item2 = child2:FindFirstChild("Item")
			end

			if item2 then
				item2.Image = abilitiesReward.ChestIcon
			end
		end

		v26:OnChange("BattlepassGacha.SelectedAbility", updateChestIcon)
		task.spawn(updateChestIcon)
	end

	for i = 1, 4 do
		local topReward = v7.TopRewards[i]
		local item = scrollingFrame.Epic.Items[`Slot{i}`]
		item.Vector.Image = topReward.Icon
		item.Label.Text = `{v.ValueConvertor:AddCommas(topReward.Probability)}%`
		local child = spin.Items:FindFirstChild((`BigItem{i}`))
		local item2 = child and child:FindFirstChild("Item")

		if not (child and item2) then
			continue
		end

		if not topReward.Icon then
			v.Icons:GetIcon("DEFAULT_MISSING")
		end

		item2.Image = topReward.Icon
		child.ItemName.Text = topReward.ItemName
		local v28 = item
		local v29 = child

		local function updateHoverInfo(p)
			if p and v14:CanShowRewardInfo(p) then
				v14:AddFromRewardInfo(v28, p)
				v14:AddFromRewardInfo(v29, p)
			else
				v14:Remove(v28)
				v14:Remove(v29)
			end
		end

		local maid = v17.new()
		local v31 = child

		local function updateInspect(p)
			maid:Clean()
			local inspect = v31:FindFirstChild("Inspect")

			if inspect then
				if p and v15:CanPreview(p) then
					inspect.Visible = true
					maid:Add(inspect.Activated:Connect(function()
						v4:CloseView("SpinGacha")
						v4:Close()
						v15:PreviewReward(p, nil, function()
							v4:Open()
							v4:OpenView("SpinGacha")
						end)
					end))
				else
					inspect.Visible = false
				end
			end
		end

		if topReward.ItemName == "Ability Token" then
			local v32 = item
			local v33 = item2
			local v34 = child

			local function updateToken()
				local v35 = v7.CheckIfPlayersOwnsBestPrizeAbility(v26)
				local v36 = assert(v7.GetAbilityRewardData(v26))
				local v37 = assert(v7.GetAbilityToken(v26))
				local v38 = v26:Get("BattlepassGacha.SelectedAbility")

				if v35 and not v36.NoUpgrade then
					v32.Vector.Image = v37.Icon
					v33.Image = v37.Icon
					local v39 = v26:Get({ "BattlepassGacha", "AbilitiesToken", v37.ItemName }) or 0
					v32.Vector.Image = v36.UpgradeTokenIcon
					v33.Image = v36.UpgradeTokenIcon
					v34.ItemName.Text = `{v39}/1`
				elseif v35 then
					v32.Vector.Image = v36.AbilityTokenIcon
					v33.Image = v36.AbilityTokenIcon
					v34.ItemName.Text = "1/1"
				else
					local v39 = v26:Find({ "BattlepassGacha", "AbilitiesRequirements", v38 }, v37.ItemName) ~= nil
					v32.Vector.Image = v36.AbilityTokenIcon
					v33.Image = v36.AbilityTokenIcon
					v34.ItemName.Text = `{v39 and 1 or 0}/1`
				end
			end

			v26:OnChange("Abilities.Unlocked", updateToken)
			v26:OnChange("BattlepassGacha.SelectedAbility", updateToken)
			v26:OnDescendantChange("BattlepassGacha.AbilitiesRequirements", updateToken)
			v26:OnDescendantChange("BattlepassGacha.AbilitiesToken", updateToken)
			task.spawn(updateToken)
			updateInspect()
			updateHoverInfo()
		elseif topReward.GetCustomReward then
			local v32 = topReward
			local v33 = item
			local v34 = item2
			local v35 = child
			local updateInspect2 = updateInspect
			local updateHoverInfo2 = updateHoverInfo

			local function updateItem()
				local customReward = v32.GetCustomReward(v26)

				if customReward.Type == "Sword" then
					v33.Vector.Image = customReward.Icon or v.Icons:GetIcon("DEFAULT_MISSING")
					v34.Image = customReward.Icon or v.Icons:GetIcon("DEFAULT_MISSING")
					v35.ItemName.Text = customReward.DisplayName or "MISSING DISPLAY NAME"
				end

				updateInspect2(customReward)
				updateHoverInfo2(customReward)
			end

			v26:OnChange("BattlepassGacha.SelectedAbility", updateItem)
			task.spawn(updateItem)
		else
			local rewardInfo = topReward.RewardInfo or topReward.GetCustomReward and topReward.GetCustomReward(v26)
			updateHoverInfo(rewardInfo)
			updateInspect(rewardInfo)
		end
	end

	for _, image in spin.Top:GetChildren() do
		if not image:IsA("ImageLabel") then
			continue
		end

		local v28 = image
		v11.Computed(function(callback)
			local v29 = callback((v11.getReplionPathState(v26, "BattlepassGacha.SelectedAbility")))
			local abilitiesReward = v7.AbilitiesRewards[v29]

			if not abilitiesReward or abilitiesReward.NoUpgrade then
				v28.Visible = false
				return nil
			end

			local displayName = abilitiesReward.DisplayName

			if v28.Name == "First" then
				v28.Image = v.Icons:GetAbilityIcon(displayName)
				v28.Visible = true
			elseif v28.Name == "Upgrade" then
				v28.Image = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(displayName):GetAttribute("Icon1") or v.Icons:GetAbilityIcon(displayName)
				v28.Visible = true
			elseif v28.Name == "Token" then
				v28.Image = v7.MagicTokenImage
				local label = v28:FindFirstChild("Label")

				if label then
					local abilityToken = v7.GetAbilityToken(v26)

					if not abilityToken then
						v28.Visible = false
						return nil
					end

					v28.Visible = true
					v28.Image = abilityToken.UpgradeIcon
					local v30 = callback((v11.getReplionPathState(
						v26,
						{ "BattlepassGacha", "AbilitiesToken", abilityToken.ItemName }
					))) or 0
					label.Text = `{tostring(v30)}/1`
					local textColor

					if v30 > 0 then
						textColor = Color3.fromRGB(255, 255, 255)
					else
						textColor = Color3.fromRGB(255, 101, 101)
					end

					label.TextColor3 = textColor
				end
			end

			return nil
		end)
	end

	local function updateTopVisibility()
		local v28 = v26:Get("BattlepassGacha.SelectedAbility")
		local v29

		if v28 then
			v29 = v7.AbilitiesRewards[v28]
		end

		if v29 and not v29.NoUpgrade then
			if v7.CheckIfPlayersOwnsBestPrizeAbility(v26) then
				spin.Top.Visible = true
				spin.TopNoUpgrade.Visible = false
			else
				spin.Top.Visible = false
				spin.TopNoUpgrade.Visible = true
			end
		else
			spin.Top.Visible = false
			spin.TopNoUpgrade.Visible = true
		end
	end

	client:OnInventoryChange("Ability", updateTopVisibility)
	v26:OnChange("BattlepassGacha.SelectedAbility", updateTopVisibility)
	task.spawn(updateTopVisibility)

	local function checkItemOwnershipStatus(data)
		local v28 = false

		if data.AwardFunctionName == "AddAbility" then
			local v29 = v7.CheckIfPlayersOwnsBestPrizeAbility(v26)
			local v30 = v7.CheckIfPlayerOwnsOriginalInfinity(v26)

			if data.ItemName ~= "Infinity" or not (v29 or v30) then
				return v26:Find("Abilities.Unlocked", data.ItemName) ~= nil
			end

			local v31 = assert(v7.GetAbilityToken(v26))
			local v32 = v26:Get({ "BattlepassGacha", "AbilitiesToken", v31.ItemName }) or 0

			if v29 and v30 and v32 >= 2 or v30 and not v29 and v32 >= 1 then
				return true
			end

			return v28
		else
			if data.AwardFunctionName == "AddEmote" then
				local v29 = v26:Get("Emotes.Unlocked")
				return v29 and v29[data.AwardFunctionArguments[1]] == true
			end

			if data.AwardFunctionName == "AddSwordSkin" then
				return v26:Find("SwordSkins.Unlocked", data.ItemName) ~= nil
			end

			if data.GetCustomReward then
				local customReward = data.GetCustomReward(v26)
				local v29 = {
					"PurchasedShopItems",
					(`GachaSpin-{v21.Season}-{customReward.Type}-{customReward.Value}`)
				}
				return v26:Get(v29) == true
			else
				if data.ItemName ~= "Ability Token" then
					return v28
				end

				local v29 = v7.CheckIfPlayersOwnsBestPrizeAbility(v26)
				local v30 = assert(v7.GetAbilityToken(v26))

				if v29 then
					return (v26:Get({ "BattlepassGacha", "AbilitiesToken", v30.ItemName }) or 0) >= 1
				end

				local v31 = {
					"BattlepassGacha",
					"AbilitiesRequirements",
					(v26:GetExpect("BattlepassGacha.SelectedAbility"))
				}
				return v26:Find(v31, v30.ItemName) ~= nil
			end
		end
	end

	local function updateAllItemsOwnershipStatus()
		for i = 1, 5 do
			local visible3 = checkItemOwnershipStatus(v7.BottomRewards[i])
			scrollingFrame.Normal.Items[`Slot{i}`].Owned.Visible = visible3
			local child = spin.Items:FindFirstChild((`SmallItem{i}`))

			if not child then
				continue
			end

			local collected = child:FindFirstChild("Collected")

			if collected then
				collected.Visible = visible3
			end
		end

		for i = 1, 4 do
			local visible3 = checkItemOwnershipStatus(v7.TopRewards[i])
			scrollingFrame.Epic.Items[`Slot{i}`].Owned.Visible = visible3
			local child = spin.Items:FindFirstChild((`BigItem{i}`))

			if not child then
				continue
			end

			local collected = child:FindFirstChild("Collected")

			if collected then
				collected.Visible = visible3
			end
		end
	end

	v26:OnChange("Abilities.Unlocked", updateAllItemsOwnershipStatus)
	v26:OnChange("Emotes.Unlocked", updateAllItemsOwnershipStatus)
	v26:OnChange("SwordSkins.Unlocked", updateAllItemsOwnershipStatus)
	v26:OnDescendantChange("BattlepassGacha.AbilitiesToken", updateAllItemsOwnershipStatus)
	v26:OnDescendantChange("BattlepassGacha.AbilitiesRequirements", updateAllItemsOwnershipStatus)
	v26:OnChange("TimeHoleUpgrade", updateAllItemsOwnershipStatus)
	v26:OnChange("BattlepassGacha.SelectedAbility", updateAllItemsOwnershipStatus)
	v26:OnChange("PurchasedShopItems", updateAllItemsOwnershipStatus)
	updateAllItemsOwnershipStatus()
	spin.Skip.Activated:Connect(function()
		visible = not visible
		spin.Skip.Check.Visible = visible
		v25 = visible
	end)
	spin.Spin.Activated:Connect(function()
		self:TrySpin()
	end)

	local function update()
		local v28 = v26:Get((`CanPurchaseInfGachaRounds{v21.Season}DailyExtra`))
		local v29 = v26:Get((`InfGachaRounds{v21.Season}`)) or 0
		spin.Spin.Label.Position = UDim2.fromScale((v29 > 0 or v29 <= 0 and not v28) and 0.5 or 0.618, 0.492)
		local label = spin.Spin.Label
		local textXAlignment

		if v29 > 0 or v29 <= 0 and not v28 then
			textXAlignment = Enum.TextXAlignment.Center
		else
			textXAlignment = Enum.TextXAlignment.Left
		end

		label.TextXAlignment = textXAlignment
		local imageLabel = spin.Spin.ImageLabel
		imageLabel.Visible = v29 <= 0 and v28

		if v28 and v29 <= 0 then
			spin.Spin.Label.Text = `400 {v21.SeasonData.Currency.Name}`
		else
			spin.Spin.Label.Text = `Spin ({v29})`
		end
	end

	v26:OnChange(`CanPurchaseInfGachaRounds{v21.Season}DailyExtra`, update)
	v26:OnChange(`InfGachaRounds{v21.Season}`, update)
	task.spawn(update)
	task.spawn(function()
		local flag = false
		spin["1"].Activated:Connect(function()
			if flag then
				return
			end

			v18:PromptPurchase(v5.Round1, Enum.InfoType.Product)
		end)
		v8(spin["1"].Price, v5.Round1, "DevProduct", ":robux:%s")
		spin["10"].Activated:Connect(function()
			if flag then
				return
			end

			v26:Get("Emotes.Unlocked.Emote398")
			v26:Find("SwordSkins.Unlocked", "Sandstorm's Edge")
			v26:Find("SwordSkins.Unlocked", "Eldermarine Blade")
			v26:Find("Abilities.Unlocked", "Slashes of Fury")

			if (v26:Get((`TotalPurchasedInfGachaRounds{v21.Season}`)) or 0) >= 50 then
				battlepassBulkSpin.Enabled = true
			else
				v18:PromptPurchase(v5.Round10, Enum.InfoType.Product)
			end
		end)
		v8(spin["10"].Price, v5.Round10, "DevProduct", ":robux:%s")
		spin.Gift.Activated:Connect(function()
			if flag then
				return
			end

			v6:SetGift("GiftSeasonPassSpin10")
		end)
		local policyInfo = v2:GetPolicyInfo()

		if policyInfo.ArePaidRandomItemsRestricted == nil then
			v2.PolicyInfoAdded:Connect(function(p)
				if p.ArePaidRandomItemsRestricted then
					flag = true
				end
			end)
		elseif policyInfo.ArePaidRandomItemsRestricted then
			flag = true
		end
	end)
	battlepassBulkSpin.SpinShop.Close.Activated:Connect(function()
		battlepassBulkSpin.Enabled = false
	end)

	for _, v28 in { battlepassBulkSpin.SpinShop.Bottom, battlepassBulkSpin.SpinShop.Top } do
		for _, image in v28:GetChildren() do
			if not image:IsA("ImageLabel") then
				continue
			end

			local v29 = tonumber(string.match(image.Name, "(%d+)"))

			if not v29 then
				continue
			end

			image.Icon.Image = v10.createGachaSpinsReward(v29).Icon or v.Icons:GetIcon("DEFAULT_MISSING")
			local v30 = v5[`Round{v29}`]

			if not v30 then
				continue
			end

			v8(image.Spin.Label, v30, "DevProduct", "%s")
			local v31 = v30
			image.Spin.Activated:Connect(function()
				v18:PromptPurchase(v31, Enum.InfoType.Product)
			end)
			local v32 = v29
			image.Gift.Activated:Connect(function()
				v6:SetGift((`GiftSeasonPassSpin{v32}`))
				battlepassBulkSpin.Enabled = false
			end)
		end
	end

	function v.Network.Events.GachaSpinStartBottom(p: number, data)
		v22(main, "Small", p, data.DisplayName or data.ItemName, data.Icon, v25)
	end

	function v.Network.Events.GachaSpinEndBottom(_: number, _) end

	function v.Network.Events.GachaSpinStartTop(p: number, data)
		v22(main, "Big", p, data.DisplayName or data.ItemName, data.Icon, v25)
	end

	function v.Network.Events.GachaSpinEndTop(_: number, _) end

	self:_extraRewards()
	local remoteEvent2 = v12:RemoteEvent("GachaBigRewardNotify")
	local megaWinners = main.Background.Spin.MegaWinners
	local textLabel = megaWinners.ScrollingFrame.TextLabel
	textLabel.Parent = nil
	local clones = {}
	remoteEvent2.OnClientEvent:Connect(function(p: string, p2: string)
		local clone = textLabel:Clone()
		clone.LayoutOrder = 20 - #clones
		clone.Visible = true
		clone.Text = string.format(
			"<stroke color=\"#000000\" thickness=\"2\">%s obtained <font color=\"#9090ff\">%s</font>!</stroke>",
			p,
			p2
		)
		clone.Parent = megaWinners.ScrollingFrame
		table.insert(clones, clone)

		if #clones > 20 then
			assert(table.remove(clones, 1)):Destroy()
		end
	end)
	local help = main.Background.Spin:FindFirstChild("Help", true)

	if help then
		help.Activated:Connect(function()
			battlepassHelp.Enabled = true
		end)
	end

	v.Thread.Every(1, function()
		local v28 = v26:Get((`CanPurchaseInfGachaRounds{v21.Season}DailyExtra`))
		local visible3 = (v26:Get((`InfGachaRounds{v21.Season}`)) or 0) <= 0
		main.Background.Spin.CountdownHolder.Countdown.Visible = visible3

		if visible3 then
			if v28 then
				main.Background.Spin.CountdownHolder.Countdown.Label.Text = "1"
				main.Background.Spin.CountdownHolder.Countdown.Timer.Text = "spin left today"
			else
				local v30 = math.max(0, v26:Get((`GachaDailyLogin{season}`)) - workspace:GetServerTimeNow())
				main.Background.Spin.CountdownHolder.Countdown.Label.Text = "Next"
				main.Background.Spin.CountdownHolder.Countdown.Timer.Text = v30 == 0 and "spin available now" or `spin in {v.ValueConvertor:FormatTimeWithDaysFull(v30)}`
			end
		end
	end)
	local total = 0

	for i = 1, v21.Season do
		local v28 = v26:Get((`InfGachaTimesSpun{i}`))

		if typeof(v28) == "number" then
			total += v28
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFeatureVisibility()
		local visible3 = (v26:Get((`InfGachaTimesSpun{v21.Season}`)) or 0) >= 5 or total >= 5
		main.Background.Spin.Corner.Visible = visible3
		main.AutoDelete.Visible = visible3
	end

	v26:OnChange(`InfGachaTimesSpun{v21.Season}`, updateFeatureVisibility)
	updateFeatureVisibility() -- equivalent call inferred; original call site unknown

	local function updateUseSteps()
		local visible3 = v26:Get("InfiniteBattlepass.UseSteps") or false
		local visible4 = not visible3
		main.Background.Spin.Spin.Visible = visible4
		main.Background.Spin.Items.Visible = visible4
		main.Background.Spin.Center.Visible = visible4
		main.Background.Spin.CountdownHolder.Visible = visible4
		main.Background.Spin["1"].Visible = visible4
		main.Background.Spin["10"].Visible = visible4
		main.Background.Spin.Gift.Visible = visible4
		main.Background.Spin.Payladder.Visible = visible3
	end

	v26:OnChange("InfiniteBattlepass.UseSteps", updateUseSteps)
	updateUseSteps()
	local v28 = v17.new()
	local v29 = {
		Green = "rbxassetid://131278853276216",
		Blue = "rbxassetid://106939264384954",
		Yellow = "rbxassetid://134924942064110"
	}
	local scrollingFrame2 = main.Background.Spin.Payladder.ScrollingFrame

	local function loadSteps()
		v28:Clean()
		local v30 = v26:Get("InfiniteBattlepass.Steps") or {}
		local v31 = v26:Get((`InfGachaRounds{v21.Season}`)) or 0

		for k, v32 in v30 do
			local v33

			if v32.pool == "Bottom" then
				v33 = v7.BottomRewards
			else
				v33 = v7.TopRewards
			end

			local v34 = v33[v32.index]

			if v34.GetCustomReward then
				v34 = v34.GetCustomReward(v26)
			end

			if v34.ItemName == "Ability Token" then
				v26:Get("BattlepassGacha.SelectedAbility")
				v34 = v7.GetAbilityToken(v26)
			end

			local clone = scrollingFrame2.UIListLayout.Holder:Clone()
			v28:Add(clone)
			local card = clone.Card
			card.BG.Image = v29[v34.Rarity or "Blue"] or "rbxassetid://106939264384954"
			card.ItemName.Text = v34.DisplayName or v34.ItemName
			card.Vector.Image = v34.Icon or v.Icons:GetIcon("DEFAULT_MISSING")
			card.Buy.Visible = k == 1
			card.Buy.Price.Visible = v31 <= 0
			card.Buy.Claim.Visible = v31 > 0
			card.Buy.Activated:Connect(function()
				if (v26:Get((`InfGachaRounds{v21.Season}`)) or 0) > 0 then
					v12:Invoke("InfiniteBattlepass/ClaimStep", 1)
				else
					v18:PromptPurchase(v5.Round1, Enum.InfoType.Product)
				end
			end)
			clone.Parent = scrollingFrame2
		end
	end

	v26:OnChange("InfiniteBattlepass.Steps", loadSteps)
	v26:OnChange("BattlepassGacha.SelectedAbility", loadSteps)
	loadSteps()
	main.Background.Spin.Payladder["10StepsBuyFrame"]["10StepsBuy"].Activated:Connect(function()
		if (v26:Get((`InfGachaRounds{v21.Season}`)) or 0) > 0 then
			v12:Invoke("InfiniteBattlepass/ClaimStep", 10)
		else
			v18:PromptPurchase(v5.Round10, Enum.InfoType.Product)
		end
	end)

	local function updateRounds()
		local v30 = v26:Get((`InfGachaRounds{v21.Season}`)) or 0

		for _, frame in scrollingFrame2:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local card = frame.Card
			card.Buy.Price.Visible = v30 <= 0
			card.Buy.Claim.Visible = v30 > 0
		end
	end

	v26:OnChange(`InfGachaRounds{v21.Season}`, updateRounds)
	updateRounds()

	function v.Network.Events.GachaSpinDoClick()
		if v26:Get("InfiniteBattlepass.UseSteps") then
			return
		end

		self:Spin(false)
	end
end

return BattlepassSpinGachaController