local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
ReplicatedStorage2:WaitForChild("events")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local ui = ReplicatedStorage3:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("ui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local debris = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))
require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("items"))
require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("fish"))
require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("bait"))
require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rods"))
require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("harpoonGuns"))
require(ReplicatedStorage.shared.modules.library.lanterns)
require(ReplicatedStorage.shared.modules.fishing.bobbers)
require(ReplicatedStorage.shared.modules.vessels)
local LocalCurrencies = require(ReplicatedStorage.shared.modules.LocalCurrencies)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
require(ReplicatedStorage3.shared.modules:WaitForChild("character"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local CurrencyController = require(ReplicatedStorage.client.legacyControllers.CurrencyController)
local WindowController = require(ReplicatedStorage.client.legacyControllers.WindowController)
local ViewOddsController = require(ReplicatedStorage.client.legacyControllers.ViewOddsController)
local Trove = require(ReplicatedStorage:WaitForChild("packages").Trove)
local InputController = require(ReplicatedStorage.client.legacyControllers.InputController)
require(ReplicatedStorage.client.legacyControllers.HudController)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local maid = Trove.new()
local v = ""
local text = 1
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
require(ReplicatedStorage.shared.modules.Utilities)
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local remoteFunction = Net:RemoteFunction("AuroraTotem/Purchase")
local events = ReplicatedStorage.events
local promptAmount = events.PromptAmount

local function getDataFolder()
	return legacyLocalPlayerData.fetch():WaitForChild("Stats")
end

local function Toggle(p)
	if p == true then
		fx:PlaySound(
			ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("open"),
			script.Parent,
			true
		)
		local hud = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("hud")
		hud.Enabled = false
		local backpack = localPlayer:WaitForChild("PlayerGui"):WaitForChild("backpack")
		backpack.Enabled = false
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = 60
			}
		):Play()
		local Lighting = game:GetService("Lighting")
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 10
			}
		):Play()
		local Lighting2 = game:GetService("Lighting")
		TweenService:Create(
			Lighting2:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = -0.07,
				TintColor = Color3.fromRGB(184, 184, 184),
				Saturation = -0.3
			}
		):Play()
	elseif p == false then
		local hud_2 = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("hud")
		hud_2.Enabled = true
		local backpack_2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("backpack")
		backpack_2.Enabled = true

		if not WindowController.CurrentWindow then
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			):Play()
			local Lighting = game:GetService("Lighting")
			TweenService:Create(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			):Play()
			local Lighting2 = game:GetService("Lighting")
			TweenService:Create(
				Lighting2:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = 0
				}
			):Play()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrencyDisplay(p)
	if p.LocalCurrency and LocalCurrencies[p.LocalCurrency] then
		return LocalCurrencies[p.LocalCurrency].DisplayName or p.LocalCurrency
	end

	return CurrencyController:GetDisplay()
end

local frozen = table.freeze({
	rod = true,
	boat = true,
	spear = true,
	lantern = true,
	bobber = true,
	harpoongun = true
})

local function DenyPrompt(text2)
	if localPlayer.PlayerGui:WaitForChild("over"):FindFirstChild("prompt") then
		return
	end

	local clone = ui:WaitForChild("deny"):Clone()
	clone.Name = "prompt"
	clone.info.Text = text2
	clone.Parent = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("over") or nil
	Toggle(true)
	local v2 = false
	local buttonDownConnection = nil
	buttonDownConnection = InputController:Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean)
		if not (flag ~= true and p == Enum.KeyCode.ButtonB) then
			return
		end

		if v2 == false then
			if buttonDownConnection then
				buttonDownConnection:Disconnect()
				buttonDownConnection = nil
			end

			v2 = true
			clone.Parent = nil
			clone:Destroy()
			Toggle(false)
		end
	end)
	clone.confirm.MouseEnter:Connect(function()
		local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage4:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
			script.Parent,
			true
		)
	end)
	clone.confirm.MouseButton1Click:Connect(function()
		if v2 == false then
			if buttonDownConnection then
				buttonDownConnection:Disconnect()
				buttonDownConnection = nil
			end

			v2 = true
			clone.Parent = nil
			clone:Destroy()
			Toggle(false)
		end
	end)
end

events:WaitForChild("denyprompt").OnClientEvent:Connect(DenyPrompt)
events:WaitForChild("prompt").OnClientEvent:Connect(function(value: string, p: number, value2: string, p2, p3)
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local fetched = legacyLocalPlayerData.fetch()
	local v2 = true
	local canPurchase, text3, v4 = FischUtils.CanPurchase(localPlayer, value2, value)

	if not (canPurchase and v4) then
		DenyPrompt(text3)
		return
	end

	if v4 then
		p = math.ceil(v4.Price * (v4.BuyMult or 1))
	else
		warn("No library data for item:", value, "using serverPrice:", p)
	end

	if playerGui and fetched then
		if playerGui:WaitForChild("over"):FindFirstChild("prompt") or not localPlayer.Character then
			return
		end

		if localPlayer.Character:FindFirstChildWhichIsA("Tool") and localPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("bobber") then
			return
		end

		WindowController:CloseActiveWindow()

		if CurrencyController:Get() < p and v2 == true then
			DenyPrompt("Insufficient funds.")
			return
		end

		local v5 = value == "Aurora Totem" or v4.OnlyBuyOne == true or frozen[value2:lower()] == true

		if v2 == true then
			local clone

			if string.lower(value2) == "rod" then
				clone = ui:WaitForChild("rodprompt"):Clone()
				clone.stats.Luck.Text = "Luck: " .. tostring(v4.Luck) .. "%"
				clone.stats.LureSpeed.Text = "Lure Speed: " .. tostring(100 - v4.LureSpeed) .. "%"
				clone.stats.Control.Text = "Control: " .. v4.Control
				clone.stats.Strength.Text = "Max Kg: " .. tostring(v4.Strength) .. "kg"
				clone.stats.Resilience.Text = "Resilience: " .. tostring(v4.Resilience) .. "%"
				clone.desc.Text = "\"" .. v4.Description .. "\""

				if 100 - v4.LureSpeed < 0 then
					clone.stats.LureSpeed.TextColor3 = Color3.fromRGB(177, 150, 150)
				end

				if v4.Luck < 0 then
					clone.stats.Luck.TextColor3 = Color3.fromRGB(177, 150, 150)
				end

				if v4.Control < 0 then
					clone.stats.Control.TextColor3 = Color3.fromRGB(177, 150, 150)
				end

				if v4.Resilience < 0 then
					clone.stats.Resilience.TextColor3 = Color3.fromRGB(177, 150, 150)
				end

				local currencyDisplay = getCurrencyDisplay(v4) -- equivalent call inferred; original call site unknown
				clone.question.Text = "Are you sure you would like to purchase [" .. value .. "] for " .. NumberUtils:Comma(p) .. ` {currencyDisplay}?`
			else
				clone = ui:WaitForChild("prompt"):Clone()
				local currencyDisplay = getCurrencyDisplay(v4) -- equivalent call inferred; original call site unknown

				if v5 then
					clone.question.Text = "Are you sure you would like to purchase [" .. value .. "] for " .. NumberUtils:Comma(p) .. ` {currencyDisplay}?`
				else
					clone.question.Text = "Are you sure you would like to purchase x1 [" .. value .. "] for " .. NumberUtils:Comma(p) .. ` {currencyDisplay}?`
				end
			end

			clone.Name = "prompt"

			if clone:FindFirstChild("amount") then
				legacyLocalPlayerData.fetch():WaitForChild("Stats")

				local function adjustAmount(text2)
					local v6 = math.max(1, text2)
					local v7 = v5 and 1 or v6
					local v8

					if v4.LocalCurrency then
						v8 = SharedDataHelper.readLegacyPathValue(localPlayer, { "LocalCurrencies", v4.LocalCurrency }) or 0
					else
						v8 = CurrencyController:Get()
					end

					local v9 = p

					if not v8 then
						return
					end

					local v10 = v5 and 1 or 1000

					if v9 * v7 <= v8 then
						local v11 = math.min(v7, v10)
						local currencyDisplay = getCurrencyDisplay(v4) -- equivalent call inferred; original call site unknown
						clone.question.Text = "Are you sure you would like to purchase x" .. v11 .. " [" .. value .. "] for " .. NumberUtils:Comma(p * v11) .. ` {currencyDisplay}?`
						text = v11
						return v11
					else
						local v11 = math.min(math.floor(v8 / v9), v10)
						local currencyDisplay = getCurrencyDisplay(v4) -- equivalent call inferred; original call site unknown
						clone.question.Text = "Are you sure you would like to purchase x" .. v11 .. " [" .. value .. "] for " .. NumberUtils:Comma(v9 * v11) .. ("%s?"):format(currencyDisplay)
						text = v11
						return v11
					end
				end

				local function textChanged(_)
					clone.amount.Text = string.gsub(clone.amount.Text, "%D+", "")
					local text2 = tonumber(clone.amount.Text)

					if text2 then
						clone.amount.Text = adjustAmount(text2)
					end
				end

				clone.amount:GetPropertyChangedSignal("Text"):Connect(textChanged)

				if v5 then
					clone.amount.Visible = false
				end

				if v5 then
					clone.amount.Visible = false
					clone.confirm.Size = UDim2.fromScale(0.42, 0.206)
					clone.deny.Size = UDim2.fromScale(0.42, 0.206)
				else
					if string.lower(v) == string.lower(value) then
						clone.amount.Text = adjustAmount(text)
					end

					clone.amount.Visible = true
					clone.confirm.Size = UDim2.fromScale(0.32, 0.206)
					clone.deny.Size = UDim2.fromScale(0.32, 0.206)
				end
			end

			clone.Parent = playerGui:WaitForChild("over")
			Toggle(true)
			clone.deny.MouseEnter:Connect(function()
				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
					script.Parent,
					true
				)
			end)
			clone.confirm.MouseEnter:Connect(function()
				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
					script.Parent,
					true
				)
			end)
			maid:Clean()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function ClearAndClose()
				maid:Clean()
				clone:Destroy()
				Toggle(false)
			end

			maid:Add(InputController:Get("Gamepad").ButtonDown:Connect(function(p4, flag: boolean)
				if flag == true then
					return
				end

				if p4 == Enum.KeyCode.ButtonB then
					ClearAndClose() -- equivalent call inferred; original call site unknown
				end
			end))
			clone.deny.Activated:Connect(function()
				ClearAndClose() -- equivalent call inferred; original call site unknown
			end)
			clone.confirm.Activated:Connect(function()
				if value == "Aurora Totem" then
					local v6, v7 = remoteFunction:InvokeServer(p3)

					if not v6 then
						ReplicatedStorage.events.anno_localthought:Fire(v7)
						ClearAndClose() -- equivalent call inferred; original call site unknown
						return
					end
				else
					events:WaitForChild("purchase"):FireServer(
						value,
						value2,
						p2,
						clone:FindFirstChild("amount") and tonumber(clone.amount.Text) or 1
					)
				end

				fx:PlaySound(
					ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("purchase"),
					script.Parent,
					false
				)
				local Lighting = game:GetService("Lighting")

				if Lighting:FindFirstChild("PurchasedCC") then
					local Lighting2 = game:GetService("Lighting")
					Lighting2:FindFirstChild("PurchasedCC"):Destroy()
				end

				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Name = "PurchasedCC"
				colorCorrectionEffect.Parent = game:GetService("Lighting")
				colorCorrectionEffect.TintColor = Color3.fromRGB(202, 255, 183)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TintColor = Color3.fromRGB(255, 255, 255)
					}
				):Play()
				debris:AddItem(colorCorrectionEffect, 2)
				v = tostring(value)

				if clone:FindFirstChild("amount") then
					text = tonumber(clone.amount.Text) or 1
				end

				ClearAndClose() -- equivalent call inferred; original call site unknown
			end)

			if v4 and v4.IsCrate then
				clone.openDetails.Visible = true
				clone.openDetails.Activated:Connect(function()
					ViewOddsController.ShowOdds("crate", value)
					ClearAndClose() -- equivalent call inferred; original call site unknown
				end)
			end
		end
	end
end)
local v2 = false

promptAmount.OnClientInvoke = function(value: string, min: number)
	local clone = ui.prompt:Clone()
	clone.Name = "prompt"
	clone.title.Text = "Open Crates"
	clone.amount.Visible = true
	clone.confirm.Size = UDim2.fromScale(0.32, 0.206)
	clone.deny.Size = UDim2.fromScale(0.32, 0.206)
	local count = 0
	local total = 0

	for _, v3 in DataController.InventoryReplicator:TryIndex({ "Inventory" }) do
		if v3.name ~= value or v3.sub.Favourited then
			continue
		end

		count += 1
		total += v3.sub.Stack or 1
	end

	local v3 = math.clamp(total, min, 1000)
	local v4

	if v2 then
		v4 = v3
	else
		v4 = min
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setQuestion(text2: number)
		local v5 = math.clamp(text2, 1, v4)
		clone.question.Text = string.format("Open x%d [%s]?", v5, value)
		return v5
	end

	local function updateOpenMode()
		if v2 then
			v4 = v3
			clone.openMode.Text = "Opening: All Unfavorited"
			clone.openMode.TextColor3 = Color3.fromRGB(255, 187, 103)
			clone.openMode.border.Color = Color3.fromRGB(255, 187, 103)
			clone.openMode.hover.ImageColor3 = Color3.fromRGB(255, 187, 103)
		else
			v4 = min
			clone.openMode.Text = "Opening: Held Only"
			clone.openMode.TextColor3 = Color3.fromRGB(111, 176, 255)
			clone.openMode.border.Color = Color3.fromRGB(111, 176, 255)
			clone.openMode.hover.ImageColor3 = Color3.fromRGB(111, 176, 255)
		end

		local text2 = tonumber(clone.amount.Text)

		if text2 and v4 < text2 then
			clone.amount.Text = tostring(v4)
		end
	end

	clone.openMode.Visible = count > 1
	clone.warning.Visible = count <= 1

	if count > 1 then
		updateOpenMode()
	end

	local v5 = string.lower(v) ~= string.lower(value) and 1 or math.min(text, v4)
	local amount = clone.amount
	local v6 = math.clamp(v5, 1, v4)
	clone.question.Text = string.format("Open x%d [%s]?", v6, value)
	amount.Text = tostring(v6)
	clone.Parent = localPlayer.PlayerGui:WaitForChild("over")
	Toggle(true)
	local v7 = nil
	clone.amount:GetPropertyChangedSignal("Text"):Connect(function()
		local text2 = tonumber(clone.amount.Text)

		if text2 and v4 < text2 then
			clone.amount.Text = tostring(v4)
		end

		clone.amount.Text = string.gsub(clone.amount.Text, "%D+", "")
		v5 = setQuestion(tonumber(clone.amount.Text) or 1)
	end)
	clone.confirm.MouseEnter:Connect(function()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, script, true)
	end)
	clone.deny.MouseEnter:Connect(function()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, script, true)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close(p)
		v7 = p
		clone:Destroy()
		Toggle(false)
	end

	clone.deny.Activated:Connect(function()
		close(false) -- equivalent call inferred; original call site unknown
	end)
	clone.openMode.Activated:Connect(function()
		v2 = not v2
		updateOpenMode()
	end)
	clone.confirm.Activated:Connect(function()
		local text2 = tonumber(clone.amount.Text)
		local v8 = math.clamp((not text2 or text2 < 1) and 1 or text2, 1, v4)
		v = value
		text = v8
		close(v8) -- equivalent call inferred; original call site unknown
	end)
	clone.openDetails.Visible = true
	clone.openDetails.Activated:Connect(function()
		ViewOddsController.ShowOdds("crate", value)
		close(false) -- equivalent call inferred; original call site unknown
	end)
	maid:Clean()
	maid:Add(InputController:Get("Gamepad").ButtonDown:Connect(function(p, p2)
		if not p2 and p == Enum.KeyCode.ButtonB then
			close(false) -- equivalent call inferred; original call site unknown
		end
	end))
	local lastTime = os.clock()

	repeat
		task.wait()
	until v7 ~= nil or not clone.Parent or os.clock() - lastTime > 30

	maid:Clean()
	return v7 == false and 0 or tonumber(v7) or 0, v2
end