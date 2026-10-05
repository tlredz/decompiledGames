local parent = script.Parent
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local flag = false
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function c(connection)
	table.insert(v5, connection)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanup()
	for _, connection in v5 do
		connection:Disconnect()
	end
end

local connection = nil
connection = parent:BindToMessage("Setup", function(p, p2, moduleScript)
	v = p
	v2 = p2
	v3 = moduleScript
	local module = require(moduleScript)
	v4 = module
	flag = true
	connection:Disconnect()
end)

repeat
	task.wait()
until flag

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v6 = v4.new()
local dependencies = v3.Dependencies
local DebugUi = require(dependencies.Debug.DebugUi)
local Iris = nil
local Config = require(dependencies.Config)
local Utilities = require(dependencies.Utilities)
local v7 = RunService:IsStudio() or Config.ALLOW_LIVE_GAME_DEBUG
local overlayEvent = v3:WaitForChild("OverlayEvent")
local v8 = false
local v9 = {
	Begin = function(...)
		overlayEvent:Fire("Begin", ...)
	end,
	End = function(...)
		overlayEvent:Fire("End", ...)
	end,
	Text = function(...)
		overlayEvent:Fire("Text", ...)
	end
}
shared.FrameCounter = 0

if v7 then
	Iris = require(dependencies.Iris)

	if not Iris.HasInit() then
		Iris = Iris.Init()
	end
end

parent.Name = `{v.Name} - {v6.ID}`
v6:LoadObject(v)

for _, v10 in v2 do
	v6:LoadRawCollider(v10[1], v10[2])
end

local v10 = v7 and {
	DRAW_BONE = Iris.State(false),
	DRAW_PHYSICAL_BONE = Iris.State(false),
	DRAW_ROOT_PART = Iris.State(false),
	DRAW_BOUNDING_BOX = Iris.State(false),
	DRAW_AXIS_LIMITS = Iris.State(false),
	DRAW_COLLIDERS = Iris.State(false),
	DRAW_COLLIDER_INFLUENCE = Iris.State(false),
	DRAW_COLLIDER_AWAKE = Iris.State(false),
	DRAW_COLLIDER_BROADPHASE = Iris.State(false),
	DRAW_FILL_COLLIDERS = Iris.State(false),
	DRAW_CONTACTS = Iris.State(false),
	DRAW_ROTATION_LIMITS = Iris.State(false),
	DRAW_ACCELERATION_INFO = Iris.State(false)
} or nil

if v7 then
	Iris:Connect(function()
		if v:GetAttribute("Debug") ~= nil then
			DebugUi(Iris, v6, v10)
		end
	end)
end

c(CollectionService:GetInstanceAddedSignal("SmartCollider"):Connect(function(part)
	if not part:IsA("BasePart") then
		return
	end

	local colliderKey = part:GetAttribute("ColliderKey")
	local colliderKey2 = v:GetAttribute("ColliderKey")

	if tostring(colliderKey) ~= tostring(colliderKey2) then
		return
	end

	v6:LoadRawCollider(Utilities.GetCollider(part), part)
end)) -- equivalent call inferred; original call site unknown
table.insert(v5, (parent:BindToMessage("Destroy", function()
	v8 = true
end)))
table.insert(v5, (RunService.Heartbeat:ConnectParallel(function(dt)
	shared.FrameCounter += 1

	if shared.FrameCounter > 131072 then
		shared.FrameCounter = 0
	end

	if not (v and v.Parent) then
		v8 = true
	end

	v6:StepBoneTrees(dt)

	if v6.ShouldDestroy or v8 then
		v6:Destroy()
		task.synchronize()
		cleanup() -- equivalent call inferred; original call site unknown
		parent:Destroy()
	elseif v7 and v:GetAttribute("Debug") ~= nil then
		task.synchronize()
		v6:DrawDebug(
			v10.DRAW_COLLIDERS:get(),
			v10.DRAW_CONTACTS:get(),
			v10.DRAW_PHYSICAL_BONE:get(),
			v10.DRAW_BONE:get(),
			v10.DRAW_AXIS_LIMITS:get(),
			v10.DRAW_ROOT_PART:get(),
			v10.DRAW_FILL_COLLIDERS:get(),
			v10.DRAW_COLLIDER_INFLUENCE:get(),
			v10.DRAW_COLLIDER_AWAKE:get(),
			v10.DRAW_COLLIDER_BROADPHASE:get(),
			v10.DRAW_BOUNDING_BOX:get(),
			v10.DRAW_ROTATION_LIMITS:get(),
			v10.DRAW_ACCELERATION_INFO:get()
		)
		v6:DrawOverlay(v9)
	end
end)))