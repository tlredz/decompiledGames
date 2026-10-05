local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule)
require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "Mokou3Controller"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.M.Scorchrise, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Misc.M.Mokou3Voice, humanoidRootPart, game.SoundService.Effect)
		end,
		Pillar = function(folder, instance)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone.Parent = workspace.Effects
			local clone2 = utils.Misc.M.Slash.PointLight:Clone()
			clone2.Parent = clone
			TweenService:Create(clone2, TweenInfo.new(1), {
				Brightness = 0,
				Color = Color3.new(1, 0, 0)
			}):Play()
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(35, 0, 35)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			local clone3 = utils.Misc.M.FirePilla:Clone()
			clone3.CFrame = humanoidRootPart.CFrame + createVector(0, 10.5, 0)
			clone3.Part.CFrame = humanoidRootPart.CFrame + createVector(0, 10.5, 0)
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 2)
			clone3.Tornado.CFrame = clone.CFrame - createVector(0, 3, 0)
			TweenService:Create(clone3.Tornado, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				CFrame = (clone.CFrame + createVector(0, 8, 0)) * CFrame.Angles(0, 3.12413936106985, 0),
				Size = createVector(40, 25.418, 40),
				Transparency = 1
			}):Play()
			task.spawn(function()
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				local clone4 = utils.Misc.M.fireballstartup:Clone()
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 10)
				local transparenciesByDescendant = {}

				for _, descendant in folder:GetDescendants() do
					if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
						continue
					end

					local transparency = descendant.Transparency
					descendant.Transparency = 1
					transparenciesByDescendant[descendant] = transparency
				end

				while true do
					local v5 = task.wait()
					clone4.Position = humanoidRootPart.Position

					if localPlayer.Character == folder then
						local cFrame = workspace.CurrentCamera.CFrame
						local moveVector = PlayerModule:GetControls():GetMoveVector()
						instance.Position += (cFrame.RightVector * moveVector.X + -cFrame.LookVector * moveVector.Z) * v5 * 70
					end

					if instance.Parent and folder.Parent then
						continue
					end

					v2:PlaySound(sounds.Misc.M.Scorchrise2, humanoidRootPart, game.SoundService.Effect)

					for _, emitter in clone4:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, child in clone4.Explode:GetChildren() do
						child:Emit(child:GetAttribute("EmitCount"))
					end

					Debris:AddItem(clone4, 1)

					for k, transparency in transparenciesByDescendant do
						if k.Parent then
							k.Transparency = transparency
						end
					end

					break
				end
			end)
			TweenService:Create(clone3["2"], TweenInfo.new(0.075), {
				Position = createVector(0, 12, 0)
			}):Play()
			task.wait(0.3)

			for _, emitter in clone3:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone3["1"]["1"], tweenInfo, {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(clone3["1"]["2"], tweenInfo, {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(clone3["1"]["3"], tweenInfo, {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Grapple.Energy, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("Mokou3Service")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("HitboxController")
end

return controller