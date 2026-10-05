local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local HappyRewardClient = {}
local happyReward = Client.Interface.HappyReward
local v = {
	{
		Name = "Vampire Cloak",
		Icon = "rbxassetid://113173145164964",
		Description = ""
	},
	{
		Name = "Bouncing Blade",
		Icon = "rbxassetid://85112292459478",
		Description = ""
	},
	{
		Name = "Laser Cannon",
		Icon = "rbxassetid://97407701909548",
		Description = ""
	}
}
local v2 = {
	Message = "Thanks for your help! I have used some Pumpkin Magic on your farm plot",
	Responses = {
		{
			Response = "Thanks Happy",
			Event = "CloseHalloweenDialogue"
		}
	}
}

function ClaimReward(p)
	happyReward.Visible = false
	Client.Sound.Play("KeyPress", {
		Duplicate = true
	})

	if Client.Events.ClaimHappyReward:InvokeServer(p) then
		Client.Sound.Play("HalloweenTreat")
		Client.PopUpUI.AddPopUp("Claimed " .. p)
	end
end

function HappyRewardClient.OpenMenu()
	happyReward.Visible = true
end

function TalkToHappy()
	if not workspace:GetAttribute("HappyQuestComplete") then
		return
	end

	if workspace:GetAttribute("HappyRewardClaimed_" .. localPlayer.UserId) then
		Client.HappyHeadDialogueClient.SetDialogue(v2)
	else
		HappyRewardClient.OpenMenu()
	end
end

function HappyRewardClient.Init()
	for i = 1, 4 do
		local v3 = happyReward.ItemsContent["Pelt" .. i]
		local v4 = v[i]
		v3.Visible = v4 ~= nil

		if not v4 then
			continue
		end

		v3.ItemIconFrame.ImageLabel.Image = v4.Icon
		v3.ItemName.Text = v4.Name
		v3.DescriptionLabel.Text = v4.Description
		local v5 = v4
		v3.SelectButton_Lower.SelectButton.MouseButton1Down:Connect(function()
			ClaimReward(v5.Name)
		end)
	end

	happyReward.CloseButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("CloseButton")
		happyReward.Visible = false
	end)
	Client.InteractionHandler.RegisterInteraction("TalkToHappy", TalkToHappy)
end

return HappyRewardClient