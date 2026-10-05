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
	Name = "WingKingController"
})

function controller.KnitStart(_)
	local v4 = {
		Dash = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.OverLuck.Dash, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)
			v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(170, 0, 0), 0.3)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local numberValue = Instance.new("NumberValue", parent)
				numberValue.Value = 30
				TweenService:Create(
					numberValue,
					TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Value = 0
					}
				):Play()

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local function swingFX(cframe)
				local clone = utils.Todo.Swing:Clone()
				clone.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, 0, 0.17453292519943295) * cframe
				clone.Weld.Part0 = humanoidRootPart
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.6)
				clone.Core.Wind:Emit(12)
				TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
					C1 = clone.Weld.C1 * CFrame.Angles(0, -3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
					Width0 = 0
				}):Play()
			end

			local function jabFX()
				local clone = utils.Charles.StabWind:Clone()
				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -4))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.3)
				TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
					Size = createVector(0, 25, 0),
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
					Size = createVector(8, 0, 8),
					Transparency = 1,
					Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
				}):Play()
			end

			v3:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)

			if p == 1 then
				v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(170, 0, 0), 0.4)
				swingFX(CFrame.Angles(0, 0, -2.9670597283903604))
			elseif p == 2 then
				jabFX()
			elseif p == 3 then
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(170, 0, 0), 0.5)
				swingFX(CFrame.Angles(0, 0, -4.1887902047863905))
			elseif p == 4 then
				v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(170, 0, 0), 0.2)
				swingFX(CFrame.Angles(0, 0, -5.061454830783556))
			elseif p == 5 then
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(170, 0, 0), 0.2)
				jabFX()
			elseif p == 6 then
				v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(170, 0, 0), 0.4)
				swingFX(CFrame.Angles(0, 0, -4.537856055185257))
			elseif p == 7 then
				v3:ArmFlash(instance["Left Leg"], Color3.fromRGB(170, 0, 0), 0.8)
				swingFX(CFrame.Angles(0, 0, -3.141592653589793))
			end
		end,
		Swing2 = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(p, instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.OverLuck.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.OverLuck.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
			clone.Glow.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind2.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.PointLight.Color = Color3.fromRGB(150, 0, 0)
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Glow:Emit(1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.OverLuck.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Crush = function(position)
			local clone = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Air:Destroy()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			TweenService:Create(clone.Floor.Ring2, TweenInfo.new(0.4), {
				TimeScale = 0.5
			}):Play()
			clone.Floor.Ring2:Emit(10)
			clone.Floor.Wind2:Emit(15)
			clone.Floor.Dust:Emit(100)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone2.Position = position
			clone2.Decal.Transparency = 0
			clone2.Mesh.Scale = createVector(2, 50, 2)
			clone2.Parent = clone
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(80, 40, 80),
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Scale = createVector(40, 10, 40)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 1)
			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Crush, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Crush2, clone, game.SoundService.Effect)
			v3:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 12, 35, 0.4, 1)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 180 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(instance, parent)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v3:PlaySound(sounds.Mahito.CrushingRushdown.HairPull, instance, game.SoundService.Effect)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Position then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (200 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
				parent.Sparks.Enabled = false
			end)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic)
			instance.End.Sparks.Parent = parent
			instance.Beam.CurveSize1 = 20
			TweenService:Create(instance.Beam, tweenInfo, {
				CurveSize1 = 0
			}):Play()
			TweenService:Create(instance.Beam, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Width0 = 0.4,
				Width1 = 0.4
			}):Play()
		end,
		Retract = function(data, instance)
			local clone = instance:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Beam, TweenInfo.new(0.6), {
				Width0 = 3,
				Width1 = 0.4
			}):Play()
			Debris:AddItem(clone, 0.6)
			local lastTime = tick()
			local _ = clone.CFrame

			repeat
				local _ = data["Right Arm"].CFrame * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone.CFrame = clone.CFrame:Lerp(data["Left Arm"].CFrame, (tick() - lastTime) / 0.6)
				task.wait()
				local now = tick()
			until lastTime + 0.6 < now or not data.Parent
		end,
		GrabArm = function(data, p, instance)
			local clone = instance:Clone()
			clone.Anchored = false
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
				Width0 = 1,
				Width1 = 0.3
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.2), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			Debris:AddItem(clone, 1.2)
			local weld = Instance.new("Weld", clone)
			weld.Part1 = clone
			weld.Part0 = p.Torso
			weld.C1 = CFrame.new(0, -1, 1) * CFrame.Angles(-0.17453292519943295, 0, 0)
			task.wait(0.8)
			weld.Enabled = false
			clone.Anchored = true
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0.6,
				Width1 = 0.6
			}):Play()
			local lastTime = tick()
			local _ = clone.CFrame

			repeat
				local _ = data["Right Arm"].CFrame * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone.CFrame = clone.CFrame:Lerp(data["Left Arm"].CFrame, (tick() - lastTime) / 0.4)
				task.wait()
				local now = tick()
			until lastTime + 0.4 < now or not data.Parent
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
	v = Knit.GetService("WingKingService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller