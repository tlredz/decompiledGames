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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BluntTraumaController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.BluntTrauma.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Slash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = {
				{
					0.15,
					CFrame.new(0, -1, 0) * CFrame.Angles(-0.08726646259971647, 0.6108652381980153, 3.141592653589793)
				},
				{ 0.165, CFrame.new(0, 0, 0) * CFrame.Angles(0.2617993877991494, -1.5707963267948966, 0) },
				{
					0.165,
					CFrame.new(0, -1, 0) * CFrame.Angles(-0.08726646259971647, 0.6108652381980153, 3.141592653589793)
				},
				{
					0.165,
					CFrame.new(0, -1, 0) * CFrame.Angles(-0.08726646259971647, 0.6108652381980153, 3.490658503988659)
				},
				{ 0.125, CFrame.new(0, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, -1.5707963267948966) }
			}
			v3:PlaySound(sounds.Reggie.BluntTrauma["Whoosh" .. p], humanoidRootPart, game.SoundService.Effect)

			if p ~= 5 then
				return
			end

			local v6 = v5[p][1]
			local clone = utils.Ryu.Slash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = v5[p][2]
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v6)
			clone.Part1.Mesh.Scale = createVector(-10, 1, 10)
			clone.Part2.Mesh.Scale = createVector(10.445, 3, 10.445)
			local tweenInfo = TweenInfo.new(v6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone.Weld, tweenInfo, {
				C1 = CFrame.Angles(0, 2.9670597283903604, 0)
			}):Play()

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("Decal") then
					descendant.Color3 = Color3.fromRGB(500, 500, 400)
					TweenService:Create(descendant, tweenInfo2, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("SpecialMesh") then
					TweenService:Create(descendant, tweenInfo, {
						Scale = descendant.Scale * 1.7
					}):Play()
				end
			end
		end,
		Break = function(instance)
			local part = Instance.new("Part")
			part.Anchored = true
			part.Transparency = 1
			part.CanCollide = false
			part.CanQuery = false
			part.CFrame = instance.CFrame
			part.Parent = workspace.Effects
			Debris:AddItem(part, 5)
			v3:PlaySound(sounds.Reggie.BluntTrauma["Break" .. math.random(1, 2)], part, game.SoundService.Effect)

			for _ = 1, 9 do
				local clone = utils.Hiromi.GavelShard:Clone()
				clone.Position = (instance.CFrame * CFrame.new((Vector3.new(
					(math.random() - 0.5) * instance.Size.X,
					(math.random() - 0.5) * instance.Size.Y,
					(math.random() - 0.5) * instance.Size.Z
				)))).Position
				clone.Size *= instance.Size.Magnitude / 3.5
				clone.Color = instance.Color
				clone.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
				task.delay(1, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end
		end,
		Hit = function(instance, instance2, p, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.BluntTrauma["Hit" .. p], humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(p == 5 and CameraShaker.Presets.SnapOh or p == 4 and CameraShaker.Presets.Snap or CameraShaker.Presets.HeavyHit)
			end
		end,
		Align = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:PlaySound(sounds.Reggie.BluntTrauma.Jump, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				repeat
					task.wait()
					p.Position = humanoidRootPart2.Position - humanoidRootPart.CFrame.LookVector * 4 + createVector(
						0,
						1.5,
						0
					)
				until instance.Parent == nil or instance2.Parent == nil or instance2:GetAttribute("Ragdoll") == 0 or p.Parent == nil
			end
		end,
		Dizzy = function(instance, instance2, instance3)
			if not (instance:FindFirstChild("HumanoidRootPart") and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			local clone = replicatedStorage.Utils.Damage.Dizzy:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = instance2.Head
			instance3.Destroying:Once(function()
				clone:Destroy()
			end)
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
	v = Knit.GetService("BluntTraumaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller