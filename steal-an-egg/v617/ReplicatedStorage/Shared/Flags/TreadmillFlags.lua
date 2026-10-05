local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local replicated = FastFlags.Replicated("Game.Treadmill.CommentsDisabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated("Game.Treadmill.VideoPlayerDisabled", Asserts.Boolean, true)
local replicated3 = FastFlags.Replicated("Game.Treadmill.CameraAutoFrameDisabled", Asserts.Boolean, true)
local replicated4 = FastFlags.Replicated("Game.Treadmill.PolicyServiceVideoEnabled", Asserts.Boolean, true)
local replicated5 = FastFlags.Replicated("Game.Treadmill.PhoneEnabled", Asserts.Boolean, false)
return table.freeze({
	CommentsDisabled = replicated,
	VideoPlayerDisabled = replicated2,
	CameraAutoFrameDisabled = replicated3,
	PolicyServiceVideoEnabled = replicated4,
	PhoneEnabled = replicated5
})