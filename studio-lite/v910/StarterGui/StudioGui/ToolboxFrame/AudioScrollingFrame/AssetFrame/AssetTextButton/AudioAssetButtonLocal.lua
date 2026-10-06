local MarketplaceService = game:GetService("MarketplaceService")
local explorerPanel = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("ExplorerPanel")
local setSelection = explorerPanel:WaitForChild("SetSelection")
local getSelection = explorerPanel:WaitForChild("GetSelection")
script.Parent.Activated:Connect(function()
	local match = script.Parent.Parent.AssetTextBox.Text:match("%d+")

	if not (match and tonumber(match) > 999) then
		warn("Enter an asset number from the URL at create.roblox.com/store")
		return
	end

	local productInfoAsync = MarketplaceService:GetProductInfoAsync(match)

	if not (productInfoAsync and productInfoAsync.Name) then
		warn("MeshPart asset# not found.  Find the asset number in the URL at create.roblox.com/store")
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = productInfoAsync.Name
	sound.SoundId = "rbxassetid://" .. tostring(match)
	local v = getSelection:Invoke()

	if v and typeof(v) == "table" and #v >= 1 then
		sound.Parent = v[1]
	else
		sound.Parent = workspace
	end

	sound.Playing = true
	task.wait(0.2)
	setSelection:Invoke({ sound })
end)