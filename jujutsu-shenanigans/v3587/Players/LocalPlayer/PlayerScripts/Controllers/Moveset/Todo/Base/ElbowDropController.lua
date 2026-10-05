local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = ReplicatedStorage.Utils
local sounds = ReplicatedStorage.Sounds
local _ = ReplicatedStorage.Animations
local _ = workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer
local Knit = require(ReplicatedStorage.Knit.Knit)
require(ReplicatedStorage.Modules.EffectUtils)
local CameraShaker = require(ReplicatedStorage.Modules.CameraShaker)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ElbowDropController"
})

local function getAngle(p: number)
	return (math.rad(math.random(1, 3) * p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function basedOnSpeed(min: number, max: number, magnitude: number, p: number, flag: boolean?)
	return (math.clamp(math.lerp(min, max, flag and 1 - magnitude / p or magnitude / p), min, max))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getArcValue(value: number, max: number, p: number)
	if max <= 0 then
		return 0
	end

	local v4 = math.clamp(value, 0, max)
	return p * 4 / max ^ 2 * v4 * (max - v4)
end

local function dustTrail(instance, duration: number, cframe: CFrame?)
	local humanoidRootPart

	if instance then
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
	else
		humanoidRootPart = nil
	end

	if not (humanoidRootPart and humanoidRootPart.Parent) then
		return
	end

	local clone = utils.Misc.SmokeTrail:Clone()
	clone.CFrame = humanoidRootPart.CFrame * (cframe or CFrame.identity)
	clone.Parent = workspace.Effects
	Debris:AddItem(clone, duration + 0.6)
	local v4 = v:GetCharacterHeight(instance) * 2

	if cframe then
		clone.Dash.Smoke.Enabled = true
		TweenService:Create(clone.Dash.Smoke, TweenInfo.new(duration), {
			Rate = 0
		}):Play()
		local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, 1, 0) * -v4, _G.MapParams)

		if raycastResult then
			clone.Position = raycastResult.Position
			clone.Dash.Smoke:Emit(15)
		end
	end

	local clone2 = nil
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not (clone and clone.Parent) then
			return
		end

		local position = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(
			position + createVector(0, 1, 0),
			createVector(0, 1, 0) * -v4,
			_G.MapParams
		)

		if raycastResult then
			if cframe then
				clone.Dash.Smoke.Enabled = true
			end

			clone.CFrame = humanoidRootPart.CFrame * (cframe or CFrame.identity) - position + raycastResult.Position
			clone.Velocity = humanoidRootPart.AssemblyLinearVelocity

			if clone2 then
				if clone2.Color.Keypoints[1].Value ~= raycastResult.Instance.Color then
					clone2.Enabled = false
					clone2 = clone2:Clone()
					clone2.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone2.Enabled = true
					clone2.Parent = clone
				end
			else
				clone2 = clone.Smoke
				clone2.Color = ColorSequence.new(raycastResult.Instance.Color)
				clone2.Enabled = true
			end
		else
			clone.Dash.Smoke.Enabled = false

			if clone2 then
				clone2.Enabled = false
			end
		end
	end)
	task.delay(duration, function()
		renderSteppedConnection:Disconnect()

		if not (clone and clone.Parent) then
			return
		end

		if clone2 then
			clone2.Enabled = false
		end

		clone.Dash.Smoke.Enabled = false
	end)
	return clone
end

function controller.KnitStart(_)
	local v4 = {
		Hit = function(p, instance, flag: boolean?)
			local humanoidRootPart

			if instance then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
			end

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.M1.Hit2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(flag and CameraShaker.Presets.MediumHit or CameraShaker.Presets.HeavyHit)
			end
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = humanoidRootPart.CFrame.LookVector * 3 - createVector(0, 5, 0)

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 100000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					local v6 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end

			TweenService:Create(p2, TweenInfo.new(0.5), {
				P = 100000
			}):Play()

			repeat
				p2.Position = p.Position - v5
				task.wait()
			until not (p2.Parent and p)
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(0.333333, 0.666667, 1))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(0.333333, 0.666667, 1))
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v3:DustBreak(position + createVector(0, 1, 0), createVector(0, 1, 0), 13, 15, 0.4, 1)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Woah = function(p, p2)
			if localPlayer.Character == p or localPlayer.Character == p2 then
				v3:PlaySound(sounds.Todo.Boom, workspace, game.SoundService.Effect)
				local clone = utils.Todo.Woah:Clone()
				clone.ImageLabel.Image = "rbxassetid://73458769859093"
				clone.Parent = localPlayer.PlayerGui
				Debris:AddItem(clone, 1)
				TweenService:Create(clone.ImageLabel, TweenInfo.new(1), {
					ImageTransparency = 1
				}):Play()
			end
		end,
		Force = function(instance, instance2)
			local humanoidRootPart

			if instance then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
			else
				humanoidRootPart = nil
			end

			if not (humanoidRootPart and humanoidRootPart.Parent and instance2 and instance2.Parent) then
				return
			end

			local steppedConnection = nil
			local renderSteppedConnection = nil
			local v5 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
			instance2.Velocity = v5 * instance2.Velocity.Magnitude
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if not (instance2 and instance2.Parent) then
					steppedConnection:Disconnect()
					return
				end

				local position = humanoidRootPart.Position
				local v6 = instance2.Velocity * dt + v5 * 2

				if workspace:Blockcast(CFrame.new(position), humanoidRootPart.Size, v6, _G.MapParams) then
					instance2.Velocity = createVector(0, 0, 0)
				end
			end)
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not (instance and instance.Parent and instance2 and instance2.Parent) then
					renderSteppedConnection:Disconnect()
					return
				end

				local position = humanoidRootPart.Position
				instance:PivotTo((CFrame.lookAt(position, position + v5)))
			end)
		end,
		SlideStart = function(instance, instance2)
			local humanoidRootPart

			if instance then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
			end

			if not (humanoidRootPart and humanoidRootPart.Parent and instance2 and instance2.Parent) then
				return
			end

			local magnitude = instance2.Velocity.Magnitude
			local clone = ReplicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			local v5 = v3:PlaySound(sounds.Gojo.TeleportDrag, humanoidRootPart, SoundService.Effect)
			local v6 = dustTrail(instance, 1.5, CFrame.new(0, 0, 1) * CFrame.Angles(0, -1.5707963267948966, 0))
			v5.PlaybackSpeed = math.clamp(math.lerp(1.15, 1.4, 1 - magnitude / 85 or magnitude / 85), 1.15, 1.4)
			v5.Volume *= 0.7

			while humanoidRootPart and humanoidRootPart.Parent and not (instance2.Velocity.Magnitude < 10) do
				local magnitude2 = instance2.Velocity.Magnitude
				local v7 = basedOnSpeed(0.7, 1.6, magnitude2, 85, false) -- equivalent call inferred; original call site unknown
				local v8 = basedOnSpeed(2, 4, magnitude2, 85, false) -- equivalent call inferred; original call site unknown
				local v9 = basedOnSpeed(2, 6, magnitude2, 85, false) -- equivalent call inferred; original call site unknown
				v3:DustBreak(humanoidRootPart.Position, createVector(0, 1, 0), v8, v9, 0.2, v7)
				task.wait(0.2)

				if not (instance2 and instance2.Parent) then
					break
				end
			end

			if v6 and v6.Parent then
				v6:Destroy()
			end

			if v5 and v5.Parent then
				v5:Destroy()
			end
		end,
		SlideKnockback = function(instance, instance2, instance3, p: number, p2: number)
			local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart") or nil
			local humanoidRootPart2

			if instance2 then
				humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart") or nil
			else
				humanoidRootPart2 = nil
			end

			if not (humanoidRootPart and humanoidRootPart.Parent and humanoidRootPart2 and humanoidRootPart2.Parent) then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Todo.SlideKick.Slide, humanoidRootPart, SoundService.Effect)
			v3:PlaySound(sounds.Todo.SlideKick.Kick1, humanoidRootPart2, SoundService.Effect)
			local ancestryChangedConnection = nil
			local ancestryChangedConnection2 = nil
			local v5 = workspace:GetServerTimeNow() - p2
			local total = 0
			local v6 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)
			local v7 = math.clamp(math.lerp(4, 8, v6.Magnitude / 90), 4, 8)
			local v8 = math.max(0, p - v5)
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if not (humanoidRootPart and humanoidRootPart.Parent and humanoidRootPart2 and humanoidRootPart2.Parent) then
					return
				end

				total += dt
				v6 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)
				local arcValue = getArcValue(total, v8, v7) -- equivalent call inferred; original call site unknown
				local v12 = arcValue + 2.5
				local v13 = CFrame.new(humanoidRootPart.Position + createVector(0, 1, 0) * v12) * CFrame.Angles(
					math.rad(math.random(1, 3) * dt),
					math.rad(math.random(1, 3) * dt),
					(math.rad(math.random(1, 3) * dt))
				)

				for _, part in instance2:GetChildren() do
					if not (part:IsA("BasePart") and part:GetAttribute("D_CC") and part.CanCollide) then
						continue
					end

					part.CanCollide = false
				end

				humanoidRootPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart2.AssemblyAngularVelocity = createVector(0, 0, 0)
				instance2:PivotTo(v13)
			end)

			local function cleanupGrab()
				ancestryChangedConnection:Disconnect()
				ancestryChangedConnection2:Disconnect()
				heartbeatConnection:Disconnect()

				if humanoidRootPart2 and humanoidRootPart2.Parent then
					for _, part in instance2:GetChildren() do
						if not part:IsA("BasePart") or not part:GetAttribute("D_CC") or part.CanCollide then
							continue
						end

						part.CanCollide = true
					end

					humanoidRootPart2.AssemblyLinearVelocity = createVector(0, 0, 0)
					humanoidRootPart2.AssemblyAngularVelocity = createVector(0, 0, 0)
				end
			end

			ancestryChangedConnection2 = instance2.AncestryChanged:Once(cleanupGrab)
			ancestryChangedConnection = instance3.AncestryChanged:Once(cleanupGrab)
		end,
		SlideKick = function(instance, instance2)
			if localPlayer == Players:GetPlayerFromCharacter(instance) or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart") or nil
			local humanoidRootPart2

			if instance2 then
				humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart") or nil
			end

			if not (humanoidRootPart and humanoidRootPart.Parent and humanoidRootPart2 and humanoidRootPart2.Parent) then
				return
			end

			local cFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			local cFrame2 = CFrame.new(humanoidRootPart2.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = cFrame2
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.4), {
				Size = createVector(12, 12, 0),
				Transparency = 1,
				Position = clone.Position + createVector(0, 2, 0)
			}):Play()
			Debris:AddItem(clone, 0.4)
			local clone2 = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone2.Position = humanoidRootPart2.Position
			clone2.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone2.Wind.Color = clone2.Sparks.Color
			clone2.Wind2.Color = clone2.Sparks.Color
			clone2.Sparks.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.165, 1, 0.2),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone2.Sparks.Speed = NumberRange.new(10, 30)
			clone2.Wind2.Size = NumberSequence.new(15)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 1)
			clone2.Sparks:Emit(30)
			clone2.Wind2:Emit(7)
			local clone3 = ReplicatedStorage.Utils.Itadori.RushWind:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 2)
			clone3.Dust:Emit(7)
			clone3.Ring:Emit(7)
			local clone4 = utils.Itadori.Shock:Clone()
			clone4.CFrame = cFrame
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone4, 0.2)
			task.delay(0.1, function()
				local clone5 = utils.Itadori.Shock:Clone()
				clone5.CFrame = cFrame
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone5, 0.2)
			end)
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Todo.SlideKick.Kick2, humanoidRootPart2, SoundService.Effect)
			v3:PlaySound(sounds.Ryu.SecondHelping.Hit, humanoidRootPart2, SoundService.Effect)
			v3:PlaySound(sounds.Todo.SlideKick.WhooshKick2, humanoidRootPart, SoundService.Effect)
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetController("HandicapController")
	v2 = Knit.GetService("ElbowDropService")
	v3 = Knit.GetController("FXController")
end

return controller