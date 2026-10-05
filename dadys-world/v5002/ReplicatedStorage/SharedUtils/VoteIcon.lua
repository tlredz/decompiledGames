local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local VoteIcon = {
	DEFAULT_SIZE = UDim2.fromScale(1, 1)
}

function VoteIcon.GetSize(result)
	if type(result) == "string" then
		local tower = TowerLUT:GetTower(result)

		if not tower then
			return VoteIcon.DEFAULT_SIZE
		end

		local success
		success, result = pcall(require, tower)

		if not success then
			return VoteIcon.DEFAULT_SIZE
		end
	end

	if type(result) ~= "table" then
		return VoteIcon.DEFAULT_SIZE
	end

	local voteIconSize = result.VoteIconSize

	if typeof(voteIconSize) == "UDim2" then
		return voteIconSize
	end

	return VoteIcon.DEFAULT_SIZE
end

function VoteIcon:Apply(p)
	if typeof(self) ~= "Instance" then
		return
	end

	self.Position = UDim2.fromScale(0.5, 0.5)
	self.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Size = VoteIcon.GetSize(p)
end

return VoteIcon