local React = require(game.ReplicatedStorage.Packages.React)
local Halloween2025 = require(script.Halloween2025)
local FoxSpirit2025 = require(script.FoxSpirit2025)
local Bloodfrost2026 = require(script.Bloodfrost2026)
local Easter2026 = require(script.Easter2026)
local GamepassBundle = require(script.GamepassBundle)
return function(p)
	local createElement = React.createElement

	if p.Type == "Halloween2025" then
		return createElement(Halloween2025, p)
	end

	if p.Type == "FoxSpirit2025" then
		return createElement(FoxSpirit2025, p)
	end

	if p.Type == "Bloodfrost2026" then
		return createElement(Bloodfrost2026, p)
	end

	if p.Type == "GamepassBundle" then
		return createElement(GamepassBundle, p)
	end

	if p.Type == "Easter2026" then
		return createElement(Easter2026, p)
	end

	error("Unknown BannerType: " .. tostring(p.Type))
end