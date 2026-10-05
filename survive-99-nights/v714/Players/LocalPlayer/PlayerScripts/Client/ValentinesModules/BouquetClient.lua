local BouquetClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
Client.InteractionHandler.RegisterInteraction("TakeBouquet", function(_)
	if localPlayer.Inventory:FindFirstChild("Bouquet") then
		Client.PopUpUI.AddPopUp("You already have a bouquet", "valentines")
	else
		Client.Events.RequestTakeBouquet:FireServer()
	end
end)
local v2 = {
	["Infernal Helmet"] = "rbxassetid://139593375323345"
}
Client.Events.BouquetChoose:Connect(function(p, list)
	if v[p] or not (list and list[1]) then
		return
	end

	v[p] = true
	local clone = Client.Interface.FlowerPrize:Clone()
	clone.Parent = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
	clone.Name = "removelater"
	Client.Sound.Play("PresentOpen")
	local itemList = clone.ItemList

	for i = 1, 3 do
		local child = itemList:FindFirstChild("Item" .. i)
		child.ItemName.Text = list[i]
		child.ImageLabel.Image = Client.Databases.HotbarIcons.Icons[list[i]] or v2[list[i]]
		local v3 = i
		child.CraftButton.Activated:Connect(function()
			Client.Sound.Play("CloseButton")
			clone:Destroy()
			Client.Events.BouquetChoose:FireServer(p, list[v3])
			Client.Events.SetPopUpMessage:Fire("selected " .. list[v3], "valentines")
		end)
	end

	clone.Visible = true
end)

function BouquetClient.Init() end

return BouquetClient