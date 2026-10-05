local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdService = game:GetService("AdService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.MatchmakingCountdown)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local billboardVideoAdsGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BillboardVideoAdsGui")
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._spin_these = {}
	self:_Init()
	return self
end

function object:Update(p2)
	local v = {}

	for k in pairs(self._spin_these) do
		if k:IsDescendantOf(workspace) or k:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
			k.Rotation += 15 * p2
		else
			v[k] = true
		end
	end

	for k in pairs(v) do
		self._spin_these[k] = nil
	end
end

function object:_BoardAdded(adornee)
	local clone = billboardVideoAdsGui:Clone()
	self._spin_these[clone.MainFrame.Background.CanvasGroup.Keys.ImageLabel] = true
	self._spin_these[clone.MainFrame.Background.CanvasGroup.Wraps.ImageLabel] = true
	local count = 0
	local v = nil
	local visible = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_visuals()
		local billboardVideoAdProgress = PlayerDataController:Get("BillboardVideoAdProgress")
		local numVideoAdsForBillboardReward = MonetizationLibrary:GetNumVideoAdsForBillboardReward(PlayerDataController:Get("BillboardVideoAdClaimedToday"))
		clone.MainFrame.Play.Title.Text = string.format(
			"%s<font size=\"8\"> /%s</font>",
			billboardVideoAdProgress,
			numVideoAdsForBillboardReward
		)
	end

	PlayerDataController:GetDataChangedSignal("BillboardVideoAdClaimedToday"):Connect(update_visuals)
	PlayerDataController:GetDataChangedSignal("BillboardVideoAdProgress"):Connect(update_visuals)
	update_visuals() -- equivalent call inferred; original call site unknown

	local function can_fetch_ads()
		return FighterController.LocalFighter and not FighterController.LocalFighter:Get("IsInDuel") and not (FighterController.LocalFighter:Get("IsInShootingRange") or MatchmakingCountdown:IsVisible()) and PlayerDataController:Get("BillboardVideoAdClaimedToday") < MonetizationLibrary.MAX_BILLBOARD_VIDEO_ADS_PER_DAY
	end

	local function update()
		count += 1
		local v3 = count

		if v then
			v:Destroy()
			v = nil
		end

		clone.MainFrame.Visible = false
		clone.KeyBundle.Visible = true

		if not can_fetch_ads() then
			return
		end

		if not visible then
			local success, adAvailabilityNowAsync = pcall(
				AdService.GetAdAvailabilityNowAsync,
				AdService,
				Enum.AdFormat.RewardedVideo
			)
			wait(0.5)

			if v3 ~= count then
				return
			end

			visible = success and adAvailabilityNowAsync.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
		end

		local visible2 = PlayerDataController:Get("BillboardVideoAdClaimedToday") == 0
		clone.MainFrame.Visible = visible
		clone.KeyBundle.Visible = not visible
		clone.MainFrame.Background.CanvasGroup.Keys.Visible = visible2
		clone.MainFrame.Background.CanvasGroup.Wraps.Visible = not visible2

		if visible then
			local new = RewardSlot.new
			local v5

			if visible2 then
				v5 = MonetizationLibrary.BILLBOARD_KEYS_REWARD_DATA
			else
				v5 = MonetizationLibrary.BILLBOARD_WRAPS_REWARD_DATA
			end

			v = new(v5)
			v:ZoomOutViewportFrame()
			v:UseHighResolutionImage()
			v:HideBackground()
			v:HideWeaponVisual()
			v:SetInteractable(false)
			v:SetParent(clone.MainFrame.Reward)
		end
	end

	MatchmakingCountdown.VisibilityChanged:Connect(update)

	local function hook_local_fighter()
		local v3 = FighterController:WaitForLocalFighter()
		v3:GetDataChangedSignal("IsInDuel"):Connect(update)
		v3:GetDataChangedSignal("IsInShootingRange"):Connect(update)
		update()
	end

	task.spawn(hook_local_fighter)
	PlayerDataController:GetDataChangedSignal("BillboardVideoAdClaimedToday"):Connect(function()
		wait(1)
		update()
		wait(1)

		if not v then
			update()
		end
	end)
	task.spawn(function()
		update()
		wait(2)

		while true do
			update()
			wait(15)
		end
	end)
	clone.MainFrame.Button.MouseButton1Click:Connect(function()
		if Pages.PageSystem.CurrentPage then
			return
		end

		task.spawn(function()
			if not ReplicatedStorage.Remotes.Misc.PlayVideoAdBillboard:InvokeServer() then
				pcall(AdService.GetAdAvailabilityNowAsync, AdService, Enum.AdFormat.RewardedVideo)
				ReplicatedStorage.Remotes.Misc.PlayVideoAdBillboard:InvokeServer()
			end
		end)
		visible = false
		task.delay(2, function()
			visible = false
			update()
		end)
	end)
	ButtonEffect:Add(clone.MainFrame.Button, true)
	local keybundle_2 = MonetizationLibrary.Bundles.keybundle_2
	local keyBundle = clone.KeyBundle
	keyBundle.Title.Text = keybundle_2.DisplayName

	for k, reward in pairs(keybundle_2.Rewards) do
		local reward2 = CosmeticLibrary.Rewards[reward.Name]

		if not (not reward2 or reward2.Type ~= "Lootbox" or not ComplianceController:ArePaidRandomItemsRestricted()) then
			continue
		end

		local v3 = RewardSlot.new(reward)
		v3.Frame.LayoutOrder = k
		v3:SetParent(keyBundle.Rewards)
		v3:OnClick(function()
			if Pages.PageSystem.CurrentPage then
				return
			end

			Pages.PageSystem:OpenPage("Shop")
			Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
			Pages.PageSystem:WaitForPage("Shop"):InspectBundle("keybundle_2")
		end)
	end

	keyBundle.Button.MouseButton1Click:Connect(function()
		if Pages.PageSystem.CurrentPage then
			return
		end

		MonetizationController:PromptProductPurchase(keybundle_2.ProductID)
	end)
	MonetizationController:SetRobuxText(keyBundle.Button.Title, keybundle_2.ProductID, Enum.InfoType.Product)
	ButtonEffect:Add(keyBundle.Button)
	clone.Adornee = adornee
	clone.Parent = Players.LocalPlayer.PlayerGui
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyBillboardVideoAds"):Connect(function(p)
		self:_BoardAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyBillboardVideoAds")) do
		task.defer(self._BoardAdded, self, v)
	end
end

return object._new()