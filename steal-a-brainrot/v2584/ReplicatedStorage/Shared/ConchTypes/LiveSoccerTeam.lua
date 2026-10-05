local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local LiveSoccerTeams = require(ReplicatedStorage.Shared.LiveSoccerTeams)
return Conch.register_type("Live Soccer Team", Conch.args.enum_new(LiveSoccerTeams))