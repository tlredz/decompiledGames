local parent = script.Parent.Parent
local Story = require(parent.Story)
local hooks = parent.Hooks
local useTagged = require(hooks.useTagged)
local components = parent.Components
local GameInfo = require(components.GameInfo)
local shared = parent.Parent.Shared
local React = require(shared.React)
local ReactRoblox = require(shared.ReactRoblox)

local function CustomStory()
	local v = {}

	for k, adornee in useTagged("RelicsTrialMount") do
		v[k] = ReactRoblox.createPortal({
			GameInfo = React.createElement(GameInfo, {
				Adornee = adornee
			})
		}, adornee)
	end

	return React.createElement(React.Fragment, nil, v)
end

return Story.Custom(CustomStory)