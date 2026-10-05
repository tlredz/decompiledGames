local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
local packages = ReplicatedStorage2.Packages
require3(packages.Net)
require3(packages.Promise)
local parent = script.Parent.Parent
require3(parent.Types)
require3(parent)
local _ = ReplicatedStorage2.Assets.UI.Leaderboard
return {
	Init = function(_, container)
		return {
			Container = container,
			Pages = {},
			Section = "Global"
		}
	end
}