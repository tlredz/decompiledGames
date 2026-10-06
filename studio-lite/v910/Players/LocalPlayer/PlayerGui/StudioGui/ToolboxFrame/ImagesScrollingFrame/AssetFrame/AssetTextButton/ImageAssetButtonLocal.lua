game:GetService("MarketplaceService")
local explorerPanel = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("ExplorerPanel")
local setSelection = explorerPanel:WaitForChild("SetSelection")
local getSelection = explorerPanel:WaitForChild("GetSelection")
script.Parent.Activated:Connect(function()
	local match = script.Parent.Parent.AssetTextBox.Text:match("%d+")

	if not (match and tonumber(match) > 999) then
		warn("Enter an asset number from the URL at create.roblox.com/store")
		return
	end

	local decal = Instance.new("Decal")
	decal.Name = "Decal"
	decal.Texture = "rbxthumb://type=Asset&id=" .. tostring(match) .. "&w=420&h=420"
	local v = getSelection:Invoke()

	if not v or typeof(v) ~= "table" or not (#v >= 1 and v[1]:IsA("BasePart")) then
		warn("First select a part to insert the decal into.")
		return
	end

	decal.Parent = v[1]
	task.wait(0.2)
	setSelection:Invoke({ decal })
end)