local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)
local tweenInfo6 = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local color = Color3.fromRGB(150, 150, 142)
local tweenInfo7 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local AncientIdolRod = {
	Morph = function(p, _, object)
		local config = p.config
		local random = object:GetRandom(19)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local function fastTween(p2, p3, p4)
			return object.renderTweens:CreateAndPlay(p2, p3, p4)
		end

		local fish = reel_bar:FindFirstChild("fish")
		local icon = fish and fish:FindFirstChild("icon")
		local stroke = fish and fish:FindFirstChild("stroke")
		local imageColor3 = icon and icon.ImageColor3 or Color3.new(1, 1, 1)
		local size = icon and icon.Size
		local color2 = stroke and stroke.Color
		local stoneColor = config.StoneColor or color
		local clone = script.shiningbar:Clone()
		clone.Parent = reel_bar
		p.reelTrove:Add(clone)
		local bar = clone.bar
		local fullglow = clone:FindFirstChild("fullglow")
		local label = clone:FindFirstChild("Label")
		bar.Size = UDim2.fromScale(0, 1)
		bar.BackgroundColor3 = config.GoldenColor
		local size2 = label and label.Size

		local function setLabel(text: string, color3: Color3, flag: boolean)
			if not label then
				return
			end

			label.Text = text
			object.renderTweens:CreateAndPlay(label, tweenInfo, {
				TextColor3 = color3,
				TextTransparency = flag and 0.35 or 0
			})

			if size2 and not flag then
				label.Size = UDim2.fromScale(size2.X.Scale, size2.Y.Scale * 1.25)
				object.renderTweens:CreateAndPlay(label, tweenInfo7, {
					Size = size2
				})
			end
		end

		if label then
			label.Text = "Idol's Judgement"
			label.TextTransparency = 0.35
		end

		local modifier = object:CreateModifier("moveIntervalFactor", "multiply")
		modifier.Value = 1
		local modifier2 = object:CreateModifier("barSize", "multiply")
		modifier2.Value = 1
		local modifier3 = object:CreateModifier("progressLossMultiplier", "multiply")
		modifier3.Value = 1
		local v = nil
		local v2 = 0
		local number = random:NextNumber(config.GlowIntervalMin, config.GlowIntervalMax)
		local total = 0
		local idolFill = 0
		local total2 = 0
		local flag = false
		p.reelTrove:Add(object.BuildEndingData:Bind(function(p2)
			p2.IdolPetrified = flag
			p2.IdolFill = idolFill
			return p2
		end))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tweenValue(p2, p3: number, p4)
			object.logicTweens:CreateAndPlay(p2, p4, {
				Value = p3
			})
		end

		local function tintFish(color3: Color3, tweenInfo8)
			if icon then
				object.renderTweens:CreateAndPlay(icon, tweenInfo8, {
					ImageColor3 = color3
				})
			end

			if stroke then
				object.renderTweens:CreateAndPlay(stroke, tweenInfo8, {
					Color = color3
				})
			end
		end

		local function pulseFish()
			if not (icon and size) then
				return
			end

			icon.Size = size
			local v6 = {
				Size = UDim2.fromScale(size.X.Scale * 1.15, size.Y.Scale * 1.15)
			}
			object.renderTweens:CreateAndPlay(icon, tweenInfo5, v6)
		end

		local clone2 = nil

		local function setWorldGlow(color3: Color3?)
			if color3 then
				if not clone2 then
					local bobberglow = script:FindFirstChild("bobberglow")
					local character = localPlayer.Character
					local tool = character and character:FindFirstChildOfClass("Tool")
					local bobber = tool and tool:FindFirstChild("bobber")

					if bobberglow and bobber and bobber:IsA("BasePart") then
						clone2 = bobberglow:Clone()
						clone2.Parent = bobber
						p.reelTrove:Add(clone2)
					else
						return
					end
				end

				for _, child in clone2:GetChildren() do
					if child:IsA("PointLight") then
						object.renderTweens:CreateAndPlay(child, tweenInfo, {
							Color = color3
						})
					elseif child:IsA("ParticleEmitter") then
						child.Color = ColorSequence.new(color3)
					end
				end
			elseif clone2 then
				clone2:Destroy()
				clone2 = nil
			end
		end

		local function setGlow(p2: string?)
			v = p2

			if p2 == "Golden" then
				tweenValue(modifier, config.GoldenFishSlowdown, tweenInfo) -- equivalent call inferred; original call site unknown
				local goldenBarShrink = object.onbar and config.GoldenBarShrink or 1
				tweenValue(modifier2, goldenBarShrink, tweenInfo4) -- equivalent call inferred; original call site unknown
				tweenValue(modifier3, 1, tweenInfo2) -- equivalent call inferred; original call site unknown
				tintFish(config.GoldenColor, tweenInfo)
				local v12 = {
					BackgroundColor3 = config.GoldenColor
				}
				object.renderTweens:CreateAndPlay(bar, tweenInfo, v12)
				pulseFish()
				setLabel("Golden Blessing", config.GoldenColor, false)
				fx:PlaySound(script.golden, script)
				setWorldGlow(config.GoldenColor)
				object.fx:SpawnShake(reel_bar, 0.12, 0.3, 0.02, false)
			elseif p2 == "Purple" then
				tweenValue(modifier, config.PurpleFishSpeedup, tweenInfo) -- equivalent call inferred; original call site unknown
				tweenValue(modifier2, config.PurpleBarShrink, tweenInfo3) -- equivalent call inferred; original call site unknown
				tweenValue(modifier3, 0, tweenInfo) -- equivalent call inferred; original call site unknown
				tintFish(config.PurpleColor, tweenInfo)
				local v12 = {
					BackgroundColor3 = config.PurpleColor
				}
				object.renderTweens:CreateAndPlay(bar, tweenInfo, v12)
				pulseFish()
				setLabel("Idol's Curse", config.PurpleColor, false)
				fx:PlaySound(script.purple, script)
				setWorldGlow(config.PurpleColor)
				object.fx:SpawnShake(reel_bar, 0.12, 0.3, 0.02, false)
			else
				tweenValue(modifier, 1, tweenInfo2) -- equivalent call inferred; original call site unknown
				tweenValue(modifier2, 1, tweenInfo2) -- equivalent call inferred; original call site unknown
				tweenValue(modifier3, 1, tweenInfo2) -- equivalent call inferred; original call site unknown

				if icon then
					object.renderTweens:CreateAndPlay(icon, tweenInfo2, {
						ImageColor3 = imageColor3
					})
				end

				if stroke and color2 then
					object.renderTweens:CreateAndPlay(stroke, tweenInfo2, {
						Color = color2
					})
				end

				local v12 = {
					BackgroundColor3 = config.GoldenColor
				}
				object.renderTweens:CreateAndPlay(bar, tweenInfo2, v12)
				setLabel("Idol's Judgement", config.GoldenColor, true)

				if clone2 then
					clone2:Destroy()
					clone2 = nil
				end
			end
		end

		p.reelTrove:Add(object.OnFishEnterBar:Connect(function()
			if v == "Golden" and not flag then
				tweenValue(modifier2, config.GoldenBarShrink, tweenInfo4) -- equivalent call inferred; original call site unknown
			end
		end))
		p.reelTrove:Add(object.OnFishExitBar:Connect(function()
			if v == "Golden" and not flag then
				tweenValue(modifier2, 1, tweenInfo4) -- equivalent call inferred; original call site unknown
			end
		end))

		local function petrify()
			flag = true
			v = nil
			tweenValue(modifier, 1, tweenInfo2) -- equivalent call inferred; original call site unknown
			tweenValue(modifier2, 1, tweenInfo2) -- equivalent call inferred; original call site unknown
			tweenValue(modifier3, 0, tweenInfo2) -- equivalent call inferred; original call site unknown
			object:FreezeFish(1e999)
			object.core.fish:PauseMovement()
			object:TweenModifier("barSize", "force", object.barSize, config.PetrifiedBarSize, tweenInfo6)
			fx:PlaySound(script.beam, script)
			setLabel("Petrified!", config.GoldenColor, false)
			setWorldGlow(stoneColor)

			if fish then
				local clone3 = script.beams:Clone()
				clone3.Parent = fish
				p.reelTrove:Add(clone3)
				local flash = clone3:FindFirstChild("flash")
				local total3 = 0

				for _, frame in clone3:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					local v10 = frame
					local scale = frame.Size.X.Scale
					object:DelayLogic(total3, function()
						if not v10.Parent then
							return
						end

						local tweenInfo8 = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
						local v13 = {
							Size = UDim2.fromScale(scale, 1)
						}
						object.renderTweens:CreateAndPlay(v10, tweenInfo8, v13)
					end)
					total3 += 0.06
				end

				object:DelayLogic(0.32, function()
					if not clone3.Parent then
						return
					end

					if flash and flash:IsA("ImageLabel") then
						local tweenInfo8 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
						object.renderTweens:CreateAndPlay(flash, tweenInfo8, {
							ImageTransparency = 0
						})
					end

					tintFish(stoneColor, tweenInfo)
					pulseFish()
					object.fx:SpawnShake(reel_bar, 0.5, 0.6, 0.01, true)

					if fullglow then
						local tweenInfo8 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
						object.renderTweens:CreateAndPlay(fullglow, tweenInfo8, {
							Transparency = 0
						})
					end
				end)
				object:DelayLogic(1.1, function()
					for _, frame in clone3:GetChildren() do
						if not frame:IsA("Frame") then
							continue
						end

						local tweenInfo8 = TweenInfo.new(0.5)
						object.renderTweens:CreateAndPlay(frame, tweenInfo8, {
							BackgroundTransparency = 1
						})
					end
				end)
			else
				tintFish(stoneColor, tweenInfo)
				object.fx:SpawnShake(reel_bar, 0.5, 0.6, 0.01, true)
			end
		end

		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active or object.isPaused then
				return
			end

			if flag then
				object:AddProgress((config.PetrifiedProgressPerSecond or 10) * p2)
			else
				if v then
					if v == "Golden" then
						if object.onbar then
							local v4 = config.GoldenProgressMultiplier * p2
							object:AddProgress(v4)
							idolFill = math.clamp(idolFill + v4 * config.FillPerGoldenProgress, 0, 1)
						end
					elseif object.onbar then
						local v4 = config.PurpleProgressLoss * p2
						object:AddProgress(-v4)
						idolFill = math.clamp(idolFill - v4 * config.DrainPerPurpleLoss, 0, 1)
					else
						object:AddProgress(config.PurpleProgressPerSecond * p2)
					end

					local now = os.clock()

					if v2 <= now then
						setGlow(nil)
					end
				else
					total += p2

					if number <= total then
						total = 0
						number = random:NextNumber(config.GlowIntervalMin, config.GlowIntervalMax)

						if random:NextNumber(0, 100) < config.GlowChance then
							v2 = os.clock() + config.GlowDuration
							setGlow(random:NextInteger(1, 2) == 1 and "Golden" or "Purple")
						end
					end
				end

				if idolFill >= 1 then
					petrify()
				end
			end

			total2 += (idolFill - total2) * math.min(p2 * 10, 1)
			bar.Size = UDim2.fromScale(total2, 1)

			if fullglow and not flag then
				fullglow.Transparency = 1 - total2 * 0.7
			end
		end))
	end
}
setmetatable(AncientIdolRod, module)
return AncientIdolRod