local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
require(ReplicatedStorage.Shared.Types.AssetItem)
local v = {
	Male = "rbxassetid://88627876961976",
	Female = "rbxassetid://98782480225988"
}
local AssetGender = {
	BadgeImage = function(p)
		return v[p] or "rbxassetid://98782480225988"
	end,
	IsTag = function(p)
		return p == "Male" or p == "Female"
	end,
	Draw = function(p)
		if (p or Random.new()):NextInteger(1, 2) == 1 then
			return "Male"
		end

		return "Female"
	end
}

function AssetGender.Settle(p: string, p2: string?, p3)
	if AssetGender.IsTag(p2) then
		return p2
	end

	local genderLocked = Assets.Directory[p].GenderLocked

	if AssetGender.IsTag(genderLocked) then
		return genderLocked
	end

	return (AssetGender.Draw(p3))
end

return AssetGender