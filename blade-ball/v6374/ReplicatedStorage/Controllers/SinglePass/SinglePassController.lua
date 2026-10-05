local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = nil
local localPlayer = Players.LocalPlayer
local main = localPlayer.PlayerGui:WaitForChild("SinglePass").MainFrame.Main
local pages = main.Pages
local milestone = pages.Milestone
local v8 = {
	Active = {
		HoverImage = "rbxassetid://84751211463829",
		Image = "rbxassetid://89617647046839"
	},
	Inactive = {
		HoverImage = "rbxassetid://88952034919639",
		Image = "rbxassetid://127132942458152"
	}
}
local buttonsByName = {}
local pageChanged = v2.new()
local SinglePassController = {
	PageChanged = pageChanged
}

function SinglePassController.Start(_)
	main.Close.MouseButton1Click:Connect(function()
		v4:Close("SinglePass")
	end)
	pageChanged:Connect(function(p: string)
		for k, v10 in buttonsByName do
			local active

			if k == p then
				active = v8.Active
			else
				active = v8.Inactive
			end

			v10.HoverImage = active.HoverImage
			v10.Image = active.Image
		end

		main.Odds.Visible = false
		v4:IsOpen("SinglePass")
	end)

	for _, button in ipairs(main.SideBtns:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local name = button.Name

		if not pages:FindFirstChild(name) then
			continue
		end

		local name2 = name
		button.MouseButton1Click:Connect(function()
			SinglePassController:SetPage(name2)
		end)
		buttonsByName[name] = button
	end

	v4:OnGuiOpen("SinglePass", function() end)
	v4:OnGuiClose("SinglePass", function() end)
	v7 = client:WaitReplion("Data")
	milestone.YouContributed.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
	v5.observeReplionPath(v7, "CNYEvent.TotalContributed", function(value)
		milestone.YouContributed.Label.Text = `You contributed: {v6.ValueConvertor:AddCommas(value or 0)}`
	end)
	milestone.AmountInput.Contribute.Activated:Connect(function()
		local text = tonumber(milestone.AmountInput.InputBox.TextBox.Text)

		if text then
			v:Invoke("CNYEvent_ContributeToMilestone", text)
		end
	end)
	milestone.TopContributors.Activated:Connect(function()
		pages.TopContributorPrizes.Visible = true
	end)
	pages.TopContributorPrizes.ViewRanking.Activated:Connect(function()
		pages.TopContributorPrizes.Visible = false
		pages.TopContributors.Visible = true
	end)
	pages.TopContributorPrizes.Close.Activated:Connect(function()
		pages.TopContributorPrizes.Visible = false
	end)
	pages.TopContributors.Back.Activated:Connect(function()
		pages.TopContributorPrizes.Visible = true
		pages.TopContributors.Visible = false
	end)
	pages.TopContributors.Close.Activated:Connect(function()
		pages.TopContributors.Visible = false
	end)
	v5.observeReplionPath(v7, "CNYEvent.Lanterns", function(value)
		main.SideBtns.Currency.List1.Amount.Text = v6.ValueConvertor:AddCommas(value or 0)
	end)
	SinglePassController.Page = nil
	SinglePassController:SetPage("Milestone")
	local v10 = client:WaitReplion("GlobalNumbers")

	local function updateGlobalNumbers()
		local v11 = v10:Get("Loaded") == true
		local v12 = v11 and v10:Get({ "Values", v3.GlobalNumberKey }) or 0
		milestone.ContributedGlobally.Text = `TOTAL CONTRIBUTED GLOBALLY: {not v11 and "???" or v6.ValueConvertor:ShrinkNumber(v12)}`
	end

	v10:OnChange("Values", updateGlobalNumbers)
	v10:OnChange("Loaded", updateGlobalNumbers)
	task.spawn(updateGlobalNumbers)
	v6.Thread.Every(1, function()
		if v3.EventEnded() and v4:IsOpen("SinglePass") then
			v4:Close("SinglePass")
		end
	end)
end

function SinglePassController:SetPage(page: string)
	for _, child in pages:GetChildren() do
		child.Visible = child.Name == page
	end

	if SinglePassController.Page ~= page then
		pageChanged:Fire(page)
	end

	SinglePassController.Page = page
end

return SinglePassController