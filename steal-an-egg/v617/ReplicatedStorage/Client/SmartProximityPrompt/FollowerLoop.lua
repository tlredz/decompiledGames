local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = require(ReplicatedStorage.Shared.Player)
require(script.Parent.SurfaceTracker)
local v = {
	Size = vector.create(1, 1, 1),
	Transparency = 1,
	Anchored = true,
	CanCollide = false,
	CanTouch = false,
	CanQuery = false
}
local FollowerLoop = {}
local localPlayer = Players.LocalPlayer
local v2 = {}
local heartbeatConnection = nil
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPulseIfIdle()
	if next(v2) ~= nil or heartbeatConnection == nil then
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

local function chase(data, position: Vector3, p: number)
	local closestSurfacePoint, v3 = data.tracker:GetClosestSurfacePoint(position, data.standoff, data.range)

	if closestSurfacePoint == nil or v3 == nil or data.range < v3 then
		return
	end

	local v4 = math.clamp(p * data.rate, 0, 1)
	data.anchor.CFrame = CFrame.new(data.anchor.Position:Lerp(closestSurfacePoint, v4))
end

local function dropFollower(p, p2: number?)
	local v3 = v2[p]

	if v3 == nil or p2 ~= nil and v3.id ~= p2 then
		return
	end

	v2[p] = nil

	for _, connection in v3.connections do
		connection:Disconnect()
	end

	table.clear(v3.connections)
	stopPulseIfIdle() -- equivalent call inferred; original call site unknown

	if p.Parent == v3.anchor then
		p.Parent = nil
	end

	v3.tracker:Destroy()
	v3.anchor:Destroy()
end

function FollowerLoop.Drop(p)
	dropFollower(p, nil)
end

local function advance(p: number)
	local primaryPart = Player.FindPrimaryPart(localPlayer)
	local position

	if primaryPart then
		position = primaryPart.Position
	end

	for k, v3 in v2 do
		local v4

		if k.Parent == v3.anchor then
			v4 = v3.anchor.Parent ~= nil
		else
			v4 = false
		end

		if v4 then
			if v3.model:IsDescendantOf(game) and position ~= nil then
				chase(v3, position, p)
			end
		else
			dropFollower(k, v3.id)
		end
	end
end

function FollowerLoop.MakeAnchor(value: string?, cFrame: CFrame)
	local part = Instance.new("Part")

	for k, v3 in v do
		part[k] = v3
	end

	part.Name = value or "SmartPromptPart"
	part.CFrame = cFrame
	part.Parent = workspace
	return part
end

function FollowerLoop:Add(instance2, parent, tracker, data)
	FollowerLoop.Drop(self)
	count += 1
	local id = count
	local v4 = {
		id = id,
		model = instance2,
		anchor = parent,
		tracker = tracker,
		connections = {},
		standoff = data.SurfaceOffset or 0.75,
		rate = data.FollowSpeed or 18,
		range = math.max(data.TrackDistance or 7, self.MaxActivationDistance)
	}
	v2[self] = v4

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dropCurrent()
		dropFollower(self, id)
	end

	v4.connections = {
		self.Destroying:Connect(dropCurrent),
		instance2.Destroying:Connect(dropCurrent),
		self.AncestryChanged:Connect(function()
			if self.Parent ~= parent then
				dropCurrent() -- equivalent call inferred; original call site unknown
			end
		end)
	}

	if parent.Parent == nil then
		dropCurrent() -- equivalent call inferred; original call site unknown
	else
		self.Parent = parent
	end

	if v2[self] == v4 and heartbeatConnection == nil then
		heartbeatConnection = RunService.Heartbeat:Connect(advance)
	end

	local flag = true
	return function()
		if flag then
			flag = false
			dropCurrent() -- equivalent call inferred; original call site unknown
		end
	end
end

return FollowerLoop