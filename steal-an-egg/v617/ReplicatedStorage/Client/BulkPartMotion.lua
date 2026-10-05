local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local t = require(ReplicatedStorage.Packages.t)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))

local function isFiniteVector(data)
	return typeof(data) == "Vector3" and intersection(data.X) and intersection(data.Y) and intersection(data.Z)
end

local function isFiniteCFrame(data)
	local v2

	if typeof(data) == "CFrame" then
		local position = data.Position

		if typeof(position) == "Vector3" then
			v2 = intersection(position.X) and intersection(position.Y) and intersection(position.Z)
		else
			v2 = false
		end

		if v2 then
			local xVector = data.XVector

			if typeof(xVector) == "Vector3" then
				v2 = intersection(xVector.X) and intersection(xVector.Y) and intersection(xVector.Z)
			else
				v2 = false
			end

			if v2 then
				local yVector = data.YVector

				if typeof(yVector) == "Vector3" then
					v2 = intersection(yVector.X) and intersection(yVector.Y) and intersection(yVector.Z)
				else
					v2 = false
				end

				if v2 then
					local zVector = data.ZVector

					if typeof(zVector) == "Vector3" then
						return intersection(zVector.X) and intersection(zVector.Y) and intersection(zVector.Z)
					else
						return false
					end
				end
			end
		end
	else
		return false
	end

	return v2
end

local strict = t.strict(t.instanceIsA("BasePart"))
local strict2 = t.strict(isFiniteCFrame)
local strict3 = t.strict(t.optional(isFiniteCFrame))
local strict4 = t.strict(isFiniteVector)
local strict5 = t.strict(t.TweenInfo)
local class = {}
class.__index = class
local v2 = {}
local v3 = {}
local v4 = {}
local bodies = {}
local queueds = {}

local function isAlive(p)
	return p ~= nil and p.Parent ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropGlide(p)
	v4[p] = nil
	p.origin = nil
	p.destination = nil
	p.curve = nil
	p.spent = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function retire(p)
	local body = p.body

	if body then
		v2[body] = nil
	end

	v3[p] = nil
	dropGlide(p) -- equivalent call inferred; original call site unknown
	p.body = nil
	p.root = nil
	p.queued = nil
	p.extent = nil
	p.retired = true
end

local function writable(p)
	local body = p.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if v5 then
		return body
	end

	retire(p) -- equivalent call inferred; original call site unknown
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enqueue(p, root: CFrame)
	p.root = root
	p.queued = root * p.lean
	v3[p] = true
end

local function reshape(state, vector2: Vector3?, vector3: Vector3?)
	strict4(vector2 or vector3)

	if state.retired then
		return
	end

	state.extent = vector2 or state.extent
	state.stretch = vector3 or state.stretch
	local body = state.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(state) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if body then
		local extent = state.extent or body.Size
		local stretch = state.stretch
		body.Size = Vector3.new(extent.X * stretch.X, extent.Y * stretch.Y, extent.Z * stretch.Z)
	end
end

local function reposition(p, root: CFrame, flag: boolean)
	strict2(root)
	local body = p.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(p) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if not body then
		return
	end

	dropGlide(p) -- equivalent call inferred; original call site unknown
	enqueue(p, root) -- equivalent call inferred; original call site unknown

	if flag then
		v3[p] = nil
		body.CFrame = p.queued
	end
end

local function sweepDead()
	for k, v5 in v2 do
		local v6

		if k == nil then
			v6 = false
		else
			v6 = k.Parent ~= nil
		end

		if v6 then
			continue
		end

		retire(v5) -- equivalent call inferred; original call site unknown
	end
end

local function advanceGlides(p: number)
	for k in v4 do
		local origin = k.origin
		local destination = k.destination
		local curve = k.curve
		local v5

		if origin == nil or destination == nil then
			v5 = false
		else
			v5 = curve ~= nil
		end

		local body = k.body
		local v6

		if body == nil then
			v6 = false
		else
			v6 = body.Parent ~= nil
		end

		if not v6 then
			retire(k) -- equivalent call inferred; original call site unknown
			body = nil
		end

		if body == nil then
			continue
		end

		if v5 then
			local time = curve.Time
			k.spent += p
			local v7 = not (time > 0) and 1 or math.clamp(k.spent / time, 0, 1)
			enqueue(k, origin:Lerp(destination, (TweenService:GetValue(v7, curve.EasingStyle, curve.EasingDirection)))) -- equivalent call inferred; original call site unknown

			if v7 >= 1 then
				dropGlide(k) -- equivalent call inferred; original call site unknown
			end
		else
			dropGlide(k) -- equivalent call inferred; original call site unknown
		end
	end
end

local BulkPartMotion = {
	Register = function(body, cframe: CFrame?)
		strict(body)
		strict3(cframe)
		local v5 = v2[body]

		if v5 == nil or v5.retired then
			v5 = setmetatable({
				body = body,
				root = nil,
				lean = CFrame.identity,
				queued = nil,
				origin = nil,
				destination = nil,
				curve = nil,
				spent = 0,
				extent = nil,
				stretch = createVector(1, 1, 1),
				retired = false
			}, class)
		end

		if cframe then
			v5:SetCFrame(cframe)
		end

		v2[body] = v5
		return v5
	end,
	Forget = function(p)
		strict(p)
		local v5 = v2[p]

		if v5 then
			retire(v5) -- equivalent call inferred; original call site unknown
		end
	end,
	Commit = function(value: number?)
		advanceGlides(value or 0)
		table.clear(bodies)
		table.clear(queueds)
		local count = 0

		for k in v3 do
			v3[k] = nil
			local body = k.body
			local queued = k.queued
			k.queued = nil
			local v5

			if body == nil then
				v5 = false
			else
				v5 = body.Parent ~= nil
			end

			if v5 then
				if queued then
					count += 1
					bodies[count] = body
					queueds[count] = queued
				end
			else
				retire(k) -- equivalent call inferred; original call site unknown
			end
		end

		if count <= 0 then
			return
		end

		if not TryCall(function()
			workspace:BulkMoveTo(bodies, queueds, Enum.BulkMoveMode.FireCFrameChanged)
		end) then
			sweepDead()
			v:AtWarning():Log("A batched part move was rejected; the roster was swept")
		end
	end
}

function class.Subject(p)
	if p.retired then
		return nil
	end

	return p.body
end

function class.Destroy(p)
	if not p.retired then
		retire(p) -- equivalent call inferred; original call site unknown
	end
end

function class.Halt(p)
	dropGlide(p) -- equivalent call inferred; original call site unknown
end

function class.Stretch(p, vector2: Vector3)
	reshape(p, nil, vector2)
end

function class.Span(p, vector2: Vector3)
	reshape(p, vector2, nil)
end

function class:Lean(lean: CFrame)
	strict2(lean)
	local body = self.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(self) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if body then
		self.lean = lean
		local root = self.root or body.CFrame
		enqueue(self, root) -- equivalent call inferred; original call site unknown
	end
end

function class:Glide(curve, destination: CFrame)
	strict5(curve)
	strict2(destination)
	local body = self.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(self) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if body then
		self.origin = self.root or body.CFrame
		self.destination = destination
		self.curve = curve
		self.spent = 0
		v4[self] = true
		v3[self] = true
	end
end

function class.Snap(p, root: CFrame)
	strict2(root)
	local body = p.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(p) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if not body then
		return
	end

	dropGlide(p) -- equivalent call inferred; original call site unknown
	enqueue(p, root) -- equivalent call inferred; original call site unknown
	v3[p] = nil
	body.CFrame = p.queued
end

function class:SetCFrame(root: CFrame)
	strict2(root)
	local body = self.body
	local v5

	if body == nil then
		v5 = false
	else
		v5 = body.Parent ~= nil
	end

	if not v5 then
		retire(self) -- equivalent call inferred; original call site unknown
		body = nil
	end

	if not body then
		return
	end

	dropGlide(self) -- equivalent call inferred; original call site unknown
	enqueue(self, root) -- equivalent call inferred; original call site unknown
end

RunService.PreSimulation:Connect(BulkPartMotion.Commit)
return BulkPartMotion