local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
local controller = Knit.CreateController({
	Name = "InfiniteVoidController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.InfiniteVoid.Voice, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, instance2)
						instance2.Humanoid:LoadAnimation(animations.Gojo.DomainWarn):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://14591918380"
						p.Panel.ImageLabel.Size = UDim2.new(0.8, 0, 0.4, 0)
					end)
				end
			end
		end,
		Opening = function(parent, p, p2, p3)
			local clone = utils.Gojo.InfiniteVoid.DomainTravel:Clone()
			clone.CFrame = parent.CFrame
			clone.Lines.CFrame = parent.CFrame
			clone.Parent = parent
			local clone2 = utils.Gojo.InfiniteVoid.DomainBG:Clone()
			clone2.CFrame = parent.CFrame
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				clone2:Destroy()
				clone:Destroy()
			end)

			if p3 then
				clone.Transparency = 1
				local playSound = v2:PlaySound(
					sounds.Gojo.InfiniteVoid.InfiniteVoid,
					workspace,
					game.SoundService.Effect
				)
				playSound.TimePosition = 1.5
			else
				local domainGround = p.DomainGround
				domainGround.Surround.Enabled = true
				TweenService:Create(domainGround.Surround, TweenInfo.new(0.8), {
					ShapePartial = 1
				}):Play()
				Debris:AddItem(domainGround, 2)
				v2:PlaySound(sounds.Gojo.InfiniteVoid.InfiniteVoid, workspace, game.SoundService.Effect)
				task.delay(0.8, function()
					TweenService:Create(domainGround, TweenInfo.new(0.4), {
						Transparency = 0
					}):Play()
					v2:DomainMapFade(Color3.new(1, 1, 1), 0.4, 1.6)
				end)
				task.wait(1.5)
				clone.Dissolve:Emit(100)
				clone.Dissolve.Enabled = true
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Dissolve, TweenInfo.new(0.5), {
					ShapePartial = 0,
					Rate = 50
				}):Play()
				task.delay(0.5, function()
					clone.Dissolve.Enabled = false
				end)
			end

			local lines = clone.Lines
			clone.SpaceBG.Enabled = true
			Debris:AddItem(clone, 2.4)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if lines.Parent then
					lines.Position = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -5)).Position
				else
					renderSteppedConnection:Disconnect()
				end
			end)

			if not (p2 and p2.Parent) then
				return
			end

			local v4 = v2:PlaySound(sounds.Gojo.InfiniteVoid.Music, workspace, game.SoundService.Music, true)
			game.SoundService.AmbientReverb = Enum.ReverbType.Arena
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
				TweenService:Create(v4, TweenInfo.new(2), {
					Volume = 0
				}):Play()
				Debris:AddItem(v4, 2)
			end)
			CameraShaker.CurrentShaker:ShakeOnce(5, 25, 2.4, 0.5, createVector(0.5, 0.5, 0), createVector(0, 0, 0))
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(2.3, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
				{
					FieldOfView = 120
				}
			):Play()
			task.delay(2.4, function()
				workspace.CurrentCamera.FieldOfView = 0
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
			task.delay(1, function()
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Contrast = 3,
						Brightness = 0.5
					}
				):Play()
				task.wait(1)
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.3), {
					Contrast = 3.5,
					Brightness = 4
				}):Play()
				task.wait(0.4)
				colorCorrectionEffect.Contrast = 0
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
				Debris:AddItem(colorCorrectionEffect, 0.5)
			end)
			task.wait(2.4)

			if not (p2 and p2.Parent) then
				return
			end

			clone2.Parent = parent
			clone2.Splatter1:Emit(70)
			clone2.Splatter2:Emit(70)
			clone2.Smoke1:Emit(20)
			local renderSteppedConnection2 = nil
			renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
				if clone2.Parent then
					clone2.Position = workspace.CurrentCamera.CFrame.Position
				else
					renderSteppedConnection2:Disconnect()
				end
			end)
		end,
		Shatter = function(position)
			local clone = utils.Domain:Clone()
			clone.Transparency = 1
			clone.CanCollide = false
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, child in clone:GetChildren() do
				if child.Name == "Shatter" then
					child:Emit(100)
				else
					child:Destroy()
				end
			end

			v2:PlaySound(sounds.Gojo.InfiniteVoid.Shatter, clone, game.SoundService.Effect)
			clone.Transparency = 0
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 150 then
					return
				end

				local random = Random.new()
				local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 80 do
					local clone2 = utils.Gojo.Shard:Clone()
					local unit = random:NextUnitVector().Unit
					clone2.Size = Vector3.new(0.1, math.random(1, 8), math.random(1, 8))
					clone2.CFrame = CFrame.lookAlong(position, unit) * CFrame.Angles(1.5707963267948966, 0, 0) + unit * 37.5
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = workspace.Effects
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Transparency = 0
					clone2.Material = Enum.Material.Neon
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 4)
				end
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
	v = Knit.GetService("InfiniteVoidService")
	v2 = Knit.GetController("FXController")
end

return controller