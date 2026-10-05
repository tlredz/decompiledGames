local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local JumpLTMData = require(ReplicatedStorage.Shared.JumpLTMData)
return Conch.register_type("JumpIsland", Conch.args.enum_new(JumpLTMData.TrackAreaNames))