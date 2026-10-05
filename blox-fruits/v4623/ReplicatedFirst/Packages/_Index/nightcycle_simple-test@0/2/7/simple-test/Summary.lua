require(script.Parent.Test)
local ENV = require(script.Parent.ENV)
local Summary = {}

function Summary.newFullJSON(items)
	local count = 0
	local passed = true

	for _, item in items do
		count += 1

		for _, v4 in item do
			if not (v4.Type == "Failure" or v4.Type == "Error") then
				continue
			end

			passed = false
			break
		end

		if not passed then
			break
		end
	end

	local clone = table.clone(items)
	table.freeze(clone)
	local v3 = {
		Type = "FullJSON",
		Count = count,
		Passed = passed,
		Results = clone
	}
	table.freeze(v3)
	return v3
end

function Summary.newOverview(items)
	local debugInfo = {}
	local count = 0
	local results = {}
	local flag = true

	for k, item in items do
		local v3 = {}

		for _, v4 in item do
			if not (v4.Type == "Failure" or v4.Type == "Error") then
				continue
			end

			if #v3 < ENV.DEBUG_CLIP_RESULTS_AT then
				table.insert(v3, v4)
			else
				break
			end
		end

		table.freeze(v3)

		if #v3 > 0 then
			debugInfo[k] = v3
		end
	end

	table.freeze(debugInfo)

	for k, item in items do
		count += 1
		local flag2 = true

		for _, v4 in item do
			if v4.Type == "Failure" then
				results[k] = "Fail"
				flag2 = false
				break
			elseif v4.Type == "Error" then
				results[k] = v4.Message
				flag2 = false
				break
			end
		end

		if flag2 then
			results[k] = "Success"
		else
			flag = false
		end
	end

	table.freeze(results)

	if flag then
		debugInfo = nil
	end

	local v3 = {
		Type = "Overview",
		Count = count,
		Passed = flag,
		Results = results,
		DebugInfo = debugInfo
	}
	table.freeze(v3)
	return v3
end

return Summary