local v = {
	target = nil,
	color = Color3.fromRGB(255, 255, 255),
	transparency = 0
}
local Highlight = {}

function Highlight.new(data)
	assert(type(data) == "table", "Highlight.new expects a table of props.")
	assert(data.target, "Highlight requires a target to be set!")
	assert(
		data.target:IsA("Model") or data.target.Parent == workspace._WorldOrigin.EnemySpawns,
		"Highlight requires target to be a Model!"
	)
	return (setmetatable({
		target = data.target,
		color = data.color or v.color,
		transparency = data.transparency or v.transparency
	}, Highlight))
end

function Highlight.fromTarget(model)
	assert(
		model and (model:IsA("Model") or model.Parent == workspace._WorldOrigin.EnemySpawns),
		"Highlight.fromTarget requires a Model target to be set!"
	)
	return Highlight.new({
		target = model
	})
end

return Highlight