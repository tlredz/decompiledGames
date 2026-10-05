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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SelfPerfectionController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.SelfPerfection.Voice, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, parent)
						parent.Humanoid:LoadAnimation(animations.Mahito.DomainWarn):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://15049595421"
						p.Panel.ImageLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
						p.Panel.Viewport.LightColor = Color3.fromRGB(255, 170, 255)
						p.Panel.Viewport.Ambient = Color3.fromRGB(50, 30, 50)
						p.Panel.Viewport.LightDirection = createVector(0, -1, 0)
						TweenService:Create(p.Panel.Viewport, TweenInfo.new(1.5), {
							LightColor = Color3.fromRGB(170, 255, 255),
							Ambient = Color3.fromRGB(0, 55, 85)
						}):Play()
						local clone = utils.Mahito.SelfPerfection.Head:Clone()
						clone.Head.Weld.Part0 = parent.Head
						clone.Mouth.Weld.Part0 = parent.Head
						clone.Head.Transparency = 1
						clone.Mouth.Transparency = 1
						clone.Mouth.Hands.Color = parent.Head.Color
						clone.Parent = parent
					end)
				end
			end
		end,
		Opening = function(parent, p, p2, p3, p4)
			local clone = utils.Mahito.SelfPerfection.DomainBG:Clone()
			clone.Parent = parent
			clone.CFrame = parent.CFrame
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				clone:Destroy()
			end)
			local hands = clone.Hands
			local track = hands.AnimationController:LoadAnimation(hands.AnimationController.Animation)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)

			for _, v4 in hands:QueryDescendants("BasePart") do
				v4.Size = createVector(0, 0, 0)
			end

			if p3 then
				local v4 = v2:PlaySound(sounds.Mahito.SelfPerfection.Music, workspace, game.SoundService.Music, true)
				game.SoundService.AmbientReverb = Enum.ReverbType.Arena
				task.spawn(function()
					repeat
						task.wait()
					until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

					game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
					TweenService:Create(v4, TweenInfo.new(3), {
						Volume = 0
					}):Play()
					Debris:AddItem(v4, 3)
				end)
			else
				local domainGround = p.DomainGround
				domainGround.Surround.Enabled = true
				TweenService:Create(domainGround.Surround, TweenInfo.new(0.8), {
					ShapePartial = 1
				}):Play()
				Debris:AddItem(domainGround, 2)
				task.delay(0.8, function()
					TweenService:Create(domainGround, TweenInfo.new(0.4), {
						Transparency = 0
					}):Play()
					v2:DomainMapFade(Color3.fromRGB(0, 0, 0), 0.4, 1.6)
				end)
				local v4 = nil
				game.SoundService.AmbientReverb = Enum.ReverbType.Arena
				task.spawn(function()
					repeat
						task.wait()
					until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

					game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb

					if not v4 then
						return
					end

					TweenService:Create(v4, TweenInfo.new(3), {
						Volume = 0
					}):Play()
					Debris:AddItem(v4, 3)
				end)
				task.wait(1)
				v4 = v2:PlaySound(sounds.Mahito.SelfPerfection.Music, workspace, game.SoundService.Music, true)
				task.wait(0.5)
			end

			clone.Stars.Enabled = true
			clone.Rays.Enabled = true

			for _, part in hands:GetDescendants() do
				if part:IsA("BasePart") then
					TweenService:Create(part, tweenInfo, {
						Size = createVector(20, 80, 20)
					}):Play()
				end
			end

			v2:PlaySound(sounds.Mahito.SelfPerfection.Perfection, workspace, game.SoundService.Effect)
			hands:SetPrimaryPartCFrame(clone.CFrame * CFrame.new(0, 10, 120))
			track:Play(0)
			track:GetMarkerReachedSignal("Loop"):Connect(function()
				track.TimePosition = 1.5
			end)

			for i = 1, 10 do
				local v4 = i * 36
				local cframe = CFrame.Angles(0, 0, (math.rad(v4)))
				local position = (clone.CFrame * cframe - (clone.CFrame * cframe).LookVector * 120).Position
				task.delay(i % 2 == 0 and 0 or 0.2, function()
					for i2 = 1, 15 do
						v4 = i2 * 12
						local v6 = cframe * CFrame.Angles(math.rad(v4), 0, 0)
						local position2 = (clone.CFrame * v6 - (clone.CFrame * v6).LookVector * 120).Position
						local cframe2 = CFrame.new(position, position2)
						local clone2 = utils.Mahito.SelfPerfection.Hand:Clone()
						clone2.CFrame = cframe2
						clone2.Parent = clone.HandFolder

						if p4 and i2 <= 8 then
							clone2.Size = createVector(10, 10, 30)
							clone2.CFrame = (cframe2 + cframe2.LookVector * 5) * CFrame.Angles(
								math.rad((math.random(-10, 10))),
								math.rad((math.random(-10, 10))),
								(math.rad((math.random(0, 360))))
							)
						else
							TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
								Size = createVector(10, 10, 30),
								CFrame = (cframe2 + cframe2.LookVector * 5) * CFrame.Angles(
									math.rad((math.random(-10, 10))),
									math.rad((math.random(-10, 10))),
									(math.rad((math.random(0, 360))))
								)
							}):Play()
							task.wait(0.2)
						end

						position = position2

						if not clone.Parent then
							break
						end
					end
				end)
			end
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
	v = Knit.GetService("SelfPerfectionService")
	v2 = Knit.GetController("FXController")
end

return controller