local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local module = require("./PassiveHandler")
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Companion/Comet/StarBuff")
local color = Color3.fromRGB(255, 190, 70)
local flag = false

local function preloadStarAssets()
	if flag then
		return
	end

	flag = true
	local children = {}

	for _, childName in pairs({ "Star", "BuffStar" }) do
		local child = script:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	if #children == 0 then
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(children)
		end)

		if not success then
			warn((`ShootingStar: failed to preload star assets - {result}`))
		end
	end)
end

local function playSound(childName: string?, reel)
	if not childName then
		return
	end

	local resources = ReplicatedStorage:FindFirstChild("resources")
	local sounds = resources and resources:FindFirstChild("sounds")
	local sfx = sounds and sounds:FindFirstChild("sfx")
	local sfxUi = sfx and sfx:FindFirstChild("ui")
	local sound = sfxUi and sfxUi:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		local clone = sound:Clone()
		clone.Name = sound.Name .. "Clone"
		clone.PlaybackSpeed = math.random(90, 115) / 100
		clone.Parent = reel
		clone:Play()
		task.delay(math.max(clone.TimeLength * 2, 2), function()
			clone:Destroy()
		end)
	end
end

local CometShootingStars = {
	Morph = function(p, _, object)
		local scaledConfig = CompanionController.GetScaledConfig(p.config)
		local random = object:GetRandom(88)
		local modifier = object:CreateModifier("progressefficiency", "add")
		local modifier2 = object:CreateModifier("resilience", "add")
		local modifier3 = object:CreateModifier("barSize", "multiply")
		modifier.Value = 0
		modifier2.Value = 0
		modifier3.Value = 1
		local v = nil

		local function barToScreenX(p2: number)
			local reel_bar = object.reel_bar
			local absolutePosition = reel_bar.AbsolutePosition
			local absoluteSize = reel_bar.AbsoluteSize
			local absolutePosition2 = object.reel.AbsolutePosition
			local absoluteSize2 = object.reel.AbsoluteSize

			if absoluteSize2.X <= 0 then
				return p2
			end

			return (absolutePosition.X - absolutePosition2.X + p2 * absoluteSize.X) / absoluteSize2.X
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getBarScreenY()
			local reel_bar = object.reel_bar
			local absolutePosition = object.reel.AbsolutePosition
			local absoluteSize = object.reel.AbsoluteSize

			if absoluteSize.Y <= 0 then
				return reel_bar.Position.Y.Scale
			end

			return (reel_bar.AbsolutePosition.Y - absolutePosition.Y + reel_bar.AbsoluteSize.Y / 2) / absoluteSize.Y
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBuffActive(flag2: boolean)
			modifier.Value = not flag2 and 0 or scaledConfig.ProgressSpeedBoost / 100
			modifier2.Value = not flag2 and 0 or scaledConfig.ResilienceBoost
			modifier3.Value = not flag2 and 1 or 1 - scaledConfig.ControlPenalty
		end

		local function flashImpact()
			if object.fx then
				object.fx:SpawnShake(object.reel_bar, 0.6, 0.35, 0.015, true)
			end

			object.renderTweens:Create(
				object.reel_playerbar,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = color
				}
			):Play()

			if v then
				v:Cancel()
			end

			local v2 = object.renderTweens:Create(
				object.reel_progress.bar,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
				{
					BackgroundColor3 = color
				}
			)
			v = v2
			v2:Play()
			playSound(scaledConfig.SoundName or "shootingStarImpact", object.reel)
		end

		local function spawnStar()
			local star = script:FindFirstChild("Star")

			if not (star and star:IsA("GuiObject")) then
				return nil, 0, 0, 0, 0
			end

			local v2, v3, v4, v5

			if random:NextNumber(0, 100) <= 35 then
				local barPosition = object.barPosition
				local reel_bar = object.reel_bar
				local absolutePosition = reel_bar.AbsolutePosition
				local absoluteSize = reel_bar.AbsoluteSize
				local absolutePosition2 = object.reel.AbsolutePosition
				local absoluteSize2 = object.reel.AbsoluteSize

				if not (absoluteSize2.X <= 0) then
					barPosition = (absolutePosition.X - absolutePosition2.X + barPosition * absoluteSize.X) / absoluteSize2.X
				end

				v2 = barPosition + random:NextNumber(-0.1, 0.1)
				v3 = -0.6
				v4 = -0.03
				local barPosition2 = object.barPosition
				local reel_bar2 = object.reel_bar
				local absolutePosition3 = reel_bar2.AbsolutePosition
				local absoluteSize3 = reel_bar2.AbsoluteSize
				local absolutePosition4 = object.reel.AbsolutePosition
				local absoluteSize4 = object.reel.AbsoluteSize

				if not (absoluteSize4.X <= 0) then
					barPosition2 = (absolutePosition3.X - absolutePosition4.X + barPosition2 * absoluteSize3.X) / absoluteSize4.X
				end

				if v2 < barPosition2 then
					v5 = -1
				else
					v5 = 1
				end
			else
				local v6 = random:NextNumber() > 0.5
				v2 = v6 and -0.08 or 1.08
				local barScreenY = getBarScreenY() -- equivalent call inferred; original call site unknown
				v3 = barScreenY + -0.35
				v4 = -0.18

				if v6 then
					v5 = -1
				else
					v5 = 1
				end
			end

			local clone = star:Clone()
			clone.Position = UDim2.fromScale(v2, v3)
			clone.Parent = object.reel
			p.reelTrove:Add(clone)
			return clone, v2, v3, v4, v5
		end

		task.spawn(function()
			object:WaitUntilReady()
			local v2 = not scaledConfig.AttemptImmediate and 0 or scaledConfig.AttemptInterval
			local now = -1e999
			local v3 = nil
			local flag2 = false
			local total = 0
			local v4 = 0
			local v5 = 0
			local v6 = -0.18
			local v7 = -1
			local v8 = 0
			local v9 = 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function clearStar()
				if v3 then
					v3:Destroy()
					v3 = nil
				end
			end

			local function fadeOutImpactedStar()
				local image = v3
				v3 = nil

				if not image then
					return
				end

				local v10 = {}

				if image:IsA("ImageLabel") then
					v10.ImageTransparency = 1
				else
					v10.BackgroundTransparency = 1
				end

				local v11 = object.renderTweens:Create(image, TweenInfo.new(0.12, Enum.EasingStyle.Linear), v10)
				v11.Completed:Once(function()
					image:Destroy()
				end)
				v11:Play()
			end

			local function headPivotOffset(p2)
				local absoluteSize = object.reel.AbsoluteSize

				if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
					return 0, 0
				end

				local rotation = math.rad(p2.Rotation)
				local v10 = p2.AbsoluteSize.X / 2
				return v10 * (1 - math.cos(rotation)) / absoluteSize.X, -v10 * math.sin(rotation) / absoluteSize.Y
			end

			local function headPivotPixels(p2)
				local rotation = math.rad(p2.Rotation)
				local v10 = p2.AbsoluteSize.X / 2
				return v10 * (1 - math.cos(rotation)), -v10 * math.sin(rotation)
			end

			local v10 = nil
			local v11 = 0
			local total2 = 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function clearBuffStar()
				if v10 then
					v10:Destroy()
					v10 = nil
				end
			end

			p.reelTrove:Add(clearBuffStar)

			local function spawnBuffStar()
				if v10 then
					return
				end

				local buffStar = script:FindFirstChild("BuffStar")

				if not (buffStar and buffStar:IsA("ImageLabel")) then
					return
				end

				local clone = buffStar:Clone()
				v11 = -(1 - clone.AnchorPoint.Y) * clone.Size.Y.Offset
				total2 = 0
				clone.Position = UDim2.new(object.barPosition, 0, 0, v11)
				clone.ZIndex = 30
				clone.Parent = object.reel_bar
				v10 = clone
			end

			local function burnOutBuffStar()
				local v12 = v10
				v10 = nil

				if not v12 then
					return
				end

				local v13 = object.renderTweens:Create(
					v12,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						ImageTransparency = 1,
						Position = v12.Position - UDim2.fromOffset(0, 6)
					}
				)
				v13.Completed:Once(function()
					v12:Destroy()
				end)
				v13:Play()
			end

			p.reelTrove:Add(clearStar)
			local v12 = 0
			local flag3 = false
			p.reelTrove:Add(function()
				setBuffActive(false) -- equivalent call inferred; original call site unknown

				if flag3 then
					flag3 = false
					remoteEvent:FireServer(false)
				end
			end)
			p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
				if object.active then
					if flag3 then
						local now2 = tick()

						if v12 <= now2 then
							flag3 = false
							setBuffActive(false) -- equivalent call inferred; original call site unknown
							burnOutBuffStar()
							remoteEvent:FireServer(false)
						end
					end

					if v10 then
						total2 += p2
						local v13 = math.sin(total2 * 2.4) * 2
						v10.Position = UDim2.new(object.barPosition, 0, 0, v11 + v13)
						v10.Rotation = math.sin(total2 * 1.7) * 8
					end

					if v3 then
						if flag2 then
							local v13 = object.barPosition + v7 * object.barSize * 0.32
							local v14 = v3
							local rotation = math.rad(v14.Rotation)
							local v15 = v14.AbsoluteSize.X / 2
							local v16 = v15 * (1 - math.cos(rotation))
							local v17 = -v15 * math.sin(rotation)
							v3.Position = UDim2.new(v13, v16, 0.5, v17)
							v3.ZIndex = 28
							v3.Parent = object.reel_bar
							flag2 = false
							fadeOutImpactedStar()
							flashImpact()
							spawnBuffStar()
						else
							total += p2
							local v13 = math.min(total / 0.8, 1)
							local v14 = v13 ^ 1.4
							local v15 = math.min(p2 * (v14 * 26 + 6), 1)
							local v16 = object.barPosition + v7 * object.barSize * 0.32
							local v17 = v8
							local reel_bar = object.reel_bar
							local absolutePosition = reel_bar.AbsolutePosition
							local absoluteSize = reel_bar.AbsoluteSize
							local absolutePosition2 = object.reel.AbsolutePosition
							local absoluteSize2 = object.reel.AbsoluteSize

							if not (absoluteSize2.X <= 0) then
								v16 = (absolutePosition.X - absolutePosition2.X + v16 * absoluteSize.X) / absoluteSize2.X
							end

							v8 = v17 + (v16 - v8) * v15
							local v18 = v9
							local barScreenY = getBarScreenY() -- equivalent call inferred; original call site unknown
							v9 = v18 + (barScreenY - v9) * v15
							local v19 = v8
							local v20 = v9
							local v21 = v4 + (v19 - v4) * v14
							local v22 = v6 * 4 * v14 * (1 - v14)
							local v23 = v5 + (v20 - v5) * v14 + v22
							local absoluteSize3 = object.reel.AbsoluteSize
							local v24 = (v19 - v4) * absoluteSize3.X
							local v25 = (v20 - v5 + v6 * 4 * (1 - v14 * 2)) * absoluteSize3.Y

							if math.abs(v24) > 0.001 or math.abs(v25) > 0.001 then
								v3.Rotation = math.deg((math.atan2(v25, v24)))
							end

							local v26 = v3
							local absoluteSize4 = object.reel.AbsoluteSize
							local v27, v28

							if absoluteSize4.X <= 0 or absoluteSize4.Y <= 0 then
								v27 = 0
								v28 = 0
							else
								local rotation = math.rad(v26.Rotation)
								local v29 = v26.AbsoluteSize.X / 2
								v27 = v29 * (1 - math.cos(rotation)) / absoluteSize4.X
								v28 = -v29 * math.sin(rotation) / absoluteSize4.Y
							end

							v3.Position = UDim2.fromScale(v21 + v27, v23 + v28)

							if v13 >= 1 then
								local v29 = object.barPosition + v7 * object.barSize * 0.32
								local reel_bar2 = object.reel_bar
								local absolutePosition3 = reel_bar2.AbsolutePosition
								local absoluteSize5 = reel_bar2.AbsoluteSize
								local absolutePosition4 = object.reel.AbsolutePosition
								local absoluteSize6 = object.reel.AbsoluteSize

								if not (absoluteSize6.X <= 0) then
									v29 = (absolutePosition3.X - absolutePosition4.X + v29 * absoluteSize5.X) / absoluteSize6.X
								end

								local barScreenY2 = getBarScreenY() -- equivalent call inferred; original call site unknown
								local v30 = v3
								local absoluteSize7 = object.reel.AbsoluteSize
								local v31, v32

								if absoluteSize7.X <= 0 or absoluteSize7.Y <= 0 then
									v31 = 0
									v32 = 0
								else
									local rotation = math.rad(v30.Rotation)
									local v33 = v30.AbsoluteSize.X / 2
									v31 = v33 * (1 - math.cos(rotation)) / absoluteSize7.X
									v32 = -v33 * math.sin(rotation) / absoluteSize7.Y
								end

								v3.Position = UDim2.fromScale(v29 + v31, barScreenY2 + v32)
								flag2 = true
								flag3 = true
								v12 = tick() + scaledConfig.Duration
								setBuffActive(true) -- equivalent call inferred; original call site unknown
								remoteEvent:FireServer(true)
							end
						end
					else
						v2 += p2

						if v2 < scaledConfig.AttemptInterval then
							return
						end

						v2 = 0

						if tick() - now < scaledConfig.Cooldown or random:NextNumber(0, 100) > scaledConfig.TriggerChance then
							return
						end

						now = tick()
						local v13, v14, v15, v16, v17 = spawnStar()

						if v13 then
							playSound(scaledConfig.WooshSoundName or "shootingStar", object.reel)
							v3 = v13
							flag2 = false
							total = 0
							v4 = v14
							v5 = v15
							v6 = v16
							v7 = v17
							local v18 = object.barPosition + v17 * object.barSize * 0.32
							local reel_bar = object.reel_bar
							local absolutePosition = reel_bar.AbsolutePosition
							local absoluteSize = reel_bar.AbsoluteSize
							local absolutePosition2 = object.reel.AbsolutePosition
							local absoluteSize2 = object.reel.AbsoluteSize

							if not (absoluteSize2.X <= 0) then
								v18 = (absolutePosition.X - absolutePosition2.X + v18 * absoluteSize.X) / absoluteSize2.X
							end

							v8 = v18
							v9 = getBarScreenY() -- equivalent call inferred; original call site unknown
						else
							flashImpact()
							spawnBuffStar()
							flag3 = true
							v12 = tick() + scaledConfig.Duration
							setBuffActive(true) -- equivalent call inferred; original call site unknown
							remoteEvent:FireServer(true)
						end
					end
				else
					clearStar() -- equivalent call inferred; original call site unknown
					clearBuffStar() -- equivalent call inferred; original call site unknown
				end
			end))
		end)
	end
}
setmetatable(CometShootingStars, module)
return CometShootingStars