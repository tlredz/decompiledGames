local CupidSBow = {}
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local hold = script.Hold

function CupidSBow.Morph(_, instance, object)
	object.core.ui.StartStopAnim_Enabled = false
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
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
		playerGui:WaitForChild("over")
		local chargeBar = instance.playerbar.ChargeBar
		local _ = instance.fish.icon
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
			object.logicTweens:Create(chargeBar.Label, TweenInfo.new(0.5), {
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
			local tweenInfo2 = TweenInfo.new(
				(math.clamp((count - 1) / 5, 0, 2) + 1) * random:NextInteger(15, 40) / 100,
				Enum.EasingStyle.Linear
			)
			hold.Playing = true
			local v3 = true

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
					PlaybackSpeed = v3 and 2 or 1.6
				})
				v2:Play()
				v = object.logicTweens:Create(fill, tweenInfo2, {
					Size = UDim2.fromScale(v3 and 1 or 0, 1)
				})
				v:Play()

				while task.wait() and not (v and v.Completed:Wait()) and flag do

				end

				if not flag then
					break
				end

				if v3 then
					object:WaitLogic(UserInputService:GetLastInputType() == Enum.UserInputType.Touch and 0.1 or 0.05)
				end

				if not flag then
					break
				end

				v3 = not v3
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
			local v3 = scale >= 0.8

			if scale <= 0 then
				clone:Destroy()
				return
			end

			clone.BackgroundColor3 = v3 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 120, 120)
			clone.Parent = bar
			local v4 = object.logicTweens:Create(clone, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			})
			v4.Completed:Once(function()
				clone:Destroy()
				v4:Destroy()
			end)
			v4:Play()
			fill.Size = UDim2.fromScale(0, 1)
			chargeBar.Position = position2 + UDim2.fromScale(0, v3 and -0.2 or 0.2)
			chargeBar.Rotation = v3 and 3 or 0
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

			if v3 then
				count = 0

				if object.onbar then
					fx:PlaySound(script.Shoot, instance, true)
					track:Play(0)
					object:AddProgress(7)
				end

				modifier.Value = 0.9
				object.logicTweens:Create(
					modifier,
					TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Value = 1
					}
				):Play()
			else
				script.Fail:Play()
				count += 1
			end
		end

		object.OnBarDirectionChange:Connect(function(p)
			if p > 0 then
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
				instance.playerbar.Heart.Size = UDim2.fromScale(1, 1.8)
				TweenService:Create(instance.playerbar.Heart, TweenInfo.new(0.5), {
					Size = UDim2.fromScale(1, 1.4)
				}):Play()
				task.wait(0.75)
			end
		end)
	end)
end

setmetatable(CupidSBow, module)
return CupidSBow