local SyncedAnimationController = {}
SyncedAnimationController.__index = SyncedAnimationController

local function ensureAnimator(clone)
	local parent = clone:FindFirstChildOfClass("AnimationController") or clone:FindFirstChildOfClass("Humanoid")

	if not parent then
		parent = Instance.new("AnimationController")
		parent.Parent = clone
	end

	local v2 = parent:FindFirstChildOfClass("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = parent
	end

	return v2
end

function SyncedAnimationController.new(data)
	assert(data and data.template, "SyncedAnimationController: config.template (Model) required")
	assert(
		data.attachTo and data.attachTo:IsA("BasePart"),
		"SyncedAnimationController: config.attachTo (BasePart) required"
	)
	local object = setmetatable({}, SyncedAnimationController)
	object._offset = data.offset or CFrame.new()
	object._cooldown = data.cooldown or 0.25
	object._overlapPolicy = data.overlapPolicy or "cooldown"
	object._hideNames = data.hideWhilePlaying
	object._attachTo = data.attachTo
	object._character = data.attachTo:FindFirstAncestorWhichIsA("Model")
	object._templateScale = data.template:GetScale()
	object._lastPlay = 0
	object._tracks = {}
	object._hidden = {}
	object._destroyed = false
	object._conns = {}
	local clone = data.template:Clone()
	clone.Name = "SyncedRig_" .. data.template.Name
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")

	if primaryPart then
		clone.PrimaryPart = primaryPart

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true

			if not (data.meshTextureOverrides and part:IsA("MeshPart")) then
				continue
			end

			local meshTextureOverride = data.meshTextureOverrides[part.Name]

			if meshTextureOverride then
				part.TextureID = meshTextureOverride
			end
		end

		clone:ScaleTo(object._templateScale * object:_hostScale())
		local _scaledOffset = object:_scaledOffset()
		clone:PivotTo(data.attachTo.CFrame * _scaledOffset)
		local weld = Instance.new("Weld")
		weld.Name = "SyncedRigWeld"
		weld.Part0 = data.attachTo
		weld.Part1 = primaryPart
		weld.C0 = _scaledOffset
		weld.Parent = primaryPart
		clone.Parent = workspace
		object._rig = clone
		object._weld = weld
		object._animator = ensureAnimator(clone)

		if object._animator and data.animationIds then
			for i, animationId in ipairs(data.animationIds) do
				local animation = Instance.new("Animation")
				animation.AnimationId = animationId
				local success, result = pcall(function()
					return object._animator:LoadAnimation(animation)
				end)

				if success and result then
					result.Looped = false
					result.Priority = Enum.AnimationPriority.Action
					object._tracks[i] = result
				else
					warn("[SyncedAnimationController] failed to load anim", i, animationId, result)
				end
			end
		end

		object:_setHidden(true)

		if object._character then
			table.insert(object._conns, object._character.AncestryChanged:Connect(function(_, parent)
				if not parent then
					object:Cleanup()
				end
			end))
		end

		table.insert(object._conns, data.attachTo.AncestryChanged:Connect(function(_, parent)
			if not parent then
				object:Cleanup()
			end
		end))
		table.insert(object._conns, data.attachTo:GetPropertyChangedSignal("Size"):Connect(function()
			object:_matchHostScale()
		end))
		return object
	else
		clone:Destroy()
		warn("[SyncedAnimationController] template has no BasePart/PrimaryPart; aborting")
		return nil
	end
end

function SyncedAnimationController:_hostScale()
	return self._character and self._character:GetScale() or 1
end

function SyncedAnimationController:_scaledOffset()
	return CFrame.new(self._offset.Position * self:_hostScale()) * self._offset.Rotation
end

function SyncedAnimationController:_matchHostScale()
	if self._destroyed or not self._rig then
		return
	end

	local success, result = pcall(function()
		local v = self._templateScale * self:_hostScale()

		if math.abs(self._rig:GetScale() - v) > 0.001 then
			self._rig:ScaleTo(v)
		end

		self._weld.C0 = self:_scaledOffset()
	end)

	if not success then
		warn("[SyncedAnimationController] rescale to host failed:", result)
	end
end

function SyncedAnimationController:_setHidden(p)
	if not (self._hideNames and self._character) then
		return
	end

	if p then
		for _, _hideName in ipairs(self._hideNames) do
			for _, part in ipairs(self._character:GetDescendants()) do
				if not (part.Name == _hideName and part:IsA("BasePart") and self._hidden[part] == nil) then
					continue
				end

				self._hidden[part] = part.Transparency
				part.Transparency = 1
			end
		end
	else
		for k, transparency in pairs(self._hidden) do
			if k and k.Parent then
				k.Transparency = transparency
			end
		end

		table.clear(self._hidden)
	end
end

function SyncedAnimationController:Play(p)
	if self._destroyed then
		return nil
	end

	local _track = self._tracks[p]

	if not _track then
		return nil
	end

	local now = os.clock()

	if self._overlapPolicy == "cooldown" then
		if now - self._lastPlay < self._cooldown then
			return nil
		end
	elseif self._overlapPolicy == "restart" then
		for _, _track2 in pairs(self._tracks) do
			if _track2.IsPlaying then
				_track2:Stop(0.05)
			end
		end
	elseif self._overlapPolicy == "single" then
		for _, _track2 in pairs(self._tracks) do
			if _track2.IsPlaying then
				return nil
			end
		end
	end

	self._lastPlay = now
	_track:Play()
	return p
end

function SyncedAnimationController:PlayRandom()
	if self._destroyed then
		return nil
	end

	local count = #self._tracks

	if count == 0 then
		return nil
	end

	return self:Play(math.random(1, count))
end

function SyncedAnimationController:SetOverlapPolicy(overlapPolicy)
	if overlapPolicy then
		self._overlapPolicy = overlapPolicy
	end
end

function SyncedAnimationController:Cleanup()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, _conn in ipairs(self._conns) do
		local connection = _conn
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(self._conns)

	for _, _track in pairs(self._tracks) do
		local v = _track
		pcall(function()
			v:Stop(0)
		end)
		local v2 = _track
		pcall(function()
			v2:Destroy()
		end)
	end

	table.clear(self._tracks)
	self:_setHidden(false)

	if self._rig then
		pcall(function()
			self._rig:Destroy()
		end)
		self._rig = nil
	end
end

return SyncedAnimationController