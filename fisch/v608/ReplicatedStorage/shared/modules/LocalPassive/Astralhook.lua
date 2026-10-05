local Astralhook = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("world")

function Astralhook.Morph(p, _, object)
	task.spawn(function()
		object:WaitUntilReady()
		local localPlayer = Players.LocalPlayer
		local random = object:GetRandom(4)
		local extended = p.reelTrove:Extend()

		while object.active do
			object:WaitLogic(random:NextNumber(p.config.MinInterval, p.config.MaxInterval))
			extended:Clean()

			if not object.active then
				break
			end

			object:AddProgress(p.config.ProgressBoost)
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local clone = ReplicatedStorage.resources.replicated.fishing.AstralStars:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, 0))
			clone.Parent = workspace.active
			ReplicatedStorage.resources.sounds.sfx.astralhook.starsfalling:Play()
			extended:Add(clone)
		end
	end)
end

setmetatable(Astralhook, module)
return Astralhook