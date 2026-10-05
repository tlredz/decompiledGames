local Players = game:GetService("Players")
return {
	kick = {
		Name = "kick",
		Description = "Kick a player from the server.",
		Category = "Moderation",
		Groups = { "Admin", "Moderator" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "reason",
				Type = "string",
				Optional = true
			}
		},
		Run = function(_, p)
			p.player:Kick(p.reason)
			return ("Kicked %s"):format(p.player.Name)
		end
	},
	ban = {
		Name = "ban",
		Description = "Ban a player from the game.",
		Category = "Moderation",
		Groups = { "Admin", "Moderator" },
		Destructive = true,
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "duration",
				Type = "int",
				Optional = true,
				Default = -1
			},
			{
				Name = "reason",
				Type = "string",
				Optional = true,
				Default = "Banned by staff"
			}
		},
		Run = function(_, data)
			local duration = data.duration
			local reason = data.reason
			Players:BanAsync({
				UserIds = { data.player.UserId },
				DisplayReason = reason,
				PrivateReason = reason,
				Duration = duration,
				ApplyToUniverse = true
			})

			if duration and duration > 0 then
				return string.format("Banned %s for %d seconds", data.player.Name, duration)
			end

			return string.format("Banned %s permanently", data.player.Name)
		end
	},
	unban = {
		Name = "unban",
		Description = "Unban a user.",
		Category = "Moderation",
		Groups = { "Admin", "Moderator" },
		Args = {
			{
				Name = "userId",
				Type = "int"
			}
		},
		Run = function(_, p)
			Players:UnbanAsync({
				UserIds = { p.userId },
				ApplyToUniverse = true
			})
			return string.format("Unbanned userId %d", p.userId)
		end
	}
}