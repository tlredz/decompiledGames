local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local suggester = {
	"Info",
	"Join",
	"Suspend",
	"Unsuspend",
	"Kick",
	"Ban",
	"Unban",
	"Whitelist",
	"Unwhitelist",
	"Mod",
	"Unmod",
	"Access",
	"PvP",
	"PvE",
	"Announce",
	"Shutdown"
}
local v2 = {
	Join = { "JoinPrivateServer", true },
	Kick = { "Kick", false },
	Ban = { "BanAdd", true },
	Unban = { "BanRemove", true },
	Whitelist = { "WhitelistAdd", true },
	Unwhitelist = { "WhitelistRemove", true },
	Mod = { "ModeratorAdd", true },
	Unmod = { "ModeratorRemove", true }
}
local v3 = { "on", "off" }
local v4 = { "closed", "friends", "everyone" }

-- equivalent calls inferred from this helper; original call sites unknown
local function named(p)
	local lower = tostring(p):lower()

	for _, v5 in suggester do
		if v5:lower() == lower then
			return v5
		end
	end

	return nil
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = suggester,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				local lower = tostring(p):lower()

				for _, v5 in suggester do
					if v5:lower() == lower then
						return v5
					end
				end

				return nil
			end
		},
		{
			Type = "Value",
			Name = "Value",
			Required = false,
			Suggester = function(list)
				local v5 = named(list[1] or "") -- equivalent call inferred; original call site unknown

				if v5 == "PvP" or v5 == "PvE" then
					return v3, true
				end

				if v5 == "Access" then
					return v4, true
				end

				if v2[v5] == nil then
					return nil
				end

				local names = {}

				for _, v6 in Players:GetPlayers() do
					table.insert(names, v6.Name)
				end

				return names, true
			end,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Server = function(p, p2: string, value: string?)
		local v5 = named(p2) -- equivalent call inferred; original call site unknown

		if v5 == nil then
			error((`PrivateServer: unknown action "{p2}" ({table.concat(suggester, ", ")})`))
		end

		local PrivateServerService = require(ServerStorage.SAM.Services.PrivateServerService)
		PrivateServerService.ResolveSession()

		if v5 == "Info" then
			local state = PrivateServerService.GetState(p)

			if state == nil then
				error("PrivateServer: this isn't a private server")
			end

			local ownerId = tostring(state.OwnerId)
			pcall(function()
				ownerId = Players:GetNameFromUserIdAsync(state.OwnerId)
			end)
			local v6 = {}

			for _, occupant in state.Occupants do
				table.insert(v6, (`{occupant.Name} ({occupant.Role})`))
			end

			return {
				Content = table.concat({
					`Owner: {ownerId}`,
					`Access: {state.Settings.Access} · PvP {state.Settings.PvP and "on" or "off"} · PvE {state.Settings.PvE and "on" or "off"}`,
					`Suspended: {state.Suspended and "yes" or "no"}`,
					`Moderators: {#(state.Moderators or {})} · Whitelist: {#(state.Whitelist or {})} · Bans: {#(state.Bans or {})}`,
					(`Here: {table.concat(v6, ", ")}`)
				}, "\n"),
				BgColor = Color3.fromRGB(40, 40, 40),
				FgColor = Color3.new(1, 1, 1)
			}
		else
			local v6 = v2[v5]
			local v7, content

			if v6 == nil then
				if v5 == "PvP" or v5 == "PvE" then
					if value ~= "on" and value ~= "off" then
						error((`PrivateServer: {v5} takes on or off`))
					end

					v7, content = PrivateServerService.SetSetting(p, v5, value == "on")
				elseif v5 == "Access" then
					local v9 = value or ""
					v7, content = PrivateServerService.SetAccess(p, v9:sub(1, 1):upper() .. v9:sub(2):lower())
				elseif v5 == "Announce" then
					v7, content = PrivateServerService.Announce(p, value)
				else
					v7, content = PrivateServerService[v5](p)
				end
			else
				local userId, v9 = PrivateServerService.ResolveUserId(value, v6[2])

				if userId == nil then
					error((`PrivateServer: {v9}`))
				end

				v7, content = PrivateServerService[v6[1]](p, userId)
			end

			if not v7 then
				error((`PrivateServer: {content}`))
			end

			return {
				Content = content,
				BgColor = Color3.fromRGB(32, 143, 70),
				FgColor = Color3.new(1, 1, 1)
			}
		end
	end
}