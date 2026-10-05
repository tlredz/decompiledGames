local DragonNames = require(game.ReplicatedStorage.Modules.Asset.DragonNames)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local Net = require(game.ReplicatedStorage.Modules.Net)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local remoteFunction = Net:RemoteFunction("Craft")
return {
	Title = "Dragon Hunter",
	Get = function(_)
		local fn

		fn = function(p)
			local v = p or Net:RemoteFunction("DragonHunter"):InvokeServer({
				Context = "Check"
			})

			if v.Text == nil then
				return {
					Text = { (`<Color=Yellow>Dragon Embers<Color=/> are remnants of a dying flame, brimming with untold power waiting to ignite again... Would you like to find some?{v.CancelQuest and ` <Color=Red>Your <{v.CancelQuest}> quest will be abandoned!<Color=/>` or ""}`) },
					Option1 = {
						Label = "Sure",
						JumpTo = function()
							Net:RemoteFunction("DragonHunter"):InvokeServer({
								Context = "RequestQuest"
							})
							return fn()
						end
					}
				}
			end

			return {
				Text = { v.Text }
			}
		end

		local function craft(p)
			local v = remoteFunction:InvokeServer("Check", p)

			if not v then
				return {
					Text = { "..." }
				}
			end

			Util.promptCraftAndWaitForGuiToClose(v.Required, v.Result, v.ResultStats)
			return {
				Text = { "..." }
			}
		end

		local function craftList()
			local v = {
				{ "Dragonheart", "Dragonheart" },
				{ "Dragonstorm", "Dragonstorm" },
				{ "Volcanic Magnet", "Volcanic Magnet" }
			}
			local result = {
				Text = { "Select a recipe." }
			}

			for i = 1, #v do
				local v2 = remoteFunction:InvokeServer("PossibleHardcode", v[i][2])
				local v4 = i
				result["Option" .. i] = {
					Label = v2 ~= true and "LOCKED" or v[i][1],
					JumpTo = function()
						if v2 == true then
							return (craft(v[v4][2]))
						end

						Util.playAction("Negative")
						return {
							Text = { "You lack the requirements to craft this item." }
						}
					end
				}
			end

			return result
		end

		local v = Net:RemoteFunction("DragonHunter"):InvokeServer({
			Context = "Check"
		})

		if not v then
			return {
				Text = { "..." }
			}
		end

		if v == "Locked" then
			return {
				Text = { "Listen well, fledgling. I only train those who've grasped the foundations of what this dojo offers. Prove you're worthy, or don't waste my time." }
			}
		end

		return {
			Text = { "Dragons leave behind embers in their tracks. As a hunter, my job is to track them down for us to study." },
			Option1 = {
				Label = "Hunt",
				JumpTo = function()
					return fn(v)
				end
			},
			Option2 = {
				Label = "Craft",
				JumpTo = function()
					return (craftList())
				end
			},
			Option3 = {
				Label = "Gacha",
				JumpTo = function()
					local function formatCost(purchase)
						local description = ""
						local materials = ""
						local beli = ""
						local fragments

						if purchase.Fragments then
							fragments = `<Color=Purple>ƒ{TextUtil.commaValue(purchase.Fragments)}<Color=/>`
							description = `{description}\n- {fragments}\n`
						else
							fragments = ""
						end

						if purchase.Beli then
							beli = `<Color=Green>${TextUtil.commaValue(purchase.Beli)}<Color=/>`
							description = `{description}\n- {beli}\n`
						end

						if purchase.EtcItems then
							for _, etcItem in pairs(purchase.EtcItems) do
								local v6 = string.sub(etcItem.Name, #etcItem.Name)
								materials ..= `- <Color=Yellow>{etcItem.Amount} {etcItem.Name}{etcItem.Amount > 1 and v6 ~= "s" and "s" or ""}<Color=/>\n`
							end

							description = `{description}\n{materials}`
						end

						return {
							Description = description,
							Materials = materials,
							Fragments = fragments,
							Beli = beli
						}
					end

					local skin = v.Skin

					if skin and skin.Context == "Purchase" then
						return {
							Text = {
								"Looking to change your appearance? I can craft a random <Dragon> skin recipe for you.",
								"Hand over the following requirements: " .. formatCost(skin.Purchase).Description
							},
							Option1 = {
								Label = "Exchange",
								JumpTo = function()
									local v2, v3 = Net:RemoteFunction("DragonHunter"):InvokeServer({
										Context = "PurchaseRecipe"
									})

									if v2 then
										Util.playAction("Positive")
										return {
											Text = { "Thanks for your business." }
										}
									end

									if not v3 or v3.Context ~= "Material" then
										return {
											Text = { "..." }
										}
									end

									Util.playAction("Negative")
									return {
										Text = { "[Not enough materials.]" }
									}
								end
							}
						}
					end

					if skin then
						if skin.Context == "Complete" then
							return {
								Text = { "I don't got any more recipes for you." }
							}
						end

						if skin.Context == "Quest" then
							return {
								Text = { "Prove your worth by completing more quests from the Dojo Trainer." }
							}
						end

						if skin.Context == "Fruit" then
							Util.playAction("Explain")

							local function getDisplayName(name: string)
								local nullable = ItemConfig.Query.selectOne({
									Index = {
										StorageKey = name
									}
								}):asNullable()

								if nullable then
									name = nullable.Display.Name

									if not name then
										return nullable.Index.StorageKey
									end
								end

								return name
							end

							local text

							if skin.Fruit then
								text = { (`[Purchase <Color=Yellow><Dragon><Color=/> or equip <Color=Yellow><{getDisplayName(skin.Fruit)}><Color=/> to access extra rewards.]`) }
							else
								text = { (`[Purchase <Color=Yellow><Dragon><Color=/> or equip <Color=Yellow><{getDisplayName(DragonNames.East)}><Color=/> or <Color=Yellow><{getDisplayName(DragonNames.West)}><Color=/> to access extra rewards.]`) }
							end

							return {
								Text = text,
								Option1 = {
									Label = "Purchase",
									JumpTo = function()
										game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"buyRobuxShop",
											"Permanent Dragon-Dragon"
										)
										return {
											Text = { "..." }
										}
									end
								}
							}
						elseif skin.Context == "Material" then
							Util.playAction("Negative")
							return {
								Text = { "[Not enough materials.]" }
							}
						end
					end

					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}