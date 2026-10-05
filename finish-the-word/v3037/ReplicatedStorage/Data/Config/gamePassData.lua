local import = _G.import("sync")
_G.import("iterator")
local GamePassData = {
	p1822375917 = {
		Server = function(p, object, _, value)
			if object:processedPass(value or "1822375917") then
				return true
			end

			import.common(p, "itemRepl", "Add", "Chair", "SchoolChair")
			object.Statistics:plus("Cash", 300)
			return true
		end
	},
	p1820865201 = {
		Server = function(instance, object, _, _)
			instance:SetAttribute("VIP", true)

			if not object:processedPass("VipSpecialKeys") then
				object.Statistics:plus("SpecialKey", 10)
				object.ProcessedPasses.VipSpecialKeys = true
			end

			return true
		end,
		Client = function(instance)
			instance:SetAttribute("VIP", true)
		end
	},
	p1860766842 = {
		Server = function(_, _, _, _)
			return true
		end
	},
	p1862924369 = {
		Server = function(_, _, _, _)
			return true
		end
	}
}

for k, v in pairs({
	p1853997082 = "p1822375917",
	p1854105063 = "p1820865201"
}) do
	local v2 = k
	local v3 = v
	local v4 = k
	GamePassData[k] = {
		Server = function(instance, object, p)
			if v2 == "p1854105063" then
				instance:SetAttribute("VIP", true)
			end

			if object:hasPass(v3:sub(2, #v3)) then
				return true
			end

			return GamePassData[v3].Server(instance, object, p, v2:sub(2, #v2))
		end,
		Client = function(instance, p, p2)
			if v4 == "p1854105063" then
				instance:SetAttribute("VIP", true)
			end
		end
	}
end

return GamePassData