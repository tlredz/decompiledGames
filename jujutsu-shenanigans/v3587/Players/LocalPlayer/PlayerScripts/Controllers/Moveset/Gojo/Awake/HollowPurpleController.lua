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
local v3 = nil
local controller = Knit.CreateController({
	Name = "HollowPurpleController"
})

function controller.KnitStart(_)
	local v4 = {
		Aerial = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			p.Position = humanoidRootPart.Position + createVector(0, 6, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Purple = function(instance, folder)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if not workspace:FindFirstChild("Music") then
				TweenService:Create(
					v2:PlaySound(sounds.Gojo.HollowPurple.Music, humanoidRootPart, game.SoundService.Music),
					TweenInfo.new(0.5),
					{
						Volume = 1.25
					}
				):Play()
			end

			local clone = utils.Gojo.HollowPurple.Blue:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = folder
			local clone2 = utils.Gojo.HollowPurple.Red:Clone()
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = folder
			TweenService:Create(clone, TweenInfo.new(0.25), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.25), {
				Brightness = 20
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone2.PointLight, TweenInfo.new(0.25), {
				Brightness = 20
			}):Play()
			clone.Mid.Charge:Emit(2)
			clone2.Mid.Charge:Emit(2)
			v2:PlaySound(sounds.Gojo.HollowPurple.Merge, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.25)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			for _, decal in folder:GetDescendants() do
				if decal.Name == "Sparks" then
					decal:Emit(20)
				elseif decal.Name == "Stars" then
					decal:Emit(7)
				elseif decal.Name == "Beam2" or decal.Name == "Smoke" then
					decal.Enabled = true
				elseif decal:IsA("Decal") then
					decal.Transparency = 0.1
				end
			end

			clone.Material = Enum.Material.Granite
			clone2.Material = Enum.Material.Granite
			TweenService:Create(clone.Weld, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				C1 = CFrame.new(0, 0, 9)
			}):Play()
			TweenService:Create(clone2.Weld, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				C1 = CFrame.new(0, 0, -9) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			task.wait(1)
			clone:Destroy()
			clone2:Destroy()
			local clone3 = utils.Gojo.HollowPurple.Purple:Clone()
			clone3.Weld.Part0 = humanoidRootPart
			clone3.Parent = folder
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Size = createVector(15, 15, 15)
			}):Play()
			TweenService:Create(clone3.Weld, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				C1 = CFrame.new(0, -3, 13)
			}):Play()
			TweenService:Create(
				clone3.PointLight,
				TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 10
				}
			):Play()
			task.spawn(function()
				local highlight = Instance.new("Highlight", clone3.Warp)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				TweenService:Create(
					clone3.Warp,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(40, 40, 40),
						Transparency = 1
					}
				):Play()
				Debris:AddItem(clone3.Warp, 0.5)
			end)

			if localPlayer.Character == instance then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)

				repeat
					task.wait()
				until not folder.Parent

				shakeSustain:StartFadeOut(1)
			end
		end,
		Launch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.HollowPurple.PurpleSnap.Center:Clone()
			clone.Parent = instance["Right Arm"]
			clone.Ring:Emit(1)
			clone.Star:Emit(1)
			clone.Wave:Emit(1)
			clone.Snap1:Emit(20)
			Debris:AddItem(clone, 1)
			v2:PlaySound(sounds.Gojo.HollowPurple.Snap, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
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

			v2:Flash(instance, Color3.fromRGB(255, 85, 255), 2)
			v2:PlaySound(sounds.Gojo.HollowPurple.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Finisher = function(folder)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.HollowPurple.Hit, humanoidRootPart, game.SoundService.Effect)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			folder["Left Leg"].Transparency = 0
			local clone = utils.Damage.LegBurn:Clone()
			clone.Weld.Part1 = folder["Left Leg"]
			clone.Weld.C1 *= CFrame.new(0, 1, 0)
			clone.Parent = folder
			folder["Right Leg"].Transparency = 0
			local clone2 = utils.Damage.LegBurn:Clone()
			clone2.Weld.Part1 = folder["Right Leg"]
			clone2.Weld.C1 *= CFrame.new(0, 1, 0)
			clone2.Parent = folder
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
	v = Knit.GetService("HollowPurpleService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller