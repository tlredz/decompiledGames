local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SeaOfBranchesController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hanami.DomainVL, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, parent)
						parent.HumanoidRootPart.CFrame *= CFrame.new(0, 1.5, 1.5)
						parent.Humanoid:LoadAnimation(animations.Hanami.Domain):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://114997336495273"
						p.Panel.ImageLabel.Size = UDim2.new(0.8, 0, 0.25, 0)
						p.Panel.Viewport.LightColor = Color3.fromRGB(170, 255, 255)
						p.Panel.Viewport.Ambient = Color3.fromRGB(255, 255, 255)
						p.Panel.Viewport.LightDirection = createVector(0, -1, 0)
						TweenService:Create(p.Panel.Viewport, TweenInfo.new(1.5), {
							LightColor = Color3.fromRGB(254, 255, 197),
							Ambient = Color3.fromRGB(255, 251, 194)
						}):Play()
						local clone = game.ReplicatedStorage.Utils.Hanami.FlowerCannon:Clone()
						clone.Weld.Part0 = parent["Left Arm"]
						clone.Parent = parent
						parent["Right Arm"].FingersR:Destroy()
						parent["Left Arm"].FingersL:Destroy()
					end)
				end
			end
		end,
		Absorb = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local leftArm = instance["Left Arm"]
			local clone = replicatedStorage.Utils.Hanami.EmpowerCharge:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(2)
			clone.Parent = workspace.Effects
			model:Destroy()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3 * instance:GetScale(), 0) * CFrame.new(0, 0.1, 0)
			local raycastResult = workspace:Raycast(leftArm.Position, createVector(-0, -20, -0), _G.MapParams)

			if raycastResult then
				clone.Position = raycastResult.Position + createVector(0, 0.1, 0)
			end

			TweenService:Create(clone.PointLight, TweenInfo.new(0.7), {
				Brightness = 5
			}):Play()
			task.spawn(function()
				for _ = 1, 3 do
					if not clone.Parent then
						break
					end

					clone.Charge.Ring:Emit(1)
					task.wait(0.3)
				end
			end)
			Debris:AddItem(clone, 4)
			instance2:GetPropertyChangedSignal("Value"):Connect(function()
				TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
				clone.Charge.Light:Emit(1)
			end)
			instance2.Destroying:Connect(function()
				if instance2.Value == true then
					return
				end

				clone:Destroy()
			end)

			repeat
				task.wait()
				local raycastResult2 = workspace:Raycast(leftArm.Position, createVector(-0, -20, -0), _G.MapParams)

				if raycastResult2 then
					clone.Position = raycastResult2.Position + createVector(0, 0.1, 0)
				end
			until instance2.Parent == nil or instance2.Value == true
		end,
		FloorEffect = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hanami.Domain.CenterGround:Clone()
			clone.Parent = workspace.Effects
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(-0, -20, -0), _G.MapParams)

			if raycastResult then
				clone.Position = raycastResult.Position - createVector(0, 1, 0)
			end

			local size = clone.Size * createVector(0.5, 1, 0.5)
			clone.Size = createVector(1, 1, 1)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = size
			}):Play()

			for _, child in clone:GetChildren() do
				child.Enabled = true
			end

			task.wait(0.5)

			for _, child in clone:GetChildren() do
				if child.Name:sub(1, 1) == "F" then
					child.ShapePartial = 1
				else
					child.Enabled = false
				end
			end

			task.wait(1.5)
			clone:Destroy()
		end,
		Fade = function(p, items)
			for _, item in items do
				local part = Instance.new("Part")
				part.CanCollide = false
				part.Massless = true
				part.Anchored = true
				part.Position = item[1]
				part.Orientation = item[2]
				part.Color = item[3]
				part.Material = item[4]
				part.Size = item[5] * createVector(1.3, 1.3, 1.3)
				part.Parent = workspace.Effects
				Debris:AddItem(part, 3)
				local v4 = (part.Position - p).Magnitude / 75
				task.delay(v4 * 1.5, function()
					part.Color = Color3.fromRGB(111, 111, 111)
				end)
			end
		end,
		Opening = function(parent, instance, p, p2, _)
			local v4 = nil
			local clone = utils.Hanami.Domain.HanamiDomain:Clone()
			clone:PivotTo(parent.CFrame)
			task.spawn(function()
				repeat
					task.wait()
				until not (p.Parent and p.Parent.Parent and p.Parent.Parent.Parent)

				clone:Destroy()

				if v4 and v4.Parent then
					v4:Destroy()
				end
			end)

			if not p2 then
				parent.Transparency = 0
				clone.DomainBG.Center.Size = createVector(141.37, 2, 141.37)
				clone.DomainBG.Center.Position += createVector(0, 9, 0)
				clone.DomainBG.Center.Transparency = 1
			end

			clone.Parent = parent
			local domainGround = instance:FindFirstChild("DomainGround")

			if domainGround then
				domainGround.Surround.Enabled = true
				TweenService:Create(domainGround.Surround, TweenInfo.new(0.8), {
					ShapePartial = 1
				}):Play()
				Debris:AddItem(domainGround, 2)
				task.delay(0.8, function()
					TweenService:Create(domainGround, TweenInfo.new(0.4), {
						Transparency = 0
					}):Play()
					v2:DomainMapFade(Color3.fromRGB(0, 0, 0), 0.5, 1.5)
				end)
			end

			if not p2 then
				task.wait(1.5)
				TweenService:Create(clone.DomainBG.Center, TweenInfo.new(0.5), {
					Transparency = 0
				}):Play()
				task.wait(0.3)
			end

			v4 = v2:PlaySound(sounds.Hanami.DomainOST, workspace, game.SoundService.Music)

			for _, part in clone.DomainBG.Emitters:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				for _, child in part:GetChildren() do
					child:Clear()
					local v5 = child
					local v6 = part
					task.delay(child:GetAttribute("EmitDelay") or 0, function()
						v5:Emit(v6:GetAttribute("EmitCount"))

						if v5.Name:sub(1, 1) == "F" then
							task.wait(0.5)
							v5.TimeScale = 0
						end
					end)
				end
			end

			task.spawn(function()
				local center = clone.DomainBG.Skybox.Center
				local _ = center.Position.Y
				local currentCamera = workspace.CurrentCamera

				while center.Parent do
					local position = currentCamera.CFrame.Position
					center.CFrame = CFrame.lookAlong(position, center.CFrame.LookVector)
					task.wait()
				end
			end)
			task.wait(0.5)
			TweenService:Create(parent, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
		end,
		Shatter = function(position)
			local clone = utils.Domain:Clone()
			clone.Transparency = 1
			clone.CanCollide = false
			clone.Position = position
			clone.Shatter.Color = ColorSequence.new(Color3.new(0, 0, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, child in clone:GetChildren() do
				if child.Name == "Shatter" then
					child:Emit(100)
				else
					child:Destroy()
				end
			end

			v2:PlaySound(sounds.Itadori.MalevolantShrine.Shatter, clone, game.SoundService.Effect)
			clone.Transparency = 0
			clone.Color = Color3.new(0, 0, 0)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 150 then
					return
				end

				local random = Random.new()
				local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 80 do
					local clone2 = utils.Gojo.Shard:Clone()
					local unit = random:NextUnitVector().Unit
					clone2.Size = Vector3.new(0.1, math.random(1, 8), math.random(1, 8))
					clone2.CFrame = CFrame.lookAlong(position, unit) * CFrame.Angles(1.5707963267948966, 0, 0) + unit * 37.5
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.Color = Color3.new(0, 0, 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = workspace.Effects
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Transparency = 0
					clone2.Material = Enum.Material.Neon
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 4)
				end
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
	v = Knit.GetService("SeaOfBranchesService")
	v2 = Knit.GetController("FXController")
end

return controller