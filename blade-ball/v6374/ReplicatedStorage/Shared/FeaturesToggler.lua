local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
ReplicatedStorage2:WaitForChild("FeaturesToggle")
local v2 = {
	studio = function(p)
		return p == "studio" and RunService:IsStudio()
	end,
	testing = function(p)
		return p == "testing" and v.isTestGame()
	end,
	production = function(p)
		return p == "production" and not RunService:IsStudio()
	end,
	player = function(value)
		local match = value:match("^player_([%d%a]+)$")

		if not (match and RunService:IsStudio()) then
			return false
		end

		local v3 = require3(script:FindFirstChildWhichIsA("ModuleScript"))

		if tonumber(match) then
			return v3.UserId == tonumber(match)
		end

		return v3.Username == match
	end,
	medal_server = function(p)
		return p == "medal_server" and v.isMedalServer()
	end,
	medal_lobby = function(p)
		return p == "medal_lobby" and v.isMedalTournamentLobby()
	end
}
local v3 = {
	"player",
	"medal_lobby",
	"medal_server",
	"studio",
	"testing",
	"production"
}
local FeaturesToggler = {
	processEnvironments = function(items)
		local v4 = {}

		for k, item in items do
			for k2, v5 in v2 do
				if v5(k) then
					table.insert(v4, {
						Priority = table.find(v3, k2) or 1e999,
						Value = item
					})
				end
			end
		end

		table.sort(v4, function(a, b)
			return a.Priority < b.Priority
		end)
		return v4[1].Value
	end
}

function FeaturesToggler:handleBoolValue()
	local v4 = FeaturesToggler.processEnvironments(self:GetAttributes())

	if not v4 then
		warn((`[!] Disabled Feature: {self}`))
	end

	self.Value = v4
	return v4
end

return FeaturesToggler