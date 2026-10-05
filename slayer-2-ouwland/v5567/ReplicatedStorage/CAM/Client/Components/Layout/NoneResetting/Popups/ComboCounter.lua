local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage.CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Interface = require(script.Interface)
return function(maid, p)
	maid:Add(cleanit.new())
	local connection = nil
	local v = nil

	local function fn(p2)
		if connection ~= nil then
			maid:Remove(connection)
			connection:Disconnect()
			connection = nil
		end

		if v ~= nil then
			if v.IsActive then
				v:Destroy()
			end

			v = nil
		end

		v = maid:Extend()
		Interface(v, p, p2)
	end

	local function updCharacter(character)
		if v ~= nil then
			if v.IsActive then
				v:Destroy()
			end

			v = nil
		end

		if connection ~= nil then
			maid:Remove(connection)
			connection:Disconnect()
			connection = nil
		end

		if character:FindFirstChild("ComboCounter") == nil then
			connection = maid:Add(character.ChildAdded:Connect(function(child)
				if child.Name == "ComboCounter" then
					fn(child)
				end
			end))
		else
			fn(character.ComboCounter)
		end
	end

	local character = localPlayer.Character

	if character ~= nil then
		updCharacter(character)
	end

	maid:Connect(localPlayer.CharacterAdded, updCharacter)
end