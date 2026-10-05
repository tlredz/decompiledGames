return {
	forSlot = function(p)
		if p == 1 then
			return ""
		elseif p == 2 then
			return "_Mirror"
		end

		return "_S" .. p
	end
}