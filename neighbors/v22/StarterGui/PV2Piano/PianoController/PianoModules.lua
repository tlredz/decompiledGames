local CollectionService = game:GetService("CollectionService")
local PianoModules = {
	GetPianoModule = function(self, p)
		return self[p] or self:LoadPianoModule(p)
	end,
	GetPianos = function(items)
		local result = {}

		for k, item in pairs(items) do
			if not (typeof(k) == "Instance" and type(item) == "table") then
				continue
			end

			table.insert(result, k)
		end

		return result
	end,
	GetPianoModules = function(items)
		local result = {}

		for k, item in pairs(items) do
			if not (typeof(k) == "Instance" and type(item) == "table") then
				continue
			end

			table.insert(result, item)
		end

		return result
	end,
	LoadPianoModule = function(self, instance)
		if not self[instance] then
			local pianoModule = instance:FindFirstChild("PianoModule")

			if pianoModule then
				local success, result = pcall(function()
					local v = self
					local module = require(pianoModule)
					v[instance] = module
				end)

				if not success then
					warn(result)
					self[instance] = {}
				end

				return self[instance]
			else
				self[instance] = {}
			end
		end
	end,
	UnloadPianoModule = function(self, p2)
		self[p2] = nil
	end
}

for _, v in ipairs(CollectionService:GetTagged("Piano")) do
	PianoModules:LoadPianoModule(v)
end

CollectionService:GetInstanceAddedSignal("Piano"):Connect(function(p)
	PianoModules:LoadPianoModule(p)
end)
CollectionService:GetInstanceRemovedSignal("Piano"):Connect(function(p)
	PianoModules:UnloadPianoModule(p)
end)
return PianoModules