local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ToonViewport = {}
local v = {
	Yatta = 0,
	Flutter = 0
}
local createTowerClone = nil
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheKey(p: string, p2: string)
	return p .. "|" .. ((p2 == "" or not p2) and "Default" or p2)
end

local function getCloneEvent()
	if createTowerClone and createTowerClone.Parent then
		return createTowerClone
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	createTowerClone = events and events:FindFirstChild("CreateTowerClone") or nil
	return createTowerClone
end

local function getWorldModel(parent)
	local v3 = parent:FindFirstChildOfClass("WorldModel")

	if not v3 then
		v3 = Instance.new("WorldModel")
		v3.Name = "WorldModel"
		v3.Parent = parent
	end

	return v3
end

local function getState(viewportFrame)
	local v3 = object[viewportFrame]

	if v3 and v3.camera and v3.camera.Parent == viewportFrame then
		return v3
	end

	local v4 = viewportFrame:FindFirstChildOfClass("Camera")

	if not v4 then
		v4 = Instance.new("Camera")
		v4.Name = "ViewportCamera"
		v4.Parent = viewportFrame
	end

	v4.FieldOfView = 30
	viewportFrame.CurrentCamera = v4
	local v5 = {
		requestId = 0,
		camera = v4,
		yaw = 0,
		basePivot = nil,
		model = nil,
		returnToken = 0,
		key = nil,
		idleTrack = nil
	}
	object[viewportFrame] = v5
	return v5
end

local function poseAndFrame(clone, camera, value: string)
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local hipHeight = humanoid and humanoid.HipHeight or 1.3
	local v3 = clone:GetExtentsSize().Y * 0.5 + hipHeight
	local cframe = CFrame.new(0, v3, 0)
	local v4 = cframe * CFrame.Angles(0, 3.141592653589793, 0)
	clone:PivotTo(v4)
	local v5 = cframe.Position + createVector(0, 1, 0)
	local v6 = v3 * 0.2
	local v7 = 16 + (v[value] or 0)
	camera.CFrame = CFrame.new(v5 + Vector3.new(0, v6, v7), v5)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyYaw(data)
	local model = data.model

	if model and model.Parent and data.basePivot then
		model:PivotTo(data.basePivot * CFrame.Angles(0, data.yaw, 0))
	end
end

local function shortestAngle(p: number)
	local v3 = (p + 3.141592653589793) % 6.283185307179586

	if v3 < 0 then
		v3 += 6.283185307179586
	end

	return v3 - 3.141592653589793
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelReturn(p)
	p.returnToken += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleReturn(state)
	cancelReturn(state) -- equivalent call inferred; original call site unknown
	local returnToken = state.returnToken
	task.spawn(function()
		task.wait(2.5)

		while state.returnToken == returnToken and math.abs(state.yaw) > 0.001 do
			local v3 = RunService.RenderStepped:Wait()
			state.yaw += (0 - state.yaw) * math.min(1, v3 * 4)
			applyYaw(state) -- equivalent call inferred; original call site unknown
		end

		if state.returnToken == returnToken then
			state.yaw = 0
			applyYaw(state) -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleSpin(p, p2: number)
	cancelReturn(p) -- equivalent call inferred; original call site unknown
	local returnToken = p.returnToken
	task.spawn(function()
		local v3 = p2

		while p.returnToken == returnToken and math.abs(v3) > 0.4363323129985824 do
			local v4 = RunService.RenderStepped:Wait()
			p.yaw += v3 * v4
			v3 -= v3 * math.min(1, v4 * 2.5)
			applyYaw(p) -- equivalent call inferred; original call site unknown
		end

		if p.returnToken ~= returnToken then
			return
		end

		local v4 = p
		local v5 = (p.yaw + 3.141592653589793) % 6.283185307179586

		if v5 < 0 then
			v5 += 6.283185307179586
		end

		v4.yaw = v5 - 3.141592653589793
		applyYaw(p) -- equivalent call inferred; original call site unknown
		scheduleReturn(p) -- equivalent call inferred; original call site unknown
	end)
end

local function playIdle(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animations = instance:FindFirstChild("Animations")
	local idle = animations and animations:FindFirstChild("Idle")

	if not (humanoid and idle and idle:IsA("Animation")) then
		return nil
	end

	local v3 = humanoid:FindFirstChildOfClass("Animator")

	if not v3 then
		v3 = Instance.new("Animator")
		v3.Parent = humanoid
	end

	local success, result = pcall(function()
		return v3:LoadAnimation(idle)
	end)

	if success and result then
		result.Looped = true
		result:Play()
		return result
	else
		return nil
	end
end

local function fetchTemplate(value: string, value2: string)
	local v3 = cacheKey(value, value2) -- equivalent call inferred; original call site unknown
	local v4 = v2[v3]

	if v4 and v4.Parent == nil then
		return v4
	end

	if not (createTowerClone and createTowerClone.Parent) then
		local events = ReplicatedStorage:FindFirstChild("Events")
		createTowerClone = events and events:FindFirstChild("CreateTowerClone") or nil
	end

	local v5 = createTowerClone

	if not v5 then
		warn("[ToonViewport] ReplicatedStorage.Events.CreateTowerClone is missing")
		return nil
	end

	local success, result = pcall(function()
		return v5:InvokeServer(value, value2 == "" and "Default" or value2 or "Default")
	end)

	if not success or typeof(result) ~= "Instance" then
		return nil
	end

	local clone = result:Clone()
	Debris:AddItem(result, 0)
	local primaryPart = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso")

	if primaryPart then
		primaryPart.Anchored = true
	end

	v2[v3] = clone
	return clone
end

function ToonViewport.Show(viewportFrame, value: string, value2: string?)
	if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
		return false
	end

	if type(value) ~= "string" or value == "" then
		ToonViewport.Clear(viewportFrame)
		return false
	end

	local state = getState(viewportFrame)
	local v4 = cacheKey(value, value2 or "") -- equivalent call inferred; original call site unknown

	if state.key == v4 and state.model and state.model:IsDescendantOf(viewportFrame) then
		if not (state.idleTrack and state.idleTrack.IsPlaying) then
			state.idleTrack = playIdle(state.model)
		end

		return true
	else
		state.requestId += 1
		local requestId = state.requestId
		state.key = nil
		state.idleTrack = nil
		local v5 = fetchTemplate(value, value2 or "")

		if state.requestId ~= requestId then
			return false
		end

		if not v5 then
			ToonViewport.Clear(viewportFrame)
			return false
		end

		local parent = viewportFrame:FindFirstChildOfClass("WorldModel")

		if not parent then
			parent = Instance.new("WorldModel")
			parent.Name = "WorldModel"
			parent.Parent = viewportFrame
		end

		parent:ClearAllChildren()
		local clone = v5:Clone()
		clone.Parent = parent
		cancelReturn(state) -- equivalent call inferred; original call site unknown
		state.yaw = 0
		state.model = clone
		state.basePivot = poseAndFrame(clone, state.camera, value)
		task.wait()

		if state.requestId ~= requestId or clone.Parent ~= parent then
			return false
		end

		state.idleTrack = playIdle(clone)
		state.key = v4
		return true
	end
end

function ToonViewport.EnableRotation(viewportFrame)
	if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
		return
	end

	local state = getState(viewportFrame)

	if state.proxy and state.proxy.Parent == viewportFrame then
		return
	end

	local v3 = viewportFrame:FindFirstChild("RotateProxy")

	if not v3 then
		v3 = Instance.new("Frame")
		v3.Name = "RotateProxy"
		v3.Size = UDim2.fromScale(1, 1)
		v3.Position = UDim2.fromScale(0, 0)
		v3.BackgroundTransparency = 1
		v3.ZIndex = 10
		v3.Parent = viewportFrame
	end

	state.proxy = v3
	local v4 = v3:FindFirstChildOfClass("UIDragDetector")

	if not v4 then
		v4 = Instance.new("UIDragDetector")
		v4.Parent = v3
	end

	local yaw = 0
	local X = 0
	local total = 0
	local yaw2 = 0
	local now = 0
	local v5 = false
	v4.DragStart:Connect(function()
		cancelReturn(state) -- equivalent call inferred; original call site unknown
		yaw = state.yaw
		X = v3.AbsolutePosition.X
		v5 = false
		total = 0
		yaw2 = state.yaw
		now = os.clock()
	end)
	v4.DragContinue:Connect(function()
		local X2 = viewportFrame.AbsoluteSize.X

		if X2 <= 0 then
			return
		end

		local v6 = (v3.AbsolutePosition.X - X) / X2
		state.yaw = yaw + v6 * 6.283185307179586
		applyYaw(state) -- equivalent call inferred; original call site unknown
		local now2 = os.clock()
		local v8 = now2 - now

		if v8 >= 0.008333333333333333 then
			local v9 = (state.yaw - yaw2) / v8
			total += (v9 - total) * math.min(1, v8 * 18)
			yaw2 = state.yaw
			now = now2
		end
	end)
	v4.DragEnd:Connect(function()
		v3.Position = UDim2.fromScale(0, 0)
		local v6 = not (os.clock() - now <= 0.12) and 0 or math.clamp(total, -25.132741228718345, 25.132741228718345)
		total = 0

		if math.abs(v6) > 0.4363323129985824 then
			scheduleSpin(state, v6) -- equivalent call inferred; original call site unknown
		else
			local v7 = state
			local v8 = (state.yaw + 3.141592653589793) % 6.283185307179586

			if v8 < 0 then
				v8 += 6.283185307179586
			end

			v7.yaw = v8 - 3.141592653589793
			scheduleReturn(state) -- equivalent call inferred; original call site unknown
		end
	end)
end

function ToonViewport.Clear(viewportFrame)
	if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
		return
	end

	local v3 = object[viewportFrame]

	if v3 then
		v3.requestId += 1
		cancelReturn(v3) -- equivalent call inferred; original call site unknown
		v3.model = nil
		v3.basePivot = nil
		v3.yaw = 0
		v3.key = nil
		v3.idleTrack = nil
	end

	local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")

	if worldModel then
		worldModel:ClearAllChildren()
	end
end

function ToonViewport.ClearCache()
	for k, v3 in pairs(v2) do
		v3:Destroy()
		v2[k] = nil
	end
end

return ToonViewport