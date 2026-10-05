local MobileLayout = {
	Toolbar = {
		Count = 5,
		Size = 48.99999999999999,
		Padding = 5,
		Edge = 5
	},
	Skills = {
		Count = 10,
		Layout = {
			{
				X = -1.69,
				Y = -0.05
			},
			{
				X = -1.16,
				Y = -0.31
			},
			{
				X = -0.86,
				Y = -0.85
			},
			{
				X = -0.57,
				Y = -1.19
			},
			{
				X = -0.03,
				Y = -1.17
			},
			{
				X = -1.23,
				Y = 0.26
			},
			{
				X = -0.8,
				Y = 0.28
			},
			{
				X = -0.78,
				Y = -0.3
			},
			{
				X = -0.31,
				Y = -0.75
			},
			{
				X = 0.35,
				Y = -0.79
			}
		}
	},
	Dash = {
		X = -211.67999999999998,
		Y = -38.21999999999999
	},
	Run = {
		X = -265.58,
		Y = -38.21999999999999
	},
	Combat = {
		X = -211.67999999999998,
		Y = -126.41999999999999
	}
}

function MobileLayout.ToolbarOffset(p: number)
	local toolbar = MobileLayout.Toolbar
	return -(toolbar.Size + toolbar.Padding) * (toolbar.Count - p) - toolbar.Edge, -toolbar.Edge
end

function MobileLayout.SkillOffset(p: number)
	local layout = MobileLayout.Skills.Layout
	local v = layout[p] or layout[#layout]
	return v.X, v.Y
end

return MobileLayout