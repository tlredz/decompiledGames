local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local success, result = pcall(function()
	local sharedData = ReplicatedStorage:WaitForChild("SharedData", 20)
	local arcadeGames = sharedData and sharedData:WaitForChild("ArcadeGames", 20)
	local swimmyBarnaby = arcadeGames and arcadeGames:WaitForChild("SwimmyBarnaby", 20)
	local frames = swimmyBarnaby and swimmyBarnaby:WaitForChild("Frames", 20)
	return frames and require(frames)
end)

if not (success and result) then
	warn("[BarnabyAttractScreens] Frames toolkit missing; cosmetic attract screens disabled")
	return
end

local cframe = CFrame.new(createVector(0, 0, 60), createVector(0, 0, 0))

-- equivalent calls inferred from this helper; original call sites unknown
local function isBarnabyOverlay(p)
	return p.Name == "SwimmyBarnaby" or string.match(p.Name, "^SwimmyBarnaby_") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function genHasOverlay(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if isBarnabyOverlay(child) then
			return true
		end
	end

	return false
end

local function findOverlayDisplayPart(folder)
	local v2 = 0
	local v3 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = string.lower(part.Name)

		if not string.find(name, "screen", 1, true) then
			continue
		end

		if string.find(name, "border", 1, true) or string.find(name, "small", 1, true) or string.find(
			name,
			"_02",
			1,
			true
		) then
			continue
		end

		local v4 = part.Size.X * part.Size.Y

		if not (v2 < v4) then
			continue
		end

		v3 = part
		v2 = v4
	end

	return v3
end

local function halfExtent(p: number, p2: number)
	return p + math.abs(p2) * 0.2679491924311227
end

local function buildScene(worldModel)
	local v2 = {
		t = 0,
		animators = {},
		seaweed = {},
		nextSeaweed = 0,
		fishHopCooldown = 1.5 + math.random()
	}

	if result.FarBackground and result.FarBackground ~= "" then
		local plane = result.buildPlane(
			Vector3.new(31.076951545867363 * 2, 31.076951545867363 * 2, 0),
			{ result.FarBackground }
		)
		plane.CFrame = CFrame.new(0, 0, -60)
		plane.Parent = worldModel
	end

	if result.Hills and #result.Hills > 0 then
		local hill = result.Hills[math.random(1, #result.Hills)]
		local width = 29.73720558371175 * 4 + 14
		local v4 = (result.HillHeight or 30) + 18
		local v5 = -29.73720558371175 + (result.HillHeight or 30) * 0.5 - 12
		v2.hills = {}

		for i = 0, 1 do
			local plane = result.buildPlane(Vector3.new(width, v4, 0), { hill })
			plane.CFrame = CFrame.new(i * width, v5, -55)
			plane.Parent = worldModel
			table.insert(v2.hills, {
				plane = plane,
				y = v5,
				width = width,
				speed = 5.8500000000000005
			})
		end
	end

	local fishScale = result.FishScale or 4
	local plane = result.buildPlane(Vector3.new(fishScale, fishScale, 0), result.Fish)
	v2.fishX = -13.5
	v2.fishBaseY = 0
	v2.fishY = 0
	v2.fishVel = 0
	plane.CFrame = CFrame.new(v2.fishX, v2.fishY, 0)
	plane.Parent = worldModel
	v2.fishPlane = plane

	if result.Fish and #result.Fish > 1 then
		table.insert(v2.animators, result.newAnimator(plane, result.Fish, result.FishFPS))
	end

	return v2
end

local function spawnSeaweed(state, parent)
	if not (result.Seaweed and #result.Seaweed > 0) or #state.seaweed >= 3 then
		return
	end

	local seaweedWidthScale = result.SeaweedWidthScale or 2
	local seaweedEdgeOvershoot = result.SeaweedEdgeOvershoot or 6
	local width = 3 * seaweedWidthScale
	local v3 = 30 * (0.45 + math.random() * 0.25) + seaweedEdgeOvershoot
	local v4

	if math.random() < 0.5 then
		v4 = 15 + seaweedEdgeOvershoot - v3 * 0.5
	else
		v4 = -15 - seaweedEdgeOvershoot + v3 * 0.5
	end

	local plane = result.buildPlane(Vector3.new(width, v3, 0), result.Seaweed)
	plane.CFrame = CFrame.new(15 + width, v4, 0)
	plane.Parent = parent
	local v5 = {
		plane = plane,
		y = v4,
		width = width
	}

	if result.Seaweed and #result.Seaweed > 1 then
		v5.animator = result.newAnimator(plane, result.Seaweed, result.SeaweedFPS)
		table.insert(state.animators, v5.animator)
	end

	table.insert(state.seaweed, v5)
end

local function tickScene(scene, worldModel, dt: number)
	scene.t += dt

	for _, animator in ipairs(scene.animators) do
		animator:Advance(dt)
	end

	if scene.hills then
		for _, hill in ipairs(scene.hills) do
			local v2 = hill.plane.Position.X - hill.speed * dt

			if v2 <= -hill.width then
				v2 += hill.width * 2
			end

			hill.plane.CFrame = CFrame.new(v2, hill.y, -55)
		end
	end

	if scene.fishPlane then
		scene.fishHopCooldown -= dt

		if scene.fishHopCooldown <= 0 then
			scene.fishHopCooldown = 1.2 + math.random() * 1.8
			scene.fishVel = 16
		end

		scene.fishVel -= dt * 42
		scene.fishY += scene.fishVel * dt
		scene.fishY += (scene.fishBaseY - scene.fishY) * math.min(dt * 1.5, 1)
		scene.fishY = math.clamp(scene.fishY, -12, 12)
		local v2 = math.sin(scene.t * 2.2) * 1.2
		scene.fishPlane.CFrame = CFrame.new(scene.fishX, scene.fishY + v2, 0)
	end

	scene.nextSeaweed -= dt

	if scene.nextSeaweed <= 0 then
		scene.nextSeaweed = 1.4
		spawnSeaweed(scene, worldModel)
	end

	for i = #scene.seaweed, 1, -1 do
		local v2 = scene.seaweed[i]
		local v3 = v2.plane.Position.X - dt * 13

		if v3 < -(15 + v2.width) then
			if v2.animator then
				for i2 = #scene.animators, 1, -1 do
					if scene.animators[i2] ~= v2.animator then
						continue
					end

					table.remove(scene.animators, i2)
					break
				end
			end

			v2.plane:Destroy()
			table.remove(scene.seaweed, i)
		else
			v2.plane.CFrame = CFrame.new(v3, v2.y, 0)
		end
	end
end

local v2 = {}
local v3 = false
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function hasLocalMirror(instance)
	return instance ~= nil and instance:FindFirstChild("BarnabyLiveMirror") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoop(state)
	if state.renderConn then
		state.renderConn:Disconnect()
		state.renderConn = nil
	end

	state.scene = nil
	state.worldModel = nil

	if state.vf then
		pcall(function()
			state.vf:Destroy()
		end)
		state.vf = nil
	end
end

local function startLoop(state)
	if state.vf then
		return
	end

	local surfaceGui = state.surfaceGui

	if not (surfaceGui and surfaceGui.Parent) then
		return
	end

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "BarnabyAttractScreen"
	viewportFrame.AnchorPoint = Vector2.new(0, 0)
	viewportFrame.Position = UDim2.fromScale(0, 0)
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	viewportFrame.BackgroundTransparency = 0
	viewportFrame.BorderSizePixel = 0
	viewportFrame.ZIndex = 5
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local camera = Instance.new("Camera")
	camera.CFrame = cframe
	camera.FieldOfView = 30
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	viewportFrame.Parent = surfaceGui
	state.vf = viewportFrame
	state.worldModel = worldModel
	state.scene = buildScene(worldModel)
	state.renderConn = RunService.Heartbeat:Connect(function(dt)
		if state.vf and state.vf.Parent and state.scene and state.worldModel then
			tickScene(state.scene, state.worldModel, dt)
			return
		end

		stopLoop(state) -- equivalent call inferred; original call site unknown
	end)
end

local function shouldRun(p)
	if not (p.gen and p.gen.Parent and p.gen:GetAttribute("BarnabyScreenState") == "playing") then
		return false
	end

	local surfaceGui = p.surfaceGui
	local v4

	if surfaceGui == nil then
		v4 = false
	else
		v4 = surfaceGui:FindFirstChild("BarnabyLiveMirror") ~= nil
	end

	return not v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function monitorDistSq(monitor)
	local displayPart = monitor.displayPart
	local currentCamera = Workspace.CurrentCamera

	if displayPart and displayPart.Parent and currentCamera then
		return (displayPart.Position - currentCamera.CFrame.Position).Magnitude ^ 2
	end

	return 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropMonitor(p, p2)
	local monitor = p.monitors[p2]

	if not monitor then
		return
	end

	p.monitors[p2] = nil
	stopLoop(monitor) -- equivalent call inferred; original call site unknown
end

local function untrack(p)
	local v4 = v2[p]

	if not v4 then
		return
	end

	v2[p] = nil

	for _, monitor in pairs(v4.monitors) do
		stopLoop(monitor) -- equivalent call inferred; original call site unknown
	end

	v4.monitors = {}

	if v4.attrConn then
		v4.attrConn:Disconnect()
		v4.attrConn = nil
	end
end

local function refreshMonitors(p)
	local gen = p.gen

	if not (gen and gen.Parent) then
		return false
	end

	local v4 = {}

	for _, child in ipairs(gen:GetChildren()) do
		if not isBarnabyOverlay(child) then
			continue
		end

		v4[child] = true
		local monitor = p.monitors[child]

		if not monitor then
			monitor = {
				gen = gen,
				overlay = child,
				distSq = 1e999
			}
			p.monitors[child] = monitor
		end

		if not (monitor.displayPart and monitor.displayPart.Parent) then
			monitor.displayPart = findOverlayDisplayPart(child)
			monitor.surfaceGui = nil
		end

		if monitor.surfaceGui and monitor.surfaceGui.Parent or not monitor.displayPart or not monitor.displayPart.Parent then
			continue
		end

		monitor.surfaceGui = monitor.displayPart:FindFirstChildWhichIsA("SurfaceGui")
	end

	for k in pairs(p.monitors) do
		if v4[k] then
			continue
		end

		dropMonitor(p, k) -- equivalent call inferred; original call site unknown
	end

	return next(p.monitors) ~= nil or next(v4) ~= nil
end

local function track(parent)
	if v2[parent] then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not genHasOverlay(parent) then
		return
	end

	local v4 = {
		gen = parent,
		monitors = {}
	}
	v2[parent] = v4
	refreshMonitors(v4)
	v4.attrConn = parent:GetAttributeChangedSignal("BarnabyScreenState"):Connect(function()
		fn()
	end)
end

local function rescan()
	local v4 = {}

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if not isBarnabyOverlay(descendant) then
			continue
		end

		local parent = descendant.Parent

		if not (parent and parent:IsA("Model")) then
			continue
		end

		v4[parent] = true
		local v5 = v2[parent]

		if v5 then
			refreshMonitors(v5)
		else
			track(parent)
		end
	end

	for k in pairs(v2) do
		if not v4[k] then
			untrack(k)
		end
	end
end

fn = function()
	local monitors = {}

	for _, v4 in pairs(v2) do
		refreshMonitors(v4)

		for _, monitor in pairs(v4.monitors) do
			local distSq = monitorDistSq(monitor) -- equivalent call inferred; original call site unknown
			monitor.distSq = distSq
			local v6

			if monitor.gen and monitor.gen.Parent and monitor.gen:GetAttribute("BarnabyScreenState") == "playing" then
				v6 = not hasLocalMirror(monitor.surfaceGui)
			else
				v6 = false
			end

			if v6 and distSq <= 3600 then
				table.insert(monitors, monitor)
			elseif monitor.vf then
				stopLoop(monitor) -- equivalent call inferred; original call site unknown
			end
		end
	end

	table.sort(monitors, function(a, b)
		return a.distSq < b.distSq
	end)

	if #monitors > 4 and not v3 then
		v3 = true
		warn(string.format(
			"[BarnabyAttractScreens] %d cabinet monitors qualify; capping active attract loops at %d (running nearest)",
			#monitors,
			4
		))
	elseif #monitors <= 4 then
		v3 = false
	end

	for i, v4 in ipairs(monitors) do
		if i <= 4 then
			startLoop(v4)
		elseif v4.vf then
			stopLoop(v4) -- equivalent call inferred; original call site unknown
		end
	end
end

Workspace.DescendantAdded:Connect(function(descendant)
	if isBarnabyOverlay(descendant) then
		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			task.defer(function()
				if parent.Parent then
					track(parent)
					fn()
				end
			end)
		end
	end
end)
Workspace.DescendantRemoving:Connect(function(descendant)
	if isBarnabyOverlay(descendant) then
		local parent = descendant.Parent

		if not parent then
			return
		end

		local v4 = v2[parent]

		if not v4 then
			return
		end

		local flag = false

		for _, child in ipairs(parent:GetChildren()) do
			if not (child ~= descendant and (child.Name == "SwimmyBarnaby" or string.match(
				child.Name,
				"^SwimmyBarnaby_"
			) ~= nil)) then
				continue
			end

			flag = true
			break
		end

		if flag then
			dropMonitor(v4, descendant) -- equivalent call inferred; original call site unknown
		else
			untrack(parent)
		end
	end
end)

local function debugReport()
	local info = Workspace:FindFirstChild("Info")

	if not (info and info:GetAttribute("BarnabyAttractDebug")) then
		return
	end

	local count = 0

	for _ in pairs(v2) do
		count += 1
	end

	print(string.format(
		"[BarnabyAttract] Frames=%s | tracked cabinets=%d | camera=%s",
		result and "loaded" or "MISSING",
		count,
		Workspace.CurrentCamera and "ok" or "nil"
	))

	for _, v4 in pairs(v2) do
		for _, monitor in pairs(v4.monitors) do
			local v6 = not v4.gen and "?" or v4.gen.Name or "?"
			local barnabyScreenState = tostring(v4.gen and v4.gen:GetAttribute("BarnabyScreenState"))
			local v7 = monitor.displayPart and monitor.displayPart.Parent and "ok" or "nil"
			local v8 = monitor.surfaceGui and monitor.surfaceGui.Parent and "ok" or "nil"
			local v9

			if monitor.gen and monitor.gen.Parent and monitor.gen:GetAttribute("BarnabyScreenState") == "playing" then
				v9 = not hasLocalMirror(monitor.surfaceGui)
			else
				v9 = false
			end

			print(string.format(
				"   gen=%s state=%s displayPart=%s surfaceGui=%s shouldRun=%s running=%s dist=%.0f",
				v6,
				barnabyScreenState,
				v7,
				v8,
				tostring(v9),
				monitor.vf and "YES" or "no",
				(math.sqrt(monitor.distSq or 0))
			))
		end
	end
end

task.spawn(function()
	rescan()
	fn()
	debugReport()

	while true do
		task.wait(1)
		fn()
		debugReport()
	end
end)