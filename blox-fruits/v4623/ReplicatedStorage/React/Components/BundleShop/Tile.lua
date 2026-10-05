local React = require(game.ReplicatedStorage.Packages.React)
local Control = require(script.Control)
local Dragon = require(script.Dragon)
local Empyrean = require(script.Empyrean)
local Kitsune = require(script.Kitsune)
local Fiend = require(script.Fiend)
local Yeti = require(script.Yeti)
local Tiger = require(script.Tiger)
local Werewolf = require(script.Werewolf)
local Lightning = require(script.Lightning)
local Magnet = require(script.Magnet)
return function(p)
	local createElement = React.createElement

	if p.Type == "Control" then
		return createElement(Control, p)
	end

	if p.Type == "Dragon" then
		return createElement(Dragon, p)
	end

	if p.Type == "Empyrean" then
		return createElement(Empyrean, p)
	end

	if p.Type == "Kitsune" then
		return createElement(Kitsune, p)
	end

	if p.Type == "Fiend" then
		return createElement(Fiend, p)
	end

	if p.Type == "Yeti" then
		return createElement(Yeti, p)
	end

	if p.Type == "Tiger" then
		return createElement(Tiger, p)
	end

	if p.Type == "Werewolf" then
		return createElement(Werewolf, p)
	end

	if p.Type == "Lightning" then
		return createElement(Lightning, p)
	end

	if p.Type == "Magnet" then
		return createElement(Magnet, p)
	end

	error("Unknown TileType: " .. tostring(p.Type))
end