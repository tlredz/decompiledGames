return {
	MakeWeldNotBreakable = function(_, instance)
		local part0 = instance.Part0
		local part1 = instance.Part1

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rebuild()
			instance.Part0 = part0
			instance.Part1 = part1
		end

		instance:GetPropertyChangedSignal("Part0"):Connect(function()
			rebuild() -- equivalent call inferred; original call site unknown
		end)
		instance:GetPropertyChangedSignal("Part1"):Connect(function()
			rebuild() -- equivalent call inferred; original call site unknown
		end)
	end
}