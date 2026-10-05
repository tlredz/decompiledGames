local ApollosSunshotClient = {}
game:GetService("UserInputService")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local world = ReplicatedStorage:WaitForChild("world")
local remoteEvent = Net:RemoteEvent("Apollo/SunshotBurn")

function ApollosSunshotClient.Morph(p, state, object)
	object.core.ui.StartStopAnim_Enabled = false
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
	task.spawn(function()
		local random = object:GetRandom(5)
		local character = game.Players.LocalPlayer.Character

		if not character then
			return
		end

		local animator = character:WaitForChild("Humanoid").Animator

		if not animator then
			return
		end

		local track = animator:LoadAnimation(script.shoot)
		track.Priority = Enum.AnimationPriority.Action4
		local bar = state.playerbar.Bar
		local fill = bar.Fill
		local position = state.Position
		local position2 = bar.Position
		local modifier = object:CreateModifier("barSize", "multiply")
		local config = p.config
		modifier.Value = 0.5
		state.Rotation = -50
		state.Position = position + UDim2.fromScale(0, 3)
		fill.Size = UDim2.fromScale(0, 1)
		local v = false
		local v2 = 0
		task.delay(0.15, function()
			TweenService:Create(state, TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Position = position,
				Rotation = 0
			}):Play()
		end)
		object:AddCleanupDelay(2)
		object.OnMinigameEnd:Once(function()
			TweenService:Create(state, TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = position + UDim2.fromScale(0, 3),
				Rotation = 50
			}):Play()
		end)
		local castProgressBoost = object.data and object.data.CastProgressBoost or 0

		if castProgressBoost > 0 then
			local v3 = math.clamp(castProgressBoost / 100, 0, 0.3)
			local v4 = math.clamp(castProgressBoost / 100 - 0.3, 0, 0.2)
			object:AddModifier("progressefficiency", "add", v3)

			if v4 > 0 then
				object:AddModifier("progressefficiency", "force_add", v4)
			end
		end

		if not object.ready then
			object.OnReady:Wait()
		end

		object.logicTweens:CreateAndPlay(
			modifier,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isDaytime()
			local cycle = world:FindFirstChild("cycle")
			return cycle and cycle.Value == "Day"
		end

		local count = 0

		local function shootArrow()
			if not object.active then
				return
			end

			if not object.onbar then
				script.Fail:Play()
				return
			end

			if v2 < 1 then
				return
			end

			v2 = 0
			fill.Size = UDim2.fromScale(0, 1)
			fx:PlaySound(script.Shoot, state, true)
			track:Play(0)
			object:AddProgress(config.ARROW_PROGRESS)
			modifier.Value = 0.9
			object.logicTweens:CreateAndPlay(
				modifier,
				TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Value = 1
				}
			)
			bar.Position = position2 + UDim2.fromScale(0, -0.2)
			object.logicTweens:CreateAndPlay(
				bar,
				TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Position = position2
				}
			)

			if random:NextNumber() * 100 <= config.BURN_CHANCE then
				task.spawn(function()
					remoteEvent:FireServer()
					fx:PlaySound(script.Burn, state, true)
					local burnEffect = state.fish.icon:FindFirstChild("BurnEffect")
					count += 1
					local v3 = count
					burnEffect.Visible = true
					task.delay(config.BURN_DURATION, function()
						if v3 == count then
							burnEffect.Visible = false
						end
					end)
					local modifier2 = object:CreateModifier("movementfactor", "multiply")
					local modifier3 = object:CreateModifier("moveIntervalFactor", "multiply")
					modifier2.Value = config.BURN_MOVE_SPEED
					modifier3.Value = 0.3
					object:WaitLogic(config.BURN_DURATION)

					if object.active then
						object.logicTweens:CreateAndPlay(modifier2, TweenInfo.new(0.5), {
							Value = 1
						})
						object.logicTweens:CreateAndPlay(modifier3, TweenInfo.new(0.5), {
							Value = 1
						})
						object:DelayLogic(0.5, function()
							modifier2:Destroy()
							modifier3:Destroy()
						end)
					else
						modifier2:Destroy()
						modifier3:Destroy()
					end
				end)
			end
		end

		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2: number)
			if not object.active then
				return
			end

			local CHARGE_RATE = v and config.CHARGE_RATE or 0

			if isDaytime() then
				CHARGE_RATE = math.max(CHARGE_RATE, config.DAYTIME_CHARGE_RATE)
			end

			if CHARGE_RATE > 0 then
				v2 = math.min(v2 + CHARGE_RATE * p2, 1)
				fill.Size = UDim2.fromScale(v2, 1)

				if v2 >= 1 then
					fill.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
				else
					fill.BackgroundColor3 = Color3.fromRGB(255, 164, 128)
				end
			end
		end))
		object.OnBarDirectionChange:Connect(function(p2)
			if p2 > 0 then
				v = true
				return
			end

			v = false
			shootArrow()
		end)

		if object.core.rod.CurrentInputDirection > 0 then
			v = true
		end
	end)
end

setmetatable(ApollosSunshotClient, module)
return ApollosSunshotClient