local function getWorldScale(object)
	local scale = object:GetScale()

	if scale == scale and not (scale <= 0) then
		return scale
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleCFramePosition(cframe: CFrame, p: number)
	local position = cframe.Position
	local v = cframe - position
	return CFrame.new(position * p) * v
end

local EmoteVfxScale = {}

function EmoteVfxScale:scaleMotor6DForWorldScale(object)
	local scale = object:GetScale()
	local v = (scale ~= scale or scale <= 0) and 1 or scale

	if v == 1 then
		return
	end

	self.C0 = scaleCFramePosition(self.C0, v)
	self.C1 = scaleCFramePosition(self.C1, v)
end

function EmoteVfxScale:scaleToCharacterWorldScale(object)
	local scale = object:GetScale()
	local v = (scale ~= scale or scale <= 0) and 1 or scale

	if v == 1 then
		return
	end

	if self:IsA("Model") or self:IsA("Tool") then
		pcall(function()
			self:ScaleTo(v)
		end)
	elseif self:IsA("BasePart") then
		local model = Instance.new("Model")
		self.Parent = model
		model.PrimaryPart = self
		local v2 = pcall(function()
			model:ScaleTo(v)
		end)
		self.Parent = nil
		model:Destroy()

		if not v2 then
			self.Size *= v
		end
	end
end

return EmoteVfxScale