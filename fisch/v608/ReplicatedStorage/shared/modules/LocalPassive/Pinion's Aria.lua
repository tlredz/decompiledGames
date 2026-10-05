local PinionSAria = {}
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local module = require("./PassiveHandler")
local rods = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local v = { script.note1, script.note2 }

local function playSound(instance, playbackSpeed: number)
	local clone = instance:Clone()
	clone.PlaybackSpeed = playbackSpeed
	clone.Name = instance.Name .. "Clone"
	clone.Parent = script
	clone:Play()
	task.delay(instance.TimeLength * 2, function()
		clone:Destroy()
	end)
	return clone
end

local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)

local function getNote(list)
	if typeof(list) == "table" then
		return list[math.random(1, #list)]
	end

	return list
end

function PinionSAria.Morph(p, parent, object)
	object:Preload({ parent, script })
	local clone = script.ResonanceOverlay:Clone()
	clone.Parent = object.reel
	local clone_2 = script.noteContainer:Clone()
	clone_2.Parent = parent

	if object.rodName == "Pinion's Aria" then
		object.OnFishEnterBar:Connect(function()
			parent.playerbar.Bar.BackgroundColor3 = Color3.fromRGB(241, 225, 255)
		end)
		object.OnFishExitBar:Connect(function()
			parent.playerbar.Bar.BackgroundColor3 = Color3.fromRGB(198, 162, 162)
		end)
	end

	local count = 0
	local count2 = 0
	local count3 = 0
	local v2 = p.config.OVERRIDE_NOTE_HIT_SOUND_NAME and script:FindFirstChild(p.config.OVERRIDE_NOTE_HIT_SOUND_NAME) or script.NoteHit
	local v3 = p.config.OVERRIDE_NOTE_MISS_SOUND_NAME and script:FindFirstChild(p.config.OVERRIDE_NOTE_MISS_SOUND_NAME) or script.NoteMiss
	object.BuildEndingData:Bind(function(p2)
		p2.PinionsAria_NoteHitCount = count
		p2.PinionsAria_NoteMissCount = count2
		p2.PinionsAria_SlashCount = count3
		local v4 = object
		local perfect = object.perfect

		if not perfect then
			if count2 == 0 then
				perfect = count3 == 0
			else
				perfect = false
			end
		end

		v4.perfect = perfect
		return p2
	end)
	local config = p.config

	if object.fish.Name == "Veiled Charybdis" then
		config.SUCCESS_PROGRESS_LOSS_REDUCTION = 0
		config.FAIL_PROGRESS_LOSS_INCREASE = 0
	end

	local v4 = rods[object.rodName].Control + 0.3
	local v5 = object.barSize - v4

	if v5 > 0 then
		object:AddModifier("barSize", "add", -v5 * config.EXTERNAL_CONTROL_DEBUFF)
	end

	local icon = parent:WaitForChild("fish"):WaitForChild("icon")

	for _, child in script.fishChildren:GetChildren() do
		local clone2 = child:Clone()

		if clone2.Name ~= "anger" and p.config.OVERRIDE_NOTE_IMG then
			local OVERRIDE_NOTE_IMG = p.config.OVERRIDE_NOTE_IMG

			if typeof(OVERRIDE_NOTE_IMG) == "table" then
				OVERRIDE_NOTE_IMG = OVERRIDE_NOTE_IMG[math.random(1, #OVERRIDE_NOTE_IMG)]
			end

			clone2.Image = OVERRIDE_NOTE_IMG
			clone2.UIGradient.Enabled = false
		end

		clone2.Parent = icon
	end

	local anger = icon:WaitForChild("anger")

	if object.fish.Name == "Toilet Fish" then
		config = table.clone(config)
		config.DROP_TIME = 10
		config.DROP_TIME_REDUCE = 0.999
		config.DROP_INTERVAL = 0
		config.MIN_DROP_INTERVAL = 0
		config.MIN_DROP_TIME = 0
		config.SUCCESS_PROGRESS_BOOST = 0
	end

	local scale = 0.5
	task.delay(0.8, function()
		if object.fish.Mutation == "Harmonized" then
			clone.BackgroundTransparency = 0
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(playSound(script.Harmonized, 1), TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				PlaybackSpeed = 5
			}):Play()
		end
	end)
	task.spawn(function()
		object:WaitUntilReady()
		local v6 = nil
		local modifier = object:CreateModifier("barSize", "add")
		local modifier2 = object:CreateModifier("barSize", "add")
		local modifier3 = object:CreateModifier("progressefficiency", "add")
		local modifier4 = object:CreateModifier("progressefficiency", "force_add")
		local modifier5 = object:CreateModifier("progressLossMultiplier", "multiply")
		local modifier6 = object:CreateModifier("movementfactor", "multiply")
		local modifier7 = object:CreateModifier("accel", "multiply")
		modifier7.Value = 2
		object:AddModifier("minBarSize", "add", 0.1)
		local noteContainer = parent:WaitForChild("noteContainer")
		local random = object:GetRandom(5)
		local DROP_INTERVAL = config.DROP_INTERVAL
		local DROP_TIME = config.DROP_TIME
		local v7 = object.rodName == "Pinion's Aria" and {
			parent:WaitForChild("progress"):WaitForChild("bar"):WaitForChild("Shine"),
			parent:WaitForChild("playerbar"):WaitForChild("Bar"):WaitForChild("Shine")
		} or {}
		local v8 = {
			icon:WaitForChild("resonanceNote1"),
			icon:WaitForChild("resonanceNote2"),
			icon:WaitForChild("resonanceNote3")
		}

		for _, v9 in v8 do
			v9:SetAttribute("OriginalPosition", v9.Position)
		end

		local count4 = 0
		local flag = false
		local total = 1
		object.OnMinigameEnd:Once(function()
			script.Resonance:Stop()
			v2.Volume = 0.5
		end)
		local lastTime = tick()
		object.trove:Add(object.OnLogicStep:Connect(function(p2: number)
			if flag then
				modifier2.Value -= p2 * config.RESONANCE_CONTROL_REDUCE_RATE * ((v5 + v4) / v4)
				modifier4.Value += p2 * config.RESONANCE_PROGRESS_SPEED_INCREASE / (object.barSize * 2)
			end
		end))
		object.trove:Add(object.OnRenderStep:Connect(function(_: number)
			if flag then
				for k, v9 in v8 do
					v9.Position = v9:GetAttribute("OriginalPosition") + UDim2.fromScale(
						0,
						math.sin((tick() - lastTime) * 2 + k / 1) * 0.1
					)
				end
			end
		end))
		object.OnSlash:Connect(function()
			if object.rodName ~= "Pinion's Aria" then
				return
			end

			if flag then
				object.renderTweens:CreateAndPlay(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					BackgroundTransparency = 1
				})
			end

			count3 += 1
			flag = false
			count4 = 0
			script.Resonance:Stop()
			v2.Volume = 0.5
			modifier7.Value = 1
			total += 0.5
			TweenService:Create(playSound(v3, math.random(15, 25) / 10), tweenInfo, {
				PlaybackSpeed = 0.5
			}):Play()
			count4 = 0
			local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quart)

			for _, v10 in v7 do
				v10.ImageColor3 = Color3.fromRGB(255, 50, 50)
				object.renderTweens:CreateAndPlay(v10, tweenInfo2, {
					ImageTransparency = 1
				}, {
					ImageTransparency = 0
				})
			end

			object.logicTweens:CreateAndPlay(modifier, tweenInfo2, {
				Value = math.min(0, modifier.Value)
			})
			object.logicTweens:CreateAndPlay(modifier3, tweenInfo2, {
				Value = 0
			})
			modifier5.Value = 1
			modifier6.Value = 1
			object:AddProgress(-10)

			for _, v10 in v8 do
				v10.Visible = false
			end

			anger.ImageTransparency = 0
			anger.Position = UDim2.fromScale(-0.5, -0.5)
			TweenService:Create(anger, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				Position = UDim2.fromScale(0.5, -0.5)
			}):Play()
			TweenService:Create(anger, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()
		end)

		while object.active do
			local clone2 = v[math.random(1, #v)]:Clone()

			if p.config.OVERRIDE_NOTE_IMG then
				local OVERRIDE_NOTE_IMG = p.config.OVERRIDE_NOTE_IMG

				if typeof(OVERRIDE_NOTE_IMG) == "table" then
					OVERRIDE_NOTE_IMG = OVERRIDE_NOTE_IMG[math.random(1, #OVERRIDE_NOTE_IMG)]
				end

				clone2.Image = OVERRIDE_NOTE_IMG
				clone2.UIGradient.Enabled = false
			end

			local halfScale = clone2.Size.X.Scale / 2
			local v10 = 1 - clone2.Size.X.Scale / 2
			local v11 = flag and scale or object.fishPosition
			local v12 = math.clamp(v11 - (object.barSize + config.DROP_RANGE), halfScale, v10)
			local v13 = math.clamp(v11 + (object.barSize + config.DROP_RANGE), halfScale, v10)
			local uDim = UDim2.fromScale(random:NextNumber(v12, v13), 0.5)
			scale = uDim.X.Scale
			local tweenInfo2 = TweenInfo.new(DROP_INTERVAL / 2, Enum.EasingStyle.Back)
			TweenInfo.new(DROP_INTERVAL / 2, Enum.EasingStyle.Sine)
			local tweenInfo3 = TweenInfo.new(DROP_INTERVAL / 2, Enum.EasingStyle.Linear)
			local tweenInfo4 = TweenInfo.new(DROP_TIME / 4, Enum.EasingStyle.Linear)
			local tweenInfo5 = TweenInfo.new(DROP_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			clone2.ImageTransparency = 1
			clone2.Position = uDim + UDim2.fromScale(0, -config.DROP_HEIGHT)
			clone2.Parent = noteContainer
			object.logicTweens:CreateAndPlay(clone2, tweenInfo4, {
				ImageTransparency = 0
			})
			local v14 = object.logicTweens:Create(clone2, tweenInfo5, {
				Position = uDim
			})
			object.trove:Add(v14.Completed:Once(function()
				if not object.active then
					return
				end

				if object:IsInBar(uDim.X.Scale, clone2.Size.X.Scale * 0.85) then
					object.logicTweens:CreateAndPlay(modifier, tweenInfo2, {
						Value = modifier.Value + config.SUCCESS_CONTROL_INCREASE / total
					})
					object:AddProgress(config.SUCCESS_PROGRESS_BOOST / total)
					object.logicTweens:CreateAndPlay(modifier3, tweenInfo2, {
						Value = modifier3.Value + config.SUCCESS_PROGRESS_SPEED_INCREASE / total
					})
					modifier5.Value += config.SUCCESS_PROGRESS_LOSS_REDUCTION / total
					modifier6.Value += config.SUCCESS_FISH_SLOW_FACTOR / total

					if v6 == nil then
						v6 = true
					end

					count4 += 1
					count += 1
					playSound(v2, math.random(15, 25) / 10)

					for k, v21 in v7 do
						v21.ImageColor3 = Color3.fromRGB(244, 237, 252)
					end
				else
					object.logicTweens:CreateAndPlay(modifier, tweenInfo2, {
						Value = modifier.Value - object.barSize * config.FAIL_CONTROL_REDUCE * total
					})
					object:AddProgress(object.progress * config.FAIL_PROGRESS_LOSS * total)
					object.logicTweens:CreateAndPlay(modifier3, tweenInfo2, {
						Value = math.max(modifier3.Value + config.FAIL_PROGRESS_SPEED_REDUCE * total, 0)
					})
					modifier5.Value += config.FAIL_PROGRESS_LOSS_INCREASE * total
					modifier6.Value = math.max(1, modifier6.Value + config.FAIL_FISH_SLOW_FACTOR * total)
					v6 = false
					TweenService:Create(playSound(v3, math.random(15, 25) / 10), tweenInfo, {
						PlaybackSpeed = 0.5
					}):Play()
					count4 = 0
					count2 += 1

					for k, v21 in v7 do
						v21.ImageColor3 = Color3.fromRGB(255, 50, 50)
					end

					DROP_TIME = config.DROP_TIME
					modifier7.Value = 2
				end

				for k, v19 in v7 do
					object.renderTweens:CreateAndPlay(v19, tweenInfo3, {
						ImageTransparency = 1
					}, {
						ImageTransparency = 0
					})
				end

				clone2:Destroy()

				if count4 >= config.RESONANCE_REQUIREMENT then
					if not flag then
						script.Resonance:Play()
						v2.Volume = 0.3
						clone.BackgroundTransparency = 0
						object.renderTweens:CreateAndPlay(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							BackgroundTransparency = 0.5
						})
						local v19 = object.core.fish:SetMovementBehavior("Follow")

						if v19.Name == "Follow" then
							v19.FollowSpeed = config.RESONANCE_FOLLOW_SPEED
						end
					end

					flag = true
				else
					if flag then
						object.renderTweens:CreateAndPlay(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							BackgroundTransparency = 1
						})
						object.logicTweens:CreateAndPlay(modifier, tweenInfo2, {
							Value = 0
						})
						object.logicTweens:CreateAndPlay(modifier2, tweenInfo2, {
							Value = 0
						})
						DROP_INTERVAL = config.DROP_INTERVAL
					end

					flag = false
					script.Resonance:Stop()
					v2.Volume = 0.5
					object.core.fish:SetMovementBehavior(object.core.fish.OriginalMovementBehaviorName)
				end

				for k, v19 in v8 do
					v19.Visible = flag
				end
			end))
			v14:Play()
			local v19 = DROP_INTERVAL * config.DROP_INTERVAL_REDUCE
			DROP_INTERVAL = math.max(v19, config.MIN_DROP_INTERVAL)
			local v20 = DROP_TIME * config.DROP_TIME_REDUCE
			DROP_TIME = math.max(v20, config.MIN_DROP_TIME)
			modifier7.Value = math.min(modifier7.Value + config.ACCEL_INCREASE, config.MAX_ACCEL_BOOST)
			object:WaitLogic(DROP_INTERVAL)
		end
	end)
end

setmetatable(PinionSAria, module)
return PinionSAria