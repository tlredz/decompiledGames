local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
require(game.ReplicatedStorage.React.Util)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local GeneratedTypes = require(script.Parent.GeneratedTypes)
local literal = Type.literal(
	"HasSeaEvents",
	"HasSeaBeasts",
	"HasEliteHunters",
	"HasShipRaids",
	"HasMirageIsland",
	"IsCelebrationEvent",
	"IsBanLand",
	"IsPermanent",
	"IsFirstSea",
	"IsSecondSea",
	"IsThirdSea",
	"IsMinimal"
)
local strictInterface = Type.strictInterface({
	Year = Type.integer,
	Month = Type.integer,
	Day = Type.integer,
	Hour = Type.optional(Type.integer),
	Minute = Type.optional(Type.integer),
	Second = Type.optional(Type.integer),
	Millisecond = Type.optional(Type.integer)
})
local v = nil
v = Type.intersection(Type.interface({
	Fallback = Type.optional(function(...)
		return v(...)
	end)
}), TypeUtil.Types.BetterUnion({
	LevelRequirement = Type.intersection(Type.interface({
		Type = TypeUtil.Types.BetterLiteral("LevelRequirement")
	}), TypeUtil.Types.BetterUnion({
		MinLevelRequirement = Type.interface({
			Minimum = Type.integer
		}),
		MaxLevelRequirement = Type.interface({
			Maximum = Type.integer
		}),
		RangeLevelRequirement = Type.interface({
			Minimum = Type.integer,
			Maximum = Type.integer
		})
	})),
	QuestRequirement = Type.interface({
		Type = TypeUtil.Types.BetterLiteral("QuestRequirement"),
		QuestName = TypeUtil.Types.BetterLiteral("ZouQuest", "DressrosaQuest")
	}),
	DateRequirement = Type.intersection(Type.interface({
		Type = TypeUtil.Types.BetterLiteral("DateRequirement")
	}), TypeUtil.Types.BetterUnion({
		BeforeRequirement = Type.interface({
			Before = strictInterface
		}),
		AfterRequirement = Type.interface({
			After = strictInterface
		}),
		BeforeAfterRequirement = Type.interface({
			Before = strictInterface,
			After = strictInterface
		})
	}))
}))
local strictInterface2 = Type.strictInterface({
	Id = Type.string,
	DisplayName = Type.string,
	Icon = Type.optional(TypeUtil.Types.ImageData),
	Check = Type.callback
})
local interface = Type.interface({
	DisplayName = Type.optional(Type.string),
	PlaceId = Type.map(Type.string, Type.integer),
	Difficulty = Type.optional(Type.integer),
	Tags = Type.optional(Type.array(literal)),
	Qualifications = Type.optional(Type.array(v)),
	Attributes = Type.optional(Type.map(Type.string, Type.any))
})
local interface2 = Type.interface({
	DisplayName = Type.string,
	PlaceId = Type.map(Type.string, Type.integer),
	Difficulty = Type.integer,
	Tags = Type.optional(Type.array(literal)),
	Qualifications = Type.array(v),
	Attributes = Type.optional(Type.map(Type.string, Type.any))
})
local intersection = Type.intersection(interface, Type.interface({
	Connections = Type.map(GeneratedTypes.RealmName, Type.array(v))
}))
local intersection2 = Type.intersection(interface2, Type.interface({
	Variants = Type.optional(Type.map(GeneratedTypes.RealmName, intersection)),
	Connections = Type.map(GeneratedTypes.RealmName, Type.array(v))
}))
return {
	PartialRealmStruct = {
		type = interface,
		convert = function(p)
			return TypeUtil.convert(p, interface)
		end
	},
	PartialRealmConfig = {
		type = intersection,
		convert = function(p)
			return TypeUtil.convert(p, intersection)
		end
	},
	BaseRealmStruct = {
		type = interface2,
		convert = function(p)
			return TypeUtil.convert(p, interface2)
		end
	},
	Qualification = {
		type = strictInterface2,
		convert = function(p)
			return TypeUtil.convert(p, strictInterface2)
		end
	},
	QualificationConfig = {
		type = v,
		convert = function(p)
			return TypeUtil.convert(p, v)
		end
	},
	RealmName = {
		type = GeneratedTypes.RealmName,
		convert = function(p)
			return TypeUtil.convert(p, GeneratedTypes.RealmName)
		end
	},
	RealmTag = {
		type = literal,
		convert = function(p)
			return TypeUtil.convert(p, literal)
		end
	},
	RealmConfig = {
		type = intersection2,
		convert = function(p)
			return TypeUtil.convert(p, intersection2)
		end
	}
}