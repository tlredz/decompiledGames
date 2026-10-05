local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local LotConstants = require(ReplicatedStorage.Modules.Shared.Housing.LotConstants)
local v = Component.new({
	Tag = "HouseCooldownUI"
})

local function getCooldownValues()
	GamepassController.WaitForGamepasses()
	local isPrivateServer = GameUtil.IsPrivateServer()

	if UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_COOLDOWN.id, Gamepasses.VIP) then
		return {
			Houses = LotConstants.BuildCooldown.VIP.Default,
			Apartments = LotConstants.BuildCooldown.VIP.Default,
			Mansions = LotConstants.BuildCooldown.VIP.Default,
			Landmarks = LotConstants.BuildCooldown.VIP.Landmark,
			Motels = LotConstants.BuildCooldown.VIP.Motel
		}
	end

	if isPrivateServer then
		return {
			Houses = LotConstants.BuildCooldown.Private.Default,
			Apartments = LotConstants.BuildCooldown.Private.Default,
			Mansions = LotConstants.BuildCooldown.Private.Default,
			Landmarks = LotConstants.BuildCooldown.Private.Landmark,
			Motels = LotConstants.BuildCooldown.Private.Motel
		}
	end

	return {
		Houses = LotConstants.BuildCooldown.Default.Default,
		Apartments = LotConstants.BuildCooldown.Default.Default,
		Mansions = LotConstants.BuildCooldown.Default.Default,
		Landmarks = LotConstants.BuildCooldown.Default.Landmark,
		Motels = LotConstants.BuildCooldown.Default.Motel
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatDynamicTime(p: number)
	local v2 = math.floor(p / 60)
	local v3 = math.floor(p % 60)
	return string.format("%d:%02d", v2, v3)
end

local function formatStaticTime(p: number)
	local v2 = math.floor(p / 60)
	local v3 = math.floor(p % 60)

	if v2 > 0 and v3 == 0 then
		return string.format("%d minute%s", v2, v2 == 1 and "" or "s")
	end

	if v2 == 0 and v3 > 0 then
		return string.format("%d second%s", v3, v3 == 1 and "" or "s")
	end

	return formatDynamicTime(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeType(value: string)
	if type(value) == "string" and value ~= "" then
		return value
	end

	return "House"
end

local function getBucket(value: string)
	local v2 = string.lower(value)

	if v2 == "motel" or v2 == "motels" then
		return "Motels"
	end

	if v2 == "houses" or v2 == "house" or v2 == "apartments" or v2 == "apartment" or v2 == "mansions" or v2 == "mansion" or v2 == "landmarks" or v2 == "landmark" then
	end

	return "Primary"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDefaultForBucket(p: string)
	local cooldownValues = getCooldownValues()

	if p == "Motels" then
		return cooldownValues.Motels
	end

	return cooldownValues.Houses
end

function v:_ensureBucketTimer(p2: string)
	self._timers[p2] = self._timers[p2] or {
		duration = 0,
		default = 0,
		onCooldown = false,
		token = nil
	}
	return self._timers[p2]
end

function v:StartTimer(value: string)
	local type2 = normalizeType(value) -- equivalent call inferred; original call site unknown
	local v2 = string.lower(type2)
	local v3

	if v2 == "motel" or v2 == "motels" then
		v3 = "Motels"
	else
		v3 = "Primary"
	end

	local _ensureBucketTimer = self:_ensureBucketTimer(v3)
	local defaultForBucket = getDefaultForBucket(v3) -- equivalent call inferred; original call site unknown
	_ensureBucketTimer.token = {}
	_ensureBucketTimer.default = defaultForBucket
	_ensureBucketTimer.duration = defaultForBucket
	_ensureBucketTimer.onCooldown = true
	local token = _ensureBucketTimer.token
	task.spawn(function()
		self.Instance.Visible = true

		while _ensureBucketTimer.duration > 0 and _ensureBucketTimer.token == token do
			local _activeHouseType = self._activeHouseType
			local v4 = string.lower(_activeHouseType)
			local v5

			if v4 == "motel" or v4 == "motels" then
				v5 = "Motels"
			else
				v5 = "Primary"
			end

			if v5 == v3 then
				self:SetTimer(_ensureBucketTimer.duration, _ensureBucketTimer.default)
			end

			task.wait(1)
			_ensureBucketTimer.duration -= 1
		end

		if _ensureBucketTimer.token == token then
			_ensureBucketTimer.onCooldown = false
			_ensureBucketTimer.duration = 0
			local _activeHouseType = self._activeHouseType
			local v4 = string.lower(_activeHouseType)
			local v5

			if v4 == "motel" or v4 == "motels" then
				v5 = "Motels"
			else
				v5 = "Primary"
			end

			if v5 == v3 then
				self:SetTimer(0, _ensureBucketTimer.default)

				if UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_COOLDOWN.id, Gamepasses.VIP) then
					self.Instance.Visible = false
				end
			end
		end
	end)
end

function v:IsOnCooldown(p2: string?)
	local type2 = normalizeType(p2 or self._activeHouseType) -- equivalent call inferred; original call site unknown
	local v3 = string.lower(type2)
	local v4

	if v3 == "motel" or v3 == "motels" then
		v4 = "Motels"
	else
		v4 = "Primary"
	end

	local _timer = self._timers[v4]
	return _timer and _timer.onCooldown or false
end

function v:GetDuration(p2: string?)
	local type2 = normalizeType(p2 or self._activeHouseType) -- equivalent call inferred; original call site unknown
	local v3 = string.lower(type2)
	local v4

	if v3 == "motel" or v3 == "motels" then
		v4 = "Motels"
	else
		v4 = "Primary"
	end

	local _timer = self._timers[v4]
	return _timer and _timer.duration or 0
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._activeHouseType = self.Instance:GetAttribute("HouseType") or "Houses"
	self._title = self.Instance:WaitForChild("Title")
	self._subtitle = self.Instance:WaitForChild("Subtitle")
	self._timers = {}
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:PromptPurchase()
	end))
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p: string)
		if p == AdFeatures.VIP_HOUSE_COOLDOWN.id then
			self:UpdateVisibility()
			self._timers = {}
		end
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(p: number)
		if p == Gamepasses.GetId(Gamepasses.VIP) then
			self:UpdateVisibility()
			self._timers = {}
		end
	end))
end

function v:Start()
	GamepassController.WaitForGamepasses()
	self:UpdateVisibility()
end

function v:SetActiveHouseType(value: string)
	self._activeHouseType = normalizeType(value)
	local _activeHouseType = self._activeHouseType
	local v2 = string.lower(_activeHouseType)
	local v3

	if v2 == "motel" or v2 == "motels" then
		v3 = "Motels"
	else
		v3 = "Primary"
	end

	local _ensureBucketTimer = self:_ensureBucketTimer(v3)

	if _ensureBucketTimer.default == 0 then
		local defaultForBucket = getDefaultForBucket(v3) -- equivalent call inferred; original call site unknown
		_ensureBucketTimer.default = defaultForBucket
	end

	self:SetTimer(_ensureBucketTimer.duration, _ensureBucketTimer.default)
end

function v:SetTimer(p: number, p2: number)
	local v2 = formatDynamicTime(p) -- equivalent call inferred; original call site unknown
	local v3 = formatStaticTime(p2)

	if UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_COOLDOWN.id, Gamepasses.VIP) then
		self._title.Text = string.format("Time left: %s", v2)
		self._subtitle.Text = "Please wait"
	elseif p == p2 or p <= 0 then
		self._title.Text = "No wait time for VIP"
		self._subtitle.Text = string.format("%s cooldown = %s", self._activeHouseType, v3)
	else
		self._title.Text = string.format("Time left: %s", v2)
		self._subtitle.Text = "Get VIP to skip!"
	end
end

function v:PromptPurchase()
	if UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_COOLDOWN.id, Gamepasses.VIP) then
		return
	end

	GamepassController.Show(
		Gamepasses.VIP,
		nil,
		`{self._activeHouseType} cooldown`,
		nil,
		AdFeatures.VIP_HOUSE_COOLDOWN,
		`{self._activeHouseType} cooldown timer active: buy VIP Gamepass to remove`,
		"HouseUI",
		"VIP"
	)
end

function v:UpdateVisibility()
	local isPrivateServer = GameUtil.IsPrivateServer()
	local isFeatureUnlocked = UnlockableController.IsFeatureUnlocked(AdFeatures.VIP_HOUSE_COOLDOWN.id, Gamepasses.VIP)
	self.Instance.Visible = not (isPrivateServer or isFeatureUnlocked)
end

function v:Stop()
	for _, _timer in pairs(self._timers) do
		_timer.token = nil
	end

	self._Janitor:Destroy()
end

return v