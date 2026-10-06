local RenderMath = require(script.Parent.RenderMath)
local TraitVisualTimeBomb = {}
TraitVisualTimeBomb.__index = TraitVisualTimeBomb

function TraitVisualTimeBomb.new(ctx)
	local self = setmetatable({}, TraitVisualTimeBomb)
	self._ctx = ctx
	self.bombModels = {}
	return self
end

function TraitVisualTimeBomb:_bombModel(p2, p3)
	local v = self.bombModels[p2] or {}
	self.bombModels[p2] = v
	local v2 = v[p3]

	if v2 then
		return v2
	end

	local _ctx = self._ctx
	v2 = _ctx.cloneTemplateModel(_ctx.bombTemplateBundle, string.format("TimeBomb_%s_%d", p2, p3))
	_ctx.setTemplateModelVisibility(v2, true)
	v[p3] = v2
	return v2
end

function TraitVisualTimeBomb:update(p)
	local _ctx = self._ctx
	local timeBomb = p.traits.TimeBomb
	local timeBomb2 = _ctx.config.traits.TimeBomb
	local bombFuseDuration = timeBomb2 and timeBomb2.bombFuseDuration or 0
	local v = {}

	for _, v2 in timeBomb and timeBomb.bombs or {} do
		v[v2.bombId] = true
		local _bombModel = self:_bombModel(p.id, v2.bombId)
		_bombModel:PivotTo(RenderMath.getArenaBallCFrame(_ctx.arenaCFrame, _ctx.worldFromArena(v2.position)) * CFrame.Angles(
			0,
			0,
			-1.5707963267948966
		) * _ctx.bombTemplateBundle.forwardOffset:Inverse())
		local UI = _bombModel:FindFirstChild("倒计时UI")
		local label = UI and UI:FindFirstChild("等级字")

		if label and label:IsA("TextLabel") then
			label.Text = tostring((math.ceil((math.max(0, bombFuseDuration - (v2.fuseElapsed or 0))))))
		end
	end

	for k, v2 in self.bombModels[p.id] or {} do
		if v[k] then
			continue
		end

		v2:Destroy()
		self.bombModels[p.id][k] = nil
	end
end

function TraitVisualTimeBomb:cleanupBall(p2)
	for _, v in self.bombModels[p2] or {} do
		v:Destroy()
	end

	self.bombModels[p2] = nil
end

function TraitVisualTimeBomb:reset()
	for k in self.bombModels do
		self:cleanupBall(k)
	end

	self.bombModels = {}
end

return TraitVisualTimeBomb