local createVector = vector.create
local RunService = game:GetService("RunService")
local SplineAnimator = {}
local SplineMath = require(script.Parent.SplineMath)
local Config = require(script.Parent.Config)
SplineMath:Init(Config)
local v = {}
local heartbeatConnection = nil
local flag = false

local function HideSplineVisuals()
	local splineMaster_Splines = workspace:FindFirstChild("SplineMaster_Splines")

	if not splineMaster_Splines then
		return
	end

	for _, folder in ipairs(splineMaster_Splines:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local controlPoints = folder:FindFirstChild("ControlPoints")

		if controlPoints then
			for _, part in ipairs(controlPoints:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Transparency = 1
				part.CanCollide = false
				local label = part:FindFirstChild("Label")

				if label then
					label.Enabled = false
				end
			end
		end

		local preview = folder:FindFirstChild("Preview")

		if not preview then
			continue
		end

		for _, part in ipairs(preview:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Transparency = 1
			part.CanCollide = false
		end
	end
end

local function GetObjectCFrame(instance)
	if instance:IsA("Model") then
		if instance.PrimaryPart then
			return instance.PrimaryPart.CFrame
		end

		local basePart = instance:FindFirstChildWhichIsA("BasePart", true)

		if basePart then
			return basePart.CFrame
		end
	elseif instance:IsA("BasePart") then
		return instance.CFrame
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetObjectCFrame(object, cFrame)
	if object:IsA("Model") then
		object:PivotTo(cFrame)
	elseif object:IsA("BasePart") then
		object.CFrame = cFrame
	end
end

local function UpdateObjectPosition(data)
	local pointOnSpline, vector2 = SplineMath:GetPointOnSpline(data.spline, data.progress)

	if not (pointOnSpline and vector2) then
		return
	end

	local v2 = pointOnSpline + data.offset
	local cframe

	if data.alignToPath then
		local cross = vector2:Cross(createVector(0, 1, 0))
		local unit = (cross.Magnitude < 0.001 and createVector(1, 0, 0) or cross).Unit
		local unit2 = unit:Cross(vector2).Unit
		cframe = CFrame.fromMatrix(Vector3.new(), unit, unit2, -vector2)
	else
		local object = data.object
		local cFrame

		if object:IsA("Model") then
			if object.PrimaryPart then
				cFrame = object.PrimaryPart.CFrame
			else
				local basePart = object:FindFirstChildWhichIsA("BasePart", true)

				if basePart then
					cFrame = basePart.CFrame
				end
			end
		elseif object:IsA("BasePart") then
			cFrame = object.CFrame
		end

		if cFrame then
			cframe = cFrame - cFrame.Position
		else
			cframe = CFrame.new()
		end
	end

	local rotationOffset = data.rotationOffset or createVector(0, 0, 0)
	local cframe2 = CFrame.Angles(math.rad(rotationOffset.X), math.rad(rotationOffset.Y), (math.rad(rotationOffset.Z)))
	SetObjectCFrame(data.object, CFrame.new(v2) * cframe * cframe2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartUpdateLoop()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		for k, v2 in pairs(v) do
			if k and k.Parent then
				if v2.playing then
					local splineLength = SplineMath:GetSplineLength(v2.spline)

					if not (splineLength <= 0) then
						local v3 = v2.speed * dt / splineLength
						v2.progress += v3 * v2.direction

						if v2.progress >= 1 then
							if v2.loop then
								v2.loopCount += 1

								if v2.pingPong then
									v2.progress = 1
									v2.direction = -1
								else
									v2.progress = 0
								end

								if v2.onLoop then
									task.spawn(v2.onLoop, v2.loopCount)
								end
							else
								v2.progress = 1
								v2.playing = false

								if v2.onComplete then
									task.spawn(v2.onComplete)
								end
							end
						elseif v2.progress <= 0 then
							if v2.loop then
								v2.loopCount += 1

								if v2.pingPong then
									v2.progress = 0
									v2.direction = 1
								else
									v2.progress = 1
								end

								if v2.onLoop then
									task.spawn(v2.onLoop, v2.loopCount)
								end
							else
								v2.progress = 0
								v2.playing = false

								if v2.onComplete then
									task.spawn(v2.onComplete)
								end
							end
						end

						UpdateObjectPosition(v2)

						if v2.onUpdate then
							local pointOnSpline, _ = SplineMath:GetPointOnSpline(v2.spline, v2.progress)
							task.spawn(v2.onUpdate, v2.progress, pointOnSpline)
						end
					end
				end
			else
				v[k] = nil
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopUpdateLoop()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Initialize()
	if flag then
		return
	end

	flag = true
	HideSplineVisuals()
end

function SplineAnimator.Play(_, instance, spline, options)
	Initialize() -- equivalent call inferred; original call site unknown

	if not instance then
		warn("[SplineAnimator] No object provided")
		return false
	end

	local v2 = options or {}

	if SplineMath:GetSplineLength(spline) <= 0 then
		warn("[SplineAnimator] Spline has no length: " .. spline)
		return false
	end

	local cFrame

	if instance:IsA("Model") then
		if instance.PrimaryPart then
			cFrame = instance.PrimaryPart.CFrame
		else
			local basePart = instance:FindFirstChildWhichIsA("BasePart", true)

			if basePart then
				cFrame = basePart.CFrame
			end
		end
	elseif instance:IsA("BasePart") then
		cFrame = instance.CFrame
	end

	local reverse = v2.reverse or Config.DefaultReverse
	local startProgress = v2.startProgress or reverse and 1 or 0
	local v3 = {
		object = instance,
		spline = spline,
		startCFrame = cFrame,
		speed = v2.speed or Config.DefaultSpeed,
		loop = v2.loop ~= nil and v2.loop or Config.DefaultLoop,
		pingPong = v2.pingPong ~= nil and v2.pingPong or Config.DefaultPingPong,
		alignToPath = v2.alignToPath ~= nil and v2.alignToPath or Config.DefaultAlignToPath,
		offset = v2.offset or Config.DefaultOffset,
		rotationOffset = v2.rotationOffset or createVector(0, 0, 0),
		progress = startProgress,
		direction = reverse and -1 or 1,
		reverse = reverse,
		playing = true,
		loopCount = 0,
		tags = v2.tags or {},
		onStart = v2.onStart,
		onComplete = v2.onComplete,
		onLoop = v2.onLoop,
		onUpdate = v2.onUpdate
	}
	v[instance] = v3
	StartUpdateLoop() -- equivalent call inferred; original call site unknown
	UpdateObjectPosition(v3)

	if v3.onStart then
		task.spawn(v3.onStart)
	end

	if Config.ShowDebugPrints then
		print("[SplineAnimator] Started:", instance.Name, "on", spline, reverse and "(reverse)" or "")
	end

	return true
end

function SplineAnimator:Stop(instance)
	local v2 = v[instance]

	if not v2 then
		return false
	end

	v2.playing = false

	if v2.startCFrame then
		local startCFrame = v2.startCFrame

		if instance:IsA("Model") then
			instance:PivotTo(startCFrame)
		elseif instance:IsA("BasePart") then
			instance.CFrame = startCFrame
		end
	end

	v[instance] = nil
	return true
end

function SplineAnimator:Pause(p)
	local v2 = v[p]

	if not v2 then
		return false
	end

	v2.playing = false
	return true
end

function SplineAnimator:Resume(p)
	local v2 = v[p]

	if not v2 then
		return false
	end

	v2.playing = true
	StartUpdateLoop() -- equivalent call inferred; original call site unknown
	return true
end

function SplineAnimator.SetSpeed(_, p, speed)
	local v2 = v[p]

	if not v2 then
		return false
	end

	v2.speed = speed
	return true
end

function SplineAnimator.SetProgress(_, p, value)
	local v2 = v[p]

	if not v2 then
		return false
	end

	v2.progress = math.clamp(value, 0, 1)
	UpdateObjectPosition(v2)
	return true
end

function SplineAnimator.GetProgress(_, p)
	local v2 = v[p]

	if v2 then
		return v2.progress
	end

	return nil
end

function SplineAnimator.IsPlaying(_, p)
	local v2 = v[p]

	if v2 then
		return v2.playing
	end

	return false
end

function SplineAnimator.SetRotationOffset(_, p, rotationOffset)
	local v2 = v[p]

	if not v2 then
		return false
	end

	v2.rotationOffset = rotationOffset
	UpdateObjectPosition(v2)
	return true
end

function SplineAnimator.GetByTag(_, p)
	local result = {}

	for k, animation in pairs(v) do
		if table.find(animation.tags, p) then
			table.insert(result, {
				object = k,
				animation = animation
			})
		end
	end

	return result
end

function SplineAnimator:StopByTag(p)
	local count = 0

	for k, v2 in pairs(v) do
		if not table.find(v2.tags, p) then
			continue
		end

		self:Stop(k)
		count += 1
	end

	return count
end

function SplineAnimator:PauseByTag(p)
	local count = 0

	for k, v2 in pairs(v) do
		if not table.find(v2.tags, p) then
			continue
		end

		self:Pause(k)
		count += 1
	end

	return count
end

function SplineAnimator:ResumeByTag(p)
	local count = 0

	for k, v2 in pairs(v) do
		if not table.find(v2.tags, p) then
			continue
		end

		self:Resume(k)
		count += 1
	end

	return count
end

function SplineAnimator.SetSpeedByTag(_, p, speed)
	local count = 0

	for _, v2 in pairs(v) do
		if not table.find(v2.tags, p) then
			continue
		end

		v2.speed = speed
		count += 1
	end

	return count
end

function SplineAnimator:StopAll()
	local count = 0

	for k, _ in pairs(v) do
		self:Stop(k)
		count += 1
	end

	StopUpdateLoop() -- equivalent call inferred; original call site unknown
	return count
end

function SplineAnimator.PauseAll(_)
	local count = 0

	for _, v2 in pairs(v) do
		v2.playing = false
		count += 1
	end

	return count
end

function SplineAnimator.ResumeAll(_)
	local count = 0

	for _, v2 in pairs(v) do
		v2.playing = true
		count += 1
	end

	StartUpdateLoop() -- equivalent call inferred; original call site unknown
	return count
end

function SplineAnimator.GetAll(_)
	local result = {}

	for k, v2 in pairs(v) do
		result[k] = v2
	end

	return result
end

function SplineAnimator:GetCount()
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	return count
end

function SplineAnimator.Cleanup(_)
	local count = 0

	for k, v2 in pairs(v) do
		if k and k.Parent and v2.playing then
			continue
		end

		v[k] = nil
		count += 1
	end

	if SplineAnimator:GetCount() == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	return count
end

SplineAnimator.Math = SplineMath
SplineAnimator.Config = Config
return SplineAnimator