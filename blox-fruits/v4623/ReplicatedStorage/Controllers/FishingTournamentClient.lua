local FishingTournamentClient = {}
local NPCTable = require(game.ReplicatedStorage.NPCTable)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local fishingTournament = IrisLog.new("FishingTournament", nil, {
	Hidden = true
})
local Summer25FishingTournament = require(game.ReplicatedStorage.Modules.Data.Summer25FishingTournament)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local Error = require(game.ReplicatedStorage.Packages.Error)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local v = nil
local v2 = nil
local v3 = nil
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local v4 = Signal.new()
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

-- equivalent calls inferred from this helper; original call sites unknown
local function log(p)
	task.spawn(function()
		local displayAsJson = Error.displayAsJson(p, 4, true)

		if isStudio then
			warn(`[{script.Name}]`, displayAsJson)
		end

		fishingTournament:Append(displayAsJson)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn(context)
	return v:InvokeServer({
		Context = context
	})
end

function FishingTournamentClient.getSummary()
	return Promise.new(function(callback, _, _)
		callback(fn("Summary"))
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function collectRewards()
	return fn("CollectAwards")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn2()
	return {
		Title = "Fishing Tournament NPC",
		Get = function(_)
			local v5 = v:InvokeServer({
				Context = "Summary",
				SpokeTournamentMaster = true
			})
			log(v5) -- equivalent call inferred; original call site unknown
			local timeUntil = TimeUtil.timeUntil(v5.TimeEnds, "long")
			local ranked = v5.Rank.Ranked == true

			if v5.IsEventEnabled and not v5.Tutorials.SpokeTournamentMaster then
				return {
					Text = {
						"Hi, I'm the fishing tournament NPC.",
						`I'm running a fishing tournament for the next {timeUntil}`,
						`Become one of the top {TextUtil.commaValue(Summer25FishingTournament.MAX_RANK_CUTOFF)} players in my tournament to win Fruit Boxes and a trophy.`,
						`In this tournament weigh your {Summer25FishingTournament.MIN_SUBMISSIONS} heaviest <{Summer25FishingTournament.EVENT_FISH.Name}> against the rest of the world.`,
						"Would you like to register for the challenge?"
					},
					Option1 = {
						Label = "Register",
						JumpTo = function()
							if ranked then
								return {
									Text = {
										`Nice! Your top {Summer25FishingTournament.MIN_SUBMISSIONS} <{Summer25FishingTournament.EVENT_FISH.Name}> weigh an average of {v5.Weight.Text}`,
										(`Become one of the top {TextUtil.commaValue(Summer25FishingTournament.MAX_RANK_CUTOFF)} fisherman by the end of this week to unlock special rewards!`)
									}
								}
							end

							return {
								Text = { (`Come back when you've caught {Summer25FishingTournament.MIN_SUBMISSIONS} <{Summer25FishingTournament.EVENT_FISH.Name}> to enter the tournament.`) }
							}
						end
					}
				}
			end

			if not v5.IsEventEnabled then
				return {
					Text = { (`The tournament has ended. {v5.Rank.Formatted}`) },
					Option1 = ranked and {
						Label = "Collect Rewards",
						JumpTo = function()
							local rewards = collectRewards() -- equivalent call inferred; original call site unknown

							if rewards == nil then
								return {
									Text = { "..." }
								}
							end

							return {
								Text = { rewards.Text }
							}
						end
					} or nil
				}
			end

			local option = not Summer25FishingTournament.AUTO_SUBMIT_FISH and {
				Label = "Submit Fish",
				JumpTo = function()
					local v7 = fn("SubmitFish") -- equivalent call inferred; original call site unknown

					if v7 == nil then
						return {
							Text = { "..." }
						}
					end

					return {
						Text = { v7.Text }
					}
				end
			} or nil
			return {
				Text = { (`Hi, I'm the fishing tournament NPC. Event ends in {timeUntil}! What would you like to do?`) },
				Option1 = {
					Label = "Shop",
					JumpTo = function()
						local NPCFishClient = require(game.ReplicatedStorage.FishReplicated.NPCFishClient)
						return NPCFishClient.FishermanDialogue()
					end
				},
				Option2 = {
					Label = "Check Rank",
					JumpTo = function()
						return {
							Text = { v5.Rank.Formatted }
						}
					end
				},
				Option3 = option
			}
		end
	}
end

FishingTournamentClient.FishTournamentNPC = fn2

function FishingTournamentClient.getLeaderboard()
	if not Summer25FishingTournament.EVENT_ENABLED then
		v3 = {}
	end

	if v3 then
		return Promise.resolve(v3)
	end

	return Promise.new(function(callback, _, _)
		v3 = v:InvokeServer({
			Context = "GetLeaderboard"
		})
		callback(v3)
	end)
end

function FishingTournamentClient.leaderboardUpdated(callback)
	return v4:Connect(callback)
end

function FishingTournamentClient.OnStart()
	if not Summer25FishingTournament.EVENT_ENABLED then
		return
	end

	v = Net:RemoteFunction("FishingTournament")
	v2 = Net:RemoteEvent("FishingTournament")
	task.spawn(function()
		local DialogueController = require(game.ReplicatedStorage.DialogueController)
		fishingTournament:AppendToTab(
			"NPC",
			fishingTournament:AuthorityButton("Tester", "Open Tournament Master Dialogue", function(_)
				DialogueController.start(fn2())
			end)
		)
		fishingTournament:AppendToTab(
			"Leaderboard",
			fishingTournament:AuthorityButton("Developer", "Print Leaderboard", function(_)
				FishingTournamentClient.getLeaderboard():andThen(function(p)
					log(p) -- equivalent call inferred; original call site unknown
				end)
			end)
		)
		NPCTable.onLoaded(function(p)
			p.new("Tournament Master NPC", fn2, 4)
		end)
	end)
	v2.OnClientEvent:Connect(function(p)
		if p == "UpdateLeaderboard" then
			v3 = v:InvokeServer({
				Context = "GetLeaderboard"
			})
			v4:Fire(v3)
		end
	end)
	v3 = v:InvokeServer({
		Context = "GetLeaderboard"
	})
	v4:Fire(v3)
end

return FishingTournamentClient