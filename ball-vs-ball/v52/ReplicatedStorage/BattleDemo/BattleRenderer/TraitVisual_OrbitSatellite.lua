local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrbitRingGeometry = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("OrbitRingGeometry"))
local TraitVisualOrbitSatellite = {}
TraitVisualOrbitSatellite.__index = TraitVisualOrbitSatellite
local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)

function TraitVisualOrbitSatellite.new(ctx)
	local self = setmetatable({}, TraitVisualOrbitSatellite)
	self._ctx = ctx
	self.satelliteModels = {}
	self.ringAdornments = {}
	return self
end

function TraitVisualOrbitSatellite:_ensureRings(p2: string)
	local _ctx = self._ctx

	if self.ringAdornments[p2] then
		return
	end

	local ballPart = _ctx.getBallPart(p2)

	if not ballPart then
		return
	end

	local orbitSatellite = _ctx.config.traits.OrbitSatellite

	if not orbitSatellite then
		return
	end

	local height = math.max((orbitSatellite.ringThickness or 0) * _ctx.arenaScale, 0.001)
	local v2 = {}

	for i = 1, OrbitRingGeometry.RING_COUNT do
		local radius = OrbitRingGeometry.radiusForRing(orbitSatellite, i) * _ctx.arenaScale
		local cylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
		cylinderHandleAdornment.Name = string.format("OrbitRing_%s_%d", p2, i)
		cylinderHandleAdornment.Adornee = ballPart
		cylinderHandleAdornment.Radius = radius
		cylinderHandleAdornment.InnerRadius = math.max(radius - height, 0)
		cylinderHandleAdornment.Height = height
		cylinderHandleAdornment.Angle = 360
		cylinderHandleAdornment.Color3 = Color3.new(1, 1, 1)
		cylinderHandleAdornment.Transparency = 0
		cylinderHandleAdornment.Visible = false
		cylinderHandleAdornment.AlwaysOnTop = false
		cylinderHandleAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
		cylinderHandleAdornment.CFrame = cframe * CFrame.new(0, 0, height * 0.5)
		cylinderHandleAdornment.Parent = ballPart
		v2[i] = cylinderHandleAdornment
	end

	self.ringAdornments[p2] = v2
end

function TraitVisualOrbitSatellite:update(p)
	local _ctx = self._ctx
	local orbitSatelliteTemplateBundle = _ctx.orbitSatelliteTemplateBundle

	if not orbitSatelliteTemplateBundle then
		return
	end

	local orbitSatellite = p.traits.OrbitSatellite

	if not (orbitSatellite and orbitSatellite.slots) then
		return
	end

	self:_ensureRings(p.id)
	local v = self.satelliteModels[p.id] or {}
	self.satelliteModels[p.id] = v
	local v2 = {}

	for _, slot in orbitSatellite.slots do
		if slot.occupied then
			v2[slot.ring] = (v2[slot.ring] or 0) + 1
		end
	end

	for k, v3 in self.ringAdornments[p.id] or {} do
		v3.Visible = (v2[k] or 0) > 0
	end

	for k, slot in orbitSatellite.slots do
		local v3 = v[k]

		if not v3 then
			v3 = _ctx.cloneTemplateModel(orbitSatelliteTemplateBundle, string.format("OrbitSatellite_%s_%d", p.id, k))
			v3.Parent = _ctx.rootFolder
			v[k] = v3
		end

		if slot.occupied and slot.position then
			local worldFromArena = _ctx.worldFromArena(slot.position)
			v3:PivotTo(CFrame.lookAt(
				worldFromArena,
				worldFromArena + _ctx.arenaCFrame.UpVector,
				_ctx.arenaCFrame.LookVector
			) * orbitSatelliteTemplateBundle.forwardOffset:Inverse())
			_ctx.setTemplateModelVisibility(v3, true)
		else
			_ctx.setTemplateModelVisibility(v3, false)
		end
	end
end

function TraitVisualOrbitSatellite:cleanupBall(p2: string)
	for _, v in self.satelliteModels[p2] or {} do
		v:Destroy()
	end

	for _, v in self.ringAdornments[p2] or {} do
		v:Destroy()
	end

	local satelliteModels = self.satelliteModels
	local ringAdornments = self.ringAdornments
	satelliteModels[p2] = nil
	ringAdornments[p2] = nil
end

function TraitVisualOrbitSatellite:reset()
	for k in self.satelliteModels do
		self:cleanupBall(k)
	end

	for k in self.ringAdornments do
		self:cleanupBall(k)
	end

	self.satelliteModels = {}
	self.ringAdornments = {}
end

return TraitVisualOrbitSatellite