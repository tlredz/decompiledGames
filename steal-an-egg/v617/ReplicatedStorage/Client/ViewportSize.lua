local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Signal = require(ReplicatedStorage.Packages.Signal)
local frozen = table.freeze({
	Floor = 0.3,
	Ceiling = 2.4
})
local v = {
	Changed = Signal.new()
}

local function scaleFor(point: Vector2)
	return (math.clamp(math.min(point.X, point.Y) / 1100, frozen.Floor, frozen.Ceiling))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapshotOf(point: Vector2)
	return {
		Size = point,
		Scale = math.clamp(math.min(point.X, point.Y) / 1100, frozen.Floor, frozen.Ceiling)
	}
end

local currentCamera = Workspace.CurrentCamera
local viewportSize

if currentCamera then
	viewportSize = currentCamera.ViewportSize
else
	viewportSize = Vector2.one * 1100
end

local v2 = {
	Size = 0,
	Scale = 0
}
v2.Size = viewportSize
v2.Scale = math.clamp(math.min(viewportSize.X, viewportSize.Y) / 1100, frozen.Floor, frozen.Ceiling)
local flag = false
local viewportSizeChangedConnection = nil

local function flush()
	flag = false
	local currentCamera2 = Workspace.CurrentCamera

	if currentCamera2 == nil then
		return
	end

	local viewportSize2 = currentCamera2.ViewportSize

	if viewportSize2 == v2.Size then
		return
	end

	v2 = snapshotOf(viewportSize2)
	v.Changed:Fire(v2.Size, v2.Scale)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queueFlush()
	if flag then
		return
	end

	flag = true
	task.defer(flush)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function follow(currentCamera2)
	if viewportSizeChangedConnection ~= nil then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	if currentCamera2 == nil then
		return
	end

	viewportSizeChangedConnection = currentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(queueFlush)
	queueFlush() -- equivalent call inferred; original call site unknown
end

function v.Get()
	return v2.Size
end

function v.ReadScale()
	return v2.Scale
end

function v.Observe(onChanged)
	local changedConnection = v.Changed:Connect(onChanged)
	onChanged(v2.Size, v2.Scale)
	return function()
		changedConnection:Disconnect()
	end
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	follow(Workspace.CurrentCamera) -- equivalent call inferred; original call site unknown
end)
follow(currentCamera) -- equivalent call inferred; original call site unknown
return table.freeze(v)