local cframe = CFrame.new(vector.create(1000000000, 1000000000, 1000000000))

local function disableTrails(trail)
	if trail:IsA("Trail") then
		pcall(function()
			if trail:GetAttribute("_pooledTrailEnabled") == nil then
				trail:SetAttribute("_pooledTrailEnabled", trail.Enabled)
			end

			if trail:GetAttribute("_pooledTrailLifetime") == nil then
				trail:SetAttribute("_pooledTrailLifetime", trail.Lifetime)
			end

			trail.Lifetime = 0
			trail.Enabled = false
		end)
		return
	end

	for _, trail2 in ipairs(trail:GetDescendants()) do
		if not trail2:IsA("Trail") then
			continue
		end

		local v = trail2
		pcall(function()
			if v:GetAttribute("_pooledTrailEnabled") == nil then
				v:SetAttribute("_pooledTrailEnabled", v.Enabled)
			end

			if v:GetAttribute("_pooledTrailLifetime") == nil then
				v:SetAttribute("_pooledTrailLifetime", v.Lifetime)
			end

			v.Lifetime = 0
			v.Enabled = false
		end)
	end
end

local function restoreTrails(trail)
	if trail:IsA("Trail") then
		pcall(function()
			local _pooledTrailLifetime = trail:GetAttribute("_pooledTrailLifetime")

			if _pooledTrailLifetime ~= nil then
				trail.Lifetime = _pooledTrailLifetime
			end

			trail:SetAttribute("_pooledTrailLifetime", nil)
			local _pooledTrailEnabled = trail:GetAttribute("_pooledTrailEnabled")

			if _pooledTrailEnabled ~= nil then
				trail.Enabled = _pooledTrailEnabled == true
			end

			trail:SetAttribute("_pooledTrailEnabled", nil)
		end)
		return
	end

	for _, trail2 in ipairs(trail:GetDescendants()) do
		if not trail2:IsA("Trail") then
			continue
		end

		local v = trail2
		pcall(function()
			local _pooledTrailLifetime = v:GetAttribute("_pooledTrailLifetime")

			if _pooledTrailLifetime ~= nil then
				v.Lifetime = _pooledTrailLifetime
			end

			v:SetAttribute("_pooledTrailLifetime", nil)
			local _pooledTrailEnabled = v:GetAttribute("_pooledTrailEnabled")

			if _pooledTrailEnabled ~= nil then
				v.Enabled = _pooledTrailEnabled == true
			end

			v:SetAttribute("_pooledTrailEnabled", nil)
		end)
	end
end

local function cancelNativeDescendants(folder)
	for _, effect in ipairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		local v = effect
		pcall(function()
			local _PartIcleNativeEmitGen = v:GetAttribute("_PartIcleNativeEmitGen") or 0
			v:SetAttribute("_PartIcleNativeEmitGen", _PartIcleNativeEmitGen + 1)
			local _PartIcleNativeDurationGen = v:GetAttribute("_PartIcleNativeDurationGen") or 0
			v:SetAttribute("_PartIcleNativeDurationGen", _PartIcleNativeDurationGen + 1)
			v.Enabled = false
		end)
	end
end

local PoolHide = {}

function PoolHide:hide(p)
	if not (self and self.Parent) then
		return
	end

	if p == "Part" then
		disableTrails(self)
		cancelNativeDescendants(self)

		if self:IsA("BasePart") then
			pcall(function()
				self.CFrame = cframe
			end)
		end
	elseif p == "Model" or p == "Lightning" then
		disableTrails(self)
		cancelNativeDescendants(self)
		pcall(function()
			self:PivotTo(cframe)
		end)
	elseif p == "Rocks" or p == "Rope" then
		disableTrails(self)
		cancelNativeDescendants(self)

		for _, part2 in ipairs(self:GetChildren()) do
			if not part2:IsA("BasePart") then
				continue
			end

			local v = part2
			pcall(function()
				v.Anchored = true
				v.CanCollide = false
				v.CanTouch = false
				v.CFrame = cframe
			end)
		end
	elseif p == "Beam" then
		pcall(function()
			if self:GetAttribute("_pooledBeamColor") == nil then
				self:SetAttribute("_pooledBeamColor", self.Color)
			end

			if self:GetAttribute("_pooledBeamTransparency") == nil then
				self:SetAttribute("_pooledBeamTransparency", self.Transparency)
			end

			self.Enabled = false
		end)
	elseif p == "PointLight" then
		pcall(function()
			self.Enabled = false
		end)
	elseif p == "Highlight" then
		pcall(function()
			self.Enabled = false
		end)
	elseif p == "TrailEmitter" then
		pcall(function()
			self.Enabled = false
		end)
	elseif p == "ImageLabel" then
		pcall(function()
			self.Visible = false
		end)
	elseif p == "Attachment" then
		disableTrails(self)
		cancelNativeDescendants(self)
	end
end

function PoolHide:show(p)
	if not (self and self.Parent) then
		return
	end

	if p == "Beam" then
		pcall(function()
			local _pooledBeamColor = self:GetAttribute("_pooledBeamColor")

			if _pooledBeamColor ~= nil then
				self.Color = _pooledBeamColor
			end

			self:SetAttribute("_pooledBeamColor", nil)
			local _pooledBeamTransparency = self:GetAttribute("_pooledBeamTransparency")

			if _pooledBeamTransparency ~= nil then
				self.Transparency = _pooledBeamTransparency
			end

			self:SetAttribute("_pooledBeamTransparency", nil)
			self.Enabled = true
		end)
	elseif p == "PointLight" or p == "Highlight" or p == "TrailEmitter" then
		pcall(function()
			self.Enabled = true
		end)
	elseif p == "ImageLabel" then
		pcall(function()
			self.Visible = true
		end)
	end
end

function PoolHide.restoreTrails(p, p2)
	if p and p.Parent and (p2 == "Part" or p2 == "Model" or p2 == "Attachment" or p2 == "Lightning" or p2 == "Rocks" or p2 == "Rope") then
		restoreTrails(p)
	end
end

return PoolHide