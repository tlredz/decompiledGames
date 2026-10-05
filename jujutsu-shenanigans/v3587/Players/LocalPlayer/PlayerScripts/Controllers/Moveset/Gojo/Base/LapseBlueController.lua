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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "LapseBlueController"
})

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function QuadraticBezier(value, position, p, position2)
	return (1 - value) ^ 2 * position + 2 * (1 - value) * value * p + value ^ 2 * position2
end

function controller.KnitStart(_)
	local v3 = {
		LapseBlue = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.LapseBlue:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame
			clone.Weld.Part0 = humanoidRootPart
			Debris:AddItem(clone, 0.8)
			v2:PlaySound(sounds.Gojo.LapseBlue.LapseBlue, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(clone.Zoom.PointLight, TweenInfo.new(0.3), {
				Range = 30
			}):Play()
			TweenService:Create(clone.Zoom.PointLight, TweenInfo.new(0.3), {
				Brightness = 12
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(2, 2, 2)
			}):Play()
			task.wait(0.3)
			TweenService:Create(clone.Zoom.PointLight, TweenInfo.new(0.15), {
				Range = 0
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(0, 0, 0)
			}):Play()
			clone.Center.Aura.Enabled = false
			clone.Zoom.Aura:Emit(20)
			local highlight = Instance.new("Highlight", clone.Grab)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			clone.Grab.Transparency = 50
			TweenService:Create(
				clone.Grab,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(15, 15, 15),
					Transparency = 1
				}
			):Play()
			Debris:AddItem(clone.Grab, 0.4)
		end,
		BlueGrab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			end

			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(10)
			clone.Ring:Emit(3)
			Debris:AddItem(clone, 0.5)
			v2:Flash(instance, Color3.fromRGB(85, 170, 255), 0.5)
		end,
		Grab = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart2, game.SoundService.Effect)
			local v4 = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude / 60
			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position)
			task.wait(v4)

			if not p.Parent then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Infinity, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.LapseBlue.Infinity:Clone()
			clone.CFrame = cframe
			clone.Parent = workspace.Effects
			clone.Attachment.Ring:Emit(5)
			clone.Attachment.Infinity:Emit(10)
			Debris:AddItem(clone, 0.5)
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)
			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position + createVector(0, 3.5, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 3.5
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Finisher = function(list, p, position, list2)
			if #list < 15 then
				for _ = 1, 15 - #list do
					table.insert(list, {
						CFrame.new(p + Vector3.new(math.random(-8, 8), math.random(-8, -2), math.random(-8, 8))),
						Color3.fromRGB(86, 66, 54),
						Enum.Material.Ground,
						createVector(2, 2, 2)
					})
				end
			elseif #list > 40 then
				for i = 40, #list do
					table.remove(list, i)
				end
			end

			local clone = utils.Gojo.LapseBlue.LapseBlue:Clone()
			clone.CFrame = CFrame.new(position)
			clone.Transparency = 1
			clone.Center.Aura.Enabled = false
			clone.Anchored = true
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)
			local humanoidRootPart

			if list2[1] then
				humanoidRootPart = list2[1]:FindFirstChild("HumanoidRootPart")
			else
				humanoidRootPart = nil
			end

			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if not clone.Parent then
					steppedConnection:Disconnect()
				end

				local position2 = humanoidRootPart and humanoidRootPart.Position or position
				clone.Position = position2
			end)
			local playSound = v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Throw, clone, game.SoundService.Effect)
			playSound.PlaybackSpeed = 1.1

			if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for k, v4 in list do
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Massless = true
				part.CFrame = v4[1]
				part.Color = v4[2]
				part.Material = v4[3]
				part.Size = v4[4]
				part.Parent = clone
				Debris:AddItem(part, 4)
				local v5 = math.random(30, 80) / 100
				local numberValue = Instance.new("NumberValue", part)
				TweenService:Create(numberValue, TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Value = 1
				}):Play()
				local vector2 = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				local vector3 = Vector3.new(
					math.random(-35, 35) / 10,
					math.random(-35, 35) / 10,
					math.random(-35, 35) / 10
				)
				local v6 = Vector3.new(
					math.random(-30, 30) / 0.8 * v5,
					math.random(-30, 30) / 0.8 * v5,
					math.random(-30, 30) / 0.8 * v5
				)
				local v11 = v4
				local steppedConnection2 = RunService.Stepped:Connect(function()
					local position2 = humanoidRootPart and humanoidRootPart.Position or position
					local v12 = position2 + v6

					if numberValue.Value == 1 then
						part.Position = position2 + vector3
						part.Orientation = vector2
					else
						local quadraticBezier = QuadraticBezier(numberValue.Value, v11[1].Position, v12, position2)
						part.CFrame = part.CFrame - part.Position + quadraticBezier
					end
				end)
				local v12 = part
				local v13 = k
				task.delay(v5, function()
					v12.Size *= 1.5

					if v13 % 7 == 0 then
						v2:PlaySound(
							sounds.Megumi.Mahoraga.M1["Hit" .. math.random(3, 4)],
							v12,
							game.SoundService.Effect
						)
						BloodyZee:Blood(v12.CFrame, 70, 180, 180)

						if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 150 then
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
						end
					end

					if v13 % 3 == 0 then
						clone.Explode.HitBase:Emit(1)
					end

					task.wait(1.5 - v5)
					steppedConnection2:Disconnect()
				end)
			end

			task.delay(1.5, function()
				for _, folder in list2 do
					if not folder.Parent then
						continue
					end

					for _, descendant in folder:GetDescendants() do
						if descendant:IsA("BasePart") or descendant:IsA("Decal") then
							descendant.Transparency = 1
						end
					end
				end

				if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 150 then
					for _, part in clone:GetChildren() do
						if not (part:IsA("BasePart") and part ~= clone.Grab) then
							continue
						end

						TweenService:Create(
							part,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Position = position
							}
						):Play()
						local v4 = part
						task.delay(0.5, function()
							if not _G.Settings.DesPHY then
								v4:Destroy()
								return
							end

							v4.Anchored = false
							v4.Velocity = Vector3.new(math.random(-50, 50), math.random(0, 100), math.random(-50, 40))
							TweenService:Create(
								v4,
								TweenInfo.new(math.random(1.5, 2), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
							task.wait(0.1)
							v4.CanCollide = true
							v4.CollisionGroup = "Effects"
						end)
					end
				else
					for _, part in clone:GetChildren() do
						if part:IsA("BasePart") and part ~= clone.Grab then
							part:Destroy()
						end
					end
				end

				local highlight = Instance.new("Highlight", clone.Grab)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				clone.Grab.Size = createVector(30, 30, 30)
				TweenService:Create(
					clone.Grab,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 40
					}
				):Play()
				TweenService:Create(clone.Grab, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				}):Play()
				v2:PlaySound(sounds.Gojo.LapseBlue.LapseBlue, clone, game.SoundService.Effect)
				TweenService:Create(clone.Zoom.PointLight, TweenInfo.new(0.3), {
					Range = 30,
					Brightness = 12
				}):Play()
				clone.Zoom.Aura.Enabled = true
				task.wait(0.5)
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
				v2:PlaySound(sounds.Gojo.LapseBlue.Absorb, clone, game.SoundService.Effect)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 150 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				TweenService:Create(clone.Zoom.PointLight, TweenInfo.new(0.15), {
					Range = 0
				}):Play()
				clone.Zoom.Aura.Enabled = false
				clone.Explode.Dust:Emit(10)
				clone.Explode.Hit:Emit(10)
				clone.Explode.Ring:Emit(10)
				TweenService:Create(
					clone.Grab,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				Debris:AddItem(clone.Grab, 0.4)
			end)
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
	v = Knit.GetService("LapseBlueService")
	v2 = Knit.GetController("FXController")
end

return controller