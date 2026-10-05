local createVector = vector.create
local Isagi = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local _ = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local class = {}
class.__index = class
Random.new()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local _ = game.Workspace.CurrentCamera
local MeshControl = require(ReplicatedStorage.Emotes.VFX.VfxMods.MeshControl)
local thrown = workspace.Thrown
local vfx = script.vfx
local v = {
	Lighting = {
		{
			ClockTime = 14.5
		},
		{
			ClockTime = 4.3
		},
		{
			ClockTime = 4.3
		},
		{
			ClockTime = 14.5
		}
	},
	Atmosphere = {
		{
			Density = 0.27
		},
		{
			Density = 0
		},
		{
			Density = 0
		},
		{
			Density = 0.27
		}
	},
	Baseplate = {
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 1
		},
		{
			Transparency = 1
		},
		{
			Transparency = 0
		}
	},
	["Box|T"] = {
		{
			Transparency = 1
		},
		{
			Transparency = 1
		},
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 1
		},
		{
			Transparency = 1
		},
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 1
		}
	},
	["Box|C"] = {
		{
			Color = Color3.fromRGB(0, 0, 0)
		},
		{
			Color = Color3.fromRGB(0, 0, 0)
		},
		{
			Color = Color3.fromRGB(151, 151, 151)
		},
		{
			Color = Color3.fromRGB(151, 151, 151)
		},
		{
			Color = Color3.fromRGB(0, 0, 0)
		}
	},
	["Box1|T"] = {
		{
			Transparency = 1
		},
		{
			Transparency = 0
		},
		{
			Transparency = 0
		},
		{
			Transparency = 1
		}
	},
	["Box1|C"] = {
		{
			Color = Color3.fromRGB(151, 151, 151)
		},
		{
			Color = Color3.fromRGB(151, 151, 151)
		},
		{
			Color = Color3.fromRGB(0, 0, 0)
		}
	},
	CameraSL = {
		{
			Brightness = 0
		},
		{
			Brightness = 2
		},
		{
			Brightness = 2
		},
		{
			Brightness = 0
		}
	},
	CameraSL0 = {
		{
			Brightness = 0
		},
		{
			Brightness = 25
		},
		{
			Brightness = 25
		},
		{
			Brightness = 0
		}
	},
	CameraSL1 = {
		{
			Brightness = 0
		},
		{
			Brightness = 2
		},
		{
			Brightness = 2
		},
		{
			Brightness = 0
		}
	}
}
local v2 = {
	Lighting = {
		TweenInfo.new(6, Enum.EasingStyle.Linear),
		TweenInfo.new(6.33, Enum.EasingStyle.Linear),
		TweenInfo.new(8.73, Enum.EasingStyle.Linear),
		TweenInfo.new(9.85, Enum.EasingStyle.Linear)
	},
	Atmosphere = {
		TweenInfo.new(0, Enum.EasingStyle.Linear),
		TweenInfo.new(0.483, Enum.EasingStyle.Linear),
		TweenInfo.new(8.86, Enum.EasingStyle.Linear),
		TweenInfo.new(9.73, Enum.EasingStyle.Linear)
	},
	Baseplate = {
		TweenInfo.new(0, Enum.EasingStyle.Linear),
		TweenInfo.new(4.25, Enum.EasingStyle.Linear),
		TweenInfo.new(4.5, Enum.EasingStyle.Linear),
		TweenInfo.new(6.2, Enum.EasingStyle.Linear),
		TweenInfo.new(6.233, Enum.EasingStyle.Linear)
	},
	["Box|T"] = {
		TweenInfo.new(0, Enum.EasingStyle.Linear),
		TweenInfo.new(0.15, Enum.EasingStyle.Linear),
		TweenInfo.new(0.36666666, Enum.EasingStyle.Linear),
		TweenInfo.new(1.8, Enum.EasingStyle.Linear),
		TweenInfo.new(2.33, Enum.EasingStyle.Linear),
		TweenInfo.new(4.416, Enum.EasingStyle.Linear),
		TweenInfo.new(4.55, Enum.EasingStyle.Linear),
		TweenInfo.new(6, Enum.EasingStyle.Linear),
		TweenInfo.new(6.25, Enum.EasingStyle.Linear),
		TweenInfo.new(9.366, Enum.EasingStyle.Linear),
		TweenInfo.new(9.6, Enum.EasingStyle.Linear)
	},
	["Box|C"] = {
		TweenInfo.new(0, Enum.EasingStyle.Linear),
		TweenInfo.new(1.95, Enum.EasingStyle.Linear),
		TweenInfo.new(2.333, Enum.EasingStyle.Linear),
		TweenInfo.new(5.66, Enum.EasingStyle.Linear),
		TweenInfo.new(6.28, Enum.EasingStyle.Linear)
	},
	["Box1|T"] = {
		TweenInfo.new(4.366, Enum.EasingStyle.Linear),
		TweenInfo.new(4.383, Enum.EasingStyle.Linear),
		TweenInfo.new(6.266, Enum.EasingStyle.Linear),
		TweenInfo.new(6.2833, Enum.EasingStyle.Linear)
	},
	["Box1|C"] = {
		TweenInfo.new(4.366, Enum.EasingStyle.Linear),
		TweenInfo.new(5.616, Enum.EasingStyle.Linear),
		TweenInfo.new(5.65, Enum.EasingStyle.Linear)
	},
	CameraSL = {
		TweenInfo.new(6.6, Enum.EasingStyle.Linear),
		TweenInfo.new(6.45, Enum.EasingStyle.Linear),
		TweenInfo.new(9, Enum.EasingStyle.Linear),
		TweenInfo.new(9.866, Enum.EasingStyle.Linear)
	},
	CameraSL0 = {
		TweenInfo.new(1.916, Enum.EasingStyle.Linear),
		TweenInfo.new(2.433, Enum.EasingStyle.Linear),
		TweenInfo.new(4.4, Enum.EasingStyle.Linear),
		TweenInfo.new(4.76, Enum.EasingStyle.Linear)
	},
	CameraSL1 = {
		TweenInfo.new(0.1833, Enum.EasingStyle.Linear),
		TweenInfo.new(0.5666, Enum.EasingStyle.Linear),
		TweenInfo.new(1.683, Enum.EasingStyle.Linear),
		TweenInfo.new(2.383, Enum.EasingStyle.Linear)
	}
}

function CreateWeld(part, p)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = part
	motor6D.Part1 = p
	motor6D.Parent = p
	return motor6D
end

function Isagi.FirstEvent(data)
	local char = data.Char
	local playerFromCharacter = Players:GetPlayerFromCharacter(char)
	local fn
	local cleanupTable = data.CleanupTable
	script:SetAttribute("PreviousClocktime", Lighting.ClockTime)
	local realAnim = data.RealAnim
	local bind = data.Bind
	local v3 = char == game.Players.LocalPlayer.Character
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local CreateTweenLoop

	CreateTweenLoop = function(p, p2, value)
		if not v8[p2] then
			v8[p2] = 1
		end

		local v10 = value or 0
		local v11 = v8[p2]
		local v12 = v[p2] and v[p2][v11]
		local v13 = v2[p2] and v2[p2][v11]

		if v13 and v12 then
			if v4[p2] then
				v4[p2]:Disconnect()
			end

			local time = v13.Time
			local v14 = math.max(0, time - v10)
			local tween = TweenService:Create(
				p,
				TweenInfo.new(v14, v13.EasingStyle, v13.EasingDirection or Enum.EasingDirection.In),
				v12
			)
			tween:Play()
			v4[p2] = tween.Completed:Connect(function()
				v4[p2]:Disconnect()
				v4[p2] = nil
				v8[p2] = v11 + 1

				if v8[p2] > #v[p2] then
					v8[p2] = 1
					v9[p2] = false
				end

				if v9[p2] then
					CreateTweenLoop(p, p2, time)
				end
			end)
		else
			v8[p2] = 1
			v9[p2] = false

			if v4[p2] then
				v4[p2]:Disconnect()
				v4[p2] = nil
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function StartTweenLoop(p, p2)
		if v4[p2] then
			v4[p2]:Disconnect()
			v4[p2] = nil
		end

		v9[p2] = true
		v8[p2] = 1
		CreateTweenLoop(p, p2, 0)
	end

	local flag = false

	local function CleanUp(char2, p)
		if not cleanupTable or cleanupTable and typeof(cleanupTable) == "table" and #cleanupTable == 0 or flag then
			return
		end

		flag = true
		print("actualllyyyyyyyyyyyyyyyyyyyyyyyyy")
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(char2)
		local _ = workspace.CurrentCamera
		local humanoidRootPart = char2:FindFirstChild("HumanoidRootPart")
		local humanoid = char2:FindFirstChildOfClass("Humanoid")
		local animator = humanoid:FindFirstChildOfClass("Animator")
		playerFromCharacter2:FindFirstChildOfClass("PlayerGui")

		for _, connection in v4 do
			connection:Disconnect()
		end

		for _, v10 in v7 do
			v10:Cancel()
			v10:Destroy()
		end

		for _, v10 in v6 do
			task.cancel(v10)
		end

		for _, connection in v5 do
			connection:Disconnect()
		end

		if not p then
			for _, v10 in animator:GetPlayingAnimationTracks() do
				v10:Stop(0)
			end
		end

		if v3 and script:GetAttribute("PreviousClocktime") then
			Lighting.ClockTime = script:GetAttribute("PreviousClocktime")
			script:SetAttribute("PreviousClocktime", nil)
		end

		humanoidRootPart.Anchored = false
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid.AutoRotate = true

		for _, v10 in cleanupTable do
			if v10 and v10.Parent then
				v10:Destroy()
			end
		end

		table.clear(cleanupTable)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function LerpColor3(data2, data3, p)
		return Color3.new(
			data2.R + (data3.R - data2.R) * p,
			data2.G + (data3.G - data2.G) * p,
			data2.B + (data3.B - data2.B) * p
		)
	end

	local function TweenScale(p: number, p2: number, data2, instance)
		local v10 = 0
		local v11 = 0

		local function onStep(p3: number)
			v10 = math.min(v10 + p3, data2.Time)
			v11 = p + TweenService:GetValue(v10 / data2.Time, data2.EasingStyle, data2.EasingDirection) * (p2 - p)

			if v11 <= 0 then
				v11 = 0.00001
			end

			instance:ScaleTo(v11)

			if v10 == data2.Time then
				v5.TweenScaleConnection:Disconnect()
			end
		end

		if v5.TweenScaleConnection then
			v5.TweenScaleConnection:Disconnect()
		end

		v5.TweenScaleConnection = RunService.Heartbeat:Connect(onStep)
	end

	local function TweenBeamColor(p, p2, p3, p4, p5)
		local v10 = p4 / p5
		task.spawn(function()
			for i = 1, p5 do
				local lerpColor3 = LerpColor3(p2, p3, i / p5) -- equivalent call inferred; original call site unknown
				p.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor3),
					ColorSequenceKeypoint.new(1, lerpColor3)
				})
				task.wait(v10)
			end
		end)
	end

	local function TweenBeamColors(folder, color, color2)
		for _, beam in folder:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) })
			local v12 = 2
			local v13 = beam
			local v14 = 0.5
			task.spawn(function()
				for i = 1, v12 do
					local lerpColor3 = LerpColor3(color, color2, i / v12) -- equivalent call inferred; original call site unknown
					v13.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, lerpColor3),
						ColorSequenceKeypoint.new(1, lerpColor3)
					})
					task.wait(v14)
				end
			end)
		end
	end

	local function ToggleVisiblity(folder, p, p2)
		local v10 = p2 == nil and {} or p2
		local transparency = p == false and 1 or 0

		for _, part in folder:GetDescendants() do
			if table.find(v10, part.Name) or not (part:IsA("MeshPart") or part:IsA("BasePart")) then
				continue
			end

			part.Transparency = transparency
		end
	end

	local function ApplySkinColor(folder, color)
		for _, part in folder:GetDescendants() do
			if not ((part:IsA("MeshPart") or part:IsA("BasePart")) and part:GetAttribute("SkinColor")) then
				continue
			end

			part.Color = color
		end
	end

	local function ApplyMeshEffects(folder)
		for _, model in folder:GetDescendants() do
			if model:IsA("Model") then
				MeshControl(model)
			end
		end
	end

	local function EmitEffects(folder)
		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v10 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v10:Emit(v10:GetAttribute("EmitCount"))
			end)
		end
	end

	local function ToggleEffects(folder, enabled)
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Trail")) then
				continue
			end

			descendant.Enabled = enabled
		end
	end

	local v10 = false
	local v11

	if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v10 = true
		v11 = false
	else
		v11 = true
	end

	if not v11 then
		return
	end

	local camRigWithLetterBox = nil
	v5.cleanup = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if not (bind and bind.Parent) then
			v10 = true

			if camRigWithLetterBox then
				camRigWithLetterBox:Destroy()
			end

			if fn then
				fn(0)
			end

			CleanUp(char, false, cleanupTable)
		end
	end)
	v5.lol = realAnim.Stopped:Once(function()
		if fn then
			fn(0)
		end

		CleanUp(char, false, cleanupTable)
	end)
	task.delay(15, function()
		local cleanup = v5.cleanup

		if cleanup then
			cleanup:Disconnect()
		end

		CleanUp(char, false, cleanupTable)
	end)
	local _ = workspace.CurrentCamera
	playerFromCharacter:FindFirstChildOfClass("PlayerGui")

	local function firstEvent()
		local v12

		if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v10 = true
			v12 = false
		else
			v12 = true
		end

		if not v12 then
			return
		end

		if v3 then
			local part = Instance.new("Part")
			table.insert(cleanupTable, part)
			part.Size = createVector(120, 120, 120)
			part.Anchored = true
			part.CanQuery = false
			part.CanTouch = false
			part.CanCollide = false
			part.CFrame = char.PrimaryPart.CFrame
			part.Parent = workspace.Thrown
			part.Transparency = 1
			part.CastShadow = false
			game.Debris:AddItem(part, 5)
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			overlapParams.FilterDescendantsInstances = { workspace.Live }
			local partsInPart = workspace:GetPartsInPart(part, overlapParams)

			fn = function(localTransparencyModifier)
				if char ~= Players.LocalPlayer.Character then
					return
				end

				if localTransparencyModifier == 0 then
					for _, part2 in pairs(partsInPart) do
						if part2:IsA("BasePart") then
							part2.LocalTransparencyModifier = 0
						end
					end
				else
					for _, part2 in pairs(partsInPart) do
						if part2:IsA("BasePart") then
							part2.LocalTransparencyModifier = localTransparencyModifier
						end
					end
				end
			end

			task.spawn(function()
				fn(1)
			end)
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		humanoid:FindFirstChildOfClass("Animator")
		local leftArm = char:FindFirstChild("Left Arm")
		local rightArm = char:FindFirstChild("Right Arm")
		local leftLeg = char:FindFirstChild("Left Leg")
		local rightLeg = char:FindFirstChild("Right Leg")
		local head = char:FindFirstChild("Head")
		local torso = char:FindFirstChild("Torso")
		v5.ChildAdded = char.ChildAdded:Connect(function(child)
			if child.Name == "Freeze" then
				CleanUp(char)
			end
		end)
		humanoidRootPart.Anchored = true
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0

		if v3 then
			local clone = vfx.Box:Clone()
			clone.CFrame = humanoidRootPart.CFrame * (CFrame.new(-0.019, 6.925, -1.499) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			))
			clone.Parent = thrown
			table.insert(cleanupTable, clone)
			local clone2 = vfx.Box1:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * (CFrame.new(-0.272, -35.141, -6.657) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			))
			clone2.Parent = thrown
			table.insert(cleanupTable, clone2)

			if workspace:FindFirstChild("Baseplate") then
				v9.Baseplate = true
				StartTweenLoop(workspace.Baseplate, "Baseplate") -- equivalent call inferred; original call site unknown
			end

			local atmosphere = Instance.new("Atmosphere")
			atmosphere.Parent = Lighting
			atmosphere.Density = 0.27
			atmosphere.Offset = 0
			atmosphere.Color = Color3.new(0, 0, 0)
			atmosphere.Decay = Color3.new(0, 0, 0)
			atmosphere.Glare = 0
			atmosphere.Haze = 0
			table.insert(cleanupTable, atmosphere)
			v9.Atmosphere = true
			StartTweenLoop(atmosphere, "Atmosphere") -- equivalent call inferred; original call site unknown
			v9["Box|T"] = true
			StartTweenLoop(clone, "Box|T") -- equivalent call inferred; original call site unknown
			v9["Box|C"] = true
			StartTweenLoop(clone, "Box|C") -- equivalent call inferred; original call site unknown
			v9["Box1|T"] = true
			StartTweenLoop(clone2, "Box1|T") -- equivalent call inferred; original call site unknown
			v9["Box1|C"] = true
			StartTweenLoop(clone2, "Box1|C") -- equivalent call inferred; original call site unknown
			v9.Lighting = true
			StartTweenLoop(Lighting, "Lighting") -- equivalent call inferred; original call site unknown
		end

		local clone = vfx.Fx:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * (CFrame.new(-6.488, -8.655, 3.847) * CFrame.Angles(
			1.5707963267948966,
			3.141592653589793,
			0
		)))
		clone.Parent = thrown
		table.insert(cleanupTable, clone)
		local clone2 = vfx.Face:Clone()
		clone2.Parent = thrown
		table.insert(cleanupTable, clone2)
		clone2:PivotTo(head.CFrame)
		CreateWeld(clone2.Handle, head, clone2.Handle)
		local clone3 = vfx.Jigsore:Clone()
		clone3.RootPart.Anchored = false
		local motor6D = Instance.new("Motor6D")
		local rootPart = clone3.RootPart
		motor6D.Part0 = humanoidRootPart
		motor6D.Part1 = rootPart
		motor6D.C0 = CFrame.new(0, -3, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		motor6D.Parent = humanoidRootPart
		table.insert(cleanupTable, motor6D)
		clone3.Parent = char
		table.insert(cleanupTable, clone3)
		local animation = Instance.new("Animation")
		animation.Parent = clone3
		animation.AnimationId = script.JigsawPiece.AnimationId
		local track = clone3.AnimationController.Animator:LoadAnimation(animation)
		track:Play()
		track.Looped = false
		track.TimePosition = data.RealAnim.TimePosition
		warn(track.TimePosition)

		for _, child in vfx.TorsoEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = torso
			table.insert(cleanupTable, clone4)
		end

		for _, child in vfx.HeadEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = head
			table.insert(cleanupTable, clone4)
		end

		for _, child in vfx.LeftLegEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = leftLeg
			table.insert(cleanupTable, clone4)
		end

		for _, child in vfx.RightLegEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = rightLeg
			table.insert(cleanupTable, clone4)
		end

		for _, child in vfx.LeftArmEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = leftArm
			table.insert(cleanupTable, clone4)
		end

		for _, child in vfx.RightArmEffects:GetChildren() do
			local clone4 = child:Clone()
			clone4.Parent = rightArm
			table.insert(cleanupTable, clone4)
		end

		v6.EffectEmit1 = task.delay(0.2, function()
			ToggleEffects(clone.JFx0, true)
			ToggleEffects(clone.Bg1Fx, true)
			ToggleEffects(clone.RoomAura0Fx, true)
		end)
		v6.EffectEmit2 = task.delay(1.683333, function()
			ToggleEffects(clone.RoomAuraFx, true)
			ToggleEffects(clone.JFx0, false)
			ToggleEffects(clone.Bg1Fx, false)
			ToggleEffects(clone.RoomAura0Fx, false)
		end)
		v6.EffectEmit3 = task.delay(1.983, function()
			ToggleEffects(clone.JFx1, true)
		end)
		v6.EffectEmit4 = task.delay(4.4166, function()
			EmitEffects(clone.BgFx)
		end)
		v6.EffectEmit5 = task.delay(4.883, function()
			ToggleEffects(clone.JFx1, false)
			ToggleEffects(clone.RoomAuraFx, false)
		end)
		v6.EffectEmit6 = task.delay(5.616, function()
			EmitEffects(clone.DropFx)
		end)
		v6.EffectEmit7 = task.delay(6.283, function()
			EmitEffects(clone.WaterFx)
			ToggleEffects(clone.JFx2, true)
			ToggleEffects(clone.FloorFx, true)
			ToggleEffects(clone.RoomAura1Fx, true)
		end)
		v6.EffectEmit8 = task.delay(9, function()
			ToggleEffects(clone.JFx2, false)
			ToggleEffects(clone.FloorFx, false)
			ToggleEffects(clone.RoomAura1Fx, false)
		end)
		v6.EffectEmit9 = task.delay(9.45, function()
			EmitEffects(clone.FuFx)
		end)
		camRigWithLetterBox = char:FindFirstChild("CamRigWithLetterBox")
		camRigWithLetterBox.Parent = thrown
		table.insert(cleanupTable, camRigWithLetterBox)

		for _, child in pairs(vfx.Folder:GetChildren()) do
			local clone_2 = child:Clone()
			clone_2.Parent = camRigWithLetterBox.camera
		end

		v9.CameraSL = true
		StartTweenLoop(camRigWithLetterBox.camera.SpotLight, "CameraSL") -- equivalent call inferred; original call site unknown
		v9.CameraSL0 = true
		StartTweenLoop(camRigWithLetterBox.camera.SpotLight0, "CameraSL0") -- equivalent call inferred; original call site unknown
		v9.CameraSL1 = true
		StartTweenLoop(camRigWithLetterBox.camera.SpotLight1, "CameraSL1") -- equivalent call inferred; original call site unknown
		v6.BeamColors = task.delay(2.216, function()
			TweenBeamColors(
				camRigWithLetterBox.camera.A,
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(156, 156, 156),
				0.144,
				10
			)
		end)
		v6["BeamColors|A"] = task.delay(4.45, function()
			TweenBeamColors(
				camRigWithLetterBox.camera.A,
				Color3.fromRGB(156, 156, 156),
				Color3.fromRGB(0, 0, 0),
				0.266,
				10
			)
		end)
		v6.DesignatedEmit = task.delay(1.9, function()
			camRigWithLetterBox.camera.Emit.Transi0:Emit(1)
		end)
		v6["DesignatedEmit|A"] = task.delay(6.05, function()
			camRigWithLetterBox.camera.Emit.Transi1:Emit(1)
		end)
		v6.DesignatedEnable = task.delay(5.85, function()
			head.B.Beam1.Enabled = true
			head.B.Beam.Enabled = true
			head.A.Beam1.Enabled = true
			head.A.Beam.Enabled = true
			head["1"].Wave.Enabled = true
			head["1"].Wave1.Enabled = true
			head["1"].Wave2.Enabled = true
			head["2"].Wave.Enabled = true
			head["2"].Wave1.Enabled = true
			head["2"].Wave2.Enabled = true
		end)
		v6["DesignatedEnable|A"] = task.delay(0.15, function()
			for _, emitter in char:GetDescendants() do
				if emitter.Name == "J1" and emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(1.216)

			for _, emitter in char:GetDescendants() do
				if emitter.Name == "J1" and emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		v6["DesignatedEnable|B"] = task.delay(0.2, function()
			for _, emitter in char:GetDescendants() do
				if emitter.Name == "J" and emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(2.2833)

			for _, emitter in char:GetDescendants() do
				if emitter.Name == "J" and emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		v6["DesignatedEnable|C"] = task.delay(0.266, function()
			camRigWithLetterBox.camera.Shard1.Enabled = true
			task.wait(1.75)
			camRigWithLetterBox.camera.Shard1.Enabled = false
		end)
		v6["DesignatedEnable|D"] = task.delay(4.133, function()
			clone3["Curve.002"].Shard2.Enabled = true
			task.wait(0.38333)
			clone3["Curve.002"].Shard2.Enabled = false
		end)
		v6["DesignatedEnable|E"] = task.delay(4.5, function()
			camRigWithLetterBox.camera.Shard2.Enabled = true
			task.wait(1.183)
			camRigWithLetterBox.camera.Shard2.Enabled = false
		end)
	end

	local v12

	if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v10 = true
		v12 = false
	else
		v12 = true
	end

	if not v12 then
		return
	end

	task.spawn(firstEvent)
end

return Isagi