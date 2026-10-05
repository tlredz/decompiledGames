local EntityLookupParams = {}
EntityLookupParams.__index = EntityLookupParams

function EntityLookupParams.new(teamID, teamkillEnabled, grabSmallHitboxes)
	local self = setmetatable({}, EntityLookupParams)
	self.TeamID = teamID
	self.TeamkillEnabled = teamkillEnabled
	self.GrabSmallHitboxes = grabSmallHitboxes
	self.SourceEntity = nil
	self.CanHurtSelf = nil
	self:_Init()
	return self
end

function EntityLookupParams.IsValidTarget(data, object)
	if not object or not data.CanHurtSelf and object == data.SourceEntity or not object:IsAlive() then
		return false
	end

	if data.TeamkillEnabled or not data.TeamID or object == data.SourceEntity or object:Get("TeamID") ~= data.TeamID then
		return true
	end

	return false
end

function EntityLookupParams:_Init() end

return EntityLookupParams