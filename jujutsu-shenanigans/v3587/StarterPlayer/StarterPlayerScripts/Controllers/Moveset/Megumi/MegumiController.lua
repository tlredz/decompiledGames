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
	Name = "MegumiController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		Shadow = function(parent, p)
			local humanoidRootPart = parent.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Megumi.ShadowEnter, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.Shadow:Clone()
			clone.Parent = parent
			task.delay(0.2, function()
				clone.Dive.Enabled = false
			end)

			while true do
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -8, 0),
					raycastParams
				)

				if raycastResult then
					clone.Shadow.Enabled = true
					clone.ShadowAir.Enabled = false
					clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
				else
					clone.CFrame = humanoidRootPart.CFrame - createVector(0, 3, 0)
					clone.Shadow.Enabled = false
					clone.ShadowAir.Enabled = true
				end

				RunService.RenderStepped:Wait()

				if p.Parent then
					continue
				end

				v3:PlaySound(sounds.Megumi.Rabbit.Despawn, humanoidRootPart, game.SoundService.Effect)
				clone.Shadow.Enabled = false
				clone.ShadowAir.Enabled = false
				clone.Dive:Emit(20)
				Debris:AddItem(clone, 1)
				break
			end
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2)
			if p == 1 or p == 3 or p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(0, 0, 0), 0.3)
			elseif p == 2 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(0, 0, 0), 0.3)
			elseif p == 4 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(0, 0, 0), p2 == "Down" and 0.4 or 0.3)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(sounds.Megumi.Awaken, torso, game.SoundService.Effect)
			local clone = utils.Megumi.Dialogue:Clone()
			clone.Parent = torso
			local position = clone.Text1.Position
			clone.Text1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Text1, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text1.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			}):Play()
			task.wait(1.1)
			local position2 = clone.Text2.Position
			clone.Text2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Text2, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text2.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			}):Play()
			task.wait(0.25)
			local position3 = clone.Chat1.Position
			clone.Chat1.Position = position3 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position3
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.9)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()

					if guiObject:FindFirstChild("UIStroke") then
						TweenService:Create(
							guiObject:FindFirstChild("UIStroke"),
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						):Play()
					end
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
	v = Knit.GetService("MegumiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller