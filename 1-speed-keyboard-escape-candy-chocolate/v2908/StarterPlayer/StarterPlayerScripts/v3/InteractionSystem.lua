local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local GiftUISystem = require(ReplicatedStorage:WaitForChild("GiftUISystem"))
local localPlayer = Players.LocalPlayer
local equipStepAward = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipStepAward")
local currentGameplayConfigs = ReplicatedStorage:WaitForChild("CurrentGameplayConfigs")
local v = false
local v2 = {}
local v3 = {}
local flag = false
local v4 = nil
local flag2 = false

local function connectStepAward(instance)
	if v2[instance] then
		return
	end

	local awardID = instance:GetAttribute("AwardID")
	local v5 = Config.STEP_AWARDS[awardID]

	if v5 then
		v2[instance] = true
		v3[instance] = v5
		task.defer(function()
			if _G.RefreshAwardVisuals then
				_G.RefreshAwardVisuals()
			end
		end)
		instance.Touched:Connect(function(otherPart)
			local character = localPlayer.Character

			if character and otherPart:IsDescendantOf(character) and not v then
				v = true
				local v6 = ClientState:Get()
				local wins = v6.Wins or 0
				local stepBonus = v6.StepBonus or 1
				local reqWins = tonumber(v5.ReqWins) or 0

				if reqWins <= wins then
					if stepBonus ~= v5.Bonus then
						equipStepAward:FireServer(awardID)
						NotificationSystem:ShowMessage(
							"EQUIPPED! +" .. Numbers.formatNumber(v5.Bonus) .. "/step",
							Color3.fromRGB(0, 255, 100)
						)
						ClientState:Update({
							StepBonus = v5.Bonus
						})
						_G.RefreshAwardVisuals()
					end
				else
					NotificationSystem:ShowMessage(
						"Need " .. Numbers.formatNumber(reqWins) .. " Wins!",
						Color3.fromRGB(255, 100, 100)
					)
				end

				task.delay(0.5, function()
					v = false
				end)
			end
		end)
	end
end

local function startStepAwards()
	if flag then
		return
	end

	flag = true

	for _, v5 in ipairs(CollectionService:GetTagged("StepAward")) do
		connectStepAward(v5)
	end

	if _G.RefreshAwardVisuals then
		_G.RefreshAwardVisuals()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function waitForStepAwardsReady()
	if currentGameplayConfigs:GetAttribute("StepAwardsReady") then
		return
	end

	currentGameplayConfigs:GetAttributeChangedSignal("StepAwardsReady"):Wait()
end

local function getGiftModal()
	if v4 then
		return v4
	end

	local tagged = CollectionService:GetTagged("GiftModal")

	for _, v5 in ipairs(tagged) do
		if not v5:IsDescendantOf(localPlayer:WaitForChild("PlayerGui")) then
			continue
		end

		v4 = v5
		return v5
	end

	return nil
end

local function connectGiftChest(proximityPrompt)
	local v5 = proximityPrompt:IsA("ProximityPrompt") and proximityPrompt or proximityPrompt:FindFirstChildOfClass("ProximityPrompt")

	if not v5 then
		return
	end

	v5.Triggered:Connect(function()
		if flag2 then
			return
		end

		flag2 = true
		local giftModal = getGiftModal()

		if not giftModal then
			task.wait(0.2)
			giftModal = getGiftModal()
		end

		if giftModal then
			GiftUISystem:InitLogic()
			ClientState:ToggleModal(giftModal, GiftUISystem)
		else
			warn("⚠️ Problème : GiftModal introuvable dans PlayerGui")
		end

		task.delay(0.5, function()
			flag2 = false
		end)
	end)
end

for _, v5 in ipairs(CollectionService:GetTagged("GiftChest")) do
	connectGiftChest(v5)
end

CollectionService:GetInstanceAddedSignal("GiftChest"):Connect(connectGiftChest)
CollectionService:GetInstanceAddedSignal("StepAward"):Connect(function(p)
	if flag then
		connectStepAward(p)
	end
end)
task.spawn(function()
	waitForStepAwardsReady() -- equivalent call inferred; original call site unknown
	startStepAwards()
end)

function _G.RefreshAwardVisuals()
	local v5 = ClientState:Get()
	local stepBonus = v5.StepBonus or 1
	local wins = v5.Wins or 0
	local tagged = CollectionService:GetTagged("StepAward")

	for _, v6 in ipairs(tagged) do
		local awardID = v6:GetAttribute("AwardID")
		local v7 = Config.STEP_AWARDS[awardID]

		if not v7 then
			continue
		end

		local reqWins = tonumber(v7.ReqWins) or 0

		if v7.Bonus == stepBonus then
			v6.BrickColor = Config.COLORS.AWARD_EQUIPPED
		elseif wins < reqWins then
			v6.BrickColor = Config.COLORS.AWARD_LOCKED
		else
			v6.BrickColor = Config.COLORS.AWARD_DEFAULT
		end
	end
end

task.delay(1.5, function()
	if _G.RefreshAwardVisuals then
		_G.RefreshAwardVisuals()
	end
end)