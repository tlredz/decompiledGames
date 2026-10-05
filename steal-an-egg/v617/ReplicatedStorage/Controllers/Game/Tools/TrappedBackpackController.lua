local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = require(ReplicatedStorage.Shared.Player)
local TrappedBackpackLock = require(script.Parent.Parent.Parent.GUI.TrappedBackpackLock)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
local v = false
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function unequipLocalTools()
			local humanoid = Player.FindHumanoid(localPlayer)

			if humanoid then
				humanoid:UnequipTools()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTrapBackpackLocked(isTrapped: boolean)
			if v == isTrapped then
				local v2 = isTrapped and Player.FindHumanoid(localPlayer)

				if v2 then
					v2:UnequipTools()
				end
			else
				v = isTrapped

				if not isTrapped then
					TrappedBackpackLock.SetLocked(false)
					return
				end

				TrappedBackpackLock.SetLocked(true)
				unequipLocalTools() -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshCharacterTrapState(instance)
			local isTrapped = instance:GetAttribute("IsTrapped") == true
			setTrapBackpackLocked(isTrapped) -- equivalent call inferred; original call site unknown
		end

		local function bindCharacter(character)
			maid:Clean()
			maid:Add(function()
				if v == false then
					return
				end

				v = false
				TrappedBackpackLock.SetLocked(false)
			end)
			maid:Connect(character:GetAttributeChangedSignal("IsTrapped"), function()
				refreshCharacterTrapState(character) -- equivalent call inferred; original call site unknown
			end)
			maid:Connect(character.ChildAdded, function(tool)
				local v2 = v and tool:IsA("Tool") and Player.FindHumanoid(localPlayer)

				if v2 then
					v2:UnequipTools()
				end
			end)
			refreshCharacterTrapState(character) -- equivalent call inferred; original call site unknown
		end

		localPlayer.CharacterAdded:Connect(bindCharacter)
		local character = Player.FindCharacter(localPlayer)

		if character then
			bindCharacter(character)
		end
	end
}