local createVector = vector.create
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local function isModel(model)
	return model and model:IsA("Model")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCFrameFlexible(model, cFrame: CFrame)
	if model and model:IsA("Model") then
		model:PivotTo(cFrame)
	else
		model.CFrame = cFrame
	end
end

local function createSparkPart(data)
	local template = nil

	if typeof(data.Template) == "Instance" and data.Template:IsA("BasePart") then
		template = data.Template
	elseif typeof(data.TemplateName) == "string" then
		template = script:FindFirstChild(data.TemplateName)
	end

	if not template then
		for _, part in ipairs(script:GetChildren()) do
			if not (part:IsA("BasePart") and part:FindFirstChildWhichIsA("Trail", true)) then
				continue
			end

			template = part
			break
		end
	end

	assert(template, "SparkModule: No spark template found (MeshPart with Trail missing).")
	local clone = template:Clone()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanProps(part)
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.CastShadow = false
		end
	end

	cleanProps(clone) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(clone:GetDescendants()) do
		cleanProps(descendant) -- equivalent call inferred; original call site unknown
	end

	return clone
end

local function reflect(vector2, p, p2)
	local dot = vector2:Dot(p)
	return vector2 - (1 + p2) * dot * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function simulateSpark(state)
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		state.age += dt

		if not (state.p and state.p.Parent) then
			heartbeatConnection:Disconnect()
		elseif state.age >= state.life then
			heartbeatConnection:Disconnect()
			Debris:AddItem(state.p, state.fade or 0.1)
		else
			state.vel += Vector3.new(0, -state.gravity, 0) * dt
			state.vel *= math.max(0, 1 - state.drag * dt)
			local pos = state.pos + state.vel * dt
			local v5 = pos - state.pos
			local raycastResult

			if v5.Magnitude > 0 then
				raycastResult = workspace:Raycast(state.pos, v5, state.rayParams)
			end

			if raycastResult then
				local normal = raycastResult.Normal
				state.pos = raycastResult.Position + normal * 0.02
				local v6 = state
				local vel = state.vel
				local bounciness = state.bounciness
				local dot = vel:Dot(normal)
				v6.vel = vel - (1 + bounciness) * dot * normal
				local dot2 = state.vel:Dot(normal)
				local v7 = state.vel - normal * dot2
				state.vel = normal * dot2 + v7 * (1 - state.friction)
				state.bounces += 1

				if state.bounces >= state.maxBounces then
					heartbeatConnection:Disconnect()
					Debris:AddItem(state.p, state.fade or 0.1)
					return
				end
			else
				state.pos = pos
			end

			if state.vel.Magnitude < state.minSpeed then
				heartbeatConnection:Disconnect()
				Debris:AddItem(state.p, state.fade or 0.1)
			else
				local unit = state.vel.Magnitude > 0 and state.vel.Unit or createVector(0, 1, 0)
				setCFrameFlexible(state.p, CFrame.new(state.pos, state.pos + unit)) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

local function emitOne(data, origin, direction, parent, raycastParams)
	if typeof(direction) == "string" then
		local lower = direction:lower()
		direction = lower == "up" and createVector(0, 1, 0) or lower == "down" and createVector(0, -1, 0) or lower == "left" and createVector(
			-1,
			0,
			0
		) or lower == "right" and createVector(1, 0, 0) or lower == "front" and createVector(0, 0, -1) or lower == "back" and createVector(
			0,
			0,
			1
		) or lower ~= "all" and createVector(0, 1, 0) or Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		).Unit
	end

	local v = math.random() * ((data.SpeedMax or 55) - (data.SpeedMin or 35)) + (data.SpeedMin or 35)
	local spreadAngle = math.rad(data.SpreadAngle or 25)
	local cframe = CFrame.fromEulerAnglesXYZ(
		(math.random() - 0.5) * spreadAngle,
		(math.random() - 0.5) * spreadAngle,
		(math.random() - 0.5) * spreadAngle
	)
	local lookVector = (CFrame.lookAt(createVector(0, 0, 0), direction) * cframe).LookVector
	local sparkPart = createSparkPart(data)
	setCFrameFlexible(sparkPart, origin) -- equivalent call inferred; original call site unknown
	sparkPart.Parent = parent
	simulateSpark({
		p = sparkPart,
		pos = origin.Position,
		vel = lookVector * v,
		age = 0,
		life = data.Lifetime or 0.6,
		gravity = data.Gravity or workspace.Gravity,
		drag = data.Drag or 1.5,
		bounciness = data.Bounciness or 0.45,
		friction = data.Friction or 0.2,
		minSpeed = data.MinSpeed or 1.5,
		maxBounces = data.MaxBounces or 5,
		bounces = 0,
		fade = data.FadeTime or 0.1,
		rayParams = raycastParams
	}) -- equivalent call inferred; original call site unknown
end

return {
	Emit = function(data)
		local origin = data.Origin or CFrame.new()
		local direction = data.Direction or createVector(0, 1, 0)
		local parent = data.Parent or workspace
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = data.RaycastIgnore or {}

		if data.Duration and data.Duration > 0 then
			local _ = data.Rate or 50
			local v = os.clock() + data.Duration

			while os.clock() < v do
				emitOne(data, origin, direction, parent, raycastParams)
				RunService.Heartbeat:Wait()
			end
		else
			for _ = 1, data.Amount or 30 do
				emitOne(data, origin, direction, parent, raycastParams)
			end
		end
	end
}