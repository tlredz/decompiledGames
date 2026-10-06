local TraitVisualThomasUpgrade = {}
TraitVisualThomasUpgrade.__index = TraitVisualThomasUpgrade

function TraitVisualThomasUpgrade.new(ctx)
	local self = setmetatable({}, TraitVisualThomasUpgrade)
	self._ctx = ctx
	self.thomasModels = {}
	self.thomasParts = {}
	self.thomasLevelBillboards = {}
	return self
end

function TraitVisualThomasUpgrade:update(p)
	local _ctx = self._ctx
	local thomasUpgrade = p.traits and p.traits.ThomasUpgrade
	local thomas = thomasUpgrade and thomasUpgrade.thomas
	local thomasModel = self.thomasModels[p.id]

	if thomas then
		local thomasPart = self.thomasParts[p.id]

		if not (thomasModel and thomasPart) then
			thomasModel, thomasPart = _ctx.cloneTemplateModel(_ctx.templateBundle, p.id .. "_Thomas")
			local thomasModels = self.thomasModels
			local id = p.id
			local thomasParts = self.thomasParts
			local id2 = p.id
			thomasModels[id] = thomasModel
			thomasParts[id2] = thomasPart
			local UI = thomasModel:FindFirstChild("等级UI")
			assert(UI and UI:IsA("BillboardGui"), "托马斯模型缺少 BillboardGui：等级UI")
			UI.Parent = _ctx.rootFolder
			self.thomasLevelBillboards[p.id] = UI
		end

		local billboardGui = self.thomasLevelBillboards[p.id]
		assert(billboardGui and billboardGui:IsA("BillboardGui"), "托马斯等级 UI 未创建")
		billboardGui.Adornee = thomasPart
		billboardGui.Enabled = true
		local label = billboardGui:FindFirstChild("等级字")
		assert(label and label:IsA("TextLabel"), "托马斯等级UI缺少 TextLabel：等级字")
		label.Text = string.format("Lv%d", thomas.level or 0)
		thomasModel:ScaleTo(thomas.radius / math.max(0.001, thomas.baseRadius))
		local worldFromArena = _ctx.worldFromArena(thomas.position, thomas.radius)
		local markerOffset = _ctx.templateBundle.markerOffset
		thomasModel:PivotTo(_ctx.getArenaBallCFrame(worldFromArena) * markerOffset:Inverse())
		_ctx.setTemplateModelVisibility(thomasModel, true)
	else
		if thomasModel then
			thomasModel:Destroy()
			local thomasModels = self.thomasModels
			local id = p.id
			local thomasParts = self.thomasParts
			local id2 = p.id
			thomasModels[id] = nil
			thomasParts[id2] = nil
		end

		local thomasLevelBillboard = self.thomasLevelBillboards[p.id]

		if thomasLevelBillboard then
			thomasLevelBillboard:Destroy()
			self.thomasLevelBillboards[p.id] = nil
		end
	end
end

function TraitVisualThomasUpgrade:cleanupBall(p: string)
	local thomasModel = self.thomasModels[p]

	if thomasModel then
		thomasModel:Destroy()
	end

	local thomasLevelBillboard = self.thomasLevelBillboards[p]

	if thomasLevelBillboard then
		thomasLevelBillboard:Destroy()
	end

	local thomasModels = self.thomasModels
	local thomasParts = self.thomasParts
	local thomasLevelBillboards = self.thomasLevelBillboards
	thomasModels[p] = nil
	thomasParts[p] = nil
	thomasLevelBillboards[p] = nil
end

function TraitVisualThomasUpgrade:cleanupInactive(p)
	for k in self.thomasModels do
		if not p[k] then
			self:cleanupBall(k)
		end
	end
end

return TraitVisualThomasUpgrade