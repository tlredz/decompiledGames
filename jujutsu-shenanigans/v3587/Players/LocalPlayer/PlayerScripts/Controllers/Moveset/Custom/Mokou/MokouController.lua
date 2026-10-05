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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "MokouController"
})

local function getTweenData(parent, duration: number, p: string, p2)
	local attribute = parent:GetAttribute(p .. "_TweenParams")
	local v4 = {
		{ "TweenStyle", p2 },
		{ "TweenDirection", Enum.EasingDirection.Out }
	}
	local v5 = {}

	if typeof(attribute) == "string" then
		local v6 = { attribute:match("(%a+),(%a+)") }

		for i = 1, 2 do
			local v7 = v6[i]
			local v8 = v4[i]
			local v9 = v8[1]
			local v10 = v8[2]

			if v7 then
				local v11 = v9
				local v12 = v7

				if not pcall(function()
					v5[v11] = Enum[v11][v12]
				end) then
					v5[v9] = v10
				end
			else
				v5[v9] = v10
			end
		end
	else
		for _, v6 in v4 do
			v5[v6[1]] = v6[2]
		end
	end

	return TweenInfo.new(duration, v5.TweenStyle, v5.TweenDirection)
end

function controller:ArcTween(instance, p)
	local firstChild = instance.Parent:FindFirstChild("End")

	if not firstChild then
		warn("Goal is not defined.")
		return
	end

	local clone = instance:Clone()
	local startTransparency = tonumber(instance.Parent:GetAttribute("StartTransparency")) or 0

	if clone:IsA("MeshPart") then
		clone.Transparency = startTransparency
	elseif clone:IsA("BasePart") and clone:FindFirstChildOfClass("Decal") then
		clone.Transparency = 1
	end

	clone.Parent = workspace.Effects
	local duration = tonumber(instance.Parent:GetAttribute("Duration")) or 0.1

	if clone:FindFirstChildOfClass("Decal") then
		TweenService:Create(clone, getTweenData(instance.Parent, duration, "Part", Enum.EasingStyle.Cubic), {
			Size = firstChild.Size,
			CFrame = firstChild.CFrame
		}):Play()
	else
		TweenService:Create(clone, getTweenData(instance.Parent, duration, "Part", Enum.EasingStyle.Cubic), {
			Size = firstChild.Size,
			CFrame = firstChild.CFrame,
			Color = firstChild.Color
		}):Play()

		if p == true then
			TweenService:Create(clone, getTweenData(instance.Parent, duration, "Part", Enum.EasingStyle.Cubic), {
				Transparency = 1
			}):Play()
		else
			clone.Transparency = 0
		end
	end

	local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")
	local specialMesh2 = firstChild:FindFirstChildOfClass("SpecialMesh")

	if specialMesh and specialMesh2 then
		TweenService:Create(specialMesh, getTweenData(instance.Parent, duration, "Mesh", Enum.EasingStyle.Sine), {
			Scale = specialMesh2.Scale
		}):Play()
	end

	local decal = clone:FindFirstChildOfClass("Decal")
	local decal2 = firstChild:FindFirstChildOfClass("Decal")

	if decal and decal2 then
		decal.Transparency = startTransparency
		TweenService:Create(decal, getTweenData(instance.Parent, duration, "Decal", Enum.EasingStyle.Cubic), {
			Color3 = decal2.Color3
		}):Play()

		if p == true then
			TweenService:Create(decal, getTweenData(instance.Parent, duration, "Decal", Enum.EasingStyle.Cubic), {
				Transparency = 1
			}):Play()
		else
			decal.Transparency = 0
		end
	end

	task.delay(duration, clone.Destroy, clone)
end

function controller:KnitStart()
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Misc.M.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.M.Hit:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				math.random(-20, 20) / 10,
				math.random(-20, 20) / 10,
				math.random(-10, 10) / 10
			)
			clone.Parent = workspace.Effects
			clone.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.15), {
				Size = createVector(7, 7, 7),
				Transparency = 1,
				Color = Color3.new(1, 0.333333, 0)
			}):Play()
			Debris:AddItem(clone, 0.6)

			if p == 4 then
				clone.Flames:Emit(20)
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
			v3:PlaySound(sounds.Misc.M.M1:FindFirstChild("Hit3"), humanoidRootPart, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
			local clone2 = utils.Misc.M.Hit:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(
				math.random(-20, 20) / 10,
				math.random(-20, 20) / 10,
				math.random(-10, 10) / 10
			)
			clone2.Parent = workspace.Effects
			clone2.Sparks:Emit(20)
			TweenService:Create(clone2, TweenInfo.new(0.15), {
				Size = createVector(7, 7, 7),
				Transparency = 1,
				Color = Color3.new(1, 0.333333, 0)
			}):Play()
			Debris:AddItem(clone2, 0.6)
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position - createVector(0, 4, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
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
		Swing2 = function(data, value, p)
			local humanoidRootPart = data.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.M.Swing[math.clamp(value, 1, 4)], humanoidRootPart, game.SoundService.Effect)

			if p == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 85, 0), 0.4)
			elseif p == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 0), 0.3)
			elseif value == 1 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 0), 0.3)
			elseif value == 2 or value == 3 then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 85, 0), 0.3)
			elseif value == 4 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 85, 0), 0.4)
			elseif value == 5 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 0), 0.4)
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
		Revive = function(player, p, cFrame)
			task.spawn(function()
				if localPlayer == player then
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				end

				repeat
					task.wait()
				until not (p.Parent and player.Character and player.Parent)

				if localPlayer == player then
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.CameraSubject = player.Character:WaitForChild("Humanoid")
				end

				local highlight = Instance.new("Highlight", player.Character)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.fromRGB(255, 255, 127)
				highlight.FillColor = Color3.fromRGB(255, 255, 127)
				highlight.FillTransparency = 0
				Debris:AddItem(highlight, 0.7)
				TweenService:Create(
					highlight,
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						FillTransparency = 1,
						OutlineTransparency = 1,
						FillColor = Color3.fromRGB(0, 0, 0),
						OutlineColor = Color3.fromRGB(255, 0, 0)
					}
				):Play()
			end)

			if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
			end

			local clone = utils.Misc.M.Revive:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			v3:PlaySound(sounds.Misc.M.Revive, clone, game.SoundService.Effect)
			Debris:AddItem(clone, 3)

			for _, child in clone.Activate:GetChildren() do
				if (child:GetAttribute("EmitDuration") or 0) > 0 then
					child.Enabled = true
				end

				if (child:GetAttribute("EmitCount") or 0) > 0 then
					child:Emit(child:GetAttribute("EmitCount") or 0)
				end
			end

			task.wait(0.6)

			for _, child in clone.Activate:GetChildren() do
				child.Enabled = false
			end

			for _, child in clone.Explode:GetChildren() do
				if (child:GetAttribute("EmitDuration") or 0) > 0 then
					child.Enabled = true
					local v5 = child
					task.delay(child:GetAttribute("EmitDuration") or 0, function()
						v5.Enabled = false
					end)
				end

				if (child:GetAttribute("EmitCount") or 0) > 0 then
					child:Emit(child:GetAttribute("EmitCount") or 0)
				end
			end
		end,
		Wing = function(p, instance)
			local clone = utils.Misc.M.wing:Clone()
			clone.Parent = p.Torso

			-- equivalent calls inferred from this helper; original call sites unknown
			local function yep(instance2)
				return instance2:IsA("ParticleEmitter") or instance2:IsA("Beam") or instance2:IsA("PointLight")
			end

			instance:GetPropertyChangedSignal("Value"):Connect(function()
				for _, descendant in clone.Left:GetDescendants() do
					if yep(descendant) then
						descendant.Enabled = true
					end
				end

				for _, descendant in clone.prewing:GetDescendants() do
					if yep(descendant) then
						descendant.Enabled = false
					end
				end

				for _, descendant in clone.right:GetDescendants() do
					if yep(descendant) then
						descendant.Enabled = true
					end
				end
			end)

			repeat
				task.wait()
			until not instance:IsDescendantOf(workspace.Characters)

			Debris:AddItem(clone, 1.5)

			for _, descendant in clone:GetDescendants() do
				if yep(descendant) then
					descendant.Enabled = false
				end
			end
		end,
		WingFly = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Misc.M.WingFly:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, emitter in clone.WHAT["1"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			TweenService:Create(clone.WHAT, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = createVector(18, 18, 18),
				Color = Color3.fromRGB(255, 64, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(
				clone.Mesh.Start,
				TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone.Mesh.End.Size,
					Transparency = 1,
					CFrame = clone.Mesh.End.CFrame
				}
			):Play()
			TweenService:Create(clone.Mesh2.Start, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = clone.Mesh2.End.Size,
				Transparency = 1,
				CFrame = clone.Mesh2.End.CFrame
			}):Play()
			TweenService:Create(
				clone.Mesh3.Start,
				TweenInfo.new(2.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = clone.Mesh3.End.Size,
					Transparency = 1,
					CFrame = clone.Mesh3.End.CFrame
				}
			):Play()
			clone.Mesh.End:Destroy()
			clone.Mesh2.End:Destroy()
			clone.Mesh3.End:Destroy()
		end,
		Interp = function(p, cFrame, p2, instance)
			local clone = instance:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local v5 = tick() + p2
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if p.Parent and not (v5 < tick()) then
					clone.CFrame = clone.CFrame:Lerp(clone.CFrame * p.Value, dt)
					return
				end

				clone:Destroy()
				steppedConnection:Disconnect()
			end)
		end,
		Kill = function(folder)
			local humanoidRootPart = folder.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.M.Kill, humanoidRootPart, game.SoundService.Effect)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			local clone = utils.Misc.M.TouhouBurst.Attachment:Clone()
			clone.Parent = humanoidRootPart
			clone.Burst:Emit(1)
			clone.Power:Emit(6)
			clone.Power2:Emit(1)

			if localPlayer.Character == folder then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(2)
				game.Lighting.ExposureCompensation = 3
				TweenService:Create(game.Lighting, TweenInfo.new(1), {
					ExposureCompensation = 0
				}):Play()
			end
		end,
		Awaken = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.M.MokouUlt, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.3)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			local clone = utils.Misc.M.Awk.Att:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 10)

			for _, child in utils.Misc.M.Awk.mokultMeh["1"]:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame)
				self:ArcTween(child.Start, true)
			end

			for _, parent in clone:GetChildren() do
				local weld = Instance.new("Weld", parent)
				weld.Part0 = p[parent.Name]
				weld.Part1 = parent
			end

			for _, emitter in clone.HumanoidRootPart["1"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Misc.M.Awk.melting:Clone()
			clone2.Parent = workspace.Effects
			clone2.Weld.Part0 = humanoidRootPart
			Debris:AddItem(clone2, 10)
			task.wait(1.75)

			for _, emitter in clone["Right Arm"]["2"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _, emitter in clone2.Melt:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2.Melt22.Enabled = true

			for _, emitter in clone2.Melt2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(1)
			local clone3 = utils.Misc.M.Awk.Pre:Clone()
			clone3.CFrame = humanoidRootPart.CFrame
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 5)
			task.wait(0.2)
			clone3.ParticleEmitter.Enabled = false
			clone3.Attachment.ParticleEmitter:Emit(clone3.Attachment.ParticleEmitter:GetAttribute("EmitCount"))
			task.wait(0.2)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)

			for _, emitter in clone.HumanoidRootPart["2"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			for _, emitter in clone["Right Arm"]["2"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in clone["Right Arm"]["1"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in clone.Head:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _, child in utils.Misc.M.Awk.mokultMeh["2"]:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame)
				self:ArcTween(child.Start, true)
			end

			task.wait(0.3)

			for _, emitter in clone.HumanoidRootPart["3"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone4 = utils.Misc.M.Awk.meshUP:Clone()
			clone4.CFrame = clone3.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) + createVector(0, 5, 0)
			clone4.Parent = workspace.Effects
			Debris:AddItem(clone4, 0.4)
			TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = createVector(102.794, 0.001, 0.001),
				CFrame = clone4.CFrame + createVector(0, 30, 0)
			}):Play()

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame)
				self:ArcTween(child.Start, true)
			end

			task.wait(0.25)

			for _, emitter in clone.Torso["1"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(1.6)

			for _, emitter in clone.Torso["2"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.4)

			for _, emitter in clone.Torso["1"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in clone.Torso["2"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in clone.Torso["2.5"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone5 = utils.Misc.M.Awk.GETIN:Clone()
			clone5.CFrame = humanoidRootPart.CFrame
			clone5.Parent = workspace.Effects
			Debris:AddItem(clone5, 5)
			task.delay(0.2, function()
				for _, emitter in clone5:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in clone5.Attachment:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(0.5)

				for _, emitter in clone5.Attachment:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait(0.7)

			for _, emitter in clone.Torso["2.7"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.05)
			CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(2)

			for _, emitter in clone.Torso["3"]:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.5)

			for _, emitter in clone.Head:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
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
	v.Hitbox:Connect(function(instance, p, object2)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		local v5 = nil

		while true do
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, 0, -4), 8)

			for _, v7 in sphereHitbox do
				local info = v7:FindFirstChild("Info")

				if not info then
					continue
				end

				local knockback = info:FindFirstChild("Knockback")

				if not (not knockback or knockback.Value ~= false) then
					continue
				end

				v5 = sphereHitbox
				break
			end

			if v5 then
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

			object2:FireServer(v5, humanoidRootPart.CFrame)
			break
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("MokouService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

controller.SpawnAnim = "109651238159963"
controller.SpawnFunc = {
	Startup = function(data, list)
		local humanoidRootPart = data.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		v3:PlaySound(sounds.Misc.M.MokouSpawnVoice, humanoidRootPart, game.SoundService.Voice)
		local v4 = v3:PlaySound(sounds.Misc.M.MokouSpawn, humanoidRootPart, game.SoundService.Effect)
		table.insert(list, v4)
		task.wait(0.1)

		if not v4.Parent then
			return
		end

		local clone = utils.Misc.M.SnapArm:Clone()
		clone.Weld.Part0 = data["Right Arm"]
		clone.Parent = workspace.Effects
		clone.Core.Sparks:Emit(15)
		clone.Core.Burst:Emit(1)
		table.insert(list, clone)

		if localPlayer.Character == data then
			local TekrinnDialogue = require(replicatedStorage.Modules.TekrinnDialogue)
			TekrinnDialogue.Speak(data, {
				{
					Text = "I'll show you the legendary phoenix...",
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
					}),
					TextStrokeColor = Color3.new(0.333333, 0, 0),
					Bold = false,
					Italic = true,
					Shake = {
						Enabled = false,
						Intensity = 1,
						Lifetime = 1
					},
					TypeSpeed = 0.08
				}
			})
			task.delay(3.8, function()
				if not data.Parent then
					return
				end

				TekrinnDialogue.Speak(data, {
					{
						Text = "that grows stronger each time it's reborn.",
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
						}),
						TextStrokeColor = Color3.new(0.333333, 0, 0),
						Bold = false,
						Italic = true,
						Shake = {
							Enabled = true,
							Intensity = 3,
							Lifetime = 1
						},
						TypeSpeed = 0.025
					}
				})
			end)
		end
	end,
	Hitbox = function(p, clones)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		local clone = utils.Misc.M.FlameArm:Clone()
		clone.Weld.Part0 = p["Left Arm"]
		clone.Parent = workspace.Effects
		clone.Core.Sparks:Emit(25)
		clone.Core.Ring:Emit(6)
		clone.Core.Flash:Emit(1)
		clone.Core.Burst:Emit(1)
		clone.Core.Flare:Emit(1)
		clone.Core.Heat:Emit(2)
		TweenService:Create(clone.PointLight, TweenInfo.new(1.5), {
			Brightness = 0,
			Color = Color3.new(1, 0, 0)
		}):Play()
		TweenService:Create(clone.Core.Flames, TweenInfo.new(1.5), {
			Rate = 0
		}):Play()
		table.insert(clones, clone)
		local clone2 = utils.Hiromi.Shockwave:Clone()
		clone2.Position = humanoidRootPart.Position - createVector(0, 3, 0)
		clone2.Parent = workspace.Effects
		clone2.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
		TweenService:Create(clone2.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Scale = createVector(15, 0, 15)
		}):Play()
		TweenService:Create(clone2.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Transparency = 1
		}):Play()
		clone2.Floor.Glow:Emit(1)
		clone2.Floor.Ring:Emit(10)
		Debris:AddItem(clone2, 1.5)

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
		end
	end
}
return controller