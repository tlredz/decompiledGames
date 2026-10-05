local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "DreamsController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(p)
			if localPlayer.Character ~= p then
				return
			end

			v3:Flash(p, Color3.new(0, 0, 0), 0.5)
			local followTakada = workspace.Effects:FindFirstChild("FollowTakada")

			if followTakada and localPlayer.Character == p then
				local track = followTakada.Humanoid:LoadAnimation(animations.Todo.TakadaJoint.Emote)
				track:Play(nil, nil, 3)
				task.wait(1.4)
				track:Stop()
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer == p then
				local clone = utils.Todo.HeavyHit:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				clone.Sparks:Emit(50)
				clone.Ring:Emit(2)
				clone.Wind2:Emit(7)
				clone.Hearts:Emit(40)
				TweenService:Create(clone.PointLight, TweenInfo.new(0.75), {
					Brightness = 0
				}):Play()
			else
				local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
				clone.Wind.Color = clone.Sparks.Color
				clone.Wind2.Color = clone.Sparks.Color
				clone.Sparks:Emit(50)
				clone.Wind:Emit(7)
				clone.Wind2:Emit(7)
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer == p then
				local clone = utils.Todo.HeavyHit:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				clone.Sparks:Emit(50)
				clone.Ring:Emit(2)
				clone.Wind2:Emit(7)
				clone.Hearts:Emit(40)
				TweenService:Create(clone.PointLight, TweenInfo.new(0.75), {
					Brightness = 0
				}):Play()
			else
				local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)
				clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
				clone.Wind.Color = clone.Sparks.Color
				clone.Wind2.Color = clone.Sparks.Color
				clone.Sparks:Emit(50)
				clone.Wind:Emit(7)
				clone.Wind2:Emit(7)
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				local clone = utils.Hakari.Barrage.ColorArm:Clone()
				clone.Color = Color3.fromRGB(255, 170, 255)
				clone.Attachment.Flames.Color = ColorSequence.new(Color3.fromRGB(255, 170, 255))
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new((p == 1 or p == 3) and 3 or -3, 1, 0) * CFrame.Angles(
					1.5707963267948966,
					math.rad((p == 1 or p == 3) and 10 or -10),
					0
				)
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
					CFrame = clone.CFrame + humanoidRootPart.CFrame.LookVector * 12
				}):Play()
				clone.Parent = workspace.Effects
				clone.Attachment.Flames:Emit(7)
				clone.Attachment.Wind:Emit(2)
				local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
				clone2.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + clone.Position + humanoidRootPart.CFrame.LookVector * 8
				clone2.Size = createVector(0, 0, 1)
				clone2.Parent = clone
				TweenService:Create(clone2, TweenInfo.new(0.15), {
					Size = createVector(4, 4, 0),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.2)
			end

			if p == 3 then
				local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
				clone.Parent = workspace.Effects
				clone.Wind:Emit(20)
				clone.PointLight:Destroy()
				clone.Back1.Back:Emit(1)
				clone.Back2.Back:Emit(1)
				TweenService:Create(clone.Back1, TweenInfo.new(2), {
					CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
				}):Play()
				TweenService:Create(clone.Back2, TweenInfo.new(2), {
					CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
				}):Play()
				Debris:AddItem(clone, 3)
			end

			v3:PlaySound(sounds.Hakari.EnergySurge.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
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
	v = Knit.GetService("DreamsService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller