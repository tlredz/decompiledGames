local BallCopySelection = require(script.Parent.BallCopySelection)
return {
	resolve = function(items, p, options)
		local v = {}
		local v2 = {}
		local v3 = type(p) ~= "table" and {} or p
		local v4 = options or {}

		for k, item in items do
			if item.itemType ~= "Ball" then
				continue
			end

			local v5 = v2[item.itemId]

			if not v5 then
				v5 = {}
				v2[item.itemId] = v5
			end

			v5[k] = item
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mark(p2)
			local v5 = p2 and items[p2]

			if v5 and BallCopySelection.available(v5) and not v4[v5.instanceId or p2] then
				v[v5.instanceId or p2] = true
			end
		end

		for k, v5 in v2 do
			mark(BallCopySelection.resolve(v5, v3, k)) -- equivalent call inferred; original call site unknown
		end

		for _, v5 in { "爆炸特效", "飞行器" } do
			local v6 = v3[v5]

			if not (v6 and items[v6] and items[v6].itemType == v5) then
				continue
			end

			mark(v6) -- equivalent call inferred; original call site unknown
		end

		return v
	end
}