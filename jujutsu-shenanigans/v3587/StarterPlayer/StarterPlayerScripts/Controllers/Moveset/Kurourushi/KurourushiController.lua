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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "KurourushiController"
})

function controller:PlayArms(instance, animation, p)
	local heianArms = instance.SetAssets:FindFirstChild("HeianArms")

	if not heianArms then
		return
	end

	local heianArmsModel = heianArms:FindFirstChild("HeianArmsModel")

	if not heianArmsModel then
		return
	end

	if animation == nil then
		return heianArmsModel
	end

	local track = heianArmsModel.Humanoid:LoadAnimation(animation)
	local v5 = nil

	for _, v7 in instance.Humanoid:GetPlayingAnimationTracks() do
		if v7.Animation.AnimationId ~= p.AnimationId then
			continue
		end

		v5 = v7
		break
	end

	for _, v7 in heianArmsModel.Humanoid:GetPlayingAnimationTracks() do
		v7:Stop(0)
	end

	track:Play(0)
	task.spawn(function()
		if v5 then
			while true do
				task.wait()

				if track.Speed ~= v5.Speed then
					track:AdjustSpeed(v5.Speed)
				end

				if track.TimePosition ~= v5.TimePosition then
					track.TimePosition = v5.TimePosition
				end

				if not (not v5.IsPlaying or not track.IsPlaying or instance.Parent == nil) then
					continue
				end

				track:Stop(0.25)
				break
			end
		end
	end)
	return track, heianArmsModel
end

function controller:KnitStart()
	local v5 = {
		Hit = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))

			if (p == 1 or p == 3) and not p2 then
				v3:PlaySound(
					sounds.Kurourushi.M1["Hit" .. math.random(1, 3)],
					humanoidRootPart2,
					game.SoundService.Effect
				)
			else
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart2, game.SoundService.Effect)
			end

			local v6 = {
				[1] = CFrame.Angles(0, 0, -0.08726646259971647),
				[3] = CFrame.Angles(0, 0, -0.17453292519943295)
			}

			if not v6[p] or p2 then
				return
			end

			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(
				humanoidRootPart2.Position + createVector(0, 0.75, 0),
				humanoidRootPart.CFrame.LookVector
			)
			clone.CFrame *= v6[p]
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(101, 35, 44))
			clone.Slash.Squash = NumberSequence.new(-1, -10)
			clone.Slash.Size = NumberSequence.new(1.5, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
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
			self:PlayArms(p, animations.Kurourushi.ArmsMelee.Chase, animations.Kurourushi.Melee.Chase)
		end,
		Swing = function(instance, p, _, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p and sounds.Kurourushi.M1:FindFirstChild("Swing" .. p) and not p2 then
				v3:PlaySound(sounds.Kurourushi.M1["Swing" .. p], humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Swing2 = function(data, p, childName, p2)
			local festeringSword = data.SetAssets:FindFirstChild("FesteringSword")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function ArmFlash(p3, color, p4)
				if p3.Transparency == 1 then
					return
				end

				v3:ArmFlash(p3, color, p4)
			end

			if (p == 1 or p == 3) and festeringSword then
				task.spawn(function()
					local clone = utils.Kurourushi.CombatTrail:Clone()
					local model = Instance.new("Model")
					clone.Parent = model
					model:ScaleTo(festeringSword:GetScale())
					Debris:AddItem(model, 0.1)
					clone.Weld.Part0 = festeringSword.Union
					clone.Parent = workspace.Effects
					task.wait(0.37)
					clone.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.2)
				end)
			elseif p == 2 then
				ArmFlash(data["Left Arm"], Color3.fromRGB(101, 35, 44), 0.3) -- equivalent call inferred; original call site unknown
			elseif p == 4 and childName == nil then
				ArmFlash(data["Left Arm"], Color3.fromRGB(101, 35, 44), 0.4) -- equivalent call inferred; original call site unknown
				ArmFlash(data["Right Arm"], Color3.fromRGB(101, 35, 44), 0.4) -- equivalent call inferred; original call site unknown
			end

			local v6 = nil
			local armsDetach = p2 and animations.Kurourushi.ArmsDetach or animations.Kurourushi.ArmsMelee
			local meleeDetach = p2 and animations.Kurourushi.MeleeDetach or animations.Kurourushi.Melee

			if childName and armsDetach:FindFirstChild(childName) then
				local v7
				v7, v6 = self:PlayArms(data, armsDetach[childName], meleeDetach[childName])
			elseif armsDetach:FindFirstChild("Melee" .. p) then
				local v7
				v7, v6 = self:PlayArms(data, armsDetach["Melee" .. p], meleeDetach["Melee" .. p])
			end

			if v6 then
				if childName == "Down" or childName == "Up" or p == 4 then
					ArmFlash(v6["Left Arm"], Color3.fromRGB(101, 35, 44), 0.4) -- equivalent call inferred; original call site unknown
					ArmFlash(v6["Right Arm"], Color3.fromRGB(101, 35, 44), 0.4) -- equivalent call inferred; original call site unknown
				elseif (p == 1 or p == 3) and p2 then
					ArmFlash(v6["Right Arm"], Color3.fromRGB(101, 35, 44), 0.3) -- equivalent call inferred; original call site unknown
				elseif p == 2 then
					local leftArm = v6["Left Arm"]
					local color = Color3.fromRGB(101, 35, 44)

					if leftArm.Transparency == 1 then
						return
					else
						v3:ArmFlash(leftArm, color, 0.3)
					end
				end
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
		InjuryTick = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(141, 49, 63), 0.5)
			v3:PlaySound(
				sounds.Kurourushi.Tick["Tick" .. math.random(1, 3)],
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Injury = function(instance, instance2, value)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			for _ = 1, value or 1 do
				v3:PlaySound(sounds.Kurourushi["Egg" .. math.random(1, 4)], humanoidRootPart2, game.SoundService.Effect)
				task.spawn(function()
					local torso = instance2.Torso
					local unit = (humanoidRootPart.Position - humanoidRootPart2.Position).Unit
					local vectorToObjectSpace = humanoidRootPart2.CFrame:VectorToObjectSpace(unit)
					local v6 = (math.random() - 0.5 + vectorToObjectSpace.X * 0.8 * 0.5) * torso.Size.X
					math.clamp(v6, -torso.Size.X / 2, torso.Size.X / 2)
					local v7 = (math.random() - 0.5 + vectorToObjectSpace.Y * 0.8 * 0.5) * torso.Size.Y
					math.clamp(v7, -torso.Size.Y / 2, torso.Size.Y / 2)
					local v8 = (math.random() - 0.5 + vectorToObjectSpace.Z * 0.8 * 0.5) * torso.Size.Z
					math.clamp(v8, -torso.Size.Z / 2, torso.Size.Z / 2)
					local cframe = CFrame.new(v6, v7, v8)

					for _ = 1, 5 do
						local clone = utils.Mahito.Morph:Clone()
						clone.Weld.Part0 = torso
						clone.Color = torso.Color
						clone.Weld.C0 = cframe * CFrame.new(math.random(-30, 30) / 100, math.random(-30, 30) / 100, 0)
						clone.Parent = workspace.Effects
						local v9 = math.random(7, 10) / 10
						clone.Size = createVector(1, 1, 1) * v9
						TweenService:Create(
							clone,
							TweenInfo.new(math.random(20, 50) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
						Debris:AddItem(clone, 0.8)
						task.wait(0.035)
					end
				end)
				task.wait()
			end
		end,
		InjuryHatch = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Kurourushi.Hatch, humanoidRootPart, game.SoundService.Effect)
			v3:Flash(instance2, Color3.fromRGB(118, 168, 92), 1)
			local v6 = { Color3.fromRGB(170, 170, 127), Color3.fromRGB(162, 170, 87), Color3.fromRGB(131, 131, 0) }
			local v7 = math.random(4, 7)
			local torso = instance2.Torso
			task.spawn(function()
				for _ = 1, 10 do
					local cframe = CFrame.new(
						math.random(-torso.Size.X, torso.Size.X) / 2,
						math.random(-torso.Size.Y, torso.Size.Y) / 2,
						math.random(-torso.Size.Z, torso.Size.Z) / 2
					)

					for _ = 1, 2 do
						local clone = utils.Mahito.Morph:Clone()
						clone.Weld.Part0 = torso
						clone.Color = torso.Color
						clone.Weld.C0 = cframe * CFrame.new(math.random(-30, 30) / 100, math.random(-30, 30) / 100, 0)
						clone.Parent = workspace.Effects
						local v8 = math.random(10, 15) / 10
						clone.Size = createVector(1, 1, 1) * v8
						TweenService:Create(
							clone,
							TweenInfo.new(math.random(10, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
						Debris:AddItem(clone, 0.8)
					end

					task.wait(0.05)
				end
			end)
			task.wait(0.8)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			v3:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 10 do
				local clone = utils.Damage.Chunk:Clone()
				clone.CFrame = torso.CFrame
				clone.Blood.Enabled = false
				clone.Velocity = Vector3.new(math.random(-60, 60), math.random(-30, 60), math.random(-60, 60))
				clone.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 3)
				clone.CollisionGroup = "Effects"
				task.delay(0.1, function()
					clone.CanCollide = true
					task.wait(1.9)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
					clone.Trail.Enabled = false
				end)

				if _G.Settings.Gore ~= false then
					continue
				end

				clone.Color = Color3.fromRGB(255, 85, 255)
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
			end

			for _ = 1, v7 do
				local clone = utils.Kurourushi.Bug:Clone()
				clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				))
				local velocity = clone["1"].CFrame.LookVector * math.random(30, 60) + Vector3.new(
					0,
					math.random(30, 60),
					0
				)
				clone["1"].RotVelocity = Vector3.new(
					math.random(-100, 100),
					math.random(-100, 100),
					math.random(-100, 100)
				)
				local color = v6[math.random(1, #v6)]

				for _, child in clone:GetChildren() do
					child.Color = color
					child.Velocity = velocity
				end

				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 3)
				local folder = clone
				task.delay(2, function()
					for i, descendant in folder:GetDescendants() do
						if descendant:IsA("BasePart") or descendant:IsA("Decal") then
							TweenService:Create(descendant, TweenInfo.new(0.5), {
								Transparency = 1
							}):Play()
						end
					end
				end)

				for i = 2, 3 do
					local v10 = clone[tostring(i)]
					local v11 = clone[tostring(i - 1)]
					local attachment = Instance.new("Attachment", v10)
					local attachment2 = Instance.new("Attachment", v11)
					attachment.Position = createVector(0, 0, -0.525)
					attachment2.Position = createVector(0, 0, 0.525)
					local ballSocketConstraint = Instance.new("BallSocketConstraint")
					ballSocketConstraint.Attachment0 = attachment
					ballSocketConstraint.Attachment1 = attachment2
					ballSocketConstraint.LimitsEnabled = true
					ballSocketConstraint.Parent = attachment
				end
			end
		end,
		EatStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Kurourushi.EatStart, humanoidRootPart, game.SoundService.Effect)
			local _, _ = self:PlayArms(instance, animations.Kurourushi.EatArms, animations.Kurourushi.Eat)
		end,
		RipArms = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 10 do
				BloodyZee:Blood(instance["Right Arm"].CFrame, math.random(5, 80), 25, 25)
			end

			for _ = 1, 10 do
				BloodyZee:Blood(instance["Left Arm"].CFrame, math.random(5, 80), 25, 25)
			end
		end,
		Eat = function(instance, instance2, childName)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			local child = instance2:FindFirstChild(childName)

			if not child then
				return
			end

			local function removeAccessories(child2)
				local v6 = {
					Head = {
						"HairAttachment",
						"HatAttachment",
						"FaceCenterAttachment",
						"FaceFrontAttachment"
					},
					Torso = {
						"BodyBackAttachment",
						"BodyFrontAttachment",
						"NeckAttachment",
						"WaistFrontAttachment",
						"WaistCenterAttachment",
						"WaistBackAttachment",
						"LeftCollarAttachment",
						"RightCollarAttachment"
					},
					["Left Arm"] = { "LeftShoulderAttachment", "LeftGripAttachment" },
					["Right Arm"] = { "RightShoulderAttachment", "RightGripAttachment" }
				}

				for _, decal in child:GetChildren() do
					if decal:IsA("Decal") then
						decal.Transparency = 1
					end
				end

				for _, accessory in instance2:GetChildren() do
					if not accessory:IsA("Accessory") then
						continue
					end

					local handle = accessory:FindFirstChild("Handle", true)

					if not handle then
						continue
					end

					for _, childName2 in v6[child2.Name] do
						if handle:FindFirstChild(childName2) then
							accessory:Destroy()
						end
					end
				end
			end

			child.Transparency = 1
			removeAccessories(child)

			if child.Name == "Torso" then
				TweenService:Create(instance2["Left Leg"], TweenInfo.new(0.5), {
					Size = createVector(0.7, 2, 0.7) * instance2:GetScale()
				}):Play()
				TweenService:Create(instance2["Right Leg"], TweenInfo.new(0.5), {
					Size = createVector(0.7, 2, 0.7) * instance2:GetScale()
				}):Play()
				instance2.SetAssets:ClearAllChildren()
			end

			local decal = child.Name == "Head" and child:FindFirstChildWhichIsA("Decal")

			if decal then
				decal.Transparency = 1
			end

			for _, descendant in pairs(instance2.SetAssets:GetDescendants()) do
				if not ((descendant:IsA("Motor6D") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint")) and descendant.Part0 == child) then
					continue
				end

				descendant.Parent:Destroy()
				descendant:Destroy()
			end

			for _ = 1, 3 do
				BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
			end

			local playSound = v3:PlaySound(sounds.Mahito.Eat, humanoidRootPart, game.SoundService.Effect)
			playSound.TimePosition = 0.1
		end,
		EarthenTranceStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Kurourushi.InsectTrance.Start, humanoidRootPart, game.SoundService.Effect)
			local _, _ = self:PlayArms(
				instance,
				animations.Kurourushi.EarthenTranceArms,
				animations.Kurourushi.EarthenTrance
			)
		end,
		Interp = function(instance, instance2, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:PlaySound(sounds.Kurourushi.InsectTrance.BugAppear, instance2, game.SoundService.Effect)
			v3:PlaySound(sounds.Kurourushi.InsectTrance.FlyLoop, instance2, game.SoundService.Effect)

			for _, part in pairs(instance2.Parent:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Transparency ~= 1) then
					continue
				end

				part.Transparency = 1
				TweenService:Create(part, TweenInfo.new(0.4), {
					Transparency = 0
				}):Play()
			end

			local cFrame = instance2.CFrame
			local cFrame2 = instance2.CFrame
			local now = tick()
			local positionChangedConnection = instance2:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame2 = instance2.CFrame
				now = tick()
			end)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				if instance2.Parent and p.Parent then
					cFrame = cFrame:Lerp(cFrame2, 0.3 * dt * 60)
					local v7 = { cFrame }
					workspace:BulkMoveTo({ instance2 }, v7, Enum.BulkMoveMode.FireCFrameChanged)
				else
					renderSteppedConnection:Disconnect()
					positionChangedConnection:Disconnect()
				end
			end)
		end,
		InsectDisappear = function(_, instance)
			for _, descendant in pairs(instance.Parent:GetDescendants()) do
				if descendant:IsA("BasePart") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				elseif descendant:IsA("Sound") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Volume = 0
						}
					):Play()
				end
			end

			local cFrame = instance.CFrame
			local v6 = instance.CFrame * CFrame.new(0, 10, 0)

			for _, part in pairs(instance.Parent:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Transparency = 1
					}):Play()
				end
			end

			v3:PlaySound(sounds.Kurourushi.InsectTrance.BugDisappear, instance, game.SoundService.Effect)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not instance.Parent then
					renderSteppedConnection:Disconnect()
					return
				end

				cFrame = cFrame:Lerp(v6, 0.025)
				local v8 = { cFrame }
				workspace:BulkMoveTo({ instance }, v8, Enum.BulkMoveMode.FireCFrameChanged)
			end)
		end,
		InsectBurst = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:PlaySound(sounds.Kurourushi.InsectTrance.BugExplode, p, game.SoundService.Effect)
			local clone = utils.Kurourushi.InsectBurst:Clone()
			clone.CFrame = p.CFrame
			clone.Parent = workspace.Effects
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 4)
		end,
		InsectHit = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:Flash(p, Color3.new(0.392157, 1, 0.27451), 2)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				v3:PlaySound(sounds.Kurourushi.InsectTrance.Screen, workspace, game.SoundService.Effect)

				if _G.Settings.Flash then
					local clone = utils.Kurourushi.InsectBurst:Clone()
					clone.CFrame = workspace.CurrentCamera.CFrame
					clone.Parent = workspace.Effects

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.LockedToPart = true
						emitter:Emit(emitter:GetAttribute("EmitCount"))
						emitter.TimeScale = 0.5
					end

					Debris:AddItem(clone, 4)
					task.spawn(function()
						repeat
							task.wait()
							clone.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -1)
						until clone.Parent == nil or clone == nil
					end)
				end

				task.wait(0.15)
				local blurEffect = Instance.new("BlurEffect", game.Lighting)
				Debris:AddItem(blurEffect, 4)
				blurEffect.Size = 64
				TweenService:Create(
					blurEffect,
					TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Size = 0
					}
				):Play()

				if _G.Settings.Flash then
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
					Debris:AddItem(colorCorrectionEffect, 4)
					colorCorrectionEffect.Contrast = 0
					colorCorrectionEffect.TintColor = Color3.new(0.376471, 1, 0.278431)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							TintColor = Color3.fromRGB(255, 255, 255)
						}
					):Play()
				end
			end
		end,
		Explode = function(position)
			local clone = utils.Kurourushi.RoachExplosion:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(3)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(position)
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Kurourushi.Bugnado.Explosion, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		KuroClone = function(instance)
			if not (instance and instance.Parent) then
				return
			end

			local clone = game.ReplicatedStorage.Utils.MoveReveal:Clone()
			clone.MaxDistance = 75
			clone.Parent = instance.PrimaryPart
			clone.Moveset.Visible = false
			clone.Handle.Enabled = true
		end,
		Bugnado = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local now = tick()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getRadius(p2)
				return math.sin(p2 * 3.141592653589793) * 6 + 0.5
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getHeight(p2)
				return (math.sin(p2 * 3.141592653589793 * 2 - 1.5707963267948966) + 1) / 2
			end

			local function getCycleSpeed(p2)
				return 1 + (1 - getHeight(p2)) * 2
			end

			v3:PlaySound(sounds.Kurourushi.Bugnado.Start, humanoidRootPart, game.SoundService.Effect)
			local lastTime = tick()
			local v6 = math.random(750, 1000)
			local clones = {}
			local v7 = 0
			local total = 20

			for i = 1, 4 do
				local clone = utils.Kurourushi.Swarm:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = workspace.Effects
				clones[i] = clone
				Debris:AddItem(clone, 20)
			end

			local clone = instance2:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 15)

			for _, v8 in ipairs(clones) do
				for _, child in ipairs(v8:GetChildren()) do
					child.Size = NumberSequence.new(0, child.Size.Keypoints[2].Value)
				end
			end

			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function(dt)
				if instance2.Parent == nil then
					preRenderConnection:Disconnect()

					if clone:FindFirstChild("Wind") and clone.Wind.Enabled then
						clone.Wind.Enabled = false
						Debris:AddItem(clone, 2)
					end

					for _, v8 in clones do
						local lookVector = v8.CFrame.LookVector
						local _ = v8.Size
						local v9 = 0
						local v10 = v8
						task.spawn(function()
							local v12 = math.random(150, 225)

							while true do
								local v13 = task.wait()
								v9 = math.min(v9 + v13 / 0.6, 1)
								local v14 = 1 - v9 * v9
								v10.CFrame = v10.CFrame * CFrame.new(lookVector * v13 * v12) - Vector3.new(
									0,
									v9 * 1 * v13 * 80,
									0
								)

								for i, child in v10:GetChildren() do
									child.Size = NumberSequence.new(
										child.Size.Keypoints[1].Value - 0.06 * v13 * 80,
										child.Size.Keypoints[2].Value
									)
								end

								if not (v9 >= 1) then
									continue
								end

								task.delay(1, function()
									v10:Destroy()
								end)
								break
							end
						end)
					end
				else
					local v8 = tick() - lastTime
					local v9 = math.min(math.max(v8 - 1.75, 0) / 1, 1)
					local v10 = v9 ^ 2 * 8
					local v11 = math.sin(v8 * 23) * v10
					local v12 = math.sin(v8 * 17) * math.rad(v10 * 3)
					v7 = v7 + math.rad(v6 * dt) + math.rad(v9 * v6 * 0.5 * dt)
					total += 0.09 * dt * 80
					local _ = instance2.Position - Vector3.new(0, instance2.Size.Y / 2, 0)

					for k, v13 in clones do
						local v14 = (v8 * 0.25 + (k - 1) / 4) % 1
						local v15 = getHeight(v14) * total
						local v16 = v7 + math.rad(90 * (k - 1)) + v12 * (k % 2 == 0 and 1 or -1)
						local v17 = getRadius(v14) + v11 * (k % 2 == 0 and 1 or -1)
						local vector2 = Vector3.new(
							math.cos(v16) * v17,
							-instance2.Size.Y / 2 + v15,
							math.sin(v16) * v17
						)
						local v18 = (v8 * 0.25 + dt * 0.25 + (k - 1) / 4) % 1
						local vector3 = Vector3.new(
							math.cos(v16 + math.rad(v6 * dt)) * getRadius(v18),
							-instance2.Size.Y / 2 + v18 * total,
							math.sin(v16) * getRadius(v18)
						)
						local v19 = math.min(v8 / 0.4, 1)
						local v20 = instance2.Position + vector2
						v13.CFrame = CFrame.lookAt(
							humanoidRootPart.Position:Lerp(v20, v19 * v19),
							instance2.Position + vector3
						)

						if v19 >= 0.75 and (workspace.CurrentCamera.CFrame.Position - p).Magnitude < 80 and now - tick() > 0.2 then
							CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
							now = tick()
						end

						clone.CFrame = instance2.CFrame

						if clone:FindFirstChild("Wind") then
							if clone.Wind.Enabled == false and v19 >= 0.75 then
								clone.Wind.Enabled = true
								local v22 = v3:PlaySound(
									sounds.Kurourushi.Bugnado.Tornado,
									instance2,
									game.SoundService.Effect
								)
								instance2.AncestryChanged:Once(function()
									v22:Destroy()
								end)
							end

							clone.Wind.Size = NumberSequence.new(
								clone.Wind.Size.Keypoints[1].Value + 0.04 * dt * 80,
								clone.Wind.Size.Keypoints[2].Value
							)
							clone.Wind.Rate += 0.1 * dt * 60
							clone.Size += createVector(0, 0.02, 0) * dt * 80
						end

						for _, child in ipairs(v13:GetChildren()) do
							child.Size = NumberSequence.new(
								child.Size.Keypoints[1].Value + 0.04 * dt * 80,
								child.Size.Keypoints[2].Value
							)
						end
					end
				end
			end)
		end,
		EatSoda = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(101, 35, 44), 1)
			v3:PlaySound(sounds.Mahito.Eat, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Divide = function(folder, folder2)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = folder:Clone()

			if clone.SetAssets:FindFirstChild("HeianArms") then
				clone.SetAssets.HeianArms:Destroy()
			end

			local clone2 = folder:Clone()

			if clone2.SetAssets:FindFirstChild("HeianArms") then
				clone2.SetAssets.HeianArms:Destroy()
			end

			clone.Parent = folder2
			clone2.Parent = folder2

			for _, part in folder2:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				if part.Name == "HumanoidRootPart" or part.Name == "Torso" then
					part.CollisionGroup = "Effects"
				else
					part.CollisionGroup = "NoCollision"
				end

				part.Massless = true
			end

			clone.HumanoidRootPart.Anchored = true
			clone2.HumanoidRootPart.Anchored = true
			local track = clone.Humanoid:LoadAnimation(animations.Kurourushi.Parthenogenesis)
			track:Play(0)
			track.TimePosition = 2.117
			local track2 = clone2.Humanoid:LoadAnimation(animations.Kurourushi.Parthenogenesis)
			track2:Play(0)
			track2.TimePosition = 2.117
			local highlight = Instance.new("Highlight", clone)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			local clone3 = highlight:Clone()
			clone3.Parent = clone2
			TweenService:Create(highlight, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				OutlineTransparency = 0
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				OutlineTransparency = 0
			}):Play()
			local weld = Instance.new("Weld", clone)
			weld.C0 = CFrame.new(0, 0, 0)
			weld.Name = "FolderWeld"
			local weld2 = Instance.new("Weld", clone2)
			weld2.C0 = CFrame.new(0, 0, 0)
			weld2.Name = "FolderWeld"
			TweenService:Create(weld, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				C0 = CFrame.new(-4, 0, 0)
			}):Play()
			TweenService:Create(weld2, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				C0 = CFrame.new(4, 0, 0)
			}):Play()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if not (weld.Parent and weld2.Parent) then
					steppedConnection:Disconnect()
					return
				end

				if weld.Enabled == true then
					clone.HumanoidRootPart.CFrame = humanoidRootPart.CFrame * weld.C0
				end

				if weld2.Enabled == true then
					clone2.HumanoidRootPart.CFrame = humanoidRootPart.CFrame * weld2.C0
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

			task.delay(6, function()
				for k, transparency in transparenciesByDescendant do
					if k.Parent then
						k.Transparency = transparency
					end
				end
			end)
			local clone4 = utils.Kurourushi.Parthenogenesis.RoachUlt:Clone()
			clone4.Weld.Part0 = humanoidRootPart
			clone4.Parent = workspace.Effects
			Debris:AddItem(clone4, 3)
			v3:PlaySound(sounds.Kurourushi.Parthenogenesis.Explode, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(clone4, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = createVector(20, 10, 10)
			}):Play()
			task.delay(0.2, function()
				if not clone4.Parent then
					return
				end

				clone4.In.Roaches.Enabled = false
				clone4.Roaches.Enabled = true
			end)
			folder2.AncestryChanged:Once(function()
				for k, transparency in transparenciesByDescendant do
					if k.Parent then
						k.Transparency = transparency
					end
				end

				clone:Destroy()
				clone2:Destroy()
				weld:Destroy()
				weld2:Destroy()
				clone4.In.Roaches:Emit(20)
				clone4.In.Sparks:Emit(20)
				clone4.RoachFly:Emit(20)
				clone4.Roaches.Enabled = false
				Debris:AddItem(clone4, 1.2)
				v3:PlaySound(sounds.Kurourushi.Parthenogenesis.Explode2, humanoidRootPart, game.SoundService.Effect)

				if (workspace.CurrentCamera.CFrame.Position - clone4.Position).Magnitude < 100 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				end
			end)

			if localPlayer.Character == folder then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 50
					}
				):Play()
				task.delay(1.5, function()
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
						{
							FieldOfView = 70
						}
					):Play()
					shakeSustain:StartFadeOut(0.3)
				end)
			end
		end,
		CollectBugs = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			controller:PlayArms(
				instance,
				animations.Kurourushi.ParthenogenesisArms,
				animations.Kurourushi.Parthenogenesis
			)
			v3:PlaySound(sounds.Kurourushi.Parthenogenesis.Startup, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Kurourushi.Parthenogenesis.RoachUlt2:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			TweenService:Create(clone.RoachFly, TweenInfo.new(2), {
				Rate = 200
			}):Play()
			TweenService:Create(clone.Attachment.Roaches, TweenInfo.new(2), {
				Rate = 200,
				TimeScale = 1
			}):Play()
			task.delay(3, function()
				if not (clone and clone.Parent) then
					return
				end

				if clone:FindFirstChild("Attachment") then
					clone.Attachment.Roaches.Enabled = false
				end

				if clone:FindFirstChild("RoachFly") then
					clone.RoachFly.Enabled = false
				end
			end)
			instance2.AncestryChanged:Once(function()
				if clone:FindFirstChild("Attachment") then
					clone.Attachment.Roaches.Enabled = false
				end

				if clone:FindFirstChild("RoachFly") then
					clone.RoachFly.Enabled = false
				end
			end)
		end,
		StartInvade = function(instance, p, p2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:PlaySound(sounds.Kurourushi.StartInvade, p, game.SoundService.Effect)
			v3:PlaySound(sounds.Kurourushi.StartInvade, p2, game.SoundService.Effect)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
	v.Hitbox:Connect(function(instance, p, object2)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		local v6 = nil

		while true do
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, 0, -4), 8)

			for _, v8 in sphereHitbox do
				local info = v8:FindFirstChild("Info")

				if not info then
					continue
				end

				local knockback = info:FindFirstChild("Knockback")

				if not (not knockback or knockback.Value ~= false) then
					continue
				end

				v6 = sphereHitbox
				break
			end

			if v6 then
				local numberValue = instance:FindFirstChildWhichIsA("NumberValue")

				if numberValue then
					TweenService:Create(numberValue, TweenInfo.new(0.1), {
						Value = 0
					}):Play()
				end
			else
				task.wait(0.05)

				if instance.Parent then
					continue
				end
			end

			object2:FireServer(v6, humanoidRootPart.CFrame)
			break
		end
	end)
	local v6 = nil
	local v7 = nil
	RunService.RenderStepped:Connect(function()
		local target = v4:GetTarget()
		local primaryPart

		if target then
			primaryPart = target.PrimaryPart or nil
		end

		if target ~= v6 then
			if v7 then
				v7.Visible = false
				v7 = nil
			end

			v6 = nil
		end

		if not primaryPart then
			return
		end

		local moveReveal = primaryPart:FindFirstChild("MoveReveal")
		local moveset = moveReveal and moveReveal:FindFirstChild("Moveset") or nil

		if moveset then
			moveset.Visible = true
			v6 = target
			v7 = moveset
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("KurourushiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("ToolController")
end

return controller