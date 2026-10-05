repeat
	task.wait()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
until ReplicatedStorage.Util:FindFirstChild("FortBuilder")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local new = require(ReplicatedStorage.Util:FindFirstChild("FortBuilder")).new
local Players = game:GetService("Players")
new(Players.LocalPlayer)