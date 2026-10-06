local SpearThrustGeometry = require(script.Parent.Parent.SpearThrustGeometry)
local TraitVisualSpearThrust = {}
TraitVisualSpearThrust.__index = TraitVisualSpearThrust

function TraitVisualSpearThrust.new(ctx)
	local self = setmetatable({}, TraitVisualSpearThrust)
	self._ctx = ctx
	self.spearModels = {}
	self.dashModels = {}
	return self
end

function TraitVisualSpearThrust:_updateDashEffect(p2)
	local _ctx = self._ctx
	local spearDashEffectTemplateBundle = _ctx.spearDashEffectTemplateBundle

	if not spearDashEffectTemplateBundle then
		return
	end

	local ballPart = _ctx.getBallPart(p2.id)
	local attachment = ballPart and ballPart:FindFirstChild("朝向标记")

	if not (attachment and attachment:IsA("Attachment")) then
		return
	end

	local dashModel = self.dashModels[p2.id]

	if not dashModel then
		dashModel = _ctx.cloneTemplateModel(spearDashEffectTemplateBundle, string.format("%s_SpearDash", p2.id))
		dashModel.Parent = _ctx.rootFolder
		self.dashModels[p2.id] = dashModel
	end

	dashModel:PivotTo(attachment.WorldCFrame * spearDashEffectTemplateBundle.markerOffset:Inverse())
end

function TraitVisualSpearThrust:update(data)
	local _ctx = self._ctx
	local spearThrust = data.traits and data.traits.SpearThrust

	if not spearThrust then
		self:cleanupBall(data.id)
		return
	end

	self:_updateDashEffect(data)
	local direction = data.direction

	if typeof(direction) ~= "Vector2" or direction.Magnitude < 1e-6 then
		return
	end

	local spearTemplateBundle = _ctx.spearTemplateBundle
	local size = spearTemplateBundle.root.Size
	local poseProgress = tonumber(spearThrust.poseProgress) or 0
	local pose, v = SpearThrustGeometry.resolvePose(
		data.position,
		direction.Unit,
		data.radius,
		size.Z,
		size.X,
		poseProgress
	)
	local ballMarkerHeight = _ctx.getBallMarkerHeight(data.id)
	local worldFromArena = _ctx.worldFromArena(pose, ballMarkerHeight)
	local worldFromArena2 = _ctx.worldFromArena(pose + v, ballMarkerHeight)
	local spearModel = self.spearModels[data.id]

	if not spearModel then
		spearModel = _ctx.cloneTemplateModel(spearTemplateBundle, string.format("%s_Spear", data.id))
		spearModel.Parent = _ctx.rootFolder
		self.spearModels[data.id] = spearModel
	end

	spearModel:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, _ctx.arenaCFrame.LookVector) * spearTemplateBundle.markerOffset:Inverse())
end

function TraitVisualSpearThrust:cleanupBall(p2: string)
	local spearModel = self.spearModels[p2]

	if spearModel then
		spearModel:Destroy()
	end

	local dashModel = self.dashModels[p2]

	if dashModel then
		dashModel:Destroy()
	end

	local spearModels = self.spearModels
	local dashModels = self.dashModels
	spearModels[p2] = nil
	dashModels[p2] = nil
end

function TraitVisualSpearThrust:reset()
	for k in self.spearModels do
		self:cleanupBall(k)
	end

	for k in self.dashModels do
		self:cleanupBall(k)
	end
end

return TraitVisualSpearThrust