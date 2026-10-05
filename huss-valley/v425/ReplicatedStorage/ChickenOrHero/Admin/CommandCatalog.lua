local CommandCatalog = {
	Tiers = {
		{
			Name = "Helper",
			Level = 1,
			Description = "Player lookup, server status and help."
		},
		{
			Name = "Moderator",
			Level = 2,
			Description = "Warnings, kicks and player recovery. Cannot manage matches or ban."
		},
		{
			Name = "Admin",
			Level = 3,
			Description = "Server announcements, match controls, lobby tools and bans up to 7 days."
		},
		{
			Name = "HeadAdmin",
			Level = 4,
			Description = "Permanent bans and unbans. Give only to highly trusted staff."
		},
		{
			Name = "Owner",
			Level = 5,
			Description = "All commands, permission grants and global operations. Cannot be assigned."
		}
	},
	CreatorRank = {
		Name = "ContentCreator",
		Level = 0,
		Creator = true,
		Description = "Filming, reversible troll effects, kicks and server controls. No bans, gifts, ranks or global operations. Movement anti-cheat exempt."
	}
}

function CommandCatalog.rank(value)
	local v = tostring(value or ""):lower():gsub("[%s_-]", "")

	if v == "contentcreator" or v == "creator" or v == "promoter" or v == "promotionalist" then
		return CommandCatalog.CreatorRank
	end

	return CommandCatalog.tier(value)
end

CommandCatalog.Aliases = {
	giftknife = "giftdagger",
	giftskin = "giftdagger",
	cmds = "help",
	commands = "help",
	staff = "admins",
	admin = "rank",
	setadmin = "rank",
	unadmin = "unrank",
	ranks = "tiers",
	re = "respawn",
	m = "announce",
	tp = "goto",
	restart = "restartserver",
	refresh = "restartserver",
	refreshserver = "restartserver",
	refreshglobal = "restartglobal",
	shutdowngame = "restartglobal",
	shutdownglobal = "restartglobal",
	update = "updategame",
	unlock = "unlockserver",
	lock = "lockserver",
	cancelupdate = "cancelglobal",
	serverinfo = "status"
}
CommandCatalog.Commands = {
	{
		Name = "globalspin",
		Level = 5,
		Usage = "",
		Description = "Give every online player across all servers one free wheel spin.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "sparkles",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Surround a player with short-lived stars.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "fire",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "A harmless fire effect; does not damage health.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "confetti",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Celebrate someone with a burst of colour.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "rainbow",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Cycle a player's avatar colours.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "ghost",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Make an avatar almost invisible temporarily.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "bighead",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Temporarily enlarge someone's head.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "spin",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Turn a character into a short, spinning spectacle.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "launch",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player> [seconds]",
		Description = "Launch a player with a bounded impulse; can affect the match.",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "untroll",
		Level = 5,
		CreatorOnly = true,
		Usage = "<player>",
		Description = "Restore all temporary creator effects on a player.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "wheel",
		Level = 5,
		Usage = "",
		Description = "Open the owner’s global giveaway picker. One winner per server; Studio is preview only.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "help",
		Level = 1,
		Usage = "[command]",
		Description = "Show commands available to your tier.",
		Args = { "command" },
		ReadOnly = true
	},
	{
		Name = "tiers",
		Level = 1,
		Usage = "",
		Description = "Explain staff tiers and the ContentCreator filming rank.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "admins",
		Level = 1,
		Usage = "",
		Description = "List the owner and assigned staff.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "players",
		Level = 1,
		Usage = "",
		Description = "List players and match admission status.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "status",
		Level = 1,
		Usage = "",
		Description = "Inspect this server and its match queue.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "whois",
		Level = 1,
		Usage = "<player>",
		Description = "Show a player's role, readiness and staff tier.",
		Args = { "player" },
		ReadOnly = true
	},
	{
		Name = "ping",
		Level = 1,
		Usage = "[player]",
		Description = "Show the server-observed network latency.",
		Args = { "player" },
		ReadOnly = true
	},
	{
		Name = "titles",
		Level = 1,
		Usage = "",
		Description = "List cosmetic titles (these grant no powers).",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "anticheat",
		Level = 2,
		Usage = "<player>",
		Description = "Read recent movement evidence; not a verdict.",
		Args = { "player" },
		ReadOnly = true
	},
	{
		Name = "clearcheatwarning",
		Level = 4,
		Usage = "<username/UserId>",
		Description = "Clear false-positive movement warnings; preserves audit evidence.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "logs",
		Level = 2,
		Usage = "",
		Description = "Read recent staff actions in this server.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "warn",
		Level = 2,
		Usage = "<player> <message>",
		Description = "Send a filtered staff warning.",
		Args = { "player", "message" },
		ReadOnly = false
	},
	{
		Name = "kick",
		Level = 2,
		Usage = "<player> [reason]",
		Description = "Remove a lower-tier player after saving.",
		Args = { "player", "message" },
		ReadOnly = false
	},
	{
		Name = "lobby",
		Level = 2,
		Usage = "<player>",
		Description = "Withdraw a player to the lobby with AFK on.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "respawn",
		Level = 2,
		Usage = "<player>",
		Description = "Reset a character safely in the lobby.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "heal",
		Level = 2,
		Usage = "<player>",
		Description = "Restore character health.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "afk",
		Level = 2,
		Usage = "<player> <on/off>",
		Description = "Set lobby participation; never interrupt a match.",
		Args = { "player", "toggle" },
		ReadOnly = false
	},
	{
		Name = "announce",
		Level = 3,
		Usage = "<message>",
		Description = "Send a filtered announcement to this server.",
		Args = { "message" },
		ReadOnly = false
	},
	{
		Name = "goto",
		Level = 3,
		Usage = "<player>",
		Description = "Teleport yourself next to someone in the lobby.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "bring",
		Level = 3,
		Usage = "<player>",
		Description = "Bring a lower-tier player to you in the lobby.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "freeze",
		Level = 3,
		Usage = "<player> [seconds]",
		Description = "Hold a lobby player briefly (5–120 seconds).",
		Args = { "player", "seconds" },
		ReadOnly = false
	},
	{
		Name = "unfreeze",
		Level = 3,
		Usage = "<player>",
		Description = "Release a staff-applied lobby hold.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "pause",
		Level = 3,
		Usage = "",
		Description = "Pause the next match; let this one finish.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "resume",
		Level = 3,
		Usage = "",
		Description = "Resume the match queue.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "endmatch",
		Level = 3,
		Usage = "",
		Description = "End this match without awarding a win.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "lockserver",
		Level = 3,
		Usage = "",
		Description = "Prevent new ordinary arrivals to this server.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "unlockserver",
		Level = 3,
		Usage = "",
		Description = "Allow new arrivals again.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "ban",
		Level = 3,
		Usage = "<username/UserId> <duration> [reason]",
		Description = "Admin: up to 7 days. Head Admin: up to 1 year or perm.",
		Args = { "player", "duration", "message" },
		ReadOnly = false
	},
	{
		Name = "unban",
		Level = 4,
		Usage = "<username/UserId>",
		Description = "Remove an experience ban.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "rank",
		Level = 5,
		Usage = "<username/UserId> <tier>",
		Description = "Assign a staff tier or ContentCreator filming rank. Owner only.",
		Args = { "player", "tier" },
		ReadOnly = false
	},
	{
		Name = "unrank",
		Level = 5,
		Usage = "<username/UserId>",
		Description = "Remove a staff or ContentCreator rank. Owner only.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "daggers",
		Level = 5,
		Usage = "",
		Description = "List every giftable dagger and its command ID.",
		Args = {},
		ReadOnly = true
	},
	{
		Name = "giftdagger",
		Level = 5,
		Usage = "<username/UserId/me> <dagger>",
		Description = "Permanently gift one dagger, including unreleased skins. Owner only; offline targets supported.",
		Args = { "player", "skin" },
		ReadOnly = false
	},
	{
		Name = "title",
		Level = 5,
		Usage = "<username/UserId> <title>",
		Description = "Award a cosmetic title, with no admin powers.",
		Args = { "player", "title" },
		ReadOnly = false
	},
	{
		Name = "untitle",
		Level = 5,
		Usage = "<username/UserId>",
		Description = "Remove a manually awarded cosmetic title.",
		Args = { "player" },
		ReadOnly = false
	},
	{
		Name = "globalannounce",
		Level = 5,
		Usage = "<message>",
		Description = "Send a filtered announcement to every server.",
		Args = { "message" },
		ReadOnly = false
	},
	{
		Name = "restartserver",
		Level = 5,
		Usage = "[seconds]",
		Description = "Refresh this server after saving progress.",
		Args = { "notice" },
		ReadOnly = false
	},
	{
		Name = "shutdownserver",
		Level = 5,
		Usage = "[seconds]",
		Description = "Close this server after saving progress.",
		Args = { "notice" },
		ReadOnly = false
	},
	{
		Name = "restartglobal",
		Level = 5,
		Usage = "[seconds]",
		Description = "Refresh all existing servers.",
		Args = { "notice" },
		ReadOnly = false
	},
	{
		Name = "updategame",
		Level = 5,
		Usage = "[seconds]",
		Description = "Announce an update and refresh existing servers.",
		Args = { "notice" },
		ReadOnly = false
	},
	{
		Name = "cancelshutdown",
		Level = 5,
		Usage = "",
		Description = "Cancel this server's pending shutdown.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "cancelglobal",
		Level = 5,
		Usage = "",
		Description = "Cancel the latest global refresh countdown.",
		Args = {},
		ReadOnly = false
	},
	{
		Name = "previewupdate",
		Level = 5,
		Usage = "",
		Description = "Preview the update screen without transferring anyone.",
		Args = {},
		ReadOnly = false
	}
}
local commandsByName = {}

for _, command in CommandCatalog.Commands do
	commandsByName[command.Name] = command
end

function CommandCatalog.find(p)
	return commandsByName[CommandCatalog.Aliases[p] or p]
end

function CommandCatalog.tier(value)
	if type(value) ~= "string" and type(value) ~= "number" then
		return nil
	end

	local v = tostring(value):lower():gsub("[%s_-]", "")
	local v2 = ({
		mod = "moderator",
		head = "headadmin",
		senioradmin = "headadmin"
	})[v] or v

	for _, tier in CommandCatalog.Tiers do
		if v2 == tier.Name:lower() or tonumber(value) == tier.Level then
			return tier
		end
	end
end

function CommandCatalog.tierName(p)
	for _, tier in CommandCatalog.Tiers do
		if tier.Level == p then
			return tier.Name
		end
	end

	return "Player"
end

CommandCatalog.CreatorCommands = {}

for _, v in {
	"help",
	"tiers",
	"admins",
	"players",
	"status",
	"whois",
	"ping",
	"titles",
	"anticheat",
	"logs",
	"warn",
	"kick",
	"lobby",
	"respawn",
	"heal",
	"afk",
	"announce",
	"goto",
	"bring",
	"freeze",
	"unfreeze",
	"pause",
	"resume",
	"endmatch",
	"lockserver",
	"unlockserver"
} do
	CommandCatalog.CreatorCommands[v] = true
end

function CommandCatalog.allowed(value, p, p2)
	local v = CommandCatalog.find(p)

	if not v or type(value) ~= "number" then
		return false
	end

	if value >= 5 then
		return true
	end

	if v.CreatorOnly then
		return p2 == true
	end

	if v.Level <= value then
		return true
	elseif p2 == true then
		return CommandCatalog.CreatorCommands[v.Name] == true
	else
		return false
	end
end

function CommandCatalog.help(p, value, p2)
	if value and value ~= "" then
		local v = CommandCatalog.find(value:lower():gsub("^;", ""))

		if v and CommandCatalog.allowed(p, v.Name, p2) then
			return ";" .. v.Name .. " " .. v.Usage .. "\n" .. v.Description .. "\nAccess: " .. (v.CreatorOnly and "ContentCreator / Owner" or CommandCatalog.tierName(v.Level) .. (CommandCatalog.CreatorCommands[v.Name] and " / ContentCreator" or ""))
		end

		return "No available command with that name."
	else
		local v = { "HUSS VALLEY · " .. (p2 and p == 0 and "ContentCreator" or CommandCatalog.tierName(p)):upper() .. " COMMANDS" }

		for _, command in CommandCatalog.Commands do
			if CommandCatalog.allowed(p, command.Name, p2) then
				table.insert(v, ";" .. command.Name .. " " .. command.Usage .. "  ·  " .. command.Description)
			end
		end

		table.insert(
			v,
			"Tab completes. Up/Down selects a suggestion. Alt+Up/Down recalls history. Tap a suggestion on mobile."
		)
		table.insert(
			v,
			"Targets: username, unique prefix, UserId or me. Use ;rank for command tiers and ;title for cosmetic recognition."
		)
		return table.concat(v, "\n")
	end
end

return CommandCatalog