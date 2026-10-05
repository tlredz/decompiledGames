local import = _G.import("class")
local import2 = _G.import("dictUtil")
local HttpService = game:GetService("HttpService")
local v = import.new()

function v.add(p, p2)
	local GUID = HttpService:GenerateGUID()
	p.Elements[GUID] = p2
	task.delay(p.TimeLimit, function()
		p.Elements[GUID] = nil
	end)
end

function v:sum()
	local total = 0

	for _, element in pairs(self.Elements) do
		total += element
	end

	return total
end

function v:avg()
	return self:sum() / import2.count(self.Elements)
end

function v:new(timeLimit, ...)
	self.TimeLimit = timeLimit
	self.Elements = {}

	for _, v2 in pairs({ ... }) do
		self.Elements[HttpService:GenerateGUID()] = v2
	end
end

return v