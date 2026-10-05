local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local parentModule = require(script.Parent.Parent)
parentModule.register(script.Name, {
	displayName = "OG Party",
	slot = "event",
	hidden = true,
	needsDuration = true,
	defaultDurationSeconds = 600,
	maxDurationSeconds = 1200,
	load = function(_)
		if RunService:IsServer() then
			local OGParty = require(ServerScriptService.Server.AdminAbuseServerModules.OGParty)
			return {
				onStart = function()
					OGParty.Start({})
				end,
				onStop = function(_)
					OGParty.Stop()
				end
			}
		end

		local OGParty = require(ReplicatedStorage.AdminAbuse.Modules.OGParty)
		return {
			onStart = function()
				OGParty:Fire()
			end,
			onStop = function(_)
				OGParty:Stop()
			end
		}
	end
})
return {}