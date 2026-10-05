local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local ModerationLibrary = {
	CanViewModerationPage = function(self, p)
		return PermissionsLibrary:HasPermission("permission_moderation_modpanel_access", p)
	end,
	CanViewBanStatusAndLogs = function(_, p)
		return PermissionsLibrary:HasPermission("permission_moderation_modpanel_viewbanned_full", p)
	end
}

function ModerationLibrary.CanLookupPlayers(_, p)
	return ModerationLibrary:CanViewModerationPage(p)
end

function ModerationLibrary.CanViewActionHistory(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_viewactions_full", p)
end

function ModerationLibrary.CanUseInvestigativeCommands(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_investigate_full", p)
end

function ModerationLibrary:CanPardonLimited(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_pardon_limited", p)
end

function ModerationLibrary:CanPardonAnyone(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_pardon_full", p)
end

function ModerationLibrary:CanPardon(p)
	return self:CanPardonLimited(p) or self:CanPardonAnyone(p)
end

function ModerationLibrary:CanViewDataLimited(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_viewdata_limited", p)
end

function ModerationLibrary:CanViewDataMost(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_viewdata_most", p)
end

function ModerationLibrary:CanViewDataFully(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_viewdata_full", p)
end

function ModerationLibrary:CanViewData(p)
	return self:CanViewDataLimited(p) or self:CanViewDataMost(p) or self:CanViewDataFully(p)
end

function ModerationLibrary.CanUnban(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_unban", p)
end

function ModerationLibrary.CanJoinAnyone(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_teleport_full", p)
end

function ModerationLibrary:CanEvictLimited(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_evict_limited", p)
end

function ModerationLibrary:CanEvictAnyone(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_evict_full", p)
end

function ModerationLibrary:CanEvict(p)
	return self:CanEvictLimited(p) or self:CanEvictAnyone(p)
end

function ModerationLibrary:CanBanLimited(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_moderate_limited", p)
end

function ModerationLibrary:CanBanMost(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_moderate_most", p)
end

function ModerationLibrary:CanBanAnyone(p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_moderate_full", p)
end

function ModerationLibrary:CanBan(p)
	return self:CanBanLimited(p) or self:CanBanMost(p) or self:CanBanAnyone(p)
end

function ModerationLibrary.CanManageBanLocks(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_lock", p)
end

function ModerationLibrary.CanRemoveFromLeaderboards(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_removelbs_limited", p)
end

function ModerationLibrary.CanWarnTemplate(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_warn_template", p)
end

function ModerationLibrary.CanWarnCustom(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_warn_custom", p)
end

function ModerationLibrary.CanRestrict(_, p)
	return PermissionsLibrary:HasPermission("permission_moderation_modpanel_restrict", p)
end

return ModerationLibrary