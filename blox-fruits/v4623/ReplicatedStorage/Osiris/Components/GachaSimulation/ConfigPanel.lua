local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Present = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Present)
local Runner = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Runner)
local Store = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)

local function toggleId(object, p: number)
	local clone = table.clone(object:get())
	local index = table.find(clone, p)

	if index == nil then
		table.insert(clone, p)
	else
		table.remove(clone, index)
	end

	object:set(clone)
end

local function callCount(p)
	local chunkFor, v = Runner.chunkFor(p)
	return math.ceil(p.SampleSize / math.max(1, chunkFor)), v
end

local function drawInventory(store, p)
	local v = store.ownedItemIds:get()
	Osiris.Widget.SameLine({}, function()
		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "own everything"
			}
		}).clicked() then
			local itemIds = table.create(#p.Entries)

			for _, entry in p.Entries do
				table.insert(itemIds, entry.ItemId)
			end

			store.ownedItemIds:set(itemIds)
		end

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "own nothing"
			}
		}).clicked() then
			store.ownedItemIds:set({})
		end

		Osiris.Widget.Text({
			Arguments = {
				Text = `{#v} owned`,
				Color = Present.MUTED
			}
		})
	end)
	Present.note("An owned item can change the box: entries gated on `HasItem` drop out, and others open up.")

	for _, rarity in p.Rarities do
		local v2 = rarity
		Osiris.Widget.Tree({
			Arguments = {
				Text = rarity
			}
		}, function()
			for k, entry in p.Entries do
				if entry.Rarity ~= v2 then
					continue
				end

				local v3 = table.find(v, entry.ItemId) ~= nil and "[x] " or "[ ] "

				if not Present.itemButton(entry, v3, Present.formatChance(entry.BaseChance)) then
					continue
				end

				toggleId(store.ownedItemIds, entry.ItemId)
			end
		end)
	end
end

local function drawLiveOps(store, p)
	local pickerOptions, v = Present.pickerOptions(p)

	if #pickerOptions == 0 then
		return
	end

	if v[store.pickerItem:get()] == nil then
		store.pickerItem:set(pickerOptions[1])
	end

	Osiris.Widget.Tree({
		Arguments = {
			Text = "Rate overrides"
		}
	}, function()
		Present.note("The live ops rate override, which pins an item's chance and renormalises everything else.")
		Osiris.Widget.ComboArray({
			Arguments = {
				Text = "item"
			},
			States = {
				index = store.pickerItem
			},
			Extra = {
				selectionArray = pickerOptions
			}
		})
		Osiris.Widget.SliderNum({
			Arguments = {
				Text = "chance",
				Min = 0,
				Max = 1,
				Increment = 0.0001,
				Format = "%.4f"
			},
			States = {
				number = store.pickerValue
			}
		})
		Osiris.Widget.SameLine({}, function()
			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "set override"
				}
			}).clicked() then
				local v2 = v[store.pickerItem:get()]

				if v2 ~= nil then
					local clone = table.clone(store.rateOverrides:get())
					clone[v2] = math.clamp(store.pickerValue:get(), 0, 1)
					store.rateOverrides:set(clone)
				end
			end

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = "clear all"
				}
			}).clicked() then
				store.rateOverrides:set({})
			end
		end)

		for k, v2 in store.rateOverrides:get() do
			local v4 = p.ById[k]
			local v5 = k
			local v6 = v2
			Osiris.Widget.SameLine({}, function()
				if v4 ~= nil then
					Present.icon(v4.Sprite, 18)
				end

				if Osiris.Widget.SmallButton({
					Arguments = {
						Text = `remove {Present.labelOf(p, v5)}`
					}
				}).clicked() then
					local clone = table.clone(store.rateOverrides:get())
					clone[v5] = nil
					store.rateOverrides:set(clone)
				end

				Osiris.Widget.Text({
					Arguments = {
						Text = Present.formatChance(v6),
						Color = Present.MUTED
					}
				})
			end)
		end
	end)
	Osiris.Widget.Tree({
		Arguments = {
			Text = "Banner item"
		}
	}, function()
		Present.note("Banner ids have their chance pinned outright. The cheater chance replaces it once any cheat flag is set.")

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "add current pick"
			}
		}).clicked() then
			local v2 = v[store.pickerItem:get()]

			if v2 ~= nil then
				toggleId(store.bannerItemIds, v2)
			end
		end

		Osiris.Widget.SliderNum({
			Arguments = {
				Text = "banner chance",
				Min = 0,
				Max = 1,
				Increment = 0.0001,
				Format = "%.4f"
			},
			States = {
				number = store.bannerChance
			}
		})
		Osiris.Widget.SliderNum({
			Arguments = {
				Text = "cheater chance",
				Min = 0,
				Max = 1,
				Increment = 0.0001,
				Format = "%.4f"
			},
			States = {
				number = store.bannerCheaterChance
			}
		})

		for _, v2 in store.bannerItemIds:get() do
			local v3 = p.ById[v2]

			if v3 ~= nil and Present.itemButton(v3, "[x] ", "") then
				toggleId(store.bannerItemIds, v2)
			end
		end
	end)
	Osiris.Widget.Tree({
		Arguments = {
			Text = "Coming soon"
		}
	}, function()
		Present.note("A coming soon product zeroes itself and everything bought with it.")
		local v2 = store.comingSoonProducts:get()

		for _, entry in p.Entries do
			local v3 = table.find(v2, entry.ItemId) ~= nil

			if Present.itemButton(entry, v3 and "[x] " or "[ ] ", "") then
				toggleId(store.comingSoonProducts, entry.ItemId)
			end
		end
	end)
	Osiris.Widget.InputText({
		Arguments = {
			Text = "cheat flag",
			TextHint = "leave empty for an honest player"
		},
		States = {
			text = store.cheatFlag
		}
	})
end

return function(p)
	local store = p.Store
	local context = p.Context
	local v = store.pool:get()
	local v2 = store.job:get()
	local busy = Runner.isBusy(store)
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Box"
		}
	})
	Osiris.Widget.ComboArray({
		Arguments = {
			Text = "box"
		},
		States = {
			index = store.boxName
		},
		Extra = {
			selectionArray = context.BoxNames
		}
	})
	Osiris.Widget.SameLine({}, function()
		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "re-solve pool"
			}
		}).clicked() and not busy then
			Runner.probe(store, context)
		end

		if v ~= nil then
			Osiris.Widget.Text({
				Arguments = {
					Text = `{#v.Entries} items`,
					Color = Present.MUTED
				}
			})
		end
	end)

	if v ~= nil then
		Present.stat("soft pity key", v.SoftPityKey or "none on this box")
		Present.stat("hard pity key", v.HardPityKey or "none on this box")
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Sample"
		}
	})
	Osiris.Widget.SliderNum({
		Arguments = {
			Text = "pulls",
			Min = 10,
			Max = store.Arguments.MaxSampleSize or 5000,
			Increment = 10,
			Format = "%d"
		},
		States = {
			number = store.sampleSize
		}
	})
	Osiris.Widget.SliderNum({
		Arguments = {
			Text = "rolls per pull",
			Min = 1,
			Max = 10,
			Increment = 1,
			Format = "%dx"
		},
		States = {
			number = store.pullCount
		}
	})
	Osiris.Widget.Checkbox({
		Arguments = {
			Text = "fresh player each pull"
		},
		States = {
			isChecked = store.freshPlayer
		}
	})

	if store.freshPlayer:get() then
		Present.note("Pity and inventory reset before every pull, so the observed rates test the advertised chances.")
	else
		Osiris.Widget.Checkbox({
			Arguments = {
				Text = "winnings stay in the inventory"
			},
			States = {
				isChecked = store.accumulateOwned
			}
		})
		Present.note("One player pulling over and over: pity carries, and anything won is owned from then on.")
	end

	Osiris.Widget.Checkbox({
		Arguments = {
			Text = "snapshot chances as they change"
		},
		States = {
			isChecked = store.trackEvolution
		}
	})

	if store.trackEvolution:get() and not store.freshPlayer:get() then
		Osiris.Widget.SliderNum({
			Arguments = {
				Text = "snapshot every",
				Min = 1,
				Max = 50,
				Increment = 1,
				Format = "%d pulls"
			},
			States = {
				number = store.evolutionStride
			}
		})
	end

	local snapshot = Store.snapshot(store)
	local chunkFor, v3 = Runner.chunkFor(snapshot)
	local v4 = math.ceil(snapshot.SampleSize / math.max(1, chunkFor))
	Present.stat("solver calls", (`{v4}`))
	Present.note(v3)
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Player"
		}
	})
	Osiris.Widget.SliderNum({
		Arguments = {
			Text = "level",
			Min = 1,
			Max = 3000,
			Increment = 1,
			Format = "%d"
		},
		States = {
			number = store.level
		}
	})
	Osiris.Widget.InputNum({
		Arguments = {
			Text = "starting soft pity",
			Min = 0,
			Max = 10000,
			Increment = 1,
			Format = "%d"
		},
		States = {
			number = store.softPity
		}
	})
	Osiris.Widget.InputNum({
		Arguments = {
			Text = "starting hard pity",
			Min = 0,
			Max = 10000,
			Increment = 1,
			Format = "%d"
		},
		States = {
			number = store.hardPity
		}
	})

	if v == nil then
		Present.note("Solving the box...")
	else
		Osiris.Widget.SeparatorText({
			Arguments = {
				Text = "Inventory"
			}
		})
		drawInventory(store, v)
		Osiris.Widget.SeparatorText({
			Arguments = {
				Text = "Live ops"
			}
		})
		drawLiveOps(store, v)
	end

	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Run"
		}
	})
	Osiris.Widget.SameLine({}, function()
		if v2.Status == "Running" then
			if Osiris.Widget.Button({
				Arguments = {
					Text = "cancel"
				}
			}).clicked() then
				Runner.cancel(store)
			end
		elseif v2.Status == "Probing" then
			Osiris.Widget.Text({
				Arguments = {
					Text = "solving...",
					Color = Present.MUTED
				}
			})
		elseif Osiris.Widget.Button({
			Arguments = {
				Text = "run simulation"
			}
		}).clicked() then
			Runner.run(store, context)
		end

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "clear result"
			}
		}).clicked() and not busy then
			store.result:set(nil)
		end
	end)
	Osiris.Widget.ProgressBar({
		Arguments = {
			Text = "progress"
		},
		States = {
			progress = store.progress
		}
	})
	local text = Osiris.Widget.Text
	local arguments = {
		Text = v2.Message,
		Color = 0,
		Wrapped = true
	}
	local color

	if v2.Status == "Failed" then
		color = Present.BAD
	else
		color = Present.MUTED
	end

	arguments.Color = color
	text({
		Arguments = arguments
	})
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Compare"
		}
	})
	Present.note("Pin the chances this config solves to, then dial something else and pin that, to see what moved.")
	Osiris.Widget.InputText({
		Arguments = {
			Text = "scenario name",
			TextHint = Store.describe(snapshot)
		},
		States = {
			text = store.scenarioName
		}
	})
	Osiris.Widget.SameLine({}, function()
		if Osiris.Widget.Button({
			Arguments = {
				Text = "pin scenario"
			}
		}).clicked() and not busy then
			local v8 = store.scenarioName:get()

			if #v8 == 0 then
				v8 = Store.describe(snapshot)
			end

			Runner.pin(store, context, v8)
			store.scenarioName:set("")
		end

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "clear scenarios"
			}
		}).clicked() then
			store.scenarios:set({})
			store.scenarioIndex:set(0)
		end
	end)
end