local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
assert(Players.LocalPlayer)
local Command = {}
Command.FreeInput = true

function Command.GetOptions()
	return {}
end

function Command.Select(p: string)
	local conch_standalone = require(ReplicatedStorage.packages.conch_standalone)
	conch_standalone.execute(p)
end

function Command.GetDisplay(value: string)
	return "Text", value:split(" ")[1]
end

function Command.GetDescription(p: string)
	return (`Run Command: "{p}"`)
end

return Command