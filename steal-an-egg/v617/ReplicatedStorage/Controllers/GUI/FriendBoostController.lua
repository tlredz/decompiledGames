local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Confetti = require(ReplicatedStorage.Client.UI.VFX.Confetti)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local Hud = require(ReplicatedStorage.Client.Hud)
local FriendRoster = require(ReplicatedStorage.Shared.Modules.FriendRoster)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local friendsInServerAttribute = FriendRoster.FriendsInServerAttribute
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local v = Hud.Find("FriendBoost")
		local currentBoost

		if v == nil then
			currentBoost = nil
		else
			currentBoost = v:FindFirstChild("CurrentBoost")
		end

		if v ~= nil then
			v.Visible = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBoostVisible(visible: boolean)
			if v ~= nil then
				v.Visible = visible
			end
		end

		local function onFriendsInGame()
			setBoostVisible(true) -- equivalent call inferred; original call site unknown
		end

		local function onNoFriends()
			setBoostVisible(false) -- equivalent call inferred; original call site unknown
		end

		local function updateBoostsDisplay()
			local attribute = localPlayer:GetAttribute(friendsInServerAttribute)

			if typeof(attribute) == "number" and not (attribute <= 0) then
				local v2 = math.floor(GameFlags.FriendBoostPercentPerFriend:Get() * math.clamp(
					attribute,
					0,
					(GameFlags.FriendBoostCap:Get())
				))

				if v2 <= 0 then
					setBoostVisible(false) -- equivalent call inferred; original call site unknown
				else
					setBoostVisible(true) -- equivalent call inferred; original call site unknown

					if currentBoost ~= nil then
						local text = string.format("Friend Boost: +%d%%", v2)
						currentBoost.Text = text
						local shadow = currentBoost:FindFirstChild("Shadow")

						if shadow ~= nil then
							shadow.Text = text
						end
					end
				end
			else
				setBoostVisible(false) -- equivalent call inferred; original call site unknown
			end
		end

		localPlayer:GetAttributeChangedSignal(friendsInServerAttribute):Connect(updateBoostsDisplay)
		updateBoostsDisplay()
		Players.PlayerAdded:Connect(updateBoostsDisplay)
		Players.PlayerRemoving:Connect(updateBoostsDisplay)
		GameFlags.FriendBoostPercentPerFriend.Changed:Connect(updateBoostsDisplay)
		GameFlags.FriendBoostCap.Changed:Connect(updateBoostsDisplay)
		Remotes.Referrals.InviteLanded.OnClientEvent:Connect(function()
			Confetti.Burst()
		end)
		return {}
	end
}