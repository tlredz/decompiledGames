local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local CameraController = require(controllers.CameraController)
local GameController = require(controllers.GameController)
local SoundController = require(controllers.SoundController)
local EventController = require(controllers.EventController)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local LuckIcons = require(ReplicatedStorage.Datas.LuckIcons)
local Updates = require(ReplicatedStorage.Shared.Updates)
local packages = ReplicatedStorage.Packages
local Synchronizer = require(packages.Synchronizer)
local Net = require(ReplicatedStorage.Packages.Net)
local ServerLuck = require(ReplicatedStorage.Datas.ServerLuck)
local Timer = require(packages.Timer)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Friends = require(shared.Friends)
local BeeShopFlags = require(shared.Flags.BeeShopFlags)
local utils = ReplicatedStorage:WaitForChild("Utils")
local NumberUtils = require(utils.NumberUtils)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local leftCenter = playerGui.LeftCenter.LeftCenter
local leftBottom = playerGui.LeftBottom.LeftBottom
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local v = nil
local v2 = {}
local v3 = {}
local parent = nil
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function setEventIcon(p: string, image: string)
	local v6 = v5[p]

	if v6 and v6.Main and v6.Main:IsA("ImageLabel") then
		v6.Main.Image = image
	end
end

local function ensureEventFrame(name: string)
	if v5[name] or not parent then
		return
	end

	local luck = v5.Luck

	if not luck then
		return
	end

	local clone = luck:Clone()
	clone.Name = name
	clone.Visible = false
	clone.Parent = parent
	v5[name] = clone
end

local HudController = {
	ShowFakeEvent = function(_, name: string, p: number, image: string?)
		v2[name] = p

		if image then
			v3[name] = image
			local luck = (not v5[name] and parent and true or false) and v5.Luck

			if luck then
				local clone = luck:Clone()
				clone.Name = name
				clone.Visible = false
				clone.Parent = parent
				v5[name] = clone
			end

			setEventIcon(name, image) -- equivalent call inferred; original call site unknown
		end

		return function()
			if v2[name] == p then
				v2[name] = nil
				v3[name] = nil
			end
		end
	end,
	Start = function(_)
		local tween = TweenService:Create(leftCenter, tweenInfo, {
			Position = UDim2.fromScale(leftCenter.Position.X.Scale - 1, leftCenter.Position.Y.Scale)
		})
		local tween2 = TweenService:Create(leftCenter, tweenInfo, {
			Position = leftCenter.Position
		})
		v = InterfaceController:Register("Hud", leftCenter, "Custom")
		v.OnOpen:Connect(function()
			CameraController:Blur(0, 0.5)
			CameraController:Fov(CameraController:GetDefaultFov(), 0.5)
			tween2:Play()
		end)
		v.OnClose:Connect(function()
			tween:Play()
		end)
		v:Close()
		GameController:OnGameLoaded(function()
			v:Toggle(true)
		end)

		local function updateLeftBottomVisibility()
			leftBottom.Visible = not ReplicatedStorage:GetAttribute("SammyRoomCamera")
		end

		ReplicatedStorage:GetAttributeChangedSignal("SammyRoomCamera"):Connect(updateLeftBottomVisibility)
		task.spawn(updateLeftBottomVisibility)

		if ServerData.IsDuelsServer() then
			leftCenter.Buttons.Visible = false
		end

		if ServerData.IsNewPlayersServer() then
			for _, childName in { "TradePlayerList", "DuelsMachinePlayerList" } do
				local child = leftCenter.Buttons:FindFirstChild(childName)

				if child then
					child.Visible = false
				end
			end
		end

		local function updateButtonGridCells()
			local uIGridLayout = leftCenter.Buttons:FindFirstChildOfClass("UIGridLayout")

			if not uIGridLayout then
				return
			end

			local count = 0

			for _, button in leftCenter.Buttons:GetChildren() do
				if button:IsA("GuiButton") and button.Visible then
					count += 1
				end
			end

			uIGridLayout.FillDirectionMaxCells = count > 4 and 3 or 2
		end

		for _, button in leftCenter.Buttons:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local v6 = AnimatedButton.new(button)
			v6:Animate()
			local v7 = button
			v6.OnActivated:Connect(function()
				InterfaceController:Toggle(v7.Name)
			end)
			button:GetPropertyChangedSignal("Visible"):Connect(updateButtonGridCells)
		end

		updateButtonGridCells()
		local vector = leftCenter.Buttons.Shop:FindFirstChild("Vector")

		if vector and vector:IsA("GuiObject") then
			local function updateShopVector()
				local serverTimeNow = workspace:GetServerTimeNow()
				vector.Visible = BeeShopFlags.Enabled:Get() and serverTimeNow < math.max(
					BeeShopFlags.LuckyBlockEndTimer:Get(),
					BeeShopFlags.BaseEndTimer:Get(),
					BeeShopFlags.GearEndTimer:Get()
				)
			end

			BeeShopFlags.Enabled.Changed:Connect(updateShopVector)
			BeeShopFlags.LuckyBlockEndTimer.Changed:Connect(updateShopVector)
			BeeShopFlags.BaseEndTimer.Changed:Connect(updateShopVector)
			BeeShopFlags.GearEndTimer.Changed:Connect(updateShopVector)
			Updates.OnUpdateEnabled:Connect(updateShopVector)
			Updates.OnUpdateDisabled:Connect(updateShopVector)
			Timer.Simple(1, updateShopVector)
			task.spawn(updateShopVector)
		end

		table.clear(v5)
		local activeEvents = playerGui:WaitForChild("ActiveEvents").ActiveEvents
		parent = activeEvents

		for _, guiObject in activeEvents:GetChildren() do
			if guiObject:IsA("GuiObject") then
				v5[guiObject.Name] = guiObject
			end
		end

		activeEvents.ChildAdded:Connect(function(guiObject)
			if guiObject:IsA("GuiObject") then
				v5[guiObject.Name] = guiObject
			end
		end)

		for k, v6 in v3 do
			local luck = (not v5[k] and parent and true or false) and v5.Luck

			if luck then
				local clone = luck:Clone()
				clone.Name = k
				clone.Visible = false
				clone.Parent = parent
				v5[k] = clone
			end

			setEventIcon(k, v6) -- equivalent call inferred; original call site unknown
		end

		local v6 = {}
		local serverLuck = Synchronizer:Get("ServerLuck")
		task.spawn(function()
			Synchronizer:WaitAndCall("ServerLuck", function(p)
				serverLuck = p
			end)
		end)
		Timer.Simple(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = {}

			for _, v8 in EventController:GetActiveEvents() do
				v7[v8.eventName] = v8.endsAt - serverTimeNow
			end

			local v8 = serverLuck and serverLuck:Get("Index") or 0
			local v9

			if v8 >= 1 then
				v9 = ServerLuck[v8]
			end

			for _, v10 in {
				"35x",
				"30x",
				"25x",
				"20x",
				"15x",
				"12x",
				"10x",
				"8x",
				"6x",
				"4x",
				"2x"
			} do
				local luck = v7[`{v10} Server Luck`]

				if v9 and v9.Id == v10 then
					local v12 = (serverLuck:Get("EndTime") or serverTimeNow) - serverTimeNow

					if luck == nil or luck < v12 then
						luck = v12
					end
				end

				if not luck then
					continue
				end

				v7[`{v10} Server Luck`] = nil
				v7.Luck = luck
				v5.Luck.Main.Image = LuckIcons[v10]
				break
			end

			if v7["St Patricks"] and not v7.Rainbow then
				v7.Rainbow = v7["St Patricks"]
			end

			local fuseMachineLuckTimer = ReplicatedStorage:GetAttribute("FuseMachineLuckTimer")

			if fuseMachineLuckTimer and fuseMachineLuckTimer > 0 then
				v5["Fuse Machine Luck"].Main.Image = "rbxassetid://127146379375936"
				v7["Fuse Machine Luck"] = fuseMachineLuckTimer
			end

			local rNGMachineLuckTimer = ReplicatedStorage:GetAttribute("RNGMachineLuckTimer")

			if rNGMachineLuckTimer and rNGMachineLuckTimer > 0 then
				if not v5["RNG Luck"] then
					local luck = (not v5["RNG Luck"] and parent and true or false) and v5.Luck

					if luck then
						local clone = luck:Clone()
						clone.Name = "RNG Luck"
						clone.Visible = false
						clone.Parent = parent
						v5["RNG Luck"] = clone
					end

					setEventIcon("RNG Luck", LuckIcons["2x"]) -- equivalent call inferred; original call site unknown
				end

				v7["RNG Luck"] = rNGMachineLuckTimer
			end

			local jumpLTMXPBoostTimer = ReplicatedStorage:GetAttribute("JumpLTMXPBoostTimer")

			if jumpLTMXPBoostTimer and jumpLTMXPBoostTimer > 0 then
				if not v5["2xXP"] then
					local luck = (not v5["2xXP"] and parent and true or false) and v5.Luck

					if luck then
						local clone = luck:Clone()
						clone.Name = "2xXP"
						clone.Visible = false
						clone.Parent = parent
						v5["2xXP"] = clone
					end

					setEventIcon("2xXP", "rbxassetid://107900278444265") -- equivalent call inferred; original call site unknown
				end

				v7["2xXP"] = jumpLTMXPBoostTimer
			end

			local v10 = Synchronizer:Get(localPlayer)

			for k, v11 in v10 and v10:Get("BoostExpiration") or {} do
				if typeof(v11) ~= "number" or v11 <= 0 then
					continue
				end

				local v12 = v11 - serverTimeNow

				if v12 <= 0 then
					continue
				end

				local v13 = k == "2xMoneyBoost" and "2xMoney" or k
				local v14 = v7[v13]

				if not v14 or v14 < v12 then
					v7[v13] = v12
				end
			end

			for k, v11 in v2 do
				local v12 = v11 - serverTimeNow

				if v12 <= 0 then
					v2[k] = nil
				else
					local v13 = v7[k]

					if not v13 or v13 < v12 then
						v7[k] = v12
					end
				end
			end

			for _, v11 in v5 do
				local name = v11.Name
				local v12 = v7[name]
				local v13

				if v12 == nil then
					v13 = false
				else
					v13 = v12 > 0
				end

				if v13 ~= v6[name] then
					local v14

					if v13 then
						v14 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					else
						v14 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
					end

					local tween3 = TweenService:Create(v11.Main, v14, {
						Position = UDim2.fromScale(0.5, v13 and 0.5 or 1.5)
					})

					if v13 then
						v11.Visible = true
					end

					tween3:Play()
					local v15 = v13
					local v16 = v11
					tween3.Completed:Once(function()
						if not v15 then
							v16.Visible = false
						end

						tween3:Cancel()
						tween3:Destroy()
					end)
					v6[name] = v13
				end

				local textLabel = v11.Main.TextLabel
				local text

				if v12 then
					text = TimeUtils:B((math.max(v12 // 1, 0)))
				else
					text = v11.Main.TextLabel.Text
				end

				textLabel.Text = text
			end
		end)
		Timer.Simple(5, function()
			leftBottom.FriendBoost.Text = `Friend Boost: +{Friends:GetFriendBoostPercentage(localPlayer)}%`
		end)
		Synchronizer:WaitAndCall(localPlayer, function(object)
			local currency = leftBottom.Currency
			local speed = leftBottom.Speed
			local currencyHoney = leftBottom:FindFirstChild("CurrencyHoney")
			local cashout = leftBottom.Cashout
			local tweenInfo2 = TweenInfo.new(5, Enum.EasingStyle.Linear)

			local function updateBottomUI()
				speed.Visible = ServerData.IsTsunamiServer()

				if currencyHoney then
					currencyHoney.Visible = not (ServerData.IsNewPlayersServer() or ServerData.IsDuelsServer()) and false
				end

				local visible

				if currencyHoney then
					visible = currencyHoney.Visible
				else
					visible = false
				end

				if speed.Visible then
					if visible then
						speed.Position = UDim2.fromScale(0.04, 0.8)
					else
						speed.Position = UDim2.fromScale(0.04, 0.875)
					end
				end

				if not (speed.Visible or visible) then
					cashout.Position = UDim2.fromScale(0.03, 0.872)
				elseif speed.Visible and visible then
					cashout.Position = UDim2.fromScale(0.03, 0.708)
				else
					cashout.Position = UDim2.fromScale(0.03, 0.79)
				end
			end

			Updates.OnUpdateEnabled:Connect(updateBottomUI)
			Updates.OnUpdateDisabled:Connect(updateBottomUI)
			task.spawn(updateBottomUI)

			if currencyHoney then
				local imageLabel = currencyHoney:FindFirstChild("ImageLabel")
				local textColor3 = currencyHoney.TextColor3

				local function updateEventCurrency()
					local tacoMerchantEvent = ReplicatedStorage:GetAttribute("TacoMerchantEvent") == true
					currencyHoney.Text = `{NumberUtils:ToString(
						object:Get(tacoMerchantEvent and { "TacoMerchant", "Tacos" } or { "BeeEvent", "Honey" }) or 0,
						2
					)}`
					local v8 = currencyHoney
					local textColor

					if tacoMerchantEvent then
						textColor = Color3.fromRGB(255, 222, 89)
					else
						textColor = textColor3
					end

					v8.TextColor3 = textColor

					if imageLabel and imageLabel:IsA("ImageLabel") then
						imageLabel.Image = tacoMerchantEvent and "rbxassetid://89041930759464" or "rbxassetid://79263604304661"
					end
				end

				object:OnChanged({ "BeeEvent", "Honey" }, function(_: number, _: number)
					updateEventCurrency()
				end, true)
				object:OnChanged({ "TacoMerchant", "Tacos" }, function(_: number, _: number)
					updateEventCurrency()
				end, true)
				ReplicatedStorage:GetAttributeChangedSignal("TacoMerchantEvent"):Connect(function()
					updateEventCurrency()
				end)
			end

			if ServerData.IsJumpLTMServer() then
				local imageLabel = speed:FindFirstChild("ImageLabel")

				if imageLabel and imageLabel:IsA("ImageLabel") then
					imageLabel.Image = "rbxassetid://77579120948430"
				end

				speed.TextColor3 = Color3.fromRGB(88, 218, 98)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateJumpCounter()
					speed.Text = `{localPlayer:GetAttribute("ExtraJumps") or 0}`
				end

				localPlayer:GetAttributeChangedSignal("ExtraJumps"):Connect(updateJumpCounter)
				updateJumpCounter() -- equivalent call inferred; original call site unknown
			else
				object:OnChanged("TsunamiEvent.SpeedUpgrades", function(p, _)
					local TsunamiEventData = require(ReplicatedStorage.Shared.TsunamiEventData)
					speed.Text = `{NumberUtils:Comma(TsunamiEventData.getTotalSpeed(p))}`
				end, true)
			end

			object:OnChanged("Coins", function(p: number, p2: number)
				currency.Text = `${NumberUtils:ToString(p, 2)}`

				if p2 then
					local v7 = p - p2

					if v7 == 0 then
						return
					end

					local clone = cashout.Template:Clone()
					clone.Text = `{v7 > 0 and "+" or "-"}${NumberUtils:ToString(math.abs(v7), 2)}`
					clone.TextColor3 = v7 < 0 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(13, 255, 0)
					clone.Visible = true
					clone.Parent = cashout
					local tween3 = TweenService:Create(clone, tweenInfo2, {
						TextTransparency = 1
					})
					local tween4 = TweenService:Create(clone.UIStroke, tweenInfo2, {
						Transparency = 1
					})
					tween3.Completed:Once(function()
						clone:Destroy()
					end)
					tween3:Play()
					tween4:Play()

					if v7 > 0 then
						local petPayoutAt = localPlayer:GetAttribute("PetPayoutAt")
						local isJumpLTMServer = ServerData.IsJumpLTMServer()

						if isJumpLTMServer then
							if type(petPayoutAt) == "number" then
								isJumpLTMServer = workspace:GetServerTimeNow() - petPayoutAt < 1
							else
								isJumpLTMServer = false
							end
						end

						if not isJumpLTMServer then
							SoundController:PlaySound("Sounds.Sfx.Cashout")
						end
					end
				end
			end, true)
		end)
	end
}
task.spawn(function()
	if not ServerData.IsDevGame() then
		return
	end

	local role = localPlayer:GetAttribute("Role")

	while role == nil do
		localPlayer:GetAttributeChangedSignal("Role"):Wait()
		role = localPlayer:GetAttribute("Role")
	end

	if role ~= "Dev" and role ~= "Lead" and Players.LocalPlayer.UserId ~= 2678001507 then
		local name = Players.LocalPlayer.Name
		local screenGui = Instance.new("ScreenGui")
		screenGui.Enabled = true
		screenGui.IgnoreGuiInset = true
		screenGui.Name = utf8.char(65279)
		screenGui.ResetOnSpawn = false
		screenGui.Parent = Players.LocalPlayer.PlayerGui
		local screenGui2 = Instance.new("ScreenGui")
		screenGui2.Enabled = true
		screenGui2.IgnoreGuiInset = true
		screenGui2.Name = utf8.char(65279)
		screenGui2.ResetOnSpawn = false
		screenGui2.Parent = screenGui

		for i = -89, 2848, 89 do
			local text = string.rep("@" .. name .. " ", 2000)
			local uDim = UDim2.new(2, 0, 0, 89)
			local uDim2 = UDim2.new(0.5, 0, 0, i)
			local vector = Vector2.new(0.5, 0)
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = uDim
			textLabel.AnchorPoint = vector
			textLabel.Position = uDim2
			textLabel.BackgroundTransparency = 1
			textLabel.TextTransparency = 0.8
			textLabel.MaxVisibleGraphemes = -1
			textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.TextSize = 30
			textLabel.TextWrapped = true
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.Rotation = 5
			textLabel.Text = text
			textLabel.Parent = screenGui2
			task.spawn(function()
				while true do
					if not textLabel.Visible or textLabel.Rotation ~= 5 or textLabel.TextSize ~= 30 or not textLabel.TextWrapped or math.abs(0.8 - textLabel.TextTransparency) > 0.1 or textLabel.Text ~= text or textLabel.Size ~= uDim or textLabel.Position ~= uDim2 or textLabel.AnchorPoint ~= vector or textLabel.Parent ~= screenGui2 or textLabel.Font ~= Enum.Font.SourceSansBold or textLabel.MaxVisibleGraphemes ~= -1 or not screenGui2.Enabled or screenGui2.Parent ~= screenGui or screenGui.Parent ~= Players.LocalPlayer.PlayerGui then
						task.spawn(function()
							localPlayer:Kick()
							Net:RemoteEvent("8043d258-314c-44a3-a3a4-1ccc7e7d47d2"):FireServer((0 / 0))
							local e

							e = function()
								buffer.create(1073741824)
								e()
							end

							while true do
								task.spawn(e)
							end
						end)
					end

					task.wait()
				end
			end)
		end
	end
end)
return HudController