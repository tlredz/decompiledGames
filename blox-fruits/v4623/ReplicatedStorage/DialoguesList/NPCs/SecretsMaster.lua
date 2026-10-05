require(game.ReplicatedStorage.DialoguesList.Types)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local remoteFunction = Net:RemoteFunction("RequestSecretStories")
local remoteFunction2 = Net:RemoteFunction("RequestBonusMomentReplication")
local remoteFunction3 = Net:RemoteFunction("RequestNextRaidHint")

local function getRaidHintAsync()
	local success, result = pcall(function()
		return remoteFunction3:InvokeServer()
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return nil
end

local function describeRaidHint(result)
	local result2 = {}

	if result.State == "Arming" then
		table.insert(result2, (`{result.Boss} is about to stir over on {result.Island}.`))
		table.insert(result2, "You should already be moving.")
		return result2
	elseif result.State == "Armed" or result.State == "Triggered" then
		table.insert(result2, (`Too late for secrets - {result.Boss} is already on his feet over on {result.Island}.`))
		table.insert(result2, "Go on, before someone else gets there first.")
		return result2
	elseif result.State == "Deferred" then
		table.insert(
			result2,
			(`{result.Boss} is waiting to stir over on {result.Island}, but another fight is blocking the way.`)
		)
		table.insert(result2, "Once the island settles, it won't wait long.")
		return result2
	else
		local v = math.max(1, (math.ceil(result.Seconds / 60)))
		table.insert(result2, (`Keep this between us: the next one to stir will be on {result.Island}.`))

		if result.Rumor then
			for _, v2 in result.Rumor do
				table.insert(result2, v2)
			end
		end

		table.insert(result2, (`Give it about {v} minute(s). Be standing there when it happens.`))
		return result2
	end
end

function getSecretPhaseAsync()
	local success, result = pcall(function()
		return remoteFunction:InvokeServer({
			Type = "GetPhase"
		})
	end)

	if success and typeof(result) == "table" then
		return result.Phase or "Locked"
	end

	return "Locked"
end

function getCompletedIslandCountAsync()
	local v = remoteFunction2:InvokeServer({
		Type = "GetMomentProgress"
	})
	assert(v.Type == "GetMomentProgress", (`bad response: "{v.Type}"`))
	local count = 0
	local count2 = 0
	local v2 = false
	local currentMap = Map.findCurrentMap()

	if not currentMap then
		return count, count2, false
	end

	for _, island in currentMap.Islands do
		if not island.BonusMoments then
			continue
		end

		count2 += 1

		if not Map.getIfIslandComplete(island, function(p)
			return v.Data[Map.getAddress(p)] == true
		end) then
			continue
		end

		count += 1

		if island.Index.Key == "Middle Town" then
			v2 = true
		end
	end

	return count, count2, v2
end

function getNextMiddleTownRumor()
	local v = remoteFunction2:InvokeServer({
		Type = "GetMomentProgress"
	})
	assert(v.Type == "GetMomentProgress", (`bad response: "{v.Type}"`))
	local currentMap = Map.findCurrentMap()

	if not currentMap then
		return nil
	end

	for _, island in currentMap.Islands do
		if not (island.BonusMoments and island.Index.Key == "Middle Town") then
			continue
		end

		for _, bonusMoment in island.BonusMoments do
			if not bonusMoment.Dialogue.Rumor then
				continue
			end

			local address = Map.getAddress(bonusMoment)

			if not v.Data[address] then
				return bonusMoment.Dialogue.Rumor
			end
		end
	end

	return nil
end

return {
	Title = "Secrets Master",
	Get = function(_)
		local completedIslandCountAsync, v, v2 = getCompletedIslandCountAsync()
		local v3 = v <= completedIslandCountAsync and getSecretPhaseAsync() or nil
		return {
			Text = {
				"Heyo, it's me the Secrets Master.",
				"What secrets? None of your business - you don't get to be the Secrets Master by telling people your secrets."
			},
			Option1 = {
				Label = "Tell me a secret, please!",
				JumpTo = function()
					return {
						Text = { "Hmmmmm, alright - you seem pretty trustworthy" },
						Option1 = {
							Label = "You can trust me!",
							JumpTo = function()
								local v4 = {
									{
										"Some people have been seeing weird things",
										"Really strange concerning things - like boxes in their field of view.",
										"These boxes tell them things like their health, their energy, and sometimes even how angry they are!",
										"Creepy stuff."
									},
									{
										"The Boat Dealer is likely nearing bankruptcy.",
										"Their \"Free Dinghy\" promotion does not make any economic sense.",
										"How can they afford to just give a free ship away to every person who asks?"
									},
									{
										"We're facing a biodiversity crisis on the Jungle island.",
										"If you look closely, many of the trees are the exact same!"
									},
									{
										"The Skylands waterfall pond is actually replenished through secret pipes running through the cloud bridges",
										"- what...",
										"Did you think it was magic?"
									},
									{
										"The lack of thumbs on anyone means the Emperor can never spare or condemn any gladiators in the Colosseum.",
										"The secret here is that there's apparently an emperor.",
										"What do you mean \"what are thumbs?\"?"
									},
									{ "There was probably a third island in the \"Desert\" region that was mined into oblivion to get enough sand for that massive pyramid." },
									{
										"Some people claim that Lightning Fruit used to be called Rumble Fruit - most think they've just misremembered.",
										"I can't help but wonder if those are memories leaking in from a parallel reality."
									},
									{
										"The Dual Katana is a scam, they'll sell you a single Katana for $1,000 fine...",
										"But - ask em for a second and SUDDENLY it's $12,000!",
										"They've played us for absolute fools."
									},
									{
										"There's rumor that a meme is going around where deranged people are eating traffic cones.",
										"What a ridiculous thing to do."
									},
									{ "I always get Ghost Fruit and Spirit Fruit mixed up.", "Don't tell anyone." },
									{ "Smoke Fruit is technically also Gas Fruit, just uh, less cool." },
									{
										"To upgrade a slingshot you need the wings of an angel, and skin of a cow.",
										"Two materials of equal worth.",
										"Apparently."
									}
								}
								return {
									Text = v4[math.random(1, #v4)],
									Option1 = {
										Label = "I'm telling everyone!",
										JumpTo = function()
											return {
												Text = { "Look at the Blabbermouth Master over here..." }
											}
										end
									},
									Option2 = {
										Label = "Your secret is safe with me.",
										JumpTo = function()
											return {
												Text = { "I knew I could trust you, with time I shall train you to be a wise Secret Master as well." }
											}
										end
									}
								}
							end
						}
					}
				end
			},
			Option2 = completedIslandCountAsync >= 3 and not v2 and {
				Label = "I heard you knew a helpful secret about Middle Town.",
				JumpTo = function()
					local nextMiddleTownRumor = getNextMiddleTownRumor()

					if nextMiddleTownRumor then
						return {
							Text = nextMiddleTownRumor
						}
					end

					return {
						Text = { "Can't tell you, it's a secret." }
					}
				end
			} or nil,
			Option3 = completedIslandCountAsync >= 1 and {
				Label = "Which boss stirs next?",
				JumpTo = function()
					local success, result = pcall(function()
						return remoteFunction3:InvokeServer()
					end)

					if not success or typeof(result) ~= "table" then
						result = nil
					end

					if result then
						return {
							Text = describeRaidHint(result)
						}
					end

					return {
						Text = { "Nothing is stirring right now. Even the monsters need a rest." }
					}
				end
			} or nil,
			Option6 = v3 == "Stories" and {
				Label = "Tell me some stories",
				JumpTo = function()
					local success, result = pcall(function()
						return remoteFunction:InvokeServer({
							Type = "RollStories"
						})
					end)
					local stories

					if success and typeof(result) == "table" then
						stories = result.Stories
					else
						stories = nil
					end

					if typeof(stories) ~= "table" or #stories == 0 then
						return {
							Text = { "Not right now. Come back when you've seen more of this sea." }
						}
					end

					local storyPage

					storyPage = function(p: number)
						local text = {}

						if p == 1 then
							table.insert(text, "Three of them. Listen close, I'm not repeating myself.")
						end

						for _, v5 in stories[p] do
							table.insert(text, v5)
						end

						if #stories <= p then
							table.insert(text, "And that's enough out of me.")
							return {
								Text = text
							}
						else
							return {
								Text = text,
								Option1 = {
									Label = "Tell me more.",
									JumpTo = function()
										return storyPage(p + 1)
									end
								}
							}
						end
					end

					return (storyPage(1))
				end
			} or nil,
			Option7 = v3 == "Complete" and {
				Label = "About that fighting style...",
				JumpTo = function()
					return {
						Text = {
							"You put the falls back the way they were. One fist, no shortcuts.",
							"So here's the last secret I've got. Which will it be?"
						},
						Option1 = {
							Label = "Advanced Combat",
							JumpTo = function()
								local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
									"SetSecretStyle",
									"Advanced Combat"
								)
								return {
									Text = { v4 == 1 and "Then take it. Don't go telling people where you got it." or v4 == 2 and "You're already using it." or "Not here, not now." }
								}
							end
						},
						Option2 = {
							Label = "Combat",
							JumpTo = function()
								local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
									"SetSecretStyle",
									"Combat"
								)
								return {
									Text = { v4 == 1 and "Back to basics. Nothing wrong with that." or v4 == 2 and "You're already using it." or "Not here, not now." }
								}
							end
						}
					}
				end
			} or nil
		}
	end
}