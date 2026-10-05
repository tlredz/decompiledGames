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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "TimeCellMoonPalaceController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.MoonPalace.Voice, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Torso.CFrame, 50, 360, 360)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = humanoidRootPart
				clone:Emit(80)
				Debris:AddItem(clone, 2)
			end

			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, instance2)
						instance2.Humanoid:LoadAnimation(animations.Naoya.DomainWarn):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://5141175245"
						p.Panel.ImageLabel.Size = UDim2.new(0.7, 0, 0.7, 0)
						p.Panel.ImageLabel.ImageColor3 = Color3.fromRGB(49, 28, 39)
						p.Panel.Viewport.LightColor = Color3.fromRGB(170, 170, 255)
						p.Panel.Viewport.Ambient = Color3.fromRGB(77, 59, 60)
						p.Panel.Viewport.LightDirection = createVector(0, 1, 0)
						local clone = utils.Naoya.MoonPalace.Eye:Clone()
						clone.Parent = p.Panel
						TweenService:Create(
							clone,
							TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.5, 0, 0.5, 0)
							}
						):Play()
						TweenService:Create(
							clone.ImageLabel,
							TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(0.7, 0, 0.7, 0),
								Rotation = 100
							}
						):Play()
					end)
				end
			end
		end,
		Opening = function(parent, p, p2, p3)
			local clone = utils.Naoya.MoonPalace.DomainBG:Clone()
			clone.Parent = parent
			clone.CFrame = parent.CFrame
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				clone:Destroy()
			end)

			if not p3 then
				local domainGround = p.DomainGround
				domainGround.Surround.Enabled = true
				TweenService:Create(domainGround.Surround, TweenInfo.new(0.8), {
					ShapePartial = 1
				}):Play()
				Debris:AddItem(domainGround, 2)
				local v4 = v2:PlaySound(sounds.Naoya.MoonPalace.Flicker, workspace, game.SoundService.Effect)
				TweenService:Create(v4, TweenInfo.new(3), {
					PlaybackSpeed = 2,
					Volume = 0
				}):Play()
				Debris:AddItem(v4, 3)
				task.delay(0.8, function()
					TweenService:Create(domainGround, TweenInfo.new(0.4), {
						Transparency = 0
					}):Play()
					v2:DomainMapFade(Color3.new(0, 0, 0), 0.4, 1.6)
				end)
				task.wait(1.5)
			end

			if not (p2 and p2.Parent) then
				return
			end

			local v4 = v2:PlaySound(sounds.Naoya.MoonPalace.Music, workspace, game.SoundService.Music, true)
			game.SoundService.AmbientReverb = Enum.ReverbType.Arena
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
			colorCorrectionEffect.Name = "DomainCC"
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5), {
				Brightness = 0.1,
				Contrast = 2,
				TintColor = Color3.fromRGB(255, 174, 174)
			}):Play()
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = workspace.Characters
			TweenService:Create(highlight, TweenInfo.new(0.5), {
				OutlineTransparency = 0
			}):Play()
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
				TweenService:Create(v4, TweenInfo.new(2), {
					Volume = 0
				}):Play()
				Debris:AddItem(v4, 2)
				colorCorrectionEffect:Destroy()
				highlight:Destroy()
			end)
			local model = clone.Model
			model:PivotTo(clone.CFrame * CFrame.Angles(0, -1.5707963267948966, 0) - createVector(0, 9, 0))

			if p3 then
				model.Eye.Size = createVector(30, 30, 30)
			else
				for _, v5 in model.Model:QueryDescendants("BasePart") do
					local size = v5.Size
					v5.Size = createVector(0, 0, 0)
					local cFrame = v5.CFrame
					v5.CFrame = (cFrame - Vector3.new(0, math.random(100, 200), 0)) * CFrame.Angles(
						math.random(-3.141592653589793, 3.141592653589793),
						math.random(-3.141592653589793, 3.141592653589793),
						math.random(-3.141592653589793, 3.141592653589793)
					)
					TweenService:Create(v5, TweenInfo.new(math.random(10, 20) / 10, Enum.EasingStyle.Exponential), {
						CFrame = cFrame
					}):Play()
					TweenService:Create(
						v5,
						TweenInfo.new(math.random(15, 40) / 10, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
						{
							Size = size
						}
					):Play()
				end

				task.wait(0.5)
				TweenService:Create(model.Eye, TweenInfo.new(0.5), {
					Size = createVector(30, 30, 30)
				}):Play()
			end

			task.spawn(function()
				repeat
					model.Eye.CFrame = CFrame.lookAt(model.Eye.Position, workspace.CurrentCamera.CFrame.Position)
					task.wait()
				until not clone.Parent
			end)
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

			v2:PlaySound(sounds.Naoya.MoonPalace.Shatter, clone, game.SoundService.Effect)
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
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Naoya.MoonPalace.Hit:Clone()

			if _G.Settings.Gore ~= true then
				clone.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
			end

			clone.Parent = instance.Torso
			Debris:AddItem(clone, 0.2)
			task.delay(0.1, function()
				clone.Enabled = false
			end)
			BloodyZee:Blood(instance.Torso.CFrame, 50, 180, 180)

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 100 then
					return
				end

				local random = Random.new()
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
				local clone2 = utils.Gojo.Shard:Clone()
				local unit = random:NextUnitVector().Unit
				clone2.Size = Vector3.new(0.2, math.random(5, 20) / 10, math.random(5, 20) / 10)
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-4, 4), 0)
				clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
				clone2.CanCollide = true
				clone2.CollisionGroup = "Effects"
				clone2.Parent = workspace.Effects
				clone2.Transparency = 0.5
				clone2.Color = utils.Naoya.NaoyaGlass.Color
				clone2.Material = Enum.Material.Neon
				clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone2.Velocity = unit * math.random(50, 100)
				TweenService:Create(clone2, tweenInfo, {
					Size = createVector(0, 0, 0)
				}):Play()
				Debris:AddItem(clone2, 1)
			end
		end,
		Form = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.Variants.Transform3, humanoidRootPart, game.SoundService.Effect)
			local curseBody = instance2.CurseBody
			local color = instance2.Body.Color

			repeat
				task.wait()
			until not instance2:IsDescendantOf(workspace)

			for _ = 1, 15 do
				local clone = utils.Mahito.Morph:Clone()
				clone.Weld.Part0 = humanoidRootPart
				clone.Color = curseBody.Color
				clone.Material = curseBody.Material
				clone.Weld.C0 = CFrame.new(
					math.random(-200, 200) / 100,
					math.random(-300, -200) / 100,
					math.random(-300, 300) / 100
				)
				clone.Parent = workspace.Effects
				local v4 = math.random(100, 250) / 100
				local v5 = math.random(40, 80) / 100
				clone.Size = createVector(1, 1, 1) * v4
				clone.Color = color
				TweenService:Create(clone, TweenInfo.new(v5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone.Weld, TweenInfo.new(v5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					C0 = CFrame.new(0, -2, 0)
				}):Play()
				Debris:AddItem(clone, v5)
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
	v = Knit.GetService("TimeCellMoonPalaceService")
	v2 = Knit.GetController("FXController")
end

return controller