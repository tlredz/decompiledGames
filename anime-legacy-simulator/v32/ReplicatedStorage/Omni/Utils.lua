local RunService = game:GetService("RunService")
local Utils = {
	Loop = require(script.Loop),
	Number = require(script.Number),
	Particles = require(script.Particles),
	Table = require(script.Table),
	Timer = require(script.Timer),
	Instance = require(script.Instance),
	Math = require(script.Math),
	Luck = require(script.Luck),
	Probability = require(script.Probability),
	String = require(script.String),
	Validator = require(script.Validator),
	Camera = require(script.Camera),
	Accessories = require(script.Accessories),
	Colors = require(script.Colors),
	Characters = require(script.Characters),
	Weapons = require(script.Weapons),
	PlayerStats = require(script.PlayerStats),
	SpatialHash = require(script.SpatialHash),
	StateManager = require(script.StateManager),
	Info = require(script.Info),
	VirtualList = require(script.VirtualList),
	Order = require(script.Order),
	Enemies = require(script.Enemies),
	Interface = require(script.Interface),
	Players = require(script.Players),
	Multipliers = require(script.Multipliers),
	Traits = require(script.Traits),
	CameraShake = require(script.CameraShake),
	Lighting = require(script.Lighting)
}

if RunService:IsClient() then
	Utils.Text = require(script.Text)
end

return Utils