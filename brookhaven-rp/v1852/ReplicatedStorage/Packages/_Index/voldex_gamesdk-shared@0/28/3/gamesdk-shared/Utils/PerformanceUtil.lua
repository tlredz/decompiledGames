local v = {
	sum = 0,
	amount = 0,
	min = nil,
	max = nil
}

local function shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local PerformanceUtil = {}

function PerformanceUtil.NewBlankRecord()
	local result = {}

	for k, v3 in pairs(v) do
		result[k] = v3
	end

	return result
end

function PerformanceUtil:Append(p: number)
	self.sum += p
	self.amount += 1
	self.min = math.min(self.min or p, p)
	self.max = math.max(self.max or p, p)
end

function PerformanceUtil.GetAverage(p)
	return p.sum / p.amount
end

return PerformanceUtil