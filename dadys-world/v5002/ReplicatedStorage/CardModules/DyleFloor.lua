local DyleFloor = {}
game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
DyleFloor.Name = "TIME'S UP"
DyleFloor.Icon = "rbxassetid://73972786736745"
DyleFloor.Description = "Travel to one of the most dangerous places in Gardenview. Complete this challenging floor to earn +50 stamina for the rest of the run."
DyleFloor.SingleUse = true
DyleFloor.MinimumFloor = 3
DyleFloor.MinimumVoteRound = 4

function DyleFloor.ApplyCardEffects()
	if not cardModifiers:FindFirstChild("DyleFloor") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "DyleFloor"
		boolValue.Value = true
		boolValue.Parent = cardModifiers
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "DyleFloorUsed"
		boolValue2.Value = true
		boolValue2.Parent = cardModifiers
		print("DyleFloor: Dyle floor modifier applied - TIME'S UP!")
	end
end

function DyleFloor.CanAppearInVote(p, _)
	if cardModifiers:FindFirstChild("DyleFloorUsed") or p < DyleFloor.MinimumFloor then
		return false
	end

	local votesSinceFloor2 = workspace.Info:FindFirstChild("VotesSinceFloor2")
	return not (votesSinceFloor2 and votesSinceFloor2.Value < DyleFloor.MinimumVoteRound)
end

return DyleFloor