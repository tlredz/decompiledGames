local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("StarterGui")
game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
require3(ReplicatedStorage2.Common.MarketplaceService)
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Shared.Policy)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v8 = require3(ReplicatedStorage2.Packages.Trove)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v9 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v10 = require3(ReplicatedStorage2.Shared.LootboxData)
local v11 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v12 = require3(game.ReplicatedStorage.Controllers.GiftingController)
require3(ReplicatedStorage2.Controllers.UI.HUDController)
require3(game.ReplicatedStorage.Common.RadialSpriteSheetGenerator)
local v13 = require3(script.BigRewardAnimation)
local v14 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local v15 = require3(script.MysteryCrateAnimation)
require3(ReplicatedStorage2.ServerInfo)
local v16 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v17 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v18 = require3(ReplicatedStorage2.Controllers.FinishersController)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v19 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v20 = require3(ReplicatedStorage2.Shared.DeepCopy)
local v21 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v22 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local remoteEvent = v2:RemoteEvent("ChangeSelectedGachaType")
local remoteEvent2 = v2:RemoteEvent("ProductPurchaseProcessed")
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local policyInfo = nil
local child = nil
local main = nil
local bulkRewards = nil
local megaReward = nil
local v28 = 0
local flag = false
local v29 = nil
local v30 = {}
local v31 = 0
local flag2 = false
local v32 = v10.ActiveGacha.Name == "SoccerGacha"
local v33 = GuiService:IsTenFootInterface() == true
local v34 = {
	Brazil = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 134, 9)),
			ColorSequenceKeypoint.new(0.370242, Color3.fromRGB(192, 245, 0)),
			ColorSequenceKeypoint.new(0.600346, Color3.fromRGB(255, 204, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(89, 255, 0))
		}),
		rotation = 47
	},
	England = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
			ColorSequenceKeypoint.new(0.179931, Color3.fromRGB(234, 240, 245)),
			ColorSequenceKeypoint.new(0.467128, Color3.fromRGB(154, 48, 51)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 0, 4))
		}),
		rotation = 47
	},
	France = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 76, 134)),
			ColorSequenceKeypoint.new(0.119377, Color3.fromRGB(0, 76, 134)),
			ColorSequenceKeypoint.new(0.444637, Color3.fromRGB(234, 240, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 0, 4))
		}),
		Rotation = 47
	},
	Germany = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 191, 0)),
			ColorSequenceKeypoint.new(0.480969, Color3.fromRGB(134, 0, 2)),
			ColorSequenceKeypoint.new(1, Color3.new())
		}),
		rotation = 47
	},
	USA = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.480969, Color3.fromRGB(34, 87, 134)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))
		}),
		rotation = 47
	}
}
local gui = v10.ActiveGacha.Gui
local name = v10.ActiveGacha.Name

local function fn() end

local v35 = {
	Hook = {
		All = false
	},
	TrackChanges = {}
}
local v36 = {
	SwordSkins = "Sword",
	Abilities = "Ability"
}
local GenericGachaController = {
	Identifier = name,
	_announcmentQueue = {},
	_gridQueue = {},
	_spriteSheet = nil,
	_skipping = false,
	_lastRewardSoundTime = 0,
	_rewardSoundCooldown = 0.75,
	_lastRewardGlowSoundTime = 0,
	_rewardGlowSoundCooldown = 0.75
}

local function fastAudio(soundId: string, parent, value: number?, value2: number?, value3: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = parent
	sound.Volume = value or 0.5
	sound.PlaybackSpeed = value2 or 1
	sound.TimePosition = value3 or 0
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

local function playerOwnsBigReward(dataReplion, data, flag3: boolean?)
	local v37 = false
	local bigRewardState = nil

	if not flag3 then
		for _, v39 in v30 do
			for _, v41 in v39[2] do
				if v41.Done then
					continue
				end

				bigRewardState = v41.BigRewardState
				break
			end

			if bigRewardState then
				break
			end
		end
	end

	local gachaIdentifier = getGachaIdentifier(dataReplion)
	local v38 = v32 and {
		"GachaData",
		gachaIdentifier,
		(`{dataReplion:GetExpect({ "GachaData", gachaIdentifier, "SelectedItem" })}BigRewards`)
	} or { "GachaData", gachaIdentifier, "BigRewards" }
	local v39 = bigRewardState or dataReplion:Get(v38)

	if data.Path ~= nil then
		local v40 = string.split(data.Path, ".")[1]
		local v41 = v36[v40]

		if v41 or v40 == "Finishers" then
			if v41 or v40 ~= "Finishers" then
				v37 = #client:FindItems(v41, data.Value) > 0
			else
				v37 = dataReplion:Find("Finishers.Unlocked", data.Value) ~= nil
			end
		else
			task.spawn(error, (`Failed to check if player owns item from old path: {data.Path}!`))
		end
	elseif v39 then
		v37 = table.find(v39, (`{data.Type}_{data.Value}`)) ~= nil
	else
		v37 = false
	end

	local currentGachaData = getCurrentGachaData(dataReplion)

	if flag3 then
		return v37
	end

	for _, v40 in v30 do
		for _, v41 in v40[2] do
			if v41.Done then
				continue
			end

			local v42

			if v32 then
				local v43 = tonumber(string.match(v41.RewardKey, "_(%d+)"))

				if not v43 then
					continue
				end

				local expect = dataReplion:GetExpect({ "GachaData", getGachaIdentifier(dataReplion), "SelectedItem" })
				v42 = assert(
					currentGachaData.SpecialBigRewardsData[expect],
					(`Failed to get Big Rewards for country {expect}`)
				)[v43]
			else
				local index = table.find(currentGachaData.BigRewardData, v41.RewardKey)

				if not index then
					continue
				end

				v42 = currentGachaData.PhysicalBigRewardData[index]
			end

			if `{v42.Type}_{v42.Value}` == `{data.Type}_{data.Value}` then
				return false
			end
		end
	end

	return v37
end

-- equivalent calls inferred from this helper; original call sites unknown
local function policyDisabled()
	if policyInfo and policyInfo.ArePaidRandomItemsRestricted then
		v19:SendNotification("Unavailable in your region!")
		return true
	else
		return false
	end
end

function GenericGachaController:GetChances()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local v37

	if v32 then
		local expect = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v38 = assert(
			currentGachaData.SpecialBigRewardsData[expect],
			(`Failed to get Big Rewards for item {expect}`)
		)
		v37 = v20(currentGachaData.BaseItems)
		local currentBucket = self:CalculateCurrentBucket()
		local v39

		if currentBucket then
			v39 = `Big_Reward_{currentBucket}`
		end

		for k, v40 in v38 do
			local formatted = `Big_Reward_{k}`

			if playerOwnsBigReward(self.DataReplion, v40.Reward) or not v39 or formatted ~= v39 then
				v37[formatted] = nil
				v37.Low_Tier_Sword.Chance += v40.Chance
			elseif v37[formatted] then
				v37[formatted].Chance = v40.Chance
			end
		end
	else
		v37 = v20(currentGachaData.Items)
		local key = currentGachaData.ChancesFFlag and v4:GetKey(currentGachaData.ChancesFFlag)

		if type(key) == "table" then
			for k, v38 in v37 do
				if key[k] then
					v38.Chance = key[k]
				end
			end
		end

		for k, v38 in currentGachaData.BigRewardData do
			local v39 = currentGachaData.PhysicalBigRewardData[k]
			local rewardKey = currentGachaData.Items[v38].RewardKey

			if playerOwnsBigReward(self.DataReplion, v39) then
				v37[rewardKey] = nil
			end
		end

		local currentBucket = self:CalculateCurrentBucket()
		local v38

		if currentBucket then
			v38 = currentGachaData.BigRewardData[currentBucket]
		end

		for _, v39 in currentGachaData.BigRewardData do
			local rewardKey = currentGachaData.Items[v39].RewardKey

			if not v38 or rewardKey ~= v38 then
				v37[rewardKey] = nil
			end
		end

		for k, v39 in currentGachaData.BigRewardData do
			local item = currentGachaData.Items[v39]
			local rewardKey = item.RewardKey

			if not (k > 1) or v37[rewardKey] then
				continue
			end

			v37.Low_Tier_Sword.Chance += item.Chance
		end
	end

	local chancesByRewardKey = {}

	for _, v38 in v37 do
		if v38.Chance > 0 then
			chancesByRewardKey[v38.RewardKey] = v38.Chance
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v38 = v4:IsDataReady() and (v4:GetKey((`{currentGachaIdentifier}LuckStartTime`)) or 0) <= serverTimeNow and serverTimeNow < (v4:GetKey((`{currentGachaIdentifier}LuckEndTime`)) or 0) and 1 or nil
	local weights = v5.getWeights(chancesByRewardKey, v38, 0.05)
	local result = {}

	for k, relativeWeight in weights.relativeWeights do
		local v39 = math.round(relativeWeight * 100 * 100) / 100
		result[weights.options[k]] = v39
	end

	return result
end

function GenericGachaController:CalculateCurrentBucket(flag3: boolean?)
	local currentGachaData = getCurrentGachaData(self.DataReplion)

	if v32 then
		local expect = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v37 = assert(
			currentGachaData.SpecialBigRewardsData[expect],
			(`Failed to get Big Rewards for item {expect}`)
		)

		for k, v38 in v37 do
			if not playerOwnsBigReward(self.DataReplion, v38.Reward, flag3) or k == #v37 then
				return k, {
					RewardKey = `Card_Reward_{k}`,
					PittyAmount = v38.Pitty
				}
			end
		end
	end

	for k, _ in currentGachaData.BigRewardData do
		local v37 = currentGachaData.PhysicalBigRewardData[k]

		if not playerOwnsBigReward(self.DataReplion, v37, flag3) then
			return k, currentGachaData.PityRewardBucket[k]
		end
	end

	return
		#currentGachaData.PhysicalBigRewardData,
		currentGachaData.PhysicalBigRewardData[#currentGachaData.PhysicalBigRewardData]
end

function GenericGachaController:UpdateLeftSide()
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local leftSide = main:WaitForChild("LeftSide")

	if v32 then
		local expect = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v37 = assert(
			currentGachaData.SpecialBigRewardsData[expect],
			(`Failed to get Big Rewards for item {expect}`)
		)

		for _, child2 in leftSide:GetChildren() do
			local v38 = tonumber(string.match(child2.Name, "(%d+)Reward"))

			if not v38 then
				continue
			end

			local child3 = leftSide:FindFirstChild((`{v38 - 1}Reward`))
			local child4 = leftSide:FindFirstChild((`Level{v38}`))
			local v39 = v37[v38]

			if v39 then
				local visible = playerOwnsBigReward(self.DataReplion, v39.Reward)
				child2.Check.Visible = visible
				child2.Vector.Image = v39.Reward.Icon
				child2.Visible = true

				if child3 then
					child3.Arrow.Visible = true
				end

				if child4 then
					child4.Visible = true
				end
			else
				if child3 then
					child3.Arrow.Visible = false
				end

				if child4 then
					child4.Visible = false
				end

				child2.Visible = false
			end
		end
	else
		for _, child2 in leftSide:GetChildren() do
			if not string.match(child2.Name, "%dReward") then
				continue
			end

			local v37 = tonumber(string.match(child2.Name, "%d"))
			local item = currentGachaData.Items[currentGachaData.BigRewardData[v37]]
			local v38 = currentGachaData.PhysicalBigRewardData[v37]
			local visible = playerOwnsBigReward(self.DataReplion, v38)
			child2.Check.Visible = visible
			child2.Glow.Visible = visible
			child2.Vector.Image = item.ImageId
		end
	end
end

function GenericGachaController:UpdatePittyFrame()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local v37

	if v32 then
		local expect = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "SelectedItem" })
		v37 = self.DataReplion:Get({ "GachaData", currentGachaIdentifier, (`{expect}DidReset`) }) == true
	else
		v37 = self.DataReplion:Get({ "GachaData", currentGachaIdentifier, "DidReset" }) == true
	end

	local rewardPity = main:WaitForChild("RewardPity")
	local guranteeText = rewardPity:WaitForChild("GuranteeText")
	local top = child:WaitForChild("BulkRewards"):WaitForChild("BG"):WaitForChild("Top")
	local main2 = top:WaitForChild("Main")
	local barProgress = main2:WaitForChild("Bar"):WaitForChild("BarProgress")
	local progress = main2:WaitForChild("Progress")
	local icon = main2:WaitForChild("Icon")
	local progressBarFrame = rewardPity:WaitForChild("ProgressBarFrame")
	local bar = progressBarFrame:WaitForChild("Bar")
	local text = progressBarFrame:WaitForChild("Text")
	local title = rewardPity:WaitForChild("Fade"):WaitForChild("Title")
	local _1 = main:WaitForChild("Wheel"):WaitForChild("Icons"):WaitForChild("1")
	local innerIcon = _1:WaitForChild("InnerIcon")
	local bestPrize1 = _1:WaitForChild("BestPrize1")
	local bestPrize2 = _1:WaitForChild("BestPrize2")
	local completed = _1:WaitForChild("Completed")
	local currentBucket, v38 = self:CalculateCurrentBucket(true)
	local v39 = true
	local baseItems, expect

	if v32 then
		local expect2 = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v40 = assert(
			currentGachaData.SpecialBigRewardsData[expect2],
			(`Failed to get Big Rewards for item {expect2}`)
		)
		baseItems = currentGachaData.BaseItems
		expect = self.DataReplion:Get({
			"GachaData",
			getGachaIdentifier(self.DataReplion),
			"PityForItems",
			expect2
		}) or 0

		for _, v42 in v40 do
			v39 = playerOwnsBigReward(self.DataReplion, v42.Reward, true)

			if not v39 then
				break
			end
		end
	else
		expect = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "TotalSpins" })
		baseItems = currentGachaData.Items

		for _, v41 in ipairs(currentGachaData.PhysicalBigRewardData) do
			v39 = playerOwnsBigReward(self.DataReplion, v41, true)

			if not v39 then
				break
			end
		end
	end

	for _, v40 in v30 do
		for _, v41 in v40[2] do
			if not v41.Done then
				expect -= 1
			end
		end
	end

	local v40 = v39 and 0 or currentBucket
	local chances = self:GetChances()

	if v40 == 0 then
		self:UpdateLeftSide()
		rewardPity.Visible = false
		local v41

		if v32 then
			local expect2 = self.DataReplion:GetExpect({
				"GachaData",
				getGachaIdentifier(self.DataReplion),
				"SelectedItem"
			})
			local v42 = assert(
				currentGachaData.SpecialBigRewardsData[expect2],
				(`Failed to get Big Rewards for item {expect2}`)
			)
			local reward = v42[#v42].Reward
			v41 = {
				ImageId = reward.Icon,
				DisplayName = reward.DisplayName
			}
		else
			v41 = baseItems[currentGachaData.PityRewardBucket[#currentGachaData.PityRewardBucket].RewardKey]
		end

		innerIcon.Image = v41.ImageId
		bestPrize1.Text = v41.DisplayName
		bestPrize2.Text = v41.DisplayName
		completed.Visible = true
		icon.Image = v41.ImageId
		barProgress.Size = UDim2.fromScale(1, bar.Size.Y.Scale)
		progress.Text = "FINISHED"
		(_1:FindFirstChild("Chances") or _1.Ring:FindFirstChild("Chances")).Text = "0%"
	else
		completed.Visible = false
		self:UpdateLeftSide()
		local baseItem = baseItems[v38.RewardKey]

		if v32 then
			local expect2 = self.DataReplion:GetExpect({
				"GachaData",
				getGachaIdentifier(self.DataReplion),
				"SelectedItem"
			})
			local v41 = assert(
				currentGachaData.SpecialBigRewardsData[expect2],
				(`Failed to get Big Rewards for item {expect2}`)
			)[v40]
			baseItem = {
				ImageId = v41.Reward.Icon,
				DisplayName = v41.Reward.DisplayName,
				Chance = v41.Chance
			}
		end

		local key = currentGachaData.PityRewardBucketFFlag and v4:GetKey(currentGachaData.PityRewardBucketFFlag)
		local v41 = key and key[v40] or v38.PittyAmount
		innerIcon.Image = baseItem.ImageId
		bestPrize1.Text = baseItem.DisplayName
		bestPrize2.Text = baseItem.DisplayName
		local visible

		if v37 then
			visible = false
		elseif v41 then
			local v43 = math.max(0, v41 - expect)
			rewardPity.Image = baseItem.ImageId
			icon.Image = baseItem.ImageId
			progress.Text = string.format("%d/%d", expect, v41)
			barProgress.Size = UDim2.fromScale(math.min(1, expect / v41), bar.Size.Y.Scale)
			guranteeText.Text = string.format(
				"<stroke color=\"#000000\" thickness=\"2\">Only <font color=\"#3256ff\">%d</font> spins for guaranteed</stroke>",
				v43
			)
			title.Text = baseItem.DisplayName
			text.Text = string.format("%d/%d", expect, v41)
			bar.Size = UDim2.fromScale(math.min(1, expect / v41), bar.Size.Y.Scale)
			visible = true
		else
			title.Text = baseItem.DisplayName
			visible = false
		end

		rewardPity.Visible = visible
		icon.Visible = visible
		progress.Visible = visible
		barProgress.Visible = visible
		guranteeText.Visible = visible
		text.Visible = visible
		bar.Visible = visible
		top.Visible = visible;
		(_1:FindFirstChild("Chances") or _1.Ring:FindFirstChild("Chances")).Text = `{chances[v38.RewardKey] or baseItem.Chance}%`
	end
end

function GenericGachaController:HideUI()
	v14:SetVisibility(false)
	local playerGui2 = Players.LocalPlayer:WaitForChild("PlayerGui")
	local announcer = playerGui2:WaitForChild("announcer")
	announcer.Enabled = false
	local touchGui = playerGui2:FindFirstChild("TouchGui")

	if touchGui then
		touchGui.Enabled = false
	end

	v17(Enum.CoreGuiType.Chat, false)
	v17(Enum.CoreGuiType.PlayerList, false)
end

function GenericGachaController:ShowUI()
	v14:SetVisibility(true)
	local playerGui2 = Players.LocalPlayer:WaitForChild("PlayerGui")
	local announcer = playerGui2:WaitForChild("announcer")
	announcer.Enabled = true
	local touchGui = playerGui2:FindFirstChild("TouchGui")

	if touchGui then
		touchGui.Enabled = true
	end

	v17(Enum.CoreGuiType.Chat, true)
	v17(Enum.CoreGuiType.PlayerList, true)
end

function GenericGachaController:InsertName(p2: string, p3: string)
	if not main then
		return
	end

	local scrollingFrame = main:WaitForChild("AnnouncementBox"):WaitForChild("ScrollingFrame")
	local clone = main:WaitForChild("RewardAnnouncementTemplate"):Clone()
	clone.LayoutOrder = 20 - #self._announcmentQueue
	clone.Visible = true
	clone.Text = string.format(
		"<stroke color=\"#000000\" thickness=\"2\">%s obtained <font color=\"rgb(155, 243, 143)\">%s</font>!</stroke>",
		p2,
		p3
	)
	clone.Parent = scrollingFrame
	table.insert(self._announcmentQueue, clone)

	if #self._announcmentQueue > 20 then
		table.remove(self._announcmentQueue, 1):Destroy()
	end
end

function GenericGachaController:UpdateMysteryCrateFrame()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local crateMain = main:WaitForChild("CrateMain")
	crateMain:WaitForChild("RadialBar")
	local progress = crateMain:WaitForChild("Progress")
	local expect = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "TotalSpins" })
	local v37 = expect - (expect - expect % currentGachaData.CrateSpinRequirement)
	progress.Text = string.format("%d/%d", v37, currentGachaData.CrateSpinRequirement)
	local radialBar = main:WaitForChild("CrateMain"):WaitForChild("RadialBar")
	self._spriteSheet:UpdateLabel(v37 / currentGachaData.CrateSpinRequirement)
	radialBar.ImageColor3 = Color3.fromRGB(50, 197, 255)
end

function GenericGachaController:IsActive()
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	return workspace:GetServerTimeNow() < currentGachaData.EventEndTimeStamp.UnixTimestamp
end

function GenericGachaController:Open()
	if self:IsActive() then
		v9:Open(gui)
	end
end

function GenericGachaController:UpdateCountdownFrame()
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local time = main:WaitForChild("Header"):WaitForChild("Timer"):WaitForChild("Timer"):WaitForChild("Time")
	local v37 = currentGachaData.EventEndTimeStamp.UnixTimestamp - workspace:GetServerTimeNow()
	time.Text = v11:FormatTimeWithDays(v37)

	if v37 <= 0 and v9:IsOpen(gui) then
		v9:Close(gui, true)
	end
end

function GenericGachaController:SetDisableWheel(flag3: boolean)
	local toggleImage = main:WaitForChild("SkipAnimation"):WaitForChild("Checkbox"):WaitForChild("ToggleImage")
	toggleImage.Visible = flag3
	self._skipping = flag3
end

local clones = {}
local rings = {}
local _ = {
	[true] = "rbxassetid://15431907789",
	[false] = "rbxassetid://15431883359"
}

function GenericGachaController:ShowBigRewardAnimation(p)
	v13:DoAnimation(megaReward, p)
end

function GenericGachaController:ShowRewardScreen(p2)
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local index

	if v32 then
		index = string.find(p2.RewardKey, "Big_Reward") ~= nil

		if index then
			local expect = self.DataReplion:GetExpect({
				"GachaData",
				getGachaIdentifier(self.DataReplion),
				"SelectedItem"
			})
			local v37 = assert(
				currentGachaData.SpecialBigRewardsData[expect],
				(`Failed to get Big Rewards for item {expect}`)
			)[assert((tonumber(string.match(p2.RewardKey, "_(%d+)"))))]
			p2.SimpleReward = {
				[v37.Reward.Type] = v37.Reward.Value
			}
		end
	else
		index = table.find(currentGachaData.BigRewardData, p2.RewardKey)
	end

	if index then
		GenericGachaController:ShowBigRewardAnimation(p2)
	end
end

function GenericGachaController:CanPlayRewardSound()
	local now = os.clock()

	if now - self._lastRewardSoundTime < self._rewardSoundCooldown then
		return false
	end

	self._lastRewardSoundTime = now
	return true
end

function GenericGachaController:CanPlayRewardGlowSound()
	local now = os.clock()

	if now - self._lastRewardGlowSoundTime < self._rewardGlowSoundCooldown then
		return false
	end

	self._lastRewardGlowSoundTime = now
	return true
end

function GenericGachaController:DoItemGlow(instance, _: number)
	local clone = instance:Clone()
	clone.Parent = instance.Parent
	clone.ZIndex = -10
	local tween = TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1.5, 1.5)
	})
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.1),
		{
			ImageTransparency = 1
		}
	)
	tween:Play()
	tween2:Play()

	if GenericGachaController:CanPlayRewardGlowSound() then
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6895079853"
		sound.Parent = SoundService
		sound.Volume = 0.2
		sound.PlaybackSpeed = 0.5
		sound.TimePosition = 0
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
	end

	tween2.Completed:Connect(function()
		clone:Destroy()
	end)
end

function GenericGachaController:DoSpinAnimation(p: number, callback)
	local numberValue = Instance.new("NumberValue")
	local v37 = p + 80
	local v38 = nil
	local v39 = 0
	local v40 = false

	local function endAnimation()
		local clone

		if self:CanPlayRewardSound() then
			clone = ReplicatedStorage2.Misc.reward:Clone()
			clone.Volume = 0.34
			clone.Parent = script
			clone:Play()
		else
			clone = nil
		end

		callback()

		for k, v41 in pairs(rings) do
			v41.Glow.Visible = p == k

			if p == k then
				GenericGachaController:DoItemGlow(v41.Glow, p)
			end
		end

		if clone then
			clone.Ended:Once(function()
				clone:Destroy()
				numberValue:Destroy()
			end)
		else
			numberValue:Destroy()
		end
	end

	if self._skipping then
		return endAnimation()
	end

	numberValue.Changed:Connect(function()
		local v41 = numberValue.Value - 1
		local v42 = math.floor(v41) % 8 + 1
		local value = numberValue.Value

		if v37 - 1 <= value and numberValue.Value < v37 then
			v40 = math.random() < 0.5
		end

		local v43 = v41 % 1

		if v38 then
			v38.Visible = false
		end

		v38 = clones[v42]

		if v38 then
			v38.Position = UDim2.fromScale(v43, 0.5)
		end

		if v42 ~= v39 then
			for k, v44 in pairs(rings) do
				v44.Glow.Visible = k == v42
			end

			local clone = ReplicatedStorage2.Misc.bink:Clone()
			clone.Parent = script
			clone.Volume = clone.Volume or 0.34
			clone:Play()
			task.delay(clone.TimeLength + 0.1, function()
				clone:Destroy()
			end)
		end

		v39 = v42
	end)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(self._skipping and 3 or 5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Value = v37
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if v38 then
			if v40 then
				v38:TweenPosition(UDim2.fromScale(0.8, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, true)
				task.wait(1)
			end

			v38:TweenPosition(UDim2.fromScale(-0.5, 0.5), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 1, true)
			task.wait(1)
			v38.Visible = false
		end

		endAnimation()
	end)
end

function GenericGachaController:ToggleChances(flag3: boolean?)
	for _, child2 in main:WaitForChild("Wheel").Icons:GetChildren() do
		local chances = child2:FindFirstChild("Chances") or child2.Ring:FindFirstChild("Chances")
		local visible

		if flag3 == nil then
			visible = not chances.Visible
		else
			visible = flag3
		end

		chances.Visible = visible
	end
end

function GenericGachaController:UpdateSciFiSpinner()
	local wheel = main:WaitForChild("Wheel")
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local chances = self:GetChances()
	local currentBucket, v37 = self:CalculateCurrentBucket()

	if v32 then
		local expect = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v38 = assert(
			currentGachaData.SpecialBigRewardsData[expect],
			(`Failed to get Big Rewards for item {expect}`)
		)
		local baseItems = currentGachaData.BaseItems
		local v39 = true

		for _, v41 in v38 do
			if playerOwnsBigReward(self.DataReplion, v41.Reward) then
				continue
			end

			v39 = false
			break
		end

		local rewardKeysByFrameAllias = {}
		local v41 = v39 and 0 or currentBucket

		for rewardKey, frameAllias in currentGachaData.FrameAlliases do
			if frameAllias == 1 then
				rewardKey = v37.RewardKey
			end

			rewardKeysByFrameAllias[frameAllias] = rewardKey
		end

		for i = 1, 8 do
			local child2 = wheel:FindFirstChild((tostring(i)))
			local child3 = wheel:FindFirstChild("Icons"):FindFirstChild((tostring(i)))

			if child3 then
				local ring = child3:FindFirstChild("Ring")
				rings[i] = ring
				local v42 = rewardKeysByFrameAllias[i]

				if v42 then
					local baseItem = baseItems[v42]
					local v43 = tonumber(string.match(v42, "_(%d+)"))

					if v43 then
						local v44 = v38[v43]
						baseItem = {
							ImageId = v44.Reward.Icon,
							DisplayName = v44.Reward.DisplayName,
							Chance = v44.Chance
						}
					end

					local firstReward = child3:FindFirstChild("FirstReward")
					local text = child3:FindFirstChild("Text") or child3:FindFirstChild("Ring") and child3.Ring:FindFirstChild("Text")

					if firstReward and baseItem then
						firstReward.Image = baseItem.ImageId
					end

					(child3:FindFirstChild("Chances") or child3.Ring:FindFirstChild("Chances")).Text = `{i == 1 and v41 == 0 and "0" or chances[v42] or not baseItem and "0" or baseItem.Chance or "0"}%`
					ring.Glow.Visible = false

					if text and baseItem then
						if baseItem.DisplayName then
							text.Text = baseItem.DisplayName
						else
							local credits = baseItem.SimpleReward and baseItem.SimpleReward.Credits or baseItem.RewardQuantity or 1

							if credits then
								text.Text = tostring(credits)
							end
						end
					end
				end
			end

			if not child2 or clones[i] then
				continue
			end

			local clone = script.Ball:Clone()
			clone.Visible = false
			clone.Parent = child2
			clones[i] = clone
		end
	else
		local v38 = true

		for _, v40 in ipairs(currentGachaData.PhysicalBigRewardData) do
			if playerOwnsBigReward(self.DataReplion, v40) then
				continue
			end

			v38 = false
			break
		end

		local rewardKeysByFrameAllias = {}
		local v40 = v38 and 0 or currentBucket

		for rewardKey, frameAllias in currentGachaData.FrameAlliases do
			if frameAllias == 1 then
				rewardKey = v37.RewardKey
			end

			rewardKeysByFrameAllias[frameAllias] = rewardKey
		end

		for i = 1, 8 do
			local child2 = wheel:FindFirstChild((tostring(i)))
			local child3 = wheel:FindFirstChild("Icons"):FindFirstChild((tostring(i)))

			if child3 then
				local ring = child3:FindFirstChild("Ring")
				rings[i] = ring
				local v41 = rewardKeysByFrameAllias[i]

				if v41 then
					local item = currentGachaData.Items[v41]
					local firstReward = child3:FindFirstChild("FirstReward")
					local text = child3:FindFirstChild("Text") or child3:FindFirstChild("Ring") and child3.Ring:FindFirstChild("Text")

					if firstReward and item then
						firstReward.Image = item.ImageId
					end

					(child3:FindFirstChild("Chances") or child3.Ring:FindFirstChild("Chances")).Text = `{i == 1 and v40 == 0 and "0" or chances[v41] or not item and "0" or item.Chance or "0"}%`
					ring.Glow.Visible = false

					if text and item then
						if item.DisplayName then
							text.Text = item.DisplayName
						else
							local credits = item.SimpleReward and item.SimpleReward.Credits or item.RewardQuantity or 1

							if credits then
								text.Text = tostring(credits)
							end
						end
					end
				end
			end

			if not child2 or clones[i] then
				continue
			end

			local clone = script.Ball:Clone()
			clone.Visible = false
			clone.Parent = child2
			clones[i] = clone
		end
	end
end

function GenericGachaController:IsFirstOfDaySaleEligible()
	local v37 = { "GachaData", getCurrentGachaIdentifier(self.DataReplion), "LastPurchaseTimeStamp" }
	local v38 = self.DataReplion:Get(v37)
	return workspace:GetServerTimeNow() - v38 > 86400
end

function GenericGachaController:UpdateChromeGachaRequirements()
	if not v32 then
		return
	end

	local v37 = self.DataReplion:Get({ "GachaData", getGachaIdentifier(self.DataReplion), "TotalSpins" }) or 0
	main.OpenButtons.Open1.Visible = true
	main.OpenButtons.Open10.Visible = v37 < 50
	main.OpenButtons.OpenBulk.Visible = v37 >= 50
	self:UpdateFTPSpins()
end

function GenericGachaController:AddRewardToBulkGrid(state)
	local bulkRewards2 = child:WaitForChild("BulkRewards")
	local grid = bulkRewards2:WaitForChild("BG"):WaitForChild("Grid")
	local v37 = v32 and tonumber(string.match(state.RewardKey, "_(%d+)"))

	if v37 then
		local currentGachaData = getCurrentGachaData(self.DataReplion)
		local expect = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })
		local v38 = assert(
			currentGachaData.SpecialBigRewardsData[expect],
			(`Failed to get Big Rewards for item {expect}`)
		)[v37]
		state.DisplayName = v38.Reward.DisplayName
		state.ImageId = v38.Reward.Icon
	end

	local rewardKey = state.RewardKey or "Reward"
	local displayName = state.DisplayName or rewardKey:gsub("(%u)", " %1"):gsub("^ ", "")
	local imageId = state.ImageId or "rbxassetid://000000000"
	local formatted = `{rewardKey}|{displayName}|{imageId}`

	for _, v38 in self._gridQueue do
		if v38:GetAttribute("RewardKey") ~= formatted then
			continue
		end

		local v39 = (v38:GetAttribute("RewardCount") or 1) + 1
		v38:SetAttribute("RewardCount", v39)
		v38.Label.Text = `{displayName} <font color="rgb(0, 255, 48)">x{v39}</font>`
		return
	end

	local clone = bulkRewards2:WaitForChild((state.Rarity or "Common") .. "GridRewardTemplate"):Clone()
	local vector = clone:WaitForChild("Vector")
	clone:SetAttribute("RewardKey", formatted)
	clone:SetAttribute("RewardCount", 1)
	clone.Label.Text = displayName
	vector.Image = imageId
	clone.Visible = true
	clone.Parent = grid
	table.insert(self._gridQueue, clone)
end

function GenericGachaController:ClearBulkFrame()
	for _, v37 in self._gridQueue do
		v37:Destroy()
	end

	table.clear(self._gridQueue)
end

function GenericGachaController:UpdateDiscountFrames()
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local openButtons = main:WaitForChild("OpenButtons")
	local open1 = openButtons:WaitForChild("Open1")
	local giftButton = open1:WaitForChild("GiftButton")
	local redBanner = open1:WaitForChild("RedBanner")
	local price = open1:WaitForChild("Price")
	local price2 = price:WaitForChild("Price")
	local discount = price:WaitForChild("Discount")
	local open10 = openButtons:WaitForChild("Open10")
	local redBanner2 = open10:WaitForChild("RedBanner")
	local price3 = open10:WaitForChild("Price")
	local price4 = price3:WaitForChild("Price")
	local discount2 = price3:WaitForChild("Discount")
	local isFirstOfDaySaleEligible = self:IsFirstOfDaySaleEligible()
	giftButton.Visible = not isFirstOfDaySaleEligible
	redBanner.Visible = isFirstOfDaySaleEligible
	redBanner2.Visible = true
	discount.Visible = isFirstOfDaySaleEligible
	discount.Text = " " .. currentGachaData.OneSpinPrice
	discount2.Visible = true
	discount2.Text = " " .. tostring(tonumber(currentGachaData.OneSpinPrice) * 10)

	if isFirstOfDaySaleEligible then
		v16(price2, currentGachaData.FirstOfTheDayOneSpin, "DevProduct", ":robux:%s")
	else
		v16(price2, currentGachaData.OneSpinProductID, "DevProduct", ":robux:%s")
	end

	v16(price4, currentGachaData.TenSpinsProductID, "DevProduct", ":robux:%s")
end

function GenericGachaController:UpdateGachaOdds() end

function GenericGachaController:UpdateFTPSpins()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)
	local gachaEvent = v10.GachaEvents[currentGachaIdentifier]
	local eventCurrencyPath = gachaEvent.MaxEventCurrencySpins and gachaEvent.EventCurrencySpinPrice and gachaEvent.EventCurrencyPath
	local eliminationsToGetSpin = gachaEvent.EliminationsToGetSpin
	local v37 = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "SpinsLeft" }) + v31
	local expect = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "CurrentKills" })
	local v38 = self.DataReplion:Get({ "GachaData", currentGachaIdentifier, "EliminationsSpins" }) or 0
	local visible = gachaEvent.MaxEliminationSpinPerDay - v38
	local flag3 = false

	if eventCurrencyPath then
		local v40 = self.DataReplion:Get({ "GachaData", currentGachaIdentifier, "EventCurrencySpins" }) or 0

		if v40 < gachaEvent.MaxEventCurrencySpins then
			visible = gachaEvent.MaxEventCurrencySpins - v40
			flag3 = true
		end
	end

	local spin = main:WaitForChild("Wheel"):WaitForChild("Spin")
	spin.Title.Text = `Spin ({v37})`
	local v40 = math.max(eliminationsToGetSpin - expect, 0)
	local v41 = math.abs(v40) <= 1 and "elimination" or "eliminations"
	spin.Desc1.Text = `<stroke color="rgb(0, 0, 0)" joins="round" thickness="2">Get <font color="rgb(0, 255, 48)">{v40}</font> more {v41} 💀 for a spin!</stroke>`
	local desc2 = spin.Desc2
	local text

	if flag3 then
		text = `({visible} {string.gsub(v22.SeasonData.Currency.Name, "s$", "")} Spins Left Today)`
	else
		text = `({visible} Eliminations Spins Left Today)`
	end

	desc2.Text = text

	if v32 then
		local _ = v34[self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" })]
		spin.Desc1.Visible = visible
		spin.Desc2.Visible = true
		spin.ImageColor3 = visible <= 0 and v37 <= 0 and Color3.fromRGB(75, 75, 75) or Color3.fromRGB(255, 255, 255)
	else
		spin.ImageColor3 = visible <= 0 and v37 <= 0 and Color3.fromRGB(75, 75, 75) or Color3.new(1, 1, 1)
	end

	if eventCurrencyPath and flag3 and v37 <= 0 then
		spin.Title.Currency.Visible = true
		spin.Title.Text = gachaEvent.EventCurrencySpinPrice
		spin.Desc1.Text = "Spin"
		spin.Desc1.Size = UDim2.fromScale(0.5, 0.175)
		spin.Title.Currency.Image = v22.SeasonData.Currency.Icon
	else
		spin.Title.Currency.Visible = false
		spin.Desc1.Size = UDim2.fromScale(0.5, 0.15)
	end
end

function GenericGachaController:CheckForSpinLastSpin()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local expect = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "TotalSpins" })
	local v37 = expect - (expect - expect % currentGachaData.CrateSpinRequirement)

	if currentGachaData.CrateSpinRequirement - v37 <= 10 then
		local expect2 = self.DataReplion:GetExpect({ "GachaData", currentGachaIdentifier, "LastSpunTimeStamp" })

		if expect2 then
			if os.time() - expect2 >= 90000 then
				self._urgentLastSpins = true
			else
				self._urgentLastSpins = false
			end
		end
	else
		self._urgentLastSpins = false
	end
end

function GenericGachaController:HookSpinShop()
	local currentGachaData = getCurrentGachaData(self.DataReplion)
	local spinShop = child:WaitForChild("SpinShop")
	local bottom = spinShop:WaitForChild("Bottom")
	local top = spinShop:WaitForChild("Top")
	local _250 = bottom:WaitForChild("250")
	local spin = _250:WaitForChild("Spin")
	local gift = _250:WaitForChild("Gift")
	local _50 = bottom:WaitForChild("50")
	local spin2 = _50:WaitForChild("Spin")
	local gift2 = _50:WaitForChild("Gift")
	local _10 = top:WaitForChild("10")
	local spin3 = _10:WaitForChild("Spin")
	local gift3 = _10:WaitForChild("Gift")
	local _1 = top:WaitForChild("1")
	local spin4 = _1:WaitForChild("Spin")
	local gift4 = _1:WaitForChild("Gift")
	spinShop:WaitForChild("Close").MouseButton1Click:Connect(function()
		spinShop.Visible = false
	end)
	local gachaIdentifier = getGachaIdentifier(self.DataReplion)

	if v33 then
		_250.Visible = false
	else
		spin.Label:SetAttribute("ProductId", currentGachaData.TwoHundredFiftySpinsProductID or 0)
		spin.MouseButton1Click:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() then
				return
			end

			self:ClearBulkFrame()
			v21:PromptPurchase(currentGachaData.TwoHundredFiftySpinsProductID, Enum.InfoType.Product)
		end)
	end

	spin2.Label:SetAttribute("ProductId", currentGachaData.FiftySpinsProductID or 0)
	spin2.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		self:ClearBulkFrame()
		v21:PromptPurchase(currentGachaData.FiftySpinsProductID, Enum.InfoType.Product)
	end)
	spin3.Label:SetAttribute("ProductId", currentGachaData.TenSpinsProductID or 0)
	spin3.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		self:ClearBulkFrame()
		v21:PromptPurchase(currentGachaData.TenSpinsProductID, Enum.InfoType.Product)
	end)
	spin4.Label:SetAttribute("ProductId", currentGachaData.OneSpinProductID or 0)
	spin4.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		self:ClearBulkFrame()
		v21:PromptPurchase(currentGachaData.OneSpinProductID, Enum.InfoType.Product)
	end)
	gift.MouseButton1Click:Connect(function()
		v12:SetGift((`GiftTwoHundredFifty{gachaIdentifier}`))
	end)
	gift2.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		v12:SetGift((`GiftFifty{gachaIdentifier}`))
	end)
	gift3.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		v12:SetGift((`GiftTen{gachaIdentifier}`))
	end)
	gift4.MouseButton1Click:Connect(function()
		-- equivalent call inferred; original call site unknown
		if policyDisabled() then
			return
		end

		v12:SetGift((`GiftOne{gachaIdentifier}`))
	end)
end

function GenericGachaController:RegisterMultiGachaButtons() end

function GenericGachaController:Hook()
	if v35.Hook.All then
		return
	end

	v35.Hook.All = true
	local closeButton = nil
	local openButtons = nil
	local open10 = nil
	local open1 = nil
	local header = nil
	local timer = nil
	local icon = nil
	local giftButton = nil
	local giftButton2 = nil
	local giftButton3 = nil
	local skipAnimation = nil
	local checkbox = nil
	local toggleImage = nil
	local bulkRewards2 = nil
	local BG = nil
	local options = nil
	local done = nil
	local oneSpin = nil
	local tenSpins = nil
	local openBulk = nil
	local spinShop = nil

	local function RECONCILE_BUTTONS()
		local gachaIdentifier = getGachaIdentifier(self.DataReplion)

		if v35.Hook[gachaIdentifier] then
			return
		end

		v35.Hook[gachaIdentifier] = true
		self:RegisterMultiGachaButtons()
		self:UpdatePittyFrame()
		self:CheckForSpinLastSpin()
		self:TrackChanges()
		self:UpdateFTPSpins()
		main:WaitForChild("Wheel"):WaitForChild("Spin").Activated:Connect(function()
			if flag2 then
				return
			end

			flag2 = true
			task.delay(1, function()
				flag2 = false
			end)
			local _ = self.DataReplion:GetExpect({ "GachaData", getGachaIdentifier(self.DataReplion), "SpinsLeft" }) + v31
			v27:InvokeServer()
		end)
		closeButton.Activated:Connect(function()
			v9:Close(child.Name, true)
		end)

		if openBulk then
			local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)

			local function shouldShowBulk()
				local v37 = self.DataReplion:Get({ "GachaData", currentGachaIdentifier, "TotalSpins" }) or 0
				openBulk.Visible = v37 >= 50
				open10.Visible = v37 < 50
			end

			openBulk.Activated:Connect(function()
				-- equivalent call inferred; original call site unknown
				if policyDisabled() then
					return
				end

				spinShop.Visible = true
			end)
			giftButton3.Activated:Connect(function()
				-- equivalent call inferred; original call site unknown
				if policyDisabled() then
					return
				end

				spinShop.Visible = true
			end)
			task.defer(shouldShowBulk)
			self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "TotalSpins" }, shouldShowBulk)
		end

		local flag3 = false
		open10.Activated:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() or flag3 then
				return
			end

			flag3 = true
			self:ClearBulkFrame()
			v21:PromptPurchase(getCurrentGachaData(self.DataReplion).TenSpinsProductID, Enum.InfoType.Product)
			task.delay(3, function()
				flag3 = false
			end)
		end)
		giftButton.Activated:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() then
				return
			end

			v12:SetGift((`GiftTen{getGachaIdentifier(self.DataReplion)}`))
		end)
		giftButton2.MouseButton1Click:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() then
				return
			end

			v12:SetGift((`GiftOne{getGachaIdentifier(self.DataReplion)}`))
		end)
		checkbox.Activated:Connect(function()
			self:SetDisableWheel(not toggleImage.Visible)
			v25:FireServer()
		end)
		open1.Activated:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() then
				return
			end

			local currentGachaData = getCurrentGachaData(self.DataReplion)

			if self:IsFirstOfDaySaleEligible() then
				v21:PromptPurchase(currentGachaData.FirstOfTheDayOneSpin, Enum.InfoType.Product)
			else
				v21:PromptPurchase(currentGachaData.OneSpinProductID, Enum.InfoType.Product)
			end
		end)
		icon.Activated:Connect(function()
			self:ToggleChances()
		end)
		tenSpins.Activated:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() or flag3 then
				return
			end

			flag3 = true
			self:ClearBulkFrame()
			task.delay(3, function()
				flag3 = false
			end)
			v21:PromptPurchase(getCurrentGachaData(self.DataReplion).TenSpinsProductID, Enum.InfoType.Product)
		end)
		remoteEvent2.OnClientEvent:Connect(function(p)
			if #self._gridQueue == 0 then
				return
			end

			local currentGachaData = getCurrentGachaData(self.DataReplion)

			if p == currentGachaData.TenSpinsProductID or currentGachaData.GiftTenSpinsProductID and p == currentGachaData.GiftTenSpinsProductID then
				self:ClearBulkFrame()
			end
		end)
		oneSpin.Activated:Connect(function()
			-- equivalent call inferred; original call site unknown
			if policyDisabled() or flag2 then
				return
			end

			flag2 = true
			task.delay(1, function()
				flag2 = false
			end)
			local v37 = { "GachaData", getCurrentGachaIdentifier(self.DataReplion), "SpinsLeft" }

			if (self.DataReplion:GetExpect(v37) or 0) > 0 then
				v27:InvokeServer()
				return
			end

			v21:PromptPurchase(getCurrentGachaData(self.DataReplion).OneSpinProductID, Enum.InfoType.Product)
		end)
		done.Activated:Connect(function()
			self:ClearBulkFrame()
			bulkRewards2.Visible = false
			main.Visible = true
		end)
		Players.LocalPlayer.CharacterAdded:Connect(function(character)
			local ancestryChangedConnection = character.AncestryChanged:Connect(function(_, parent)
				if parent == workspace.Alive then
					v9:Close(gui, true)
				end
			end)
			character.Destroying:Once(function()
				ancestryChangedConnection:Disconnect()
				ancestryChangedConnection = nil
			end)
		end)
		local leftSide = main:WaitForChild("LeftSide")
		local gachaEvent = v10.GachaEvents[gachaIdentifier]

		if v32 then
			local function updateChromeTheme()
				self:UpdateChromeGachaRequirements()
				local expect = self.DataReplion:GetExpect({
					"GachaData",
					getGachaIdentifier(self.DataReplion),
					"SelectedItem"
				})
				local v37 = v34[expect]
				main.Countries.CountryChosen.Subheader.Text = `SELECTED: {string.upper(expect)}`
				local color = v37.color
				local v38 = typeof(color) == "ColorSequence"

				for _, guiObject in CollectionService:GetTagged("SoccarColor") do
					local uIGradient = guiObject:FindFirstChildWhichIsA("UIGradient")
					local attribute = guiObject:GetAttribute((`{expect}Offset`)) or v37.offset
					local attribute2 = guiObject:GetAttribute((`{expect}Rotation`)) or v37.rotation

					if uIGradient then
						local color2

						if v38 then
							color2 = color
						else
							color2 = ColorSequence.new(color)
						end

						uIGradient.Color = color2
						uIGradient.Offset = attribute or Vector2.zero
						uIGradient.Rotation = attribute2 or 0
					end

					if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
						local imageColor

						if v38 or uIGradient then
							imageColor = Color3.fromRGB(255, 255, 255)
						else
							imageColor = color
						end

						guiObject.ImageColor3 = imageColor
					elseif guiObject:IsA("TextLabel") then
						local textColor

						if v38 or uIGradient then
							textColor = Color3.fromRGB(255, 255, 255)
						else
							textColor = color
						end

						guiObject.TextColor3 = textColor
					end
				end
			end

			self.DataReplion:OnChange(
				{ "GachaData", getGachaIdentifier(self.DataReplion), "SelectedItem" },
				updateChromeTheme
			)
			self.DataReplion:OnDescendantChange({ "GachaData", getGachaIdentifier(self.DataReplion) }, function()
				self:UpdateChromeGachaRequirements()
			end)
			task.spawn(updateChromeTheme)

			for _, button in main.Countries.CountryButtons:GetChildren() do
				if not button:IsA("GuiButton") then
					continue
				end

				local v37 = button
				button.Activated:Connect(function()
					if next(v30) or flag then
						ReplicatedStorage2.Misc.error:Play()
					elseif v2:Invoke("GenericGacha/SetItem", v37.Name) then
						fn()
					else
						ReplicatedStorage2.Misc.error:Play()
					end
				end)
			end

			for _, child2 in leftSide:GetChildren() do
				local tryButton = child2:FindFirstChild("TryButton")

				if not tryButton then
					continue
				end

				local v37 = tonumber(string.match(child2.Name, "(%d+)Reward"))

				if not v37 then
					continue
				end

				tryButton.Visible = false
				local v38 = v37
				tryButton.Activated:Connect(function()
					local expect = self.DataReplion:GetExpect({
						"GachaData",
						getGachaIdentifier(self.DataReplion),
						"SelectedItem"
					})
					v18:Preview(assert(
						gachaEvent.SpecialBigRewardsData[expect],
						(`Failed to get Big Rewards for item {expect}`)
					)[v38].Reward.Value)

					if Players.LocalPlayer.Character and Players.LocalPlayer.Character.Parent == workspace.Dead then
						v9:Open(child.Name)
					end
				end)
			end
		else
			for _, child2 in leftSide:GetChildren() do
				if not string.match(child2.Name, "%dReward") then
					continue
				end

				local v37 = tonumber(string.match(child2.Name, "%d"))
				local item = gachaEvent.Items[gachaEvent.BigRewardData[v37]]
				local tryButton = child2:FindFirstChild("TryButton")

				if not tryButton then
					continue
				end

				tryButton.Visible = item.SimpleReward.Finisher ~= nil
				local v38 = item
				tryButton.Activated:Connect(function()
					v18:Preview(v38.SimpleReward.Finisher)

					if Players.LocalPlayer.Character and Players.LocalPlayer.Character.Parent == workspace.Dead then
						v9:Open(child.Name)
					end
				end)
			end
		end
	end

	local function RECONCILE_UI_CONFIGURATION()
		local gachaIdentifier = getGachaIdentifier(self.DataReplion)
		gui = gachaIdentifier
		child = playerGui:WaitForChild(gui)
		main = child:WaitForChild("Main")
		bulkRewards = child:WaitForChild("BulkRewards")
		megaReward = child:WaitForChild("MegaReward")
		closeButton = main:WaitForChild("CloseButton")
		openButtons = main:WaitForChild("OpenButtons")
		open10 = openButtons:WaitForChild("Open10")
		open1 = openButtons:WaitForChild("Open1")
		openBulk = openButtons:FindFirstChild("OpenBulk")
		header = main:WaitForChild("Header")
		timer = header:WaitForChild("Timer")
		icon = timer:WaitForChild("Icon")
		giftButton = open10:WaitForChild("GiftButton")
		giftButton3 = openBulk:WaitForChild("GiftButton")
		giftButton2 = open1:WaitForChild("GiftButton")
		skipAnimation = main:WaitForChild("SkipAnimation")
		checkbox = skipAnimation:WaitForChild("Checkbox")
		toggleImage = checkbox:WaitForChild("ToggleImage")
		bulkRewards2 = child:WaitForChild("BulkRewards")
		BG = bulkRewards2:WaitForChild("BG")
		options = BG:WaitForChild("Options")
		done = options:WaitForChild("Done")
		oneSpin = options:WaitForChild("OneSpin")
		tenSpins = options:WaitForChild("TenSpins")
		spinShop = child:FindFirstChild("SpinShop")
		local genericGacha = workspace:WaitForChild("Spawn"):FindFirstChild("GenericGacha")

		if genericGacha then
			genericGacha:SetAttribute("WindowName", gachaIdentifier)
		end
	end

	RECONCILE_UI_CONFIGURATION()
	RECONCILE_BUTTONS()

	fn = function()
		RECONCILE_UI_CONFIGURATION()
		RECONCILE_BUTTONS()

		if not (Players.LocalPlayer.Character and Players.LocalPlayer.Character:IsDescendantOf(workspace.Dead)) and v9:IsOpen(child.Name) then
			v9:Close(gui)
		end

		local select = main:FindFirstChild("Select")

		if select then
			select.Visible = false
			local v37 = {
				FireDragonGacha = select:FindFirstChild("Fire"),
				IceDragonGacha = select:FindFirstChild("Frost")
			}
			local gachaIdentifier = getGachaIdentifier(self.DataReplion)

			for k, v38 in v37 do
				v38.Check.Visible = gachaIdentifier == k
			end
		end

		self:RegisterMultiGachaButtons()
		self:UpdatePittyFrame()
		self:CheckForSpinLastSpin()
		self:TrackChanges()
		self:UpdateFTPSpins()
		GenericGachaController:UpdateSciFiSpinner()
	end

	self:HookSpinShop()
	local updateQueue

	updateQueue = function()
		if flag then
			return
		end

		local v37 = v30[1]

		if not v37 then
			return
		end

		local v38, v39 = table.unpack(v37)
		flag = true
		v29 = v38

		if not v9:IsOpen(child.Name) then
			local character = Players.LocalPlayer.Character

			if character and character:IsDescendantOf(workspace.Dead) then
				v9:Open(child.Name)
			end
		end

		local currentGachaData = getCurrentGachaData(self.DataReplion)
		local count = #v39
		local disableWheelSpin = self.DataReplion.Data.GachaData.DisableWheelSpin
		local success, _ = pcall(function()
			if disableWheelSpin then
				main.Visible = false
				bulkRewards2.Visible = true

				if spinShop then
					spinShop.Visible = false
				end

				self:UpdateGachaOdds()
			end

			for k, v40 in v39 do
				local v41 = currentGachaData.FrameAlliases[v40.RewardKey] or math.random(2, 8)

				if not v41 then
					continue
				end

				if disableWheelSpin then
					self:AddRewardToBulkGrid(v40)

					if k % 25 == 0 then
						task.wait()
					end
				else
					self:UpdateGachaOdds()
					local v42 = v40
					local v43 = coroutine.running()
					GenericGachaController:DoSpinAnimation(v41, function()
						child.SpinShop.Visible = false
						GenericGachaController:ShowRewardScreen(v42)
						task.defer(function()
							v6.Thread.SafeResume(v43)
						end)
					end)
					coroutine.yield()
				end

				v40.Done = true
				v28 -= 1
				v31 -= 1

				if disableWheelSpin then
					if k == count then
						self:UpdateFTPSpins()
						self:UpdateLeftSide()
						self:UpdatePittyFrame()

						if fn then
							fn()
						end
					end
				else
					self:UpdateFTPSpins()
					self:UpdateLeftSide()
					self:UpdatePittyFrame()

					if fn then
						fn()
					end
				end
			end
		end)

		if not success then
			for _, v40 in v39 do
				v40.Done = true
			end

			self:UpdateFTPSpins()
			self:UpdateLeftSide()
			self:UpdatePittyFrame()
		end

		if v29 ~= getCurrentGachaIdentifier(self.DataReplion) then
			task.wait(3)
		end

		table.remove(v30, 1)
		flag = false
		v29 = nil

		if fn then
			fn()
		end

		task.spawn(updateQueue)
	end

	v23.OnClientEvent:Connect(function(p, list)
		v31 += #list
		self:UpdateFTPSpins()
		table.insert(v30, { p, list })
		updateQueue()
	end)
	local skipping = self.DataReplion:Get({ "GachaData", "DisableWheelSpin" })
	self._skipping = skipping
	self:SetDisableWheel(skipping)
	v7.Every(1, function()
		if not v9:IsOpen(gui) then
			return
		end

		local v38 = { "GachaData", getCurrentGachaIdentifier(self.DataReplion), "LastLoginStamp" }
		local expect = self.DataReplion:GetExpect(v38)

		if not expect then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local v39 = math.max(expect + 86400 - serverTimeNow, 0)
		child.FTPCountdown.Countdown.Text = v11:FormatTimeHHMMSS(v39)
	end)
	task.spawn(function()
		local uIGradient = main:WaitForChild("RewardPity"):WaitForChild("ProgressBarFrame"):WaitForChild("SlowFlash"):WaitForChild("UIGradient")
		local size = open10.Size
		local tween = TweenService:Create(open10, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size + UDim2.new(0, 20, 0, 20)
		})
		local tween2 = TweenService:Create(
			open10,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = size
			}
		)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = uIGradient.Transparency.Keypoints[1].Value
		local tween3 = TweenService:Create(
			numberValue,
			TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
			{
				Value = 0
			}
		)
		numberValue.Changed:Connect(function()
			uIGradient.Transparency = NumberSequence.new(numberValue.Value)
		end)

		while true do
			if self._urgentLastSpins then
				if tween.PlaybackState ~= Enum.PlaybackState.Playing then
					tween:Play()
				end

				if tween2.PlaybackState ~= Enum.PlaybackState.Playing then
					tween2:Play()
				end

				if tween3.PlaybackState ~= Enum.PlaybackState.Playing then
					tween3:Play()
				end
			else
				tween:Cancel()
				tween2:Cancel()
				tween3:Cancel()
			end

			task.wait(0.1)
		end
	end)
	task.spawn(function()
		GenericGachaController:UpdateSciFiSpinner()
		GenericGachaController:ToggleChances(false)
		self:UpdatePittyFrame()
	end)
	task.spawn(function()
		while true do
			self:UpdateDiscountFrames()
			self:UpdateCountdownFrame()
			task.wait(1)
		end
	end)
end

function GenericGachaController.CheckMysteryCrate(_, p)
	if p >= 1 then
		v15:DoSmallAnimation()
	else
		v15:StopSmallAnimation()
	end
end

function GenericGachaController:TrackChanges()
	local currentGachaIdentifier = getCurrentGachaIdentifier(self.DataReplion)

	if v35.TrackChanges[currentGachaIdentifier] then
		return
	end

	v35.TrackChanges[currentGachaIdentifier] = true
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "TotalSpins" }, function()
		self:CheckForSpinLastSpin()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "SpinsLeft" }, function(_)
		self:UpdateFTPSpins()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "RequiredKillsForFreeSpin" }, function(_)
		self:UpdateFTPSpins()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "CurrentKills" }, function(_)
		self:UpdateFTPSpins()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "CurrentKillRotation" }, function(_)
		self:UpdateFTPSpins()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "EventCurrencySpins" }, function(_)
		self:UpdateFTPSpins()
	end)
	self.DataReplion:OnChange({ "GachaData", currentGachaIdentifier, "EventCurrencySpins" }, function(_)
		self:UpdateFTPSpins()
	end)
	self:UpdateFTPSpins()
end

function GenericGachaController:Start()
	v4:WaitForData()
	v.Client:WaitReplion("Inventory")
	self.DataReplion = v.Client:WaitReplion("Data")
	policyInfo = v3:GetPolicyInfo() or v3.PolicyInfoAdded:Wait()
	v23 = v2:RemoteEvent("GenericGachaSpinStarted")
	v24 = v2:RemoteEvent("GenericGachaBigRewardNotify")
	v25 = v2:RemoteEvent("GachaDisableWheelAnimation")
	v26 = v2:RemoteFunction("GetPlayersRewardQueue")
	v27 = v2:RemoteFunction("GenericGachaFTPSpin")
	local playerGui2 = Players.LocalPlayer.PlayerGui
	local rightHUD = playerGui2:WaitForChild("RightHUD")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function enableHUD()
		rightHUD.Enabled = true
		self:ShowUI()
	end

	local function hideHUD()
		rightHUD.Enabled = false
		self:HideUI()
	end

	v9:OnGuiOpen(gui, hideHUD)
	v9:OnGuiOpen(gui, enableHUD)
	v9:OnGuiOpen(gui, function()
		local _ = getFirstTimeGacha(self.DataReplion) or false

		if not (main.Visible or bulkRewards.Visible) then
			main.Visible = true
			bulkRewards.Visible = false
		end
	end)
	v9:OnGuiClose(gui, function()
		enableHUD() -- equivalent call inferred; original call site unknown
	end)
	v24.OnClientEvent:Connect(function(p: string, p2: string)
		GenericGachaController:InsertName(p, p2)
	end)
	self:Hook()
	fn()
	v9:OnGuiOpen(gui, fn)
end

function getGachaIdentifier(_, _: boolean?)
	return name
end

function getCurrentGachaIdentifier(p, flag3: boolean?)
	return getGachaIdentifier(p, flag3)
end

function getFirstTimeGacha(_)
	return false
end

function getCurrentGachaData(p, flag3: boolean?)
	local gachaIdentifier = getGachaIdentifier(p, flag3)
	return v10.GachaEvents[gachaIdentifier]
end

return GenericGachaController