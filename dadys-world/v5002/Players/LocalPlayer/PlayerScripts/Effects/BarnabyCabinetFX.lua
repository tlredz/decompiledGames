local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local color = Color3.fromRGB(120, 255, 150)
local color2 = Color3.fromRGB(70, 200, 90)
local color3 = Color3.fromRGB(255, 60, 60)
local color4 = Color3.fromRGB(255, 45, 45)
local v = {
	scanline = 0.96,
	wash = 1,
	glow = 1
}
local v2 = {
	idle = {
		0.55,
		0.22,
		0.6,
		0.9,
		0.95
	},
	playing = {
		1.1,
		0.7,
		1.5,
		0.86,
		0.93
	}
}

local function basePulse(p)
	return v2[p] or v2.idle
end

-- equivalent calls inferred from this helper; original call sites unknown
local function approach(p: number, p2: number, p3: number, p4: number)
	return p + (p2 - p) * (1 - math.exp(-p3 / p4))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOut(value: number)
	local v3 = math.clamp(value, 0, 1)
	return 1 - (1 - v3) * (1 - v3)
end

local function fxEnabled()
	local info = Workspace:FindFirstChild("Info")
	return not info or info:GetAttribute("BarnabyCabinetFXEnabled") ~= false
end

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
	local v3 = 0
	local v4 = nil

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

		local v5 = part.Size.X * part.Size.Y

		if not (v3 < v5) then
			continue
		end

		v4 = part
		v3 = v5
	end

	return v4
end

local function buildScanlineSequence(bands: number)
	local v3 = math.clamp(bands * 2, 6, 18)
	local numberSequenceKeypoints = {}

	for i = 0, v3 do
		local v4 = i / v3
		local v5 = i % 2 == 0 and 0 or 1
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4, v5))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local v3 = {}
local v4 = false
local total = 0

local function stopFX(state)
	if state.light then
		pcall(function()
			state.light:Destroy()
		end)
		state.light = nil
	end

	if state.overlayFrame then
		pcall(function()
			state.overlayFrame:Destroy()
		end)
		state.overlayFrame = nil
	end

	state.scanFrame = nil
	state.scanGradient = nil
end

local function startFX(state)
	if state.light or state.overlayFrame then
		return
	end

	local displayPart = state.displayPart
	local surfaceGui = state.surfaceGui

	if not (displayPart and displayPart.Parent and surfaceGui and surfaceGui.Parent) then
		return
	end

	local surfaceLight = Instance.new("SurfaceLight")
	surfaceLight.Name = "BarnabyCRTLight"
	surfaceLight.Face = surfaceGui.Face
	surfaceLight.Color = color
	surfaceLight.Brightness = 0.6
	surfaceLight.Range = 9
	surfaceLight.Angle = 90
	surfaceLight.Shadows = false
	surfaceLight.Parent = displayPart
	local frame = Instance.new("Frame")
	frame.Name = "BarnabyCRTOverlay"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color2
	frame.BackgroundTransparency = 0.9
	frame.BorderSizePixel = 0
	frame.ZIndex = 150
	frame.Active = false
	frame.Parent = surfaceGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "Scanlines"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	frame2.BackgroundTransparency = v.scanline
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 151
	frame2.Active = false
	frame2.Parent = frame
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	local v5 = v3[state.gen]
	uIGradient.Transparency = buildScanlineSequence(v5 and v5.bands or 9)
	uIGradient.Parent = frame2
	state.light = surfaceLight
	state.overlayFrame = frame
	state.scanFrame = frame2
	state.scanGradient = uIGradient
end

local function computeTargets(state)
	local state2 = state.state
	local v5, v6, v7, v8, v9 = table.unpack(v2[state2] or v2.idle)
	local v10 = total + state.timeOffset
	local v11 = v5 * state.speedMul
	local v12 = math.sin(v10 * v11 * 6.283185307179586)
	local v13 = math.sin(v10 * v11 * 2.7 * 6.283185307179586 + 1.3)
	local v14 = math.clamp(v12 * 0.4 + 0.5 + v13 * 0.1, 0, 1)
	local v15 = (v6 + (v7 - v6) * v14) * state.brightMul
	local v16 = v9 + (v8 - v9) * v14
	local v17 = 0

	if not state.flashKind and math.sin(v10 * 3) < -0.95 then
		v15 *= 0.7
	end

	if state.flashKind then
		local v18 = total - state.flashStart

		if state.flashKind == "win" and v18 < 1.4 then
			local v19 = easeOut(1 - v18 / 1.4) -- equivalent call inferred; original call site unknown
			v15 += v19 * 3.6
			v16 = math.min(v16, (1 - v19) * 0.48 + 0.45)
		elseif state.flashKind == "lose" and v18 < 1.6 then
			v17 = easeOut(1 - v18 / 1.6)
			local v19 = math.sin(v10 * 9) * 0.2 + 0.8
			v15 = (v17 * 3 + 0.9) * v19
			v16 = math.min(v16, (1 - v17) * 0.45 + 0.5)
		elseif state.flashKind == "alerted" and v18 < 1.3 then
			local v19 = math.floor(v10 * 6) % 2 == 0
			v15 = v19 and 4.5 or 0.7
			v16 = v19 and 0.45 or 0.85
			v17 = 1
		else
			state.flashKind = nil
		end
	end

	return v15 * v.glow, math.clamp(1 - (1 - v16) * v.wash, 0, 1), v17
end

local function refreshMonitors(p)
	local gen = p.gen

	if not (gen and gen.Parent) then
		return false
	end

	local v5 = {}

	for _, child in ipairs(gen:GetChildren()) do
		if not isBarnabyOverlay(child) then
			continue
		end

		v5[child] = true
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

	for k, monitor in pairs(p.monitors) do
		if v5[k] then
			continue
		end

		stopFX(monitor)
		p.monitors[k] = nil
	end

	return next(p.monitors) ~= nil
end

local function track(parent)
	if v3[parent] then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not genHasOverlay(parent) then
		return
	end

	local v5 = {
		gen = parent,
		monitors = {},
		state = parent:GetAttribute("BarnabyScreenState"),
		timeOffset = math.random() * 1000,
		speedMul = 0.85 + math.random() * 0.3,
		brightMul = 0.92 + math.random() * 0.16,
		bands = math.random(6, 9)
	}
	v3[parent] = v5
	refreshMonitors(v5)
	v5.stateConn = parent:GetAttributeChangedSignal("BarnabyScreenState"):Connect(function()
		local barnabyScreenState = parent:GetAttribute("BarnabyScreenState")

		if barnabyScreenState == "win" or barnabyScreenState == "lose" or barnabyScreenState == "alerted" then
			v5.flashKind = barnabyScreenState
			v5.flashStart = total
		end

		v5.state = barnabyScreenState
	end)
end

local function untrack(parent)
	local v5 = v3[parent]

	if not v5 then
		return
	end

	v3[parent] = nil

	if v5.stateConn then
		v5.stateConn:Disconnect()
		v5.stateConn = nil
	end

	for _, monitor in pairs(v5.monitors) do
		stopFX(monitor)
	end
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

local function fn()
	local info = Workspace:FindFirstChild("Info")

	if info and info:GetAttribute("BarnabyCabinetFXEnabled") == false then
		for _, v5 in pairs(v3) do
			for _, monitor in pairs(v5.monitors) do
				stopFX(monitor)
			end
		end
	else
		local monitors = {}

		for _, v5 in pairs(v3) do
			refreshMonitors(v5)

			for _, monitor in pairs(v5.monitors) do
				local distSq = monitorDistSq(monitor) -- equivalent call inferred; original call site unknown
				monitor.distSq = distSq

				if monitor.displayPart and monitor.displayPart.Parent and monitor.surfaceGui and monitor.surfaceGui.Parent and distSq <= 8100 then
					table.insert(monitors, monitor)
				elseif monitor.light or monitor.overlayFrame then
					stopFX(monitor)
				end
			end
		end

		table.sort(monitors, function(a, b)
			return a.distSq < b.distSq
		end)

		if #monitors > 6 and not v4 then
			v4 = true
			warn(string.format(
				"[BarnabyCabinetFX] %d cabinet monitors in range; capping CRT FX at %d (nearest)",
				#monitors,
				6
			))
		elseif #monitors <= 6 then
			v4 = false
		end

		for i, v5 in ipairs(monitors) do
			if i <= 6 then
				startFX(v5)
			elseif v5.light or v5.overlayFrame then
				stopFX(v5)
			end
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	total += dt

	for _, v5 in pairs(v3) do
		local v6, v7, v8 = computeTargets(v5)
		local sBright = v5.sBright or v6
		v5.sBright = approach(sBright, v6, dt, 0.12)
		local sTransp = v5.sTransp or v7
		v5.sTransp = approach(sTransp, v7, dt, 0.14)
		local sRed = v5.sRed or v8
		v5.sRed = approach(sRed, v8, dt, 0.18)
		local lerped = color:Lerp(color3, v5.sRed)
		local lerped2 = color2:Lerp(color4, v5.sRed)
		local bands = v5.bands or 9
		local v9 = (total + v5.timeOffset) * 0.25 * v5.speedMul % 1 / bands

		for _, monitor in pairs(v5.monitors) do
			if monitor.light then
				monitor.light.Color = lerped
				monitor.light.Brightness = v5.sBright
			end

			if monitor.overlayFrame then
				monitor.overlayFrame.BackgroundColor3 = lerped2
				monitor.overlayFrame.BackgroundTransparency = v5.sTransp
			end

			if monitor.scanFrame then
				monitor.scanFrame.BackgroundTransparency = v.scanline
			end

			if monitor.scanGradient then
				monitor.scanGradient.Offset = Vector2.new(0, v9)
			end
		end
	end
end)
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

		local v5 = v3[parent]

		if not v5 then
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
			local monitor = v5.monitors[descendant]

			if monitor then
				stopFX(monitor)
				v5.monitors[descendant] = nil
			end
		else
			untrack(parent)
		end
	end
end)

local function readTuning()
	local info = Workspace:FindFirstChild("Info")

	if not info then
		return
	end

	local barnabyCRTScanline = info:GetAttribute("BarnabyCRTScanline")
	local barnabyCRTWash = info:GetAttribute("BarnabyCRTWash")
	local barnabyCRTGlow = info:GetAttribute("BarnabyCRTGlow")
	v.scanline = type(barnabyCRTScanline) ~= "number" and 0.96 or math.clamp(barnabyCRTScanline, 0, 1) or 0.96
	v.wash = type(barnabyCRTWash) ~= "number" and 1 or math.max(barnabyCRTWash, 0) or 1
	v.glow = type(barnabyCRTGlow) ~= "number" and 1 or math.max(barnabyCRTGlow, 0) or 1
end

local function bindInfoWatchers()
	local info = Workspace:FindFirstChild("Info")

	if not info then
		return false
	end

	info:GetAttributeChangedSignal("BarnabyCabinetFXEnabled"):Connect(fn)

	for _, v5 in ipairs({ "BarnabyCRTScanline", "BarnabyCRTWash", "BarnabyCRTGlow" }) do
		info:GetAttributeChangedSignal(v5):Connect(readTuning)
	end

	readTuning()
	return true
end

task.spawn(function()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if not isBarnabyOverlay(descendant) then
			continue
		end

		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			track(parent)
		end
	end

	if not bindInfoWatchers() then
		Workspace.ChildAdded:Connect(function(child)
			if child.Name == "Info" then
				bindInfoWatchers()
			end
		end)
	end

	fn()

	while true do
		task.wait(1)
		fn()
	end
end)