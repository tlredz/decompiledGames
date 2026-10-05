local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "CrushingRushdownController"
})

function controller.KnitStart(_)
	local v4 = {
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v3:PlaySound(sounds.Mahito.CrushingRushdown.HairPull, instance, game.SoundService.Effect)
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
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic)

			for _, beam in instance:GetChildren() do
				if not beam:IsA("Beam") then
					continue
				end

				local curveSize1 = beam.CurveSize1
				beam.CurveSize1 = math.random(-20, 20)
				TweenService:Create(beam, tweenInfo, {
					CurveSize1 = curveSize1
				}):Play()
			end
		end,
		HairRetract = function(instance, instance2)
			local head = instance:FindFirstChild("Head")

			if not head then
				return
			end

			local clone = instance2:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.In)

			for _, beam in clone:GetChildren() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, tweenInfo, {
						CurveSize1 = math.random(-20, 20)
					}):Play()
				else
					TweenService:Create(beam, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = beam.Position + createVector(5, 0, 0)
					}):Play()
					local v5 = beam
					task.delay(0.35, function()
						TweenService:Create(v5, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Position = v5.Position - createVector(10, 0, 0)
						}):Play()
						task.wait(0.35)
						TweenService:Create(v5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = v5.Position + createVector(5, 0, 0)
						}):Play()
					end)
				end
			end

			local lastTime = tick()
			local _ = clone.CFrame

			repeat
				clone.CFrame = clone.CFrame:Lerp(head.CFrame, (tick() - lastTime) / 1)
				task.wait()
				local now = tick()
			until lastTime + 1 < now or not head.Parent
		end,
		Hair = function(instance, instance2, attachment)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local leftLeg = instance2:FindFirstChild("Left Leg")

			if not leftLeg then
				return
			end

			local clone = utils.Mahito.Worms.HairEnd:Clone()
			clone.Anchored = false
			Debris:AddItem(clone, 0.7)
			clone.Parent = workspace.Effects
			local weld = Instance.new("Weld", clone)
			weld.Part1 = clone
			weld.Part0 = leftLeg
			v3:PlaySound(sounds.Mahito.CrushingRushdown.Leap, humanoidRootPart, game.SoundService.Effect)
			local clone2 = utils.Mahito.Worms.HairGrab:Clone()
			clone2.Weld.Part0 = leftLeg
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.7)
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic)

			for _, beam in clone:GetChildren() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Attachment0 = attachment
				local curveSize1 = beam.CurveSize1
				beam.CurveSize1 = math.random(-50, 50)
				TweenService:Create(beam, tweenInfo, {
					CurveSize1 = curveSize1
				}):Play()
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Ram = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.CrushingRushdown.Leap, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Crush2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.Dash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			repeat
				task.wait()
			until not p.Parent

			if clone.Parent then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Wind, humanoidRootPart, game.SoundService.Effect)

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Throw, humanoidRootPart, game.SoundService.Effect)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CrushingRushdownService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller