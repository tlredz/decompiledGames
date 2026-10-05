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
require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "Mokou2Controller"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.M.Kick, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Misc.M.Mokou2Voice, humanoidRootPart, game.SoundService.Voice)
		end,
		Dive = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.spawn(function()
				local model = Instance.new("Model")
				local clone = utils.Misc.S.Boost:Clone()
				clone.Parent = model
				model:ScaleTo(0.5)
				clone.Parent = parent
				model:Destroy()

				repeat
					clone.CFrame = CFrame.lookAlong(
						humanoidRootPart.Position,
						-humanoidRootPart.CFrame.LookVector + humanoidRootPart.CFrame.UpVector
					) * CFrame.Angles(0, 0, math.random(0, 3.141592653589793))
					task.wait()
				until not p.Parent and parent.Parent

				clone:Destroy()
			end)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.Soulfire.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Crush = function(p, position)
			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			local clone2 = utils.Misc.M.DashHit:Clone()
			clone2.Position = position
			clone2.Parent = workspace.Effects

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone2, 1)
			local clone3 = utils.Misc.M.Slash.PointLight:Clone()
			clone3.Parent = clone2
			TweenService:Create(clone3, TweenInfo.new(0.6), {
				Brightness = 0,
				Color = Color3.new(1, 0, 0)
			}):Play()
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Misc.M.KickHit, clone, game.SoundService.Effect)

			if localPlayer == p then
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
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		while true do
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.LookVector * 8 - humanoidRootPart.CFrame.UpVector * 8,
				raycastParams
			)
			local sphereHitbox = v3:SphereHitbox(p, CFrame.new(0, -5, -5), 8)

			if #sphereHitbox > 0 or raycastResult then
				if not (#sphereHitbox > 0) then
					sphereHitbox = false
				end

				object:FireServer(sphereHitbox, raycastResult and raycastResult.Position)

				if raycastResult then
					instance:Destroy()
					break
				end
			end

			task.wait(0.025)

			if not instance.Parent then
				break
			end
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("Mokou2Service")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("HitboxController")
end

return controller