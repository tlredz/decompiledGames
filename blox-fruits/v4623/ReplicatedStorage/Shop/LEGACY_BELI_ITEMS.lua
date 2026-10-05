local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

local function raisedFortressFlag(p)
	local bonusMoments = p.BonusMoments
	local fortressFlagpole

	if typeof(bonusMoments) == "table" then
		fortressFlagpole = bonusMoments["Fortress Flagpole"]
	end

	return typeof(fortressFlagpole) == "table" and fortressFlagpole.Completed == true
end

local LEGACYBELIITEMS = {}

for k, list in pairs({
	["Rocket-Rocket"] = {},
	["Spin-Spin"] = {},
	["Blade-Blade"] = {},
	["Spring-Spring"] = {},
	["Bomb-Bomb"] = {},
	["Smoke-Smoke"] = {},
	["Lightning-Lightning"] = {},
	["Spike-Spike"] = {},
	["Flame-Flame"] = {},
	["Eagle-Eagle"] = {},
	["Ice-Ice"] = {},
	["Sand-Sand"] = {},
	["Dark-Dark"] = {},
	["Diamond-Diamond"] = {},
	["Light-Light"] = {},
	["Rubber-Rubber"] = {},
	["Control-Control"] = {},
	["Ghost-Ghost"] = {},
	["Magma-Magma"] = {},
	["Quake-Quake"] = {},
	["Buddha-Buddha"] = {},
	["Love-Love"] = {},
	["Spider-Spider"] = {},
	["Sound-Sound"] = {},
	["Phoenix-Phoenix"] = {},
	["Portal-Portal"] = {},
	["Pain-Pain"] = {},
	["Blizzard-Blizzard"] = {},
	["Gravity-Gravity"] = {},
	["T-Rex-T-Rex"] = {},
	["Mammoth-Mammoth"] = {},
	["Dough-Dough"] = {},
	["Shadow-Shadow"] = {},
	["Venom-Venom"] = {},
	["Creation-Creation"] = {},
	["Gas-Gas"] = {},
	["Spirit-Spirit"] = {},
	["Yeti-Yeti"] = {},
	["Tiger-Tiger"] = {},
	["Kitsune-Kitsune"] = {},
	["Dragon-Dragon"] = {},
	["Magnet-Magnet"] = {},
	["Meme-Meme"] = {},
	Cannon = {},
	Musket = {},
	Slingshot = {},
	["Refined Slingshot"] = {},
	Flintlock = {},
	["Dual Flintlock"] = {},
	Cutlass = {},
	["Dual Katana"] = {},
	Katana = {},
	["Triple Katana"] = {},
	["Dark Blade"] = {},
	Bisento = {
		LevelReq = 250
	},
	["Soul Cane"] = {},
	["Dual-Headed Blade"] = {},
	["Iron Mace"] = {},
	Pipe = {},
	["Black Cape"] = {
		Condition = function(p)
			if not (p.Level >= 50) then
				return false
			end

			local bonusMoments = p.BonusMoments
			local fortressFlagpole

			if typeof(bonusMoments) == "table" then
				fortressFlagpole = bonusMoments["Fortress Flagpole"]
			end

			local v

			if typeof(fortressFlagpole) == "table" then
				v = fortressFlagpole.Completed == true
			else
				v = false
			end

			if v then
				return true
			end

			return false
		end
	},
	["Swordsman Hat"] = {
		Price = 150000,
		Description = "",
		Condition = function(p)
			if p.Stats.Sword.Level >= 100 and p.Abilities.Buso and p.Abilities.Geppo and p.Abilities.Soru then
				return true
			end

			return false
		end
	},
	["Tomoe Ring"] = {
		Condition = function(p)
			return p.Stats.Melee.Level >= 200
		end
	}
}) do
	local unwrapped = ItemConfig.Query.joinOne({
		Index = {
			StorageKey = k,
			IdType = {
				Operation = "OR",
				Values = { "PhysicalMoveset", "Moveset" }
			}
		},
		Quality = {
			MoneyPrice = {
				Operation = "NEQ",
				Value = nil
			}
		}
	}, {
		Index = {
			StorageKey = k,
			IdType = "Accessory"
		}
	}):unwrap()
	list.Name = k
	list.Price = unwrapped.Quality.MoneyPrice
	list.Description = unwrapped.Display.Description
	assert(list.Price, (`bad price: {list.Price}`))
	list.StockChance = unwrapped.Quality.StockChance
	list.StockOffset = unwrapped.Quality.StockOffset
	table.freeze(list)
	LEGACYBELIITEMS[k] = list
end

table.freeze(LEGACYBELIITEMS)
return LEGACYBELIITEMS