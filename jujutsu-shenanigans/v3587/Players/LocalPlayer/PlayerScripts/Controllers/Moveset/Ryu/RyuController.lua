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
require(replicatedStorage.Modules.BloodyZee)
require(replicatedStorage.Modules.StaticLightning)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RyuController"
})
local random = Random.new()
local currentCamera = workspace.CurrentCamera
Color3.fromRGB(128, 187, 219)
local color = Color3.new(1, 1, 1)

local function drawBeam(folder, p, data)
	local v4 = math.max(data.Z - 45 - data.X / 2, 0)
	local X = folder.BlackStart.Size.X
	folder.BlackStart.CFrame = p * CFrame.new(0, 0, -22.5) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackStart.Size = Vector3.new(data.X, 45, data.Y)
	folder.PinkStart.CFrame = folder.BlackStart.CFrame
	folder.PinkStart.Size = folder.BlackStart.Size * createVector(0.6, 1, 0.6)
	folder.BlackMiddle.CFrame = p * CFrame.new(0, 0, -(v4 / 2 + 45)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	folder.BlackMiddle.Size = Vector3.new(data.X, v4, data.Y)
	folder.PinkMiddle.CFrame = folder.BlackMiddle.CFrame
	folder.PinkMiddle.Size = folder.BlackMiddle.Size * createVector(0.6, 1, 0.6)
	folder.BlackEnd.CFrame = p * CFrame.new(0, 0, -(v4 + 45 + data.X / 4)) * CFrame.Angles(1.5707963267948966, 0, 0)
	folder.BlackEnd.Size = Vector3.new(data.X, data.X / 2, data.X)
	folder.PinkEnd.CFrame = folder.BlackEnd.CFrame
	folder.PinkEnd.Size = folder.BlackEnd.Size * createVector(0.6, 1, 0.6)

	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		local v5 = X / beam.CurveSize0
		beam.CurveSize0 = data.X / v5
	end
end

local function shootSpec(parent)
	local clone = utils.Yuta.LoveBeam.BlackSpec:Clone()
	clone.Color = Color3.new(1, 1, 1)
	clone.CFrame = parent.PinkStart.CFrame * CFrame.new(0, -10, 0)
	clone.Parent = parent
	local X = parent.BlackMiddle.Size.X
	local Y = parent.BlackMiddle.Size.Y
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = Vector3.new(X, 20, X),
		CFrame = clone.CFrame * CFrame.new(0, Y / 2, 0)
	}):Play()
	task.wait(0.2)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = Vector3.new(X, 0, X),
		CFrame = parent.PinkStart.CFrame * CFrame.new(0, Y, 0)
	}):Play()
	task.wait(0.3)
	clone:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCameraInBeam(clone)
	local boundingBox, v4 = clone:GetBoundingBox()
	local v5 = v4 / 2
	local pointToObjectSpace = boundingBox:PointToObjectSpace(currentCamera.CFrame.Position)

	if pointToObjectSpace.Z > v5.Z or pointToObjectSpace.Z < -v5.Z then
		return
	end

	if (pointToObjectSpace * createVector(1, 1, 0)).Magnitude > v5.X then
		return
	else
		return true
	end
end

function controller.KnitStart(_)
	task.spawn(function()
		game.ContentProvider:PreloadAsync({ "rbxassetid://131698399665351", "rbxassetid://94473169004838" })
	end)
	local v4 = {
		Hit = function(instance, value, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, color)
			v3:PlaySound(
				sounds.Itadori.M1:FindFirstChild("Hit" .. (value or 1)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if p then
				local clone = utils.Itadori.CounterHit:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				clone.Glow:Emit(1)
				clone.Sparks:Emit(20)
				Debris:AddItem(clone, 0.5)
			end
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
			if p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(170, 255, 255))
			elseif p2 == "Down" or p == 2 then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(170, 255, 255), p2 == "Down" and 0.4 or false)
			elseif p == 1 or p == 3 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(170, 255, 255))
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
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 15, 25, 0.7, 1.4)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Ring = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Ryu.GraniteBlast.Fire, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Ryu.Ring:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Fade, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				CFrame = clone.Fade.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone.Fade.Attachment, TweenInfo.new(0.3), {
				Position = createVector(0, 0, 4.5)
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				C1 = CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			task.delay(0.3, function()
				clone.Fade.Attachment.Trail.Enabled = false
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 0
				}):Play()

				for _, effect in clone.Attachment:GetDescendants() do
					if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end
			end)

			repeat
				task.wait()
			until not instance2:IsDescendantOf(workspace)

			Debris:AddItem(clone, 1)
			clone.Weld.Enabled = false
			clone.Anchored = true

			for _, effect in clone.Attachment:GetDescendants() do
				if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			clone.Fade.Attachment.Trail.Enabled = true
			TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone.Fade, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				CFrame = clone.Fade.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
		end,
		Overheat = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Ryu.Buildup:Clone()
			clone.Parent = instance.Torso
			TweenService:Create(clone.BG, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.5
			}):Play()
			TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.2), {
				BackgroundTransparency = 0
			}):Play()
			local v5 = 0

			while true do
				local v6 = p.Value / 50
				v5 = math.lerp(v5, v6, 0.1)
				clone.Bar.Size = UDim2.new(1, 0, v5, 0)
				clone.Bar.Bar.Size = UDim2.new(1, 0, 1 / v5, 0)

				if v6 >= 1 then
					clone.Bar.Bar.UIGradient.Enabled = false
					clone.Bar.Bar.Overheat.Enabled = true
				end

				task.wait()

				if instance.Parent and p.Parent then
					continue
				end

				clone.Bar.Bar.UIGradient.Enabled = true
				clone.Bar.Bar.Overheat.Enabled = false
				TweenService:Create(clone.BG, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.4), {
					BackgroundTransparency = 1
				}):Play()
				Debris:AddItem(clone, 0.4)

				repeat
					v5 = math.lerp(v5, 0, 0.1)
					clone.Bar.Size = UDim2.new(1, 0, v5, 0)
					clone.Bar.Bar.Size = UDim2.new(1, 0, 1 / v5, 0)
					task.wait()
				until not clone.Parent

				break
			end
		end,
		Comb = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v3:PlaySound(sounds.Ryu.Recovery2.Comb, humanoidRootPart, game.SoundService.Effect)
			elseif instance:GetAttribute("InUlt") then
				v3:PlaySound(sounds.Ryu.Recovery3, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Ryu.Recovery.Comb, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Comb2 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v3:PlaySound(sounds.Ryu.Recovery2.Hair, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Ryu.Recovery.Sweet, humanoidRootPart, game.SoundService.Voice)
			end
		end,
		FireBeam = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Ryu.GraniteBeam:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 2, -12)
			clone.Size = createVector(12, 12, 24)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 24)
			}):Play()
			Debris:AddItem(clone, 0.2)
			v3:PlaySound(sounds.Ryu.GraniteBlast.Fire, humanoidRootPart, game.SoundService.Effect)
		end,
		UltimateCharge = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Ryu.UltimateStart, humanoidRootPart, game.SoundService.Effect)
			local v5 = v3:PlaySound(sounds.Ryu.Ultimate, humanoidRootPart, game.SoundService.Music)
			Debris:AddItem(v5, 3.35)
			v5.TimePosition = (p and 140 or 9.9) - 3.35
			local volume = v5.Volume
			v5.Volume = 0
			TweenService:Create(v5, TweenInfo.new(2), {
				Volume = volume
			}):Play()
			local clone = utils.Ryu.Dialogue:Clone()
			clone.Parent = instance.Torso
			local position = clone.Text1.Position
			clone.Text1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Text1, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text1.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			}):Play()

			if p2 then
				clone.Text1.Text = "LET'S LARP!"
			end

			task.wait(1.6)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()

					if guiObject:FindFirstChild("UIStroke") then
						TweenService:Create(
							guiObject:FindFirstChild("UIStroke"),
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end,
		Ultimate = function(instance, p, p2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local v5 = v3:PlaySound(sounds.Ryu.Ultimate, workspace, game.SoundService.Music)
			local v6 = v3:PlaySound(
				sounds.Ryu[p2 and "UltimateVocalsLarp" or "UltimateVocals"],
				workspace,
				game.SoundService.Music
			)
			v5.TimePosition = p2 and 0 or p and 140 or 9.9
			local v7 = p2 and 0.15 or 0
			local clone = utils.Hakari.IdleDeath.AudioVis:Clone()
			clone.Beat.ImageColor3 = Color3.fromRGB(170, 255, 255)
			clone.Parent = localPlayer.PlayerGui
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if v5.Parent and v6.Parent and instance.Parent and humanoid.Parent and instance:GetAttribute("InUlt") then
					local timePosition2 = v5.TimePosition + v7
					local timePosition = v6.TimePosition
					local v9 = timePosition - timePosition2

					if v9 < 0 then
						v9 = -v9
					end

					if v9 > 0.1 then
						v6.TimePosition = timePosition2
					elseif timePosition2 < timePosition then
						v6.PlaybackSpeed = 0.99
					elseif timePosition < timePosition2 then
						v6.PlaybackSpeed = 1.01
					else
						v6.PlaybackSpeed = 1
					end

					local v10 = math.clamp(2 - v6.PlaybackLoudness / 330, 1, 1e999)
					clone.Beat.Size = clone.Beat.Size:Lerp(UDim2.new(v10, 0, v10, 0), 0.5)

					if humanoid.Health < 50 then
						v6.Volume = math.lerp(v6.Volume, 1, dt)
					else
						v6.Volume = math.lerp(v6.Volume, 0, dt)
					end
				else
					steppedConnection:Disconnect()
					TweenService:Create(v5, TweenInfo.new(3), {
						Volume = 0
					}):Play()
					Debris:AddItem(v5, 3)
					TweenService:Create(v6, TweenInfo.new(3), {
						Volume = 0
					}):Play()
					Debris:AddItem(v6, 3)
					TweenService:Create(clone.Beat, TweenInfo.new(0.25), {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone, 0.25)
				end
			end)
		end,
		EveryLastDrop = function(p)
			local clone = utils.Ryu.Larp:Clone()
			clone.Parent = localPlayer.PlayerGui
			Debris:AddItem(clone, 2)

			if p then
				clone.Beat.Size = UDim2.new(1, 0, 1, 0)
				clone.Beat.SizeConstraint = Enum.SizeConstraint.RelativeXY
				clone.Beat.Image = "rbxassetid://94473169004838"
				clone.Lyrics.TextColor3 = Color3.new(0, 0, 0)
				clone.Lyrics.Text = "LET'S LARP!!!!!!!!!!!!!!!!!!!"
			end

			v3:PlaySound(sounds.Ryu.Jingle, workspace, game.SoundService.Effect)
			TweenService:Create(clone.Beat, TweenInfo.new(0.3), {
				ImageTransparency = 0
			}):Play()
			local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
			task.wait(0.5)
			clone.Beat.BackgroundTransparency = 1
			TweenService:Create(clone.Beat, tweenInfo, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(clone.Lyrics, tweenInfo, {
				TextTransparency = 1
			}):Play()
			TweenService:Create(clone.Beat.Frame1, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(clone.Beat.Frame2, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
		end,
		StartBeam = function(instance)
			local beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
			local cFrame = currentCamera.CFrame
			local v5 = beamStartCFrame.Position - cFrame.Position

			if v5.Unit:Dot(cFrame.LookVector) >= 0.7 and v5.Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(beamStartCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(beamStartCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			local clone = utils.Ryu.FinalBeam:Clone()
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Value = createVector(30, 30, 180)
			drawBeam(
				clone,
				beamStartCFrame * CFrame.new(0, 0, -5),
				Vector3.new(30, 30, instance:GetAttribute("BeamLength"))
			)
			clone.Parent = workspace.Effects
			v3:PlaySound(sounds.Ryu.UltimateFire, clone.PinkStart, game.SoundService.Effect)
			local _ = beamStartCFrame * CFrame.new(0, 0, -3)
			local v6 = true
			task.spawn(function()
				local clone2 = utils.Yuta.LoveBeam.CameraFX:Clone()
				clone2.TintColor = Color3.fromRGB(170, 255, 255)
				local v7

				if (currentCamera.CFrame.Position - beamStartCFrame.Position).Magnitude < 180 then
					v7 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				end

				while true do
					local v8 = v6 and createVector(1, 1, 0) * random:NextNumber(1, 5) or createVector(0, 0, 0)
					beamStartCFrame = instance:GetAttribute("BeamStartCFrame")
					drawBeam(
						clone,
						beamStartCFrame,
						vector3Value.Value * createVector(1, 1, 0) + v8 + Vector3.new(
							0,
							0,
							instance:GetAttribute("BeamLength")
						)
					)

					-- equivalent call inferred; original call site unknown
					if isCameraInBeam(clone) then
						clone2.Parent = game.Lighting
					else
						clone2.Parent = nil
					end

					task.wait()

					if clone.Parent then
						continue
					end

					if v7 then
						v7:StartFadeOut(0.5)
					end

					clone2:Destroy()
					break
				end
			end)
			local v7 = true
			task.spawn(function()
				repeat
					task.spawn(shootSpec, clone)
					task.wait(0.3)
				until not (clone.Parent and v7)
			end)
			TweenService:Create(vector3Value, TweenInfo.new(0.3), {
				Value = createVector(60, 60, 180)
			}):Play()
			task.wait(0.3)
			TweenService:Create(vector3Value, TweenInfo.new(0.1), {
				Value = createVector(40, 40, 180)
			}):Play()
			task.wait(0.1)
			TweenService:Create(vector3Value, TweenInfo.new(1), {
				Value = createVector(30, 30, 180)
			}):Play()

			local function updateWidth()
				local width = instance:GetAttribute("Width")
				TweenService:Create(vector3Value, TweenInfo.new(0.2), {
					Value = Vector3.new(width.X - 5, width.Y - 5, 180)
				}):Play()
			end

			updateWidth()
			instance:GetAttributeChangedSignal("Width"):Connect(updateWidth)

			repeat
				task.wait()
			until not instance.Parent

			v7 = false
			TweenService:Create(clone.BlackStart.Glow.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			TweenService:Create(vector3Value, TweenInfo.new(0.5), {
				Value = createVector(0, 0, 180)
			}):Play()

			for _, effect in clone:GetDescendants() do
				if effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			task.wait(0.25)
			v6 = false
			task.wait(0.25)
			clone:Destroy()
		end,
		YutaClashing = function(instance, p)
			local clone = utils.Ryu.Clashing:Clone()
			clone.Parent = workspace.Effects

			local function toggleParticles(enabled)
				for _, emitter in clone:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = enabled
					end
				end
			end

			task.spawn(function()
				while instance.Parent and p.Parent do
					local cFrame = instance:GetAttribute("BeamStartCFrame") * CFrame.new(
						0,
						0,
						-instance:GetAttribute("BeamLength")
					) * CFrame.Angles(0, 3.141592653589793, 0)
					local v6 = createVector(1, 1, 1) * random:NextNumber(1, 5)
					clone.Size = createVector(10, 10, 10) + v6
					clone.CFrame = cFrame
					task.wait()
				end

				toggleParticles(false)
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait(1)
				clone:Destroy()
			end)
			clone.Attachment.Impact1:Emit(15)
			clone.Attachment.Impact2:Emit(15)
			task.wait(0.1)

			if not instance.Parent then
				return
			end

			toggleParticles(true)
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
	v = Knit.GetService("RyuService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller