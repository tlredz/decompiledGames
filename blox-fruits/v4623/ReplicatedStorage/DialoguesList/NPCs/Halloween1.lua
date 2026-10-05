require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Death King",
	Get = function(_)
		return {
			Text = { "Hey, got some bones?" },
			Option1 = {
				Label = "Yeah",
				JumpTo = function()
					return ((function(p)
						local v, v2, v3, v4, v5 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
						local v6

						if v == 1 then
							v6 = 1 .. " Bone"
						else
							v6 = v .. " Bones"
						end

						if v3 <= 0 then
							Util.playAction("Negative")
							return {
								Text = { "You currently have " .. v3 .. " purchases left. Come back in " .. v4 .. " minutes." }
							}
						end

						local result = {
							Text = { "You currently have <Color=Orange>" .. v6 .. "<Color=/>. You can only purchase up to " .. v5 .. " times every 2 hours. You currently have " .. v3 .. " purchase(s) left." }
						}
						local v7 = v2[p]

						for k, v8 in pairs(v7) do
							local v9 = v8
							local v10 = k
							result["Option" .. k] = {
								Label = v8[1],
								JumpTo = function()
									return {
										Text = { "Would you like to buy <" .. v9[1] .. "> for <Color=Orange>" .. v9[2] .. " Bones<Color=/>?" },
										Option1 = {
											Label = "Buy",
											JumpTo = function()
												local v11 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"Bones",
													"Buy",
													p,
													v10
												)

												if v11 == 1 then
													Util.playAction("Positive")
													return {
														Text = { "[Trade completed.]" }
													}
												elseif v11 == 2 then
													Util.playAction("Negative")
													return {
														Text = { "[You don't have enough bones.]" }
													}
												elseif v11 == 3 then
													Util.playAction("Negative")
													return {
														Text = { "[You already have this item.]" }
													}
												end

												if v11 then
													return {
														Text = { v11 }
													}
												end

												return {
													Text = { "[Error.]" }
												}
											end
										},
										Option2 = {
											Label = "Return",
											JumpTo = function()
												return result
											end
										}
									}
								end
							}
						end

						return result
					end)(1))
				end
			}
		}
	end
}