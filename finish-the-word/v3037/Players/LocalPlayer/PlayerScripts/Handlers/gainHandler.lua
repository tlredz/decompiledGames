local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("clientUtil")
local import4 = _G.import("configuration")
local gainBillboard = _G.import("viewImports"):get("gainBillboard")
local CollectionService = game:GetService("CollectionService")
local localPlayer = game.Players.LocalPlayer
local PET = import4.PET
local LEVEL = import4.LEVEL
local v = {}
local flag = false

local function processQueue()
	if flag then
		return
	end

	flag = true

	while #v > 0 do
		table.remove(v, 1)()
		task.wait(2.5)
	end

	flag = false
end

local function enqueue(p)
	table.insert(v, p)
	task.spawn(processQueue)
end

local function showXpGain(xp)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	import3.sound("ItemPurchase5")
	import.mount(import.make(gainBillboard.Xp, {
		Old = xp.Character.Old,
		Gain = xp.Character.Gain,
		MaxXp = LEVEL.LEVEL_MAX_XP,
		LevelGrowth = LEVEL.LEVEL_XP_GROWTH,
		StudsOffset = createVector(0, 1.5, 0)
	}), character.HumanoidRootPart)

	if not xp.Pet then
		return
	end

	for _, v2 in pairs(CollectionService:GetTagged("bob")) do
		if not v2:IsDescendantOf(character) then
			continue
		end

		import.mount(import.make(gainBillboard.Xp, {
			Old = xp.Pet.Old,
			Gain = xp.Pet.Gain,
			MaxXp = PET.PET_MAX_XP,
			LevelGrowth = PET.PET_LEVEL_GROWTH,
			StudsOffset = createVector(0, 3, 0)
		}), v2)
		break
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showCurrencyGain(currency)
	import.mount(import.make(gainBillboard.Currency, {
		Target = currency.Cash
	}), localPlayer.PlayerGui)
end

local function gain(p)
	if p.Xp then
		table.insert(v, function()
			showXpGain(p.Xp)
		end)
		task.spawn(processQueue)
	end

	if p.Currency then
		table.insert(v, function()
			showCurrencyGain(p.Currency) -- equivalent call inferred; original call site unknown
		end)
		task.spawn(processQueue)
	end
end

return {
	Priority = 1,
	Run = function()
		import2.connect("gain", gain)
		import2.remoteConnect("gain", gain)
	end
}