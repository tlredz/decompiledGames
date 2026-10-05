local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(script.GreenTea)
local v2 = require3(script.Actions)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local createActions = v2.createActions
local createServerAction = v2.createServerAction
local _ = v2.createClientAction
local createSharedAction = v2.createSharedAction
local string = v.string({
	limits = "[1, 21]",
	unicode = true
})
local string2 = v.string({
	unicode = true
})
local anyTable = v.anyTable()
local literal = v.t.literal("Ability", "Sword", "Explosion", "Emote", "Booth")

local function t(...)
	local v3 = table.pack(...)
	return function()
		return table.unpack({ table.unpack(v3, 1, v3.n) })
	end
end

return table.freeze({
	Permissions = require3(script.Permissions),
	Actions = createActions({
		GetPermissions = createServerAction({
			Permissions = {},
			Input = t(v.none()),
			Output = t(v.array(v.string()))
		}),
		LoadUser = createSharedAction({
			Server = {
				Permissions = { "Session.Create" },
				Input = t(v.number({
					integer = true,
					nan = false,
					range = {
						min = 1,
						max = 1e999
					}
				})),
				Output = t(v.optional(v.table({
					UserId = v.number(),
					SessionId = v.string({
						unicode = true
					})
				})))
			},
			Client = {
				Permissions = { "Session.Create" },
				Input = t(v.tuple(v.table({
					UserId = v.number(),
					SessionId = v.string({
						unicode = true
					})
				}), v.optional(v.string())))
			}
		}),
		Reload = createServerAction({
			Permissions = { "Session.Create" },
			Input = t(v.none()),
			Output = t(v.optional(v.boolean()))
		}),
		CloseSession = createServerAction({
			Permissions = { "Session.Create" },
			Input = t(v.none()),
			Output = t(v.optional(v.boolean()))
		}),
		Follow = createServerAction({
			Permissions = { "Session.Follow" },
			Input = t(v.none()),
			Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
		}),
		Save = createServerAction({
			Permissions = { "Session.Save" },
			Input = t(v.none()),
			Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
		}),
		Inventory = createActions({
			Add = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.table({
					Type = literal,
					Name = string2,
					Attributes = anyTable
				})),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			BatchAdd = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.dictionary(literal, v.array(v.table({
					Name = string2,
					Attributes = anyTable
				})))),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			Modify = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.table({
					Type = literal,
					UUID = string,
					Attributes = anyTable
				})),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			BatchModify = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.dictionary(literal, v.dictionary(string, anyTable))),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			Remove = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.table({
					Type = literal,
					UUID = string
				})),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			BatchRemove = createServerAction({
				Permissions = { "Inventory.Write" },
				Input = t(v.dictionary(literal, v.array(string))),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			GrantTokens = createServerAction({
				Permissions = { "Inventory.GrantTokens" },
				Input = t(v.number({
					integer = true,
					nan = false,
					range = {
						min = -1e999,
						max = 25000
					}
				})),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			})
		}),
		Trade = createActions({
			History = createServerAction({
				Permissions = { "TradeHistory.Read" },
				Input = t(v.table({
					Type = v.t.literal("Trade", "Booth"),
					Page = v.number({
						integer = true,
						nan = false
					})
				})),
				Output = t(v.tuple(v.optional(v.boolean()), (v.optional(v.union(v.array(v.any()), v.string())))))
			})
		}),
		Moderation = createActions({
			Ban = createServerAction({
				Permissions = { "Moderation.Ban" },
				Input = t(v.table({
					Reason = v.opt(v.string()),
					Duration = v.opt(v.number({
						integer = true
					}))
				})),
				Output = t(v.optional(v.boolean()))
			}),
			Unban = createServerAction({
				Permissions = { "Moderation.Unban" },
				Input = t(v.none()),
				Output = t(v.optional(v.boolean()))
			}),
			SetTradeBanned = createServerAction({
				Permissions = { "Moderation.TradeBan" },
				Input = t(v.boolean()),
				Output = t(v.optional(v.boolean()))
			}),
			SetRankedBanned = createServerAction({
				Permissions = { "Moderation.RankedBan" },
				Input = t(v.boolean()),
				Output = t(v.optional(v.boolean()))
			}),
			SetLeaderboardBanned = createServerAction({
				Permissions = { "Moderation.LeaderboardBan" },
				Input = t(v.boolean()),
				Output = t(v.optional(v.boolean()))
			}),
			WipeLeaderboards = createServerAction({
				Permissions = { "Moderation.WipeLeaderboards" },
				Input = t(v.dictionary(v.string(), v.boolean())),
				Output = t(v.optional(v.boolean()))
			}),
			ResetTradePIN = createServerAction({
				Permissions = { "Trade.ResetPIN" },
				Input = t(v.none()),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.string())))
			}),
			SyncBanHistory = createServerAction({
				Permissions = { "Moderation.Ban" },
				Input = t(v.none()),
				Output = t(v.optional(v.any()))
			})
		}),
		Leaderboards = createActions({
			Get = createServerAction({
				Permissions = { "Leaderboards.Read" },
				Input = t(v.string()),
				Output = t(v.tuple(v.optional(v.boolean()), v.optional(v.array(v.table({
					key = v.string(),
					value = v.any()
				})))))
			})
		})
	})
})