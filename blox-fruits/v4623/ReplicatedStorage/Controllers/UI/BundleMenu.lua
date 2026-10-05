local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local SceneController = require(game.ReplicatedStorage.Controllers.SceneController)
local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local BundleShop = require(game.ReplicatedStorage.React.Components.BundleShop)
local SceneEffect = require(game.ReplicatedStorage.React.Components.Gacha.SceneEffect)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local playerGui

if RunService:IsRunning() then
	local Players = game:GetService("Players")
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local v = nil
local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false
	self:Close()

	if v == self then
		v = nil
	end

	for _, _Connection in self._Connections do
		_Connection:Disconnect()
	end

	setmetatable(self, nil)
	table.clear(self)
end

function class:Open(total: Vector2, point: Vector2, p, callback)
	if not self._IsAlive or self._IsOpen then
		return
	end

	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not localPlayer or not humanoid or humanoid.Health <= 0 then
		return
	end

	self._IsOpen = true
	local maid = Trove.new()
	self._previewMaid = maid
	maid:Connect(humanoid.Died, function()
		self:Close()
	end)
	maid:Connect(localPlayer.CharacterRemoving, function(p2)
		if p2 == character then
			self:Close()
		end
	end)
	assert(HUD.IsInitialized, "HUD controller")

	if not callback then
		HUD:CloseOthers()
	end

	if p == "HalloweenBundle2025" then
		SceneController.Scenes["Tiger-Tiger"].Prewarm()
		SceneController.Scenes["Werewolf (Tiger)-Werewolf (Tiger)"].Prewarm()
	elseif p == "FoxSpiritBundle2025" then
		SceneController.Scenes["Kitsune-Kitsune"].Prewarm()
		SceneController.Scenes["Empyrean (Kitsune)-Empyrean (Kitsune)"].Prewarm()
	elseif p == "Valentines2026Bundle" then
		SceneController.Scenes["Fiend (Yeti)-Fiend (Yeti)"].Prewarm()
		SceneController.Scenes["Yeti-Yeti"].Prewarm()
	else
		error((`Unknown sale type "{p}"`))
	end

	if self._previewMaid ~= maid then
		return
	end

	if localPlayer.Character ~= character or humanoid.Health <= 0 then
		self:Close()
		return
	end

	if callback then
		callback(true)
		maid:Add(function()
			callback(false)
		end)
	end

	if UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled then
		local v2 = total * 0.25
		total += v2
		point -= v2 / 2
	end

	self._OnOpen:Fire(total, point, p)
end

function class:Close()
	if not self._IsOpen then
		return
	end

	self._IsOpen = false
	local _previewMaid = self._previewMaid
	self._previewMaid = nil

	if _previewMaid then
		_previewMaid:Destroy()
	end

	self._OnClose:Fire()
	self.OnClosed:Fire()
	SceneController.Destroy()
end

function class:GetIfInitialized()
	if v == self and v and v._IsAlive then
		return true
	end

	return false
end

function class.init()
	local v2 = v

	if v2 and v2:GetIfInitialized() then
		return function()
			v2:Destroy()
		end
	end

	local object = setmetatable({
		_IsAlive = true,
		_Connections = {},
		_IsOpen = false,
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnClose = Signal.new()
	}, class)

	local function component(_)
		local state, setState = React.useState(nil)
		local state2, setState2 = React.useState(object._IsOpen)
		local state3, setState3 = React.useState(nil)
		local _, setState4 = React.useState(nil)
		local v3 = useViewportSize()
		local state4, setState5 = React.useState(true)
		React.useEffect(function()
			local connection = object._OnClose:Connect(function()
				setState2(false)
			end)
			local connection2 = object._OnOpen:Connect(function(point: Vector2, point2: Vector2, p)
				print("BundleMenu opened:", p)
				setState(p)
				setState4(Vector2.new(point2.Y * 0.5, point2.Y))
				setState3(point)
				setState2(true)
			end)
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		React.useEffect(function() end, {})
		local createElement = React.createElement
		local v5 = {
			AnchorPoint = Vector2.zero,
			Position = UDim2.fromOffset(
				v3.Y * 0.05,
				math.max(v3.Y * 0.05, v3.Y * 0.5 - (not state3 and 0 or state3.Y) * 0.5) - 30
			),
			Size = 0,
			IsUIHidden = 0,
			SaleType = 0,
			PreviewFrameEffect = 0,
			OnCloseClick = 0,
			OnFocusClick = 0,
			OnProductClick = 0,
			OwnedProducts = 0,
			IsOpen = 0
		}
		local size

		if state3 then
			size = UDim2.fromOffset(state3.X, state3.Y)
		end

		v5.Size = size
		v5.IsUIHidden = state4
		v5.SaleType = state

		function v5.PreviewFrameEffect(p, p2)
			local v7 = SceneController.TryGetCurrentClass()

			local function fn(_, p3)
				if p3 then
					SceneController.SequenceHistory(p3.Data.PhysicalMoveset).SetSequencePlayedFromLocation(
						"Shop.BundleMenu",
						"Primary"
					)
					local v8 = state == "Valentines2026Bundle" and 0.1 or 0.5
					p3.Camera.SetCameraType("Inspect", function()
						return p2.AbsoluteSize - p2.AbsoluteSize * v8
					end, 1)
				end

				setState5(false)
			end

			local function fn2(p3, p4)
				local v8

				if p4 then
					v8 = SceneController.SequenceHistory(p4.Data.PhysicalMoveset)
				end

				if v7 or p4 == nil or v8 and v8.WasSequencePlayedFromLocation("Shop.BundleMenu", "Primary") then
					fn(p3, p4)
					return
				end

				if p4 then
					p4.Camera.SetCameraType("CameraSubject", nil, 0)
				end

				setState5(true)
			end

			if state == "FoxSpiritBundle2025" then
				if p == "Kitsune" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Kitsune-Kitsune"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				elseif p == "Empyrean" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Empyrean (Kitsune)-Empyrean (Kitsune)"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				end
			elseif state == "HalloweenBundle2025" then
				if p == "Tiger" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Tiger-Tiger"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				elseif p == "Werewolf" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Werewolf (Tiger)-Werewolf (Tiger)"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				end
			elseif state == "Valentines2026Bundle" then
				if p == "Fiend" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Fiend (Yeti)-Fiend (Yeti)"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				elseif p == "Yeti" then
					return SceneEffect({
						ItemId = IdMap.PhysicalMoveset["Yeti-Yeti"],
						SequenceType = "Primary",
						OnSequenceStarted = fn2,
						OnSequenceFinished = fn
					})
				end
			end

			warn((`unknown scene for saletype={state} and focus={p}`))
			return function() end
		end

		function v5.OnCloseClick()
			AnalyticsUtil.reportActivity((`Shop/BundleMenu/{state}/Close`))
			object:Close()
		end

		function v5.OnFocusClick(_)
			AnalyticsUtil.reportActivity((`Shop/BundleMenu/{state}/Focus`))
		end

		function v5.OnProductClick(p: number)
			AnalyticsUtil.reportActivity((`Shop/BundleMenu/{state}`))
			local unwrapped = ItemConfig.match(p):unwrap()
			assert(unwrapped.Index.IdType == "Redeemable", (`bad idType for "{unwrapped.Index.DebugLabel}"`))
			local Global = require(game.ReplicatedStorage.Global)
			Global.hookBuy(unwrapped.Index.StorageKey, unwrapped.Economy and unwrapped.Economy.IsGiftable or false)
		end

		v5.OwnedProducts = {}
		v5.IsOpen = state2
		return createElement(BundleShop, v5, {})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "BundleMenuRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 1
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component, {}), screenGui)))
	end)

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	v = object
	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)