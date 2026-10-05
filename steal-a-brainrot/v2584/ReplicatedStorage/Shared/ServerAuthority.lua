local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local v = game.GameId == 10593523064
local ServerAuthority = {
	isEnabled = function()
		return FFlags:GetInstant("UseServerAuthority", v)
	end
}

function ServerAuthority:SetNetworkOwner(p)
	if ServerAuthority.isEnabled() then
		p = nil
	end

	self:SetNetworkOwner(p)
end

function ServerAuthority:SetNetworkOwnershipAuto()
	if ServerAuthority.isEnabled() then
		self:SetNetworkOwner(nil)
	else
		self:SetNetworkOwnershipAuto()
	end
end

function ServerAuthority.observe(callback)
	local connection = FFlags:OnChange("UseServerAuthority", callback)
	return function()
		connection:Disconnect()
	end
end

return ServerAuthority