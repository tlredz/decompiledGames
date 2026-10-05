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
	Name = "ThisDessertController"
})
local v3 = {
	"rbxassetid://1179108573",
	"rbxassetid://71845731466516",
	"rbxassetid://87448031781486",
	"rbxassetid://1195495141",
	"rbxassetid://139763419390819",
	"rbxassetid://118771487275303",
	"rbxassetid://132000956098235",
	"rbxassetid://86387593022324",
	"rbxassetid://119931280790531",
	"rbxassetid://81714155332842",
	"rbxassetid://71211268740252",
	"rbxassetid://86546583614760",
	"rbxassetid://1195495141",
	"rbxassetid://104840081726175",
	"rbxassetid://93699203917632",
	"rbxassetid://117187548246869",
	"rbxassetid://134478530219943",
	"rbxassetid://87702215058937",
	"rbxassetid://84891765170592",
	"rbxassetid://1195495141"
}

function controller.KnitStart(_)
	task.spawn(function()
		local v4 = {}

		for _, v5 in pairs(v3) do
			table.insert(v4, v5)
		end

		game.ContentProvider:PreloadAsync(v4)
	end)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.Dessert.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.Dessert.Dash, humanoidRootPart, game.SoundService.Effect)

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			task.wait(0.2)

			for _, child in utils.Ryu.Doosh:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			task.wait(0.4)
			v2:PlaySound(sounds.Ryu.Dessert.Slide, humanoidRootPart, game.SoundService.Effect)
			v2:DustTrail(instance, 1)
		end,
		FirstHit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Dessert.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)

			if p then
				for _ = 1, 20 do
					BloodyZee:Blood(instance2.Head.CFrame, math.random(5, 60), 20, 20)
				end
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Ryu.Slash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 0, 0.7853981633974483)
			clone.Weld.C1 = CFrame.Angles(0, -1.5707963267948966, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.15)
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone.Weld, tweenInfo, {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -1.7453292519943295, 0)
			}):Play()

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("Decal") then
					TweenService:Create(descendant, tweenInfo2, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("SpecialMesh") then
					TweenService:Create(descendant, tweenInfo, {
						Scale = descendant.Scale * 1.2
					}):Play()
				end
			end
		end,
		StartHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Dessert.LongHit, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 2 do
				local v5 = i == 1 and instance or instance2
				local clone = replicatedStorage.Utils.Gojo.HandTrail:Clone()
				clone.Parent = workspace.Effects
				clone.Trail.Color = ColorSequence.new(v5["Left Arm"].Color)
				clone.Weld.Part0 = v5["Left Arm"]
				Debris:AddItem(clone, 4)
				local clone2 = replicatedStorage.Utils.Gojo.HandTrail:Clone()
				clone2.Parent = workspace.Effects
				clone2.Trail.Color = ColorSequence.new(v5["Right Arm"].Color)
				clone2.Weld.Part0 = v5["Right Arm"]
				clone2.Weld.C1 *= CFrame.Angles(0, 3.141592653589793, 0)
				Debris:AddItem(clone2, 4)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Flash = function(self, instance2, p)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			task.spawn(function()
				if p == 1 and _G.Settings.Gore == true then
					local clone = utils.Naoya.BleedFreeze.Attachment:Clone()
					clone.Position = createVector(0, -0.5, 0.5)
					clone.Blood.Enabled = false
					clone.Blood.LockedToPart = true
					Debris:AddItem(clone, 1)
					clone.Parent = instance2.Head
					clone.Blood:Emit(7)
					task.delay(0.05, function()
						clone.Blood.TimeScale = 0
						task.wait(0.37)
						clone.Blood.TimeScale = 1

						for _ = 1, 8 do
							BloodyZee:Blood(instance2.Head.CFrame, math.random(5, 80), 25, 25)
						end
					end)
				elseif p == 2 then
					if _G.Settings.Gore == true then
						local clone = utils.Naoya.BleedFreeze.Attachment:Clone()
						clone.Position = createVector(0, -0.5, 0.5)
						clone.Blood.Enabled = false
						clone.Blood.LockedToPart = true
						Debris:AddItem(clone, 1)
						clone.Parent = self.Head
						clone.Blood:Emit(7)
						task.delay(0.05, function()
							clone.Blood.TimeScale = 0
							task.wait(0.42)
							clone.Blood.TimeScale = 1

							for _ = 1, 8 do
								BloodyZee:Blood(self.Head.CFrame, math.random(5, 80), 25, 25)
							end
						end)
					end

					task.wait(0.45)
					v2:PlaySound(sounds.Ryu.Dessert.Impact, humanoidRootPart, game.SoundService.Effect)
				end
			end)

			if localPlayer.Character == self or localPlayer.Character == instance2 then
				if p == 1 then
					local clone = utils.Ryu.DOF:Clone()
					clone.Parent = game.Lighting
					Debris:AddItem(clone, 0.4)
					local clone2 = utils.Ryu.Lines:Clone()
					clone2.Parent = localPlayer.PlayerGui
					Debris:AddItem(clone2, 0.4)
					local cframe = CFrame.new(
						-0.542443275,
						1.10020399,
						-3.05016518,
						-0.37603417,
						-0.910731256,
						-0.170783877,
						-0.892315924,
						0.306238711,
						0.331647605,
						-0.249741182,
						0.27710408,
						-0.927816153
					)
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					workspace.CurrentCamera.FieldOfView = 30
					local v5 = tick() + 0.4

					repeat
						workspace.CurrentCamera.CFrame = instance2.Head.CFrame:ToWorldSpace(cframe)
						RunService.RenderStepped:Wait()
					until v5 < tick() or not (humanoidRootPart.Parent and humanoidRootPart2.Parent)

					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.FieldOfView = 70
				elseif p == 2 then
					local clone = utils.Ryu.DOF:Clone()
					clone.Parent = game.Lighting
					Debris:AddItem(clone, 0.45)
					local clone2 = utils.Ryu.Lines:Clone()
					clone2.Parent = localPlayer.PlayerGui
					Debris:AddItem(clone2, 0.45)
					clone2.Line1.Rotation = 7
					clone2.Line2.Rotation = 7
					clone2.Line1.Position = UDim2.new(0.1, 0, 0.5, 0)
					clone2.Line2.Position = UDim2.new(1, 0, 0.5, 0)
					local cframe = CFrame.new(
						-0.610998154,
						0.568918705,
						-3.20584297,
						-0.879151344,
						0.442517459,
						-0.176836967,
						0.413873523,
						0.89296639,
						0.176974386,
						0.236223653,
						0.0823992491,
						-0.968198776
					)
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					workspace.CurrentCamera.FieldOfView = 30
					local v5 = tick() + 0.45

					repeat
						workspace.CurrentCamera.CFrame = self.Head.CFrame:ToWorldSpace(cframe)
						RunService.RenderStepped:Wait()
					until v5 < tick() or not (humanoidRootPart.Parent and humanoidRootPart2.Parent)

					if not (humanoidRootPart.Parent and humanoidRootPart2.Parent) then
						return
					end

					task.spawn(function()
						local clone3 = utils.Ryu.DessertImpact:Clone()
						clone3.ViewportFrame.CurrentCamera = workspace.CurrentCamera
						v2:WorldModelChar(self, clone3.ViewportFrame)
						v2:WorldModelChar(instance2, clone3.ViewportFrame)
						clone3.Parent = localPlayer.PlayerGui
						Debris:AddItem(clone3, 2.4)

						for i = 1, #v3 do
							local imageLabel = Instance.new("ImageLabel")
							imageLabel.Name = tostring(i)
							imageLabel.Image = v3[i]
							imageLabel.Size = UDim2.new(0, 1, 0, 1)
							imageLabel.ZIndex = 3
							imageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
							imageLabel.Parent = clone3.Impact
						end

						if _G.Settings.Flash == true then
							local lastTime = tick()

							for i = 1, #v3 do
								clone3.Impact[tostring(i)].Size = UDim2.new(1, 0, 1, 0)

								if i ~= 1 then
									clone3.Impact[tostring(i - 1)]:Destroy()
								end

								repeat
									task.wait()
								until tick() - lastTime >= 0.05

								lastTime = tick()
							end
						else
							clone3.Impact["1"].Size = UDim2.new(1, 0, 1, 0)
							task.wait(#v3 * 0.05)
						end

						clone3.Impact:Destroy()
						clone3.Fade.Visible = true
						TweenService:Create(clone3.Fade, TweenInfo.new(1), {
							BackgroundTransparency = 1
						}):Play()
						TweenService:Create(clone3.Fade, TweenInfo.new(1.3), {
							ImageTransparency = 1
						}):Play()
						TweenService:Create(clone3.BG.ImageLabel, TweenInfo.new(1.4, Enum.EasingStyle.Linear), {
							Position = UDim2.new(0, 0, 0, 0)
						}):Play()
					end)
					local cframe2 = CFrame.new(
						-7.05208826,
						0.152262688,
						-8.68662262,
						-0.746794939,
						-0.0204642545,
						-0.664739549,
						1.86264515e-9,
						0.99952662,
						-0.0307707973,
						0.6650545,
						-0.0229794774,
						-0.746441305
					)
					local v6 = tick() + 2.4

					repeat
						workspace.CurrentCamera.CFrame = humanoidRootPart.CFrame:ToWorldSpace(cframe2)
						RunService.RenderStepped:Wait()
					until v6 < tick() or not (humanoidRootPart.Parent and humanoidRootPart2.Parent)

					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.FieldOfView = 70
					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(1), {
						ExposureCompensation = 0
					}):Play()
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(2)

					if _G.Settings.Flash ~= true then
						return
					end

					local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone3.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone3.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone3.Brightness = 200
					clone3.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone3:Destroy()
				end
			end
		end,
		Hit1 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Ryu.Unsatisfied:FindFirstChild("Hit" .. math.random(1, 3)),
				humanoidRootPart,
				game.SoundService.Effect
			)
			BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
			local v5 = math.random(400, 600) / 10
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.9
			clone.Position = instance.Head.Position
			clone.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v5, v5, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.1)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Weave = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.4)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				child.Transparency = 0.1
				TweenService:Create(child, TweenInfo.new(0.4), {
					Transparency = 1
				}):Play()
			end
		end,
		FinalHit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("ThisDessertService")
	v2 = Knit.GetController("FXController")
end

return controller