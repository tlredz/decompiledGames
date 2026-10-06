local v = {
	Preparing = true,
	Launching = true,
	Active = true,
	Ending = true
}
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = {}

local function ValidateInfo(data)
	if typeof(data) ~= "table" or data.Enabled ~= true or (not v2.IsFinite(data.Cooldown) or data.Cooldown < 0) then
		return false
	end

	if typeof(data.Phases) ~= "table" or #data.Phases == 0 then
		return false
	end

	local total = 0

	for _, phas in data.Phases do
		if typeof(phas) ~= "table" or not v[phas.Name] or (not v2.IsFinite(phas.Duration) or phas.Duration <= 0) then
			return false
		end

		total += phas.Duration
		local movement = phas.Movement

		if movement then
			if typeof(movement) ~= "table" or movement.Mode ~= nil and movement.Mode ~= "Free" and movement.Mode ~= "Slowed" and movement.Mode ~= "Locked" then
				return false
			end

			if movement.Mode == "Slowed" and (not v2.IsFinite(movement.SpeedMultiplier) or movement.SpeedMultiplier <= 0 or movement.SpeedMultiplier >= 1) then
				return false
			end
		end

		local damage = phas.Damage

		if damage then
			if typeof(damage) ~= "table" or (not v2.IsFinite(damage.Amount) or damage.Amount <= 0) then
				return false
			end

			if not v2.IsFinite(damage.Interval) or damage.Interval < 0.05 or damage.Mode ~= nil and damage.Mode ~= "Ball" and damage.Mode ~= "Block" then
				return false
			end

			if damage.Immediate ~= nil and typeof(damage.Immediate) ~= "boolean" then
				return false
			end

			if damage.Mode == "Block" then
				local size = damage.Size

				if typeof(size) ~= "Vector3" then
					return false
				end

				if v2.IsFinite(size.X) and v2.IsFinite(size.Y) and v2.IsFinite(size.Z) then
					if size.X <= 0 or size.Y <= 0 or size.Z <= 0 then
						return false
					end
				else
					return false
				end
			else
				if not v2.IsFinite(damage.Radius) or damage.Radius <= 0 then
					return false
				end

				if damage.EndRadius ~= nil and (not v2.IsFinite(damage.EndRadius) or damage.EndRadius < 0) then
					return false
				end
			end

			if damage.Offset ~= nil and typeof(damage.Offset) ~= "CFrame" then
				return false
			end

			local offsets = { damage.Offset or CFrame.identity }

			if damage.Offsets ~= nil then
				if typeof(damage.Offsets) ~= "table" or #damage.Offsets == 0 then
					return false
				end

				for _, offset in damage.Offsets do
					table.insert(offsets, offset)
				end
			end

			for _, cframe in offsets do
				if typeof(cframe) ~= "CFrame" then
					return false
				end

				for _, v3 in { cframe:GetComponents() } do
					if not v2.IsFinite(v3) then
						return false
					end
				end
			end
		end

		if phas.Speed ~= nil and (not v2.IsFinite(phas.Speed) or phas.Speed < 0) then
			return false
		end
	end

	if data.Sounds == nil then
		return total <= 120
	end

	if typeof(data.Sounds) ~= "table" then
		return false
	end

	for _, sound in data.Sounds do
		if typeof(sound) ~= "table" or typeof(sound.Name) ~= "string" or sound.Name == "" then
			return false
		end

		if not v2.IsFinite(sound.Time) or sound.Time < 0 then
			return false
		end

		if sound.Count ~= nil and (not v2.IsFinite(sound.Count) or sound.Count < 1 or sound.Count % 1 ~= 0) then
			return false
		end

		if sound.Variants ~= nil and (not v2.IsFinite(sound.Variants) or sound.Variants < 1 or sound.Variants % 1 ~= 0) then
			return false
		end

		if (sound.Count or 1) > 1 and (not v2.IsFinite(sound.Interval) or sound.Interval <= 0) then
			return false
		end
	end

	return total <= 120
end

function v2.IsFinite(value)
	return typeof(value) == "number" and math.isfinite(value)
end

function v2.Direction(data, vector: Vector3?)
	if typeof(data) ~= "Vector3" then
		return nil
	end

	if not (v2.IsFinite(data.X) and v2.IsFinite(data.Y) and v2.IsFinite(data.Z)) then
		return nil
	end

	local vector2 = Vector3.new(data.X, 0, data.Z)

	if vector2.Magnitude > 0.0001 and v2.IsFinite(vector2.Magnitude) then
		return vector2.Unit
	end

	if vector then
		return v2.Direction(vector)
	end

	return nil
end

function v2.Validate(p)
	if typeof(p) ~= "table" then
		return false
	end

	local v3 = object[p]

	if v3 == nil then
		v3 = ValidateInfo(p)
		object[p] = v3
	end

	return v3
end

function v2.GetDuration(p)
	local total = 0

	for _, phas in p.Phases do
		total += phas.Duration or 0
	end

	return total
end

function v2.GetSoundTimeline(p)
	local result = {}

	for _, v3 in p.Sounds or {} do
		for i = 1, v3.Count or 1 do
			local name

			if v3.Variants then
				name = v3.Name .. (i - 1) % v3.Variants + 1
			else
				name = v3.Name
			end

			table.insert(result, {
				Name = name,
				Time = v3.Time + (i - 1) * (v3.Interval or 0)
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Time < b.Time
	end)
	return result
end

function v2.GetProgress(p: number, p2: number, p3: number)
	local v3 = math.max(0, p - p3)
	return not (p2 > 0) and 1 or 1 - math.clamp(v3 / p2, 0, 1), v3
end

return table.freeze(v2)