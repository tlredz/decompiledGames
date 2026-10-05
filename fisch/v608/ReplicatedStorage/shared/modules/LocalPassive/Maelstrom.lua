local Maelstrom = {}
game:GetService("UserInputService")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local freeze = script.Freeze
local hold = script.Hold

function Maelstrom.Morph(p, instance, object)
	object.core.ui.StartStopAnim_Enabled = false
	object:Preload(script:GetChildren())
	task.spawn(function()
		local random = object:GetRandom(5)
		local localPlayer = game.Players.LocalPlayer
		local playerGui = localPlayer.PlayerGui
		local character = localPlayer.Character

		if not character then
			return
		end

		local animator = character:WaitForChild("Humanoid").Animator

		if not animator then
			return
		end

		local track = animator:LoadAnimation(script.shoot)
		track.Priority = Enum.AnimationPriority.Action4
		local over = playerGui:WaitForChild("over")
		local chargeBar = instance.playerbar.ChargeBar
		local frozen = instance.fish.icon.Frozen
		local bar = chargeBar.Bar
		local fill = bar.Fill
		local v = nil
		local v2 = nil
		local position = instance.Position
		local position2 = chargeBar.Position
		local modifier = object:CreateModifier("barSize", "multiply")
		object:CreateModifier("resilience", "multiply")
		modifier.Value = 0.5
		chargeBar.Position = position2 + UDim2.fromScale(0, 0.5)
		instance.Rotation = -50
		instance.Position = position + UDim2.fromScale(0, 3)
		fill.Size = UDim2.fromScale(0, 1)
		local flag = false
		local v3 = false
		task.delay(0.15, function()
			TweenService:Create(instance, TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Position = position,
				Rotation = 0
			}):Play()
		end)
		object:AddCleanupDelay(2)
		object.OnMinigameEnd:Once(function()
			TweenService:Create(instance, TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = position + UDim2.fromScale(0, 3),
				Rotation = 50
			}):Play()
		end)
		local count = 0
		local v4 = nil

		local function freeze_fish()
			count += 1
			local v5 = count
			local v6 = v3
			v3 = true
			fx:PlaySound(freeze, script, true)
			local maelstromFreeze = nil

			if v6 then
				maelstromFreeze = over:FindFirstChild("MaelstromFreeze")
			else
				frozen.Visible = true
			end

			if not maelstromFreeze then
				maelstromFreeze = script.MaelstromFreeze:Clone()
				p.reelTrove:Add(maelstromFreeze)
				maelstromFreeze.Parent = over
			end

			maelstromFreeze.ImageTransparency = 0.5

			if v4 then
				v4:Cancel()
				v4 = nil
			end

			v4 = object.logicTweens:Create(maelstromFreeze, TweenInfo.new(2), {
				ImageTransparency = 1
			})
			v4.Completed:Once(function()
				v4:Destroy()
				v4 = nil
			end)
			v4:Play()
			local integer = random:NextInteger(2, 4)
			object.frozenUntil = tick() + integer
			object:WaitLogic(integer)

			if count ~= v5 then
				return
			end

			v3 = false
			maelstromFreeze:Destroy()
			frozen.Visible = false
		end

		if not object.ready then
			object.OnReady:Wait()
		end

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
		object.logicTweens:Create(modifier, tweenInfo, {
			Value = 1
		}):Play()
		object.logicTweens:Create(chargeBar, tweenInfo, {
			Position = position2
		}):Play()
		object:DelayLogic(2, function()
			TweenService:Create(chargeBar.Label, TweenInfo.new(0.5), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end)

		local function onInputBegan()
			if flag then
				return
			end

			flag = true
			fill.BackgroundTransparency = 0
			fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hold.PlaybackSpeed = 1.4
			local tweenInfo2 = TweenInfo.new(random:NextInteger(20, 100) / 100, Enum.EasingStyle.Linear)
			hold.Playing = true
			local v5 = true

			while flag do
				if v2 then
					v2:Cancel()
					v2 = nil
				end

				if v then
					v:Cancel()
					v = nil
				end

				v2 = object.logicTweens:Create(hold, tweenInfo2, {
					PlaybackSpeed = v5 and 1.8 or 1.4
				})
				v2:Play()
				v = object.logicTweens:Create(fill, tweenInfo2, {
					Size = UDim2.fromScale(v5 and 1 or 0, 1)
				})
				v:Play()

				while task.wait() and not (v and v.Completed:Wait()) and flag do

				end

				if not flag then
					break
				end

				v5 = not v5
			end

			hold.Playing = false
		end

		local function onInputEnd()
			if not flag then
				return
			end

			flag = false

			if v2 then
				v2:Cancel()
				v2 = nil
			end

			if v then
				v:Cancel()
				v = nil
			end

			local clone = fill:Clone()
			local scale = clone.Size.X.Scale
			local v5 = scale >= 0.8

			if scale <= 0 then
				clone:Destroy()
				return
			end

			clone.BackgroundColor3 = v5 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 120, 120)
			clone.Parent = bar
			local v6 = object.logicTweens:Create(clone, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			})
			v6.Completed:Once(function()
				clone:Destroy()
				v6:Destroy()
			end)
			v6:Play()
			fill.Size = UDim2.fromScale(0, 1)
			chargeBar.Position = position2 + UDim2.fromScale(0, v5 and -0.2 or 0.2)
			chargeBar.Rotation = v5 and 3 or 0
			object.logicTweens:Create(
				chargeBar,
				TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Position = position2
				}
			):Play()
			object.logicTweens:Create(chargeBar, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Rotation = 0
			}):Play()

			if not v5 then
				script.Fail:Play()
				return
			end

			if object.onbar then
				fx:PlaySound(script.Shoot, instance, true)
				track:Play(0)
				object:AddProgress(15)

				if random:NextNumber() * 100 <= 25 then
					task.spawn(freeze_fish)
				end
			end

			modifier.Value = 0.9
			object.logicTweens:Create(
				modifier,
				TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Value = 1
				}
			):Play()
		end

		object.OnBarDirectionChange:Connect(function(p2)
			if p2 > 0 then
				onInputBegan()
			else
				onInputEnd()
			end
		end)

		if object.core.rod.CurrentInputDirection > 0 then
			onInputBegan()
		end

		task.spawn(function()
			while instance.Parent do
				instance.Maelring.Rotation += 0.5
				task.wait()
			end
		end)
	end)
end

setmetatable(Maelstrom, module)
return Maelstrom