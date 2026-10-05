local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Net = require(game.ReplicatedStorage.Modules.Net)
local frozen = table.freeze({
	SHAKE_DURATION = 0.5,
	SHAKE_ANGLE = 0.06981317007977318,
	SHAKE_FREQUENCY = 34,
	SHAKE_RENDER_DISTANCE = 500,
	HIT_SHAKE_DURATION_STEP = 0.08,
	HIT_SHAKE_ANGLE_STEP = 0.03490658503988659,
	FINALE_SHAKE_DURATION = 1.7,
	FINALE_SHAKE_ANGLE = 0.24434609527920614,
	FINALE_SHAKE_FREQUENCY = 11,
	ISLAND_NAME = "Jungle",
	TREES_FOLDER = "BananaTrees",
	LEAF_MATCH = "BananaLeaf",
	AMBIENT_MIN_DELAY = 12,
	AMBIENT_MAX_DELAY = 25,
	AMBIENT_DISTANCE = 140,
	LEAF_SHAKE_DURATION = 1.2,
	LEAF_SHAKE_ANGLE = 0.04363323129985824,
	LEAF_SHAKE_FREQUENCY = 12
})
local random = Random.new()
local localPlayer = Players.LocalPlayer
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local object4 = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function localPosition()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position or nil
end

local function shakeTree(instance, p: number?, p2: number?, p3: number?)
	if not instance:IsDescendantOf(Workspace) then
		return
	end

	local v = localPosition() -- equivalent call inferred; original call site unknown

	if v and (instance:GetPivot().Position - v).Magnitude > frozen.SHAKE_RENDER_DISTANCE then
		return
	end

	if not object[instance] then
		object[instance] = instance:GetPivot()
		local boundingBox, v2 = instance:GetBoundingBox()
		object2[instance] = Vector3.new(boundingBox.X, boundingBox.Y - v2.Y / 2, boundingBox.Z)
	end

	local v2 = object[instance]
	local v3 = object2[instance]
	local v4 = (object3[instance] or 0) + 1
	object3[instance] = v4
	local number = random:NextNumber(0, 6.283185307179586)
	local vector = Vector3.new(math.cos(number), 0, (math.sin(number)))
	task.spawn(function()
		local total = 0
		local v5 = p or frozen.SHAKE_DURATION
		local v6 = p2 or frozen.SHAKE_ANGLE
		local SHAKE_FREQUENCY = p3

		if not SHAKE_FREQUENCY then
			SHAKE_FREQUENCY = frozen.SHAKE_FREQUENCY
		end

		while total < v5 do
			local v7 = RunService.Heartbeat:Wait()

			if object3[instance] ~= v4 or not instance:IsDescendantOf(Workspace) then
				return
			end

			total += v7
			local v8 = math.max(0, 1 - total / v5)
			local v9 = math.sin(total * SHAKE_FREQUENCY) * v6 * v8
			instance:PivotTo(CFrame.new(v3) * CFrame.fromAxisAngle(vector, v9) * CFrame.new(-v3) * v2)
		end

		if object3[instance] == v4 and instance:IsDescendantOf(Workspace) then
			instance:PivotTo(v2)
		end
	end)
end

local function getLeafOffsets(folder)
	local v = object4[folder]

	if v then
		return v
	end

	local pivot = folder:GetPivot()
	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and string.find(part.Name, frozen.LEAF_MATCH) ~= nil) then
			continue
		end

		table.insert(result, {
			part = part,
			offset = pivot:ToObjectSpace(part.CFrame)
		})
	end

	object4[folder] = result
	return result
end

local function rustleLeaves(instance)
	if not instance:IsDescendantOf(Workspace) then
		return
	end

	local leafOffsets = getLeafOffsets(instance)

	if #leafOffsets == 0 then
		return
	end

	local v = (object3[instance] or 0) + 1
	object3[instance] = v
	local v2 = object[instance]

	if v2 then
		instance:PivotTo(v2)
	end

	local v3 = {}

	for k in leafOffsets do
		local number = random:NextNumber(0, 6.283185307179586)
		v3[k] = {
			axis = Vector3.new(math.cos(number), 0, (math.sin(number))),
			phase = random:NextNumber(0, 6.283185307179586)
		}
	end

	task.spawn(function()
		local total = 0

		while total < frozen.LEAF_SHAKE_DURATION do
			local v4 = RunService.Heartbeat:Wait()

			if object3[instance] ~= v or not instance:IsDescendantOf(Workspace) then
				break
			end

			total += v4
			local v5 = math.sin(math.min(total / frozen.LEAF_SHAKE_DURATION, 1) * 3.141592653589793)
			local pivot = instance:GetPivot()

			for k, leafOffset in leafOffsets do
				local v6 = v3[k]
				local v7 = math.sin(total * frozen.LEAF_SHAKE_FREQUENCY + v6.phase) * frozen.LEAF_SHAKE_ANGLE * v5
				leafOffset.part.CFrame = pivot * leafOffset.offset * CFrame.fromAxisAngle(v6.axis, v7)
			end
		end

		if instance:IsDescendantOf(Workspace) then
			local pivot = instance:GetPivot()

			for _, leafOffset in leafOffsets do
				leafOffset.part.CFrame = pivot * leafOffset.offset
			end
		end
	end)
end

local function startAmbientShakes()
	local child = Workspace:WaitForChild("Map"):WaitForChild(frozen.ISLAND_NAME, 60)
	local child2 = child and child:WaitForChild(frozen.TREES_FOLDER, 60)

	if not child2 then
		return
	end

	while true do
		task.wait(random:NextNumber(frozen.AMBIENT_MIN_DELAY, frozen.AMBIENT_MAX_DELAY))
		local v = localPosition() -- equivalent call inferred; original call site unknown

		if not v then
			continue
		end

		local models = {}

		for _, model in child2:GetChildren() do
			if not (model:IsA("Model") and (model:GetPivot().Position - v).Magnitude <= frozen.AMBIENT_DISTANCE) then
				continue
			end

			table.insert(models, model)
		end

		if #models > 0 then
			rustleLeaves(models[random:NextInteger(1, #models)])
		end
	end
end

return {
	OnStart = function(_)
		Net:RemoteEvent("BananaTreeFX").OnClientEvent:Connect(function(p, ...)
			if p == "shake" then
				local v, v2 = ...

				if v then
					local v3 = typeof(v2) ~= "number" and 0 or math.max(v2 - 1, 0)
					shakeTree(
						v,
						frozen.SHAKE_DURATION + frozen.HIT_SHAKE_DURATION_STEP * v3,
						frozen.SHAKE_ANGLE + frozen.HIT_SHAKE_ANGLE_STEP * v3
					)
				end
			else
				local v = p == "finale" and ...

				if v then
					shakeTree(v, frozen.FINALE_SHAKE_DURATION, frozen.FINALE_SHAKE_ANGLE, frozen.FINALE_SHAKE_FREQUENCY)
				end
			end
		end)
		task.spawn(startAmbientShakes)
	end
}