local createVector = vector.create
local _ = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pool = require(game.ReplicatedStorage:WaitForChild("Pool"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
workspace:WaitForChild("_WorldOrigin")
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local buzzcut = dough.Models.Arms:FindFirstChild("Buzzcut")
local v = {
	Character = {
		{ "WindUp Buzz", 0.5 },
		{ "Buzz Loop", 0.5 },
		{ "Buzz Slam Final", 1.5 },
		{ "End Hold Buzz", 1 },
		{ "Buzzcut Retract", 1.7333333333333334 }
	},
	Arm = {
		{ "WindUp Buzz", 0.96 },
		{ "Buzz Loop", 3.183333333333333 },
		{
			"Buzz Slam Final",
			1.4333333333333333,
			1.4833333333333334,
			3
		},
		{ "Buzzcut Retract", 0.79 }
	}
}

local function GetAnimationData(p, value)
	local lower = value:lower()
	local v2 = v[p]

	for k, v3 in pairs(v2) do
		if v3[1]:lower() == lower then
			return v2[k]
		end
	end
end

local function darkenColor(color, p)
	return (p or Color3.new(0.1, 0.1, 0.1)):Lerp(color or Color3.new(1, 1, 1), 0.5):Lerp(Color3.new(), 0.575)
end

local function SetupModel(clone)
	local v2 = {
		Scale = 1,
		Model = clone,
		RootPart = clone.PrimaryPart
	}
	v2.RootBone = v2.RootPart:FindFirstChildOfClass("Bone")
	v2.RootJoint = v2.RootPart:FindFirstChildOfClass("Motor6D")
	v2.Parts = {}
	v2.Joints = {}
	v2.Bones = {
		Extendable = { 2, 11 },
		Steady = { 24, 31 },
		Spike = {}
	}
	v2.SpikeData = {}

	for _, part in pairs(v2.Model:GetChildren()) do
		if part:IsA("BasePart") then
			v2.Parts[part] = {
				Offset = v2.RootPart.CFrame:ToObjectSpace(part.CFrame),
				Size = part.Size
			}
			local motor6D = part:FindFirstChildOfClass("Motor6D")

			if motor6D then
				v2.Joints[motor6D] = {
					C0 = motor6D.C0,
					C1 = motor6D.C1
				}
			end
		end

		if part ~= v2.RootPart then
			continue
		end

		local count = 0
		local count2 = 0
		local prepBone
		local prepBone2 = prepBone

		prepBone = function(bone)
			if not bone:IsA("Bone") then
				return
			end

			local v3 = {
				Object = bone,
				Offset = v2.RootPart.CFrame:ToObjectSpace(bone.WorldCFrame),
				Position = bone.Position
			}
			count += 1
			v2.Bones[count] = v3
			local v4 = count

			for i, child in pairs(bone:GetChildren()) do
				if child.Name:find("Spike") then
					if not v3.Spikes then
						count2 += 1
						v3.Spikes = {}
						v2.Bones.Spike[count2] = v4
					end

					table.insert(v3.Spikes, {
						Object = child,
						Position = child.Position
					})
				else
					prepBone2(child)
				end
			end
		end

		prepBone(v2.RootBone)
	end

	table.sort(v2.Bones.Spike, function(a, b)
		return a < b
	end)
	v2.LengthToRoot = (v2.Bones[1].Object.WorldPosition - v2.RootPart.Position).Magnitude
	v2.LengthToFist = (v2.RootPart.CFrame * Vector3.new(0, 0, -v2.Model:GetModelSize().Z / 2) - v2.Bones[#v2.Bones].Object.WorldPosition).Magnitude
	v2.CurrentLength = 0
	local bone = v2.Bones[v2.Bones.Extendable[1]]
	local bone2 = v2.Bones[v2.Bones.Extendable[2]]
	v2.CurrentLength = (bone.Object.WorldPosition - bone2.Object.WorldPosition).Magnitude
	return v2
end

local function ScaleModel(state, p)
	local scale = math.max(0.001, p or state.Scale)
	state.Scale = scale

	for _, bone in pairs(state.Bones) do
		if not bone.Object then
			continue
		end

		bone.Object.Position = bone.Position * scale

		if not bone.Spikes then
			continue
		end

		for _, spike in pairs(bone.Spikes) do
			spike.Object.Position = spike.Position * scale
		end
	end

	for _, v3 in pairs({ state.Parts, state.Joints }) do
		for instance, v4 in pairs(v3) do
			if typeof(instance) ~= "Instance" then
				continue
			end

			if instance:IsA("BasePart") then
				instance.Size = v4.Size * scale * (instance:GetAttribute("Scale") or 1)
			end

			if not instance:IsA("Motor6D") then
				continue
			end

			instance.C0 = Util.Misc.scaleCF(v4.C0, scale)
			instance.C1 = Util.Misc.scaleCF(v4.C1, scale)
		end
	end
end

local function PaintModel(armObject, buso, windUpDuration)
	local now = tick()
	local color

	if typeof(buso) == "Instance" then
		color = buso.Color
	else
		color = buso
	end

	if not armObject.ColorStart then
		armObject.ColorStart = now
	end

	local v2 = math.min(1, (now - armObject.ColorStart) / (windUpDuration or 1))
	local sine = Util.Tween.ease.inout.sine(v2, 0, 1, 1)

	for k, _ in pairs(armObject.Parts) do
		if k.Name == "Layer" then
			if color and typeof(color) == "Color3" and typeof(buso) == "Instance" then
				k.Transparency = 0
				k.Color = color
			else
				k.Transparency = 1
			end
		elseif k.Name == "Haki" then
			local v3

			if typeof(color) == "Color3" and typeof(buso) == "Instance" then
				v3 = darkenColor(color)
			else
				v3 = darkenColor(Color3.new())
			end

			local v4

			if color and typeof(color) == "Color3" then
				v4 = color
			else
				v4 = Color3.new(1, 1, 1)
			end

			k.Color = v4:Lerp(v3, sine)
			k.Material = v2 == 1 and Enum.Material.Glass or Enum.Material.Neon
		end
	end
end

local localPlayer = game.Players.LocalPlayer
local v2 = {}
local v3 = Pool.new(string.format("Dough/%s/%s", script.Parent.name, script.Name))

local function adjustDuration(p, p2)
	local v4 = p - p2
	return v4, p2 - (p - v4)
end

v3:setAction(function(object, _)
	local now = tick()

	for _, v4 in pairs(object.Pool) do
		if v2[v4.Character] and v4.Object.Hitbox:IsDescendantOf(workspace) and v4.Object.Hitbox:FindFirstChildOfClass("Weld") then
			local bone = v4.Object.ArmObject.Bones[#v4.Object.ArmObject.Bones - 5]
			v4.Object.Hitbox.Weld.C0 = v4.Object.Hitbox.Weld.Part0.CFrame:ToObjectSpace(bone.Object.TransformedWorldCFrame)
			PaintModel(v4.Object.ArmObject, v4.Object.Buso, v4.Object.WindUpDuration)

			if v4.HasRights then
				if not v4.LastPoll then
					v4.LastPoll = 0
				end

				if now - v4.LastPoll > 0.022222222222222223 then
					v4.Remote:FireServer({
						Player = localPlayer,
						Weld = v4.Object.Hitbox.Weld,
						C0 = v4.Object.Hitbox.Weld.C0
					})
					v4.LastPoll = now
				end
			end
		else
			object:remove(v4)
		end
	end
end)
return function(player)
	local stage = player.Stage or 1
	local character = player.Character
	local hasRights = game.Players:GetPlayerFromCharacter(character) == localPlayer
	local v5 = { "Arm" }

	if hasRights then
		v5[#v5 + 1] = "Character"
	end

	local function scaleObject(instance, p)
		if not v2[character] then
			return
		end

		local v6 = p or v2[character].Hitbox.Size.Magnitude / 28

		if instance:IsA("ParticleEmitter") then
			Util.Misc.ScaleParticle(instance, v6)
		elseif instance:IsA("Attachment") then
			instance.Position /= 8
			instance.Position *= v6
		end
	end

	if stage == 1 then
		if v2[character] then
			warn("Why are you calling me again?")
			return
		end

		v2[character] = {
			Hitbox = player.Hitbox,
			Buso = player.Buso,
			CFrame = player.CFrame,
			SlamCFrame = player.SlamCFrame,
			RaiseHeight = player.RaiseHeight,
			TotalSpins = player.TotalSpins,
			WindUpDuration = player.WindUpDuration,
			SpinDuration = player.SpinDuration,
			SlamDuration = player.SlamDuration,
			SlamHoldDuration = player.SlamHoldDuration,
			RetractDuration = player.RetractDuration
		}
		v2[character].TotalDuration = v2[character].WindUpDuration + v2[character].SpinDuration + v2[character].SlamDuration + v2[character].SlamHoldDuration + v2[character].RetractDuration
		local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightUpperArm")
		local clone = buzzcut:Clone()
		local motor6D = clone.PrimaryPart:FindFirstChildOfClass("Motor6D")
		clone:SetPrimaryPartCFrame(rightHand.CFrame)
		motor6D.Part0 = rightHand
		local armObject = SetupModel(clone)
		ScaleModel(armObject, 0, 0)
		clone.Parent = character
		local BG, BP

		if hasRights then
			local duration = 0 + v2[character].WindUpDuration + v2[character].SpinDuration + v2[character].SlamDuration + v2[character].SlamHoldDuration + v2[character].RetractDuration
			BG = Util.BodyMover.new(character):Create("BodyGyro", {
				CFrame = v2[character].CFrame,
				MaxTorque = createVector(900000, 900000, 900000),
				D = 300,
				Duration = duration,
				Priority = 1000
			})
			BP = Util.BodyMover.new(character):Create("BodyPosition", {
				Position = v2[character].CFrame.p,
				P = 10000,
				MaxForce = createVector(900000, 900000, 900000),
				D = 300,
				Duration = duration,
				Priority = 1000
			})
		end

		local animationControllers = {
			Character = character:FindFirstChildOfClass("Humanoid"),
			Arm = clone:FindFirstChildOfClass("AnimationController")
		}
		local animations = {
			Arm = clone:FindFirstChild("Animations"):GetChildren()
		}
		v2[character].PreviousAnimation = ""
		v2[character].AnchorPart = rightHand
		v2[character].Arm = clone
		v2[character].MainJoint = motor6D
		v2[character].ArmObject = armObject
		v2[character].BP = BP
		v2[character].BG = BG
		v2[character].AnimationControllers = animationControllers
		v2[character].Animations = animations
		v2[character].AnimationCache = {
			Arm = {}
		}

		v2[character].GetAnimation = function(p, p2, value)
			if p2 == "Character" then
				return Util.Anims:Get(character, value)
			end

			local lower = value:lower()
			local animation = p.Animations[p2]

			for _, v11 in pairs(animation) do
				if v11.Name:lower() == lower then
					return v11
				end
			end
		end

		v2[character].GetAnimationTrack = function(p, p2, value)
			if p2 == "Character" then
				return Util.Anims:Get(character, value)
			end

			local lower = value:lower()
			local v11 = p.AnimationCache[p2]

			for k, v12 in pairs(v11) do
				if k:lower() == lower then
					return v12
				end
			end
		end

		v2[character].LoadAnimation = function(object, p, p2)
			local animationTrack = object:GetAnimationTrack(p, p2)

			if animationTrack then
				return animationTrack
			end

			local animation = object:GetAnimation(p, p2)

			if not animation then
				return
			end

			local track = object.AnimationControllers[p]:LoadAnimation(animation)
			object.AnimationCache[p][p2] = track
			return track
		end

		v3:add({
			Character = character,
			HasRights = hasRights,
			Remote = player.Remote,
			Object = v2[character]
		})
		Effect.new("Dough.C.Arm"):replicate({
			Stage = 0,
			Character = character,
			Locked = false
		})
		local windUpDuration = v2[character].WindUpDuration
		local v11 = Util.MasterClock:GetTime() - player.Timestamp
		local v12 = windUpDuration - v11
		v11 -= windUpDuration - v12

		if v12 <= 0 then
			return
		end

		if typeof(v2[character].Buso) == "Instance" then
			local color = v2[character].Buso.Color
			local v13 = v2[character].ArmObject.Parts[v2[character].ArmObject.Model.Haki].Size.Magnitude * 0.3 * v2[character].ArmObject.Scale
			local v14 = {}
			local v15 = 0

			for _, child in pairs(dough.Particles.Buso:GetChildren()) do
				local clone2 = child:Clone()
				v14[clone2] = {
					Size = clone2.Size.Keypoints,
					Acceleration = clone2.Acceleration,
					Speed = clone2.Speed,
					ZOffset = clone2.ZOffset
				}
				Util.Misc.ScaleParticle(clone2, v13 / 2, v14[clone2])
				clone2.Color = ColorSequence.new(color)
				clone2.Parent = v2[character].ArmObject.Model.Haki
				clone2:Emit((clone2:GetAttribute("Emit") or 10) + v13)
				clone2.Enabled = true
				local v16 = v15 + v12
				v15 = math.max(v16, child.Lifetime.Max)
				task.delay(v12, function()
					clone2.Enabled = false
					v14[clone2] = nil
					Util.Debris:AddItem(clone2, clone2.Lifetime.Max + 0.1)
				end)
			end

			Util.DistributedLoop:add(function(p, _)
				if not (character:IsDescendantOf(workspace) and v2[character]) then
					return true
				end

				local v16 = math.min(1, p / v15)
				local count = 0

				for _, v17 in pairs(v14) do
					if v17 then
						count += 1
					end
				end

				local v17 = v2[character].ArmObject.Parts[v2[character].ArmObject.Model.Haki].Size.Magnitude * 0.3 * v2[character].ArmObject.Scale

				for k, v18 in pairs(v14) do
					Util.Misc.ScaleParticle(k, v17 / 2, v18)
				end

				if v16 == 1 or count == 0 then
					return true
				end
			end)
		end

		local v13 = {}
		task.delay(v12 / 2, function()
			local color = nil

			if typeof(v2[character].Buso) == "Instance" then
				color = v2[character].Buso.Color
			elseif typeof(v2[character].Buso) == "Color3" then
				color = v2[character].Buso
			end

			for _, child in pairs(dough.C.Arm.Assets.Spawn:GetChildren()) do
				local clone2 = child:Clone()

				for _, emitter in pairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
						table.insert(v13, emitter)
					end

					scaleObject(emitter)
				end

				if clone2:IsA("ParticleEmitter") then
					clone2.Enabled = false
					table.insert(v13, clone2)
				end

				scaleObject(clone2)
				clone2.Parent = v2[character].Hitbox
				Util.Debris:AddItem(clone2, v2[character].TotalDuration)
			end

			local lifetime = v12 / 4

			for _, particle in pairs(v13) do
				if color then
					particle.Color = Util.Misc.SwapColorInKeypoints(particle.Color, Color3.new(1, 0, 0), color)
				end

				local emitCount = particle:GetAttribute("EmitCount")

				if emitCount then
					particle:Emit(emitCount)
				end

				if not (particle.Name:find("Lightning") or particle.Name:find("Beam")) then
					continue
				end

				particle.Enabled = true

				if particle.Name:find("Lightning") then
					Effect.new("Dough.Misc.SpriteParticle"):replicate({
						Particle = particle,
						Sprite = particle.Name,
						Duration = particle.Lifetime.Max,
						Lifetime = lifetime
					})
				end
			end

			task.wait(lifetime)
			local v15 = 0

			for _, v16 in pairs(v13) do
				v15 = math.max(v15, v16.Lifetime.Max)
				v16.Enabled = false
			end

			task.delay(v15, function()
				for k, v16 in pairs(v13) do
					v16:Destroy()
					v13[k] = nil
				end
			end)
		end)
		v2[character].PreviousAnimation = "WindUp Buzz"

		for _, animation in pairs(v5) do
			local animationData = GetAnimationData(animation, "WindUp Buzz")
			v2[character]:LoadAnimation(animation, "WindUp Buzz"):Play(nil, nil, animationData[2] / v12)
		end

		local lastTime = tick()

		while character:IsDescendantOf(workspace) and v2[character] do
			local v14 = math.min(1, (tick() - lastTime) / (v12 - 0.03333333333333333))
			ScaleModel(v2[character].ArmObject, v14, v2[character].ArmObject.CurrentLength * v14)

			if v14 == 1 then
				break
			else
				task.wait(0.016666666666666666)
			end
		end

		if not v2[character] then
			return
		end

		for _, v14 in pairs(v5) do
			v2[character]:GetAnimationTrack(v14, "WindUp Buzz"):Stop()
		end
	else
		if not v2[character] then
			return
		end

		if stage == -1 then
			local previousAnimation = v2[character].PreviousAnimation

			if previousAnimation then
				for _, v6 in pairs(v5) do
					local animationTrack = v2[character]:GetAnimationTrack(v6, previousAnimation)

					if animationTrack then
						animationTrack:Stop()
					end
				end
			end

			v2[character].Arm:Destroy()

			if hasRights then
				v2[character].BG:Set(v2[character].CFrame)
				v2[character].BG:Destroy()
				v2[character].BP:Destroy()
			end

			v2[character].Arm:Destroy()
			v2[character] = nil
		elseif stage == 0 then
			local v6 = 0

			for _, emitter in pairs(v2[character].ArmObject.Model.Haki.Particles:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v6 = math.max(v6, emitter.Lifetime.Max)
				emitter.LockedToPart = player.Locked
				local emitCount = emitter:GetAttribute("EmitCount") or emitter:GetAttribute("Emit")

				if emitCount then
					emitter:Emit(emitCount)
				end
			end

			Util.Sound:Play("Dough.DoughBuzzGrab", v2[character].Hitbox, nil, 1.732 / v6)
		elseif stage == 2 then
			local spinDuration = v2[character].SpinDuration
			local v6 = Util.MasterClock:GetTime() - player.Timestamp
			local v7 = spinDuration - v6
			v6 -= spinDuration - v7

			if v7 <= 0 then
				return
			end

			local previousAnimation = v2[character].PreviousAnimation

			for _, v8 in pairs(v5) do
				local animationTrack = v2[character]:GetAnimationTrack(v8, previousAnimation)

				if animationTrack then
					animationTrack:Stop()
				end
			end

			v2[character].PreviousAnimation = "Buzz Loop"

			for _, animation in pairs(v5) do
				local animationData = GetAnimationData(animation, "Buzz Loop")
				local track = v2[character]:LoadAnimation(animation, "Buzz Loop")

				if animation == "Arm" then
					track:Play(nil, nil, animationData[2] / v7)
				else
					track:Play(nil, nil, animationData[2] / (v7 / v2[character].TotalSpins))
				end
			end

			task.wait(v7 - 0.03333333333333333)

			if not (character:IsDescendantOf(workspace) and v2[character]) then
				return
			end

			local animationData2 = GetAnimationData("Arm", "Buzz Loop")
			local animationTrack = v2[character]:GetAnimationTrack("Arm", "Buzz Loop")
			animationTrack:AdjustSpeed(0)
			animationTrack.TimePosition = animationData2[2] - 0.016666666666666666
		elseif stage == 3 then
			local slamDuration = v2[character].SlamDuration
			local v6 = Util.MasterClock:GetTime() - player.Timestamp
			local v7 = slamDuration - v6
			v6 -= slamDuration - v7

			if v7 <= 0 then
				return
			end

			local previousAnimation = v2[character].PreviousAnimation

			for _, v8 in pairs(v5) do
				local animationTrack = v2[character]:GetAnimationTrack(v8, previousAnimation)

				if animationTrack then
					animationTrack:Stop()
				end
			end

			v2[character].PreviousAnimation = "Buzz Slam Final"
			local animationData = GetAnimationData("Arm", "Buzz Slam Final")
			local v9 = v7 * (animationData[3] - animationData[2])

			for _, animation in pairs(v5) do
				local animationData2 = GetAnimationData(animation, "Buzz Slam Final")
				local track = v2[character]:LoadAnimation(animation, "Buzz Slam Final")
				local v11

				if animation == "Arm" then
					v11 = animationData2[4] / (v7 * animationData2[3] + v9)
				else
					v11 = animationData2[2] / v7
				end

				track:Play(nil, nil, v11)
			end

			task.wait(v7 - 0.03333333333333333)

			if not (character:IsDescendantOf(workspace) and v2[character]) then
				return
			end

			v2[character].PreviousCharacterAnimation = "End Hold Buzz"

			if hasRights then
				GetAnimationData("Character", "Buzz Slam Final")
				local animationTrack = v2[character]:GetAnimationTrack("Character", "Buzz Slam Final")

				if animationTrack then
					animationTrack:Stop()
				end

				local animationData2 = GetAnimationData("Character", "End Hold Buzz")
				local track = v2[character]:LoadAnimation("Character", "End Hold Buzz")

				if track then
					track:Play(nil, nil, animationData2[2] / v2[character].SlamHoldDuration)
				end
			end

			local animationData3 = GetAnimationData("Arm", "Buzz Slam Final")
			local animationTrack = v2[character]:GetAnimationTrack("Arm", "Buzz Slam Final")
			local v11 = v9 / 2
			task.spawn(function()
				local lastTime = tick()
				local v12 = v2[character].SlamCFrame * (createVector(0, 1, 0) * v2[character].RaiseHeight)
				local rayMap, v13, _ = Util.RayMap(
					v2[character].SlamCFrame.p,
					v2[character].SlamCFrame.UpVector * v2[character].RaiseHeight
				)

				if rayMap then
					v12 = v13
				end

				local vector2 = v12 - v2[character].CFrame.p
				local upVector = v2[character].SlamCFrame.UpVector
				local dot = vector2:Dot(upVector)

				while character:IsDescendantOf(workspace) and v2[character] do
					local v14 = math.clamp((tick() - lastTime) / v11, 0, 1)
					local circ = Util.Tween.ease.out.circ(v14, 0, 1, 1)

					if hasRights then
						v2[character].BP:Set(v2[character].CFrame * (upVector * (dot * circ)))
					end

					if v14 == 1 then
						break
					else
						task.wait(0.016666666666666666)
					end
				end

				if not v2[character] then
					return
				end

				animationTrack:AdjustSpeed(0)
				animationTrack.TimePosition = animationData3[2] - 0.016666666666666666
			end)
		elseif stage == 4 then
			local retractDuration = v2[character].RetractDuration
			local v6 = Util.MasterClock:GetTime() - player.Timestamp
			local v7 = retractDuration - v6
			v6 -= retractDuration - v7
			local v8 = math.max(v7, 0.01)
			task.delay(v8, function()
				if not v2[character] then
					return
				end

				pcall(function()
					local previousAnimation = v2[character].PreviousAnimation

					if previousAnimation then
						for _, v9 in pairs(v5) do
							local animationTrack = v2[character]:GetAnimationTrack(v9, previousAnimation)

							if animationTrack then
								animationTrack:Stop()
							end
						end
					end
				end)
				pcall(function()
					v2[character].Arm:Destroy()
				end)
				pcall(function()
					if hasRights then
						v2[character].BG:Set(v2[character].CFrame)
						v2[character].BG:Destroy()
						v2[character].BP:Destroy()
					end
				end)
				v2[character] = nil
			end)
			local flag = false

			if hasRights then
				local previousCharacterAnimation = v2[character].PreviousCharacterAnimation

				if previousCharacterAnimation then
					GetAnimationData("Character", previousCharacterAnimation)
					local animationTrack = v2[character]:GetAnimationTrack("Character", previousCharacterAnimation)

					if animationTrack then
						animationTrack:Stop()
					end
				else
					flag = true
					local previousAnimation = v2[character].PreviousAnimation
					GetAnimationData("Character", previousAnimation)
					local animationTrack = v2[character]:GetAnimationTrack("Character", previousAnimation)

					if animationTrack then
						animationTrack:Stop()
					end
				end
			end

			local previousAnimation = v2[character].PreviousAnimation
			local animationTrack = v2[character]:GetAnimationTrack("Arm", previousAnimation)

			if animationTrack then
				animationTrack:Stop()
			end

			v2[character].PreviousAnimation = "Buzzcut Retract"

			for _, animation in pairs(v5) do
				local animationData = GetAnimationData(animation, "Buzzcut Retract")
				local track = v2[character]:LoadAnimation(animation, "Buzzcut Retract")

				if track then
					track:Play(nil, nil, animationData[2] / v8)
				end
			end

			if flag then
				v2[character].BG:Set(v2[character].CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
			end

			Util.Sound:Play("Dough.DoughArmRetract", character.PrimaryPart.Position, 0.5, 0.314 / (1 * v8))
			local lastTime = tick()

			while true do
				local v9 = math.min(1, (tick() - lastTime) / (v8 - 0.03333333333333333))
				local circ = Util.Tween.ease["in"].circ(v9, 1, -1, 1)

				if not (character:IsDescendantOf(workspace) and v2[character] and v2[character].ArmObject and v2[character].ArmObject.Model:IsDescendantOf(workspace)) then
					break
				end

				ScaleModel(v2[character].ArmObject, circ)

				if v9 == 1 then
					break
				else
					task.wait(0.016666666666666666)
				end
			end

			if not v2[character] then
				return
			end

			for _, v9 in pairs(v5) do
				local animationTrack2 = v2[character]:GetAnimationTrack(v9, "Buzzcut Retract")

				if animationTrack2 then
					animationTrack2:Stop()
				end
			end

			v2[character].Arm:Destroy()

			if hasRights then
				if flag then
					v2[character].BG:Set(v2[character].CFrame)
				end

				v2[character].BG:Destroy()
				v2[character].BP:Destroy()
			end

			v2[character] = nil
		end
	end
end