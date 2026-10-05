require(game.ReplicatedStorage.Spritesheets)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Sprite Key"] = "Sprite",
	["Outline Sprite Key"] = "OutlineSprite",
	["Sprite Border Thickness"] = "SpriteBorderThickness",
	["Corner Icon Sprite Key"] = "CornerIcon",
	["Outline Sprite Color"] = "OutlineColor",
	["Background Color"] = "BackgroundColor",
	["Category Icon Text"] = "CategoryIconText",
	["Category Icon Sprite Key"] = "CategoryIcon",
	["Ribbon Text"] = "RibbonText"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	Name = Parse.Optional(Parse.String),
	Title = Parse.Optional(Parse.String),
	Category = Parse.Optional(Parse.String),
	Sprite = Parse.Optional(Parse.Sprite),
	OutlineSprite = Parse.Optional(Parse.Sprite),
	CategoryIcon = Parse.Optional(Parse.Sprite),
	CategoryIconText = Parse.Optional(Parse.String),
	OutlineColor = Parse.Optional(Parse.Color3),
	Description = Parse.Optional(Parse.String),
	BackgroundColor = Parse.Optional(Parse.Color3),
	CornerIcon = Parse.Optional(Parse.Sprite),
	RibbonText = Parse.Optional(Parse.String),
	SpriteBorderThickness = Parse.Optional(Parse.UnsignedInteger)
})))