local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local PropLimitPurchaseController = require(ReplicatedStorage.Modules.Client.Props.PropLimitPurchaseController)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local localPlayer = Players.LocalPlayer
local PUBLIC_SERVER_PROP_LIMIT = CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT
local PRIVATE_SERVER_PROP_LIMIT = CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT
local color = Color3.fromRGB(100, 100, 100)
local v = Component.new({
	Tag = "PropCount"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function isPropOwnedByLocalPlayer(model)
	local name = model.Name
	local name2 = localPlayer.Name
	return not (#name < #name2) and string.sub(name, -#name2) == name2
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._placementFolder = nil
	self._totalOwnCount = 0
end

function v:Start()
	GamepassController.WaitForGamepasses()
	self._placementFolder = PropsUtil.GetPlacementFolder()
	self:_RebuildCounts()
	self._Janitor:Add(self._placementFolder.ChildAdded:Connect(function(child)
		task.defer(function()
			self:_OnPropAdded(child)
		end)
	end))
	self._Janitor:Add(self._placementFolder.ChildRemoved:Connect(function(child)
		task.defer(function()
			self:_OnPropRemoved(child)
		end)
	end))
	local increaseLimit = self.Instance.Parent.IncreaseLimit
	local backgroundColor3 = increaseLimit.BackgroundColor3
	local imageColor3

	if increaseLimit:IsA("ImageButton") then
		imageColor3 = increaseLimit.ImageColor3
	else
		imageColor3 = nil
	end

	local function refreshIncreaseLimit()
		local v2 = GameUtil.IsPrivateServer() == true
		local v3 = GameUtil.IsPrivateServerOwner(localPlayer) == true
		local v4

		if v2 then
			v4 = PropsLimitClient.IsAtPrivateServerMax()
		else
			v4 = PropsLimitClient.IsAtPublicMax()
		end

		increaseLimit.Visible = not v2 or v3
		increaseLimit.Interactable = not v4
		local increaseLimit2 = increaseLimit
		local backgroundColor

		if v4 then
			backgroundColor = color
		else
			backgroundColor = backgroundColor3
		end

		increaseLimit2.BackgroundColor3 = backgroundColor

		if increaseLimit:IsA("ImageButton") then
			local increaseLimit3 = increaseLimit
			local imageColor

			if v4 then
				imageColor = color
			else
				imageColor = imageColor3
			end

			increaseLimit3.ImageColor3 = imageColor
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshAll()
		self:_Refresh()
		refreshIncreaseLimit()
	end

	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(refreshAll))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(PUBLIC_SERVER_PROP_LIMIT):Connect(refreshAll))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(PRIVATE_SERVER_PROP_LIMIT):Connect(refreshAll))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PrivateServerPropLimits.WORKSPACE_ATTR):Connect(refreshAll))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PropsUtil.DEBUG_PROP_LIMIT_ATTR):Connect(refreshAll))
	refreshAll() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(increaseLimit.Activated:Connect(function()
		PropLimitPurchaseController.PromptIncrease("PropCount:IncreaseLimit")
		refreshIncreaseLimit()
	end))
end

function v:_RebuildCounts()
	self._totalOwnCount = 0
	local _placementFolder = self._placementFolder

	if _placementFolder == nil then
		return
	end

	for _, model in _placementFolder:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if isPropOwnedByLocalPlayer(model) then
			self._totalOwnCount += 1
		end
	end
end

function v:_OnPropAdded(model)
	if model:IsA("Model") then
		-- equivalent call inferred; original call site unknown
		if isPropOwnedByLocalPlayer(model) then
			self._totalOwnCount += 1
			self:_Refresh()
		end
	end
end

function v:_OnPropRemoved(model)
	if model:IsA("Model") then
		-- equivalent call inferred; original call site unknown
		if isPropOwnedByLocalPlayer(model) then
			self._totalOwnCount -= 1
			self:_Refresh()
		end
	end
end

function v:_Refresh()
	local instance = self.Instance
	local isOwned = GamepassController.IsOwned(Gamepasses.VIP)
	local propLimit = PropsLimitClient.GetPropLimit(isOwned)
	instance.Text = string.format("%d/%d props", self._totalOwnCount, propLimit)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v