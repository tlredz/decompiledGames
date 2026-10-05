local AI = script.Parent.Parent.Parent.AI
require(AI.Types)
local ConfigHandler = require(AI.ConfigHandler)
local Defaults = require(AI.ConfigHandler.Defaults)
local PathfindingProcessor = require(AI.PathfindingProcessor)
local v = {
	NodeTableExpander = function(part)
		local result = {}

		local function searchInstance(folder)
			for _, descendant in pairs(folder:GetDescendants()) do
				if not descendant:IsA("BasePart") or descendant:IsA("Model") then
					continue
				end

				local flag = true
				local v2

				for _, v3 in pairs(result) do
					if v3 ~= descendant then
						continue
					end

					v2 = true
					flag = false
					break
				end

				if flag then
					v2 = false
				end

				if not v2 then
					table.insert(result, descendant)
				end
			end
		end

		if typeof(part) == "Instance" then
			if part:IsA("BasePart") then
				table.insert(result, part)
			end

			searchInstance(part)
		end

		if typeof(part) == "table" then
			for _, item in pairs(part) do
				searchInstance(item)
			end
		end

		return result
	end,
	CheckPath = function(p, p2, p3)
		local v2

		if p ~= nil then
			v2 = ConfigHandler.GetActiveConfig(p)
		end

		if p == nil then
			v2 = Defaults
		end

		return PathfindingProcessor.RawCompute(p2.CFrame.Position, p3.CFrame.Position, v2.AgentInfo) ~= nil
	end
}

function v.DetectBadPaths(p, p2, flag: boolean?)
	local v2 = Defaults

	if p2 ~= nil then
		v2 = ConfigHandler.GetActiveConfig(p2)
	end

	if v2 == nil then
		error("no cfg!, this is unusual!")
	end

	local result = {}

	local function InsertBadPath(from, to)
		table.insert(result, {
			From = from,
			To = to,
			Omnidirectional = false
		})
	end

	local nodeTableExpander = v.NodeTableExpander(p)
	local count = #nodeTableExpander

	while #nodeTableExpander > 1 do
		for _ = 1, count do
			local v3 = v.CheckPath(nodeTableExpander[1], nodeTableExpander[count])

			if not v3 then
				table.insert(result, {
					From = nodeTableExpander[1],
					To = nodeTableExpander[count],
					Omnidirectional = false
				})
			end

			if not flag then
				continue
			end

			local v4 = v.CheckPath(nodeTableExpander[count], nodeTableExpander[1])

			if v4 then
				continue
			end

			if v3 or v4 then
				table.insert(result, {
					From = nodeTableExpander[count],
					To = nodeTableExpander[1],
					Omnidirectional = false
				})
			else
				result[#result].Omnidirectional = true
			end
		end
	end

	return result
end