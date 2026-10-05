local parent = script.Parent
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local hooks = parent2.Hooks
local useStyleSheet = require(hooks.useStyleSheet)
local Enums = require(parent2.Enums)
local State = require(parent2.State)
local React = require(shared.React)
local TabButton = require(parent.TabButton)

local function NavigationBar(p)
	local v = useStyleSheet("Icons", "string")
	local v2 = React.useContext(State.Context)
	local features = v2.Features
	local windowTab = v2.WindowTab
	local v3 = React.useMemo(function()
		local children = {
			Scale = p.Scale and React.createElement("UIScale", {
				Scale = p.Scale
			})
		}
		local v4 = {}

		if not (features.Emotes or features.Skins) then
			v4.Upgrades = true
		end

		if not features.Auras then
			v4.Auras = true
		end

		if not features.Favorites then
			v4.Favorites = true
		end

		for k, order in pairs(Enums.WindowTab) do
			if k == "Upsell" or v(`Image-NavBar-{k}`, nil) == nil or v4[k] then
				continue
			end

			local v6 = k
			local v7 = order
			children[k] = React.createElement(TabButton, {
				Tab = k,
				Order = order,
				Active = windowTab == order,
				Spin = false,
				OnActivated = function()
					if p.OnActivated then
						p.OnActivated(v6, v7)
					else
						v2.SetWindowTab(v7)
					end
				end
			})
		end

		return children
	end, {
		features,
		windowTab,
		v,
		p.OnActivated,
		v2.SetWindowTab
	})
	return React.createElement("Frame", {
		[React.Tag] = "NavigationBarContainer"
	}, v3, {
		Ignore = React.createElement("Folder", {}, {
			Upper = React.createElement("Frame", {
				[React.Tag] = "UpperGapBackground"
			})
		})
	})
end

return NavigationBar