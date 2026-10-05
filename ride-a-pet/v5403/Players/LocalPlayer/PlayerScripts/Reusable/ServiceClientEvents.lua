local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")
local services = game.ReplicatedStorage.Services
local Interface = require(services:WaitForChild("Interface"))
local Roulette = require(services:WaitForChild("Roulette"))
local Monetization = require(services:WaitForChild("Monetization"))
local Audio = require(services:WaitForChild("Audio"))
local reusable = game.ReplicatedStorage.Remotes:WaitForChild("Reusable")
local localPlayer = game.Players.LocalPlayer
local SFX = game.SoundService.SFX
reusable:WaitForChild("PlaySoundOnClient").OnClientEvent:Connect(function(instance, p)
	if p then
		Audio:PlayOnce(instance, p)
	elseif instance:HasTag("ComboSound") then
		instance:SetAttribute("Play", (tonumber(instance:GetAttribute("Play")) or 0) + 1)
	else
		instance:Play()
	end
end)
local rBXGeneral = game.TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
reusable.ServerMessage.OnClientEvent:Connect(function(p, p2)
	local v = p2 or Color3.fromRGB(255, 55, 55)
	rBXGeneral:DisplaySystemMessage(string.format("<font color='#%s'><b><i>%s</i></b></font>", v:ToHex(), p))
end)
reusable:WaitForChild("PromptPurchase").OnClientEvent:Connect(function(p, p2)
	SFX.Click:Play()
	Monetization:OpenBuyPrompt(localPlayer, p, p2)
end)
reusable:WaitForChild("Purchase").OnClientEvent:Connect(function()
	SFX.Purchase:Play()
end)
reusable:WaitForChild("PurchaseEnded").OnClientEvent:Connect(function()
	Monetization:CloseBuyPrompt(localPlayer)
end)
reusable:WaitForChild("Reward").OnClientEvent:Connect(function()
	SFX.Reward:Play()
end)
reusable:WaitForChild("Roulette").OnClientEvent:Connect(function(p, p2)
	Roulette:Roll(p, p2)
end)
local inputEndedConnection = nil
local thread = nil
local v = false
local gameInvitePromptClosedConnection = nil
reusable:WaitForChild("InviteRandomFriend").Event:Connect(function()
	v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Cleanup()
		if gameInvitePromptClosedConnection then
			gameInvitePromptClosedConnection:Disconnect()
			gameInvitePromptClosedConnection = nil
		end

		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end
	end

	Cleanup() -- equivalent call inferred; original call site unknown
	local friendsOnline = localPlayer:GetFriendsOnline(10)

	if not friendsOnline then
		return
	end

	local v2 = friendsOnline[math.random(1, #friendsOnline)]
	local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
	experienceInviteOptions.InviteUser = v2.VisitorId
	experienceInviteOptions.PromptMessage = "Have fun and get +10% cash boost!"
	SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed == false then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local offsetToScale = Interface:OffsetToScale(UDim2.fromOffset(input.Position.X, input.Position.Y))
			local v3

			if offsetToScale.X.Scale > 0.5 then
				v3 = offsetToScale.X.Scale < 0.7
			else
				v3 = false
			end

			local v4

			if offsetToScale.Y.Scale > 0.5 then
				v4 = offsetToScale.Y.Scale < 0.7
			else
				v4 = false
			end

			if v3 == true and v4 == true then
				Cleanup() -- equivalent call inferred; original call site unknown
				v = true
				SFX.Reward.Reward:Play()
				reusable.InvitedFriend:FireServer()
			end
		end
	end)
	thread = task.delay(60, function()
		thread = nil
		Cleanup() -- equivalent call inferred; original call site unknown
	end)
	gameInvitePromptClosedConnection = SocialService.GameInvitePromptClosed:Connect(function(_, _)
		if v == false then
			Cleanup() -- equivalent call inferred; original call site unknown
		end
	end)
end)