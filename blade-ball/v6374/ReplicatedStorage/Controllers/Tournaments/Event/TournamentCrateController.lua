local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
require3(ReplicatedStorage2.Controllers.NotificationController)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventCrate)
local v6 = require3(ReplicatedStorage2.Controllers.StPatricksDayEventController)
local v7 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v8 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v9 = require3(ReplicatedStorage2.Shared.Policy)
local v10 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v11 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Common.RewardInfo)
local tournamentEvent = Players.LocalPlayer.PlayerGui:WaitForChild("TournamentEvent")
local eventCrate = tournamentEvent.MainFrame.Frame.Views.EventCrate
local container = eventCrate.Container
local _7 = container["7"]
local v12 = nil
local remoteEvent = v:RemoteEvent("ProcessTournamentEventRoll")
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear)
local random = Random.new()

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

local TournamentCrateController = {}
TournamentCrateController.Spinning = false
TournamentCrateController.SpinQueue = {}

function TournamentCrateController:Start()
	local v13 = v2.Client:WaitReplion("LimitedStockItems")
	local item = v5.Items[7]
	local v14 = v13:Get({ "InitialStock", item.Reward.Value }) or 0
	local position = _7.Percent.Position
	local v15 = false

	local function updateBigReward()
		if not v13:Get({ "Loaded" }) then
			_7.Claimed.Text = "LOADING..."
			return
		end

		local v16 = v13:Get({ "Stock", item.Reward.Value }) or 0
		local v17 = math.clamp(math.ceil(v16), 0, v14)
		local v18 = v2.Client:WaitReplion("Data")
		local v19

		if item.Replacement then
			v19 = v16 <= 0 or v18:Get("ReceivedTournamentEventFFAOrbitSpear") == true
		else
			v19 = false
		end

		local replacement

		if v19 then
			replacement = item.Replacement
		else
			replacement = item.Reward
		end

		if v19 ~= v15 then
			v15 = v19
			v10:Remove(_7)
			v10:AddFromRewardInfo(_7, replacement)
		end

		_7.Inspect.Visible = v11:CanPreview(replacement)
		_7.NameLabel.Text = replacement.DisplayName
		_7.Icon.Image = replacement.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")

		if v15 then
			_7.Claimed.Visible = false
			_7.Percent.Position = _7.Claimed.Position
		else
			_7.Claimed.Visible = true
			_7.Claimed.Text = `{v3.ValueConvertor:AddCommas(v17)}/{v3.ValueConvertor:ShrinkNumber(v14)} LEFT`
			_7.Percent.Position = position
		end
	end

	v10:AddFromRewardInfo(_7, item.Reward)
	_7.Inspect.Visible = v11:CanPreview(item.Reward)
	_7.Inspect.Activated:Connect(function()
		local v17

		if v15 then
			v17 = item.Replacement
		else
			v17 = item.Reward
		end

		v11:PreviewReward(v17)
	end)
	eventCrate.ViewOdds.Activated:Connect(function()
		for _, child in container:GetChildren() do
			child.Percent.Visible = not child.Percent.Visible
		end
	end)
	eventCrate.Buttons.Spin.Activated:Connect(function()
		remoteEvent:FireServer()
	end)
	v8(eventCrate.Buttons.Robux.Robux, 1916255924, "DevProduct", "%s")
	eventCrate.Buttons.Robux.Activated:Connect(function()
		v4:PromptPurchase(1916255924, Enum.InfoType.Product)
	end)
	task.spawn(function()
		local policyInfo = v9:GetPolicyInfo()

		if policyInfo and policyInfo.ArePaidRandomItemsRestricted then
			eventCrate.Buttons.Robux.Visible = false
		end
	end)
	remoteEvent.OnClientEvent:Connect(function(list)
		local fastSpin = #list > 1

		for _, v17 in list do
			table.insert(self.SpinQueue, {
				Index = v17.Index,
				FastSpin = fastSpin
			})
		end
	end)

	for k, item2 in v5.Items do
		local v16 = container[k]

		if item2.Replacement then
			continue
		end

		v16.NameLabel.Text = item2.Reward.DisplayName
		v16.Icon.Image = item2.Reward.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
		v10:AddFromRewardInfo(v16, item2.Reward)
		v16.Inspect.Visible = v11:CanPreview(item2.Reward)
		local v17 = item2
		v16.Inspect.Activated:Connect(function()
			v11:PreviewReward(v17.Reward)
		end)
	end

	v13:OnChange({ "Stock", item.Reward.Value }, updateBigReward)
	v13:OnChange({ "Loaded" }, updateBigReward)
	updateBigReward()
	local v16 = nil

	local function updateChances()
		local v17 = {}

		for _, item2 in v5.Items do
			v17[item2] = item2.Chance
		end

		local instantFFlag = v3.FFlag.GetInstantFFlag("TournamentEventGrandPrizeChance", 0.25)
		v17[v5.Items[7]] = instantFFlag
		local weights = v7.getWeights(v17, v16 and 1 or 0, 0.05)
		local v18 = {}

		for k, relativeWeight in weights.relativeWeights do
			v18[weights.options[k]] = math.round(relativeWeight * 100 * 100) / 100
		end

		for k, v19 in v18 do
			local findFirstChild = container:FindFirstChild(table.find(v5.Items, k))
			findFirstChild.Percent.Text = `{v19}%`
		end
	end

	updateChances()
	v3.FFlag.OnChange(updateChances)
	v3.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local visible = v3.FFlag.GetInstantFFlag("TournamentEventLuckStartTime", 0) <= serverTimeNow and serverTimeNow < v3.FFlag.GetInstantFFlag(
			"TournamentEventLuckEndTime",
			0
		) or v6:HasLuck()

		if visible ~= v16 then
			tournamentEvent.MainFrame.Frame.LeftButtons.EventCrate.Clover.Visible = visible
			v16 = visible
			updateChances()
		end

		if #self.SpinQueue == 0 or self.Spinning == true then
			return
		end

		local v18 = table.remove(self.SpinQueue)

		if not v18 then
			return
		end

		self:DoSpinAnimation(v18.Index, v18.FastSpin)
	end)
end

function TournamentCrateController:DoSpinAnimation(p: number, flag: boolean?)
	local v13 = 7 * random:NextInteger(9, 11) + p - 1
	local total = 0.02
	self.Spinning = true

	local function endAnimation()
		local clone = ReplicatedStorage2.Misc.reward:Clone()
		clone.Volume = 0.34
		clone.Parent = script
		clone:Play()
		local clone2 = container[v12]:Clone()
		clone2.Name = "clone"
		clone2:ClearAllChildren()
		clone2.Parent = container
		local tween = TweenService:Create(clone2, tweenInfo, {
			Size = clone2.Size + UDim2.fromScale(0.15, 0.15),
			ImageTransparency = 1
		})
		tween:Play()
		tween.Completed:Once(function()
			clone2:Destroy()
			tween:Destroy()
			container[v12].Glow.Visible = false
			self.Spinning = false
		end)
	end

	if flag then
		v12 = nil
		self:DoItemGlow(p)
		task.wait(0.1)
	else
		for i = 1, v13 do
			self:DoItemGlow(i % 7 + 1)
			task.wait(total)
			total += v13 - i < 20 and 0.015 or 0
		end
	end

	v12 = p
	endAnimation()
end

function TournamentCrateController:DoItemGlow(p: number)
	container[p].Glow.Visible = true
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6895079853"
	sound.Parent = SoundService
	sound.Volume = 0.2
	sound.PlaybackSpeed = 1.2
	sound.TimePosition = 0
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)

	if v12 then
		container[v12].Glow.Visible = false
	end

	v12 = p
end

return TournamentCrateController