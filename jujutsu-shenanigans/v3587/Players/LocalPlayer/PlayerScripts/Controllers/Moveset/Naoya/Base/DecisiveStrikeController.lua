local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
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
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "DecisiveStrikeController"
})

function controller.KnitStart(_)
	local v5 = {
		Weave = function(folder)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local tweenInfo = TweenInfo.new(1.2)
			v3:DustTrail(folder, 0.5, CFrame.Angles(0, -1.5707963267948966, 0))
			v3:PlaySound(sounds.Naoya.Decisive.Startup, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 3 do
				local clone = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone, 1.2)
				clone.Parent = workspace.Effects

				for _, child in clone:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Anchored = true
					child.CFrame = folder[child.Name].CFrame
					TweenService:Create(child, tweenInfo, {
						Transparency = 1,
						Position = child.Position + humanoidRootPart.CFrame.LookVector * 4
					}):Play()
				end

				local transparenciesByDescendant = {}

				for _, descendant in folder:GetDescendants() do
					if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
						continue
					end

					local transparency = descendant.Transparency
					descendant.Transparency = 1
					transparenciesByDescendant[descendant] = transparency
				end

				task.wait(0.1)

				for k, transparency in transparenciesByDescendant do
					if k.Parent then
						k.Transparency = transparency
					end
				end

				local clone2 = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone2, 1.2)
				clone2.Parent = workspace.Effects

				for _, child in clone2:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Anchored = true
					child.CFrame = folder[child.Name].CFrame
					TweenService:Create(child, tweenInfo, {
						Transparency = 1,
						Position = child.Position + humanoidRootPart.CFrame.LookVector * 4
					}):Play()
				end

				if i == 2 then
					v3:PlaySound(sounds.Naoya.Decisive.Flicker1, humanoidRootPart, game.SoundService.Effect)
				elseif i == 3 then
					v3:PlaySound(sounds.Naoya.Decisive.Flicker2, humanoidRootPart, game.SoundService.Effect)
				end

				local clone3 = utils.Naoya.Teleport:Clone()
				clone3.CFrame = humanoidRootPart.CFrame
				clone3.Parent = workspace.Effects
				clone3.Lines:Emit(8)
				clone3.Floor.Dust:Emit(30)
				Debris:AddItem(clone3, 1)
				task.wait(0.1)
			end
		end,
		Flick = function(folder, p, p2)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cFrame = humanoidRootPart.CFrame

			if p2 > 1 and p then
				local v6 = v3:PlaySound(sounds.Naoya.Decisive.Boost, humanoidRootPart, game.SoundService.Effect)
				v6.Volume *= p2 / 3
				local model = Instance.new("Model")
				local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
				clone.CFrame = cFrame * CFrame.new(0, -1, 0)
				clone.Parent = model
				model.Parent = workspace.Effects
				model:ScaleTo(0.25 * p2)
				clone.Ring:Emit(7)
				Debris:AddItem(model, 2)
				local clone2 = utils.Itadori.Shock:Clone()
				local model2 = Instance.new("Model")
				clone2.Parent = model2
				model2:ScaleTo(0.4 * p2)
				Debris:AddItem(model2, 0.2)
				clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.2)
				task.delay(0.05, function()
					local clone3 = utils.Itadori.Shock:Clone()
					clone3.CFrame = (cFrame - cFrame.Position + humanoidRootPart.Position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone3, 0.2)
				end)
			end

			local tweenInfo = TweenInfo.new(1.2)
			v3:DustTrail(folder, 0.5, CFrame.Angles(0, -1.5707963267948966, 0))
			local clone = utils.Damage.HitGlow:Clone()
			Debris:AddItem(clone, 1.2)
			clone.Parent = workspace.Effects

			for _, child in clone:GetChildren() do
				child.Color = Color3.fromRGB(128, 126, 255)
				child.Anchored = true
				child.CFrame = folder[child.Name].CFrame
				TweenService:Create(child, tweenInfo, {
					Transparency = 1,
					Position = child.Position + humanoidRootPart.CFrame.LookVector * 4
				}):Play()
			end

			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
					continue
				end

				local transparency = descendant.Transparency
				descendant.Transparency = 1
				transparenciesByDescendant[descendant] = transparency
			end

			task.wait(0.1)

			for k, transparency in transparenciesByDescendant do
				if k.Parent then
					k.Transparency = transparency
				end
			end

			local clone2 = utils.Damage.HitGlow:Clone()
			Debris:AddItem(clone2, 1.2)
			clone2.Parent = workspace.Effects

			for _, child in clone2:GetChildren() do
				child.Color = Color3.fromRGB(128, 126, 255)
				child.Anchored = true
				child.CFrame = folder[child.Name].CFrame
				TweenService:Create(child, tweenInfo, {
					Transparency = 1,
					Position = child.Position + humanoidRootPart.CFrame.LookVector * 4
				}):Play()
			end

			local v6 = math.random(1, 3)
			local playSound = v3:PlaySound(
				sounds.Naoya.Decisive["Flicker" .. v6],
				humanoidRootPart,
				game.SoundService.Effect
			)
			playSound.PlaybackSpeed = math.random(90, 110) / 100
			local clone3 = utils.Naoya.Teleport:Clone()
			clone3.CFrame = humanoidRootPart.CFrame
			clone3.Parent = workspace.Effects
			clone3.Lines:Emit(8)
			clone3.Floor.Dust:Emit(30)
			Debris:AddItem(clone3, 1)
		end,
		ClearForce = function(self)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:ClearForce(humanoidRootPart)
			v4:ClearForce(self.Torso)
		end,
		FlickBar = function(instance, instance2)
			if not (instance and instance2) then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.Outburst.ChargeMeter:Clone()
			clone.Parent = humanoidRootPart
			local bars = clone:FindFirstChild("Bars")
			TweenService:Create(bars, TweenInfo.new(0), {
				GroupTransparency = 0
			}):Play()
			local changedConnection = instance2.Changed:Connect(function()
				local child = bars:FindFirstChild(instance2.Value)

				if child then
					local clone2 = utils.Naoya.Projection.Bar.Bar.UIGradient:Clone()
					clone2.Rotation = 90
					clone2.Parent = child
					child.BackgroundColor3 = Color3.new(1, 1, 1)
					child.BackgroundTransparency = 0
				end
			end)
			instance2.AncestryChanged:Once(function()
				if clone and clone.Parent then
					TweenService:Create(bars, TweenInfo.new(0.3), {
						GroupTransparency = 1
					}):Play()
					Debris:AddItem(clone, 0.3)
				end

				changedConnection:Disconnect()
			end)
		end,
		Ding = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Naoya.Decisive.Ding, humanoidRootPart, game.SoundService.Effect)
		end,
		Windup = function(instance)
			local humanoidRootPart

			if instance then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
			end

			if not humanoidRootPart then
				return
			end

			local armFlash = v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(128, 126, 255), 0.65)
			local childAddedConnection = nil
			childAddedConnection = instance:FindFirstChild("Info").ChildAdded:Connect(function(child)
				if child.Name == "NaoyaFrame" then
					childAddedConnection:Disconnect()

					if armFlash and armFlash.Parent then
						armFlash:Destroy()
					end
				end
			end)
			armFlash.AncestryChanged:Once(function()
				childAddedConnection:Disconnect()
			end)
			task.wait(0.2)
			v3:PlaySound(sounds.Naoya.Decisive.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit1 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(0.666667, 0.666667, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Naoya.Decisive.FirstHit, humanoidRootPart, game.SoundService.Effect)
			v3:ArmFlash(p["Right Arm"], Color3.fromRGB(128, 126, 255), 0.3)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Naoya.Decisive.SecondHit, humanoidRootPart2, game.SoundService.Effect)
			v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(128, 126, 255), 0.3)
			v3:PlaySound(sounds.Naoya.Decisive.Swing2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Naoya.Decisive:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart2,
				game.SoundService.Effect
			)
			local v6 = math.random(140, 200) / 10
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.7
			clone.Position = instance2.Head.Position
			clone.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v6, v6, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.1)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
			end

			local tweenInfo = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.075, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

			for _ = 1, 2 do
				local clone2 = utils.Naoya.Barrage:Clone()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.075)
				clone2.Arm1.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(15, 35) / 10,
					math.random(-5, 15) / 10,
					math.random(-10, 30) / 10
				) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(10, 25))),
					math.random(0, 3.141592653589793)
				)
				clone2.Arm2.CFrame = humanoidRootPart.CFrame * CFrame.new(
					-math.random(15, 35) / 10,
					math.random(-5, 15) / 10,
					math.random(-10, 30) / 10
				) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(-25, -10))),
					math.random(0, 3.141592653589793)
				)
				TweenService:Create(clone2.Arm1, tweenInfo, {
					CFrame = clone2.Arm1.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(
						0,
						math.rad((math.random(30, 60))),
						0
					)
				}):Play()
				TweenService:Create(clone2.Arm2, tweenInfo, {
					CFrame = clone2.Arm2.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(
						0,
						math.rad((math.random(30, 60))),
						0
					)
				}):Play()
				TweenService:Create(clone2.Arm1, tweenInfo2, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.Arm2, tweenInfo2, {
					Transparency = 1
				}):Play()
				task.wait(0.05)
			end
		end,
		Hit3 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Naoya.Decisive:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart2,
				game.SoundService.Effect
			)
			local v6 = math.random(140, 200) / 10
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.7
			clone.Position = instance2.Head.Position
			clone.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v6, v6, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.1)
			BloodyZee:Blood(instance2.Head.CFrame, math.random(25, 55), 80, 15)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
			end

			local tweenInfo = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.075, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

			for _ = 1, 2 do
				local clone2 = utils.Naoya.Barrage:Clone()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.075)
				clone2.Arm1.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(5, 15) / 10,
					math.random(-5, 15) / 10,
					math.random(-10, 30) / 10
				) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(-15, 15))),
					math.random(0, 3.141592653589793)
				)
				clone2.Arm2.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(5, 15) / 10,
					math.random(-5, 15) / 10,
					math.random(-10, 30) / 10
				) * CFrame.Angles(
					math.rad((math.random(-5, 5))),
					math.rad((math.random(-15, 15))),
					math.random(0, 3.141592653589793)
				)
				TweenService:Create(clone2.Arm1, tweenInfo, {
					CFrame = clone2.Arm1.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(
						0,
						math.rad((math.random(30, 60))),
						0
					)
				}):Play()
				TweenService:Create(clone2.Arm2, tweenInfo, {
					CFrame = clone2.Arm2.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(
						0,
						math.rad((math.random(30, 60))),
						0
					)
				}):Play()
				TweenService:Create(clone2.Arm1, tweenInfo2, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.Arm2, tweenInfo2, {
					Transparency = 1
				}):Play()
				task.wait(0.05)
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
	v2.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("DecisiveStrikeService")
	v2 = Knit.GetService("DecisiveStrike2Service")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("HandicapController")
end

return controller