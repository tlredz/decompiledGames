local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local TweenColor = require(ReplicatedStorage.Shared.TweenColor)
local playerGui = Players.LocalPlayer.PlayerGui
return Observers.observeTag("TweenColor", TweenColor.Watch, { workspace, playerGui })