local SkillStats = require(script.Parent.Parent.Parent.Modules.SkillStats)
return {
	CanPlayOver = function(_, p: string, p2: string)
		if p == nil or p2 == nil then
			return false, false
		end

		local v = SkillStats.Get(p)

		if v == nil or v.skills_to_play_over == nil or type(v.skills_to_play_over) ~= "table" or v.skills_to_play_over[p2] ~= true then
			return false, false
		end

		local dont_cancel_on_play_over = v.dont_cancel_on_play_over
		return true, type(dont_cancel_on_play_over) == "table" and dont_cancel_on_play_over[p2] == true
	end
}