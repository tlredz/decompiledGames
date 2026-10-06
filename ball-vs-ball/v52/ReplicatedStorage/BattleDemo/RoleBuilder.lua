local BallVisualRegistry = require(script.Parent.BallVisualRegistry)
local v = {
	[""] = true,
	["无"] = true,
	x = true
}

local function buildCnIdToTraitId(items)
	local result = {}

	for k, item in items do
		if typeof(item.cnId) == "string" then
			result[item.cnId] = k
		end
	end

	return result
end

return {
	build = function(p, p2)
		local result = {}
		local cnIds = {}
		local cnIds2 = {}
		local cnIds3 = {}

		if typeof(p2) ~= "table" or typeof(p2.list) ~= "table" then
			warn("[RoleBuilder] 飞书 ball 配置为空，rolePool 将为空")
			return result, cnIds, cnIds2, cnIds3
		end

		local cnIdToTraitId = buildCnIdToTraitId(p)

		for _, v2 in p2.list do
			local v3

			if typeof(v2.skills) == "table" then
				v3 = v2.skills[1]
			else
				v3 = false
			end

			local v4, clone

			if v3 == nil or v[v3] then
				v4 = {}
				clone = {
					name = "无",
					trigger = "None"
				}
			else
				local v5

				if typeof(v3) == "string" then
					v5 = cnIdToTraitId[v3]
				else
					v5 = false
				end

				if not v5 then
					warn((`[RoleBuilder] 跳过球 {tostring(v2.cnId)}: 技能 {tostring(v3)} 未在代码里登记(behaviorKey 缺失)`))
					continue
				end

				v4 = p[v5]
				clone = table.clone(v4)
				clone.name = v4.displayName
				clone.trigger = v4.behaviorKey
				clone.displayName = nil
				clone.behaviorKey = nil
				clone.cnId = nil
			end

			local v5 = BallVisualRegistry.get(v2.cnId)
			result[v2.cnId] = {
				roleId = v2.cnId,
				displayName = v2.displayName,
				displayNameCN = v2.displayNameCN,
				color = v5.color,
				highlightColor = v5.highlightColor,
				radius = v2.radius,
				templateName = v2.assetName,
				maxHp = v2.maxHp,
				attack = v4.attack or 0,
				speed = v2.speed,
				skill = clone
			}
			table.insert(cnIds, v2.cnId)

			if v2.canPlayerUse then
				table.insert(cnIds2, v2.cnId)
			end

			if v2.canAnalyze then
				table.insert(cnIds3, v2.cnId)
			end
		end

		return result, cnIds, cnIds2, cnIds3
	end
}