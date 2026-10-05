local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	Seconds = 1,
	Style = Enum.EasingStyle.Elastic,
	Direction = Enum.EasingDirection.Out
}
local v2 = {
	Seconds = 0.35,
	Style = Enum.EasingStyle.Quad,
	Direction = Enum.EasingDirection.Out
}
local AreaEggResetWall = {
	CollapseSeconds = v2.Seconds,
	Changed = Signal.new()
}

local function demandFolder(p, p2: string)
	local folder = p[p2]
	assert(folder:IsA("Folder"), (`{p2} under {p.Name} is not a Folder`))
	return folder
end

local function demandPart(p, p2: string)
	local part = p[p2]
	assert(part:IsA("BasePart"), (`{p2} under {p.Name} is not a BasePart`))
	return part
end

local world = Workspace.World
assert(world:IsA("Folder"), (`World under {Workspace.Name} is not a Folder`))
local areas = world.Areas
assert(areas:IsA("Folder"), (`Areas under {world.Name} is not a Folder`))
local wallStartVisual = areas.WallStartVisual
assert(wallStartVisual:IsA("BasePart"), (`WallStartVisual under {areas.Name} is not a BasePart`))
local wallStartCollision = areas.WallStartCollision
assert(wallStartCollision:IsA("BasePart"), (`WallStartCollision under {areas.Name} is not a BasePart`))
local v3 = wallStartVisual.Size * createVector(1, 0, 1)
local Y = wallStartVisual.Size.Y
local v4 = wallStartVisual.CFrame * CFrame.new(createVector(0, 1, 0) * (Y * -0.5))
local v5 = nil
local v6 = false
wallStartVisual.CanCollide = false

-- equivalent calls inferred from this helper; original call sites unknown
local function applyHeight(value: number)
	local v7 = math.clamp(value, 0, Y)
	wallStartVisual.Size = v3 + createVector(0, 1, 0) * v7
	wallStartVisual.CFrame = v4 * CFrame.new(createVector(0, 1, 0) * (v7 * 0.5))
end

local function setBarrierSolid(canCollide: boolean)
	local descendants = wallStartCollision:GetDescendants()
	table.insert(descendants, wallStartCollision)

	for _, part in descendants do
		if part:IsA("BasePart") then
			part.CanCollide = canCollide
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publishSealed(flag: boolean)
	if v6 ~= flag then
		v6 = flag
		AreaEggResetWall.Changed:Fire(v6)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function abortSweep()
	local connection = v5
	v5 = nil

	if connection then
		connection:Disconnect()
	end
end

local function runSweep(data, value: number, value2: number)
	abortSweep() -- equivalent call inferred; original call site unknown
	applyHeight(value) -- equivalent call inferred; original call site unknown
	local v7 = value2 - value
	local v8 = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v8 = math.min(v8 + dt, data.Seconds)
		applyHeight(value + v7 * TweenService:GetValue(v8 / data.Seconds, data.Style, data.Direction)) -- equivalent call inferred; original call site unknown

		if v8 >= data.Seconds then
			preRenderConnection:Disconnect()
		end
	end)
	v5 = preRenderConnection
	task.delay(data.Seconds * 3, function()
		if v5 == preRenderConnection then
			preRenderConnection:Disconnect()
		end
	end)

	while preRenderConnection.Connected do
		task.wait()
	end

	if v5 ~= preRenderConnection then
		return false
	end

	v5 = nil
	applyHeight(value2) -- equivalent call inferred; original call site unknown
	return true
end

function AreaEggResetWall.ArmReveal()
	abortSweep() -- equivalent call inferred; original call site unknown
	applyHeight(0) -- equivalent call inferred; original call site unknown
	setBarrierSolid(true)
	publishSealed(true) -- equivalent call inferred; original call site unknown
end

function AreaEggResetWall.RaiseWall()
	runSweep(v, 0, Y)
end

function AreaEggResetWall.DropWall()
	setBarrierSolid(false)
	publishSealed(false) -- equivalent call inferred; original call site unknown
	runSweep(v2, wallStartVisual.Size.Y, 0)
end

function AreaEggResetWall.ClearWall()
	abortSweep() -- equivalent call inferred; original call site unknown
	applyHeight(0) -- equivalent call inferred; original call site unknown
	setBarrierSolid(false)
	publishSealed(false) -- equivalent call inferred; original call site unknown
end

function AreaEggResetWall.ResolveWallPart()
	return wallStartVisual
end

function AreaEggResetWall.ResolveFullHeight()
	return Y
end

function AreaEggResetWall.IsSealed()
	return v6
end

return AreaEggResetWall