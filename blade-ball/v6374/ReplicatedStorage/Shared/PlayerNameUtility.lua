local RunService = game:GetService("RunService")

function _convertToPlayerAssetType(value)
	if typeof(value) == "Instance" then
		return value
	end

	if typeof(value) == "table" then
		return {
			UserId = value.Id,
			Name = value.Username,
			DisplayName = value.DisplayName,
			HasVerifiedBadge = value.HasVerifiedBadge,
			MembershipType = value.MembershipType or Enum.MembershipType.None
		}
	end
end

function _getBaseEmoji(instance, flag: boolean)
	local v = ""

	if flag and typeof(instance) == "Instance" and _getGroupAccess(instance) then
		v ..= "🔨"
	end

	if instance.HasVerifiedBadge then
		v ..= ""
	end

	if instance.MembershipType == Enum.MembershipType.Premium then
		v ..= ""
	end

	if string.len(v) > 0 then
		return v .. " "
	end

	return v
end

function _getGroupAccess(instance)
	local groupRank = instance:GetAttribute("GroupRank")

	if typeof(groupRank) == "number" then
		return groupRank >= 210
	end

	if not RunService:IsStudio() then
		return false
	end

	local success, result = pcall(function()
		return instance:GetRankInGroup(12836673)
	end)

	if success then
		instance:SetAttribute("GroupRank", result)
	end

	return success
end

local PlayerNameUtility = {}

function PlayerNameUtility.GetHumanoidName(_, p, flag: boolean)
	return _getBaseEmoji(p, flag) .. p.Name
end

function PlayerNameUtility.GetHumanoidDisplayName(_, p, flag: boolean)
	return _getBaseEmoji(p, flag) .. p.DisplayName
end

function PlayerNameUtility.GetUserDisplayName(_, p)
	local v = _convertToPlayerAssetType(p)

	if v then
		return _getBaseEmoji(v, false) .. v.DisplayName
	end

	return p.DisplayName
end

function PlayerNameUtility.GetUserName(_, p)
	local v = _convertToPlayerAssetType(p)

	if v then
		return _getBaseEmoji(v, false) .. v.Name
	end

	return p.Username
end

return PlayerNameUtility