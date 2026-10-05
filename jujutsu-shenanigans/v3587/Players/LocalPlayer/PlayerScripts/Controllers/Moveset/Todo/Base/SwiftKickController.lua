local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "SwiftKickController"
})

local function writeFloat16(buf: buffer, p: number, p2: number)
	local v5 = p * 8

	if p2 == 0 then
		buffer.writebits(buf, v5, 16, 0)
		return
	end

	if p2 >= 65520 then
		buffer.writebits(buf, v5, 16, 31744)
		return
	end

	if p2 <= -65520 then
		buffer.writebits(buf, v5, 16, 64512)
		return
	end

	if p2 ~= p2 then
		buffer.writebits(buf, v5, 16, 31745)
		return
	end

	local v6

	if p2 < 0 then
		p2 = -p2
		v6 = 1
	else
		v6 = 0
	end

	local v7, v8 = math.frexp(p2)
	buffer.writebits(buf, v5 + 0, 10, v7 * 2048 - 1023.5)
	buffer.writebits(buf, v5 + 10, 5, v8 + 14)
	buffer.writebits(buf, v5 + 15, 1, v6)
end

function controller.KnitStart(_)
	local v5 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:PlaySound(sounds.Hakari.FeverBreak.Dash, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Todo.Swing:Clone()
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
			v4:PlaySound(sounds.Hakari.Counter.Startup, humanoidRootPart, game.SoundService.Effect)
			v4:PlaySound(sounds.Choso.PiercingBlood.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, parent, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local numberValue = Instance.new("NumberValue", parent)
				numberValue.Value = p and 165 or 150
				TweenService:Create(
					numberValue,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = 35
					}
				):Play()

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.2)
			v4:PlaySound(sounds.Mahito.CrushingRushdown.Leap, humanoidRootPart, game.SoundService.Effect)
		end,
		UpdateCamera = function(instance)
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				if not (instance and instance.Parent) then
					return
				end

				local lookVector = currentCamera.CFrame.LookVector
				local buf = buffer.create(6)
				writeFloat16(buf, 0, lookVector.X)
				writeFloat16(buf, 2, lookVector.Y)
				writeFloat16(buf, 4, lookVector.Z)
				instance:FireServer(buf)
			end)
			instance.AncestryChanged:Once(function()
				heartbeatConnection:Disconnect()
			end)
		end,
		Aim = function(instance, p)
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
			p.Position = humanoidRootPart.Position + createVector(0, 2, 0)
			humanoid.PlatformStand = true

			repeat
				v3:GetMouseTarget(nil, true)
				bodyGyro.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + workspace.CurrentCamera.CFrame.LookVector
				)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Throw = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(2, 1, -4))
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
			TweenService:Create(clone.Shockwave, TweenInfo.new(0.3), {
				Size = createVector(0, 30, 0),
				Transparency = 1,
				CFrame = clone.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			v4:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 4 do
				task.delay(i * 0.1, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart2.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(10, 0, 10),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.15)
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("SwiftKickService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("ToolController")
	v4 = Knit.GetController("FXController")
end

return controller