local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local PointInBox = require(ReplicatedStorage.Shared.Utils.PointInBox)
local Player = require(ReplicatedStorage.Shared.Player)
local Signal = require(ReplicatedStorage.Packages.Signal)
local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local v = {
	Changed = Signal.new()
}
local v2 = {}
local v3 = nil
local v4 = false

local function padBox(instance)
	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	if instance:IsA("Model") then
		return ModelBounds(instance)
	end

	return instance:GetPivot(), createVector(0, 0, 0)
end

local function topUnderFoot(p, vector2: Vector3)
	local surface = p.Surface
	local cFrame, size

	if surface:IsA("BasePart") then
		cFrame = surface.CFrame
		size = surface.Size
	elseif surface:IsA("Model") then
		cFrame, size = ModelBounds(surface)
	else
		cFrame = surface:GetPivot()
		size = createVector(0, 0, 0)
	end

	if PointInBox(cFrame * CFrame.new(createVector(0, 6, 0)), size + createVector(0, 12, 0), vector2) then
		return (cFrame * CFrame.new(0, size.Y / 2, 0)).Position.Y
	end

	return nil
end

local function padBeneath(position: Vector3)
	local v5 = -1e999
	local v6 = nil

	for _, v7 in v2 do
		local v8 = topUnderFoot(v7, position)

		if not (v8 ~= nil and v5 < v8) then
			continue
		end

		v6 = v7
		v5 = v8
	end

	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function transition(p)
	local v5 = v3

	if p == v5 then
		return
	end

	v3 = p
	v.Changed:Fire(p, v5)
end

v.Changed:Connect(function(p, p2)
	local entered

	if p ~= nil then
		entered = p.Hooks.Entered
	end

	if entered ~= nil then
		task.spawn(entered)
	end

	local left

	if p2 ~= nil then
		left = p2.Hooks.Left
	end

	if left ~= nil then
		task.spawn(left)
	end
end)

local function poll()
	while #v2 > 0 do
		local rootPart = Player.FindRootPart()
		local v5

		if rootPart ~= nil then
			v5 = padBeneath(rootPart.Position)
		end

		transition(v5) -- equivalent call inferred; original call site unknown
		task.wait(0.15)
	end

	local v5 = v3

	if v5 ~= nil then
		v3 = nil
		v.Changed:Fire(nil, v5)
	end

	v4 = false
end

local function startBob(padMarker)
	local pivot = padMarker:GetPivot()
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "PadMarkerLift"
	numberValue.Value = -0.4
	local changedConnection = numberValue.Changed:Connect(function(p: number)
		padMarker:PivotTo(pivot + Vector3.new(0, p, 0))
	end)
	numberValue.Parent = padMarker
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = 0.4
	})

	if not GameFlags.WorldOverlaysHidden:Get() then
		tween:Play()
	end

	return {
		Height = numberValue,
		Motion = tween,
		Follow = changedConnection
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopBob(bob)
	bob.Motion:Cancel()
	bob.Follow:Disconnect()
	bob.Height:Destroy()
end

GameFlags.WorldOverlaysHidden.Changed:Connect(function(flag: boolean)
	for _, v5 in v2 do
		local bob = v5.Bob

		if bob == nil then
			continue
		end

		if flag then
			bob.Motion:Pause()
		else
			bob.Motion:Play()
		end
	end
end)

function v.Track(pVInstance, options)
	local v5

	if typeof(pVInstance) == "Instance" then
		v5 = pVInstance:IsA("PVInstance")
	else
		v5 = false
	end

	assert(v5, "Pads.Track needs a PVInstance surface")
	local v6 = nil

	local function untrack()
		local index = table.find(v2, v6)

		if index == nil then
			return
		end

		table.remove(v2, index)
		v6.Gone:Disconnect()
		local bob = v6.Bob

		if bob ~= nil then
			stopBob(bob) -- equivalent call inferred; original call site unknown
		end

		if v3 == v6 then
			v3 = nil
		end
	end

	local parent = pVInstance.Parent
	local padMarker

	if parent ~= nil then
		padMarker = parent:FindFirstChild("PadMarker")
	end

	local v7 = {
		Surface = pVInstance,
		Hooks = options or {},
		Bob = 0,
		Gone = 0
	}
	local bob2

	if not (padMarker == nil or not padMarker:IsA("PVInstance")) then
		bob2 = startBob(padMarker)
	end

	v7.Bob = bob2
	v7.Gone = pVInstance.Destroying:Once(untrack)
	v6 = v7
	table.insert(v2, v6)

	if not v4 then
		v4 = true
		task.spawn(poll)
	end

	return untrack
end

return table.freeze(v)