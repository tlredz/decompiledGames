local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "CursedBudsController"
})
local v4 = { Color3.fromRGB(86, 66, 54), Color3.fromRGB(76, 60, 51), Color3.fromRGB(86, 60, 51) }

function controller.KnitStart(_)
	local v5 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.CursedBuds.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Appear = function(instance, folder, object)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder
			local color = v4[math.random(1, #v4)]
			local scale = folder:GetScale()
			local v7 = folder:GetPivot() * CFrame.new(0, -6.65 * scale, 0)
			task.spawn(function()
				local v8 = math.random() * 3.141592653589793 * 2

				for i = 1, 4 do
					local v9 = v8 + (i - 1) / 4 * 3.141592653589793 * 2
					local v10 = (3 + math.random() * 2) * scale
					local v11 = v7 + Vector3.new(math.cos(v9) * v10, 0, math.sin(v9) * v10) + createVector(0, 1, 0)
					local raycastResult = workspace:Raycast(v11.Position, createVector(0, -15, 0), _G.MapParams)

					if not raycastResult then
						continue
					end

					local clone = replicatedStorage.Utils.Hanami.bud1:Clone()
					clone.Parent = workspace.Effects
					task.delay(0.7, function()
						clone.Parent = folder
					end)
					clone:PivotTo(CFrame.new(raycastResult.Position) * CFrame.Angles(0, math.random(-360, 360), 0))
					clone:ScaleTo(2.584 + scale / 2)
					Debris:AddItem(clone, 10)
					v2:DustBreak(raycastResult.Position + createVector(0, 1, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
					local track = clone.AnimationController:LoadAnimation(animations.Hanami.CursedBudsTreeSmall)
					track:Play()
					track:GetMarkerReachedSignal("Loop"):Connect(function(timePosition)
						track.TimePosition = timePosition
					end)

					for _, part in clone:GetDescendants() do
						if not (part:IsA("BasePart") and part.Transparency == 0 and part.Color == Color3.fromRGB(
							84,
							72,
							47
						)) then
							continue
						end

						for _, child in particleDissipationHolder:GetChildren() do
							local clone2 = child:Clone()
							clone2.Shape = Enum.ParticleEmitterShape.Box
							clone2.Size = NumberSequence.new({
								NumberSequenceKeypoint.new(0, part.Size.X, 0),
								NumberSequenceKeypoint.new(1, part.Size.X, 0)
							})
							clone2.Parent = part
						end

						part.Color = color
					end
				end
			end)
			v2:DustBreak(v7.Position + createVector(0, 1, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Hanami.CursedBuds.Appear, folder.HumanoidRootPart, game.SoundService.Effect)

			for _, part in folder:GetDescendants() do
				if part:GetAttribute("Smoke") then
					for _, child in particleDissipationHolder:GetChildren() do
						local clone = child:Clone()
						clone.Shape = Enum.ParticleEmitterShape.Box
						clone.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, part.Size.X, 0),
							NumberSequenceKeypoint.new(1, part.Size.X, 0)
						})
						clone.Parent = part
					end
				end

				if not (part:IsA("BasePart") and part.Color == Color3.fromRGB(84, 72, 47)) then
					continue
				end

				part.Color = color
			end

			folder:ScaleTo(0.25)
			folder:PivotTo(folder:GetPivot() * CFrame.new(0, -1.6625, 0))
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.25
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				folder:ScaleTo(numberValue.Value)
				folder:PivotTo(v7 * CFrame.new(0, 6.65 * numberValue.Value, 0))
			end)
			TweenService:Create(numberValue, TweenInfo.new(0.65), {
				Value = scale
			}):Play()
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = 0.923 * scale
			numberValue2:GetPropertyChangedSignal("Value"):Connect(function()
				folder.Model:ScaleTo(numberValue2.Value)
			end)
			task.delay(0.25, function()
				TweenService:Create(numberValue2, TweenInfo.new(1), {
					Value = 1.25 * scale
				}):Play()
				TweenService:Create(folder.stem4.Mouth.PartRoot, TweenInfo.new(0.5), {
					C0 = CFrame.new(0, 1.65 * scale, 0)
				}):Play()
			end)

			while object and object.Parent do
				task.wait(0.02)
				local target = v3:GetTarget()
				local v8

				if target == nil then
					v8 = v3:GetMouseTarget(300)
				else
					v8 = target.PrimaryPart.Position
				end

				object:FireServer(v8)
			end

			TweenService:Create(numberValue2, TweenInfo.new(0.85), {
				Value = 0.923 * scale
			}):Play()
		end,
		Interp = function(instance, object)
			local playSound = v2:PlaySound(
				sounds.Hanami.BudShot.Throw,
				object.HumanoidRootPart,
				game.SoundService.Effect
			)
			playSound.PlaybackSpeed = math.random(90, 110) / 100
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = instance.CFrame * CFrame.new(0, 0, -1.5 * object:GetScale())
			clone.Size = createVector(0, 0, 1.25)
			clone.Parent = workspace.Effects
			clone.Transparency = 0.5
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(8.75, 8.75, 0),
				Position = clone.Position - instance.CFrame.LookVector * -2,
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (200 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local playSound = v2:PlaySound(
				sounds.Hanami.BudShot[`Hit{math.random(1, 2)}`],
				humanoidRootPart,
				game.SoundService.Effect
			)
			playSound.PlaybackSpeed = math.random(90, 110) / 100
			v2:Flash(instance, Color3.new(1, 1, 1))
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hanami.DefenseResponse.Hit2, humanoidRootPart, game.SoundService.Effect)
		end,
		Disappear = function(_, folder)
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			v2:PlayParticles(folder)
			v2:PlaySound(sounds.Hanami.CursedBuds.Disappear, folder.HumanoidRootPart, game.SoundService.Effect)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CursedBudsService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller