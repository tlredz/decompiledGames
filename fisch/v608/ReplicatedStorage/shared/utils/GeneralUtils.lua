local createVector = vector.create
local TweenService = game:GetService("TweenService")
local GeneralUtils = {}
local random = Random.new()
local RunService = game:GetService("RunService")
local v = not RunService:IsStudio() and game.GameId == 5750914919

function GeneralUtils.getRandomByPercentage(items, value: number?, value2: number?)
	if not v and value2 == nil then
		local total = 0
		local v2 = 0.1

		for _, item in items do
			total += item
			v2 = math.min(v2, item)
		end

		if v2 <= math.abs(total - 100) then
			warn("GeneralUtils.getRandomByPercentage() called without maxWeight when weights do not add up to 100. This will result in undefined behavior.")
			print(debug.traceback())
		end
	end

	local number = random:NextNumber(value or 0, value2 or 100)
	local v2 = nil
	local total = 0
	local v3 = nil

	for k, item in pairs(items) do
		v2 = v2 or k

		if total < number and number <= total + item then
			v3 = k
		end

		total += item
	end

	return v3 or v2
end

function GeneralUtils.getRandomByWeight(items)
	local clone = table.clone(items)
	local total = 0

	for k, item in items do
		if typeof(item) == "number" and not (item <= 0) then
			total += item
		else
			clone[k] = nil
		end
	end

	if total == 0 then
		return nil
	end

	local number = random:NextNumber(0, total)
	local v2 = nil
	local total2 = 0
	local v3 = nil

	for k, v4 in clone do
		v2 = v2 or k

		if total2 < number and number <= total2 + v4 then
			v3 = k
		end

		total2 += v4
	end

	return v3 or v2
end

function GeneralUtils.getRandomPartByWeight(instance)
	if not instance then
		return nil
	end

	local children = instance:GetChildren()
	local magnitudesByPart = {}
	local total = 0

	for _, folder in pairs(children) do
		if not folder:IsA("Folder") then
			continue
		end

		for _, part in folder:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			magnitudesByPart[part] = part.Size.Magnitude
			total += part.Size.Magnitude
		end
	end

	return (GeneralUtils.getRandomByPercentage(magnitudesByPart, 0, total))
end

function GeneralUtils.isInsidePart(part, vector2: Vector3, options)
	if not (part and part:IsA("BasePart")) then
		return false
	end

	local v2 = options or {}
	local size = part.Size
	local v3 = size.X / 2
	local v4 = size.Y / 2
	local v5 = size.Z / 2
	local position = part.Position
	local v6 = position.X - v3
	local v7 = position.X + v3
	local v8 = position.Y - v4
	local v9 = position.Y + v4
	local v10 = position.Z - v5
	local v11 = position.Z + v5
	local X = v2.X

	if not X then
		if v6 <= vector2.X then
			X = vector2.X <= v7
		else
			X = false
		end
	end

	local Y = v2.Y

	if not Y then
		if v8 <= vector2.Y then
			Y = vector2.Y <= v9
		else
			Y = false
		end
	end

	local Z = v2.Z

	if not Z then
		if v10 <= vector2.Z then
			Z = vector2.Z <= v11
		else
			Z = false
		end
	end

	return X and Y and Z
end

function GeneralUtils.isInsideRegion(vector2: Vector3, instance)
	local v2 = (instance.CFrame:PointToObjectSpace(vector2) - instance.CFrame:PointToObjectSpace(instance.CFrame.Position)) / instance.Size
	return v2.X >= -0.5 and v2.X <= 0.5 and v2.Y >= -0.5 and v2.Y <= 0.5 and v2.Z >= -0.5 and v2.Z <= 0.5
end

function GeneralUtils.nBezier(list, p: number)
	local count = #list
	local clone = table.clone(list)

	for i = 1, count - 1 do
		for i2 = 1, count - i do
			clone[i2] = (1 - p) * clone[i2] + p * clone[i2 + 1]
		end
	end

	return clone[1]
end

function GeneralUtils.normalizeInRange(p: number, p2: number, p3: number)
	return (p - p2) / (p3 - p2)
end

function GeneralUtils.percentageBetweenRange(p: number, p2: number, p3: number, value: number?)
	return p * (p3 - p2) / (value or 100) + p2
end

function GeneralUtils.fastTween(p, p2, p3, p4)
	local tween = TweenService:Create(p, p2, p3)

	if p4 ~= false then
		tween:Play()
	end

	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

function GeneralUtils.scaleTween(instance, p, p2, p3, p4)
	local numberPose = Instance.new("NumberPose")
	numberPose.Value = p4 or instance:GetScale()
	local tween = TweenService:Create(numberPose, p, {
		Value = p2
	})
	numberPose:GetPropertyChangedSignal("Value"):Connect(function()
		instance:ScaleTo((math.clamp(numberPose.Value, 0.001, 1e999)))
	end)

	if p3 ~= false then
		tween:Play()
	end

	tween.Completed:Connect(function()
		numberPose:Destroy()
		tween:Destroy()
	end)
	tween.Destroying:Connect(function()
		numberPose:Destroy()
	end)
	return tween
end

function GeneralUtils.pivotTween(instance, p, p2, p3, p4)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local tween = TweenService:Create(cFrameValue, p, {
		Value = p2
	})
	cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		instance:PivotTo(cFrameValue.Value)
	end)

	if p3 ~= false then
		tween:Play()
	end

	if not p4 then
		tween.Completed:Once(function()
			cFrameValue:Destroy()
			tween:Destroy()
		end)
	end

	tween.Destroying:Once(function()
		cFrameValue:Destroy()
	end)
	return tween
end

function GeneralUtils:gradientTween(p, items, p2, p3)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local tween = TweenService:Create(numberValue, p, {
		Value = 1
	})
	local v2 = {}
	local keypoints = {}

	for k in items do
		v2[k] = self[k]
		keypoints[k] = self[k].Keypoints
	end

	numberValue.Changed:Connect(function(p4)
		for k, item in items do
			for k2, keypoint in item.Keypoints do
				local keypoint2 = v2[k].Keypoints[k2]
				keypoints[k][k2] = ColorSequenceKeypoint.new(keypoint.Time, keypoint2.Value:Lerp(keypoint.Value, p4))
			end

			self[k] = ColorSequence.new(keypoints[k])
		end
	end)

	if p2 ~= false then
		tween:Play()
	end

	if not p3 then
		tween.Completed:Once(function()
			tween:Destroy()
			task.wait()
			numberValue:Destroy()
		end)
	end

	tween.Destroying:Once(function()
		task.wait()
		numberValue:Destroy()
	end)
	return tween
end

function GeneralUtils.secondsConverter(value, p, p2)
	if typeof(value) ~= "number" then
		return nil
	end

	if value >= 86400 or p == "Days" then
		if p2 then
			return value / 3600 / 24, value / 3600 % 24, value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i:%02i:%02i", value / 3600 / 24, value / 3600 % 24, value / 60 % 60, value % 60)
	elseif value >= 3600 and value < 86400 or p == "Hours" then
		if p2 then
			return value / 3600 % 24, value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i:%02i", value / 3600 % 24, value / 60 % 60, value % 60)
	elseif value < 3600 then
		if p2 then
			return value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i", value / 60 % 60, value % 60)
	else
		return nil
	end
end

function GeneralUtils.copy(p, flag: boolean?)
	if typeof(p) ~= "table" then
		return p
	end

	if not flag then
		return (table.clone(p))
	end

	debug.profilebegin("GeneralUtils.copy")
	local deepCopy

	deepCopy = function(p2)
		local clone = table.clone(p2)

		for k, v2 in clone do
			if type(v2) == "table" then
				clone[k] = deepCopy(v2)
			end
		end

		return clone
	end

	local v2 = deepCopy(p)
	debug.profileend()
	return v2
end

function GeneralUtils:applyProperties(items)
	for childName, item in pairs(items) do
		if self:FindFirstChild(childName) and typeof(item) == "table" then
			GeneralUtils.applyProperties(self[childName], item)
		elseif GeneralUtils.hasProperty(self, childName) then
			self[childName] = item
		end
	end
end

local applyTableRecurse

applyTableRecurse = function(copy, items, flag: boolean?, flag2: boolean?)
	if not items then
		return copy
	end

	if not flag then
		copy = GeneralUtils.copy(copy, true)
	end

	for k, item in pairs(items) do
		if typeof(item) == "table" then
			if item._o == nil or flag2 == true then
				if copy[k] and typeof((next(item))) ~= "number" then
					applyTableRecurse(copy[k], item, true, flag2)
				else
					copy[k] = applyTableRecurse({}, item, true, flag2)
				end
			elseif item._o == 0 then
				copy[k] = nil
			elseif item._o == 1 then
				copy[k] = (copy[k] or 0) + item._v
			elseif item._o == 2 then
				copy[k] = (copy[k] or 0) - item._v
			elseif item._o == 3 then
				copy[k] = (copy[k] or 0) * item._v
			elseif item._o == 4 then
				copy[k] = (copy[k] or 0) / item._v
			elseif item._o == 5 then
				copy[k] = math.pow(copy[k] or 0, item._v)
			elseif item._o == 6 then
				copy[k] = (copy[k] or "") .. tostring(item._v)
			elseif item._o == 7 then
				if copy[k] == nil then
					copy[k] = GeneralUtils.copy(item._v, true)
				end
			elseif item._o == 8 then
				copy[k] = GeneralUtils.copy(item._v[copy[k]] or item._d, true)
			elseif item._o == 9 then
				if copy[k] ~= nil then
					copy[k] = GeneralUtils.copy(item._v, true)
				end
			elseif item._o == 10 then
				if copy[k] == nil then
					copy[k] = GeneralUtils.copy(item._v, true)
				else
					for _, v2 in ipairs(item._v) do
						if item._e ~= true or table.find(copy[k], v2) == nil then
							table.insert(copy[k], GeneralUtils.copy(v2, true))
						end
					end
				end
			elseif item._o == 11 then
				if copy[k] ~= nil then
					for _, v2 in ipairs(item._v) do
						local index = table.find(copy[k], v2)

						if index ~= nil then
							table.remove(copy[k], index)
						end
					end
				end
			elseif item._o == 12 then
				copy[k] = GeneralUtils.copy(item._v[copy[item._k]] or item._d, true)
			else
				copy[k] = GeneralUtils.copy(item, true)
			end
		else
			copy[k] = item
		end
	end

	return copy
end

function GeneralUtils.applyTable(p, p2, p3, p4)
	debug.profilebegin("GeneralUtils.applyTable")
	local v2 = applyTableRecurse(p, p2, p3, p4)
	debug.profileend()
	return v2
end

function GeneralUtils.hasProperty(p, p2)
	return (pcall(function()
		return p[p2]
	end))
end

function GeneralUtils.incrementAttribute(instance, attributeName, value, value2, value3)
	if instance and attributeName then
		local v2 = math.clamp((instance:GetAttribute(attributeName) or 0) + (value or 1), value2 or 0, value3 or 1e999)
		instance:SetAttribute(attributeName, v2)
		return v2
	else
		return nil
	end
end

function GeneralUtils.safeUnit(vector2: Vector3)
	local unit = vector2.Unit

	if math.isfinite(unit.X) and math.isfinite(unit.Y) and math.isfinite(unit.Z) then
		return unit
	end

	return createVector(0, 0, 0)
end

function GeneralUtils.safeUnit2(point: Vector2)
	local unit = point.Unit

	if math.isfinite(unit.X) and math.isfinite(unit.Y) then
		return unit
	end

	return Vector2.zero
end

return GeneralUtils