local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local currentCamera = workspace.CurrentCamera
local v = {}
local v2 = {}
local _ = Players.LocalPlayer

local function getSurfaceNormal(instance)
	local adornee = instance.Adornee or instance.Parent

	if not (adornee and adornee:IsA("BasePart")) then
		return nil
	end

	local face = instance.Face

	if face == Enum.NormalId.Front then
		return adornee.CFrame.LookVector
	end

	if face == Enum.NormalId.Back then
		return -adornee.CFrame.LookVector
	end

	if face == Enum.NormalId.Left then
		return -adornee.CFrame.RightVector
	end

	if face == Enum.NormalId.Right then
		return adornee.CFrame.RightVector
	end

	if face == Enum.NormalId.Top then
		return adornee.CFrame.UpVector
	end

	if face == Enum.NormalId.Bottom then
		return -adornee.CFrame.UpVector
	end
end

local function getFacingScore(instance, position)
	local position2 = currentCamera.CFrame.Position
	local total = 0
	local dot = currentCamera.CFrame.LookVector:Dot((position - position2).Unit)

	if dot > 0 then
		total += dot * 40
	end

	if not instance then
		return total
	end

	if instance:IsA("SurfaceGui") then
		local surfaceNormal = getSurfaceNormal(instance)

		if not surfaceNormal then
			return total
		end

		local dot2 = surfaceNormal:Dot((position2 - position).Unit)

		if dot2 > 0 then
			return total + dot2 * 60
		end

		return total
	else
		if instance:IsA("BillboardGui") then
			total += 60
		end

		return total
	end
end

local function getPosition(instance)
	local surfaceGui = instance:FindFirstAncestorWhichIsA("SurfaceGui") or instance:FindFirstAncestorWhichIsA("BillboardGui")

	if surfaceGui then
		return
			surfaceGui.Adornee and surfaceGui.Adornee:GetPivot().Position or surfaceGui.Parent and surfaceGui.Parent:GetPivot().Position,
			surfaceGui
	end

	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui then
		return currentCamera.CFrame.Position, screenGui
	end

	return nil
end

local function getDistance(p)
	local position, v3 = getPosition(p)

	if not position then
		return 1e999
	end

	local magnitude = (currentCamera.CFrame.Position - position).Magnitude

	if magnitude > 200 then
		return 1e999, position
	end

	return magnitude, position, v3
end

local function getScore(p)
	local position, v3 = getPosition(p)
	local magnitude

	if position then
		magnitude = (currentCamera.CFrame.Position - position).Magnitude

		if magnitude > 200 then
			magnitude = 1e999
			v3 = nil
		end
	else
		magnitude = 1e999
		v3 = nil
		position = nil
	end

	if magnitude > 200 then
		return magnitude
	end

	return magnitude - getFacingScore(v3, position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop(object)
	if object.Playing then
		object:Pause()
	end

	v2[object] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function start(object)
	if not object.Playing then
		object:Play()
	end

	v2[object] = true
end

local function update()
	local v3 = {}

	for k in pairs(v) do
		table.insert(v3, k)
	end

	table.sort(v3, function(a, b)
		local position, v4 = getPosition(a)
		local magnitude

		if position then
			magnitude = (currentCamera.CFrame.Position - position).Magnitude

			if magnitude > 200 then
				magnitude = 1e999
				v4 = nil
			end
		else
			magnitude = 1e999
			v4 = nil
			position = nil
		end

		if not (magnitude > 200) then
			magnitude -= getFacingScore(v4, position)
		end

		local position2, v5 = getPosition(b)
		local magnitude2

		if position2 then
			magnitude2 = (currentCamera.CFrame.Position - position2).Magnitude

			if magnitude2 > 200 then
				magnitude2 = 1e999
				v5 = nil
			end
		else
			magnitude2 = 1e999
			v5 = nil
			position2 = nil
		end

		if not (magnitude2 > 200) then
			magnitude2 -= getFacingScore(v5, position2)
		end

		return magnitude < magnitude2
	end)
	local v4 = {}

	for i = 1, math.min(2, #v3) do
		v4[v3[i]] = true
	end

	for k in pairs(v) do
		if v4[k] then
			continue
		end

		stop(k) -- equivalent call inferred; original call site unknown
	end

	for k in pairs(v) do
		if not v4[k] then
			continue
		end

		start(k) -- equivalent call inferred; original call site unknown
	end
end

local function add(instance)
	print("added ", instance:GetFullName())
	v[instance] = true
end

local function remove(object)
	v[object] = nil
	stop(object) -- equivalent call inferred; original call site unknown
end

local VideoFrameManager = {
	_init = function()
		CollectionService:GetInstanceRemovedSignal("ActiveVideoFrame"):Connect(remove)
		CollectionService:GetInstanceAddedSignal("ActiveVideoFrame"):Connect(add)

		for _, v3 in ipairs(CollectionService:GetTagged("ActiveVideoFrame")) do
			task.spawn(add, v3)
		end

		local v3 = 0
		RunService.Heartbeat:Connect(function()
			local now = tick()

			if now - v3 < 0.1 then
				return
			end

			v3 = now
			update()
		end)
	end
}

if RunService:IsClient() and not script:GetAttribute("init") then
	script:SetAttribute("init", true)
	VideoFrameManager._init()
end

return VideoFrameManager