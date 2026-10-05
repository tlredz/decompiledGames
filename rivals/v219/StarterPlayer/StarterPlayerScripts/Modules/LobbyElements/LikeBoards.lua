local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local likeBoardGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LikeBoardGui")
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object:_BoardAdded(adornee)
	local clone = likeBoardGui:Clone()
	local v = nil

	local function update()
		if v then
			v:Destroy()
			v = nil
		end

		local loaded = adornee:GetAttribute("Loaded")
		local currentLikes = adornee:GetAttribute("CurrentLikes") or 0
		local goalLikes = adornee:GetAttribute("GoalLikes") or 0
		local lastGoalLikes = adornee:GetAttribute("LastGoalLikes") or 0
		local currentMilestone = adornee:GetAttribute("CurrentMilestone") or 0
		local keyQuantity = adornee:GetAttribute("KeyQuantity") or 0
		local code = adornee:GetAttribute("Code") or ""
		local v2 = (currentLikes - lastGoalLikes) / (goalLikes - lastGoalLikes)
		clone.MainFrame.Progress.Current.Text = Utility:PrettyNumber(currentLikes)
		clone.MainFrame.Progress.Goal.Text = Utility:PrettyNumber(goalLikes)
		clone.MainFrame.Progress.Bar.Bar.Size = UDim2.new(math.clamp(v2, 0, 1), 0, 1, 0)
		clone.MainFrame.Progress.Percent.Text = math.floor(v2 * 100) .. "%"
		clone.MainFrame.Code.Text = string.upper(code)
		clone.MainFrame.Description.Visible = currentMilestone > 0
		clone.MainFrame.Visible = loaded
		clone.StarterBundle.Visible = not loaded
		clone.Waiting.Visible = false

		if currentMilestone > 0 then
			v = RewardSlot.new({
				Name = "Key",
				Quantity = keyQuantity
			})
			v:SetParent(clone.MainFrame.Reward)
		end
	end

	adornee:GetAttributeChangedSignal("CurrentLikes"):Connect(update)
	adornee:GetAttributeChangedSignal("GoalLikes"):Connect(update)
	adornee:GetAttributeChangedSignal("LastGoalLikes"):Connect(update)
	adornee:GetAttributeChangedSignal("CurrentMilestone"):Connect(update)
	adornee:GetAttributeChangedSignal("KeyQuantity"):Connect(update)
	adornee:GetAttributeChangedSignal("Code"):Connect(update)
	update()
	local starterBundle = clone.StarterBundle
	local starter_bundle = MonetizationLibrary.Bundles.starter_bundle

	for k, reward in pairs(starter_bundle.Rewards) do
		local reward2 = CosmeticLibrary.Rewards[reward.Name]

		if not (not reward2 or reward2.Type ~= "Lootbox" or not ComplianceController:ArePaidRandomItemsRestricted()) then
			continue
		end

		local v2 = RewardSlot.new(reward)
		v2.Frame.LayoutOrder = k
		v2:SetParent(starterBundle.MainFrame.Rewards)
		v2:OnClick(function()
			if Pages.PageSystem.CurrentPage then
				return
			end

			Pages.PageSystem:OpenPage("Shop")
			Pages.PageSystem:WaitForPage("Shop"):SetPage("Bundles")
			Pages.PageSystem:WaitForPage("Shop"):InspectBundle("starter_bundle")
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update2()
		local visible = PlayerDataController:Get("GamepassBundlesClaimed")[starter_bundle.GamepassName]
		starterBundle.MainFrame.Button.Visible = not visible
		starterBundle.MainFrame.Owned.Visible = visible
	end

	PlayerDataController:GetDataChangedSignal("GamepassBundlesClaimed"):Connect(update2)
	update2() -- equivalent call inferred; original call site unknown
	starterBundle.MainFrame.Button.MouseButton1Click:Connect(function()
		if Pages.PageSystem.CurrentPage then
			return
		end

		MonetizationController:PromptGamePassPurchase(MonetizationLibrary.Gamepasses[starter_bundle.GamepassName].GamepassID)
	end)
	MonetizationController:SetRobuxText(
		starterBundle.MainFrame.Button.Title,
		MonetizationLibrary.Gamepasses[starter_bundle.GamepassName].GamepassID,
		Enum.InfoType.GamePass
	)
	ButtonEffect:Add(starterBundle.MainFrame.Button)
	clone.Adornee = adornee
	clone.Parent = Players.LocalPlayer.PlayerGui
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyLikeBoard"):Connect(function(p)
		self:_BoardAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyLikeBoard")) do
		task.defer(self._BoardAdded, self, v)
	end
end

return object._new()