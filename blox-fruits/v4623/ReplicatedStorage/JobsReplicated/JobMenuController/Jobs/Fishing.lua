local v = {
	JOB_NAME = script.Name,
	SKILL_DATA = {
		{
			Name = "Casting",
			Image = "rbxassetid://118711879479900",
			ImageRectOffset = Vector2.new(0, 0),
			Description = "Bite delay reduced by NUMBERs"
		},
		{
			Name = "Bait",
			Image = "rbxassetid://118711879479900",
			ImageRectOffset = Vector2.new(128, 0),
			Description = "Effectiveness increased by NUMBER%"
		},
		{
			Name = "Control",
			Image = "rbxassetid://118711879479900",
			ImageRectOffset = Vector2.new(256, 0),
			Description = "Bar width increased by NUMBER%"
		}
	}
}
return function(p)
	local BaseJobMenu = require(script.Parent.BaseJobMenu)
	return BaseJobMenu(p, v)
end