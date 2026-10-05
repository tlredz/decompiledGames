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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "NueController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function QuadraticBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

function controller.KnitStart(_)
	local v3 = {
		Nue = function(p, position, p2, p3, p4, state)
			local clone = utils.Megumi.Spawn:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local raycastResult = workspace:Raycast(
				position + createVector(0, 2, 0),
				createVector(0, -8, 0),
				raycastParams
			)

			if raycastResult then
				position = raycastResult.Position - createVector(0, 10, 0)
				clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
				clone.Shadow:Emit(12)
				clone.Dive:Emit(6)
			else
				clone.Position = position
				clone.Shadow.Orientation = Enum.ParticleOrientation.FacingCamera
				clone.Shadow:Emit(6)
			end

			local clone2 = utils.Megumi.Nue:Clone()
			clone2.RootPart.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			local track = clone2.AnimationController:LoadAnimation(clone2.AnimationController.Summon)
			track:Play(0)
			v2:PlaySound(sounds.Megumi.Nue.Spawn, clone2.RootPart, game.SoundService.Effect)

			if state then
				TweenService:Create(state, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					P = 100000
				}):Play()
			end

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if state then
					state.Parent = p["Right Arm"]
				end
			end

			local lowerTorso = clone2.RootPart.LowerTorso
			local C0 = lowerTorso.C0
			TweenService:Create(lowerTorso, TweenInfo.new(p4 / 2), {
				C0 = C0 * CFrame.Angles(0, 0, -0.6981317007977318)
			}):Play()
			task.delay(p4 / 2, function()
				TweenService:Create(lowerTorso, TweenInfo.new(p4 / 2), {
					C0 = C0
				}):Play()
				task.wait(p4 / 2)
				TweenService:Create(lowerTorso, TweenInfo.new(p4 / 2), {
					C0 = C0 * CFrame.Angles(0, 0, 0.5235987755982988)
				}):Play()
				track:AdjustSpeed(-0.7)
			end)
			local lastTime = tick()
			local position2 = p3
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, _)
				local v4 = tick() - lastTime

				if p4 + 0.6 <= v4 then
					steppedConnection:Disconnect()

					for _, part in clone2:GetDescendants() do
						if part:IsA("BasePart") then
							TweenService:Create(part, TweenInfo.new(0.2), {
								Color = Color3.new(0, 0, 0)
							}):Play()
						end
					end

					Debris:AddItem(clone2, 0.2)
					local clone3 = utils.Megumi.Spawn:Clone()
					clone3.CFrame = clone2.RootPart.CFrame
					clone3.Shadow.LockedToPart = true
					clone3.Parent = workspace.Effects
					local cFrame = clone2.RootPart.CFrame + clone2.RootPart.CFrame.LookVector * 20
					TweenService:Create(clone2.RootPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						CFrame = cFrame
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						CFrame = cFrame
					}):Play()
					clone3.Shadow.Orientation = Enum.ParticleOrientation.FacingCamera
					clone3.Shadow.EmissionDirection = Enum.NormalId.Right
					clone3.Shadow.Lifetime = NumberRange.new(0.3, 0.6)
					clone3.Shadow.Speed = NumberRange.new(-100, 100)
					clone3.Shadow.Drag = 5
					clone3.Shadow:Emit(30)
					Debris:AddItem(clone3, 1)
				else
					if typeof(p3) ~= "Vector3" then
						position2 = p3.Position
					end

					local v5 = position2 + CFrame.new(p2, position2).LookVector * 50 + createVector(0, 40, 0)
					local v6

					if p4 <= v4 then
						v6 = QuadraticBezier(
							(v4 - p4) / 0.6,
							position2,
							(v5 + position2) / 2 - createVector(0, 10, 0),
							v5
						)
					else
						v6 = QuadraticBezier(v4 / p4, position, p2, position2)
					end

					clone2.RootPart.CFrame = CFrame.new(v6, v6 + (v6 - clone2.RootPart.Position).Unit)

					if state and state.Parent then
						local humanoidRootPart = state.Parent.Parent:FindFirstChild("HumanoidRootPart")

						if not humanoidRootPart then
							return
						end

						if localPlayer.Character == humanoidRootPart.Parent then
							local v7 = clone2.RightLeg.CFrame.UpVector * -3
							state.Position = clone2.RightLeg.Position - v7
						else
							local v7 = clone2.RightLeg.CFrame.UpVector * 1.5 - clone2.RightLeg.CFrame.LookVector * 4
							local v8 = humanoidRootPart.CFrame - humanoidRootPart.Position + clone2.RightLeg.Position - v7
							humanoidRootPart.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + humanoidRootPart.CFrame:Lerp(
								v8,
								state.P / 100000
							).Position
						end
					end
				end
			end)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.NueShock:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.CFrame = humanoidRootPart.CFrame
			clone.Hit:Emit(20)
			TweenService:Create(clone.Electric, TweenInfo.new(0.2), {
				Rate = 0
			}):Play()
			v2:Flash(instance, Color3.fromRGB(255, 85, 255), 1)
			v2:PlaySound(sounds.Megumi.Nue.Hit1, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Nue.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			elseif localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Finisher = function(p)
			local WAIT_INTERVAL = 0.04

			if not p.HumanoidRootPart then
				return
			end

			v2:Burn(p)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.TintColor = Color3.new(1, 1, 1)
				clone.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone.TintColor = Color3.new(1, 0, 0.498039)
				task.wait(WAIT_INTERVAL)
				clone.Brightness = 200
				clone.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone:Destroy()
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
	v = Knit.GetService("NueService")
	v2 = Knit.GetController("FXController")
end

return controller