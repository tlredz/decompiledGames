local localPlayer = game.Players.LocalPlayer
local favoriteReward = script.Parent.CoinHUD:WaitForChild("FavoriteReward")
local v = false
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(text)
	pcall(function()
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("SendNotification", {
			Title = "Like + Favorite",
			Text = text,
			Duration = 7
		})
	end)
end

local function update()
	favoriteReward.Text = localPlayer:GetAttribute("FavoriteRewardClaimed") and "Reward claimed" or v and "Checking…" or flag and "Check favorite · +20" or "Like + Favorite for 20 coins"
	local v2 = favoriteReward
	local interactable = not v

	if interactable then
		if localPlayer:GetAttribute("CoinsReady") == true then
			interactable = not localPlayer:GetAttribute("FavoriteRewardClaimed")
		else
			interactable = false
		end
	end

	v2.Interactable = interactable
end

favoriteReward.Activated:Connect(function()
	if v or localPlayer:GetAttribute("FavoriteRewardClaimed") then
		return
	end

	if flag then
		v = true
		update()
		local success, result = pcall(function()
			return game.ReplicatedStorage.FavoriteRewardCheck:InvokeServer()
		end)
		v = false
		update()
		notify(not success and "Couldn't check. Please try again." or result.claimed and "Reward claimed! Your 20 coins are saved." or result.error or "Couldn't check. Please try again.") -- equivalent call inferred; original call site unknown
	else
		flag = true
		update()
		notify("Like and favorite the game! The 20-coin reward is verified using your favorite. Tap Check favorite afterward.") -- equivalent call inferred; original call site unknown
		pcall(function()
			local AvatarEditorService = game:GetService("AvatarEditorService")
			AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
		end)
	end
end)
localPlayer:GetAttributeChangedSignal("FavoriteRewardClaimed"):Connect(update)
localPlayer:GetAttributeChangedSignal("CoinsReady"):Connect(update)
update()