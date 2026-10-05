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
	Name = "GraniteBlastController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Ryu.Charge:Clone()
			clone.Weld.Part0 = instance.Head
			clone.Parent = workspace.Effects
			clone.Attachment.Flare:Emit(1)
			TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(1), {
				Brightness = 5
			}):Play()
			local v5 = v2:PlaySound(sounds.Ryu.GraniteBlast.Charge, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Once(function()
				if v5.Parent then
					v5:Destroy()
				end

				if clone.Parent then
					clone:Destroy()
				end
			end)
		end,
		Warn = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Ryu.ChargeWarn:Clone()
			clone.Weld.Part0 = instance.Head
			clone.Parent = workspace.Effects
			clone.Attachment.Warn:Emit(1)
			TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(1), {
				Brightness = 5
			}):Play()
			Debris:AddItem(clone, 0.2)
		end,
		Fire = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.GraniteBlast.Fire, humanoidRootPart, game.SoundService.Effect)

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end
		end,
		FireHard = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.GraniteBlast.FireHard, humanoidRootPart, game.SoundService.Effect)

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(p * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			local clone = utils.Ryu.GraniteBeam:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = p * CFrame.new(0, 2, -50)
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 100)
			}):Play()
			Debris:AddItem(clone, 1)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.GraniteBlast.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
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
						{ cFrame + cFrame.LookVector * (180 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
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
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -12, 0), _G.MapParams)

			if raycastResult then
				p.Position = raycastResult.Position + createVector(0, 4, 0)
			else
				p.Position = humanoidRootPart.Position
			end

			humanoid.PlatformStand = true

			while true do
				local mouseTarget = v3:GetMouseTarget()

				if not bodyGyro:GetAttribute("Lock") then
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				end

				task.wait()

				if p.Parent then
					continue
				end

				bodyGyro:Destroy()
				humanoid.PlatformStand = false
				break
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Burn(p)
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
	v = Knit.GetService("GraniteBlastService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller