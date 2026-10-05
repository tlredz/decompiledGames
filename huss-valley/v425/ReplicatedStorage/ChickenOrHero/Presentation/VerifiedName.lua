local VerifiedName = {}
local v = utf8.char(57344)

-- equivalent calls inferred from this helper; original call sites unknown
local function escape(value)
	return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;")
end

function VerifiedName.format(value, p)
	local v2 = escape(value) -- equivalent call inferred; original call site unknown

	if p == true then
		return v2 .. " <font color=\"#3AA8FF\">" .. v .. "</font>" or v2
	end

	return v2
end

function VerifiedName.player(player)
	return VerifiedName.format(
		player.DisplayName,
		typeof(player) == "Instance" and player:IsA("Player") and player.HasVerifiedBadge
	)
end

return VerifiedName