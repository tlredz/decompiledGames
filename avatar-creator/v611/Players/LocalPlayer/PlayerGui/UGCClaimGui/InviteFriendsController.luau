local localPlayer = game.Players.LocalPlayer
local SocialService = game:GetService("SocialService")
local inviteFriends = script.Parent.CoinHUD:WaitForChild("InviteFriends")
local StarterGui = game:GetService("StarterGui")
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 6
		})
	end)
end

inviteFriends.Activated:Connect(function()
	if flag then
		return
	end

	flag = true
	local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer)

	if success and result then
		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.PromptMessage = "Earn 20 coins when a new friend joins! One reward per new player."
		local v = pcall(SocialService.PromptGameInvite, SocialService, localPlayer, experienceInviteOptions)
		experienceInviteOptions:Destroy()

		if not v then
			notify("Invite Friends", "Couldn't open invites. Please try again.") -- equivalent call inferred; original call site unknown
		end
	else
		local RunService = game:GetService("RunService")
		notify(
			"Invite Friends",
			RunService:IsStudio() and "Friend invitations are available in the published Roblox game." or "Invites aren't available right now. Please try again later."
		) -- equivalent call inferred; original call site unknown
	end

	task.wait(1)
	flag = false
end)
local referralCoins = localPlayer:GetAttribute("ReferralCoins")
localPlayer:GetAttributeChangedSignal("ReferralCoins"):Connect(function()
	local referralCoins2 = localPlayer:GetAttribute("ReferralCoins") or 0

	if referralCoins and referralCoins < referralCoins2 then
		notify("Friend invite reward!", "Your invited friend joined! +" .. referralCoins2 - referralCoins .. " coins") -- equivalent call inferred; original call site unknown
	end

	referralCoins = referralCoins2
end)