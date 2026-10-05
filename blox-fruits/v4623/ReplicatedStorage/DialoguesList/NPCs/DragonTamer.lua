local GetFruitName = require(game.ReplicatedStorage.Modules.Asset.GetFruitName)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local DragonNames = require(game.ReplicatedStorage.Modules.Asset.DragonNames)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("DragonTamer"):tag("Equipment"):tag("NPC"):tag("Dialogue"):display():traceback():build()
require(game.ReplicatedStorage.DialoguesList.Types)
require(script.Types)
local commF_ = game.ReplicatedStorage.Remotes.CommF_

function createBook(data)
	assert(data.label)
	assert(data.list)
	assert(data.text)
	assert(data.optionSelected)
	local v2 = {
		currentPageNumber = 1,
		list = data.list,
		pages = {}
	}
	local v3 = math.ceil(#data.list / 2)
	v2.totalPages = #data.list <= 3 and 1 or v3
	local v4 = {
		Text = { data.text(v2) }
	}
	v2.pages[1] = v4
	local v5 = 1
	local v6 = 1

	for i = 1, #v2.list do
		local v7 = v2.list[i]
		v4[`Option{v5}`] = {
			Label = data.label(v2, v7),
			JumpTo = function()
				return data.optionSelected(v2, v7)
			end
		}
		v5 += 1

		if v2.totalPages == 1 then
			continue
		end

		if v2.list[i + 1] and v5 == 3 then
			v6 += 1
			local v9 = {
				Text = { "..." }
			}
			local currentPageNumber = v6
			v4[`Option{3}`] = {
				Label = "Next",
				JumpTo = function()
					v2.currentPageNumber = currentPageNumber
					v9.Text = { data.text(v2) }
					return v9
				end
			}
			v2.pages[v6] = v9
			v4 = v9
			v5 = 1
		elseif not v2.list[i + 1] then
			v4[`Option{v5}`] = {
				Label = "Back",
				JumpTo = function()
					v2.currentPageNumber = 1
					return v2.pages[1]
				end
			}
		end
	end

	return v2
end

function sellDragonFruitEquipment(_, items)
	local v2 = nil
	local fn

	fn = function(p: string, value: number?)
		local fruitName = GetFruitName(p)

		if not v2.IsFruitAccessible then
			return {
				Text = { (`[Purchase or equip <Color=Yellow><{fruitName}><Color=/> to buy upgrades for it.]`) },
				Option1 = {
					Label = "Purchase",
					JumpTo = function()
						commF_:InvokeServer("buyRobuxShop", (`Permanent {p}`))
						return {
							Text = { "..." }
						}
					end
				}
			}
		end

		if v2.Mastery.Current < v2.Mastery.Min then
			return {
				Text = { (`Your connection to the <Color=Yellow><{fruitName}><Color=/> fruit is still weak. Strengthen it by reaching <Color=Red>{v2.Mastery.Min} Mastery<Color=/>, and the path forward will reveal itself.`) }
			}
		end

		local fn2
		local book = createBook({
			list = v2.Equipment,
			label = function(_, p2)
				return p2.DisplayName
			end,
			text = function(_)
				if v2.Description then
					return v2.Description
				end

				return (`The power of your <Color=Yellow><{fruitName}><Color=/> fruit is incomplete. Shall I unlock it for you?`)
			end,
			optionSelected = function(_, p2)
				return fn2(p2)
			end
		})

		fn2 = function(data)
			v2 = commF_:InvokeServer("getEquipmentForFruit", p)

			if not v2 then
				return {
					Text = { "..." }
				}
			end

			for _, v5 in pairs(v2.Equipment) do
				if v5.StorageName ~= data.StorageName then
					continue
				end

				data = v5
				break
			end

			local v5 = {
				Unlock = {
					StorageName = data.StorageName,
					Type = "FruitEquipment",
					Context = "Purchase"
				},
				Enable = {
					StorageName = data.StorageName,
					Type = "FruitEquipment",
					Equip = true,
					Context = "Equip"
				},
				Disable = {
					StorageName = data.StorageName,
					Type = "FruitEquipment",
					Equip = false,
					Context = "Equip"
				}
			}
			local v6, label

			if data.IsEquipmentEquipped then
				v6 = "<Color=Green>enabled<Color=/>"
				label = "Disable"
			elseif data.IsEquipmentOwned then
				v6 = "<Color=Red>disabled<Color=/>"
				label = "Enable"
			else
				v6 = "locked"
				label = "Unlock"
			end

			local v8 = `{data.DisplayName} is currently {v6}.\nThis upgrade ` .. data.Description

			if label == "Unlock" then
				local v9 = v8 .. "\nI can unlock it for the cost of "

				if data.Requirements.Fragments then
					v9 ..= `<Color=Purple>ƒ{TextUtil.commaValue(data.Requirements.Fragments)}<Color=/>`
				end

				if data.Requirements.Beli then
					v9 ..= `<Color=Green>${TextUtil.commaValue(data.Requirements.Beli)}<Color=/>`
				end

				if data.Requirements.EtcItems then
					local v10 = ""

					for _, etcItem in pairs(data.Requirements.EtcItems) do
						v10 ..= ` <Color=Yellow>{etcItem.Amount} {etcItem.Name}{etcItem.Amount > 1 and "s" or ""}<Color=/>`
					end

					v9 ..= ` and{v10}`
				end

				v8 = v9 .. "."
			end

			return {
				Text = { v8 },
				Option2 = {
					Label = "Back",
					JumpTo = function()
						return fn(p, book.currentPageNumber)
					end
				},
				Option1 = {
					Label = label,
					JumpTo = function()
						local _, v9 = commF_:InvokeServer("updateEquipment", v5[label])

						if v9 then
							return {
								Text = { v9 }
							}
						end

						return fn2(data)
					end
				}
			}
		end

		return book.pages[value or 1]
	end

	local count = 0
	local v3 = nil

	for _, item in pairs(items) do
		local v4 = commF_:InvokeServer("getEquipmentForFruit", item)
		local v5 = item
		v.trace(function()
			return `thisResult for {v5}`, v4
		end)

		if not (v4 and v4.IsFruitAccessible) then
			continue
		end

		count += 1

		if not v4.IsFruitEquipped then
			continue
		end

		v2 = v4
		v3 = item
	end

	local v4 = count == 2

	if v3 then
		return fn(v3)
	end

	if v4 then
		return {
			Text = { "Greetings, traveler. I see you are not bonded with the power of the <Color=Yellow><Dragon><Color=/> fruit. Only those who wield its might can proceed..." }
		}
	end

	return {
		Text = { "Greetings, traveler. I see you are not bonded with the power of the <Color=Yellow><Dragon><Color=/> fruit. Only those who wield its might can proceed..." },
		Option1 = {
			Label = "Purchase",
			JumpTo = function()
				commF_:InvokeServer("buyRobuxShop", "Permanent Dragon-Dragon")
				return {
					Text = { "..." }
				}
			end
		}
	}
end

return {
	Title = "Dragon Tamer",
	Get = function(p)
		return sellDragonFruitEquipment(p, { DragonNames.East, DragonNames.West })
	end
}