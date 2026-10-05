local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Areas = require(ReplicatedStorage.Data.Areas)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GuardEscapeRequirement = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardEscapeRequirement)
local Log = require(ReplicatedStorage.Packages.Log)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local t = require(ReplicatedStorage.Packages.t)
local v = Log.new()
local v2 = nil

local function resolveSpeed(model, separationLine)
	local guard = model:FindFirstChild("Guard")
	local humanoidRootPart

	if guard ~= nil then
		humanoidRootPart = guard:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return nil
	end

	local success, result = pcall(
		GuardEscapeRequirement.ResolveSpeedPower,
		model,
		humanoidRootPart.Position,
		separationLine
	)

	if success then
		return result
	end

	v:AtWarning():Log((`Zone ladder could not resolve {model.Name}: {result}`))
	return nil
end

local function computeSpeeds()
	local world = Workspace:WaitForChild("World", 30)
	local areas

	if world ~= nil then
		areas = world:WaitForChild("Areas", 30)
	end

	assert(areas ~= nil, "Workspace.World.Areas is required for the zone ladder")
	local guardAreas = areas:WaitForChild("GuardAreas", 30)
	local separationLine = areas:WaitForChild("SeparationLine", 30)
	assert(guardAreas ~= nil, "Workspace.World.Areas.GuardAreas is required for the zone ladder")
	local v3

	if separationLine == nil then
		v3 = false
	else
		v3 = separationLine:IsA("BasePart")
	end

	assert(v3, "Workspace.World.Areas.SeparationLine must be a BasePart")
	local speedsByChildName = {}

	for childName in Areas.Directory do
		local model

		if Constants.IS_CLIENT then
			model = guardAreas:WaitForChild(childName, 30)
		else
			model = guardAreas:FindFirstChild(childName)
		end

		if model == nil or not model:IsA("Model") then
			v:AtWarning():Log((`Zone ladder skipped {childName}: no guard area model`))
		else
			local speed = resolveSpeed(model, separationLine)

			if speed ~= nil then
				speedsByChildName[childName] = speed
			end
		end
	end

	return speedsByChildName
end

local function speeds()
	local v3 = v2

	if v3 == nil then
		v3 = computeSpeeds()
		v2 = v3
	end

	return v3
end

local RiftZoneLadder = {
	Get = function()
		local v3 = v2

		if v3 == nil then
			v3 = computeSpeeds()
			v2 = v3
		end

		local result = {}
		local v4 = RiftFlags.ZoneLadderOverride:Get()

		if #v4 > 0 then
			for _, id in v4 do
				if Areas.Directory[id] ~= nil then
					table.insert(result, {
						Id = id,
						SpeedPower = v3[id] or 0
					})
				end
			end
		else
			for k, speedPower in v3 do
				table.insert(result, {
					Id = k,
					SpeedPower = speedPower
				})
			end

			table.sort(result, function(a, b)
				if a.SpeedPower == b.SpeedPower then
					return a.Id < b.Id
				end

				return a.SpeedPower < b.SpeedPower
			end)
		end

		return result
	end
}

function RiftZoneLadder.IndexOf(p: string)
	t.strict(t.string)(p)

	for k, v3 in RiftZoneLadder.Get() do
		if v3.Id == p then
			return k
		end
	end

	return nil
end

function RiftZoneLadder.SpeedPowerFor(p: string)
	t.strict(t.string)(p)
	local v3 = v2

	if v3 == nil then
		v3 = computeSpeeds()
		v2 = v3
	end

	return v3[p]
end

function RiftZoneLadder.Invalidate()
	v2 = nil
end

return RiftZoneLadder