local TestPlan = require(script.Parent.TestPlan)
return {
	createPlan = function(list, p, p2)
		local v = TestPlan.new(p, p2)
		table.sort(list, function(a, b)
			return a.pathStringForSorting < b.pathStringForSorting
		end)

		for _, v2 in ipairs(list) do
			v:addRoot(v2.path, v2.method)
		end

		return v
	end
}