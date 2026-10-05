local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local abaiasSpite = ReplicatedStorage.shared.modules.LocalPassive.AbaiasSpite
local fishing = ReplicatedStorage.resources.replicated.fishing
local fishing2 = ReplicatedStorage.resources.sounds.sfx.fishing
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local AbaiasSpite = {}

local function rotationBetween(unit: Vector3, vector2: Vector3)
	local v = math.clamp(unit:Dot(vector2), -1, 1)
	local cross = unit:Cross(vector2)

	if cross.Magnitude < 0.0001 then
		if v > 0 then
			return CFrame.identity
		end

		return (CFrame.fromAxisAngle(createVector(1, 0, 0), 3.141592653589793))
	else
		return CFrame.fromAxisAngle(cross.Unit, (math.acos(v)))
	end
end

local function mouthInfo(abaia)
	local mouth = abaia.PrimaryPart and abaia.PrimaryPart:FindFirstChild("mouth")

	if mouth and mouth:IsA("Attachment") and not (mouth.Position.Magnitude < 0.001) then
		return mouth.Position.Magnitude, rotationBetween(mouth.Position.Unit, createVector(-0, -0, -1))
	end

	return 0, CFrame.identity
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bitePose(p: number, cframe: CFrame, vector2: Vector3, vector3: Vector3)
	local v = vector3 * 0.9063077870366499 + createVector(0, 0.42261827, 0)
	local v2 = vector2 - v * p
	return CFrame.lookAt(v2, v2 + v) * cframe
end

-- equivalent calls inferred from this helper; original call sites unknown
local function circlePose(cframe: CFrame, vector2: Vector3, p: number)
	local v = Vector3.new(math.cos(p), 0, (math.sin(p))) * 20
	local vector3 = Vector3.new(-math.sin(p), 0, (math.cos(p)))
	local v2 = vector2 + v - createVector(0, 5, 0)
	return CFrame.lookAt(v2, v2 + vector3) * cframe
end

local function flatDirection(vector2: Vector3, vector3: Vector3?)
	if vector3 then
		local vector4 = Vector3.new(vector3.X - vector2.X, 0, vector3.Z - vector2.Z)

		if vector4.Magnitude > 1 then
			return vector4.Unit
		end
	end

	return createVector(1, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function splash(position: Vector3, p: number, p2)
	local clone = fishing.splash:Clone()
	clone.Position = position
	clone.Parent = workspace.active.debrisfx
	clone.particles:Emit(p)
	SaneDebris:AddItem(clone, 3)

	if p2 then
		fx:PlaySound(p2, clone, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
end

local function loadTracks(clone)
	local tracksByName = {}
	local animations = abaiasSpite:FindFirstChild("animations")
	local animationController = clone:FindFirstChildWhichIsA("AnimationController", true)
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if not (animations and animator) then
		return tracksByName
	end

	for _, animation in animations:GetChildren() do
		if animation:IsA("Animation") then
			tracksByName[animation.Name] = animator:LoadAnimation(animation)
		end
	end

	if tracksByName.Chomp then
		tracksByName.Chomp.Looped = false
	end

	return tracksByName
end

local function playTrack(object, value: number?)
	if object then
		object:Play(0.1, 1, value or 1)
	end
end

local function stopTrack(object)
	if object then
		object:Stop(0.1)
	end
end

local function spawnModel(object, cframe: CFrame)
	local abaia = abaiasSpite:FindFirstChild("Abaia")

	if not (abaia and abaia:IsA("Model") and abaia.PrimaryPart) then
		return nil, {}
	end

	local clone = abaia:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	clone:PivotTo(cframe)
	clone.Parent = workspace.active.debrisfx
	object:Add(clone)
	return clone, (loadTracks(clone))
end

local function surface(instance, data, duration: number)
	local swimming = data.Swimming

	if swimming then
		swimming:Stop(0.1)
	end

	local idle = data.Idle

	if idle then
		idle:Play(0.1, 1, 1)
	end

	local chomp = data.Chomp

	if chomp then
		local v = duration + 0.35
		local v2 = not (chomp.Length > 0) and 1 or math.max(1, chomp.Length / v)

		if chomp then
			chomp:Play(0.1, 1, v2 or 1)
		end
	end

	local chomp2 = abaiasSpite:FindFirstChild("chomp")

	if chomp2 then
		fx:PlaySound(chomp2, instance.PrimaryPart, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function submerge(p)
	local idle = p.Idle

	if idle then
		idle:Stop(0.1)
	end

	local swimming = p.Swimming

	if swimming then
		swimming:Play(0.1, 1, 1)
	end
end

function AbaiasSpite.Surface(p, vector2: Vector3, duration: number, vector3: Vector3?)
	local abaia = abaiasSpite:FindFirstChild("Abaia")

	if not (abaia and abaia:IsA("Model") and abaia.PrimaryPart) then
		return nil
	end

	local v, v2 = mouthInfo(abaia)
	local currentCamera = workspace.CurrentCamera
	local v3 = vector3 or currentCamera and currentCamera.CFrame.Position
	local v4

	if v3 then
		local vector4 = Vector3.new(v3.X - vector2.X, 0, v3.Z - vector2.Z)
		v4 = not (vector4.Magnitude > 1) and createVector(1, 0, 0) or vector4.Unit
	else
		v4 = createVector(1, 0, 0)
	end

	local v6 = bitePose(v, v2, vector2 + createVector(0, 2, 0), v4) -- equivalent call inferred; original call site unknown
	local v7 = v6 - createVector(0, 12, 0)
	local v8, v9 = spawnModel(p, v7)

	if not v8 then
		return nil
	end

	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = v7
	cFrameValue.Changed:Connect(function(cframe)
		if v8.Parent then
			v8:PivotTo(cframe)
		end
	end)
	task.spawn(function()
		local swimming = v9.Swimming

		if swimming then
			swimming:Play(0.1, 1, 1)
		end

		splash(vector2, 18, fishing2.splash1)
		playTween(cFrameValue, tweenInfo, {
			Value = v6
		}) -- equivalent call inferred; original call site unknown

		if not v8.Parent then
			return
		end

		surface(v8, v9, duration)

		if vector3 then
			local vector4 = Vector3.new(vector3.X - vector2.X, 0, vector3.Z - vector2.Z)

			if vector4.Magnitude > 1 then
				local v10 = math.min(vector4.Magnitude * 0.5, 5)
				playTween(cFrameValue, tweenInfo3, {
					Value = v6 + v4 * v10
				}) -- equivalent call inferred; original call site unknown
				splash(vector2 + v4 * v10, 30, fishing2.bigsplash)
			end
		end

		task.wait(duration)

		if not v8.Parent then
			return
		end

		submerge(v9) -- equivalent call inferred; original call site unknown
		playTween(cFrameValue, tweenInfo2, {
			Value = v7
		}) -- equivalent call inferred; original call site unknown
		splash(vector2, 12) -- equivalent call inferred; original call site unknown
		cFrameValue:Destroy()
		v8:Destroy()
	end)
	return v8
end

function AbaiasSpite.Swim(maid, callback)
	local abaia = abaiasSpite:FindFirstChild("Abaia")
	local v = callback()

	if not (abaia and abaia:IsA("Model") and v) then
		return nil
	end

	local v2, v3 = mouthInfo(abaia)
	local v4 = math.random() * 3.141592653589793 * 2
	local v8, v9 = spawnModel(maid, circlePose(v3, v, v4))

	if not v8 then
		return nil
	end

	local numberValue = Instance.new("NumberValue")
	maid:Add(numberValue)
	local pivot = v8:GetPivot()
	local v10 = false
	maid:Add(RunService.Heartbeat:Connect(function(dt)
		v = callback() or v

		if not v10 then
			v4 += dt * 14 / 20
		end

		local v14 = circlePose(v3, v, v4) -- equivalent call inferred; original call site unknown

		if numberValue.Value > 0 then
			v14 = v14:Lerp(pivot, numberValue.Value)
		end

		v8:PivotTo(v14)
	end))
	local swimming = v9.Swimming

	if swimming then
		swimming:Play(0.1, 1, 1)
	end

	return {
		Bite = function(_, duration: number)
			if v10 or not v8.Parent then
				return
			end

			v10 = true
			maid:Add(task.spawn(function()
				local position2 = v
				local position = (circlePose(v3, position2, v4)).Position
				local v16 = position2 + createVector(0, 2, 0)
				local v17

				if position2 then
					local vector2 = Vector3.new(position2.X - position.X, 0, position2.Z - position.Z)
					v17 = not (vector2.Magnitude > 1) and createVector(1, 0, 0) or vector2.Unit
				else
					v17 = createVector(1, 0, 0)
				end

				pivot = bitePose(v2, v3, v16, v17)
				splash(position2, 18, fishing2.splash1)
				playTween(numberValue, tweenInfo, {
					Value = 1
				}) -- equivalent call inferred; original call site unknown

				if not v8.Parent then
					return
				end

				surface(v8, v9, duration)
				task.wait(duration)

				if not v8.Parent then
					return
				end

				submerge(v9) -- equivalent call inferred; original call site unknown
				playTween(numberValue, tweenInfo2, {
					Value = 0
				}) -- equivalent call inferred; original call site unknown
				splash(position2, 12) -- equivalent call inferred; original call site unknown
				v10 = false
			end))
		end
	}
end

function AbaiasSpite.Collect(p, _, _: string, _: number, vector2: Vector3?)
	if typeof(vector2) ~= "Vector3" then
		return
	end

	AbaiasSpite.Surface(p, vector2, 0.5)
end

function AbaiasSpite.Deliver(p, _, _: string, _: number, vector2: Vector3?, vector3: Vector3?)
	if typeof(vector2) ~= "Vector3" then
		return
	end

	local surface2 = AbaiasSpite.Surface

	if typeof(vector3) ~= "Vector3" then
		vector3 = nil
	end

	surface2(p, vector2, 0.7, vector3)
end

return AbaiasSpite