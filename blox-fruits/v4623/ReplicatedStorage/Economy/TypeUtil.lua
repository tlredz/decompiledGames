local Option = require(game.ReplicatedStorage.Packages.Option)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
return {
	BetterLiteral = {
		Type = {
			check = TypeUtil.Types.BetterLiteral
		}
	},
	BetterUnion = {
		Type = {
			check = TypeUtil.Types.BetterUnion
		}
	},
	Option = {
		Type = {
			check = Option.type
		}
	},
	Metatable = {
		Type = {
			check = TypeUtil.Types.Metatable
		}
	}
}