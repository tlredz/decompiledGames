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
	Name = "FesteringStrikesController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))

			if p2 == nil then
				v2:PlaySound(sounds.Kurourushi.FesteringStrikes["Hit" .. p], humanoidRootPart, game.SoundService.Effect)

				if instance == localPlayer.Character or instance2 == localPlayer.Character then
					CameraShaker.CurrentShaker:Shake(p >= 3 and CameraShaker.Presets.HeavyHit or CameraShaker.Presets.MediumHit)
				end
			else
				v2:PlaySound(sounds.Kurourushi.FesteringStrikes.FinalHit2, humanoidRootPart2, game.SoundService.Effect)
			end

			local v5 = {
				CFrame.new() * CFrame.Angles(0, 0, 0.2617993877991494),
				CFrame.new() * CFrame.Angles(0, 0, 2.530727415391778),
				CFrame.new() * CFrame.Angles(0, 0, -0.6108652381980153)
			}

			if not v5[p] then
				return
			end

			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(
				humanoidRootPart2.Position + createVector(0, 0.75, 0),
				humanoidRootPart.CFrame.LookVector
			)
			clone.CFrame *= v5[p]
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(101, 35, 44))
			clone.Slash.Squash = NumberSequence.new(-1 * (p2 and -2.5 or 1), -10)
			clone.Slash.Size = NumberSequence.new(2 * (p2 and 1.5 or 1), 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		Arms = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				local v5 = v2:PlaySound(
					sounds.Kurourushi.FesteringStrikes.Throw,
					humanoidRootPart,
					game.SoundService.Effect
				)
				local volume = v5.Volume
				v5.Volume = 0
				TweenService:Create(v5, TweenInfo.new(0.5), {
					Volume = volume
				}):Play()
			end

			v3:PlayArms(instance, animations.Kurourushi.FesteringStrikesArms, animations.Kurourushi.FesteringStrikes)
		end,
		Clash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(p, Color3.new(1, 1, 0.498039), 0.6)
			v2:Flash(instance, Color3.new(1, 1, 0.498039), 0.6)
			v2:PlaySound(sounds.Misc.Items.Clash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.Items.Clash.Attachment:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.9)

			for _, light in clone:GetChildren() do
				if light:IsA("PointLight") then
					TweenService:Create(light, TweenInfo.new(light:GetAttribute("Duration")), {
						Brightness = 0
					}):Play()
				else
					light:Emit(light:GetAttribute("EmitCount"))
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Slash = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Kurourushi.FesteringStrikes["Swing" .. p], humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Kurourushi.KurourushiSwing:Clone()
			clone.Weld.Part0 = humanoidRootPart
			local vertexColor = clone.Mesh.VertexColor
			clone.Mesh.VertexColor = clone.Mesh.VertexColor * 2

			if p == 1 then
				local clone2 = utils.Kurourushi.KurourushiSwing:Clone()
				clone2.Weld.Part0 = humanoidRootPart
				local vertexColor2 = clone2.Mesh.VertexColor
				clone2.Mesh.VertexColor = clone2.Mesh.VertexColor * 2
				clone2.Mesh.Scale = createVector(-0.25, -0.05, -0.25)
				clone2.Weld.C0 = CFrame.new(1.5, 0.15, 0) * CFrame.Angles(
					-0.1308996938995747,
					0.4363323129985824,
					-2.6179938779914944
				)
				TweenService:Create(
					clone2.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = CFrame.new(1.5, 0.15, 0) * CFrame.Angles(
							-0.1308996938995747,
							-2.6179938779914944,
							2.6179938779914944
						)
					}
				):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(-0.25, -0.25, -0.25),
					VertexColor = vertexColor2
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				clone2.Parent = workspace.Effects

				for _, child in clone2.SwingWindParticles:GetChildren() do
					child.RotSpeed = NumberRange.new(90, 180)
				end

				v2:PlayParticles(clone2)
				Debris:AddItem(clone2, 1)
				local clone3 = replicatedStorage.Utils.MeiMei.WindMesh2:Clone()
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone3.Transparency = 0.975
				clone3.Size = createVector(5, 2.5, 5)
				TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(20, 5, 20),
					Transparency = 1
				}):Play()
				TweenService:Create(
					clone3.Weld,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = clone3.Weld.C0 * CFrame.new(0, -0.25, 0) * CFrame.Angles(0, -3.12413936106985, 0)
					}
				):Play()
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 0.2)
				local clone4 = replicatedStorage.Utils.Kurourushi.KurourushiSwingThinner:Clone()
				clone4.Transparency = 0.75
				clone4.Mesh.Scale = createVector(0.2, 0.1, 0.2)
				clone4.Mesh.VertexColor = createVector(0, 0, 0)
				clone4.Weld.Part0 = humanoidRootPart
				clone4.Weld.C0 = clone2.Weld.C0
				clone4.Weld.C1 = CFrame.Angles(0, 3.141592653589793, 0)
				TweenService:Create(clone4.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					C0 = CFrame.Angles(-0.1308996938995747, -2.6179938779914944, 2.792526803190927)
				}):Play()
				TweenService:Create(clone4.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.255, 0.3, 0.255)
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 0.15)
				local clone5 = replicatedStorage.Utils.Kurourushi.SwirlMesh1:Clone()
				clone5.Transparency = 0.75
				clone5.Size = createVector(5, 2, 5)
				clone5.Weld.Part0 = humanoidRootPart
				clone5.Weld.C0 = clone2.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				TweenService:Create(clone5.Weld, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					C1 = CFrame.Angles(0, -3.0543261909900767, 0)
				}):Play()
				TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(20, 5, 20)
				}):Play()
				clone5.Parent = workspace.Effects
				Debris:AddItem(clone5, 0.2)
			elseif p == 2 then
				local clone2 = utils.Kurourushi.KurourushiSwing:Clone()
				clone2.Weld.Part0 = humanoidRootPart
				local vertexColor2 = clone2.Mesh.VertexColor
				clone2.Mesh.VertexColor = clone2.Mesh.VertexColor * 2
				clone2.Mesh.Scale = createVector(-0.225, -0.05, -0.225)
				clone2.Weld.C0 = CFrame.new(-1, 1, 0) * CFrame.Angles(0, 0.2617993877991494, -0.6108652381980153)
				TweenService:Create(
					clone2.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = CFrame.Angles(0, -2.6179938779914944, 0)
					}
				):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(-0.25, -0.25, -0.25),
					VertexColor = vertexColor2
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				clone2.Parent = workspace.Effects

				for _, child in clone2.SwingWindParticles:GetChildren() do
					child.RotSpeed = NumberRange.new(180, 360)
				end

				v2:PlayParticles(clone2)
				Debris:AddItem(clone2, 1)
				local clone3 = replicatedStorage.Utils.MeiMei.WindMesh2:Clone()
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone3.Transparency = 0.95
				clone3.Size = createVector(5, 2.5, 5)
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(22.5, 7.5, 22.5),
					Transparency = 1
				}):Play()
				TweenService:Create(
					clone3.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = clone3.Weld.C0 * CFrame.new(0, -0.325, 0) * CFrame.Angles(0, 4.71238898038469, 0)
					}
				):Play()
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 0.15)
				local clone4 = replicatedStorage.Utils.Kurourushi.KurourushiSwingThinner:Clone()
				clone4.Transparency = 0.75
				clone4.Mesh.Scale = createVector(0.225, 0.1, 0.225)
				clone4.Mesh.VertexColor = createVector(0, 0, 0)
				clone4.Weld.Part0 = humanoidRootPart
				clone4.Weld.C0 = clone2.Weld.C0
				clone4.Weld.C1 = CFrame.Angles(0, 3.141592653589793, 0)
				TweenService:Create(
					clone4.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = clone4.Weld.C1 * CFrame.Angles(0, -2.6179938779914944, 0)
					}
				):Play()
				TweenService:Create(clone4.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.255, 0.3, 0.255)
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 0.15)
				local clone5 = replicatedStorage.Utils.Kurourushi.SwirlMesh1:Clone()
				clone5.Transparency = 0.75
				clone5.Size = createVector(5, 2, 5)
				clone5.Weld.Part0 = humanoidRootPart
				clone5.Weld.C0 = clone2.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				TweenService:Create(clone5.Weld, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					C1 = CFrame.Angles(0, -3.0543261909900767, 0)
				}):Play()
				TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(20, 5, 20)
				}):Play()
				clone5.Parent = workspace.Effects
				Debris:AddItem(clone5, 0.2)
			elseif p == 3 and not p2 then
				clone.Mesh.Scale = createVector(-0.225, -0.05, -0.225)
				clone.Weld.C0 = CFrame.new(0.35, -0.1, 0) * CFrame.Angles(
					0.17453292519943295,
					-0.08726646259971647,
					2.530727415391778
				)
				TweenService:Create(
					clone.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = CFrame.Angles(0, -2.181661564992912, 0)
					}
				):Play()
				TweenService:Create(clone.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(-0.25, -0.25, -0.25),
					VertexColor = vertexColor
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				clone.Parent = workspace.Effects

				for _, child in clone.SwingWindParticles:GetChildren() do
					child.RotSpeed = NumberRange.new(360, 720)
				end

				v2:PlayParticles(clone)
				Debris:AddItem(clone, 1)
				local clone2 = replicatedStorage.Utils.MeiMei.WindMesh2:Clone()
				clone2.Weld.Part0 = humanoidRootPart
				clone2.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone2.Transparency = 0.9
				clone2.Size = createVector(5, 2.5, 5)
				TweenService:Create(clone2, TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(25, 10, 25),
					Transparency = 1
				}):Play()
				TweenService:Create(
					clone2.Weld,
					TweenInfo.new(0.175, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = clone2.Weld.C0 * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -4.71238898038469, 0)
					}
				):Play()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.175)
				local clone3 = replicatedStorage.Utils.Kurourushi.KurourushiSwingThinner:Clone()
				clone3.Transparency = 0.5
				clone3.Mesh.Scale = createVector(0.225, 0.1, 0.225)
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Weld.C0 = clone.Weld.C0
				clone3.Weld.C1 = CFrame.Angles(0, 3.141592653589793, 0)
				TweenService:Create(
					clone3.Weld,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = clone3.Weld.C1 * CFrame.Angles(0, -2.181661564992912, 0)
					}
				):Play()
				TweenService:Create(clone3.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Scale = createVector(0.255, 0.3, 0.255)
				}):Play()
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 0.15)
				local clone4 = replicatedStorage.Utils.Kurourushi.SwirlMesh1:Clone()
				clone4.Transparency = 0.75
				clone4.Size = createVector(5, 2, 5)
				clone4.Weld.Part0 = humanoidRootPart
				clone4.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				TweenService:Create(clone4.Weld, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					C1 = CFrame.Angles(0, -3.0543261909900767, 0)
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(20, 5, 20)
				}):Play()
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 0.2)
			end

			local festeringSword = instance.SetAssets:FindFirstChild("FesteringSword")

			if not festeringSword then
				return
			end

			local clone2 = utils.Kurourushi.CombatTrail:Clone()
			local model = Instance.new("Model")
			clone2.Parent = model
			model:ScaleTo(festeringSword:GetScale())
			Debris:AddItem(model, 0.1)
			clone2.Weld.Part0 = festeringSword.Union
			clone2.Parent = workspace.Effects
			clone2.Trail.FaceCamera = false
			task.wait(0.3)
			clone2.Trail.Enabled = false
			TweenService:Create(clone2, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
		end,
		Hit2 = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			task.spawn(function()
				local clone = utils.Kurourushi.KurourushiSwing:Clone()
				clone.Weld.Part0 = humanoidRootPart
				local vertexColor = clone.Mesh.VertexColor
				clone.Mesh.VertexColor = clone.Mesh.VertexColor * 2
				clone.Mesh.Scale = createVector(-0.225, -0.05, -0.225)
				clone.Weld.C0 = CFrame.new(0.35, -0.1, 0) * CFrame.Angles(
					0.17453292519943295,
					-0.08726646259971647,
					2.530727415391778
				)
				local cframe = CFrame.Angles(0, -2.181661564992912, 0)
				local tween = TweenService:Create(
					clone.Weld,
					TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = cframe
					}
				)
				local tween2 = TweenService:Create(
					clone.Mesh,
					TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Scale = createVector(-0.25, -0.25, -0.25),
						VertexColor = vertexColor
					}
				)
				local tween3 = TweenService:Create(
					clone,
					TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				)
				tween:Play()
				tween2:Play()
				tween3:Play()
				clone.Parent = workspace.Effects

				for _, child in clone.SwingWindParticles:GetChildren() do
					child.RotSpeed = NumberRange.new(360, 720)
					child.TimeScale = 0.1
				end

				v2:PlayParticles(clone)
				Debris:AddItem(clone, 3)
				local clone2 = replicatedStorage.Utils.MeiMei.WindMesh2:Clone()
				clone2.Weld.Part0 = humanoidRootPart
				clone2.Weld.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone2.Transparency = 0.9
				clone2.Size = createVector(5, 2.5, 5)
				local C0 = clone2.Weld.C0 * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -4.71238898038469, 0)
				local tween4 = TweenService:Create(
					clone2,
					TweenInfo.new(1.7499999999999998, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = createVector(25, 10, 25),
						Transparency = 1
					}
				)
				local tween5 = TweenService:Create(
					clone2.Weld,
					TweenInfo.new(1.7499999999999998, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = C0
					}
				)
				tween4:Play()
				tween5:Play()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 3)
				local clone3 = replicatedStorage.Utils.Kurourushi.KurourushiSwingThinner:Clone()
				clone3.Transparency = 0.5
				clone3.Mesh.Scale = createVector(0.225, 0.1, 0.225)
				clone3.Mesh.VertexColor = createVector(0, 0, 0)
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Weld.C0 = clone.Weld.C0
				clone3.Weld.C1 = CFrame.Angles(0, 3.141592653589793, 0)
				local C1 = clone3.Weld.C1 * CFrame.Angles(0, -2.181661564992912, 0)
				local tween6 = TweenService:Create(
					clone3.Weld,
					TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C1 = C1
					}
				)
				local tween7 = TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.255, 0.3, 0.255)
					}
				)
				local tween8 = TweenService:Create(clone3, TweenInfo.new(1.4999999999999998, Enum.EasingStyle.Linear), {
					Transparency = 1
				})
				tween6:Play()
				tween7:Play()
				tween8:Play()
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 3)
				local clone4 = replicatedStorage.Utils.Kurourushi.SwirlMesh1:Clone()
				clone4.Transparency = 0.75
				clone4.Size = createVector(5, 2, 5)
				clone4.Weld.Part0 = humanoidRootPart
				clone4.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				local tween9 = TweenService:Create(
					clone4.Weld,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						C1 = CFrame.Angles(0, -3.0543261909900767, 0)
					}
				)
				local tween10 = TweenService:Create(
					clone4,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						Size = createVector(20, 5, 20)
					}
				)
				tween9:Play()
				tween10:Play()
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 3)
				task.delay(0.5, function()
					tween:Cancel()
					tween2:Cancel()
					tween3:Cancel()
					tween4:Cancel()
					tween5:Cancel()
					tween6:Cancel()
					tween7:Cancel()
					tween8:Cancel()
					tween9:Cancel()
					tween10:Cancel()

					for _, child in clone.SwingWindParticles:GetChildren() do
						child.TimeScale = 1
					end

					TweenService:Create(
						clone.Weld,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C1 = cframe
						}
					):Play()
					TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Scale = createVector(-0.25, -0.25, -0.25),
							VertexColor = vertexColor
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					TweenService:Create(clone2, TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(25, 10, 25),
						Transparency = 1
					}):Play()
					TweenService:Create(
						clone2.Weld,
						TweenInfo.new(0.175, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = C0
						}
					):Play()
					TweenService:Create(
						clone3.Weld,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C1 = C1
						}
					):Play()
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.255, 0.3, 0.255)
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
						Transparency = 1
					}):Play()
					TweenService:Create(
						clone4.Weld,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							C1 = CFrame.Angles(0, -3.0543261909900767, 0)
						}
					):Play()
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Transparency = 1,
						Size = createVector(20, 5, 20)
					}):Play()
				end)
			end)

			if not instance.SetAssets:FindFirstChild("FesteringSword") then
				return
			end

			v2:Flash(parent, Color3.new(1, 1, 0.498039), 0.6)
			v2:PlaySound(sounds.Kurourushi.FesteringStrikes.FinalHit1, humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.Misc.Items.Clash.Attachment:Clone()
			clone.Parent = parent
			Debris:AddItem(clone, 1)

			for _, light in clone:GetChildren() do
				if light:IsA("PointLight") then
					TweenService:Create(light, TweenInfo.new(light:GetAttribute("Duration")), {
						Brightness = 0
					}):Play()
				else
					light.Color = ColorSequence.new(Color3.fromRGB(141, 49, 63), Color3.fromRGB(0, 0, 0))
					light:Emit(light:GetAttribute("EmitCount"))
				end
			end

			clone.ParticleEmitter.Enabled = true
			clone["spikes 1"].Enabled = true
			local rate = clone.ParticleEmitter.Rate
			local _ = clone.ParticleEmitter.Size
			CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(0.65)

			for i = 20, 0, -1 do
				local v5 = i / 20
				clone.ParticleEmitter.Rate = rate * v5
				clone["spikes 1"].Rate = clone["spikes 1"].Rate * v5
				task.wait(0.0325)
			end
		end,
		Hit3 = function(instance, instance2, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			local playSound = v2:PlaySound(
				p == 3 and sounds.Kurourushi.Chokehold.PunchHit1 or sounds.Kurourushi.Chokehold.PunchHit2,
				humanoidRootPart,
				game.SoundService.Effect
			)
			playSound.PlaybackSpeed = math.random(90, 110) / 100
			local v5 = math.random(140, 200) / 10
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.7
			clone.Position = instance2.Head.Position
			clone.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v5, v5, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.1)
		end,
		PunchSwing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlayArms(instance)

			if not v5 then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function ArmFlash(p2, color, p3)
				if p2.Transparency == 1 then
					return
				end

				v2:ArmFlash(p2, color, p3)
			end

			v2:PlaySound(
				sounds.Kurourushi.FesteringStrikes["PunchSwing" .. p],
				humanoidRootPart,
				game.SoundService.Effect
			)

			if p == 1 then
				ArmFlash(v5["Right Arm"], Color3.fromRGB(101, 35, 44), 0.25) -- equivalent call inferred; original call site unknown
				ArmFlash(instance["Right Arm"], Color3.fromRGB(101, 35, 44), 0.25) -- equivalent call inferred; original call site unknown
			elseif p == 2 then
				ArmFlash(v5["Left Arm"], Color3.fromRGB(101, 35, 44), 0.25) -- equivalent call inferred; original call site unknown
				ArmFlash(instance["Left Arm"], Color3.fromRGB(101, 35, 44), 0.25) -- equivalent call inferred; original call site unknown
				task.wait(0.2)
				local rightArm = v5["Right Arm"]
				local color3 = Color3.fromRGB(101, 35, 44)

				if rightArm.Transparency == 1 then
					return
				else
					v2:ArmFlash(rightArm, color3, 0.45)
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
	v = Knit.GetService("FesteringStrikesService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("KurourushiController")
end

return controller