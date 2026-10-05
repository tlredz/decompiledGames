local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local Config = require(script.Parent.Config)
local intersection = t.intersection(t.integer, t.numberPositive)
local literalList = t.literalList(Config.WORLD_CATEGORY_IDS)
local intersection2 = t.intersection(t.integer, t.numberConstrained(0, Config.MAX_ITEM_TIER))
local intersection3 = t.intersection(t.integer, t.numberConstrained(1, Config.MAX_GIVE_AMOUNT))
local match = t.match("^[%w_]" .. string.rep("[%w_]?", 63) .. "$")
return remo.createRemotes({
	ccPanel = remo.namespace({
		getAccess = remo.remote().returns(),
		spectateFollow = remo.remote(t.optional(intersection)),
		getTrollActions = remo.remote().returns(),
		trollAction = remo.remote(t.string, intersection).middleware(remo.throttleMiddleware(Config.TROLL_SERVER_THROTTLE)),
		getGiftState = remo.remote().returns(),
		giftTreadmill = remo.remote(t.string, intersection).returns(),
		selfGiftCandy = remo.remote().returns(),
		getWorldState = remo.remote().returns(),
		teleportToWorld = remo.remote(t.intersection(t.integer, t.numberConstrained(1, Config.MAX_WORLD_INDEX))).returns(),
		returnToMainGame = remo.remote().returns(),
		giveAll = remo.remote(literalList, intersection2).returns(),
		getCatalog = remo.remote(literalList).returns(),
		giveOne = remo.remote(literalList, t.string, intersection3, intersection2).returns(),
		setWins = remo.remote(t.intersection(t.integer, t.numberConstrained(0, Config.MAX_SET_WINS))).returns(),
		setLevel = remo.remote(t.intersection(t.integer, t.numberConstrained(1, Config.MAX_SET_LEVEL))).returns(),
		resetData = remo.remote().returns(),
		getContentState = remo.remote().returns(),
		setMultiplier = remo.remote(
			t.literalList(Config.MULTIPLIER_KINDS),
			t.numberConstrained(1, Config.MAX_CUSTOM_MULTIPLIER)
		).returns(),
		morph = remo.remote(match).returns(),
		unmorph = remo.remote().returns(),
		spawnKey = remo.remote(
			t.match(Config.KEY_CHAR_PATTERN),
			t.Color3,
			t.numberConstrained(Config.KEY_SCALE_MIN, Config.KEY_SCALE_MAX),
			t.intersection(t.integer, t.numberConstrained(0, Config.MAX_ASSET_ID))
		).returns(),
		undoKey = remo.remote().returns(),
		clearKeys = remo.remote().returns(),
		getEventState = remo.remote().returns(),
		startEvent = remo.remote(match, t.intersection(t.integer, t.numberConstrained(0, Config.MAX_EVENT_MINUTES))).returns(),
		stopEvent = remo.remote(match).returns(),
		sendInvite = remo.remote(t.match(Config.USERNAME_PATTERN)).returns(),
		respondInvite = remo.remote(t.match(Config.INVITE_ID_PATTERN), t.boolean).returns(),
		inviteReceived = remo.remote(),
		inviteAck = remo.remote()
	})
}).ccPanel