local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local createGroup = Gamepad:CreateGroup(script.Parent.Frame)
createGroup.EnableCursorBehavior = true