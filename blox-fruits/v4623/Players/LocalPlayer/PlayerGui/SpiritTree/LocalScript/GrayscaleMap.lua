local GrayscaleMap = {}
GrayscaleMap.__index = GrayscaleMap

function GrayscaleMap.new(maps)
	local v = {
		OriginalColors = {},
		ActiveTasks = {},
		Maps = maps
	}
	setmetatable(v, GrayscaleMap)

	for _, folder in ipairs(maps) do
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				v.OriginalColors[part] = part.Color
			end
		end

		local v2 = folder
		folder.AttributeChanged:Connect(function(p)
			v:Refresh(v2)
		end)
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTargetColor(originalColor: Color3)
	local HSV, _, v = originalColor:ToHSV()
	return Color3.fromHSV(HSV, 0, v):Lerp(Color3.new(0, 0, 0), 0.3)
end

local function fadeParts(list, color: Color3, color2: Color3)
	local total = 0

	while total < 1 do
		total += 0.1
		local lerped = color:Lerp(color2, (math.min(total, 1)))

		for _, v in ipairs(list) do
			v.Color = lerped
		end

		task.wait(0.1)
	end

	for _, v in ipairs(list) do
		v.Color = color2
	end
end

local function cleanupStacks(ancestor)
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v in pairs(ancestor:GetAttributes()) do
		if not (k:match("^GrayscaleStack%d+$") and typeof(v) == "NumberRange" and v.Max < serverTimeNow) then
			continue
		end

		ancestor:SetAttribute(k, nil)
	end
end

local function isGrayscaleNow(ancestor)
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v in pairs(ancestor:GetAttributes()) do
		if k:match("^GrayscaleStack%d+$") and typeof(v) == "NumberRange" and v.Min <= serverTimeNow and serverTimeNow <= v.Max then
			return true
		end
	end

	return false
end

local function getNextFlipTime(ancestor, grayscaleNow: boolean)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = nil

	for k, v2 in pairs(ancestor:GetAttributes()) do
		if not (k:match("^GrayscaleStack%d+$") and typeof(v2) == "NumberRange") then
			continue
		end

		if grayscaleNow then
			if serverTimeNow < v2.Max then
				v = v and math.min(v, v2.Max) or v2.Max
			end
		elseif serverTimeNow < v2.Min then
			v = v and math.min(v, v2.Min) or v2.Min
		end
	end

	return v
end

function GrayscaleMap:Refresh(ancestor)
	if self.ActiveTasks[ancestor] then
		task.cancel(self.ActiveTasks[ancestor])
		self.ActiveTasks[ancestor] = nil
	end

	cleanupStacks(ancestor)
	local thread = task.spawn(function()
		local grayscaleNow = isGrayscaleNow(ancestor)
		local nextFlipTime = getNextFlipTime(ancestor, grayscaleNow)

		if nextFlipTime and workspace:GetServerTimeNow() < nextFlipTime then
			task.wait(nextFlipTime - workspace:GetServerTimeNow())
			cleanupStacks(ancestor)
			grayscaleNow = isGrayscaleNow(ancestor)
		end

		local v = {}

		for k, _ in pairs(self.OriginalColors) do
			if k:IsDescendantOf(ancestor) then
				table.insert(v, k)
			end
		end

		for _, v2 in ipairs(v) do
			local originalColor = self.OriginalColors[v2]

			if grayscaleNow then
				originalColor = getTargetColor(originalColor)
			end

			fadeParts({ v2 }, v2.Color, originalColor)
		end
	end)
	self.ActiveTasks[ancestor] = thread
end

return GrayscaleMap