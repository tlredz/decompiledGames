local GachaWindow = {
	_setSourceHidden = nil
}
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local PolicyServiceClient = require(game.ReplicatedStorage.Controllers.PolicyServiceClient)
local Locks = require(game.ReplicatedStorage.Controllers.Locks)
local SceneController = require(game.ReplicatedStorage.Controllers.SceneController)
local maid = nil
local v = nil
local v2 = Signal.new()
local v3 = Signal.new()
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local useBannerItem = require(game.ReplicatedStorage.React.Hooks.Gacha.useBannerItem)

function GachaWindow:Close(flag: boolean?)
	if flag then
		if maid then
			maid:Destroy()
		end
	elseif GachaWindow:IsOpen() then
		v2:Fire()
	end
end

function GachaWindow:IsOpen()
	return maid ~= nil
end

function GachaWindow.WaitForClose(_)
	local bindableEvent

	if maid then
		bindableEvent = Instance.new("BindableEvent")
		maid:Add(function()
			bindableEvent:Fire()
			bindableEvent:Destroy()
		end)
	else
		bindableEvent = nil
	end

	if bindableEvent then
		bindableEvent.Event:Wait()
	end
end

function GachaWindow:OnStart()
	v3:Connect(function(p, p2, p3)
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local character = localPlayer.Character
		local gachaAsync = GachaClient.GetGachaAsync(p)

		if not gachaAsync.ENABLED then
			return
		end

		if gachaAsync.POLICY_SERVICE_REQUIREMENTS and gachaAsync.POLICY_SERVICE_REQUIREMENTS.ArePaidRandomItemsRestricted and PolicyServiceClient.GetAsync().ArePaidRandomItemsRestricted == true then
			local Notification = require(game.ReplicatedStorage.Notification)
			Notification.new("This gacha is disabled in your region.", 5)
		else
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if localPlayer.Character ~= character or not humanoid or humanoid.Health <= 0 then
				return
			end

			if v == p then
				print("same window")
				return
			end

			local setSourceHidden = p3 or GachaWindow._setSourceHidden

			if not setSourceHidden then
				local Global = require(game.ReplicatedStorage.Global)
				Global.closeOthers("Gacha")
			end

			if setSourceHidden == GachaWindow._setSourceHidden then
				GachaWindow._setSourceHidden = nil
			end

			if maid then
				maid:Destroy()
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.ScreenInsets = Enum.ScreenInsets.None
			screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
			screenGui.IgnoreGuiInset = false
			screenGui.Name = `{p}_Window`
			local Players2 = game:GetService("Players")
			screenGui.Parent = Players2.LocalPlayer:WaitForChild("PlayerGui")
			screenGui.DisplayOrder = 1
			screenGui.Enabled = true
			screenGui.ResetOnSpawn = false
			local root = ReactRoblox.createRoot(screenGui)
			local v5 = Trove.new()
			maid = v5
			v = p
			GachaWindow._setSourceHidden = setSourceHidden

			if setSourceHidden then
				setSourceHidden(true)
			end

			Locks.GachaWindowLock:Lock()
			assert(maid):Add(function()
				v = nil
				maid = nil
				local _setSourceHidden = GachaWindow._setSourceHidden
				GachaWindow._setSourceHidden = nil
				Locks.GachaWindowLock:Unlock()
				SceneController.Destroy()
				root:unmount()
				screenGui:Destroy()

				if _setSourceHidden then
					_setSourceHidden(false)
				end
			end)
			v5:Connect(humanoid.Died, function()
				v5:Destroy()
			end)
			v5:Connect(localPlayer.CharacterRemoving, function(p4)
				if p4 == character then
					v5:Destroy()
				end
			end)
			local Spinner = require(game.ReplicatedStorage.Controllers.UI.Spinner)

			if maid ~= v5 or localPlayer.Character ~= character or humanoid.Health <= 0 then
				v5:Destroy()
				return
			end

			local UID = 1

			local function fn()
				local ref = React.useRef(maid)
				local state, setState = React.useState({
					Value = nil,
					UID = 0
				})
				local sendNotification = React.useCallback(function(p4: string)
					UID += 1
					setState({
						Value = p4,
						UID = UID
					})
				end)
				local state2, setState2 = React.useState(true)
				React.useEffect(function()
					local connection = v2:Connect(function()
						setState2(false)
					end)
					return function()
						connection:Disconnect()
					end
				end, {})
				local ref2 = React.useRef(1)
				local v8 = React.useCallback(function(p4)
					if tick() - ref2.current < 1 then
						print("debouncePurchase")
						return
					end

					ref2.current = tick()
					local purchaseGachaAsync, v9 = GachaClient.PurchaseGachaAsync(p4)

					if purchaseGachaAsync then
						Sound:Play("Blox_Purchase_01", nil, nil, nil, 2)
					elseif v9 then
						sendNotification(v9.ErrorMessage)
					else
						sendNotification("Error")
					end
				end, {})

				if gachaAsync.BOX_NAME == "PremiumChromaticMagnetGacha26" then
					local Premium = require(script.Controllers.MagnetEvent26.Premium)
					local state3, setState3 = React.useState(true)
					React.useEffect(function()
						if state3 == false then
							SceneController.DestroyRig()
						end
					end, { state3 })
					React.useEffect(function()
						if ref.current then
							ref.current:Add(Spinner.OnOpen(function()
								setState3(false)
							end))
							ref.current:Add(Spinner.OnClose(function()
								setState3(true)
							end))
						end
					end, { ref.current })
					return React.createElement(Premium, {
						Visible = state3,
						Close = function()
							GachaWindow:Close(true)
						end,
						SendNotification = sendNotification
					})
				else
					React.useEffect(function()
						if ref.current then
							ref.current:Add(SceneController.Destroy)
							ref.current:Add(Spinner.OnOpen(function()
								GachaWindow:Close(true)
							end))
						end
					end, { ref.current })

					if gachaAsync.BOX_NAME == "MagnetEventGacha26" then
						local FreeToPlay = require(script.Controllers.MagnetEvent26.FreeToPlay)
						local v9 = {
							TryPurchase = function()
								v8(gachaAsync.BOX_NAME)
							end,
							Cost = assert(gachaAsync.ROLL_COST),
							BoxName = gachaAsync.BOX_NAME,
							Close = function()
								GachaWindow:Close(true)
							end,
							Notification = state,
							SendNotification = sendNotification,
							OpenGacha = function(p4, p5)
								GachaWindow:Open(p4, p5)
							end
						}
						return React.createElement(FreeToPlay, v9)
					else
						if gachaAsync.WINDOW ~= "Cousin" then
							error((`unknown window={p}:{gachaAsync.WINDOW}`))
							return
						end

						local Cousin = require(script.Controllers.Cousin)
						local v9 = use("Silver Key", "Material")
						local bannerItem = useBannerItem()
						local useState = React.useState
						local v11

						if bannerItem then
							v11 = bannerItem.BoxName
						else
							v11 = gachaAsync.BOX_NAME
						end

						local state3, setState3 = useState(v11)
						React.useEffect(function()
							if bannerItem then
								setState3(bannerItem.BoxName)
							else
								setState3(gachaAsync.BOX_NAME)
							end
						end, { bannerItem })
						local v12 = {
							TryPurchase = function()
								v8(state3)
							end,
							Cost = assert(p2),
							BoxName = state3,
							SetClosed = function()
								setState2(false)
							end,
							Close = function()
								GachaWindow:Close(true)
							end,
							IsOpen = state2,
							Notification = state,
							Keys = {
								Silver = v9 or 0
							},
							BannerItem = bannerItem
						}
						return React.createElement(Cousin, v12)
					end
				end
			end

			local thread = task.spawn(function()
				root:render((ReactRoblox.createPortal(createElement(fn, {
					Root = screenGui
				}), screenGui)))
			end)
			maid:Add(thread)
		end
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Gacha", function(...)
			return self:Open(...)
		end, function(...)
			return self:Close(...)
		end, function()
			return self:IsOpen()
		end)
	end)
end

function GachaWindow:Open(p, p2, callback)
	v3:Fire(p, p2, callback)
end

return GachaWindow