local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local VideoAdRewards = require(Players.LocalPlayer.PlayerScripts.Modules.VideoAdRewards)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local starterBundleGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("StarterBundleGui")
Color3.fromRGB(114, 140, 255)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._boards = {}
	self:_Init()
	return self
end

function object:_BoardAdded(adornee)
	local v = {
		Gui = starterBundleGui:Clone(),
		VideoAdRewards = VideoAdRewards.new(),
		Connections = {}
	}
	local starterBundle = v.Gui.StarterBundle
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
	local function update()
		local visible = PlayerDataController:Get("GamepassBundlesClaimed")[starter_bundle.GamepassName]
		starterBundle.MainFrame.Button.Visible = not visible
		starterBundle.MainFrame.Owned.Visible = visible
	end

	table.insert(v.Connections, PlayerDataController:GetDataChangedSignal("GamepassBundlesClaimed"):Connect(update))
	update() -- equivalent call inferred; original call site unknown
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
	local videoAdRewards = v.Gui.VideoAdRewards
	starterBundle.Visible = true
	videoAdRewards.Visible = false
	v.Gui.Adornee = adornee
	v.Gui.Parent = Players.LocalPlayer.PlayerGui
	self._boards[adornee] = v
end

function object:_BoardRemoved(p2)
	local _board = self._boards[p2]

	if not _board then
		return
	end

	for _, connection in pairs(_board.Connections) do
		connection:Disconnect()
	end

	_board.Gui:Destroy()
	_board.VideoAdRewards:Destroy()
	self._boards[p2] = nil
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyStarterBundleBoard"):Connect(function(p)
		self:_BoardAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("LobbyStarterBundleBoard"):Connect(function(p)
		self:_BoardRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyStarterBundleBoard")) do
		task.defer(self._BoardAdded, self, v)
	end
end

return object._new()