local Clipboard = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Tool)
local _ = Players.LocalPlayer

function Clipboard.Initialize(_) end

function Clipboard.Activated(_) end

function Clipboard.Equipped(p)
	p.Player.PlayerGui.Clipboard.Enabled = true
end

function Clipboard.Unequipped(p)
	p.Player.PlayerGui.Clipboard.Enabled = false
end

function Clipboard.Destroyed(_) end

return Clipboard