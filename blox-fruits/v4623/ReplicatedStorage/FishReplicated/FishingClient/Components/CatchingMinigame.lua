local CatchingMinigame = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	Gui = nil,
	FishFrame = nil,
	Fish = nil,
	CastStrength = 0,
	state = nil
}
CatchingMinigame.__index = CatchingMinigame
local Config = require(script.Parent.Parent.Config)
local minigame = Config.Minigame
local DialogueController = require(game.ReplicatedStorage:WaitForChild("DialogueController"))
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local fishing = IrisLog.new("Fishing")

function CatchingMinigame:Hide()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
		self.Bar = nil
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function CatchingMinigame:Show()
	self:Hide()

	if not self.Gui then
		self.Gui = script.Fishing_Reeling:Clone()
		self.__maid:GiveTask(self.Gui)
		self.MinigameFrame = self.Gui.Minigame
		self.ContainerFrame = self.MinigameFrame.Container
		self.FishFrame = self.ContainerFrame.Fish
		self.ReelZoneFrame = self.ContainerFrame.ReelZone
		self.TreasureFrame = self.ContainerFrame.Treasure
		self.ProgressBar = self.MinigameFrame.ProgressBar
		self.ProgressFill = self.ProgressBar.Bar
		self.TipFrame = self.MinigameFrame.Tip
		self.TipFrame.Visible = false
		local size = self.MinigameFrame.Size
		local uDim = UDim2.new(0, 0, size.Y.Scale, 0)
		local position = self.MinigameFrame.Position
		local uDim2 = UDim2.new(position.X.Scale + size.X.Scale / 2, 0, position.Y.Scale, 0)
		self.MinigameFrame.Size = uDim
		self.MinigameFrame.Position = uDim2
		self.FishFrame.Visible = false
		self.TreasureFrame.Visible = false
		self.Gui.Parent = game.Players.LocalPlayer.PlayerGui
		self.ProgressBar.Visible = false
		self.ReelZoneFrame.Visible = false
		local lastTime = tick()

		while true do
			local v = math.clamp((tick() - lastTime) / 0.7, 0, 1)
			local scale = uDim2.X.Scale
			local v2 = scale + (position.X.Scale - scale) * v
			local scale2 = uDim2.Y.Scale
			local uDim3 = UDim2.new(v2, 0, scale2 + (position.Y.Scale - scale2) * v, 0)
			local scale3 = uDim.X.Scale
			local v3 = scale3 + (size.X.Scale - scale3) * v
			local scale4 = uDim.Y.Scale
			local uDim4 = UDim2.new(v3, 0, scale4 + (size.Y.Scale - scale4) * v, 0)
			self.MinigameFrame.Size = uDim4
			self.MinigameFrame.Position = uDim3

			if v >= 1 then
				break
			end

			task.wait()
		end

		local transparency = self.ProgressBar.Transparency
		local backgroundTransparency = self.ProgressBar.BackgroundTransparency
		local transparency2 = self.ReelZoneFrame.Transparency
		local backgroundTransparency2 = self.ReelZoneFrame.BackgroundTransparency
		self.ProgressBar.Transparency = 1
		self.ProgressBar.BackgroundTransparency = 1
		self.ReelZoneFrame.Transparency = 1
		self.ReelZoneFrame.BackgroundTransparency = 1
		self.ProgressBar.Visible = true
		self.ReelZoneFrame.Visible = true
		local size2 = self.ReelZoneFrame.Size
		local JobsReplicated = require(game.ReplicatedStorage.JobsReplicated)
		local jobStatAlpha = JobsReplicated.GetJobStatAlpha("Fishing", "Control")
		local v = size2.X.Scale * (0.5 + jobStatAlpha)
		self.ReelZoneFrame.Size = UDim2.new(v, size2.X.Offset, size2.Y.Scale, size2.Y.Offset)
		local lastTime2 = tick()

		while true do
			local v2 = math.clamp((tick() - lastTime2) / 0.4, 0, 1)
			local v3 = self.__state.Controller:IsReeling() and 1 or v2
			self.ProgressBar.Transparency = 1 + (transparency - 1) * v3
			self.ProgressBar.BackgroundTransparency = 1 + (backgroundTransparency - 1) * v3
			self.ReelZoneFrame.Transparency = 1 + (transparency2 - 1) * v3
			self.ReelZoneFrame.BackgroundTransparency = 1 + (backgroundTransparency2 - 1) * v3

			if v3 >= 1 then
				break
			end

			task.wait()
		end

		self.FishFrame.Position = UDim2.new(self.__state.fishPos, 0, 0.5, 0)
		self:ShowFish()
		local v2 = tick() + 1

		while tick() < v2 and not self.__state.Controller:IsReeling() do
			task.wait()
		end

		self.FinallyPlaying = true
	end
end

function CatchingMinigame:ShowFish()
	self.FishFrame.Visible = true
end

function CatchingMinigame:ShowTreasure()
	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGamePrint("ShowTreasure")
	self.TreasureFrame.Visible = true
	self.__components:Get("Sounds"):PlayRandom("TreasureChestAppears")
end

function CatchingMinigame:ChestAcquired()
	local treasureFrame = self.TreasureFrame
	local bobber = self.__components:Get("Bobber")
	task.spawn(function()
		local openedIcon = self.TreasureFrame.OpenedIcon
		local unopenedIcon = self.TreasureFrame.UnopenedIcon

		for _ = 1, 3 do
			for i = 0, 2 do
				unopenedIcon.Position = UDim2.new(i / 50 + 0.475, 0, 0.5, 0)
				task.wait()
			end

			for i = 2, 0, -1 do
				unopenedIcon.Position = UDim2.new(i / 50 + 0.475, 0, 0.5, 0)
				task.wait()
			end

			for i = 0, -2, -1 do
				unopenedIcon.Position = UDim2.new(i / 50 + 0.475, 0, 0.5, 0)
				task.wait()
			end

			for i = -2, 0 do
				unopenedIcon.Position = UDim2.new(i / 50 + 0.475, 0, 0.5, 0)
				task.wait()
			end

			unopenedIcon.Position = UDim2.new(0.475, 0, 0.5, 0)
			task.wait()

			if not treasureFrame.Parent then
				return
			end
		end

		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
		local color = treasureFrame.UIStroke.Color
		local backgroundColor3 = treasureFrame.BackgroundColor3
		local TweenService = game:GetService("TweenService")
		TweenService:Create(treasureFrame.UIStroke, tweenInfo, {
			Color = Color3.new(1, 1, 1)
		}):Play()
		local TweenService2 = game:GetService("TweenService")
		local tween = TweenService2:Create(treasureFrame, tweenInfo, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.1)

		if not treasureFrame.Parent then
			return
		end

		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(treasureFrame.UIStroke, tweenInfo, {
			Color = color
		}):Play()
		local TweenService4 = game:GetService("TweenService")
		local tween2 = TweenService4:Create(treasureFrame, tweenInfo, {
			BackgroundColor3 = backgroundColor3,
			BackgroundTransparency = 0.5
		})
		tween2:Play()
		tween2.Completed:Wait()
		unopenedIcon.Visible = false
		openedIcon.Visible = true
		bobber:PlayChestBobberVFX()
		task.wait(0.25)

		if not treasureFrame.Parent then
			return
		end

		openedIcon.Visible = false
		treasureFrame.Visible = false
	end)
end

function CatchingMinigame:AnimateFish(p, p2)
	local v = p2 * 60
	local icon = self.FishFrame.Icon

	if not self.lastFishUpdate then
		self.lastFishUpdate = tick()
	end

	local _ = self.lastFishUpdate

	if not self.fishAnimDirection then
		self.fishAnimDirection = 1
	end

	if p then
		if icon.Rotation == 15 then
			self.fishAnimDirection = -1
		elseif icon.Rotation == -15 then
			self.fishAnimDirection = 1
		end

		icon.Rotation = math.clamp(icon.Rotation + 5 * self.fishAnimDirection * v, -15, 15)
	elseif icon.Rotation > 0 then
		icon.Rotation = math.max(icon.Rotation + -5 * v, 0)
	elseif icon.Rotation < 0 then
		icon.Rotation = math.min(icon.Rotation + 5 * v, 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOppositeColor(value)
	local R = value.R
	local G = value.G
	local B = value.B
	return (Color3.new(math.min(G * 1.1, 1), R * 0.7, B))
end

local color = script.Fishing_Reeling.Minigame.ProgressBar.Bar.UIGradient.Color
local v = {}

for _, keypoint in color.Keypoints do
	local time = keypoint.Time
	local value = keypoint.Value
	table.insert(v, ColorSequenceKeypoint.new(time, getOppositeColor(value)))
end

local colorSequence = ColorSequence.new(v)

function CatchingMinigame:UpdateProgressBar(p2)
	self.ProgressFill.Size = UDim2.new(p2, 0, 1, 0)

	if p2 < 0.15 then
		self.ProgressFill.UIGradient.Color = colorSequence
		return
	end

	if not (p2 < 0.23) then
		self.ProgressFill.UIGradient.Color = color
		return
	end

	local v2 = {}

	for _, keypoint in color.Keypoints do
		local time = keypoint.Time
		local value = keypoint.Value
		local value2 = keypoint.Value
		table.insert(
			v2,
			ColorSequenceKeypoint.new(time, value:Lerp(getOppositeColor(value2), (math.min((0.23 - p2) * 3, 1))))
		)
	end

	self.ProgressFill.UIGradient.Color = ColorSequence.new(v2)
end

function CatchingMinigame:SetChestOverlap(_, p2)
	local treasureFrame = self.TreasureFrame
	local _ = treasureFrame.UnopenedIcon.Size
	local _ = treasureFrame.OpenedIcon.Size
	treasureFrame.UnopenedIcon.Size = UDim2.new(
		0.7200000000000001 + 0.22499999999999998 * math.min(p2, 1),
		0,
		0.68 + 0.2124999999999999 * math.min(p2, 1),
		0
	)
	treasureFrame.OpenedIcon.Size = UDim2.new(
		0.76 + 0.3324999999999998 * math.min(p2, 1),
		0,
		0.7176 + 0.31394999999999995 * math.min(p2, 1),
		0
	)
end

function CatchingMinigame:UpdateDirectionalArrows(p2)
	local reelZoneFrame = self.ReelZoneFrame
	local leftArrow = reelZoneFrame.LeftArrow
	local rightArrow = reelZoneFrame.RightArrow

	if p2 then
		rightArrow.ImageTransparency = math.max(rightArrow.ImageTransparency - 0.2, 0.25)
		leftArrow.ImageTransparency = math.min(leftArrow.ImageTransparency + 0.2, 1)
	else
		leftArrow.ImageTransparency = math.max(leftArrow.ImageTransparency - 0.2, 0.25)
		rightArrow.ImageTransparency = math.min(rightArrow.ImageTransparency + 0.2, 1)
	end
end

TweenInfo.new(0.5, Enum.EasingStyle.Linear)
game:GetService("TweenService")

function CatchingMinigame:UpdateReelZone(p2, p3)
	self.ReelZoneFrame.Position = UDim2.new(p2, 0, 0.5, 0)

	if p3 then
		self.ReelZoneFrame.BackgroundTransparency = math.max(self.ReelZoneFrame.BackgroundTransparency - 0.1, 0.4)
		self.ReelZoneFrame.BackgroundColor3 = self.ReelZoneFrame.BackgroundColor3:Lerp(Color3.new(0, 0.776471, 0), 0.1)
	else
		self.ReelZoneFrame.BackgroundTransparency = math.min(self.ReelZoneFrame.BackgroundTransparency + 0.1, 0.75)
		self.ReelZoneFrame.BackgroundColor3 = self.ReelZoneFrame.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.1)
	end

	self.ReelZoneFrame.UIStroke.Color = self.ReelZoneFrame.BackgroundColor3
end

function CatchingMinigame:Main()
	self:Show()
	local _ = self.Fish
	local __state = self.__state
	local currentFishingRod = __state.currentFishingRod
	local scrollModifier_RodProtector = currentFishingRod:GetAttribute("ScrollModifier_RodProtector")
	local timeToMaxChaos = minigame.TimeToMaxChaos

	if currentFishingRod:GetAttribute("ScrollModifier_TerrorfishCurse") then
		timeToMaxChaos -= timeToMaxChaos * 0.2
		task.spawn(function()
			for _ = 1, 20 do
				__state.progress += 0.01
				task.wait(0.05)
			end
		end)
	end

	local __maid = self.__maid
	local icon = self.FishFrame.Icon
	__maid.Minigame = task.spawn(function()
		local fn

		fn = function(state, p)
			local maxProgress = state.MaxProgress
			local fishingRodData = currentFishingRod.FishingRodData
			local v2 = minigame.ProgressGainRate * (1 + fishingRodData.Strength.Value / 10)
			local aggressiveness = state.Aggressiveness
			local elusiveness = state.Elusiveness
			local v3 = minigame.PlayerMovementSpeed * (1 + (fishingRodData.Speed.Value - 1) / 10)
			local v4 = minigame.PlayerAcceleration * (1 + (fishingRodData.Strength.Value - 1) / 10)
			local v5 = minigame.FishAcceleration * (1 + (aggressiveness - 1) / 10)
			local v6 = minigame.FishMovementSpeed * (1 + (elusiveness - 1) / 10)
			local v7 = minigame.ProgressGainRate * (1 + (aggressiveness - 1) / 10 + (elusiveness - 1) / 10 - fishingRodData.Resilience.Value / 10)
			local bossBattle = p and p.BossBattle
			local controller = __state.Controller
			__state.nextFishTargetChange = 0
			local v8 = 1 + 0.25 * (state.Rarity - 1)
			fishing:Append(fishing:Blue("Fish: ", state.Name), "; Rarity: ", state.Rarity)
			local v9 = v6 * v8
			local v10 = v5 * v8
			local v11 = v7 * v8
			local scrollModifier_RodResilience = currentFishingRod:GetAttribute("ScrollModifier_RodResilience")

			if scrollModifier_RodResilience then
				v11 *= 1 - scrollModifier_RodResilience
			end

			local scale = self.ReelZoneFrame.Size.X.Scale
			local RunService = game:GetService("RunService")
			local renderStepped = RunService.RenderStepped
			local total = 0

			while true do
				local v12 = renderStepped:Wait()

				if currentFishingRod:GetAttribute("ActiveSkill") == "Reel Boost" then
					if not __maid.ReelBoost then
						v11 /= 2
						v2 *= 2
						v3 *= 1.5

						function __maid.ReelBoost()
							v11 *= 2
							v2 /= 2
							v3 /= 1.5
						end
					end
				elseif currentFishingRod:GetAttribute("ActiveSkill") == "Calming Technique" then
					if not __maid.Calming then
						minigame.TimeToMaxChaos *= 5
						v10 /= 1.5

						function __maid.Calming()
							minigame.TimeToMaxChaos /= 5
							v10 *= 1.5
						end
					end
				else
					if __maid.ReelBoost then
						__maid.ReelBoost = nil
					end

					if __maid.Calming then
						__maid.Calming = nil
					end
				end

				__state.elapsed += v12
				__state.chaos = math.clamp(
					__state.elapsed / minigame.TimeToMaxChaos * (minigame.MaxChaosMultiplier - 1),
					0,
					minigame.MaxChaosMultiplier - 1
				) + 1

				if tick() >= __state.nextFishTargetChange then
					local fishTarget = __state.fishTarget
					__state.fishTarget = math.random()

					while math.abs(__state.fishTarget - fishTarget) < 0.4 do
						__state.fishTarget = math.random()
					end

					__state.lastFishTargetChange = tick()
					__state.nextFishTargetChange = tick() + (minigame.FishTargetChangeMin + math.random() * (minigame.FishTargetChangeMax - minigame.FishTargetChangeMin)) / __state.chaos
				end

				local v14 = (__state.fishTarget - __state.fishPos) * v10 * 1
				__state.fishPos = math.clamp(
					__state.fishPos + v14 * v9 * (v12 * 30) * (1 + 0.5 * (__state.chaos - 1)),
					0,
					1 - minigame.FishBarHeight
				)

				if v14 > 0 then
					icon.ImageRectOffset = Vector2.new(39, 111)
					icon.ImageRectSize = Vector2.new(119, 92)
				else
					icon.ImageRectOffset = Vector2.new(158, 111)
					icon.ImageRectSize = Vector2.new(-119, 92)
				end

				self.FishFrame.Position = UDim2.new(__state.fishPos, 0, 0.5, 0)
				local isReeling = controller:IsReeling()
				local v15 = isReeling and v3 or -v3
				self:UpdateDirectionalArrows(isReeling)
				__state.velocity += (v15 - __state.velocity) * v4 * math.max(1 - __state.chaos / 30, 0.3) * (v12 * 60 * 1)
				__state.playerPos = math.clamp(
					__state.playerPos + __state.velocity * v12 * 30,
					0 + scale / 2,
					1 - scale / 2
				)
				local v17 = __state.fishPos - minigame.FishBarHeight / 2
				local v18 = __state.fishPos + minigame.FishBarHeight / 2
				local v19 = __state.playerPos - scale / 2
				local v20 = __state.playerPos + scale / 2
				local v21

				if v17 <= v20 then
					v21 = v19 <= v18
				else
					v21 = false
				end

				self:AnimateFish(v21, v12)
				self:UpdateReelZone(__state.playerPos, v21)

				if v21 then
					total += v12
					__state.progress = math.clamp(__state.progress + v2 * v12 * 30, 0, 1)
				else
					local v22 = __state
					local progress = __state.progress
					local v23 = v11 * v12 * 30
					v22.progress = math.clamp(progress - v23 * (1 + __state.chaos / 10), 0, 1)
				end

				local Global = require(game.ReplicatedStorage.Global)

				if Global.FishingInstantCatch then
					__state.progress = maxProgress
				end

				self:UpdateProgressBar(__state.progress)

				if __state.BobberComponent then
					__state.BobberComponent:Update(
						-__state.progress,
						__state.fishPos - (1 - minigame.FishBarHeight) / 2,
						__state.playerPos
					)
				end

				if __state.treasurePos and self.TreasureFrame.Visible then
					local v22

					if __state.treasurePos <= v20 then
						v22 = v19 <= __state.treasurePos + minigame.ChestBarHeight
					else
						v22 = false
					end

					self:SetChestOverlap(v22, __state.treasureProgress)

					if v22 then
						__state.treasureProgress = math.clamp(
							__state.treasureProgress + minigame.TreasureGainRate * v12 * 30,
							0,
							1
						)
					else
						__state.treasureProgress = math.clamp(
							__state.treasureProgress - minigame.TreasureLossRate * v12 * 30,
							0,
							1
						)
					end

					self.TreasureFrame.Position = UDim2.new(__state.treasurePos, 0, 0.5, 0)

					if __state.treasureProgress >= 1 then
						__state.treasurePos = nil
						self:ChestAcquired()
					end
				end

				if not (maxProgress <= __state.progress or __state.progress <= 0) then
					continue
				end

				if __state.progress >= 1 and bossBattle then
					__state.RemoteFunction:InvokeServer("ProceedBossBattle")
					local rodController = self.__components:Get("RodController")
					local v22

					if rodController.pauseReeling then
						v22 = rodController.pauseReeling()
					end

					DialogueController.start({
						Title = "",
						Get = function(self)
							return {
								Text = { "What's this?! There's something else on the line!" }
							}
						end
					})

					if __state.RemoteFunction:InvokeServer("ProceedBossBattle") then
						if v22 then
							v22()
						end

						__state.progress = 0.5
						__state.chaos = 1
						return fn(p)
					end
				end

				if __state.progress <= 0 and scrollModifier_RodProtector then
					scrollModifier_RodProtector = false
					__state.progress = 0.3
					__state.chaos = 1
				else
					self.__maid.Minigame = nil
					task.spawn(function()
						self:Hide()
						controller:ReelInAnimation(maxProgress <= __state.progress)
					end)
					self.__maid.invokeServerTask = task.spawn(function()
						if __state.RemoteFunction:InvokeServer(
							"Catch",
							__state.progress,
							__state.treasureProgress,
							total / __state.elapsed
						) then
							local Config2 = require(script.Parent.Parent.Config)
							local rarityColor = Config2.RarityColors[state.Rarity or 0]

							if __state.progress >= 1 then
								local lerped = Color3.new(1, 0.2, 0.2):Lerp(
									Color3.new(0.5, 1, 0.5),
									(state.Weight - state.MinWeight) / (state.MaxWeight - state.MinWeight)
								)
								local FishingIndexInventoryData = require(game.ReplicatedStorage.FishReplicated.FishingIndexInventoryData)
								local flag = false
								local v22

								if state.IsNotAFish then
									local v23 = FishingIndexInventoryData.Lookup[state.Name]

									if v23.Tags and table.find(v23.Tags, "Recipe") then
										v22 = `You found a note in a bottle...\nInside is... A new <Color={rarityColor}>{state.KEYITEM_NAME}<Color=/> recipe!`
										flag = true
									else
										v22 = `That's not a fish... That's a <Color={rarityColor}>{state.Name}<Color=/>{(state.Rarity or 1) > 0 and "!" or "."}`
									end
								else
									local weight = tostring(state.Weight)

									if currentFishingRod:GetAttribute("ScrollModifier_Gluttony") then
										local v23 = state.Weight * 0.15
										state.Weight = math.clamp(
											state.Weight + v23,
											state.MinWeight or 0,
											state.MaxWeight or 1e999
										)
										local Global2 = require(game.ReplicatedStorage.Global)
										Global2.TestGamePrint("increased weight")
										weight ..= `(+{math.floor(v23 * 100) / 100})`
									end

									local formatted = `Species: <Color={rarityColor}>{state.Name}<Color=/>`

									if rarityColor == "Mythical" then
										formatted = `<AnimateStyle=Wiggle><AnimateStepFrequency=2>{formatted}<AnimateYield=1><AnimateStyle=/><AnimateStepFrequency=/>`
									end

									v22 = `{formatted}\n{`Weight: <Color={math.floor(lerped.R * 100) / 100},{math.floor(lerped.G * 100) / 100},{math.floor(lerped.B * 100) / 100}>{weight}kg<Color=/>`}`

									if state.isFirstFound then
										v22 ..= "\nIt's the first one you've found!"
									elseif state.isBiggest then
										v22 ..= "\nIt's the biggest one you've found!"
									end
								end

								function self.__maid.onFinishedWaitingTap()
									task.spawn(function()
										__state.RemoteFunction:InvokeServer("RemoveBobberFish")
									end)
								end

								self.__maid.WaitForTapDialogue = task.spawn(function()
									local lastTime = tick()
									task.wait(0.5)

									while not controller:IsReeling() do
										task.wait()

										if tick() - lastTime > 5 then
											break
										end
									end

									local v23 = {
										Text = { v22 },
										NoCancelButton = true
									}

									if flag then
										v23.Option1 = {
											Label = "Learn",
											JumpTo = function()
												Notification.new((`Learned {state.KEYITEM_NAME} recipe!`)):Display()
											end
										}
									end

									DialogueController.start({
										Title = "",
										Get = function(self)
											return v23
										end
									})
									self.__maid.onFinishedWaitingTap = nil
								end)
							end
						end
					end)
					break
				end
			end
		end

		if __state.currentFish.BossBattle then
			fn(__state.currentFish.dummyFish, __state.currentFish)
		else
			fn(__state.currentFish)
		end
	end)
end

function CatchingMinigame:StartCatching(p)
	local Entity = require(script.Entity)
	self.Fish = Entity.new("Fish", p.Name)
	self:Main()
end

function CatchingMinigame.Construct(p)
	local self = setmetatable(p, CatchingMinigame)
	self.Entities = {}
	return self
end

function CatchingMinigame.Setup() end

return CatchingMinigame