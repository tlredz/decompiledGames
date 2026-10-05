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
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "GreatSerpentController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Serpent.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Leap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) - createVector(0, 3, 0)
			clone.Ring.RotSpeed = NumberRange.new(300, 600)
			clone.Ring.Speed = NumberRange.new(0.1, 20)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(15)
			clone.Dust:Emit(6)
			Debris:AddItem(clone, 0.5)
			v2:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Spawn = function(folder, instance)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = folder:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			task.spawn(function()
				local clone = utils.Megumi.Serpent:Clone()
				clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.Angles(-0.7853981633974483, 0, 0))
				clone.Parent = workspace.Effects
				local highlight = Instance.new("Highlight")
				highlight.FillTransparency = 0
				highlight.OutlineTransparency = 0
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.OutlineColor = Color3.new(0, 0, 0)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = clone
				TweenService:Create(highlight, TweenInfo.new(0.4), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
				v2:PlaySound(sounds.Megumi.Serpent.Spawn, humanoidRootPart, game.SoundService.Effect)
				local v4 = v2:PlaySound(sounds.Megumi.Serpent.Fly, humanoidRootPart, game.SoundService.Effect, true)
				Debris:AddItem(v4, 10)
				local v5 = {
					clone.Torso1,
					clone.Torso2,
					clone.Torso3,
					clone.Torso4,
					clone.Torso5,
					clone.Torso6,
					clone.Tail
				}
				local clone2 = utils.Megumi.Spawn:Clone()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 1)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -30, 0),
					raycastParams
				)

				if raycastResult then
					clone2.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
					clone2.Shadow:Emit(12)
					clone2.Dive:Emit(6)
				else
					clone2.Position = humanoidRootPart.Position
					clone2.Shadow.Orientation = Enum.ParticleOrientation.FacingCamera
					clone2.Shadow:Emit(6)
				end

				for _, v6 in v5 do
					v6.Joint.Enabled = false

					if not raycastResult then
						v6.CFrame = clone.Neck.CFrame + clone.Neck.CFrame.LookVector * math.random(-10, 10) + clone.Neck.CFrame.RightVector * math.random(
							-10,
							10
						)
					end
				end

				local transparenciesByPart = {}

				for _, part in folder:GetDescendants() do
					if not (part:IsA("BasePart") and part.Transparency == 0) then
						continue
					end

					transparenciesByPart[part] = part.Transparency
					part.Transparency = 1
				end

				humanoidRootPart:FindFirstChild("RootJoint")
				local numberValue = Instance.new("NumberValue", folder)
				numberValue.Name = "Offset"
				local v6 = false
				local cFrame = nil
				local steppedConnection = nil
				steppedConnection = RunService.Stepped:Connect(function(_, dt)
					if not clone.Parent then
						steppedConnection:Disconnect()
						return
					end

					if cFrame then
						cFrame += cFrame.LookVector * (120 * dt)
					end

					numberValue.Value += 8 * dt
					local v8 = cFrame and cFrame or humanoidRootPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					local v9 = CFrame.new(math.sin(numberValue.Value) * 5, 0, 0) * CFrame.Angles(
						0,
						math.rad(math.cos(numberValue.Value) * 25),
						0
					)
					clone.Neck.CFrame = v8 * v9

					for _, v10 in v5 do
						local joint = v10.Joint
						local v11 = joint.Part0.CFrame * joint.C0
						local part1 = joint.Part1
						local cframe = CFrame.new(v11.Position, part1.Position)
						part1.CFrame = cframe + cframe.LookVector * 4.619999999999999
					end

					if not (instance and instance:IsDescendantOf(workspace)) and v6 == false then
						v6 = true
						cFrame = humanoidRootPart.CFrame
						local highlight2 = Instance.new("Highlight")
						highlight2.FillTransparency = 1
						highlight2.OutlineTransparency = 1
						highlight2.FillColor = Color3.new(0, 0, 0)
						highlight2.OutlineColor = Color3.new(0, 0, 0)
						highlight2.DepthMode = Enum.HighlightDepthMode.Occluded
						highlight2.Parent = clone
						TweenService:Create(highlight2, TweenInfo.new(0.2), {
							FillTransparency = 0,
							OutlineTransparency = 0
						}):Play()
						v2:PlaySound(sounds.Megumi.Serpent.Despawn, humanoidRootPart, game.SoundService.Effect)
						TweenService:Create(v4, TweenInfo.new(1), {
							Volume = 0
						}):Play()
						numberValue:Destroy()

						for k, transparency in transparenciesByPart do
							if k and k.Parent then
								k.Transparency = transparency
							end
						end

						local v10 = {
							clone.Head,
							clone.Jaw,
							clone.Neck,
							clone.Torso1,
							clone.Torso2,
							clone.Torso3,
							clone.Torso4,
							clone.Torso5,
							clone.Torso6,
							clone.Tail
						}
						Debris:AddItem(clone, 2)

						for _, folder2 in v10 do
							v2:PlaySound(sounds.Megumi.DivineDog.Despawn, folder2, game.SoundService.Effect)
							local clone3 = utils.Megumi.Spawn.Shadow:Clone()
							clone3.Parent = folder2
							clone3.Orientation = Enum.ParticleOrientation.FacingCamera
							clone3.EmissionDirection = Enum.NormalId.Right
							clone3.Lifetime = NumberRange.new(0.25, 0.5)
							clone3:Emit(10)
							folder2.Transparency = 1

							for _, descendant in folder2:GetDescendants() do
								if descendant:IsA("BasePart") or descendant:IsA("Decal") then
									descendant.Transparency = 1
								end
							end

							task.wait(0.1)
						end
					end
				end)
			end)

			if localPlayer.Character == folder then
				local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
				bodyGyro.P = 40000
				bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
				humanoid.PlatformStand = true
				TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					FieldOfView = 120
				}):Play()
				local v4 = humanoidRootPart.Position + createVector(0, 40, 0) + humanoidRootPart.CFrame.LookVector * 40
				local numberValue = Instance.new("NumberValue", instance)
				numberValue.Value = 50
				TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Value = 25
				}):Play()

				while true do
					instance.Position = humanoidRootPart.Position + workspace.CurrentCamera.CFrame.LookVector * numberValue.Value

					if numberValue.Value ~= 25 then
						local v5 = (numberValue.Value - 25) / 25
						instance.Position = instance.Position:Lerp(v4, v5)
					end

					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, instance.Position)
					RunService.Stepped:Wait()

					if instance:IsDescendantOf(workspace) and humanoidRootPart.Parent then
						continue
					end

					TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
						FieldOfView = 70
					}):Play()
					humanoid.PlatformStand = false
					bodyGyro:Destroy()
					break
				end
			end
		end,
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.spawn(function()
				repeat
					local offset = instance:FindFirstChild("Offset")

					if offset then
						p.C0 = CFrame.new(0, math.sin(-offset.Value) * 5, 0) * CFrame.Angles(
							math.rad(math.cos(offset.Value) * 25),
							0,
							0
						)
						task.wait()
					else
						task.wait()
					end
				until not (instance.Parent and instance2.Parent and p.Parent)
			end)
			local clone = utils.Megumi.DivineAttack.Bite:Clone()
			clone.Color = ColorSequence.new(Color3.fromRGB(85, 0, 127))
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(5)
			Debris:AddItem(clone, 0.15)
			v2:PlaySound(sounds.Megumi.Serpent.Hit, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("GreatSerpentService")
	v2 = Knit.GetController("FXController")
end

return controller