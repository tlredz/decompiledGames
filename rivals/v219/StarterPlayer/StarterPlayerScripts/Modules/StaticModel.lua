local StaticModel = {}
StaticModel.__index = StaticModel

function StaticModel.new(model)
	local self = setmetatable({}, StaticModel)
	self.Model = model
	self._destroyed = false
	self._original_scale = self.Model:GetScale()
	self:_Init()
	return self
end

function StaticModel:GetPivot()
	return self.Model:GetPivot()
end

function StaticModel.SetParent(p, parent)
	p.Model.Parent = parent
end

function StaticModel.SetArchivable(p, archivable)
	for _, part in pairs(p.Model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Archivable = archivable
		end
	end
end

function StaticModel:ScaleTo(p2)
	self.Model:ScaleTo(self._original_scale * p2)
end

function StaticModel:PivotTo(cframe, p)
	self.Model.WorldPivot = p or self.Model.WorldPivot
	self.Model:PivotTo(cframe)
	self:Update(0)
end

function StaticModel:Update(_) end

function StaticModel:Destroy()
	self._destroyed = true
	self.Model:Destroy()
end

function StaticModel:_Init() end

return StaticModel