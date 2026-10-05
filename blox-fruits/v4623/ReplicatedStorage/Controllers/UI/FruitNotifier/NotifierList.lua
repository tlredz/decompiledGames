local React = require(game.ReplicatedStorage.Packages.React)
local NotifierLabel = require(script.Parent.NotifierLabel)
require(script.Parent.Types)

local function NotifierList(p)
	local children = {}

	for _, source in p.sources do
		children[source.id] = React.createElement(NotifierLabel, {
			id = source.id,
			text = source.text,
			visible = source.visible,
			layoutOrder = source.layoutOrder,
			size = source.size
		})
	end

	return React.createElement(React.Fragment, nil, children)
end

return NotifierList