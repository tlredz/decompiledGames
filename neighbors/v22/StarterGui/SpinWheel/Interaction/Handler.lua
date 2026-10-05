require(game.ReplicatedStorage.Modules.Network)
local Server = require(game.ReplicatedStorage.Modules.Server)
local isAdultServer = Server:IsAdultServer()
local parent = script.Parent
local parent2 = parent.Parent
local purchase = parent:WaitForChild("Purchase")
purchase.MouseButton1Click:Connect(function()
	if parent2:GetAttribute("Spinning") then
		return
	end

	local MarketplaceService = game:GetService("MarketplaceService")
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, isAdultServer and 1846052528 or 1846052454)
end)
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("ItemsShopRGBText", Enum.RenderPriority.Camera.Value, function()
	if not parent.Visible then
		return
	end

	local color = Color3.fromHSV(tick() % 10 / 10, 1, 1)
	parent.RarityTitle.BackgroundColor3 = color

	if parent2:GetAttribute("Spinning") then
		purchase.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
	else
		purchase.BackgroundColor3 = color
	end
end)