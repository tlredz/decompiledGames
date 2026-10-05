local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local parentModule = require(script.Parent)

function newTestData(label: string, p2, p3, items, items2)
	local empty = parentModule.Data.Modification.empty()

	for _, item in items do
		empty = parentModule.Data.Modification.setUnlock(item, empty, true)
	end

	for _, item in items2 do
		empty = parentModule.Data.Modification.setPreferred(item, empty, true)
	end

	return {
		Label = label,
		Adornee = parentModule.Data.Adornee.new(p2, p3),
		Modification = empty
	}
end

function newUsabilityCase(modificationItemId: number, p2, shouldBeUsable: boolean)
	return {
		Method = "getIfCanUse",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeUsable = shouldBeUsable
	}
end

function newEquippable(modificationItemId: number, p2, shouldBeEquippable: boolean)
	return {
		Method = "getIfCanEquip",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeEquippable = shouldBeEquippable
	}
end

function newUnequippable(modificationItemId: number, p2, shouldBeUnequippable: boolean)
	return {
		Method = "getIfCanUnequip",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeUnequippable = shouldBeUnequippable
	}
end

function newEquipped(modificationItemId: number, p2, shouldBeEquipped: boolean)
	return {
		Method = "getIfEquipped",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeEquipped = shouldBeEquipped
	}
end

function newUnlocked(modificationItemId: number, p2, shouldBeUnlocked: boolean)
	return {
		Method = "getIfUnlocked",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeUnlocked = shouldBeUnlocked
	}
end

function newUnlockable(modificationItemId: number, p2, shouldBeUnlockable: boolean)
	return {
		Method = "getIfCanUnlock",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBeUnlockable = shouldBeUnlockable
	}
end

function newPurchasable(modificationItemId: number, p2, shouldBePurchasable: boolean)
	return {
		Method = "getIfCanPurchase",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBePurchasable = shouldBePurchasable
	}
end

function newPreferred(modificationItemId: number, p2, shouldBePreferred: boolean)
	return {
		Method = "getIfPreferred",
		ModificationItemId = modificationItemId,
		Data = p2,
		ShouldBePreferred = shouldBePreferred
	}
end

function newIsAdorneeEquipped(adorneeId: number, p2, shouldBeEquipped: boolean)
	return {
		Method = "getIfAdorneeEquipped",
		AdorneeId = adorneeId,
		Data = p2,
		ShouldBeEquipped = shouldBeEquipped
	}
end

local v = {}

local function modificationCases(p: number, p2: number, p3: number?, purchasable: boolean, p4: number?, flag2: boolean?)
	local isGiftable = false
	local unwrapped = ItemConfig.match(p2):unwrap()

	if unwrapped.Economy and unwrapped.Economy.PurchaseWith then
		local unwrapped2 = ItemConfig.match(unwrapped.Economy.PurchaseWith):unwrap()

		if unwrapped2.Economy and unwrapped2.Economy.IsGiftable then
			isGiftable = unwrapped2.Economy.IsGiftable
		end
	end

	local v2 = newTestData("ownedAdorneeOnly", { p }, {}, {}, {})
	local v3 = newTestData("unlockedModificationOnly", {}, {}, { p2 }, {})
	local v4 = newTestData("ownedAdorneeAndUnlockedModification", { p }, {}, { p2 }, {})
	local v5 = newTestData("equippedAdorneeAndUnlockedModification", {}, { p4 or p }, { p2 }, {})
	local v6 = newTestData("ownedAdorneeAndEquippedModification", { p }, {}, {}, { p2 })
	local v7 = newTestData("equippedAdorneeAndEquippedModification", {}, { p4 or p }, {}, { p2 })
	local v8 = newTestData("noAdorneeAndUnlockedModification", {}, {}, { p2 }, {})
	local v9 = newTestData("noAdorneeAndNoModification", {}, {}, {}, {})
	local v10 = newTestData("bothAdorneeAndUnlockedModification", { p }, { p4 or p }, { p2 }, {})
	local v11 = newTestData("bothAdorneeAndBothModification", { p }, { p4 or p }, { p2 }, { p2 })

	if unwrapped.Index.IdType == "Mutation" then
		for k, v12 in {
			[v2] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v3] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = false
			},
			[v4] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			},
			[v5] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable and flag2 ~= true
			},
			[v6] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = true,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v7] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = true,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable and flag2 ~= true
			},
			[v8] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = false
			},
			[v9] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = false,
				Unlockable = false,
				Purchasable = false
			},
			[v10] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			},
			[v11] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = true,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			}
		} do
			table.insert(v, newUsable(p2, k, v12.Usable))
			table.insert(v, newEquippable(p2, k, v12.Equippable))
			table.insert(v, newEquipped(p2, k, v12.Equipped))
			table.insert(v, newPreferred(p2, k, v12.Preferred))
			table.insert(v, newUnlocked(p2, k, v12.Unlocked))
			table.insert(v, newUnlockable(p2, k, v12.Unlockable))
			table.insert(v, newPurchasable(p2, k, v12.Purchasable))
		end
	else
		local v12 = newTestData("bothAdorneeAndEquippedModification", { p }, { p4 or p }, {}, { p2 })
		local v13 = newTestData("bothAdorneeAndNoModification", { p }, { p4 or p }, {}, {})

		for k, v14 in {
			[v2] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v3] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = false
			},
			[v4] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			},
			[v5] = {
				Usable = true,
				Equippable = true,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable and flag2 ~= true
			},
			[v6] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = true,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v7] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = true,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable and flag2 ~= true
			},
			[v8] = {
				Usable = true,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = false
			},
			[v9] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = false,
				Unlockable = false,
				Purchasable = false
			},
			[v13] = {
				Usable = false,
				Equippable = false,
				Equipped = false,
				Preferred = false,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v12] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = true,
				Unlocked = false,
				Unlockable = true,
				Purchasable = purchasable
			},
			[v10] = {
				Usable = true,
				Equippable = true,
				Equipped = false,
				Preferred = false,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			},
			[v11] = {
				Usable = true,
				Equippable = false,
				Equipped = true,
				Preferred = true,
				Unlocked = true,
				Unlockable = false,
				Purchasable = purchasable and isGiftable
			}
		} do
			table.insert(v, newUsable(p2, k, v14.Usable))
			table.insert(v, newEquippable(p2, k, v14.Equippable))
			table.insert(v, newEquipped(p2, k, v14.Equipped))
			table.insert(v, newPreferred(p2, k, v14.Preferred))
			table.insert(v, newUnlocked(p2, k, v14.Unlocked))
			table.insert(v, newUnlockable(p2, k, v14.Unlockable))
			table.insert(v, newPurchasable(p2, k, v14.Purchasable))
		end
	end

	if p3 then
		local v12 = newTestData("equippedAdorneeWithOtherModificationEquipped", {}, { p4 or p }, {}, { p2 })
		local v13 = newTestData("unlockedAdorneeWithOtherModificationEquipped", { p }, {}, {}, { p2 })
		local v14 = newTestData("bothAdorneeWithOtherModificationEquipped", { p }, { p4 or p }, {}, { p2 })
		local v15 = newTestData("bothAdorneeWithOtherModificationBoth", { p }, { p4 or p }, { p2 }, { p2 })
		local v16 = newTestData("bothAdorneeWithOtherModificationUnlocked", { p }, { p4 or p }, { p2 }, {})
		local v17 = newTestData("unlockedAdorneeOnly", { p }, {}, {}, {})
		local v18 = newTestData("bothAdornee", { p }, { p }, {}, {})
		local v19 = newTestData("noAdornee", {}, {}, {}, {})

		if unwrapped.Index.IdType == "Mutation" then
			for k, v20 in {
				[v19] = {
					Usable = false,
					Equippable = false,
					Equipped = false,
					Preferred = false,
					Unlocked = false,
					Unlockable = false,
					Purchasable = false
				},
				[v18] = {
					Usable = true,
					Equippable = false,
					Equipped = true,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v17] = {
					Usable = true,
					Equippable = false,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v12] = {
					Usable = false,
					Equippable = false,
					Equipped = false,
					Preferred = false,
					Unlocked = false,
					Unlockable = true,
					Purchasable = false
				},
				[v13] = {
					Usable = true,
					Equippable = false,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v14] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v15] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v16] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				}
			} do
				table.insert(v, newUsable(p3, k, v20.Usable))
				table.insert(v, newEquippable(p3, k, v20.Equippable))
				table.insert(v, newEquipped(p3, k, v20.Equipped))
				table.insert(v, newPreferred(p3, k, v20.Preferred))
				table.insert(v, newUnlocked(p3, k, v20.Unlocked))
				table.insert(v, newUnlockable(p3, k, v20.Unlockable))
				table.insert(v, newPurchasable(p3, k, v20.Purchasable))
			end
		else
			for k, v20 in {
				[v19] = {
					Usable = false,
					Equippable = false,
					Equipped = false,
					Preferred = true,
					Unlocked = false,
					Unlockable = false,
					Purchasable = false
				},
				[v18] = {
					Usable = true,
					Equippable = false,
					Equipped = true,
					Preferred = true,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v17] = {
					Usable = true,
					Equippable = false,
					Equipped = false,
					Preferred = true,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[newTestData("equippedAdorneeOnly", {}, { p }, {}, {})] = {
					Usable = true,
					Equippable = false,
					Equipped = true,
					Preferred = true,
					Unlocked = false,
					Unlockable = false,
					Purchasable = false
				},
				[v12] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = false,
					Unlockable = false,
					Purchasable = false
				},
				[v13] = {
					Usable = true,
					Equippable = false,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v14] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v15] = {
					Usable = true,
					Equippable = true,
					Equipped = false,
					Preferred = false,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				},
				[v16] = {
					Usable = true,
					Equippable = false,
					Equipped = true,
					Preferred = true,
					Unlocked = true,
					Unlockable = false,
					Purchasable = false
				}
			} do
				table.insert(v, newUsable(p3, k, v20.Usable))
				table.insert(v, newEquippable(p3, k, v20.Equippable))
				table.insert(v, newEquipped(p3, k, v20.Equipped))
				table.insert(v, newPreferred(p3, k, v20.Preferred))
				table.insert(v, newUnlocked(p3, k, v20.Unlocked))
				table.insert(v, newUnlockable(p3, k, v20.Unlockable))
				table.insert(v, newPurchasable(p3, k, v20.Purchasable))
			end
		end
	end
end

modificationCases(IdMap.Moveset["Eagle-Eagle"], IdMap.Skin.FALCSKINvelvet, IdMap.Skin.FALCSKINeagle, true)
modificationCases(
	IdMap.Moveset["Dragon (East)-Dragon (East)"],
	IdMap.Skin.ESTDSKINyellow,
	IdMap.Skin.ESTDSKINgreen,
	true
)
modificationCases(
	IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"],
	IdMap.Skin.KYUKONSKINgalaxy,
	IdMap.Skin.KYUKONSKINcrimson,
	false
)
modificationCases(IdMap.Moveset["Dark Blade"], IdMap.Skin.DARKBLADESKINslayer, IdMap.Skin.DARKBLADESKINdefault, false)
modificationCases(
	IdMap.Moveset["Tiger-Tiger"],
	IdMap.Mutation.TIGERMUTWerewolf,
	IdMap.Mutation.TIGERMUTTiger,
	true,
	IdMap.Moveset["Werewolf (Tiger)-Werewolf (Tiger)"],
	true
)
modificationCases(
	IdMap.Moveset["Kitsune-Kitsune"],
	IdMap.Mutation.KITSUNEMUTKyukon,
	IdMap.Mutation.KITSUNEMUTKitsune,
	true,
	IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"],
	true
)
modificationCases(
	IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"],
	IdMap.Skin.KYUKONSKINgalaxy,
	IdMap.Skin.KYUKONSKINcrimson,
	false
)
modificationCases(IdMap.Moveset["Dragon (East)-Dragon (East)"], IdMap.Equipment.EastDragCrown, nil, false)
local v2 = newTestData(
	"noFoundationAdorneeAtAllJustVariant",
	{},
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Skin.KYUKONSKINgalaxy },
	{ IdMap.Mutation.KITSUNEMUTKyukon }
)
table.insert(v, newEquippable(IdMap.Skin.KYUKONSKINgalaxy, v2, true))
table.insert(v, newEquipped(IdMap.Skin.KYUKONSKINgalaxy, v2, false))
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINgalaxy, v2, false))
table.insert(v, newUsable(IdMap.Skin.KYUKONSKINgalaxy, v2, true))
table.insert(v, newUnlockable(IdMap.Skin.KYUKONSKINgalaxy, v2, false))
table.insert(v, newUnlocked(IdMap.Skin.KYUKONSKINgalaxy, v2, true))
local v3 = newTestData(
	"doNotLoseBaseMutation",
	{ IdMap.Moveset["Kitsune-Kitsune"] },
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Mutation.KITSUNEMUTKyukon },
	{ IdMap.Mutation.KITSUNEMUTKyukon }
)
table.insert(v, newEquippable(IdMap.Mutation.KITSUNEMUTKitsune, v3, true))
table.insert(v, newEquipped(IdMap.Mutation.KITSUNEMUTKitsune, v3, false))
table.insert(v, newPreferred(IdMap.Mutation.KITSUNEMUTKitsune, v3, false))
table.insert(v, newUnlocked(IdMap.Mutation.KITSUNEMUTKitsune, v3, true))
local v4 = newTestData(
	"notPreferredGalaxySkin",
	{ IdMap.Moveset["Kitsune-Kitsune"] },
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Mutation.KITSUNEMUTKyukon },
	{ IdMap.Mutation.KITSUNEMUTKyukon }
)
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINcrimson, v4, true))
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINgalaxy, v4, false))
local v5 = newTestData(
	"notPreferredGalaxySkinButHasIt",
	{ IdMap.Moveset["Kitsune-Kitsune"] },
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Mutation.KITSUNEMUTKyukon, IdMap.Skin.KYUKONSKINgalaxy },
	{ IdMap.Mutation.KITSUNEMUTKyukon }
)
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINcrimson, v5, true))
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINgalaxy, v5, false))
local v6 = newTestData(
	"preferredGalaxySkinButHasIt",
	{ IdMap.Moveset["Kitsune-Kitsune"] },
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Mutation.KITSUNEMUTKyukon },
	{ IdMap.Mutation.KITSUNEMUTKyukon, IdMap.Skin.KYUKONSKINgalaxy }
)
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINgalaxy, v6, true))
table.insert(v, newPreferred(IdMap.Skin.KYUKONSKINcrimson, v6, false))
local v7 = newTestData("onlyBase", { IdMap.Moveset["Bomb-Bomb"] }, {}, {}, {})
table.insert(v, newEquippable(IdMap.Skin.BOMBSKINdefault, v7, false))
table.insert(v, newEquipped(IdMap.Skin.BOMBSKINdefault, v7, false))
table.insert(v, newPreferred(IdMap.Skin.BOMBSKINdefault, v7, true))
table.insert(v, newUnlocked(IdMap.Skin.BOMBSKINdefault, v7, true))
table.insert(v, newUsable(IdMap.Skin.BOMBSKINdefault, v7, true))
local v8 = newTestData("onlyBaseAdornee", {}, { IdMap.Moveset["Bomb-Bomb"] }, {}, {})
table.insert(v, newEquippable(IdMap.Skin.BOMBSKINdefault, v8, false))
table.insert(v, newEquipped(IdMap.Skin.BOMBSKINdefault, v8, true))
table.insert(v, newPreferred(IdMap.Skin.BOMBSKINdefault, v8, true))
table.insert(v, newUnlocked(IdMap.Skin.BOMBSKINdefault, v8, false))
table.insert(v, newUsable(IdMap.Skin.BOMBSKINdefault, v8, true))
table.insert(v, newIsAdorneeEquipped(IdMap.Moveset["Bomb-Bomb"], v8, true))
local v9 = newTestData(
	"onlyAdorneeEquipped",
	{ IdMap.Moveset["Tiger-Tiger"] },
	{ IdMap.Moveset["Tiger-Tiger"], IdMap.Moveset["Werewolf (Tiger)-Werewolf (Tiger)"] },
	{},
	{}
)
table.insert(v, newEquippable(IdMap.Mutation.TIGERMUTWerewolf, v9, false))
table.insert(v, newPreferred(IdMap.Mutation.TIGERMUTWerewolf, v9, false))
table.insert(v, newEquipped(IdMap.Mutation.TIGERMUTWerewolf, v9, true))
table.insert(v, newIsAdorneeEquipped(IdMap.Moveset["Tiger-Tiger"], v9, false))
table.insert(v, newIsAdorneeEquipped(IdMap.Moveset["Werewolf (Tiger)-Werewolf (Tiger)"], v9, true))
local v10 = newTestData(
	"unequipMutaion",
	{},
	{ IdMap.Moveset["Yeti-Yeti"], IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTFiend },
	{ IdMap.Mutation.YETIMUTFiend }
)
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v10, false))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTFiend, v10, true))
local v11 = newTestData(
	"unequipMutation",
	{ IdMap.Moveset["Kitsune-Kitsune"], IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Moveset["Empyrean (Kitsune)-Empyrean (Kitsune)"] },
	{ IdMap.Mutation.KITSUNEMUTKyukon },
	{ IdMap.Mutation.KITSUNEMUTKyukon }
)
table.insert(v, newEquipped(IdMap.Mutation.KITSUNEMUTKitsune, v11, false))
local v12 = newTestData(
	"unequipMutation",
	{},
	{ IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTFiend },
	{ IdMap.Mutation.YETIMUTFiend }
)
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v12, false))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTYeti, v12, false))
table.insert(v, newUsable(IdMap.Mutation.YETIMUTYeti, v12, false))
local v13 = newTestData("equipDualDragonSkins", {}, { IdMap.Moveset["Dragon (East)-Dragon (East)"] }, {}, {})
table.insert(v, newUnlockable(IdMap.Skin.WSTDSKINvioletnight, v13, true))
table.insert(v, newUnlockable(IdMap.Skin.ESTDSKINvioletnight, v13, true))
local v14 = newTestData("unlockEclipse", { IdMap.Moveset["Dragon-Dragon"] }, {}, {}, {})
table.insert(v, newUnlockable(IdMap.Skin.ESTDSKINeclipse, v14, true))
table.insert(v, newUnlockable(IdMap.Skin.WSTDSKINeclipse, v14, true))
local v15 = newTestData(
	"unlockedDefaultSkin",
	{},
	{ IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTYeti, IdMap.Mutation.YETIMUTFiend },
	{ IdMap.Mutation.YETIMUTFiend }
)
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v15, true))
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v15, false))
table.insert(v, newUnlocked(IdMap.Skin.YETISKINfiend, v15, true))
local v16 = newTestData(
	"noUnlockedDefaultSkin",
	{},
	{ IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTFiend },
	{ IdMap.Mutation.YETIMUTFiend }
)
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v16, false))
table.insert(v, newEquippable(IdMap.Skin.YETISKINfiend, v16, false))
table.insert(v, newEquipped(IdMap.Skin.YETISKINfiend, v16, true))
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v16, true))
table.insert(v, newIsAdorneeEquipped(IdMap.Moveset["Yeti-Yeti"], v16, false))
table.insert(v, newIsAdorneeEquipped(IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"], v16, true))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTFiend, v16, true))
local v17 = newTestData("justEquipped", {}, { IdMap.Moveset["Yeti-Yeti"] }, {}, {})
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v17, true))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTYeti, v17, false))
table.insert(v, newUnlocked(IdMap.Skin.YETISKINfiend, v17, false))
table.insert(v, newUnequippable(IdMap.Mutation.YETIMUTYeti, v17, false))
local v18 = newTestData(
	"unlockedFiendSkin",
	{},
	{ IdMap.Moveset["Yeti-Yeti"], IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTFiend },
	{}
)
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v18, true))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTYeti, v18, false))
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v18, false))
table.insert(v, newUnequippable(IdMap.Mutation.YETIMUTFiend, v18, false))
local v19 = newTestData(
	"unlockedBothYetisAndDoubleEquipped",
	{},
	{ IdMap.Moveset["Yeti-Yeti"], IdMap.Moveset["Fiend (Yeti)-Fiend (Yeti)"] },
	{ IdMap.Mutation.YETIMUTFiend, IdMap.Mutation.YETIMUTYeti },
	{}
)
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v19, false))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTYeti, v19, true))
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTFiend, v19, false))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTFiend, v19, true))
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTYeti, v19, true))
table.insert(v, newEquipped(IdMap.Skin.YETISKINfiend, v19, true))
table.insert(v, newUnlocked(IdMap.Skin.YETISKINfiend, v19, true))
table.insert(v, newUnequippable(IdMap.Skin.YETISKINfiend, v19, false))
table.insert(v, newUnequippable(IdMap.Mutation.YETIMUTFiend, v19, true))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTFiend, v19, false))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTYeti, v19, false))
local v20 = newTestData(
	"unlockedBothYetisAndEquippedBase",
	{},
	{ IdMap.Moveset["Yeti-Yeti"] },
	{ IdMap.Mutation.YETIMUTFiend, IdMap.Mutation.YETIMUTYeti },
	{}
)
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTYeti, v20, false))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTYeti, v20, true))
table.insert(v, newUnlockable(IdMap.Mutation.YETIMUTFiend, v20, false))
table.insert(v, newUnlocked(IdMap.Mutation.YETIMUTFiend, v20, true))
table.insert(v, newUnlocked(IdMap.Skin.YETISKINfiend, v20, true))
table.insert(v, newEquippable(IdMap.Mutation.YETIMUTFiend, v20, true))
table.insert(v, newEquipped(IdMap.Skin.YETISKINfiend, v20, false))
table.insert(v, newUnequippable(IdMap.Skin.YETISKINfiend, v20, false))
table.insert(v, newUnequippable(IdMap.Mutation.YETIMUTYeti, v20, false))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTFiend, v20, false))
table.insert(v, newPreferred(IdMap.Mutation.YETIMUTYeti, v20, false))
local v21 = newTestData("getDefaultBombSkin", {}, {}, { IdMap.Skin.BOMBSKINazura }, {})
table.insert(v, newUsable(IdMap.Skin.BOMBSKINdefault, v21, true))
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v, function(p)
		local clone = table.clone(p)

		if clone.ModificationItemId then
			clone.ModificationItemId = ItemConfig.match(clone.ModificationItemId):unwrap().Index.DebugLabel
		end

		if clone.Data then
			clone.Data = {
				Modification = parentModule.Data.Modification.debug(p.Data.Modification),
				Adornee = parentModule.Data.Adornee.debug(p.Data.Adornee)
			}
			clone.Case = `{clone.Method}:{p.Data.Label}`
			clone.Method = nil
		end

		return clone
	end) }, function(data)
	if data.Method == "getIfCanUse" then
		return parentModule.getIfCanUse(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeUsable
	end

	if data.Method == "getIfCanEquip" then
		return parentModule.getIfCanEquip(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeEquippable
	end

	if data.Method == "getIfCanUnequip" then
		return parentModule.getIfCanUnequip(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeUnequippable
	end

	if data.Method == "getIfEquipped" then
		return parentModule.getIfEquipped(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeEquipped
	end

	if data.Method == "getIfUnlocked" then
		return parentModule.getIfUnlocked(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeUnlocked
	end

	if data.Method == "getIfCanUnlock" then
		return parentModule.getIfCanUnlock(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBeUnlockable
	end

	if data.Method == "getIfCanPurchase" then
		return parentModule.getIfCanPurchase(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBePurchasable
	end

	if data.Method == "getIfPreferred" then
		return parentModule.getIfPreferred(data.ModificationItemId, data.Data.Modification, data.Data.Adornee) == data.ShouldBePreferred
	end

	if data.Method == "getIfAdorneeEquipped" then
		return parentModule.getIfAdorneeEquipped(data.AdorneeId, data.Data.Adornee) == data.ShouldBeEquipped
	end

	error((`unknown case: {data.Method}`))
end, #v + 1)