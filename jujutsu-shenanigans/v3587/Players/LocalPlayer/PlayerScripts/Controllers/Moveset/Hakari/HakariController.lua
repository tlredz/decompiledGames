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
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HakariController"
})
local v4 = {
	"rbxassetid://17207807777",
	"rbxassetid://17207806991",
	"rbxassetid://17207806413",
	"rbxassetid://17207805758",
	"rbxassetid://17207805299",
	"rbxassetid://17207804676",
	"rbxassetid://17207804009"
}

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		Counter = function(p, p2, color)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.Counter.Startup, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hakari.ShutterDoors.Spawn, humanoidRootPart, game.SoundService.Effect)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(2, 2, 2)
			highlight.OutlineColor = Color3.new(2, 2, 2)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = p2.Doors

			if color then
				p2.Doors.Door1.Color = color
				p2.Doors.Door2.Color = color
				p2.Doors.Door1.Stars.Color = ColorSequence.new(color)
				p2.Doors.Door2.Stars.Color = ColorSequence.new(color)
			end

			TweenService:Create(highlight, TweenInfo.new(0.4), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			Debris:AddItem(highlight, 0.4)
			task.wait(0.2)
			p2.Doors.Door1.Stars.Enabled = false
			p2.Doors.Door2.Stars.Enabled = false
		end,
		Fade = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance, Color3.new(0, 0, 0), 0.3)
			v3:PlaySound(sounds.Hakari.ShutterDoors.Slam, humanoidRootPart, game.SoundService.Effect)
		end,
		CounterHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		CounterEnd = function(_, data)
			TweenService:Create(data.Weld1, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				C1 = CFrame.new(0, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
			TweenService:Create(data.Weld2, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				C1 = CFrame.new(0, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
			}):Play()

			for _, descendant in data.Doors:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") then
					TweenService:Create(descendant, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end
		end,
		CounterSwing = function(p, parent, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.Counter.Swing, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hakari.Counter.Slam, humanoidRootPart, game.SoundService.Effect)
			local clone = parent.Doors:Clone()
			clone.Parent = parent
			parent.Doors:Destroy()
			clone.Door1.Stars:Emit(20)
			clone.Door2.Stars:Emit(20)
			clone.Door1.CanCollide = true
			clone.Door2.CanCollide = true
			clone.Door1.Velocity = humanoidRootPart.CFrame.LookVector * (p2 and -60 or 60) + humanoidRootPart.CFrame.RightVector * 20
			clone.Door2.Velocity = humanoidRootPart.CFrame.LookVector * (p2 and -60 or 60) + humanoidRootPart.CFrame.RightVector * 20

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end
			end
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(instance, p, p2)
			if instance:GetAttribute("InUlt") then
				if p2 == "Down" then
					v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(85, 255, 127), 0.4)
				elseif p == 1 or p == 4 then
					v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(85, 255, 127), 0.3)
				else
					v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(85, 255, 127), 0.3)
				end
			elseif p2 == "Up" then
				v3:ArmFlash(instance["Left Leg"], Color3.fromRGB(85, 255, 127), 0.4)
			elseif p2 == "Down" then
				v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(85, 255, 127), 0.4)
			elseif p == 4 then
				v3:ArmFlash(instance["Left Leg"], Color3.fromRGB(85, 255, 127))
			else
				v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(85, 255, 127), 0.3)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Surge = function(instance, data)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			data.EnergyBurst:Emit(20)
			v3:Flash(instance, Color3.fromRGB(85, 255, 127), 1)
			v3:PlaySound(sounds.Hakari.OverLuck.Charge, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)

				repeat
					task.wait()
				until not data.Parent or data.Surge.Enabled == false

				shakeSustain:StartFadeOut(1)
			end
		end,
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.IdleDeath.Voice, humanoidRootPart, game.SoundService.Voice)
			v3:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v3:Domain(instance, function(p, instance2)
						instance2.Humanoid:LoadAnimation(animations.Hakari.DomainWarn):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://16069822951"
					end)
				end
			end
		end,
		Opening = function(parent, p, p2, p3)
			local clone = utils.Hakari.IdleDeath.DomainBG:Clone()
			clone.Parent = parent
			clone.CFrame = parent.CFrame
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				clone:Destroy()
			end)
			local clone2

			if p3 then
				clone2 = nil
			else
				local domainGround = p.DomainGround
				domainGround.Surround.ShapePartial = 1
				domainGround.Surround.Enabled = true
				Debris:AddItem(domainGround, 2)
				v3:PlaySound(sounds.Hakari.IdleDeath.IdleDeath, workspace, game.SoundService.Effect)
				task.delay(0.5, function()
					TweenService:Create(domainGround, TweenInfo.new(0.25), {
						Transparency = 0
					}):Play()
					v3:DomainMapFade(Color3.new(1, 1, 1), 0.25, 1)
				end)
				task.wait(1)

				if not (p2 and p2.Parent) then
					return
				end

				clone2 = utils.Hakari.IdleDeath.DomainInfo:Clone()
				clone2.Scenario1.Text = "Transit Card Richii (☆ ☆ ★)"
				clone2.Scenario2.Text = "Travel Emergency Richii (☆ ★ ★)"
				clone2.Parent = localPlayer.PlayerGui
				Debris:AddItem(clone2, 15)
				task.spawn(function()
					local v6 = 0

					for _, label in clone2:GetChildren() do
						if not label:IsA("TextLabel") then
							continue
						end

						TweenService:Create(
							label,
							TweenInfo.new(15, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
							{
								TextTransparency = 1,
								TextStrokeTransparency = 1
							}
						):Play()
						local position = label.Position
						label.Position = position + UDim2.new(label.AnchorPoint.X == 1 and 0.5 or -0.5, 0, 0, 0)
						TweenService:Create(
							label,
							TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Position = position
							}
						):Play()
					end

					repeat
						for _, label in clone2:GetChildren() do
							if label:IsA("TextLabel") then
								label.TextColor3 = Color3.fromHSV(v6, 1, 1)
							end
						end

						task.wait()
						v6 = (v6 + 0.01) % 1
					until not clone2.Parent
				end)

				for _, image in v4 do
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Size = UDim2.new(0, 0, 0, 0)
					imageLabel.Image = image
					imageLabel.Parent = clone2
				end
			end

			local v6 = v3:PlaySound(sounds.Hakari.IdleDeath.Music, workspace, game.SoundService.Music, true)
			local v7 = v3:PlaySound(sounds.Hakari.IdleDeath.Travel, workspace, game.SoundService.Effect, true)
			game.SoundService.AmbientReverb = Enum.ReverbType.Alley
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
				TweenService:Create(v6, TweenInfo.new(2), {
					PlaybackSpeed = 0
				}):Play()
				Debris:AddItem(v6, 2)

				if v7 then
					v7:Destroy()
				end

				if clone2 and clone2.Parent then
					clone2:Destroy()
				end
			end)
			clone:GetAttributeChangedSignal("OhYeah"):Connect(function()
				TweenService:Create(v6, TweenInfo.new(2), {
					PlaybackSpeed = 0,
					Volume = 0
				}):Play()
			end)
			clone.Speedlines.Enabled = true
			local clone3 = utils.Hakari.IdleDeath.Segment:Clone()
			local clone4 = utils.Hakari.IdleDeath.Segment:Clone()
			clone3.CFrame = parent.CFrame * CFrame.new(40, 0, 400) * CFrame.Angles(0, 3.141592653589793, 0)
			clone4.CFrame = parent.CFrame * CFrame.new(-40, 0, 400)

			for i = 1, 50 do
				local clone5 = utils.Hakari.IdleDeath.Segment:Clone()
				clone5.CFrame = clone3.CFrame * CFrame.new(0, 0, i * -8)
				clone5.Anchored = false
				clone5.WeldConstraint.Part1 = clone3
				clone5.Parent = clone3
				local clone6 = clone5:Clone()
				clone6.CFrame = clone4.CFrame * CFrame.new(0, 0, i * 8)
				clone6.WeldConstraint.Part1 = clone4
				clone6.Parent = clone4
			end

			clone3.Parent = parent
			clone4.Parent = parent
			TweenService:Create(clone3, TweenInfo.new(0.5), {
				CFrame = parent.CFrame * CFrame.new(40, 0, -200) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.5), {
				CFrame = parent.CFrame * CFrame.new(-40, 0, -200)
			}):Play()
			local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
			task.wait(0.5)
			local numberValue = Instance.new("NumberValue", clone)
			numberValue.Value = 0
			TweenService:Create(
				numberValue,
				TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
				{
					Value = 90
				}
			):Play()
			Debris:AddItem(numberValue, 1.5)

			repeat
				clone.CFrame = parent.CFrame * CFrame.Angles(
					math.rad(numberValue.Value),
					0,
					(math.rad(numberValue.Value * 2))
				)
				clone3.CFrame = clone.CFrame * CFrame.new(40, 0, -200 + math.random(-200, 200) / 100) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
				clone4.CFrame = clone.CFrame * CFrame.new(-40, 0, -200 + math.random(-200, 200) / 100)
				task.wait()
			until not (numberValue.Parent and clone3.Parent)

			shakeSustain:StartFadeOut(1)

			if not clone.Parent then
				return
			end

			clone.Speedlines:Destroy()
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Color = Color3.fromRGB(160, 160, 160)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.5), {
				CFrame = clone.CFrame * CFrame.new(40, 0, -800) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.5), {
				CFrame = clone.CFrame * CFrame.new(-40, 0, -800)
			}):Play()
			Debris:AddItem(clone3, 0.5)
			Debris:AddItem(clone4, 0.5)
			clone.CFrame = parent.CFrame
			local clone5 = utils.Hakari.IdleDeath.Normal:Clone()
			clone5.CFrame = parent.CFrame * CFrame.new(0, -150, 0)
			clone5.Parent = clone
			TweenService:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = parent.CFrame
			}):Play()
			local children = clone5:GetChildren()

			for i = 1, 16 do
				local v8 = CFrame.new() * CFrame.Angles(0, math.rad((i - 1) * 22.5), 0)
				children[i].Weld.C1 = v8 * CFrame.new(0, 0, 50) * CFrame.Angles(0, 1.5707963267948966, 0)
			end
		end,
		Richii = function(_, instance, jackpot, p, p2)
			local domainBG = instance:FindFirstChild("DomainBG")

			if not domainBG then
				return
			end

			local normal = domainBG:FindFirstChild("Normal")

			if not normal then
				return
			end

			local v6 = p2 and p2 == 2 and 1.667 or 1
			local v7 = { utils.Hakari.IdleDeath.Scenarios.IC, utils.Hakari.IdleDeath.Scenarios.P }
			TweenService:Create(normal, TweenInfo.new(0), {
				CFrame = instance.CFrame * CFrame.new(0, -250, 0)
			}):Play()
			local clone = v7[p]:Clone()
			clone:SetAttribute("Jackpot", jackpot)
			clone:SetAttribute("Speed", v6)
			clone:PivotTo(instance.CFrame)
			clone.Parent = domainBG.Scenario
			clone.ScenarioPlay.Enabled = true
			game.Lighting.ExposureCompensation = 15
			TweenService:Create(game.Lighting, TweenInfo.new(1), {
				ExposureCompensation = 0
			}):Play()
			task.wait(3 / v6)

			if jackpot then
				domainBG:SetAttribute("OhYeah", true)
				local v8 = v3:PlaySound(
					utils.Hakari.IdleDeath.Aura.Torso.JackpotMusic,
					domainBG,
					game.SoundService.Music
				)
				v8.TimePosition -= 3 / v6
				v8.Volume = 0
				TweenService:Create(v8, TweenInfo.new(2), {
					Volume = 1
				}):Play()
			end

			task.wait(3 / v6)

			if not instance.Parent or jackpot then
				return
			end

			domainBG.Scenario:ClearAllChildren()
			TweenService:Create(normal, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = instance.CFrame
			}):Play()
			game.Lighting.ExposureCompensation = -15
			TweenService:Create(game.Lighting, TweenInfo.new(1), {
				ExposureCompensation = 0
			}):Play()
		end,
		Roll = function(p, p2)
			local clone = utils.Hakari.IdleDeath.Roll:Clone()
			clone.Parent = localPlayer.PlayerGui
			Debris:AddItem(clone, 3)

			if p then
				clone.Number1.Image = v4[p]
				v3:PlaySound(sounds.Hakari.IdleDeath.Roll, workspace, game.SoundService.Effect)
				TweenService:Create(
					clone.Number1,
					TweenInfo.new(0.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0.225, 0, 0.5, 0)
					}
				):Play()
				TweenService:Create(
					clone.Number1,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						ImageTransparency = 1
					}
				):Play()
				task.wait(0.15)
				clone.Number3.Image = v4[p]
				v3:PlaySound(sounds.Hakari.IdleDeath.Roll, workspace, game.SoundService.Effect)
				TweenService:Create(
					clone.Number3,
					TweenInfo.new(0.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0.775, 0, 0.5, 0)
					}
				):Play()
				TweenService:Create(
					clone.Number3,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						ImageTransparency = 1
					}
				):Play()
				task.wait(0.15)
			end

			if p2 then
				clone.Number2.Image = v4[p2]
				v3:PlaySound(sounds.Hakari.IdleDeath.Roll, workspace, game.SoundService.Effect)
				TweenService:Create(
					clone.Number2,
					TweenInfo.new(0.75, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0.5, 0, 0.5, 0)
					}
				):Play()
				TweenService:Create(
					clone.Number2,
					TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						ImageTransparency = 1
					}
				):Play()

				if p2 == p then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
					v3:PlaySound(sounds.Hakari.IdleDeath.Jackpot, workspace, game.SoundService.Effect)
				end
			end
		end,
		Jackpot = function(instance, data, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hakari.IdleDeath.Jackpot:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame
			clone.EnergyBurst:Emit(7)
			clone.Ring:Emit(7)
			clone.Sparks:Emit(21)
			Debris:AddItem(clone, 1)
			task.spawn(function()
				local clone2 = utils.Hakari.Dialogue:Clone()
				clone2.Parent = instance.Torso

				if p then
					clone2.Chat1.Sub.Text = "IN THE NEXT 50 SECONDS..."
				end

				local position = clone2.Chat1.Position
				clone2.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
				TweenService:Create(clone2.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = position
				}):Play()
				TweenService:Create(clone2.Chat1, TweenInfo.new(0.3), {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone2.Chat1.Sub, TweenInfo.new(0.3), {
					TextTransparency = 0
				}):Play()
				task.wait(0.5)
				local position2 = clone2.Chat2.Position
				clone2.Chat2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
				TweenService:Create(clone2.Chat2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = position2
				}):Play()
				TweenService:Create(clone2.Chat2, TweenInfo.new(0.3), {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone2.Chat2.Sub, TweenInfo.new(0.3), {
					TextTransparency = 0
				}):Play()
				task.wait(2)
				Debris:AddItem(clone2, 0.6)

				for _, guiObject in clone2:GetDescendants() do
					if guiObject:IsA("Frame") then
						TweenService:Create(
							guiObject,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
								BackgroundTransparency = 1
							}
						):Play()
					elseif guiObject:IsA("TextLabel") then
						TweenService:Create(
							guiObject,
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								TextTransparency = 1
							}
						):Play()
					end
				end
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local clone2 = utils.Hakari.IdleDeath.AudioVis:Clone()
				clone2.Parent = localPlayer.PlayerGui
				local v6 = {
					[49.375] = "You struck me,",
					[51.03] = "boy, you knocked me down",
					[52.9] = "Was never looking for you but you called me out",
					[57.01] = "You caught me and I can't get enough",
					[60.7] = "I'm trippin' out, I'm trippin' out",
					[62.8] = "I'm trippin' out on love",
					[64.13] = "I gotta pinch myself so I know it's real",
					[68.26] = "With you next to me, I am strong as steel",
					[71.91] = "Boy, you struck me, can't get enough",
					[76.06] = "I'm trippin' out, I'm trippin' out",
					[78.04] = "I'm trippin' out on love",
					[80.84] = ""
				}

				while true do
					for k, text in v6 do
						if not (k < data.TimePosition) then
							continue
						end

						clone2.Lyrics.Text = text
						v6[k] = nil
						break
					end

					local v7 = math.clamp(2 - data.PlaybackLoudness / 330, 1, 1e999)
					clone2.Beat.Size = clone2.Beat.Size:Lerp(UDim2.new(v7, 0, v7, 0), 0.5)
					task.wait()

					if not (not data.Parent or data.Volume ~= 1) then
						continue
					end

					TweenService:Create(clone2.Beat, TweenInfo.new(0.25), {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.25)
					break
				end
			end
		end,
		Shatter = function(position)
			local clone = utils.Domain:Clone()
			clone.Transparency = 1
			clone.CanCollide = false
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, child in clone:GetChildren() do
				if child.Name == "Shatter" then
					child:Emit(100)
				else
					child:Destroy()
				end
			end

			v3:PlaySound(sounds.Hakari.IdleDeath.Shatter, clone, game.SoundService.Effect)
			clone.Transparency = 0
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
	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync(v4)
	end)
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("HakariService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller