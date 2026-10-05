local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local IdMap = require(game.ReplicatedStorage.IdMap)
local PlayerStats = require(game.ReplicatedStorage.React.Factories.Hooks.PlayerStats)
local parentModule = require(script.Parent)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IsOpen = true,
		IsDungeon = false,
		StatPoints = UILabs.Slider(1857, 0, 5000, 1),
		Race = UILabs.Choose(TableUtil.keys(IdMap.Race), 1),
		RaceLevel = UILabs.Slider(1, 1, 4, 1),
		StoredStatRefunds = UILabs.Slider(0, 0, 20, 1),
		GunLevel = UILabs.Slider(1, 1, 3000, 1),
		FruitLevel = UILabs.Slider(1, 1, 3000, 1),
		DefenseLevel = UILabs.Slider(1, 1, 3000, 1),
		MeleeLevel = UILabs.Slider(1, 1, 3000, 1),
		SwordLevel = UILabs.Slider(1, 1, 3000, 1),
		GunMasteryBoost = UILabs.Slider(0, 0, 150, 1),
		FruitMasteryBoost = UILabs.Slider(0, 0, 150, 1),
		DefenseMasteryBoost = UILabs.Slider(0, 0, 150, 1),
		MeleeMasteryBoost = UILabs.Slider(0, 0, 150, 1),
		SwordMasteryBoost = UILabs.Slider(0, 0, 150, 1),
		LevelCap = UILabs.Slider(2800, 2800, 3000, 1),
		HasGun = false,
		HasFruit = false,
		HasSword = false,
		RerollCount = UILabs.Slider(9, 0, 50, 1)
	}
}, function(p)
	useMockStateWriter("PlayerRaceId", IdMap.Race[p.controls.Race])
	useMockStateWriter("PlayerRaceLevel", p.controls.RaceLevel)
	useMockStateWriter(PlayerStats.getMockKey("Gun", "Level"), p.controls.GunLevel)
	useMockStateWriter(PlayerStats.getMockKey("Sword", "Level"), p.controls.SwordLevel)
	useMockStateWriter(PlayerStats.getMockKey("Demon Fruit", "Level"), p.controls.FruitLevel)
	useMockStateWriter(PlayerStats.getMockKey("Defense", "Level"), p.controls.DefenseLevel)
	useMockStateWriter(PlayerStats.getMockKey("Melee", "Level"), p.controls.MeleeLevel)
	useMockStateWriter("LevelCap", p.controls.LevelCap)
	useMockStateWriter("GunMasteryBoost", p.controls.GunMasteryBoost)
	useMockStateWriter("SwordMasteryBoost", p.controls.SwordMasteryBoost)
	useMockStateWriter("BloxFruitMasteryBoost", p.controls.FruitMasteryBoost)
	useMockStateWriter("DefenseMasteryBoost", p.controls.DefenseMasteryBoost)
	useMockStateWriter("MeleeMasteryBoost", p.controls.MeleeMasteryBoost)
	useMockStateWriter("PlayerSwordItemId", p.controls.HasSword and IdMap.Moveset.Katana or nil)
	useMockStateWriter("PlayerGunItemId", p.controls.HasGun and IdMap.Moveset.Bazooka or nil)
	useMockStateWriter("PlayerBloxFruit", p.controls.HasFruit and "Bomb-Bomb" or nil)
	useMockStateWriter("RaceRerolls", p.controls.RerollCount)
	useMockStateWriter("StatPoints", p.controls.StatPoints)
	useMockStateWriter("IsDungeon", p.controls.IsDungeon)
	useMockStateWriter("StoredStatRefunds", p.controls.StoredStatRefunds)
	return createElement(parentModule, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		ZIndex = CONSTANTS.LAYER.RAISED,
		IsOpen = p.controls.IsOpen,
		OnAction = function(p2)
			print("action", p2)
		end,
		OnExit = function()
			print("exit")
		end
	})
end)