local Config = require(script.Parent.Config)
require(script.Parent.Types)
local Zone = require(script.Parent.Zone)

local function findAliveCharacter(player)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character and humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return character, humanoidRootPart
	end

	return nil, nil
end

local Rewards = {}

function Rewards.newState()
	return {
		character = nil,
		survivedSeconds = 0,
		progress = 0
	}
end

function Rewards.getTierWins(list, p: number)
	local wins = list[#list].wins

	for _, v in list do
		if p <= v.maxLevel then
			return v.wins
		end
	end

	return wins
end

function Rewards.getStreakMultiplier(p: number)
	local multiplier = 1

	for _, rewardStreakMultiplier in Config.rewardStreakMultipliers do
		if rewardStreakMultiplier.afterSeconds <= p then
			multiplier = rewardStreakMultiplier.multiplier
		end
	end

	return multiplier
end

function Rewards.step(state, p, p2, p3: number, flag: boolean)
	local aliveCharacter, v = findAliveCharacter(p)
	local v2 = false

	if aliveCharacter and v then
		if state.character ~= aliveCharacter then
			state.character = aliveCharacter
			state.survivedSeconds = 0
			state.progress = 0
		end

		if not Zone.isInside(p2, v.Position) then
			state.progress = math.max(0, state.progress - p3 / Config.rewardOutsideDepleteSeconds)
			return false
		end

		state.survivedSeconds += p3
		state.progress += p3 / Config.rewardFillSeconds

		if not flag then
			state.progress = math.min(1, state.progress)
			return v2
		end

		if state.progress >= 1 then
			state.progress -= 1
			return true
		end
	else
		state.character = nil
		state.survivedSeconds = 0
		state.progress = 0
	end

	return v2
end

function Rewards.pruneDisconnected(items)
	for k in items do
		if k.Parent == nil then
			items[k] = nil
		end
	end
end

return Rewards