local parent = script.Parent
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local flag = false
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function c(p)
	table.insert(v5, p)
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
require(dependencies.Debug.DebugUi)
require(dependencies.Config)
local Utilities = require(dependencies.Utilities)
local overlayEvent = v3:WaitForChild("OverlayEvent")
local _ = {
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
parent.Name = `{v.Name} - {v6.ID}`
v6:LoadObject(v)
local v7 = false

for _, v8 in v2 do
	v6:LoadRawCollider(v8[1], v8[2])
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
	v7 = true
end)))
c(RunService.Heartbeat:ConnectParallel(function(dt)
	shared.FrameCounter += 1

	if shared.FrameCounter > 131072 then
		shared.FrameCounter = 0
	end

	v6:StepBoneTrees(dt)

	if not (v6.ShouldDestroy or v7) then
		return
	end

	v6:Destroy()
	task.synchronize()
	cleanup() -- equivalent call inferred; original call site unknown
	parent:Destroy()
end)) -- equivalent call inferred; original call site unknown