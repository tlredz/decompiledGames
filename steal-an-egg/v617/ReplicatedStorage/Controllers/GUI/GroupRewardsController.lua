local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Confetti = require(ReplicatedStorage.Client.UI.VFX.Confetti)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GUI = require(ReplicatedStorage.Client.GUI)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local Log = require(ReplicatedStorage.Packages.Log)
local Message = require(ReplicatedStorage.Client.Message)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local SpeedPower = require(ReplicatedStorage.Client.RewardFeedback.SpeedPower)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local colorSequence = ColorSequence.new(Color3.fromRGB(150, 150, 150), Color3.fromRGB(110, 110, 110))
return {
	Start = function()
		local v = Log.new()
		local localPlayer = Players.LocalPlayer
		local buyCash = GUI.GroupReward().Frame.BuyCash
		local price = buyCash:FindFirstChild("Price")
		local uIGradient = buyCash:FindFirstChildOfClass("UIGradient")
		local proximityPrompt = Workspace.World.GroupReward.ProximityPrompt
		local text = price.Text
		local color

		if uIGradient == nil then
			color = nil
		else
			color = uIGradient.Color
		end

		local tryLock = TryLock()
		assert(proximityPrompt:IsA("ProximityPrompt"), "Expected GroupReward.ProximityPrompt to be a ProximityPrompt")
		local v3

		if price == nil then
			v3 = false
		else
			v3 = price:IsA("TextLabel")
		end

		assert(v3, "FreeGift.Frame.BuyCash.Price must be a TextLabel")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function renderClaimState(claimedGroupReward: boolean)
			t.strict(t.boolean)(claimedGroupReward)
			price.Text = claimedGroupReward and "CLAIMED!" or text

			if uIGradient ~= nil and color ~= nil then
				local v4 = uIGradient
				local color2

				if claimedGroupReward then
					color2 = colorSequence
				else
					color2 = color
				end

				v4.Color = color2
			end
		end

		local function updateView()
			local v4 = Save.Await()

			if v4 == nil then
				return
			end

			local claimedGroupReward = v4.ClaimedGroupReward == true
			renderClaimState(claimedGroupReward) -- equivalent call inferred; original call site unknown
		end

		local function invokeClaim(flag: boolean)
			t.strict(t.boolean)(flag)
			local v4, v5, v6 = Remotes.GroupPerk.RedeemPerk:InvokeServer(flag)

			if not v4 then
				Message.Notice(v5 or "Failed to claim reward!")
				return false
			end

			t.strict(t.number)(v6)

			if Tabs.IsActive("GroupReward") then
				Tabs.Deactivate()
			end

			t.strict(t.boolean)(true)
			price.Text = "CLAIMED!"

			if uIGradient ~= nil and color ~= nil then
				uIGradient.Color = colorSequence
			end

			Message.Notice("REWARD CLAIMED!")
			Confetti.Burst()
			SpeedPower.Announce(v6)
			return true
		end

		local function resolveClientMembership()
			local success, result = pcall(function()
				return localPlayer:IsInGroupAsync(Constants.GROUP_ID)
			end)

			if not success then
				Message.Notice("Failed to verify your group membership!")
				return false, false
			end

			if result then
				return true, true
			end

			local success2, result2 = pcall(function()
				return GroupService:PromptJoinAsync(Constants.GROUP_ID)
			end)

			if not success2 then
				Message.Notice("Failed to open the group join prompt!")
				return false, false
			end

			if result2 == Enum.GroupMembershipStatus.Joined or result2 == Enum.GroupMembershipStatus.AlreadyMember then
				return true, true
			end

			if result2 == Enum.GroupMembershipStatus.JoinRequestPending then
				Message.Notice("Your request to join the group is pending approval.")
			else
				Message.Notice("You must join the group to claim this reward!")
			end

			return false, false
		end

		local function onClaimActivated()
			local v4 = Save.Await()

			if v4 == nil then
				Message.WarnGeneric()
				return
			end

			if v4.ClaimedGroupReward == true then
				Message.Notice("You already claimed this reward!")
				return
			end

			local clientMembership, v5 = resolveClientMembership()

			if not clientMembership then
				return
			end

			invokeClaim(v5)
		end

		ButtonFX(buyCash, 1.08, function()
			tryLock(onClaimActivated)
		end)
		proximityPrompt.Triggered:Connect(function()
			Tabs.Toggle("GroupReward")
		end)

		if Save.IsLoaded() then
			local v4 = Save.Await()

			if v4 ~= nil then
				local claimedGroupReward = v4.ClaimedGroupReward == true
				t.strict(t.boolean)(claimedGroupReward)
				price.Text = claimedGroupReward and "CLAIMED!" or text

				if uIGradient ~= nil and color ~= nil then
					if claimedGroupReward then
						color = colorSequence
					end

					uIGradient.Color = color
				end
			end
		else
			Save.Loaded:Connect(updateView)
		end

		Save.WatchFields({ "ClaimedGroupReward" }, updateView)
		v:AtInfo():Log("Group rewards client initialized")
	end
}