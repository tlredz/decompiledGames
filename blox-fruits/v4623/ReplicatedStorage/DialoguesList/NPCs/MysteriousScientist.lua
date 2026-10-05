local Realm = require(game.ReplicatedStorage.Util.Realm)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Mysterious Scientist",
	Get = function(p)
		local adminPanel = game.ReplicatedStorage.DialoguesList:FindFirstChild("AdminPanel")

		if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
			local option

			if adminPanel then
				local module = require(adminPanel)
				option = module.option(p) or nil
			end

			return {
				Text = { "Welcome." },
				Option1 = option
			}
		else
			local v = {
				Text = { "Welcome." },
				Option1 = {
					Label = "Talk",
					JumpTo = function()
						return ((function()
							local v2 = nil

							local function call(p2, p3)
								return {
									Text = { not p3 and "Would you like to trade a physical fruit for a Special Microchip? <Color=Yellow>Alternatively, you can purchase them for<Color=/> <Color=Green>$100,000<Color=/> <Color=Yellow>every 2 hours.<Color=/>" or ("Would you like to trade a <Color=Green>$1M+<Color=/> physical fruit for a <%s> Special Microchip? <Color=Yellow>Alternatively, you can purchase them for <Color=Purple>ƒ1,000<Color=/> every 2 hours.<Color=/>"):format(p2) },
									Option1 = {
										Label = "Trade/Buy",
										JumpTo = function()
											local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
												"RaidsNpc",
												"Select",
												p2
											)

											if v3 == 1 then
												Util.playAction("Explain")
												return {
													Text = { "Thank you. By the way, if you use the <Color=Yellow><" .. p2 .. "><Color=/> fruit to clear this raid, you may find yourself in a mysterious location." }
												}
											elseif v3 == 0 then
												Util.playAction("Negative")
												return {
													Text = { "[You must be Level 1100 to do this.]" }
												}
											end

											if typeof(v3) == "string" then
												return {
													Text = { v3 }
												}
											end

											return {
												Text = { "..." }
											}
										end
									},
									Option2 = {
										Label = "Back",
										JumpTo = function()
											return v2
										end
									}
								}
							end

							local function GetRaidText(p2, p3)
								local Raids = require(game.ReplicatedStorage.Raids)
								local advancedRaids

								if p2 then
									advancedRaids = Raids.advancedRaids
								else
									advancedRaids = Raids.raids
								end

								local v3 = math.ceil(#advancedRaids / 2)
								local GetNextPage

								GetNextPage = function(p4)
									local v5 = p4 * 2 - 1
									local v4 = {
										Text = { ("Select a raid theme. (%s/%s)"):format(p4, v3) },
										Option1 = {
											Label = p2 and not p3[advancedRaids[v5]] and "LOCKED" or advancedRaids[v5],
											Text = { "" },
											JumpTo = function()
												if p2 and not p3[advancedRaids[v5]] then
													return {
														Text = { "..." }
													}
												end

												return (call(advancedRaids[v5], p2))
											end
										}
									}

									if advancedRaids[v5 + 1] then
										v4.Option2 = {
											Label = p2 and not p3[advancedRaids[v5 + 1]] and "LOCKED" or advancedRaids[v5 + 1],
											Text = { "" },
											JumpTo = function()
												if p2 and not p3[advancedRaids[v5 + 1]] then
													return {
														Text = { "..." }
													}
												end

												return (call(advancedRaids[v5 + 1], p2))
											end
										}

										if v3 > 1 then
											v4.Option3 = {
												Label = "Next",
												JumpTo = function()
													if p4 == v3 then
														return v2
													end

													return GetNextPage(p4 + 1)
												end
											}
											return v4
										end
									elseif v3 > 1 then
										v4.Option2 = {
											Label = "Next",
											Text = { "" },
											JumpTo = function()
												return v2
											end
										}
									end

									return v4
								end

								v2 = GetNextPage(1)
								return v2
							end

							local v3, v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Check")

							if v3 == 0 then
								Util.playAction("Negative")
								return {
									Text = { "[You must be at least Level 1100 to do this.]" }
								}
							end

							if not v3 then
								return {
									Text = { "..." }
								}
							end

							local flag = false

							for _, v6 in pairs(v4) do
								if not v6 then
									continue
								end

								flag = true
								break
							end

							return {
								Text = { "Select a raid type." },
								Option1 = {
									Label = "Normal",
									Text = { "" },
									JumpTo = function()
										return (GetRaidText())
									end
								},
								Option2 = {
									Label = flag and "Advanced" or "LOCKED",
									Text = { "" },
									JumpTo = function()
										if flag then
											return (GetRaidText(true, v4))
										end

										Util.playAction("Negative")
										return {
											Text = { "You have done nothing for us scientists." }
										}
									end
								}
							}
						end)())
					end
				},
				Option2 = 0
			}
			local option

			if adminPanel then
				local module = require(adminPanel)
				option = module.option(p) or nil
			end

			v.Option2 = option
			return v
		end
	end
}