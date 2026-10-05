local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local isTenFootInterface = GuiService:IsTenFootInterface()
local currentCamera = workspace.CurrentCamera
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(255, 255, 255)
local success, result = pcall(function()
	if isTenFootInterface then
		error("disabled in console")
	end

	return AssetService:CreateEditableImage({
		Size = Vector2.new(1, 1)
	})
end)

if not success then
	warn("[PhantomSequence] failed to initialize alpha image")
end

local success2, result2 = pcall(function()
	if isTenFootInterface then
		error("disabled in console")
	end

	return AssetService:CreateEditableImage({
		Size = Vector2.new(1, 1)
	})
end)

if not success2 then
	warn("[PhantomSequence] failed to initialize color image")
end

local success3, result3 = pcall(function()
	if isTenFootInterface then
		error("disabled in console")
	end

	return AssetService:CreateSurfaceAppearanceAsync({
		ColorMap = Content.fromObject(result),
		EmissiveMask = Content.fromObject(result2)
	})
end)

if success3 then
	if result3 then
		result3.AlphaMode = Enum.AlphaMode.Transparency
	end
else
	warn("[PhantomSequence] failed to initialize base surface")
end

local function setEyeWave(p: number)
	local v = (1 - p) * 0.9 * 255 // 1
	local v2 = math.lerp(0, 255, p) // 1

	if success2 and result2 then
		local buf = buffer.create(4)
		buffer.writeu8(buf, 0, v2)
		buffer.writeu8(buf, 1, v2)
		buffer.writeu8(buf, 2, v2)
		buffer.writeu8(buf, 3, v2)
		result2:WritePixelsBuffer(Vector2.zero, Vector2.new(1, 1), buf)
	end

	if success and result then
		local buf = buffer.create(4)
		buffer.writeu8(buf, 0, 255 - v)
		buffer.writeu8(buf, 1, 255 - v)
		buffer.writeu8(buf, 2, 255 - v)
		buffer.writeu8(buf, 3, 255 - v)
		result:WritePixelsBuffer(Vector2.zero, Vector2.new(1, 1), buf)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBodyWave(p: number)
	if p < 2 then
		return (1 - math.cos(p / 2 * 3.141592653589793 * 2 * 2)) / 2
	end

	if p < 3.9 then
		return 0
	end

	return (1 - math.cos((p - 2 - 1 - 0.8999999999999999) / 2 * 3.141592653589793 * 2 * 2)) / 2
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getUpdateInterval(magnitude: number, flag: boolean)
	if not flag then
		return 1
	end

	if magnitude < 50 then
		return 0.001
	end

	if magnitude < 140 then
		return 0.03333333333333333
	end

	if magnitude < 220 then
		return 0.2
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBodyWave(data, p: number)
	local instance = data.instance
	instance.Transparency = math.lerp(data.restTransparency, data.activeTransparency, p)

	if not data.noColor then
		instance.Color = data.restColor:Lerp(data.activeColor, p)
	end
end

local v = {}

local function siftUp(p: number)
	while p > 1 do
		local v2 = p // 2

		if not (v[p].nextUpdate < v[v2].nextUpdate) then
			break
		end

		local v3 = v
		local v4 = v
		local v5 = v[v2]
		local v6 = v[p]
		v3[p] = v5
		v4[v2] = v6
		p = v2
	end
end

local function siftDown(p: number)
	local count = #v

	while true do
		local v2 = p * 2
		local v3 = v2 + 1

		if v2 <= count then
			if not (v[v2].nextUpdate < v[p].nextUpdate) then
				v2 = p
			end
		else
			v2 = p
		end

		if v3 <= count and v[v3].nextUpdate < v[v2].nextUpdate then
			v2 = v3
		end

		if v2 == p then
			break
		end

		local v4 = v
		local v5 = v
		local v6 = v[v2]
		local v7 = v[p]
		v4[p] = v6
		v5[v2] = v7
		p = v2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function heapPush(p)
	local v2 = #v + 1
	v[v2] = p
	siftUp(v2)
end

local function heapPop()
	local count = #v
	local v2 = v[1]
	local v3 = v[count]
	v[count] = nil

	if count > 1 then
		v[1] = v3
		siftDown(1)
	end

	return v2
end

local v2 = 0
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	local v3 = workspace:GetServerTimeNow() % 5.9
	local bodyWave = getBodyWave(v3) -- equivalent call inferred; original call site unknown
	local v4 = 0

	if v3 >= 2 and v3 < 3.9 then
		local v5 = v3 - 2 - 1
		v4 = v5 >= 0 and v5 % 0.3 < 0.15 and 1 or v4
	elseif v3 >= 3.9 then
		v4 = bodyWave
	end

	if v4 ~= v2 then
		v2 = v4
		setEyeWave(v4)
	end

	local instant = FFlags:GetInstant("Phantom.DistributeLoad", true)
	local v5 = not instant and 1e999 or FFlags:GetInstant("Phantom.DistributeLoadBudget", 0.00125)
	local v6 = not instant and 1e999 or FFlags:GetInstant("Phantom.MaxUpdatesPerFrame", 200)
	local cFrame = currentCamera.CFrame
	local position = cFrame.Position
	local lookVector = cFrame.LookVector
	local v7 = math.rad(currentCamera.FieldOfView / 2) + 0.20943951023931956
	debug.profilebegin("PhantomSequence:Body")
	local count = 0

	while count < v6 and v5 > 0 do
		local v8 = v[1]

		if not v8 or now < v8.nextUpdate then
			break
		end

		local count2 = #v
		local _ = v[1]
		local v9 = v[count2]
		v[count2] = nil

		if count2 > 1 then
			v[1] = v9
			siftDown(1)
		end

		if v8.removed then
			continue
		end

		local lastTime = os.clock()
		local v10 = position - v8.instance.Position
		local magnitude = v10.Magnitude
		local v11 = math.acos((lookVector:Dot(v10.Unit)))
		local lastWave

		if v8.useEyeWave then
			lastWave = v4
		else
			lastWave = bodyWave
		end

		if lastWave ~= v8.lastWave then
			v8.lastWave = lastWave
			applyBodyWave(v8, lastWave) -- equivalent call inferred; original call site unknown
		end

		v8.nextUpdate = now + getUpdateInterval(magnitude, v7 <= v11)
		heapPush(v8) -- equivalent call inferred; original call site unknown
		v5 -= os.clock() - lastTime
		count += 1
	end

	debug.profileend()
end)
Observers.observeTag("PhantomPart", function(instance)
	local color3 = instance.Color
	local transparency = instance.Transparency
	local surfaceAppearance = instance:FindFirstChildWhichIsA("SurfaceAppearance")
	local v3 = {
		instance = instance,
		restTransparency = math.random(60, 90) / 100,
		restColor = color3:Lerp(color, 0.7),
		activeTransparency = transparency,
		activeColor = color3,
		surface = surfaceAppearance,
		activeStrength = surfaceAppearance and 1000 or 0,
		noColor = instance:GetAttribute("PhantomNoColor") == true,
		useEyeWave = false,
		nextUpdate = 0,
		lastWave = -1,
		removed = false
	}
	heapPush(v3) -- equivalent call inferred; original call site unknown
	return function()
		v3.removed = true
	end
end)
Observers.observeTag("PhantomEyesPart", function(part)
	if part:IsA("MeshPart") and success3 and result3 then
		part.Transparency = 0
		local surfaceAppearance = part:FindFirstChildWhichIsA("SurfaceAppearance")

		if surfaceAppearance then
			surfaceAppearance.Parent = nil
		end

		local clone = result3:Clone()
		clone.Parent = part
		return function()
			clone:Destroy()

			if surfaceAppearance then
				if part.Parent then
					pcall(function()
						surfaceAppearance.Parent = part
					end)
				else
					surfaceAppearance:Destroy()
				end

				surfaceAppearance = nil
			end
		end
	else
		local v3 = {
			instance = part,
			restTransparency = 0.9,
			restColor = color,
			activeTransparency = part:GetAttribute("DefaultTransparency") or 0,
			activeColor = color2,
			surface = nil,
			activeStrength = 0,
			noColor = false,
			useEyeWave = true,
			nextUpdate = 0,
			lastWave = -1,
			removed = false
		}
		heapPush(v3) -- equivalent call inferred; original call site unknown
		return function()
			v3.removed = true
		end
	end
end)