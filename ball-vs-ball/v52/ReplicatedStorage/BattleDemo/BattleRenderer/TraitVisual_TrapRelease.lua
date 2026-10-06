local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RenderMath = require(script.Parent.RenderMath)

-- equivalent calls inferred from this helper; original call sites unknown
local function brighten(color: Color3)
	local HSV, v, v2 = color:ToHSV()
	return Color3.fromHSV(HSV, v, (math.min(1, v2 * 2.4 + 0.1)))
end

local TraitVisualTrapRelease = {}
TraitVisualTrapRelease.__index = TraitVisualTrapRelease

function TraitVisualTrapRelease.new(ctx)
	local self = setmetatable({}, TraitVisualTrapRelease)
	self._ctx = ctx
	self._tracked = {}
	return self
end

function TraitVisualTrapRelease:_track(p2: string)
	local v = self._tracked[p2]

	if not v then
		v = {
			trapEntries = {},
			fadingModels = {}
		}
		self._tracked[p2] = v
	end

	return v
end

function TraitVisualTrapRelease:_createTrap(p2: string, p3)
	local _ctx = self._ctx
	local trapTemplateBundle = _ctx.trapTemplateBundle
	local trapRelease = _ctx.config.traits.TrapRelease
	local templateModel, v = _ctx.cloneTemplateModel(
		trapTemplateBundle,
		string.format("%s_TrapRelease_Trap_%d", p2, p3.trapId)
	)
	local worldFromArena = _ctx.worldFromArena(p3.position)
	templateModel:PivotTo(RenderMath.getArenaBallCFrame(_ctx.arenaCFrame, worldFromArena) * trapTemplateBundle.forwardOffset:Inverse())
	local radius = math.max(trapTemplateBundle.root.Size.X, trapTemplateBundle.root.Size.Z) * 0.5 * _ctx.arenaScale
	local height = math.max((trapRelease.ringThickness or 0) * _ctx.arenaScale, 0.001)
	local cylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	cylinderHandleAdornment.Name = "TrapRing"
	cylinderHandleAdornment.Adornee = v
	cylinderHandleAdornment.Radius = radius
	cylinderHandleAdornment.InnerRadius = math.max(radius - height, 0)
	cylinderHandleAdornment.Height = height
	cylinderHandleAdornment.Angle = 360
	cylinderHandleAdornment.AlwaysOnTop = false
	cylinderHandleAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
	local lookVector = _ctx.arenaCFrame.LookVector
	local cframe = CFrame.lookAt(
		worldFromArena - lookVector * (height * 0.5),
		worldFromArena + lookVector,
		_ctx.arenaCFrame.UpVector
	)
	cylinderHandleAdornment.CFrame = v.CFrame:ToObjectSpace(cframe)
	cylinderHandleAdornment.Parent = v
	local bodyParts = {}

	for _, part in templateModel:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(bodyParts, {
				part = part,
				color = part.Color,
				transparency = part.Transparency
			})
		end
	end

	local ringColor

	if bodyParts[1] then
		ringColor = bodyParts[1].color
	else
		ringColor = v.Color
	end

	return {
		model = templateModel,
		root = v,
		ring = cylinderHandleAdornment,
		bodyParts = bodyParts,
		ringColor = ringColor,
		isActive = nil
	}
end

function TraitVisualTrapRelease:_applyActive(state, isActive: boolean)
	if state.isActive == isActive then
		return
	end

	state.isActive = isActive

	for _, bodyPart in state.bodyParts do
		local part = bodyPart.part
		local color

		if isActive then
			color = brighten(bodyPart.color)
		else
			color = bodyPart.color
		end

		part.Color = color
		local part2 = bodyPart.part
		local transparency

		if isActive then
			transparency = bodyPart.transparency * 0.4
		else
			transparency = bodyPart.transparency
		end

		part2.Transparency = transparency
	end

	local ring = state.ring
	local color2

	if isActive then
		color2 = brighten(state.ringColor)
	else
		color2 = state.ringColor
	end

	ring.Color3 = color2
	state.ring.Transparency = isActive and 0 or 0.35
end

function TraitVisualTrapRelease:_fadeOutTrap(p, p2, duration: number)
	p2.ring.Visible = false
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, descendant in p2.model:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	table.insert(p.fadingModels, p2.model)
	Debris:AddItem(p2.model, duration)
end

function TraitVisualTrapRelease:update(data)
	local _ctx = self._ctx
	local trapRelease = data.traits and data.traits.TrapRelease

	if not trapRelease then
		self:cleanupBall(data.id)
		return
	end

	if not _ctx.trapTemplateBundle then
		return
	end

	local trapRelease2 = _ctx.config.traits.TrapRelease
	local _track = self:_track(data.id)
	local trapReleaseEffectTemplateName = _ctx.config.visual.trapReleaseEffectTemplateName
	local v = {}
	local v2 = false

	for _, v3 in trapRelease.traps or {} do
		v[v3.trapId] = true
		local trapEntry = _track.trapEntries[v3.trapId]

		if not trapEntry then
			trapEntry = self:_createTrap(data.id, v3)
			_track.trapEntries[v3.trapId] = trapEntry

			if not v2 and trapReleaseEffectTemplateName and (v3.elapsed or 0) <= 0.25 then
				_ctx.playOneShotModelEffect(trapReleaseEffectTemplateName, data.position, nil, data.id)
				v2 = true
			end
		end

		self:_applyActive(trapEntry, v3.isActive == true)
	end

	for k, trapEntry in _track.trapEntries do
		if v[k] then
			continue
		end

		self:_fadeOutTrap(_track, trapEntry, trapRelease2.regionResidueLifetime or 1)
		_track.trapEntries[k] = nil
	end
end

function TraitVisualTrapRelease:cleanupBall(p2: string)
	local v = self._tracked[p2]

	if not v then
		return
	end

	for _, trapEntry in v.trapEntries do
		trapEntry.model:Destroy()
	end

	for _, fadingModel in v.fadingModels do
		if fadingModel.Parent then
			fadingModel:Destroy()
		end
	end

	self._tracked[p2] = nil
end

function TraitVisualTrapRelease:reset()
	for k in self._tracked do
		self:cleanupBall(k)
	end
end

return TraitVisualTrapRelease