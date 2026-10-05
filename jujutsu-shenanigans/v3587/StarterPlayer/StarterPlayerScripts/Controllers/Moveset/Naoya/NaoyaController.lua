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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "NaoyaController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or instance:FindFirstChild("Info") and instance.Info:FindFirstChild("NaoyaFrame") then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
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
		Swing = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, _, p2)
			if p == 1 or p == 2 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(128, 126, 255), 0.4)
			elseif p == 3 or p2 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(128, 126, 255), 0.4)
			else
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(128, 126, 255), 0.4)
			end
		end,
		Swing3 = function(p, p2, p3)
			if p2 == 1 or p2 == 3 then
				v3:ArmFlash(p["Right Arm"], Color3.fromRGB(128, 126, 255), 0.4)
				return
			end

			if p2 == 2 or p3 == "Up" then
				v3:ArmFlash(p["Left Arm"], Color3.fromRGB(128, 126, 255), 0.4)
				return
			end

			v3:ArmFlash(p["Left Arm"], Color3.fromRGB(128, 126, 255), 0.4)
			v3:ArmFlash(p["Right Arm"], Color3.fromRGB(128, 126, 255), 0.4)
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
		Frame = function(folder, instance)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local chargeMeter = humanoidRootPart:FindFirstChild("ChargeMeter")

			if chargeMeter then
				chargeMeter:Destroy()
			end

			local clone = utils.Naoya.NaoyaGlass:Clone()

			if folder:GetScale() ~= 1 then
				clone.Size *= folder:GetScale()
				clone.Part.Size *= folder:GetScale()
			end

			clone.CFrame = folder.Torso.CFrame
			clone.Parent = workspace.Effects
			clone.Front.Transparency = 1
			clone.Back.Transparency = 1
			Debris:AddItem(clone, 4)
			local clones = {}
			task.spawn(function()
				for i = 1, 2 do
					local clone2 = utils.Naoya.NaoyaGlassUI:Clone()
					table.insert(clones, clone2)
					clone2.Parent = localPlayer.PlayerGui
					clone2.Adornee = clone
					local clone3 = folder:Clone()

					for _, script in pairs(clone3:GetDescendants()) do
						if not (script:IsA("LocalScript") or script:IsA("Script") or script.Name == "Stunna" or script.Name == "ChargeMeter") then
							continue
						end

						script:Destroy()
					end

					for _, motor6D in pairs(folder:GetDescendants()) do
						if not motor6D:IsA("Motor6D") then
							continue
						end

						local motor6D2 = clone3:FindFirstChild(motor6D.Name, true)

						if not (motor6D2 and motor6D2:IsA("Motor6D")) then
							continue
						end

						motor6D2.C0 = motor6D.C0
						motor6D2.C1 = motor6D.C1
						motor6D2.Transform = motor6D.Transform
					end

					clone3.Parent = clone2.ViewportFrame.WorldModel
					clone3:PivotTo(CFrame.new())

					if i == 2 then
						clone2.Face = Enum.NormalId.Back
					end

					local camera = Instance.new("Camera", clone2.ViewportFrame)
					camera.CFrame = CFrame.new(0, 0, (i == 2 and 400 or -400) * folder:GetScale()) * CFrame.Angles(
						0,
						math.rad(i == 2 and 0 or 180),
						0
					)
					camera.FieldOfView = 1
					clone2.ViewportFrame.CurrentCamera = camera
				end
			end)
			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
					continue
				end

				local transparency = descendant.Transparency
				descendant.Transparency = 1
				transparenciesByDescendant[descendant] = transparency
			end

			clone.Transparency = 0
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 0.5
			}):Play()
			v3:PlaySound(sounds.Naoya.Frame, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.5, function()
				if clone.Transparency == 1 then
					return
				end

				TweenService:Create(clone, TweenInfo.new(2.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					Transparency = 0
				}):Play()
			end)
			task.spawn(function()
				repeat
					clone.CFrame = folder.Torso.CFrame
					task.wait()
				until not (folder.Parent and humanoidRootPart.Parent and instance:IsDescendantOf(workspace.Characters))

				for k, transparency in transparenciesByDescendant do
					if k.Parent then
						k.Transparency = transparency
					end
				end

				for _, v5 in clones do
					v5:Destroy()
				end

				TweenService:Create(clone, TweenInfo.new(0), {
					Transparency = 1
				}):Play()
				clone.Part.Transparency = 1
				clone.Front.Transparency = 1
				clone.Back.Transparency = 1
				clone.Attachment.Flash:Emit(3)
				clone.Attachment.Wind:Emit(5)
				clone.Attachment.WindCircle:Emit(5)
				clone.Attachment.Shockwave:Emit(4)
				clone.Shatter:Emit(40)
				v3:PlaySound(sounds.Naoya.FrameBreak, humanoidRootPart, game.SoundService.Effect)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end

				if _G.Settings.DesPHY then
					if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 100 then
						return
					end

					task.wait(0.1)
					local random = Random.new()
					local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

					for _ = 1, 20 do
						local clone2 = utils.Gojo.Shard:Clone()
						local unit = random:NextUnitVector().Unit
						clone2.Size = Vector3.new(0.2, math.random(5, 20) / 10, math.random(5, 20) / 10)
						clone2.CFrame = clone.CFrame * CFrame.new(math.random(-2, 2), math.random(-4, 4), 0)
						clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
						clone2.CanCollide = true
						clone2.CollisionGroup = "Effects"
						clone2.Parent = workspace.Effects
						clone2.Transparency = 0.5
						clone2.Color = clone.Color
						clone2.Material = Enum.Material.Neon
						clone2.RotVelocity = Vector3.new(
							math.random(-50, 50),
							math.random(-50, 50),
							math.random(-50, 50)
						)
						clone2.Velocity = unit * math.random(30, 60) + humanoidRootPart.Velocity
						TweenService:Create(clone2, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
						Debris:AddItem(clone2, 3)
					end
				end
			end)
		end,
		Zwoosh = function(folder, _, p)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local color = p or Color3.fromRGB(128, 126, 255)
			local tweenInfo = TweenInfo.new(1.2)
			v3:PlaySound(sounds.Naoya.Decisive.Startup, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Damage.HitGlow:Clone()
			Debris:AddItem(clone, 1.2)
			clone.Parent = workspace.Effects

			for _, child in clone:GetChildren() do
				child.Color = color
				child.Anchored = true
				child.CFrame = folder[child.Name].CFrame
				TweenService:Create(child, tweenInfo, {
					Transparency = 1,
					Position = child.Position
				}):Play()
			end

			local clone2 = utils.Naoya.Teleport:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			clone2.Lines.Color = ColorSequence.new(color)
			clone2.Lines:Emit(8)
			clone2.Floor.Dust:Emit(30)
			Debris:AddItem(clone2, 1)
			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
					continue
				end

				local transparency = descendant.Transparency
				descendant.Transparency = 1
				transparenciesByDescendant[descendant] = transparency
			end

			task.wait(0.25)
			v3:PlaySound(sounds.Naoya.Decisive.Flicker2, humanoidRootPart, game.SoundService.Effect)

			for k, transparency in transparenciesByDescendant do
				if k.Parent then
					k.Transparency = transparency
				end
			end

			local clone3 = utils.Naoya.Teleport:Clone()
			clone3.CFrame = humanoidRootPart.CFrame
			clone3.Parent = workspace.Effects
			clone3.Lines.Color = ColorSequence.new(color)
			clone3.Lines:Emit(8)
			clone3.Floor.Dust:Emit(30)
			Debris:AddItem(clone3, 1)
		end,
		Trail = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local tweenInfo = TweenInfo.new(1.2)
			local unit = (p2 - p).Unit

			for i = 0, math.floor((p - p2).Magnitude / 4) do
				local clone = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone, 1.2)
				clone.Parent = workspace.Effects

				for _, child in clone:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Anchored = true
					child.CFrame = instance[child.Name].CFrame - humanoidRootPart.Position + p + unit * i * 4
					TweenService:Create(child, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			local tweenInfo2 = TweenInfo.new(0.2)

			for _ = 1, 10 do
				local clone = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone, 0.2)
				clone.Parent = workspace.Effects

				for _, child in clone:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Anchored = true
					child.CFrame = instance[child.Name].CFrame
					TweenService:Create(child, tweenInfo2, {
						Transparency = 1
					}):Play()
				end

				task.wait(0.04)
			end
		end,
		Blink = function(instance, p)
			v3:DomainMapFade(Color3.new(0, 0, 0), 0.2, 0.3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = humanoidRootPart.Position
			TweenInfo.new(1.2)
			local unit = (p - position).Unit

			for i = 0, math.floor((position - p).Magnitude / 4) do
				local clone = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone, 0.25)
				clone.Parent = workspace.Effects

				for _, child in clone:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Anchored = true
					child.Transparency = 0
					child.CFrame = instance[child.Name].CFrame - humanoidRootPart.Position + position + unit * i * 4
				end

				task.wait(0.02)
			end
		end,
		Parry = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
			end

			local startup = humanoidRootPart:FindFirstChild("Startup")

			if startup and startup:IsA("Sound") then
				TweenService:Create(startup, TweenInfo.new(0.2), {
					Volume = 0
				}):Play()
			end

			v3:PlaySound(sounds.Naoya.Ultimate.Parry, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.C.M1.Hit1:Clone()
			clone.Parent = instance["Right Arm"]
			clone.Position = createVector(0, -1, 0)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.LockedToPart = true
			end

			Debris:AddItem(clone, 0.5)

			for _ = 1, 7 do
				local clone2 = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone2, 0.5)
				clone2.Parent = workspace.Effects
				local tweenInfo = TweenInfo.new(0.5)

				for _, child in clone2:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Transparency = 0.5
					child.Anchored = true
					child.CFrame = instance[child.Name].CFrame
					TweenService:Create(child, tweenInfo, {
						Transparency = 1
					}):Play()
				end

				task.wait(0.02)
			end
		end,
		Lost = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p2 then
				task.wait(0.45)
				v3:PlaySound(sounds.Naoya.Ultimate.Fall, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.4)
				local clone = utils.Naoya.Fall:Clone()
				clone:PivotTo(humanoidRootPart.CFrame)
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1.5)
				TweenService:Create(
					clone.Mesh.Start,
					TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone.Mesh.End.Size,
						Transparency = 1,
						CFrame = clone.Mesh.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone.Mesh2.Start,
					TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone.Mesh2.End.Size,
						Transparency = 1,
						CFrame = clone.Mesh2.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone.Mesh3.Start,
					TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone.Mesh3.End.Size,
						Transparency = 1,
						CFrame = clone.Mesh3.End.CFrame
					}
				):Play()
				clone.Mesh.End:Destroy()
				clone.Mesh2.End:Destroy()
				clone.Mesh3.End:Destroy()

				if localPlayer.Character == instance or localPlayer.Character == p then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			else
				v3:PlaySound(sounds.Naoya.Ultimate.Catch, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.3)
				local clone = utils.Naoya.Dialogue:Clone()
				clone.Parent = instance.Head
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
				task.wait(1.3)
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
				task.wait(0.8)
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
			end
		end,
		Grip = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Naoya.Ultimate.Grab, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.2, function()
				v3:PlaySound(sounds.Naoya.Ultimate.Grab2, humanoidRootPart, game.SoundService.Effect)
			end)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Form = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Naoya.Ultimate.Form, humanoidRootPart, game.SoundService.Effect)
			local colors = {}

			for _, part in instance:GetChildren() do
				if part:IsA("BasePart") and part ~= humanoidRootPart then
					table.insert(colors, part.Color)
				end
			end

			local clone = utils.Naoya.Form:Clone()
			clone.Color = colors[math.random(1, #colors)]
			clone.Weld.Part0 = instance.Torso
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 4)
			TweenService:Create(clone, TweenInfo.new(0.4), {
				Size = createVector(4, 4, 4)
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local clone2 = utils.Misc.M.WingFly:Clone()
			clone2.WHAT:Destroy()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2:ScaleTo(2)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 1.5)
			TweenService:Create(
				clone2.Mesh.Start,
				TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone2.Mesh2.Start,
				TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh2.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh2.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone2.Mesh3.Start,
				TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone2.Mesh3.End.Size,
					Transparency = 1,
					CFrame = clone2.Mesh3.End.CFrame
				}
			):Play()
			clone2.Mesh.End:Destroy()
			clone2.Mesh2.End:Destroy()
			clone2.Mesh3.End:Destroy()
			local clone3 = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone3.Position = humanoidRootPart.Position
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 1)
			clone3.Sparks.Color = ColorSequence.new(instance.Torso.Color)
			clone3.Wind.Color = clone3.Sparks.Color
			clone3.Wind2.Color = clone3.Sparks.Color
			clone3.Sparks:Emit(50)
			clone3.Wind:Emit(7)
			clone3.Wind2:Emit(7)
			local attachment = clone.Attachment

			for _ = 1, 30 do
				local clone4 = attachment:Clone()
				clone4.CFrame *= CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
				clone4.Beam.Color = ColorSequence.new(clone.Color, colors[math.random(1, #colors)])
				clone4.Parent = clone
				local v5 = math.random(100, 200) / 100
				local tweenInfo = TweenInfo.new(0.4 * v5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
				TweenService:Create(clone4.Attachment, tweenInfo, {
					Position = Vector3.new(0, math.random(30, 50), 0)
				}):Play()
				TweenService:Create(clone4.Beam, tweenInfo, {
					CurveSize0 = 0
				}):Play()
				TweenService:Create(
					clone4.Attachment,
					TweenInfo.new(0.6 * v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Orientation = createVector(0, 0, -90)
					}
				):Play()
				task.delay(0.4 * v5, function()
					tweenInfo = TweenInfo.new(0.4 * v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
					TweenService:Create(clone4.Attachment, tweenInfo, {
						Position = createVector(0, 0, 0)
					}):Play()
					TweenService:Create(clone4.Beam, tweenInfo, {
						CurveSize0 = -15
					}):Play()
				end)
			end

			attachment:Destroy()
			task.wait(0.4)
			clone.Core.Wrap.Enabled = true
			TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(16, 16, 16)
			}):Play()
			task.spawn(function()
				repeat
					clone.Core.Wrap.Size = NumberSequence.new(clone.Size.X / 2 + 0.1)
					task.wait()
				until not clone.Parent
			end)
			task.wait(0.8)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0)
			}):Play()
			local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			for i = 1, 15 do
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
					task.wait()
				else
					local v5 = math.random(90, 130) / 100
					local clone4 = utils.Mahito.Worms.Morph2:Clone()

					if i % 4 ~= 0 then
						clone4.Decal:Destroy()
					end

					clone4.Color = colors[math.random(1, #colors)]
					clone4.Weld.C0 *= CFrame.Angles(
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793)
					)
					clone4.Weld.Part0 = humanoidRootPart
					clone4.Parent = workspace.Effects
					Debris:AddItem(clone4, 2)
					TweenService:Create(clone4.Weld, TweenInfo.new(v5 + 0.4, Enum.EasingStyle.Exponential), {
						C0 = clone4.Weld.C0 * CFrame.Angles(
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793)
						)
					}):Play()
					task.spawn(function()
						local v8 = v5 / 5
						TweenService:Create(clone4, TweenInfo.new(v5 * 0.66, Enum.EasingStyle.Elastic), {
							Size = createVector(1, 1, 1) * math.random(80, 140) / 10
						}):Play()
						task.delay(v5 * 0.33, function()
							TweenService:Create(
								clone4,
								TweenInfo.new(v5 * 0.33, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 10)
								}
							):Play()
						end)
						local tweenInfo2 = TweenInfo.new(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

						for i2 = 1, 5 do
							local lerped = CFrame.new(
								math.random(-40, 40) / 3,
								math.random(-10, 50) / 5,
								math.random(-20, 20) / 3
							):Lerp(
								CFrame.new(),
								i2 / 6
							)
							TweenService:Create(clone4.Weld, tweenInfo2, {
								C1 = lerped
							}):Play()
							task.wait(v8)
						end

						TweenService:Create(clone4, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
					task.wait()
				end
			end

			task.wait(0.5)
			clone:Destroy()
		end,
		Spin = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Naoya.HitArea:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.groundwaveing.Spin, TweenInfo.new(1), {
				TimeScale = 1
			}):Play()
			local _ = instance.Torso.Position
			local v5

			if localPlayer.Character == instance then
				v5 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
			end

			local now = tick()

			while true do
				clone.Position = humanoidRootPart.Position
				local _ = instance.Torso.Position
				local now2 = tick()

				if now + 0.1 < now2 then
					now = tick()
					local curse = instance:FindFirstChild("Curse")

					if curse then
						local clone2 = curse:Clone()

						for _, descendant in clone2:GetDescendants() do
							if descendant:IsA("Decal") then
								descendant.Transparency = 1
							elseif descendant:IsA("BasePart") and descendant.Transparency ~= 1 then
								descendant.Transparency = 0.5
								descendant.Material = Enum.Material.Neon
								descendant.Anchored = true
								descendant.Color = Color3.fromRGB(128, 126, 255)

								if descendant:IsA("UnionOperation") then
									descendant.UsePartColor = true
								end

								TweenService:Create(descendant, TweenInfo.new(1), {
									Transparency = 1
								}):Play()
							elseif descendant:IsA("Weld") or descendant:IsA("Motor6D") then
								descendant:Destroy()
							end
						end

						clone2.Parent = workspace.Effects
						Debris:AddItem(clone2, 1)
					end
				end

				RunService.Stepped:Wait()

				if instance2:IsDescendantOf(workspace) and humanoidRootPart.Parent then
					continue
				end

				clone.groundwaveing.Spin.Enabled = false
				TweenService:Create(clone.groundwaveing.Spin, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
					TimeScale = 0.1
				}):Play()

				if v5 then
					v5:StartFadeOut(0.5)
				end

				local clone2 = utils.Misc.M.WingFly:Clone()
				clone2.WHAT:Destroy()
				clone2:PivotTo(humanoidRootPart.CFrame)
				clone2:ScaleTo(2)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 1.5)
				TweenService:Create(
					clone2.Mesh.Start,
					TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone2.Mesh.End.Size,
						Transparency = 1,
						CFrame = clone2.Mesh.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone2.Mesh2.Start,
					TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone2.Mesh2.End.Size,
						Transparency = 1,
						CFrame = clone2.Mesh2.End.CFrame
					}
				):Play()
				TweenService:Create(
					clone2.Mesh3.Start,
					TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Size = clone2.Mesh3.End.Size,
						Transparency = 1,
						CFrame = clone2.Mesh3.End.CFrame
					}
				):Play()
				clone2.Mesh.End:Destroy()
				clone2.Mesh2.End:Destroy()
				clone2.Mesh3.End:Destroy()
				break
			end
		end,
		SpinStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Naoya.Acceleration, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Naoya.Frames, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Naoya.Air:Clone()
			clone.Parent = instance.Torso

			for _, beam in clone:GetDescendants() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.5), {
						Width1 = 8,
						TextureSpeed = -4
					}):Play()
				end
			end

			task.spawn(function()
				repeat
					for _, beam in clone:GetDescendants() do
						if beam:IsA("Beam") then
							beam.CurveSize1 = math.random(-60, 60) / 10
						end
					end

					task.wait(0.04)
				until not clone.Parent
			end)
			task.wait(1)
			Debris:AddItem(clone, 0.2)

			for _, effect in clone:GetDescendants() do
				if effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.2), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end,
		Velocity = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Yuki.Buildup:Clone()
			clone.Bar.Bar.UIGradient.Color = ColorSequence.new(
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(128, 126, 255)
			)
			clone.Parent = instance.Torso
			TweenService:Create(clone.BG, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.5
			}):Play()
			TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.2), {
				BackgroundTransparency = 0
			}):Play()

			repeat
				local v5 = ((instance.Humanoid:GetAttribute("Speed") or 2) - 2) / 2
				clone.Bar.Size = UDim2.new(1, 0, v5, 0)
				clone.Bar.Bar.Size = UDim2.new(1, 0, 1 / v5, 0)
				task.wait()
			until not (instance.Parent and p.Parent)

			TweenService:Create(clone.BG, TweenInfo.new(0.4), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(clone.Bar.Bar, TweenInfo.new(0.4), {
				BackgroundTransparency = 1
			}):Play()
			Debris:AddItem(clone, 0.4)
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
	v = Knit.GetService("NaoyaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller