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
local controller = Knit.CreateController({
	Name = "WerentInvitedController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.NotInvited.Windup, humanoidRootPart, game.SoundService.Effect)
		end,
		Charge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.NotInvited.ChargeStart, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mechamaru.Dust:Clone()
			clone.bigimpact:Destroy()
			clone.Smoke2:Destroy()
			clone.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)

			for _, child in clone:GetChildren() do
				child.TimeScale = 0.5
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end,
		Charged = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.NotInvited.FullCharge, humanoidRootPart, game.SoundService.Effect)
			v2:Flash(instance, Color3.fromRGB(0, 255, 255), 1)
		end,
		Dash = function(instance, _, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(
				p and sounds.Ryu.NotInvited.PowerDash or sounds.Ryu.NotInvited.Dash,
				humanoidRootPart,
				game.SoundService.Effect
			)

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.NotInvited.Swing, humanoidRootPart, game.SoundService.Effect)
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
						{ cFrame + cFrame.LookVector * (120 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
			instance.Destroying:Connect(function()
				local ring = instance.Ring
				local clone = utils.Megumi.Mahoraga.Rock:Clone()
				clone.Transparency = 1
				clone.Anchored = true
				clone.CFrame = instance.CFrame
				clone.Parent = workspace.Effects
				ring.Parent = clone
				clone.Attachment.Dust:Emit(20)
				clone.Attachment.Hit:Emit(20)
				clone.Attachment.Sparks:Emit(20)
				Debris:AddItem(clone, 1.5)
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
				local magnitude = (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude

				if magnitude < 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				if magnitude < 100 then
					local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

					for i, child in instance.Rocks:GetChildren() do
						if i > 25 then
							continue
						end

						child.CanCollide = true
						child.CollisionGroup = "Effects"
						child.Parent = workspace.Effects
						Debris:AddItem(child, 3)
						TweenService:Create(child, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
					end
				end
			end)
		end,
		Crunch = function(instance, part, items, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for _, item in items do
				local part2 = Instance.new("Part")
				part2.CanCollide = false
				part2.Massless = true
				part2.Position = item[1]
				part2.Orientation = item[2]
				part2.Color = item[3]
				part2.Material = item[4]
				part2.Size = item[5]
				part2.Transparency = item[6]

				if p then
					part2.Position += part.CFrame.LookVector * p
				end

				part2.Parent = part.Rocks
				local weld = Instance.new("Weld")
				weld.C1 = part.CFrame:ToObjectSpace(part2.CFrame)
				weld.Part1 = part2
				weld.Part0 = part
				weld.Parent = part2
			end
		end,
		Hit = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.03
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			local v4 = v2
			local hit = sounds.Ryu.NotInvited.Hit
			local v5

			if localPlayer.Character == instance then
				v5 = humanoidRootPart or humanoidRootPart2
			else
				v5 = humanoidRootPart2
			end

			v4:PlaySound(hit, v5, game.SoundService.Effect)
			local cframe = CFrame.lookAlong(humanoidRootPart2.Position, -p.RightVector)

			for _, child in utils.Ryu.Doosh:GetChildren() do
				child:PivotTo(cframe * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			local clone = utils.Mechamaru.Dust:Clone()
			clone.bigimpact:Destroy()
			clone.Smoke2:Destroy()
			clone.Position = humanoidRootPart2.Position - createVector(0, 3, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)

			for _, child in clone:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)

				if _G.Settings.Flash == true then
					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.Parent = game.Lighting
					clone2.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = -200
					clone2.Contrast = 1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end
			end
		end,
		PunchWall = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(p * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.8)
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
	v = Knit.GetService("WerentInvitedService")
	v2 = Knit.GetController("FXController")
end

return controller