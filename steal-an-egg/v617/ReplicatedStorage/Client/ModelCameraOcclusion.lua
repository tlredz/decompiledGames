local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local Log = require(ReplicatedStorage.Packages.Log)
local Player = require(ReplicatedStorage.Shared.Player)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local v = Enum.RenderPriority.Camera.Value + 3
local v2 = {
	blocked = {},
	faceOwner = {},
	probeFrom = {},
	probeSkip = {},
	roster = {},
	shelved = {},
	sweep = nil,
	sweeping = false
}
local v3 = Log.new()
local localPlayer = Players.LocalPlayer
local strict = t.strict(t.instanceIsA("Model"))
local strict2 = t.strict(t.number)
local strict3 = t.strict(t.boolean)

-- equivalent calls inferred from this helper; original call sites unknown
local function repaint(instance, target: number?)
	local shelved = v2.shelved

	if target == nil then
		local transparency = shelved[instance]

		if transparency ~= nil then
			shelved[instance] = nil

			if instance.Parent then
				instance.Transparency = transparency
			end
		end
	elseif instance.Transparency < 1 then
		local transparency = instance.Transparency
		local v4 = shelved[instance]

		if v4 == nil and transparency < target then
			shelved[instance] = transparency
			v4 = transparency
		end

		if v4 ~= nil then
			instance.Transparency = math.max(v4, target)
		end
	end
end

local function repaintEntry(state, faded: boolean)
	state.Faded = faded
	local target

	if faded then
		target = state.Target
	end

	for k in state.Faces do
		repaint(k, target) -- equivalent call inferred; original call site unknown
	end
end

local function releaseEverything()
	for _, v4 in v2.roster do
		v4.UnfadeAt = 0
		v4.Faded = false

		for k in v4.Faces do
			local shelved = v2.shelved
			local transparency = shelved[k]

			if transparency == nil then
				continue
			end

			shelved[k] = nil

			if k.Parent then
				k.Transparency = transparency
			end
		end
	end

	table.clear(v2.blocked)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function demand(p)
	return assert(v2.roster[p], (`{p.Name} is not registered for occlusion`))
end

local function isUnderfoot(object, data, position: Vector3)
	local v4 = object:GetScale() / data.RegisteredScale
	local bounds = data.Bounds
	local cframe = data.Pivot.CFrame * (CFrame.new(bounds.Position * v4) * bounds.Rotation)
	local pointToObjectSpace = cframe:PointToObjectSpace(position)
	local v5 = data.Extents * v4 * 0.5
	local v6 = cframe:PointToWorldSpace((Vector3.new(
		math.clamp(pointToObjectSpace.X, -v5.X, v5.X),
		-v5.Y,
		(math.clamp(pointToObjectSpace.Z, -v5.Z, v5.Z))
	))) - position
	return v6.X * v6.X + v6.Z * v6.Z <= 625
end

local function advance(state, flag: boolean, p: number)
	if flag then
		state.UnfadeAt = 0
		return repaintEntry(state, true)
	end

	if not state.Faded then
		state.UnfadeAt = 0
	elseif state.UnfadeAt == 0 then
		state.UnfadeAt = p + 1
	elseif state.UnfadeAt <= p then
		state.UnfadeAt = 0
		state.Faded = false

		for k in state.Faces do
			local shelved = v2.shelved
			local transparency = shelved[k]

			if transparency == nil then
				continue
			end

			shelved[k] = nil

			if k.Parent then
				k.Transparency = transparency
			end
		end
	end
end

local function onFrame()
	local currentCamera = Workspace.CurrentCamera
	local character = Player.FindCharacter(localPlayer)
	local head = Player.FindHead(localPlayer)
	local rootPart = Player.FindRootPart(localPlayer)

	if not (v2.sweeping and currentCamera and character and head and rootPart) then
		return releaseEverything()
	end

	local blocked = v2.blocked
	local faceOwner = v2.faceOwner
	v2.probeFrom[1] = head.Position
	v2.probeSkip[1] = character
	table.clear(blocked)

	for _, v4 in currentCamera:GetPartsObscuringTarget(v2.probeFrom, v2.probeSkip) do
		local v5 = faceOwner[v4]

		if v5 then
			blocked[v5] = true
		end
	end

	local position = rootPart.Position
	local serverTimeNow = Workspace:GetServerTimeNow()

	for k, v4 in v2.roster do
		if v4.Muted then
			continue
		end

		if blocked[k] == true or isUnderfoot(k, v4, position) then
			v4.UnfadeAt = 0
			v4.Faded = true
			local target = v4.Target

			for k2 in v4.Faces do
				repaint(k2, target) -- equivalent call inferred; original call site unknown
			end
		elseif v4.Faded then
			if v4.UnfadeAt == 0 then
				v4.UnfadeAt = serverTimeNow + 1
			elseif v4.UnfadeAt <= serverTimeNow then
				v4.UnfadeAt = 0
				v4.Faded = false

				for k2 in v4.Faces do
					local shelved = v2.shelved
					local transparency = shelved[k2]

					if transparency == nil then
						continue
					end

					shelved[k2] = nil

					if k2.Parent then
						k2.Transparency = transparency
					end
				end
			end
		else
			v4.UnfadeAt = 0
		end
	end
end

local ModelCameraOcclusion = {
	Register = function(folder, target: number)
		strict(folder)
		strict2(target)
		local v4

		if target >= 0 then
			v4 = target <= 1
		else
			v4 = false
		end

		assert(v4, "an occlusion fade target has to land between 0 and 1")
		assert(v2.roster[folder] == nil, (`{folder.Name} is being registered for occlusion twice`))
		local pivot = assert(folder.PrimaryPart, (`{folder.Name} has no PrimaryPart to measure against`))
		local scale = folder:GetScale()
		assert(scale > 0, (`{folder.Name} reports a scale of {scale}, which cannot be normalised`))
		local v6, extents = ModelBounds(folder)
		local v8 = {
			Bounds = pivot.CFrame:ToObjectSpace(v6),
			Extents = extents,
			Faces = {},
			Faded = false,
			Lifetime = Trove.new(),
			Muted = false,
			Pivot = pivot,
			RegisteredScale = scale,
			Target = target,
			UnfadeAt = 0
		}
		v2.roster[folder] = v8

		local function adopt(part)
			if part:IsA("BasePart") then
				assert(v2.faceOwner[part] == nil, (`{part:GetFullName()} is claimed by two occlusion models`))
				v8.Faces[part] = true
				v2.faceOwner[part] = folder

				if v8.Faded then
					repaint(part, v8.Target) -- equivalent call inferred; original call site unknown
				end
			end
		end

		local function drop(part)
			if part:IsA("BasePart") and v8.Faces[part] then
				local shelved = v2.shelved
				local transparency = shelved[part]

				if transparency ~= nil then
					shelved[part] = nil

					if part.Parent then
						part.Transparency = transparency
					end
				end

				v8.Faces[part] = nil
				v2.faceOwner[part] = nil
			end
		end

		for _, descendant in folder:GetDescendants() do
			adopt(descendant)
		end

		v8.Lifetime:Connect(folder.DescendantAdded, adopt)
		v8.Lifetime:Connect(folder.DescendantRemoving, drop)
	end,
	Forget = function(p)
		strict(p)
		local v4 = demand(p) -- equivalent call inferred; original call site unknown
		v4.UnfadeAt = 0
		v4.Faded = false

		for k in v4.Faces do
			local shelved = v2.shelved
			local transparency = shelved[k]

			if transparency == nil then
				continue
			end

			shelved[k] = nil

			if k.Parent then
				k.Transparency = transparency
			end
		end

		for k in v4.Faces do
			v2.faceOwner[k] = nil
		end

		v4.Lifetime:Destroy()
		table.clear(v4.Faces)
		v2.roster[p] = nil
		v2.blocked[p] = nil
	end,
	SetIgnored = function(p, muted: boolean)
		strict(p)
		strict3(muted)
		local v4 = demand(p) -- equivalent call inferred; original call site unknown

		if v4.Muted ~= muted then
			v4.Muted = muted

			if muted then
				v4.UnfadeAt = 0
				v4.Faded = false

				for k in v4.Faces do
					local shelved = v2.shelved
					local transparency = shelved[k]

					if transparency == nil then
						continue
					end

					shelved[k] = nil

					if k.Parent then
						k.Transparency = transparency
					end
				end

				v2.blocked[p] = nil
			end
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function standDown()
	local sweeping = v2.sweeping
	v2.sweeping = false
	local sweep = v2.sweep
	v2.sweep = nil

	if sweep then
		task.defer(RunService.UnbindFromRenderStep, RunService, sweep)
	end

	releaseEverything()

	if sweeping then
		v3:AtDebug():Log("Occlusion sweep released the camera")
	end
end

function ModelCameraOcclusion.SetEnabled(flag: boolean)
	strict3(flag)

	if flag and not v2.sweeping then
		assert(v2.sweep == nil, "an occlusion sweep is bound while the system reads as idle")
		v2.sweeping = true
		local formatted = `ModelCameraOcclusion.{HttpService:GenerateGUID(false)}`
		RunService:BindToRenderStep(formatted, v, onFrame)
		v2.sweep = formatted
		v3:AtDebug():Log("Occlusion sweep took the camera")
	elseif not flag then
		standDown() -- equivalent call inferred; original call site unknown
	end
end

return ModelCameraOcclusion