return {
	SendOverType = nil,
	AiSkillType = nil,
	ScaleAttribute = function(p: string, value: string?, p2: string?)
		if value ~= nil then
			p = `{p}__{value:gsub("%W", "_")}`
		end

		if p2 == nil then
			return p
		end

		return p .. p2
	end
}