local Range = require(script.Parent.Range)
local Particles = {}

local function parseDuration(emitDuration)
	if emitDuration == nil then
		return nil
	end

	if typeof(emitDuration) == "number" then
		return emitDuration
	end

	local v = {}

	for k in tostring(emitDuration):gmatch("[^,]+") do
		local v2 = tonumber(k:match("^%s*(.-)%s*$"))

		if v2 then
			table.insert(v, v2)
		end
	end

	if #v == 0 then
		return nil
	end

	if #v == 1 then
		return v[1]
	end

	local v2 = math.min(v[1], v[2])
	local v3 = math.max(v[1], v[2])
	return Range.RandomValueFromRange(NumberRange.new(v2, v3))
end

Particles.parseDuration = parseDuration

local function _hasTransformedAncestor(effect, folder)
	local parent = effect.Parent

	while parent and parent ~= folder do
		if parent:GetAttribute("Transformed") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function _alive(callback)
	return not callback or callback()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _readCancelGen(effect)
	return effect:GetAttribute("_PartIcleNativeEmitGen") or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _bumpCancelGen(instance)
	local v = (instance:GetAttribute("_PartIcleNativeEmitGen") or 0) + 1
	pcall(function()
		instance:SetAttribute("_PartIcleNativeEmitGen", v)
	end)
	return v
end

local function _cancelGenStillCurrent(instance, p)
	return instance.Parent ~= nil and (instance:GetAttribute("_PartIcleNativeEmitGen") or 0) == p
end

local function _readDurationGen(instance)
	return instance:GetAttribute("_PartIcleNativeDurationGen") or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _bumpDurationGen(instance)
	local v = (instance:GetAttribute("_PartIcleNativeDurationGen") or 0) + 1
	pcall(function()
		instance:SetAttribute("_PartIcleNativeDurationGen", v)
	end)
	return v
end

local function _durationGenStillCurrent(instance, p)
	return instance.Parent ~= nil and (instance:GetAttribute("_PartIcleNativeDurationGen") or 0) == p
end

function Particles:SetEnabledForDuration(duration)
	local v = _bumpDurationGen(self) -- equivalent call inferred; original call site unknown
	self.Enabled = true
	task.delay(duration, function()
		local v2 = self
		local v3 = v
		local v4

		if v2.Parent == nil then
			v4 = false
		else
			v4 = (v2:GetAttribute("_PartIcleNativeDurationGen") or 0) == v3
		end

		if v4 then
			self.Enabled = false
		end
	end)
end

Particles.ReadNativeGen = _readCancelGen
Particles.IsNativeGenCurrent = _cancelGenStillCurrent

function Particles:CancelNative()
	_bumpCancelGen(self) -- equivalent call inferred; original call site unknown
	_bumpDurationGen(self) -- equivalent call inferred; original call site unknown
	pcall(function()
		self.Enabled = false
	end)
end

function Particles.EnableEmit(folder, p)
	for _, effect in folder:GetDescendants() do
		if _hasTransformedAncestor(effect, folder) then
			continue
		end

		if effect:IsA("ParticleEmitter") then
			local emitCount = effect:GetAttribute("EmitCount") or 1
			local emitDelay = effect:GetAttribute("EmitDelay") or 0
			local emitDuration = effect:GetAttribute("EmitDuration") or 0

			if emitCount <= 0 and emitDuration <= 0 then
				continue
			end

			local v = _readCancelGen(effect) -- equivalent call inferred; original call site unknown
			local v2 = effect

			local function doEmit()
				if not p or p() then
					local v7 = v2
					local v8 = v
					local v9

					if v7.Parent == nil then
						v9 = false
					else
						v9 = (v7:GetAttribute("_PartIcleNativeEmitGen") or 0) == v8
					end

					if v9 then
						if emitCount > 0 then
							v2:Emit(emitCount)
						end

						if emitDuration > 0 then
							local v11 = _bumpDurationGen(v2) -- equivalent call inferred; original call site unknown
							v2.Enabled = true
							task.delay(emitDuration, function()
								local v12 = v2
								local v13 = v11
								local v14

								if v12.Parent == nil then
									v14 = false
								else
									v14 = (v12:GetAttribute("_PartIcleNativeDurationGen") or 0) == v13
								end

								if v14 then
									v2.Enabled = false
								end
							end)
						end
					end
				end
			end

			if emitDelay > 0 then
				task.delay(emitDelay, doEmit)
			else
				doEmit()
			end
		end

		if effect:IsA("Trail") and not effect:GetAttribute("Transformed") then
			local v = parseDuration(effect:GetAttribute("EmitDuration"))

			if v and v > 0 then
				local v2 = _readCancelGen(effect) -- equivalent call inferred; original call site unknown
				local v3 = effect
				local v5 = v
				task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
					if not p or p() then
						local v7 = v3
						local v8 = v2
						local v9

						if v7.Parent == nil then
							v9 = false
						else
							v9 = (v7:GetAttribute("_PartIcleNativeEmitGen") or 0) == v8
						end

						if v9 then
							local v11 = _bumpDurationGen(v3) -- equivalent call inferred; original call site unknown
							v3.Enabled = true
							task.delay(v5, function()
								local v12 = v3
								local v13 = v11
								local v14

								if v12.Parent == nil then
									v14 = false
								else
									v14 = (v12:GetAttribute("_PartIcleNativeDurationGen") or 0) == v13
								end

								if v14 then
									v3.Enabled = false
								end
							end)
						end
					end
				end)
			end
		end

		if not effect:IsA("Beam") or effect:GetAttribute("Transformed") then
			continue
		end

		local emitDuration = tonumber(effect:GetAttribute("EmitDuration")) or 0
		local emitDelay = tonumber(effect:GetAttribute("EmitDelay")) or 0

		if not (emitDuration > 0) then
			continue
		end

		local v = _readCancelGen(effect) -- equivalent call inferred; original call site unknown
		local v2 = effect
		local v4 = emitDuration

		local function doEmit()
			if not p or p() then
				local v6 = v2
				local v7 = v
				local v8

				if v6.Parent == nil then
					v8 = false
				else
					v8 = (v6:GetAttribute("_PartIcleNativeEmitGen") or 0) == v7
				end

				if v8 then
					local v10 = _bumpDurationGen(v2) -- equivalent call inferred; original call site unknown
					v2.Enabled = true
					task.delay(v4, function()
						local v11 = v2
						local v12 = v10
						local v13

						if v11.Parent == nil then
							v13 = false
						else
							v13 = (v11:GetAttribute("_PartIcleNativeDurationGen") or 0) == v12
						end

						if v13 then
							v2.Enabled = false
						end
					end)
				end
			end
		end

		if emitDelay > 0 then
			task.delay(emitDelay, doEmit)
		else
			doEmit()
		end
	end
end

function Particles:EnableEmitSingle(p)
	if self:IsA("Trail") then
		local v = parseDuration(self:GetAttribute("EmitDuration"))

		if v and v > 0 then
			local v2 = _readCancelGen(self) -- equivalent call inferred; original call site unknown
			local emitDelay = self:GetAttribute("EmitDelay") or 0

			local function doEnable()
				if not p or p() then
					local v4 = self
					local v5 = v2
					local v6

					if v4.Parent == nil then
						v6 = false
					else
						v6 = (v4:GetAttribute("_PartIcleNativeEmitGen") or 0) == v5
					end

					if v6 then
						local v8 = _bumpDurationGen(self) -- equivalent call inferred; original call site unknown
						self.Enabled = true
						task.delay(v, function()
							local v9 = self
							local v10 = v8
							local v11

							if v9.Parent == nil then
								v11 = false
							else
								v11 = (v9:GetAttribute("_PartIcleNativeDurationGen") or 0) == v10
							end

							if v11 then
								self.Enabled = false
							end
						end)
					end
				end
			end

			if emitDelay > 0 then
				task.delay(emitDelay, doEnable)
			else
				doEnable()
			end
		end
	end

	if self:IsA("ParticleEmitter") then
		local emitCount = self:GetAttribute("EmitCount") or 1
		local emitDelay = self:GetAttribute("EmitDelay") or 0
		local emitDuration = self:GetAttribute("EmitDuration") or 0

		if emitCount <= 0 and emitDuration <= 0 then
			return
		end

		local v = _readCancelGen(self) -- equivalent call inferred; original call site unknown

		local function doEmit()
			if not p or p() then
				local v3 = self
				local v4 = v
				local v5

				if v3.Parent == nil then
					v5 = false
				else
					v5 = (v3:GetAttribute("_PartIcleNativeEmitGen") or 0) == v4
				end

				if v5 then
					if emitCount > 0 then
						self:Emit(emitCount)
					end

					if emitDuration > 0 then
						local v7 = _bumpDurationGen(self) -- equivalent call inferred; original call site unknown
						self.Enabled = true
						task.delay(emitDuration, function()
							local v8 = self
							local v9 = v7
							local v10

							if v8.Parent == nil then
								v10 = false
							else
								v10 = (v8:GetAttribute("_PartIcleNativeDurationGen") or 0) == v9
							end

							if v10 then
								self.Enabled = false
							end
						end)
					end
				end
			end
		end

		if emitDelay > 0 then
			task.delay(emitDelay, doEmit)
		else
			doEmit()
		end
	end
end

function Particles.EnableEmitChildrenAndRepeatForAttachments(instance, p)
	for _, attachment in instance:GetChildren() do
		Particles.EnableEmitSingle(attachment, p)

		if attachment:IsA("Attachment") then
			Particles.EnableEmitChildrenAndRepeatForAttachments(attachment, p)
		end
	end
end

return Particles