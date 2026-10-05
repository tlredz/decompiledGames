local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("ContextActionService")
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local v5 = require3(script.Parent.TradeRequestController)
local v6 = require3(ReplicatedStorage2.ServerInfo)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Common.Utils)
local color = Color3.fromRGB(255, 50, 50)
local color2 = Color3.fromRGB(255, 255, 255)
local remoteFunction = v3:RemoteFunction("SetPINCode")
v3:RemoteEvent("CancelSetPINCode")
local remoteEvent = v3:RemoteEvent("UpdatePINResetWarn")
local localPlayer = Players.LocalPlayer
local tradeRequest = localPlayer.PlayerGui:WaitForChild("TradeRequest")
local tradeSetPIN = localPlayer.PlayerGui:WaitForChild("TradeSetPIN")
local tradePINRecovery = localPlayer.PlayerGui:WaitForChild("TradePINRecovery")
local tradeSettings = tradeRequest.Main.Views.TradeSettings
local main = tradeSetPIN.Main
local pin = main.Pin
local buttons = main.Buttons
local visible = v.TouchEnabled and not v.KeyboardEnabled
local main2 = tradePINRecovery.Main
local state = v4.State()
local v10 = {}
local v11 = {}

for _, image in pin.Label.Boxes:GetChildren() do
	if not image:IsA("ImageLabel") then
		continue
	end

	local v12 = assert(image:FindFirstChildWhichIsA("TextBox"), "TextBox not found!")
	v10[assert(tonumber(image.Name), "Invalid TextBox name!")] = v12
end

for _, image in main2.Main.Label.Boxes:GetChildren() do
	if not image:IsA("ImageLabel") then
		continue
	end

	local v12 = assert(image:FindFirstChildWhichIsA("TextBox"), "TextBox not found!")
	v11[assert(tonumber(image.Name), "Invalid TextBox name!")] = v12
end

local TradePINCodeController = {}

function TradePINCodeController:_getPINCode()
	local v12 = ""
	local flag = false

	for _, v13 in v10 do
		if string.len(v13.Text) > 1 or not tonumber(v13.Text) then
			v13.PlaceholderColor3 = color
			v13.Text = ""
			flag = true
		else
			v12 ..= v13.Text
		end
	end

	if flag then
		return nil
	end

	return v12
end

function TradePINCodeController:_clearPINBoxes()
	for _, v12 in v10 do
		v12.Text = ""
		v12.PlaceholderColor3 = color2
	end
end

function TradePINCodeController:_clearRecoveryBoxes()
	for _, v12 in v11 do
		v12.Text = ""
		v12.PlaceholderColor3 = color2
	end
end

function TradePINCodeController:_setupPINBox(instance, currentTextBoxIndex)
	local nextSelectionRight = v10[currentTextBoxIndex + 1]
	instance.NextSelectionRight = nextSelectionRight
	instance.NextSelectionLeft = v10[currentTextBoxIndex - 1]
	instance.Focused:Connect(function()
		local v13 = state:Get()

		if v13 ~= "SetPIN" and v13 ~= "CheckPIN" then
			return
		end

		if instance.PlaceholderColor3 == color then
			instance.PlaceholderColor3 = color2
		end

		self._currentTextBoxIndex = currentTextBoxIndex
	end)
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		local text = instance.Text
		local text2 = string.match(text, "^%d?")

		if text2 == nil or text2 == "" then
			instance.Text = ""
			return
		end

		instance.Text = text2

		if nextSelectionRight and not visible then
			nextSelectionRight:CaptureFocus()
		end
	end)
end

function TradePINCodeController:_setupRecoveryBox(instance, currentTextBoxIndex)
	instance.NextSelectionRight = v11[currentTextBoxIndex + 1]
	instance.NextSelectionLeft = v11[currentTextBoxIndex - 1]
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		if state:Get() ~= "ResetPIN" then
			return
		end

		instance.Text = v8.String.RemoveWhitespace(instance.Text)
	end)
	instance.Focused:Connect(function()
		local v12 = state:Get()

		if v12 ~= "SaveRecoveryPhrase" and v12 ~= "ResetPIN" then
			return
		end

		self._currentTextBoxIndex = currentTextBoxIndex
	end)
end

function TradePINCodeController:_getRecoveryWords()
	local texts = {}
	local flag = false

	for _, v12 in v11 do
		if v12.Text == "" then
			v12.PlaceholderColor3 = color
			flag = true
		else
			table.insert(texts, v12.Text)
		end
	end

	if flag then
		return nil
	end

	return texts
end

function TradePINCodeController:ShowRecoveryPhrase(p)
	if state:Get() == "SaveRecoveryPhrase" then
		return
	end

	state:Set("SaveRecoveryPhrase")
	main2.Visible = true
	tradePINRecovery.SuccesfullyChanged.Visible = false

	for k, v12 in v11 do
		v12.TextEditable = false
		v12.Text = `{k}. {p[k] or "???"}`
	end
end

function TradePINCodeController:TryResetPINWithPhrase()
	if self._isBeingUsed or state:Get() == "SaveRecoveryPhrase" then
		return
	end

	self._isBeingUsed = true
	state:Set("ResetPIN")
	main2.Visible = true
	tradePINRecovery.SuccesfullyChanged.Visible = false

	for k, v12 in v11 do
		v12.TextEditable = true
		v12.Text = ""
		v12.PlaceholderText = `{k}.`
	end
end

function TradePINCodeController:TryResetPINWithPIN()
	if self._isBeingUsed or state:Get() == "SaveRecoveryPhrase" then
		return
	end

	self._isBeingUsed = true
	self:_clearPINBoxes()
	state:Set("PINRecovery")
	main2.Visible = false
	tradePINRecovery.SuccesfullyChanged.Visible = false
end

function TradePINCodeController:Start()
	local v12 = v2.Client:WaitReplion("Inventory")

	if not v12 then
		return
	end

	for k, v13 in v10 do
		self:_setupPINBox(v13, k)
	end

	for k, v13 in v11 do
		self:_setupRecoveryBox(v13, k)
	end

	local tradingPin = tradeSettings.ScrollingFrame.TradingPin
	local replionPathState = v4.getReplionPathState(v12, "TradePINCode")
	v4.Computed(function(callback)
		local visible2 = callback(replionPathState) ~= nil
		tradingPin.Info.Enabled.Visible = visible2
		tradingPin.Info.Disabled.Visible = not visible2
		tradingPin.Info.SetPin.Visible = not visible2
		tradingPin.Info.ResetPin.Visible = visible2
		return nil
	end)
	v4.Computed(function(callback)
		local v13 = callback(state)
		main.TriesLeft.Visible = v13 == "CheckPIN"
		tradePINRecovery.Enabled = v13 == "SaveRecoveryPhrase" or v13 == "ResetPIN" or v13 == "PinOrPhrase"
		tradeSetPIN.Enabled = v13 == "SetPIN" or v13 == "CheckPIN" or v13 == "PINRecovery"
		tradeSetPIN.Main.Label.Text = v13 == "CheckPIN" and "Enter your 4-digit PIN" or v13 == "PINRecovery" and "Enter your 4-digit PIN to reset your PIN" or "Set a 4-Digit Trading PIN that must be entered to trade when you join the game."
		main2.ResetText.Visible = v13 == "ResetPIN"
		main2.RetriesLeft.Visible = v13 == "ResetPIN"
		main2.Close.Visible = v13 == "ResetPIN"
		main2.Buttons.Cancel.Visible = v13 == "ResetPIN"
		main2.Check.Visible = v13 == "SaveRecoveryPhrase"
		main2.SafetyWarn.Visible = v13 == "SaveRecoveryPhrase"
		main2.Main.Label.DoNotShare.Visible = v13 == "SaveRecoveryPhrase"
		main2.Label1.Visible = v13 == "SaveRecoveryPhrase"
		tradePINRecovery.PinOrPhrase.Visible = v13 == "PinOrPhrase"

		if v13 == nil then
			self._isBeingUsed = nil
		end

		return nil
	end)
	tradingPin.Info.SetPin.Activated:Connect(function()
		if self._isBeingUsed then
			ReplicatedStorage2.Misc.error:Play()
		elseif replionPathState:Get() == nil then
			self._isBeingUsed = true
			state:Set("SetPIN")
		else
			ReplicatedStorage2.Misc.error:Play()

			if _G.SendNotification then
				_G.SendNotification("You already have a pin, if you've forgotten it, you should reset it.")
			end
		end
	end)
	tradePINRecovery.PinOrPhrase.Close.Activated:Connect(function()
		if state:Get() ~= "PinOrPhrase" then
			return
		end

		state:Set(nil)
	end)
	tradePINRecovery.PinOrPhrase.Buttons.ResetWithPin.Activated:Connect(function()
		self:TryResetPINWithPIN()
	end)
	tradePINRecovery.PinOrPhrase.Buttons.ResetWithRecoveryPhrase.Activated:Connect(function()
		self:TryResetPINWithPhrase()
	end)
	tradingPin.Info.ResetPin.Activated:Connect(function()
		if self._isBeingUsed then
			return
		end

		main2.Visible = false
		state:Set("PinOrPhrase")
	end)
	local state2 = v4.State(false)
	main2.Check.Checkbox.Activated:Connect(function()
		if state:Get() ~= "SaveRecoveryPhrase" then
			return
		end

		state2:Set(not state2:Get())
	end)
	v4.setPropertyState(main2.Check.Checkbox.ToggleImage, "Visible", state2)
	main2.Buttons.Confirm.Activated:Connect(function()
		local v13 = state:Get()

		if v13 == "SaveRecoveryPhrase" then
			if not state2:Get() then
				ReplicatedStorage2.Misc.error:Play()
				return
			end

			state:Set(nil)
			state2:Set(false)

			if v7:IsOpen("TradeRequest") then
				v5.CurrentTab:Set("TradeSettings")
			end
		elseif v13 == "ResetPIN" then
			local _getRecoveryWords = self:_getRecoveryWords()

			if not _getRecoveryWords then
				ReplicatedStorage2.Misc.error:Play()
				return
			end

			local v14, v15 = v3:Invoke("ResetPINCode", {
				option = "Phrase",
				value = _getRecoveryWords
			})

			if v14 then
				main2.Visible = false
				tradePINRecovery.SuccesfullyChanged.Visible = true
			else
				ReplicatedStorage2.Misc.error:Play()

				if _G.SendNotification and v15 then
					_G.SendNotification(v15)
				end
			end
		end
	end)

	local function cancelRecovery()
		if state:Get() == "SaveRecoveryPhrase" then
			return
		end

		self._isBeingUsed = nil
		state:Set(nil)
		self:_clearRecoveryBoxes()
	end

	main2.Buttons.Cancel.Activated:Connect(cancelRecovery)
	main2.Close.Activated:Connect(cancelRecovery)
	tradePINRecovery.SuccesfullyChanged.Confirm.Activated:Connect(cancelRecovery)
	tradePINRecovery.SuccesfullyChanged.Close.Activated:Connect(cancelRecovery)
	local replionPathState2 = v4.getReplionPathState(v12, "PINResetRetries")
	v4.Computed(function(callback)
		local v13 = callback(replionPathState2)
		main2.RetriesLeft.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">You have<font color="rgb(255, 58, 58)"> ({v13}) </font>attempts remaining today </stroke>`
		return nil
	end)
	local replionPathState3 = v4.getReplionPathState(v12, "PINCheckRetries")
	v4.Computed(function(callback)
		local v13 = callback(replionPathState3)
		main.TriesLeft.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">You have<font color="rgb(255, 58, 58)"> ({v13}) </font>attempts remaining today </stroke>`
		return nil
	end)
	buttons.Confirm.Activated:Connect(function()
		local _getPINCode = self:_getPINCode()

		if not _getPINCode then
			ReplicatedStorage2.Misc.error:Play()
		elseif state:Get() == "CheckPIN" then
			local v13, v14 = v3:Invoke("RespondPINCheck", _getPINCode)
			state:Set(nil)
			self:_clearPINBoxes()

			if not v13 then
				ReplicatedStorage2.Misc.error:Play()

				if _G.SendNotification and v14 then
					_G.SendNotification(v14)
				end
			end
		elseif state:Get() == "SetPIN" then
			local v13 = self._confirmationStep ~= nil

			if v13 then
				if self._confirmationStep then
					if self._confirmationStep.pinCode == _getPINCode then
						local v14, v15 = remoteFunction:InvokeServer(_getPINCode, true)

						if v14 then
							if type(v15) == "table" then
								self:ShowRecoveryPhrase(v15)
							end

							if _G.SendNotification then
								_G.SendNotification("Your PIN has been successfully set!")
							end

							self._confirmationStep = nil
							self:_clearPINBoxes()
						else
							ReplicatedStorage2.Misc.error:Play()

							if _G.SendNotification and v15 then
								_G.SendNotification(v15)
							end

							return false
						end
					else
						ReplicatedStorage2.Misc.error:Play()

						if _G.SendNotification then
							_G.SendNotification("The PINs are not the same!")
						end
					end
				end
			else
				local v14, v15 = remoteFunction:InvokeServer(_getPINCode, v13)

				if v14 then
					self._confirmationStep = {
						pinCode = _getPINCode
					}
					main.Label.Text = "Enter your 4-digit trading PIN again"
					self:_clearPINBoxes()
				else
					ReplicatedStorage2.Misc.error:Play()

					if _G.SendNotification and v15 then
						_G.SendNotification(v15)
					end

					return false
				end
			end
		elseif state:Get() == "PINRecovery" then
			local v13, v14 = v3:Invoke("ResetPINCode", {
				option = "PIN",
				value = _getPINCode
			})

			if v13 then
				self:_clearPINBoxes()
				state:Set(nil)
			else
				ReplicatedStorage2.Misc.error:Play()

				if _G.SendNotification and v14 then
					_G.SendNotification(v14)
				end
			end
		end
	end)

	local function cancelSetPin()
		local v13 = state:Get()

		if v13 == "SaveRecoveryPhrase" then
			return
		end

		if self._isBeingUsed and v13 == "CheckPIN" then
			task.spawn(v3.Invoke, v3, "RespondPINCheck", nil)
		end

		self._isBeingUsed = nil
		self._confirmationStep = nil
		self._currentTextBoxIndex = nil
		main.Label.Text = "Set a 4-Digit Trading PIN that must be entered to trade when you join the game."
		self:_clearPINBoxes()
		state:Set(nil)

		if v7:IsOpen("TradeRequest") then
			v5.CurrentTab:Set("TradeSettings")
		end
	end

	buttons.Cancel.Activated:Connect(cancelSetPin)
	main.Close.Activated:Connect(cancelSetPin)
	v.InputBegan:Connect(function(input, gameProcessed: boolean?)
		if not (gameProcessed and self._currentTextBoxIndex and (tradeSetPIN.Enabled or tradePINRecovery.Enabled)) then
			return
		end

		local focusedTextBox = v:GetFocusedTextBox()
		local v13 = state:Get()
		local v14

		if v13 == "SaveRecoveryPhrase" or v13 == "ResetPIN" then
			v14 = v11
		else
			v14 = v10
		end

		if not table.find(v14, focusedTextBox) then
			return
		end

		local v15 = nil

		if input.KeyCode == Enum.KeyCode.Backspace and focusedTextBox.Text == "" then
			v15 = v14[self._currentTextBoxIndex - 1]
		elseif input.KeyCode == Enum.KeyCode.Tab then
			v15 = v14[self._currentTextBoxIndex + 1]
		end

		if v15 and not visible then
			v15:CaptureFocus()
		end
	end)
	local mobileTextBox = pin.Label.MobileTextBox

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDevice()
		visible = v.TouchEnabled and not v.KeyboardEnabled
		mobileTextBox.Visible = visible

		for _, v13 in v10 do
			v13.Selectable = not visible
			v13.Active = not visible
			v13.TextEditable = not visible
		end
	end

	v.LastInputTypeChanged:Connect(updateDevice)
	mobileTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = mobileTextBox.Text:gsub("%D", ""):sub(1, 4)
		mobileTextBox.Text = text

		for k, v14 in v10 do
			v14.Text = text:sub(k, k)
		end
	end)
	updateDevice() -- equivalent call inferred; original call site unknown
	v3:Connect("RequestPINCheck", function(p)
		if state:Get() == "SaveRecoveryPhrase" then
			task.spawn(v3.Invoke, v3, "RespondPINCheck", nil)
			return
		end

		if type(p) == "boolean" and p == false and self._isBeingUsed then
			cancelSetPin()
			return
		end

		self._isBeingUsed = true
		state:Set("CheckPIN")
	end)
	local v13

	if v6.isTradingPlazaServer() and v12:Get("PINWarnTradePlaza") == true then
		v7:Open("TradeRequest", true)
		v7:Lock("TradePINWarning", true)
		tradeRequest.Main.TradePINResetWarn.Visible = true
		v13 = true
	else
		v13 = nil
	end

	tradeRequest.Main.TradePINResetWarn.Close.Activated:Connect(function()
		v7:Unlock("TradePINWarning")
		tradeRequest.Main.TradePINResetWarn.Visible = false
		remoteEvent:FireServer(v13)
		v13 = false
	end)
	tradeRequest.Main.TradePINResetWarn.Buttons.Yes.Activated:Connect(function()
		v7:Unlock("TradePINWarning")
		tradeRequest.Main.TradePINResetWarn.Visible = false
		remoteEvent:FireServer(v13)
		v13 = false
	end)
	v7:OnGuiOpen("TradeRequest", function()
		local pINResetWarnsLeft = v12:Get("PINResetWarnsLeft")
		local tradePINCode = v12:Get("TradePINCode")

		if pINResetWarnsLeft and not (pINResetWarnsLeft <= 0 or tradePINCode) then
			tradeRequest.Main.TradePINResetWarn.Visible = true
		end
	end)
end

return TradePINCodeController