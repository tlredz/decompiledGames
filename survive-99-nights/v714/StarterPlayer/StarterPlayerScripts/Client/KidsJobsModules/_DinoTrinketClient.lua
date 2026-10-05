local DinoTrinketClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local howManyGems = nil
local v = nil
local v2 = false

function AttemptOpenCage(p)
	local v3 = Client.Events.AttemptOpenTrinketCage:InvokeServer(p)

	if v3 and v3.Success then
		OpenTrinketMenu(p)
	end
end

function OpenTrinketMenu(p)
	if howManyGems == nil then
		return
	end

	v = p
	howManyGems.Visible = true
end

function CloseTrinketMenu()
	v = nil

	if howManyGems then
		howManyGems.Visible = false
	end
end

function SelectDifficulty(p)
	if v2 or v == nil then
		return
	end

	v2 = true
	Client.Events.SelectTrinketReward:InvokeServer(v, p)
	v2 = false
	CloseTrinketMenu()
end

function SetupTrinketMenu()
	howManyGems = Client.Interface.HowManyGems

	for i = 1, 3 do
		local v3 = i
		howManyGems.Options["Option" .. i].ConfirmButton_Lower.Upper.Activated:Connect(function()
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})
			SelectDifficulty(v3)
		end)
	end

	howManyGems.CloseButton.Activated:Connect(function()
		Client.Sound.Play("CloseButton", {
			Duplicate = true
		})
		CloseTrinketMenu()
	end)
end

function DinoTrinketClient.Init()
	Client.InteractionHandler.RegisterInteraction("DinoToyCage", AttemptOpenCage)
	Client.Events.TrinketRewardClaimed:Connect(CloseTrinketMenu)
	task.spawn(SetupTrinketMenu)
end

return DinoTrinketClient