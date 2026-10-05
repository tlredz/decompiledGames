local HighlightTargets = {}
local v = {}
local model = Instance.new("Model")
model.Name = "BlurHighlightTarget"

function HighlightTargets.IsMuted(p)
	local v2 = v[p]
	return v2 ~= nil and v2.Muted
end

function HighlightTargets:SetAdornee(adornee)
	local v2 = v[self]

	if v2 then
		v2.Adornee = adornee

		if v2.Muted then
			return
		end
	end

	if self.Adornee ~= adornee then
		self.Adornee = adornee
	end
end

function HighlightTargets:Track(p)
	if v[self] then
		return
	end

	local v2 = {
		Adornee = self.Adornee,
		Muted = false
	}
	v[self] = v2
	v2.Connection = self:GetPropertyChangedSignal("Adornee"):Connect(function()
		if self.Adornee == model then
			return
		end

		v2.Adornee = self.Adornee

		if v2.Muted then
			self.Adornee = model
		end
	end)
	HighlightTargets.SetMuted(self, p)
end

function HighlightTargets:SetMuted(muted)
	local v2 = v[self]

	if not v2 or v2.Muted == muted then
		return
	end

	v2.Muted = muted

	if muted then
		v2.Adornee = self.Adornee

		if self.Adornee ~= model then
			self.Adornee = model
		end
	elseif self.Adornee == model then
		self.Adornee = v2.Adornee
	end
end

function HighlightTargets:Untrack()
	local v2 = v[self]

	if not v2 then
		return
	end

	v[self] = nil
	v2.Connection:Disconnect()

	if v2.Muted and self.Adornee == model then
		self.Adornee = v2.Adornee
	end
end

return HighlightTargets