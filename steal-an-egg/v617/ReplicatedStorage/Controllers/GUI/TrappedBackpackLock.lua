local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Main = require(script.Parent.BackpackController.Main)
local backpack = GUI.Backpack()
local v = false
local backpackEnabled = nil
return {
	SetLocked = function(flag: boolean)
		if v == flag then
			return
		end

		v = flag

		if flag then
			backpackEnabled = Main:GetBackpackEnabled()
			Main:SetBackpackEnabled(false)
			backpack.Enabled = false
		else
			local v2 = backpackEnabled
			backpackEnabled = nil

			if v2 == nil then
				return
			end

			Main:SetBackpackEnabled(v2)

			if v2 and not HiddenUIHandler.IsHidden() then
				backpack.Enabled = true
			end
		end
	end
}