local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Utility = require(global:WaitForChild("Utility"))
local Config = require(script.Parent.Config)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")
return {
	new = function(p: string, instance)
		local v = {
			Id = 0,
			Type = p
		}
		local maid = cleanit.new()

		local function findAnimation()
			local activation = instance ~= nil and instance:FindFirstChild("Activation") or nil

			if activation == nil then
				return (script:FindFirstChild("Activation"))
			end

			return activation
		end

		function v.Hold(player)
			if player == nil then
				return false
			end

			local character = player.Character

			if character == nil then
				return false
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart == nil or humanoid == nil then
				return false
			end

			maid:Clean()
			local id = v.Id
			local clone = skill_stand_still:Clone()
			clone.Parent = humanoidRootPart
			maid:Add(clone)
			maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))
			local activation

			if instance ~= nil then
				activation = instance:FindFirstChild("Activation") or nil
			end

			if activation == nil then
				activation = script:FindFirstChild("Activation")
			end

			local animator = humanoid:FindFirstChild("Animator")
			local track

			if activation == nil or animator == nil then
				track = nil
			else
				track = animator:LoadAnimation(activation)
				maid:Add(track)
				track:Play()
				track.Stopped:Once(function()
					track:Destroy()
				end)
			end

			task.wait(Config.LOCK)

			if id ~= v.Id then
				return true
			end

			if track ~= nil then
				maid:Remove(track)
			end

			maid:Clean()
			return true
		end

		function v.Switch(player)
			local character = player and player.Character

			if character == nil then
				return
			end

			local parent

			if instance ~= nil then
				parent = instance.Parent or nil
			end

			local effect

			if parent ~= nil then
				effect = parent:FindFirstChild("Effect") or nil
			end

			if effect ~= nil and effect:IsA("ModuleScript") then
				local module = require(effect)

				if module.Switch ~= nil then
					module.Switch(player, character)
				end
			end
		end

		function v.Cancel(_)
			maid:Clean()
		end

		return v
	end
}