local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local TraitVisualOnePunch = {}
TraitVisualOnePunch.__index = TraitVisualOnePunch

function TraitVisualOnePunch.new(ctx)
	local self = setmetatable({}, TraitVisualOnePunch)
	self._ctx = ctx
	self.trails = {}
	self.windups = {}
	self.idleTimers = {}
	self.fadingTrails = {}
	return self
end

local function fadeOutTrail(folder)
	local v = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		v = math.max(v, emitter.Lifetime.Max)
	end

	Debris:AddItem(folder, v)
end

function TraitVisualOnePunch:_updateIdle(p2: string, flag: boolean)
	local now = os.clock()
	local idleTimer = self.idleTimers[p2]

	if not flag or idleTimer == nil then
		self.idleTimers[p2] = now
		return
	end

	local visual = self._ctx.config.visual

	if now - idleTimer >= (visual.onePunchIdleEffectInterval or 2.5) then
		self._ctx.playOneShotModelEffect(visual.onePunchIdleEffectTemplateName, nil, nil, p2)
		self.idleTimers[p2] = now
	end
end

function TraitVisualOnePunch:_updateWindup(p2: string, flag: boolean, p3)
	local clone = self.windups[p2]

	if flag and p3 then
		local _ctx = self._ctx

		if not clone then
			local model = _ctx.effectAssetRoot:FindFirstChild(_ctx.config.visual.onePunchWindupEffectTemplateName)

			if not (model and model:IsA("Model")) then
				return
			end

			clone = model:Clone()
			clone.Name = string.format("%s_OnePunchWindup", p2)
			clone.Parent = _ctx.rootFolder
			clone:PivotTo(CFrame.new(p3.Position) * _ctx.getEffectArenaRotation() * model:GetPivot().Rotation)
			EffectPlayer.playLive(clone)
			self.windups[p2] = clone
		end

		local pivot = clone:GetPivot()
		clone:PivotTo(CFrame.new(p3.Position) * pivot.Rotation)
	elseif clone then
		clone:Destroy()
		self.windups[p2] = nil
	end
end

function TraitVisualOnePunch:_updateTrail(data2, flag: boolean, p)
	local id = data2.id
	local trail = self.trails[id]

	if flag and p then
		local _ctx = self._ctx
		local onePunchTrailTemplateBundle = _ctx.onePunchTrailTemplateBundle

		if not onePunchTrailTemplateBundle then
			return
		end

		if not trail then
			trail = _ctx.cloneTemplateModel(onePunchTrailTemplateBundle, string.format("%s_OnePunchTrail", id))
			trail.Parent = _ctx.rootFolder
			EffectPlayer.playEmbeddedSounds(trail)
			self.trails[id] = trail
		end

		local dashDirection = data2.traits.OnePunch.dashDirection
		local position = p.Position

		if typeof(dashDirection) == "Vector2" and dashDirection.Magnitude > 1e-6 then
			local v = _ctx.worldFromArena(data2.position + dashDirection.Unit, 0) - _ctx.worldFromArena(
				data2.position,
				0
			)
			trail:PivotTo(CFrame.lookAt(position, position + v, _ctx.arenaCFrame.LookVector) * onePunchTrailTemplateBundle.forwardOffset:Inverse())
		else
			local pivot = trail:GetPivot()
			trail:PivotTo(CFrame.new(position) * pivot.Rotation)
		end
	elseif trail then
		fadeOutTrail(trail)
		self.fadingTrails[trail] = true
		self.trails[id] = nil
	end
end

function TraitVisualOnePunch:update(p)
	local onePunch = p.traits and p.traits.OnePunch

	if not onePunch then
		self:cleanupBall(p.id)
		return
	end

	local ballPart = self._ctx.getBallPart(p.id)
	local phase = onePunch.phase
	self:_updateIdle(p.id, phase == "Idle")
	self:_updateWindup(p.id, phase == "Windup", ballPart)
	self:_updateTrail(p, phase == "Dash", ballPart)
end

function TraitVisualOnePunch:cleanupBall(p: string)
	local trail = self.trails[p]

	if trail then
		trail:Destroy()
	end

	local windup = self.windups[p]

	if windup then
		windup:Destroy()
	end

	local trails = self.trails
	local windups = self.windups
	local idleTimers = self.idleTimers
	trails[p] = nil
	windups[p] = nil
	idleTimers[p] = nil
end

function TraitVisualOnePunch:reset()
	for k in self.trails do
		self:cleanupBall(k)
	end

	for k in self.windups do
		self:cleanupBall(k)
	end

	for k in self.fadingTrails do
		k:Destroy()
	end

	table.clear(self.fadingTrails)
	table.clear(self.idleTimers)
end

return TraitVisualOnePunch