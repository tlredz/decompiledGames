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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "FurnaceArrowController"
})

function controller.KnitStart(_)
	local v3 = {
		HotHands = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Heian.FireArrow.Hands, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Heian.FlameArrow.Hands:Clone()
			clone.LA.Weld.Part1 = instance["Left Arm"]
			clone.RA.Weld.Part1 = instance["Right Arm"]
			clone.Parent = parent
		end,
		Clap = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local hands = parent:FindFirstChild("Hands")

			if hands then
				for _, child in hands.LA.startup:GetChildren() do
					child.Enabled = false
				end

				for _, child in hands.RA.startup:GetChildren() do
					child.Enabled = false
				end

				for _, child in hands.LA.fire:GetChildren() do
					child.Enabled = true
				end

				for _, child in hands.RA.fire:GetChildren() do
					child.Enabled = true
				end

				for _, child in hands.LA.Beam:GetChildren() do
					child.Enabled = true
				end

				TweenService:Create(
					v2:PlaySound(sounds.Heian.FireArrow.FlameIdle, hands.RA, game.SoundService.Effect),
					TweenInfo.new(3),
					{
						Volume = 1
					}
				):Play()
			end

			local clone = utils.Heian.FlameArrow.Clap:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			Debris:AddItem(clone, 2)
			clone.Parent = parent

			for _, child in clone.C1:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v2:PlaySound(sounds.Heian.FireArrow.Clap, humanoidRootPart, game.SoundService.Effect)
		end,
		Clap2 = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.FlameArrow.Clap:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			Debris:AddItem(clone, 2)
			clone.Parent = parent

			for _, child in clone.C2:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(2)
			end

			v2:PlaySound(sounds.Heian.FireArrow.Clap, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.2)

			if instance:GetAttribute("Moveset") ~= "Heian" then
				return
			end

			v2:PlaySound(sounds.Heian.FireArrow.Voice, humanoidRootPart, game.SoundService.Voice)
		end,
		Arrow = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local hands = parent:FindFirstChild("Hands")

			if hands then
				for _, child in hands.LA.fire:GetChildren() do
					child.Enabled = false
				end

				for _, child in hands.RA.fire:GetChildren() do
					child.Enabled = false
				end

				for _, child in hands.LA.Beam:GetChildren() do
					child.Enabled = false
				end
			end

			local clone = utils.Heian.FlameArrow.Arrow:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = parent
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

			for _, child in clone.Beam:GetChildren() do
				TweenService:Create(child, tweenInfo, {
					Brightness = 50
				}):Play()
			end

			TweenService:Create(clone.light.SpotLight, TweenInfo.new(0.4), {
				Brightness = 2
			}):Play()
			TweenService:Create(clone.Ground.PointLight, TweenInfo.new(1), {
				Brightness = 2
			}):Play()
			v2:PlaySound(sounds.Heian.FireArrow.Arrow, humanoidRootPart, game.SoundService.Effect)

			if instance:GetAttribute("Moveset") ~= "Heian" then
				return
			end

			v2:PlaySound(sounds.Heian.FireArrow.FugaVoice, humanoidRootPart, game.SoundService.Voice)
		end,
		Fire = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local hands = instance2:FindFirstChild("Hands")

			if hands then
				hands:Destroy()
			end

			local arrow = instance2:FindFirstChild("Arrow")

			if arrow then
				for _, descendant in arrow:GetDescendants() do
					if not (descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("SpotLight") or descendant:IsA("PointLight")) then
						continue
					end

					descendant.Enabled = false
				end

				local ground = arrow.Ground
				ground.Parent = humanoidRootPart
				Debris:AddItem(ground, 2)
			end

			local clone = utils.Heian.FlameArrow.Shot:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			Debris:AddItem(clone, 2)
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v2:PlaySound(sounds.Heian.FireArrow.Fire, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance)
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
						{ cFrame + cFrame.LookVector * (192 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Burn = function(self)
			local clone = utils.Heian.FlameArrow.explode:Clone()
			clone.Startup.Position = self
			clone.boom.Position = self
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, emitter in clone.Startup:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = true
				local v4 = emitter
				task.delay(emitter:GetAttribute("EmitDuration"), function()
					v4.Enabled = false
				end)
			end

			v2:PlaySound(sounds.Heian.FireArrow.Shockwave, clone.Startup, game.SoundService.Effect)
			task.wait(0.4)

			for _, emitter in clone.boom.Attachment:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				local v4 = emitter
				task.delay(0.5, function()
					v4.Enabled = false
				end)
			end

			local clone2 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone2.Position = self
			clone2.Decal.Transparency = 0
			clone2.Mesh.Scale = createVector(2, 50, 2)
			clone2.Parent = clone
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(80, 40, 80),
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Scale = createVector(60, 10, 60)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 1)
			local clone3 = utils.Itadori.FireArrow.Burn:Clone()
			clone3.Parent = clone
			clone3.Position = self
			clone3.Center.Wind2:Emit(25)
			clone3.Flames:Emit(200)
			TweenService:Create(clone3, TweenInfo.new(0.75), {
				Size = createVector(0, 250, 0),
				CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone3.Beam, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(clone3.Lines, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			v2:PlaySound(sounds.Heian.FireArrow.Explode, clone3, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - self).Magnitude < 300 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
			end
		end,
		Finisher = function(instance)
			if not instance.HumanoidRootPart then
				return
			end

			v2:Burn(instance)

			for _, part in instance:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Damage.Flames:Clone()
				clone.Parent = part
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("FurnaceArrowService")
	v2 = Knit.GetController("FXController")
end

return controller