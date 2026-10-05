local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "HiromiController"
})

local function dialogBox(p, text)
	if p.Head:FindFirstChild("HiromiText") then
		p.Head.HiromiText:Destroy()
	end

	v3:PlaySound(sounds.Hiromi.DeadlySentence.Talk, p.Head, game.SoundService.Voice)
	local clone = utils.Hiromi.DeadlySentencing.HiromiText:Clone()
	clone.TextLabel.Text = text
	clone.Parent = p.Head
	Debris:AddItem(clone, 1.5)
	task.delay(1, function()
		if not clone.Parent then
			return
		end

		TweenService:Create(clone.TextLabel, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
		TweenService:Create(clone.TextLabel.UIStroke, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	end)
end

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		Dodge2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			local v5 = {
				"Dodge1",
				"Dodge2",
				"Dodge3",
				"Dodge4",
				"Dodge5"
			}

			for _, v6 in instance.Humanoid:GetPlayingAnimationTracks() do
				if table.find(v5, v6.Name) then
					v6:Stop(0.02)
				end
			end

			instance.Humanoid:LoadAnimation(animations.Hiromi.Dodge:GetChildren()[math.random(1, 5)]):Play(0.02)
		end,
		Dodge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(1, 0.807843, 0.423529)
				child.Anchored = true
				child.Transparency = 0.1
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			local v5 = {
				"Dodge1",
				"Dodge2",
				"Dodge3",
				"Dodge4",
				"Dodge5"
			}

			for _, v6 in instance.Humanoid:GetPlayingAnimationTracks() do
				if table.find(v5, v6.Name) then
					v6:Stop(0.02)
				end
			end

			instance.Humanoid:LoadAnimation(animations.Hiromi.Dodge:GetChildren()[math.random(1, 5)]):Play(0.02)
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
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
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
		Swing2 = function(data, p, p2)
			local humanoidRootPart = data.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(179, 130, 61), 0.4)
				v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
			elseif p2 == "Up" then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(179, 130, 61), 0.3)
				v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
			else
				local gavel = data.SetAssets:FindFirstChild("Gavel")
				local execSword = data.SetAssets:FindFirstChild("ExecSword")

				if gavel then
					v3:PlaySound(sounds.Hiromi.M1Swing["Swing" .. p], humanoidRootPart, game.SoundService.Effect)

					if p == 3 then
						local clone = utils.Hiromi.CombatTrail2:Clone()
						clone.Color = Color3.fromRGB(179, 130, 61)
						clone.Trail.Color = ColorSequence.new(Color3.fromRGB(179, 130, 61))
						clone.Weld.Part0 = gavel
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, 0.2)
					else
						local clone = utils.Hiromi.CombatTrail:Clone()
						clone.Color = Color3.fromRGB(179, 130, 61)
						clone.Trail.Color = ColorSequence.new(Color3.fromRGB(179, 130, 61))
						clone.Weld.Part0 = gavel
						clone.Parent = workspace.Effects
						task.wait(p == 2 and 0.6 or 0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, 0.2)
					end
				elseif execSword then
					if p == 4 then
						v3:ArmFlash(data["Left Arm"], Color3.fromRGB(179, 130, 61), 0.3)
						v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
					else
						v3:PlaySound(
							sounds.Hiromi.M1SwordSwing["Swing" .. p],
							humanoidRootPart,
							game.SoundService.Effect
						)
					end
				end
			end
		end,
		Chat = function(instance, p, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.spawn(function()
				local clone = utils.Hiromi.Dialogue:Clone()
				clone.Parent = instance.Torso
				local position = clone.Chat1.Position
				clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
				TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = position
				}):Play()
				TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
					TextTransparency = 0
				}):Play()
				task.wait(0.7)
				local position2 = clone.Chat2.Position
				clone.Chat2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
				TweenService:Create(clone.Chat2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = position2
				}):Play()
				TweenService:Create(clone.Chat2, TweenInfo.new(0.3), {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone.Chat2.Sub, TweenInfo.new(0.3), {
					TextTransparency = 0
				}):Play()
				task.wait(1.3)
				Debris:AddItem(clone, 0.6)

				for _, guiObject in clone:GetDescendants() do
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
			v3:PlaySound(sounds.Hiromi.Awaken, humanoidRootPart, game.SoundService.Effect)

			for _, child in instance2:GetChildren() do
				if child.Name ~= "Attachment" then
					continue
				end

				local position = child.Position
				child.Position = createVector(0, 0, 0)
				TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					Position = position
				}):Play()
			end

			p.Weld.C0 = CFrame.new(0, 0, 0)
			p.Weld.Part0 = instance2
			task.delay(0.5, function()
				for _ = 1, 10 do
					local clone = utils.Hiromi.GavelShard:Clone()
					clone.Position = instance2.Position
					clone.Size *= math.random(30, 100) / 100
					clone.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 2)
					task.delay(1, function()
						TweenService:Create(clone, TweenInfo.new(1), {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
				end

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end)
			local clone = utils.Hiromi.SwordBuild.Charge:Clone()
			Debris:AddItem(clone, 1)
			clone.Parent = instance2
			task.wait(0.7)
			clone:Destroy()

			for _, child in utils.Hiromi.SwordBuild.Create:GetChildren() do
				local clone2 = child:Clone()
				clone2.Parent = instance2
				Debris:AddItem(clone2, 1.5)
				clone2:Emit(clone2:GetAttribute("EmitCount"))
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
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.DeadlySentence.Voice, humanoidRootPart, game.SoundService.Voice)
			v3:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v3:Domain(instance, function(p, parent)
						parent.Humanoid:LoadAnimation(animations.Hiromi.DomainWarn):Play(0)
						p.Panel.ImageLabel:Destroy()
						local clone = utils.Hiromi.DeadlySentencing.JudgemanPanel:Clone()
						clone.Parent = p.Panel
						p.Panel.BackgroundColor3 = Color3.new(0, 0, 0)
						TweenService:Create(
							clone,
							TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Position = UDim2.new(0.41, 0, 0.3, 0),
								ImageTransparency = 0
							}
						):Play()
						p.Panel.Camera.CFrame = parent.HumanoidRootPart.CFrame * CFrame.new(
							2.16096544,
							-1.70169497,
							-4.07498741,
							-0.891988277,
							0.183446124,
							0.41316402,
							-1.49011612e-8,
							0.913961232,
							-0.405801684,
							-0.452058613,
							-0.361970335,
							-0.815242589
						)
						p.Panel.Viewport.LightColor = Color3.fromRGB(255, 249, 166)
						p.Panel.Viewport.Ambient = Color3.fromRGB(0, 0, 0)
						p.Panel.Viewport.LightDirection = createVector(1, -1, -1)
						local gavel = instance.SetAssets:FindFirstChild("Gavel")

						if gavel then
							local clone2 = gavel:Clone()
							clone2.Extensions:Destroy()
							clone2.Weld.Part0 = parent["Right Arm"]
							clone2.Parent = parent
						end
					end)
				end
			end
		end,
		Opening = function(parent, parent2, p, object, p2, data, p3, p4)
			local clone = utils.Hiromi.DeadlySentencing.DomainBG:Clone()
			clone.Parent = parent
			clone.CFrame = parent.CFrame
			clone.Domain:PivotTo(parent.CFrame + createVector(0, 1, 0))
			clone.Judgeman:PivotTo(CFrame.new(1, 10000, 1))
			task.spawn(function()
				repeat
					task.wait()
				until not (p.Parent and p.Parent.Parent and p.Parent.Parent.Parent)

				clone:Destroy()
				TweenService:Create(game.Lighting, TweenInfo.new(0.2), {
					ExposureCompensation = 0
				}):Play()
			end)
			TweenService:Create(game.Lighting, TweenInfo.new(0.75), {
				ExposureCompensation = -3
			}):Play()

			for _, descendant in clone.Lights.Spotlight:GetDescendants() do
				if descendant:IsA("Beam") or descendant:IsA("SpotLight") then
					descendant.Enabled = false
				end
			end

			if not p3 then
				local domainGround = parent2.DomainGround
				domainGround.Surround.ShapePartial = 1
				domainGround.Surround.Enabled = true
				Debris:AddItem(domainGround, 2)
				task.spawn(function()
					local tweenInfo = TweenInfo.new(0.4)
					local clone2 = clone.Judgeman:Clone()
					clone2:PivotTo(parent2.CFrame * CFrame.Angles(0, 3.141592653589793, 0) - parent2.CFrame.LookVector * 25 + createVector(
						0,
						10,
						0
					))

					for _, descendant in clone2:GetDescendants() do
						if not ((descendant:IsA("Decal") or descendant:IsA("BasePart")) and descendant.Transparency == 0) then
							continue
						end

						descendant.Transparency = 1
						TweenService:Create(descendant, tweenInfo, {
							Transparency = 0
						}):Play()
					end

					clone2.Parent = parent2
					Debris:AddItem(clone2, 2)
				end)
				task.delay(0.5, function()
					TweenService:Create(domainGround, TweenInfo.new(0.25), {
						Transparency = 0
					}):Play()
					v3:DomainMapFade(Color3.new(0, 0, 0), 0.25, 1)
				end)
				task.wait(1)

				if not (p and p.Parent) then
					return
				end

				v3:PlaySound(sounds.Hiromi.DeadlySentence.Create, workspace, game.SoundService.Effect)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				for _, part in clone.Domain:GetDescendants() do
					if not (part:IsA("BasePart") and part.Transparency == 0) then
						continue
					end

					local cFrame = part.CFrame
					part.CFrame = (cFrame - Vector3.new(0, math.random(100, 200), 0)) * CFrame.Angles(
						math.random(-3.141592653589793, 3.141592653589793),
						math.random(-3.141592653589793, 3.141592653589793),
						math.random(-3.141592653589793, 3.141592653589793)
					)
					part.Transparency = 0
					TweenService:Create(part, TweenInfo.new(math.random(1, 2), Enum.EasingStyle.Exponential), {
						CFrame = cFrame,
						Transparency = 0
					}):Play()
				end

				for _, beam in clone:GetDescendants() do
					if not (beam:IsA("Beam") and beam.Parent.Parent == clone) then
						continue
					end

					beam.LightEmission = 1
					TweenService:Create(beam, TweenInfo.new(1), {
						LightEmission = 0
					}):Play()
				end
			end

			for _, descendant in clone.Lights.Spotlight:GetDescendants() do
				if not (descendant:IsA("Beam") or descendant:IsA("SpotLight")) then
					continue
				end

				local v5 = descendant
				task.delay(0.4, function()
					local WAIT_INTERVAL = 0.05
					v5.Enabled = true
					task.wait(WAIT_INTERVAL)
					v5.Enabled = false
					task.wait(WAIT_INTERVAL)
					v5.Enabled = true
					task.wait(WAIT_INTERVAL)
					v5.Enabled = false
					task.wait(WAIT_INTERVAL)
					v5.Enabled = true
					task.wait(WAIT_INTERVAL)
					v5.Enabled = false
					task.wait(0.3)
					v5.Enabled = true
				end)
			end

			task.spawn(function()
				local judgeman = clone.Judgeman
				judgeman:PivotTo(clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0) - clone.CFrame.LookVector * 25 + createVector(
					0,
					10,
					0
				))
				local total = 0

				repeat
					local v5 = task.wait()
					total += v5 * 2

					if judgeman.Parent and data and data.Parent then
						local position = data.HumanoidRootPart.Position
						local cframe = CFrame.lookAt(
							clone.Position,
							(Vector3.new(position.X, clone.Position.Y, position.Z))
						)
						judgeman:PivotTo((judgeman:GetPivot():Lerp(
							cframe + cframe.LookVector * 40 + Vector3.new(0, math.sin(total) * 1.5 + 10, 0),
							4 * v5
						)))
					end
				until not clone.Parent
			end)
			task.delay(p3 and 0 or 2, function()
				if not clone.Parent then
					return
				end

				local _ = clone.Domain.Saws.MainBlade.Blade.CFrame

				for _, child in pairs(clone.Domain.Saws:GetChildren()) do
					child:SetAttribute("cf", child.Blade.CFrame)
				end

				parent2:GetAttributeChangedSignal("VisualHealth"):Connect(function()
					if not clone.Parent then
						return
					end

					local visualHealth = parent2:GetAttribute("VisualHealth")
					local children = clone.Domain.Saws:GetChildren()
					local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					local v5 = false

					for _, v6 in pairs(children) do
						if not (visualHealth < v6:GetAttribute("DecreaseHP")) then
							continue
						end

						TweenService:Create(v6.Blade, tweenInfo, {
							CFrame = v6:GetAttribute("cf") - createVector(0, 45, 0)
						}):Play()

						if v5 then
							continue
						end

						v3:PlaySound(sounds.Hiromi.DeadlySentence.BladeFallRope, workspace, game.SoundService.Effect)
						task.delay(0.3, function()
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
							v3:PlaySound(
								sounds.Hiromi.DeadlySentence["BladeFall" .. math.random(1, 2)],
								workspace,
								game.SoundService.Effect
							)
						end)
						v5 = true
					end
				end)
			end)
			local clone2 = utils.Hiromi.DeadlySentencing.Choose:Clone()
			clone2.Parent = localPlayer.PlayerGui
			local tweenInfo = TweenInfo.new(0.5)
			TweenService:Create(clone2.Title, tweenInfo, {
				TextTransparency = 0.5
			}):Play()
			TweenService:Create(clone2.Crime, tweenInfo, {
				TextTransparency = 0.5
			}):Play()
			local DeadlyData = require(replicatedStorage.Modules.DeadlyData)
			task.delay(p3 and 0 or 1.2, function()
				if not clone2.Parent then
					return
				end

				TweenService:Create(clone2.Confess, tweenInfo, {
					BackgroundTransparency = 0.5,
					TextTransparency = 0
				}):Play()
				TweenService:Create(clone2.Silence, tweenInfo, {
					BackgroundTransparency = 0.5,
					TextTransparency = 0
				}):Play()
				TweenService:Create(clone2.Denial, tweenInfo, {
					BackgroundTransparency = 0.5,
					TextTransparency = 0
				}):Play()
				TweenService:Create(clone2.Health, tweenInfo, {
					BackgroundTransparency = 0.5
				}):Play()
				TweenService:Create(clone2.Health.Bar, tweenInfo, {
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(clone2.Health.Marks.Bar1, tweenInfo, {
					BackgroundTransparency = 0.5
				}):Play()
				TweenService:Create(clone2.Health.Marks.Bar2, tweenInfo, {
					BackgroundTransparency = 0.5
				}):Play()
				parent2:GetAttributeChangedSignal("UI"):Connect(function()
					if localPlayer.Character == data then
						return
					end

					if parent2:GetAttribute("UI") ~= true == false then
						clone2.Timer.Visible = true

						for i = 3, 1, -1 do
							if clone2.Timer.Visible == false then
								break
							end

							v3:PlaySound(sounds.Hiromi.DeadlySentence.Tick, workspace, game.SoundService.Effect)
							clone2.Timer.Text = i
							task.wait(1)
						end
					end
				end)
				parent2:GetAttributeChangedSignal("UI2"):Connect(function()
					if localPlayer.Character ~= data then
						return
					end

					local UI2 = parent2:GetAttribute("UI2")

					if UI2 == nil then
						clone2.Confess.Visible = true
						clone2.Silence.Visible = true
						clone2.Denial.Visible = true
						clone2.Timer.Visible = false
						clone2.Confess.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						clone2.Silence.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						clone2.Denial.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					elseif UI2 == true then
						clone2.Confess.Visible = false
						clone2.Silence.Visible = false
						clone2.Denial.Visible = false
					elseif UI2 == false then
						clone2.Timer.Visible = true

						for i = 3, 1, -1 do
							if clone2.Timer.Visible == false then
								break
							end

							v3:PlaySound(sounds.Hiromi.DeadlySentence.Tick, workspace, game.SoundService.Effect)
							clone2.Timer.Text = i
							task.wait(1)
						end

						clone2.Timer.Visible = false
					end
				end)

				local function bindCounter(attributeName, p5, text)
					parent2:GetAttributeChangedSignal(attributeName):Connect(function()
						local attribute = parent2:GetAttribute(attributeName) or 0

						if attribute > 0 and localPlayer.Character ~= data then
							p5.Text = text .. " (" .. attribute .. ")"
							return
						end

						p5.Text = text
						p5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end)
				end

				local denial = clone2.Denial
				local v5 = "DenialCount"
				local text2 = "DENIAL"
				parent2:GetAttributeChangedSignal("DenialCount"):Connect(function()
					local attribute = parent2:GetAttribute(v5) or 0

					if attribute > 0 and localPlayer.Character ~= data then
						denial.Text = text2 .. " (" .. attribute .. ")"
						return
					end

					denial.Text = text2
					denial.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end)
				local silence = clone2.Silence
				local v7 = "SilenceCount"
				local text3 = "SILENCE"
				parent2:GetAttributeChangedSignal("SilenceCount"):Connect(function()
					local attribute = parent2:GetAttribute(v7) or 0

					if attribute > 0 and localPlayer.Character ~= data then
						silence.Text = text3 .. " (" .. attribute .. ")"
						return
					end

					silence.Text = text3
					silence.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end)
				local confess = clone2.Confess
				local v9 = "ConfessCount"
				local text4 = "CONFESS"
				parent2:GetAttributeChangedSignal("ConfessCount"):Connect(function()
					local attribute = parent2:GetAttribute(v9) or 0

					if attribute > 0 and localPlayer.Character ~= data then
						confess.Text = text4 .. " (" .. attribute .. ")"
						return
					end

					confess.Text = text4
					confess.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end)

				local function bindClick(state, p5)
					if localPlayer.Character == data then
						state.AutoButtonColor = false
						state.MouseEnter:Connect(function()
							state.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
						end)
						state.MouseLeave:Connect(function()
							state.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						end)
					end

					state.MouseButton1Down:Connect(function()
						if localPlayer.Character == data then
							clone2.Confess.Visible = false
							clone2.Silence.Visible = false
							clone2.Denial.Visible = false
						end

						clone2.Confess.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						clone2.Silence.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						clone2.Denial.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						state.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
						v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						object:FireServer(p5)
					end)
				end

				bindClick(clone2.Denial, 1)
				bindClick(clone2.Silence, 2)
				bindClick(clone2.Confess, 3)
				local v11 = 0

				local function healthChanged(p5)
					v11 = p4
					TweenService:Create(
						clone2.Health.Bar,
						TweenInfo.new(p5 >= 3 and 0.65 or 0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Size = UDim2.new(p5 / 3, 0, 1, 0)
						}
					):Play()
					v3:PlaySound(sounds.Hiromi.DeadlySentence.Fill, workspace, game.SoundService.Effect)
				end

				if p4 ~= 0 then
					healthChanged(p4)
				end

				object.OnClientEvent:Connect(function(p5, p6, p7, p8, p9, p10)
					if not (p5 and p6 and p7) then
						return
					end

					clone2.Timer.Visible = false

					if p10 and p10.Parent then
						dialogBox(p10, DeadlyData.Dialog[p5][1][p6])
					end

					task.wait(0.75)

					if parent2 and parent2.Parent and data and data.Parent then
						dialogBox(
							p5 == 3 and p6 == 3 and p7 == p6 and clone.Judgeman or data,
							p6 == p7 and DeadlyData.Dialog[p5][2][p6] or DeadlyData.DialogFail[p8]
						)

						if p6 ~= p7 then
							if p8 == 4 then
								v3:PlaySound(sounds.Hiromi.DeadlySentence.Sure, data.Head, game.SoundService.Voice)
							else
								v3:PlaySound(sounds.Hiromi.DeadlySentence.TalkFail, data.Head, game.SoundService.Voice)
							end
						end
					end

					if v11 ~= p9 then
						healthChanged(p9)
					end

					if p9 then
						if p9 < 3 then
							task.wait(0.75)
							clone2.Confess.Visible = true
							clone2.Silence.Visible = true
							clone2.Denial.Visible = true
						else
							clone.Judgeman.Face.Face.Transparency = 1
							clone.Judgeman.Face.Face2.Transparency = 0
						end
					end
				end)
			end)
			clone2.Crime.Text = DeadlyData.Crimes[p2]
			local v5 = v3:PlaySound(sounds.Hiromi.DeadlySentence.Music, workspace, game.SoundService.Music, true)
			local v6 = v3:PlaySound(sounds.Hiromi.DeadlySentence.Travel, workspace, game.SoundService.Effect, true)
			TweenService:Create(v6, TweenInfo.new(2), {
				Volume = 0.7
			}):Play()
			game.SoundService.AmbientReverb = Enum.ReverbType.Auditorium
			task.spawn(function()
				repeat
					task.wait()
				until not (p.Parent and p.Parent.Parent and p.Parent.Parent.Parent)

				game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
				TweenService:Create(v5, TweenInfo.new(2), {
					Volume = 0
				}):Play()
				Debris:AddItem(v5, 2)

				if v6 then
					v6:Destroy()
				end

				if clone2 then
					clone2:Destroy()
				end
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

			v3:PlaySound(sounds.Hiromi.DeadlySentence.Shatter, clone, game.SoundService.Effect)
			clone.Transparency = 0
			clone.Color = Color3.new(0, 0, 0)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()

			if _G.Settings.DesPHY then
				task.wait(0.04)

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
		LightShatter = function(position)
			local clone = utils.Hiromi.DeadlySentencing.LightShatter:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			clone.Shatter.Color = ColorSequence.new(Color3.new(0, 0, 0))
			clone.Surround.Color = ColorSequence.new(Color3.new(0, 0, 0))
			clone.Shatter:Emit(50)
			clone.Surround:Emit(150)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Gojo.Teleport, clone, game.SoundService.Effect)

			if localPlayer.Character and (localPlayer.Character.HumanoidRootPart.Position - position).Magnitude < 35 then
				v3:DomainMapFade(Color3.new(0, 0, 0), 0, 0.15)
				clone.DomainGround.Position = position - createVector(0, 3, 0)
				clone.Surround:Emit(100)
			end

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 150 then
					return
				end

				local random = Random.new()
				local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 80 do
					local clone2 = utils.Gojo.Shard:Clone()
					local unit = random:NextUnitVector().Unit
					clone2.Size = Vector3.new(0.1, math.random(1, 8) / 2, math.random(1, 8) / 2)
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
		Confiscate = function(instance, p, textColor)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local confiscate = instance.Head:FindFirstChild("Confiscate")

			if textColor or not confiscate then
				local clone = utils.Hiromi.Confiscate:Clone()
				clone.Parent = instance.Head

				if textColor then
					clone.TextLabel.TextColor3 = textColor
				end

				task.delay(textColor and 0.5 or 3, function()
					TweenService:Create(clone.TextLabel, TweenInfo.new(textColor and 0.5 or 1), {
						TextTransparency = 1
					}):Play()
				end)
				Debris:AddItem(clone, textColor and 1 or 4)
				clone.TextLabel.Size += UDim2.new(0, 0, 1, 0)
				clone.TextLabel.Text = "- [" .. p .. "]"
			else
				confiscate.TextLabel.Size += UDim2.new(0, 0, 1, 0)
				confiscate.TextLabel.Text = confiscate.TextLabel.Text .. "\n- [" .. p .. "]"
			end
		end,
		AmpliStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(0.666667, 1, 1), 1)
			v3:PlaySound(sounds.Hiromi.Amplification.Start, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		AmpliAbsorb = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.AmpliAbsorb:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Aura:Emit(50)
			clone.Hit:Emit(50)
			clone.Wind2:Emit(10)
			local clone2 = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
			clone2.Size = createVector(20, 20, 20)
			clone2.Anchored = true
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			local highlight = Instance.new("Highlight", clone2)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			clone2.Transparency = 50
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = createVector(13, 13, 13)
			}):Play()
			Debris:AddItem(clone2, 1)
			v3:Flash(instance, Color3.new(0.666667, 1, 1), 1)
			v3:PlaySound(sounds.Hiromi.Amplification.Absorb, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, _)
				if instance.Parent and not instance:GetAttribute("Rebound") then
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
		end,
		Recall = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local lastTime = tick()
			v3:PlaySound(sounds.Yuki.Rebound.Bounce, humanoidRootPart, game.SoundService.Effect)
			instance2:SetAttribute("Rebound", true)
			local v5 = 15 * (p2 / 0.5)

			while true do
				local v6 = task.wait()
				local v7 = (tick() - lastTime) / p2
				local v8 = p:Lerp(humanoidRootPart.Position, v7) + Vector3.new(0, math.sin(v7 * 3.14) * v5, 0)
				instance2.CFrame = CFrame.lookAlong(v8, p - humanoidRootPart.Position)

				if instance2:FindFirstChild("Gavel") then
					instance2.Gavel.Weld.C1 *= CFrame.Angles(math.rad(-600 * v6), 0, 0)
				end

				if not (not humanoidRootPart.Parent or p2 < tick() - lastTime) then
					continue
				end

				if instance2 then
					instance2:Destroy()
				end

				break
			end
		end,
		HammerHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Whack:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.Verdict.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Dash = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Choso.CounterSwing.Shock:Clone()
			clone.Size = createVector(6, 30, 6)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()

			for i = 1, 4 do
				task.delay(i * 0.04, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone2.Transparency = 0.3
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(20, 0, 20),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.15)
				end)
			end
		end,
		HammerSwap = function(instance, attachment)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Recall, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Hiromi.HammerSwap:Clone()
			clone.Parent = humanoidRootPart
			clone.WorldPosition = attachment:IsA("Attachment") and attachment.WorldPosition or attachment.Position
			clone.Sparks:Emit(10)
			clone.Star:Emit(1)
			Debris:AddItem(clone, 0.1)
		end,
		HammerIFrame = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local flash = v3:Flash(instance, Color3.fromRGB(255, 170, 0), 1)
			instance2.AncestryChanged:Once(function()
				flash:Destroy()
			end)
		end,
		Bang = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Bang, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("HiromiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller