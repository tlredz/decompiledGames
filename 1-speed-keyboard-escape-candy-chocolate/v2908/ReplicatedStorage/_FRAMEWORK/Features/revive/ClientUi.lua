local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ClientState = require(ReplicatedStorage.ClientState)
local Config = require(ReplicatedStorage.Config)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Config2 = require(script.Parent.Config)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = utf8.char(57346)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.08)
local random = Random.new()
local bindTrees
local maid = nil

local function fn() end

local function findTaggedGui(playerGui, tag: string)
	local v2 = nil

	for _, guiObject in CollectionService:GetTagged(tag) do
		if not (v2 == nil and guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui)) then
			continue
		end

		v2 = guiObject
	end

	return v2
end

local ClientUi = {
	pulseBoost = function()
		fn()
	end,
	bind = function(p, callback)
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local speedGameUI = playerGui:WaitForChild("SpeedGameUI", 30)
		local taggedGui = findTaggedGui(playerGui, "ReviveV2UpsellModal")
		local reviveV2Frame = speedGameUI and speedGameUI.Frames:FindFirstChild("ReviveV2Frame")

		if taggedGui and reviveV2Frame then
			bindTrees(localPlayer, taggedGui, reviveV2Frame, p, callback)
		else
			logger:warn("ReviveV2 UI is missing under SpeedGameUI")
		end
	end
}

bindTrees = function(localPlayer, taggedGui, reviveV2Frame, data, callback)
	local Ads = require(ReplicatedStorage.Monetization.Ads)
	local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)
	local list = taggedGui.Container.ButtonsFrame.List
	local reviveOptsShort = reviveV2Frame.ReviveOptsShort
	local other = reviveOptsShort.Other
	local boost = reviveV2Frame.Boost
	local revived = reviveV2Frame.Revived
	local bootLabel = boost.BootLabel
	local size = bootLabel.Size
	local uDim = UDim2.new(size.X.Scale + 0.4, size.X.Offset, size.Y.Scale + 0.4, size.Y.Offset)
	local tween = TweenService:Create(bootLabel, tweenInfo3, {
		Size = size,
		Rotation = 0
	})
	local position = reviveOptsShort.Position
	local uDim2 = UDim2.new(position.X.Scale, position.X.Offset, -1, 0)
	local position2 = revived.Position
	local uDim3 = UDim2.new(position2.X.Scale, position2.X.Offset, -1, 0)
	taggedGui.Visible = false
	reviveOptsShort.Position = uDim2
	reviveOptsShort.Visible = false
	boost.Visible = false
	revived.Position = uDim3
	revived.Visible = false
	local count = 0
	local count2 = 0
	local v2 = 0
	local v3 = 0
	local v4 = nil
	local v5 = false
	local v6 = nil
	local v7 = false
	local v8 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flapWings(now: number)
		local rotation = math.sin(now * 3.141592653589793 * 2 * 1) * 15
		local rotation2 = math.sin((now * 3.141592653589793 * 2 + 3.141592653589793) * 1) * 15
		list.ReviveBoost.LeftWing.Rotation = rotation
		list.ReviveBoost.RightWing.Rotation = rotation2
		reviveOptsShort.ReviveBoost.LeftWing.Rotation = rotation
		reviveOptsShort.ReviveBoost.RightWing.Rotation = rotation2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fillBonus(p: number)
		local text = string.format("+%d WALKSPEED", p)
		local visible = p > 0
		list.ReviveBoost.Visible = visible
		reviveOptsShort.ReviveBoost.Visible = visible
		list.ReviveBoost.Bonus.WalkspeedLabel.Text = text
		reviveOptsShort.ReviveBoost.Bonus.WalkspeedLabel.Text = text
		boost.WalkspeedLabel.Text = text
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playerIsAlive()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			return true
		end

		return false
	end

	local function playShortMotion(flag: boolean)
		if v5 ~= flag then
			v5 = flag

			if v4 then
				v4:Cancel()
			end

			local v9

			if flag then
				v9 = tweenInfo
			else
				v9 = tweenInfo2
			end

			local position3

			if flag then
				position3 = position
			else
				position3 = uDim2
			end

			v4 = TweenService:Create(reviveOptsShort, v9, {
				Position = position3
			})
			v4:Play()
		end
	end

	local function slideShortOut(callback2, callback3)
		if v5 then
			playShortMotion(false)
			v4.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed and callback2() then
					callback3()
				end
			end)
		elseif callback2() then
			callback3()
		end
	end

	local function playRevivedMotion(flag: boolean)
		if v7 ~= flag then
			v7 = flag

			if v6 then
				v6:Cancel()
			end

			local v9

			if flag then
				v9 = tweenInfo
			else
				v9 = tweenInfo2
			end

			local position3

			if flag then
				position3 = position2
			else
				position3 = uDim3
			end

			v6 = TweenService:Create(revived, v9, {
				Position = position3
			})
			v6:Play()
		end
	end

	local function slideRevivedOut(callback2, callback3)
		if v7 then
			playRevivedMotion(false)
			v6.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed and callback2() then
					callback3()
				end
			end)
		elseif callback2() then
			callback3()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closeUpsell()
		v3 = 0

		if ClientState.ActiveModal == taggedGui then
			ClientState:CloseCurrentModal()
		else
			taggedGui.Visible = false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hideShortImmediate()
		if v4 then
			v4:Cancel()
			v4 = nil
		end

		v5 = false
		reviveOptsShort.Visible = false
		reviveOptsShort.Position = uDim2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hidePrompts()
		count += 1
		hideShortImmediate() -- equivalent call inferred; original call site unknown
		closeUpsell() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function runWhenRespawned(p: number, fn2)
		if playerIsAlive() then
			fn2()
		else
			localPlayer.CharacterAdded:Once(function()
				task.defer(function()
					if p == count then
						fn2()
					end
				end)
			end)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showUpsell(p: number)
		count += 1

		local function fn2()
			hideShortImmediate() -- equivalent call inferred; original call site unknown
			taggedGui.Container.MaxStage.Text = string.format("STAGE %d", p)
			taggedGui.Container.Timer.Text = string.format("%ds", Config2.UPSELL_SECONDS)
			v3 = os.clock() + Config2.UPSELL_SECONDS
			ClientState:ToggleModal(taggedGui)
		end

		runWhenRespawned(count, fn2) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showShort()
		count += 1
		local v9 = count

		local function fn2()
			closeUpsell() -- equivalent call inferred; original call site unknown

			if v4 then
				v4:Cancel()
				v4 = nil
			end

			v5 = false
			reviveOptsShort.Position = uDim2
			reviveOptsShort.Visible = true
			playShortMotion(true)
			task.delay(Config2.SHORT_PROMPT_SECONDS, function()
				if v9 == count then
					local function fn3()
						return v9 == count
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function fn4()
						reviveOptsShort.Visible = false
					end

					if v5 then
						playShortMotion(false)
						v4.Completed:Once(function(p)
							if p == Enum.PlaybackState.Completed and fn3() then
								fn4()
							end
						end)
					elseif v9 == count then
						fn4() -- equivalent call inferred; original call site unknown
					end
				end
			end)
		end

		runWhenRespawned(v9, fn2) -- equivalent call inferred; original call site unknown
	end

	local function showRevived(p: number)
		revived.Title.Text = string.format("REVIVED at Stage %d!!", p)
		count2 += 1
		local v9 = count2

		if v6 then
			v6:Cancel()
			v6 = nil
		end

		v7 = false
		revived.Position = uDim3
		revived.Visible = true
		playRevivedMotion(true)
		task.delay(Config2.REVIVED_SECONDS, function()
			if v9 == count2 then
				local function fn2()
					return v9 == count2
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function fn3()
					revived.Visible = false
				end

				if v7 then
					playRevivedMotion(false)
					v6.Completed:Once(function(p2)
						if p2 == Enum.PlaybackState.Completed and fn2() then
							fn3()
						end
					end)
				elseif v9 == count2 then
					fn3() -- equivalent call inferred; original call site unknown
				end
			end
		end)
	end

	local function currentEndsAt()
		local attribute = localPlayer:GetAttribute(Config2.BONUS_ENDS_ATTRIBUTE)
		local v9 = nil

		if type(attribute) == "number" then
			return attribute
		end

		if v2 > 0 then
			return v2
		end

		return v9
	end

	local function updateBoostTimer()
		local attribute = localPlayer:GetAttribute(Config2.BONUS_ENDS_ATTRIBUTE)
		local v9 = nil

		if type(attribute) == "number" then
			v9 = attribute
		elseif v2 > 0 then
			v9 = v2
		end

		if boost.Visible and v9 then
			local v10 = v9 - workspace:GetServerTimeNow()

			if v10 > 0 then
				local v11 = math.ceil(v10)
				boost.Timer.Timer.Text = string.format("%d:%02d", math.floor(v11 / 60), v11 % 60)
			else
				boost.Visible = false
				v2 = 0
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateUpsellTimer()
		if v3 > 0 then
			local v9 = v3 - os.clock()

			if v9 > 0 then
				taggedGui.Container.Timer.Text = string.format("%ds", (math.ceil(v9)))
				return
			end

			closeUpsell() -- equivalent call inferred; original call site unknown
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshAds()
		list.ReviveAds.Visible = false
		other.ReviveAds.Visible = false
		task.spawn(function()
			local visible = Ads.checkForAds()
			list.ReviveAds.Visible = visible
			other.ReviveAds.Visible = visible
		end)
	end

	local function weldSpeedVisual(folder, humanoidRootPart)
		if folder:IsA("BasePart") then
			folder.Anchored = false
			folder.CanCollide = false
			folder.Massless = true
			folder.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = humanoidRootPart
			weldConstraint.Part1 = folder
			weldConstraint.Parent = folder
		elseif folder:IsA("Model") then
			folder:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0))
			local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart", true)

			if primaryPart then
				for _, part in folder:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Anchored = false
					part.CanCollide = false
					part.Massless = true
				end

				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = humanoidRootPart
				weldConstraint.Part1 = primaryPart
				weldConstraint.Parent = primaryPart
			end
		end
	end

	local function playSpeedBoostEffect()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if character and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local speedIncrease = assets and assets:FindFirstChild("SpeedIncrease")

			if speedIncrease then
				local clone = speedIncrease:Clone()

				for _, billboardGui in clone:GetDescendants() do
					if billboardGui:IsA("BillboardGui") then
						billboardGui.ClipsDescendants = false
					end
				end

				clone.Parent = character
				weldSpeedVisual(clone, humanoidRootPart)

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter.Rate)
					end
				end

				Debris:AddItem(clone, 10)
			end

			if not (v8 and v8.Parent) then
				local sound = Instance.new("Sound")
				sound.Name = "Stage15SpeedBoost"
				sound.SoundId = "rbxassetid://127199850989931"
				sound.Looped = false
				sound.Volume = 1
				sound.Parent = SoundService
				v8 = sound
			end

			v8.TimePosition = 0
			v8:Play()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playBuySound()
		local BUY = Config.SOUNDS.BUY
		local sound = Instance.new("Sound")
		sound.SoundId = BUY.ID
		sound.Volume = BUY.Volume
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 5)
	end

	local function onRevive()
		data.requestRevive:fire()
	end

	local function onAd()
		data.requestAd:fire()
	end

	local function onBoost()
		data.requestBoost:fire()
	end

	local function onPresent(p: string, p2: number, _: number, p3: number)
		fillBonus(p3) -- equivalent call inferred; original call site unknown
		refreshAds() -- equivalent call inferred; original call site unknown

		if p == "upsell" then
			showUpsell(p2) -- equivalent call inferred; original call site unknown
		else
			showShort() -- equivalent call inferred; original call site unknown
		end
	end

	local function onRevived(p: number, p2: number, p3: number)
		hidePrompts() -- equivalent call inferred; original call site unknown
		showRevived(p)
		playBuySound() -- equivalent call inferred; original call site unknown

		if p2 > 0 then
			fillBonus(p2) -- equivalent call inferred; original call site unknown
			v2 = p3
			boost.Visible = true
			updateBoostTimer()
			playSpeedBoostEffect()
		end

		callback()
	end

	local function onPurchaseFinished(p: number, p2: number, flag: boolean)
		if p == localPlayer.UserId and not flag and (p2 == Config.DEV_PRODUCTS.REVIVE or p2 == Config.DEV_PRODUCTS.REVIVE_WALKSPEED) then
			hidePrompts() -- equivalent call inferred; original call site unknown
		end
	end

	local function onBonusAttribute()
		callback()
		updateBoostTimer()
	end

	local function applyPrice(p: number, callback2)
		if p ~= 0 then
			task.spawn(function()
				MarketplaceInfoCache.Request(p, Enum.InfoType.Product, function(p2)
					if type(p2) == "table" and type(p2.PriceInRobux) == "number" then
						callback2(p2.PriceInRobux)
					end
				end)
			end)
		end
	end

	local REVIVE = Config.DEV_PRODUCTS.REVIVE

	local function fn2(priceInRobux: number)
		local text = string.format("REVIVE for %d%s", priceInRobux, v)
		list.Revive.Title.Text = text
		other.Revive.Title.Text = text
	end

	if REVIVE ~= 0 then
		task.spawn(function()
			MarketplaceInfoCache.Request(REVIVE, Enum.InfoType.Product, function(p)
				if type(p) == "table" and type(p.PriceInRobux) == "number" then
					fn2(p.PriceInRobux)
				end
			end)
		end)
	end

	local REVIVE_WALKSPEED = Config.DEV_PRODUCTS.REVIVE_WALKSPEED

	local function fn3(priceInRobux: number)
		local text = string.format("REVIVE + BOOST %d%s", priceInRobux, v)
		local text2 = string.format("ONLY %d%s!", priceInRobux, v)
		list.ReviveBoost.Title.Text = text
		reviveOptsShort.ReviveBoost.Title.Text = text
		list.ReviveBoost.Pricetag.Title.Text = text2
		reviveOptsShort.ReviveBoost.Pricetag.Title.Text = text2
	end

	if REVIVE_WALKSPEED ~= 0 then
		task.spawn(function()
			MarketplaceInfoCache.Request(REVIVE_WALKSPEED, Enum.InfoType.Product, function(p)
				if type(p) == "table" and type(p.PriceInRobux) == "number" then
					fn3(p.PriceInRobux)
				end
			end)
		end)
	end

	maid = Janitor.new()
	maid:Add(data.present:connect(onPresent))
	maid:Add(data.revived:connect(onRevived))
	maid:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(onPurchaseFinished))
	maid:Add(localPlayer:GetAttributeChangedSignal(Config2.BONUS_ATTRIBUTE):Connect(onBonusAttribute))
	maid:Add(localPlayer:GetAttributeChangedSignal(Config2.BONUS_ENDS_ATTRIBUTE):Connect(onBonusAttribute))
	maid:Add(RunService.Heartbeat:Connect(function()
		flapWings(os.clock()) -- equivalent call inferred; original call site unknown
		updateBoostTimer()
		updateUpsellTimer() -- equivalent call inferred; original call site unknown
	end))
	maid:Add(function()
		if v4 then
			v4:Cancel()
		end

		if v6 then
			v6:Cancel()
		end
	end)
	maid:Add(list.Revive.MouseButton1Click:Connect(onRevive))
	maid:Add(list.ReviveAds.MouseButton1Click:Connect(onAd))
	maid:Add(list.ReviveBoost.MouseButton1Click:Connect(onBoost))
	maid:Add(other.Revive.MouseButton1Click:Connect(onRevive))
	maid:Add(other.ReviveAds.MouseButton1Click:Connect(onAd))
	maid:Add(reviveOptsShort.ReviveBoost.MouseButton1Click:Connect(onBoost))
	maid:Add(taggedGui.Container.SkipRevive.MouseButton1Click:Connect(hidePrompts))

	fn = function()
		tween:Cancel()
		bootLabel.Size = uDim
		bootLabel.Rotation = random:NextNumber(-15, 15)
		tween:Play()
	end
end

return ClientUi