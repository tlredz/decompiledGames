local RunService = game:GetService("RunService")
local v = false

local function fn() end

local TsunamiEventDebug = {}

local function cylinderVisualizer(color: Color3)
	if not v then
		return fn
	end

	local cylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	cylinderHandleAdornment.Adornee = workspace.Terrain
	cylinderHandleAdornment.Color3 = color
	cylinderHandleAdornment.Transparency = RunService:IsClient() and 0.7 or 0.4
	cylinderHandleAdornment.Parent = workspace.Terrain
	return function(position, radius)
		if position == nil then
			cylinderHandleAdornment:Destroy()
			return
		end

		cylinderHandleAdornment.CFrame = CFrame.new(position) * CFrame.Angles(1.5707963267948966, 0, 0)
		cylinderHandleAdornment.Radius = radius
	end
end

local function tsunamiVisualizer(color: Color3)
	if not v then
		return fn
	end

	local boxHandleAdornment = Instance.new("BoxHandleAdornment")
	boxHandleAdornment.Adornee = workspace.Terrain
	boxHandleAdornment.Color3 = color
	boxHandleAdornment.Transparency = RunService:IsClient() and 0.7 or 0.4
	boxHandleAdornment.Parent = workspace.Terrain
	return function(cFrame, size)
		if cFrame == nil then
			boxHandleAdornment:Destroy()
			return
		end

		boxHandleAdornment.CFrame = cFrame
		boxHandleAdornment.Size = size
	end
end

local v2 = {}

function TsunamiEventDebug.drawHitbox(vector: Vector3)
	if v then
		local v3 = cylinderVisualizer(Color3.fromRGB(55, 255, 0))
		v3(vector, 5)
		table.insert(v2, function()
			v3(nil)
		end)
	end
end

function TsunamiEventDebug.drawTsunami(cframe: CFrame, vector: Vector3)
	if v then
		local v3 = tsunamiVisualizer(Color3.fromRGB(255, 0, 0))
		v3(cframe, vector)
		table.insert(v2, function()
			v3(nil)
		end)
	end
end

function TsunamiEventDebug.drawTsunamiMutationArea(cframe: CFrame, vector: Vector3, duration: number)
	if v then
		local v3 = tsunamiVisualizer(Color3.fromRGB(255, 247, 0))
		v3(cframe, vector)
		task.delay(duration, function()
			v3(nil)
		end)
	end
end

function TsunamiEventDebug.clear()
	for _, v3 in v2 do
		v3()
	end

	table.clear(v2)
end

function TsunamiEventDebug.getEnabled()
	return v
end

function TsunamiEventDebug.setEnabled(enabled)
	v = enabled

	if RunService:IsServer() then
		script:SetAttribute("Enabled", enabled)
	end
end

if RunService:IsClient() then
	script:GetAttributeChangedSignal("Enabled"):Connect(function()
		TsunamiEventDebug.setEnabled(script:GetAttribute("Enabled"))
	end)
end

return TsunamiEventDebug