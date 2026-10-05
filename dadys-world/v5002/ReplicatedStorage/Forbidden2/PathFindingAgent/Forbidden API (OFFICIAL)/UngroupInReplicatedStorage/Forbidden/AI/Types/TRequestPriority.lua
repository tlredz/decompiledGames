local TRequestPriority = {
	ConvertNumberToPriority = function(p: number)
		if p <= 0 then
			return "Low"
		end

		if p == 1 then
			return "Normal"
		elseif p == 2 then
			return "High"
		end

		if p >= 3 then
			return "Critical"
		end

		error("Invalid number for RequestPriority: " .. tostring(p))
	end,
	ConvertPriorityToNumber = function(p: string)
		if p == "Low" then
			return 0
		elseif p == "DefaultStart" then
			return 1
		elseif p == "Normal" then
			return 1
		elseif p == "DefaultStop" then
			return 2
		elseif p == "High" then
			return 2
		elseif p == "Critical" then
			return 3
		end

		error("Invalid RequestPriority: " .. tostring(p))
	end
}

function TRequestPriority.GetPriorityNumber(value)
	if typeof(value) == "number" then
		return value
	end

	return TRequestPriority.ConvertPriorityToNumber(value)
end

return TRequestPriority