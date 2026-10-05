local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local RaycastHelper = require(script.Parent.RaycastHelper)
local Utility = require(script.Parent.Utility)
local HitCooldown = require(script.Parent.Subsets.Gameplay.HitCooldown)
local gameSettings = require(script.Parent.gameSettings)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local PartBox = {}
local class = {}
class.__index = class
local cframe = CFrame.Angles(0, 0, 1.5707963267948966)

local function modelOf(instance)
	local model = instance:FindFirstAncestorWhichIsA("Model")

	if model == nil or model.PrimaryPart == nil or model:FindFirstChildOfClass("Humanoid") == nil then
		return nil
	end

	return model
end

function PartBox.new(data)
	if data == nil or data.Shape == nil or data.Center == nil or data.Size == nil then
		return
	end

	local cframe2

	if typeof(data.Center) == "Vector3" then
		cframe2 = CFrame.new(data.Center)
	else
		cframe2 = data.Center
	end

	local part = Instance.new("Part")
	part.Shape = data.Shape

	if data.Shape == "Cylinder" then
		part.Size = Vector3.new(data.Size.Y, data.Size.X, data.Size.Z)
		part.CFrame = cframe2 * cframe
	else
		part.Size = data.Size
		part.CFrame = cframe2
	end

	if (gameSettings.hitboxVisualiserEnabled == true or data.visualize == true) and isStudio then
		part.Transparency = gameSettings.HitBoxTransparency or 0.85
		part.Color = Color3.fromRGB(255, 0, 0)
		part.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		part.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	else
		part.Transparency = 1
	end

	part.CastShadow = false
	part.CanQuery = true
	part.CanCollide = false
	part.CanTouch = true
	part.Anchored = true
	part.AudioCanCollide = false
	local object = setmetatable({
		Part = part,
		Entered = simplesignal.new(),
		Left = simplesignal.new()
	}, class)
	local touching = {}
	local inside = {}
	local partConns = {}
	object._touching = touching
	object._inside = inside
	object._partConns = partConns
	object._leave = nil
	object._expiry = task.delay(data.MaxDuration or 15, function()
		object._expiry = nil
		object:Destroy()
	end)

	local function admitAlly(p, flag: boolean)
		if inside[p] ~= nil then
			return
		end

		local getvaluesfolder = Utility.getvaluesfolder(p)
		inside[p] = { getvaluesfolder }

		if data.hitDetected ~= nil then
			data.hitDetected(p, getvaluesfolder, nil, data.extraArgs or {})
		end

		if flag then
			object.Entered:Fire(p, getvaluesfolder, nil, data.extraArgs or {})
		end
	end

	local v4 = HitCooldown.new(data.TouchCooldown or 1)

	local function enter(model)
		if not (inside[model] == nil and v4:Take(model)) then
			return
		end

		if data.Allies == true then
			admitAlly(model, true)
			return
		end

		local v5, _, v6, v7 = Utility.ProcessHitboxTarget(data, model)

		if not v5 then
			return
		end

		inside[model] = { v6, v7 }
		object.Entered:Fire(model, v6, v7, data.extraArgs or {})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function leave(p)
		local v5 = inside[p]

		if v5 == nil then
			return
		end

		inside[p] = nil
		object.Left:Fire(p, v5[1], v5[2], data.extraArgs or {})
	end

	object._leave = leave

	local function stillInside(p)
		for _, v5 in workspace:GetPartsInPart(part, RaycastHelper.Humanoids) do
			local model = v5:FindFirstAncestorWhichIsA("Model")

			if model == nil or model.PrimaryPart == nil or model:FindFirstChildOfClass("Humanoid") == nil then
				model = nil
			end

			if model == p then
				return true
			end
		end

		return false
	end

	local v5 = false

	local function verifySoon()
		if v5 or object._destroyed then
			return
		end

		v5 = true
		task.delay(0.2, function()
			v5 = false

			if object._destroyed then
				return
			end

			local v6 = {}

			for k in inside do
				if k.Parent == nil or not stillInside(k) then
					table.insert(v6, k)
				end
			end

			for _, v7 in v6 do
				touching[v7] = nil
				leave(v7) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function forgetPart(p, p2)
		local v6 = touching[p]

		if v6 == nil then
			return
		end

		v6[p2] = nil

		if next(v6) == nil or not stillInside(p) then
			touching[p] = nil
			leave(p) -- equivalent call inferred; original call site unknown
		elseif not v5 then
			if object._destroyed then
				return
			end

			v5 = true
			task.delay(0.2, function()
				v5 = false

				if object._destroyed then
					return
				end

				local v7 = {}

				for k in inside do
					if k.Parent == nil or not stillInside(k) then
						table.insert(v7, k)
					end
				end

				for _, v8 in v7 do
					touching[v8] = nil
					leave(v8) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	object._partDestroying = part.Destroying:Once(function()
		object:Destroy()
	end)

	local function trackPart(model, instance)
		local v6 = touching[model]

		if v6 == nil then
			v6 = {}
			touching[model] = v6
		end

		if v6[instance] then
			return false
		end

		v6[instance] = true
		partConns[instance] = instance.Destroying:Once(function()
			partConns[instance] = nil
			forgetPart(model, instance) -- equivalent call inferred; original call site unknown
		end)
		return true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dropPart(model, otherPart)
		local connection = partConns[otherPart]

		if connection ~= nil then
			connection:Disconnect()
			partConns[otherPart] = nil
		end

		forgetPart(model, otherPart) -- equivalent call inferred; original call site unknown
	end

	part.Parent = workspace.Debree
	local models = {}

	for _, v6 in workspace:GetPartsInPart(part, RaycastHelper.Humanoids) do
		local model = v6:FindFirstAncestorWhichIsA("Model")

		if model == nil or model.PrimaryPart == nil or model:FindFirstChildOfClass("Humanoid") == nil then
			model = nil
		end

		if model == nil then
			continue
		end

		trackPart(model, v6)

		if table.find(models, model) == nil then
			table.insert(models, model)
		end
	end

	if data.Allies == true then
		for _, v6 in models do
			admitAlly(v6, false)
		end

		if data.After ~= nil then
			data.After()
		end
	else
		Utility.ProcessHitboxTargets(data, table.clone(models))

		for _, v6 in models do
			v4:Take(v6)
			local humanoid = v6:FindFirstChildOfClass("Humanoid")

			if not (v6 ~= data.caster and humanoid ~= nil and humanoid.RootPart ~= nil) then
				continue
			end

			local getvaluesfolder = Utility.getvaluesfolder(v6)
			local check_victim = data.checker.check_victim(script, data.caster, v6)

			if check_victim ~= nil and (not data.specificStateResult or check_victim == data.specificStateResult) then
				inside[v6] = { getvaluesfolder, check_victim }
			end
		end
	end

	object._touched = part.Touched:Connect(function(otherPart)
		local model = otherPart:FindFirstAncestorWhichIsA("Model")

		if model == nil or model.PrimaryPart == nil or model:FindFirstChildOfClass("Humanoid") == nil then
			model = nil
		end

		if model == nil then
			return
		end

		if trackPart(model, otherPart) then
			enter(model)
		end
	end)
	object._touchEnded = part.TouchEnded:Connect(function(otherPart)
		local model = otherPart:FindFirstAncestorWhichIsA("Model")

		if model == nil or model.PrimaryPart == nil or model:FindFirstChildOfClass("Humanoid") == nil then
			model = nil
		end

		if model == nil then
			return
		end

		dropPart(model, otherPart) -- equivalent call inferred; original call site unknown
	end)
	return object
end

function class:Inside()
	local result = {}

	for k in self._inside do
		table.insert(result, k)
	end

	return result
end

function class:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self._expiry then
		task.cancel(self._expiry)
		self._expiry = nil
	end

	if self._leave ~= nil then
		for k in self._inside do
			self._leave(k)
		end
	end

	if self._touched then
		self._touched:Disconnect()
		self._touched = nil
	end

	if self._touchEnded then
		self._touchEnded:Disconnect()
		self._touchEnded = nil
	end

	if self._partDestroying then
		self._partDestroying:Disconnect()
		self._partDestroying = nil
	end

	for _, _partConn in self._partConns do
		_partConn:Disconnect()
	end

	table.clear(self._partConns)
	table.clear(self._touching)
	table.clear(self._inside)

	if self.Part ~= nil then
		self.Part:Destroy()
	end

	self.Part = nil
	setmetatable(self, nil)
end

return PartBox