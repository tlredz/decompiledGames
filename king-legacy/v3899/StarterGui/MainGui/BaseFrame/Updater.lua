local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local currentCamera = workspace.CurrentCamera

repeat
	task.wait(0.1)
until localPlayer:FindFirstChild("PlayerStats") and localPlayer:FindFirstChild("DataLoaded") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and currentCamera and currentCamera.ViewportSize.Magnitude > 0

local TweenService = game:GetService("TweenService")
local humanoid = localPlayer.Character:findFirstChild("Humanoid")
local exp = localPlayer:WaitForChild("PlayerStats"):WaitForChild("exp")
local expneed = localPlayer:WaitForChild("PlayerStats"):WaitForChild("expneed")
local x2ExpTime = localPlayer:WaitForChild("PlayerStats"):WaitForChild("X2ExpTime")
local playerStats = localPlayer.PlayerStats
local v = playerStats:waitForChild("beli")
local v2 = playerStats:waitForChild("lvl")
local v3 = playerStats:waitForChild("Gem")
local HAOHAKI = playerStats:WaitForChild("HAOHAKI")
local haogamepass = playerStats:WaitForChild("haogamepass")
local settings = playerStats:WaitForChild("Settings")
local parent = script.Parent
local parent2 = parent.Parent
local baseFrameOG = parent2:WaitForChild("BaseFrameOG")
local parent3 = script.Parent
local xboxZoom = parent2.StarterFrame.XboxZoom
local healthText = parent3.Frame.HealthFrame.HealthText
local expText = parent3.Frame.ExpFrame.ExpText
local lvl = parent3.Frame.Lvl
local moneyText = parent3.Frame.MoneyFrame.MoneyText
local gemText = parent3.Frame.GemFrame.GemText
local moneyButton = parent3.Frame.MoneyFrame.MoneyButton
local gemButton = parent3.Frame.GemFrame.GemButton
local healthButton = parent3.Frame.HealthFrame.HealthButton
local expButton = parent3.Frame.ExpFrame.ExpButton
local expBar = parent3.Frame.ExpFrame.ExpBar
local healthBar = parent3.Frame.HealthFrame.HealthBar
local armorBar = parent3.Frame.HealthFrame.ArmorBar
local underHealthBar = parent3.Frame.HealthFrame.UnderHealthBar
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local v4 = true
local flag = true
local v5 = "Exp "
local v6 = "Health "

function Format(p)
	return string.format("%02i", p)
end

local v7 = {}

function ConnectButton(data, p, data2)
	if not v7[p] then
		v7[p] = {}
	end

	for _, connection in pairs(v7[p]) do
		if connection then
			connection:Disconnect()
		end
	end

	if data2.Click then
		v7[p].Click = data.MouseButton1Click:Connect(data2.Click)
	end

	if data2.Enter then
		v7[p].Enter = data.MouseEnter:Connect(data2.Enter)
	end

	if data2.Leave then
		v7[p].Leave = data.MouseLeave:Connect(data2.Leave)
	end
end

local TextChatService = game:GetService("TextChatService")
local chatWindowConfiguration = TextChatService:FindFirstChild("ChatWindowConfiguration")

function UpdateSettings()
	local v8 = _G.CheckSettingClient(localPlayer, "Setting_RetroUI")

	if v8 then
		if chatWindowConfiguration then
			chatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
			chatWindowConfiguration.WidthScale = 0.7
		end

		parent.Visible = false
		baseFrameOG.Visible = true
		parent3 = baseFrameOG
	else
		if chatWindowConfiguration then
			chatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Top
			chatWindowConfiguration.WidthScale = 1
		end

		parent.Visible = true
		baseFrameOG.Visible = false
		parent3 = script.Parent
	end

	healthText = parent3.Frame.HealthFrame.HealthText
	expText = parent3.Frame.ExpFrame.ExpText
	lvl = parent3.Frame.Lvl
	moneyText = parent3.Frame.MoneyFrame.MoneyText
	gemText = parent3.Frame.GemFrame.GemText
	expBar = parent3.Frame.ExpFrame.ExpBar
	healthBar = parent3.Frame.HealthFrame.HealthBar
	armorBar = parent3.Frame.HealthFrame.ArmorBar
	underHealthBar = parent3.Frame.HealthFrame.UnderHealthBar
	moneyButton = parent3.Frame.MoneyFrame.MoneyButton
	gemButton = parent3.Frame.GemFrame.GemButton
	healthButton = parent3.Frame.HealthFrame.HealthButton
	expButton = parent3.Frame.ExpFrame.ExpButton
	ConnectButton(moneyButton, "MoneyButton", {
		Enter = function()
			if v then
				moneyText.Text = _G.Suffix_Comma(v.Value)
			end
		end,
		Leave = function()
			CheckBeli()
		end
	})
	ConnectButton(gemButton, "GemButton", {
		Enter = function()
			if v3 then
				gemText.Text = _G.Suffix_Comma(v3.Value)
			end
		end,
		Leave = function()
			CheckGem()
		end
	})
	ConnectButton(healthButton, "HealthButton", {
		Enter = function()
			if humanoid and humanoid.MaxHealth and humanoid.MaxHealth >= 1000000 then
				healthText.Text = v6 .. _G.Suffix_Comma(humanoid.Health) .. "/" .. _G.Suffix_Comma(humanoid.MaxHealth)
				v4 = nil
			end
		end,
		Leave = function()
			if humanoid and humanoid.MaxHealth and humanoid.MaxHealth >= 1000000 then
				healthText.Text = v6 .. _G.Suffix(humanoid.Health) .. "/" .. _G.Suffix(humanoid.MaxHealth)
				v4 = true
			end
		end
	})
	ConnectButton(expButton, "ExpButton", {
		Enter = function()
			if exp and expneed then
				expText.Text = v5 .. _G.Suffix_Comma(exp.Value) .. "/" .. _G.Suffix_Comma(expneed.Value)
			end

			flag = nil
			v4 = nil
		end,
		Leave = function()
			if exp and expneed then
				expText.Text = v5 .. _G.Suffix(exp.Value) .. "/" .. _G.Suffix(expneed.Value)
			end

			if x2ExpTime and x2ExpTime.Value > 0 then
				expText.Text ..= " (2x " .. tostring(ConvertToHMS(x2ExpTime.Value)) .. ")"
			end

			flag = true
			v4 = true
		end
	})
	CheckBar()
	CheckGem()
	CheckLvl()
	CheckBeli()
	UpdateImageBar()
	task.spawn(function()
		if not _G.UpdateFramePosY then
			repeat
				task.wait()
			until _G.UpdateFramePosY ~= nil
		end

		_G.UpdateFramePosY(v8)
	end)
end

settings.Changed:Connect(function()
	wait()
	UpdateSettings()
	task.spawn(function()
		if not _G.UpdateSettingButton then
			repeat
				task.wait()
			until _G.UpdateSettingButton ~= nil
		end

		_G.UpdateSettingButton()
	end)
end)

function ConvertToHMS(p)
	local v8 = math.floor(p / 60)
	local v9 = math.floor(v8 / 60)
	local v10 = v8 - v9 * 60
	local v11 = math.floor(v9 / 24)
	local v12 = v9 - v11 * 24
	return Format(v11) .. ":" .. Format(v12) .. ":" .. Format(v10) .. ":" .. Format(p % 60)
end

function UpdateImageBar()
	if HAOHAKI.Value == "HAOYOUHAVEIT" or haogamepass.Value == "HAOYOUHAVEIT" then
		baseFrameOG.Frame.MainBar.Image = "rbxassetid://132170540324252"
		baseFrameOG.Frame.Steering.Image.Image = "rbxassetid://124455149724702"
		parent.Frame.Steering.Image.Image = "rbxassetid://124455149724702"
	end
end

function CheckBar()
	local expBar2 = parent3.Frame.ExpFrame.ExpBar
	local expText2 = parent3.Frame.ExpFrame.ExpText
	local healthBar2 = parent3.Frame.HealthFrame.HealthBar
	local healthText2 = parent3.Frame.HealthFrame.HealthText

	if playerStats.Language.Value == "TH" then
		v5 = "ประสบการณ์ "
		v6 = "พลังชีวิต "
	else
		v5 = "Exp "
		v6 = "Health "
	end

	local v8 = math.min(exp.Value / expneed.Value, 1)

	if v8 >= 1 then
		expBar2.Size = UDim2.new(0, 0, 1, 0)
	end

	TweenService:Create(expBar2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
		Size = UDim2.new(v8 * 1, 0, 1, 0)
	}):Play()

	if flag then
		expText2.Text = v5 .. _G.Suffix(exp.Value) .. "/" .. _G.Suffix(expneed.Value)

		if x2ExpTime and x2ExpTime.Value > 0 then
			expText2.Text ..= " (2x " .. tostring(ConvertToHMS(x2ExpTime.Value)) .. ")"
		end
	else
		expText2.Text = v5 .. _G.Suffix_Comma(exp.Value) .. "/" .. _G.Suffix_Comma(expneed.Value)
	end

	local v9 = math.clamp(humanoid.Health / (humanoid.MaxHealth - 0), 0, 1)
	local v10 = math.floor(v9 * 100)
	local v11 = humanoid.MaxHealth - 0
	local v12 = math.min(humanoid.Health, v11)

	if v10 >= 100 then
		if v4 and humanoid.MaxHealth >= 1000000 then
			healthText2.Text = v6 .. _G.Suffix(v12) .. "/" .. _G.Suffix(v11)
		else
			healthText2.Text = v6 .. _G.Suffix_Comma(v12) .. "/" .. _G.Suffix_Comma(v11)
		end
	elseif v4 and humanoid.MaxHealth >= 1000000 then
		healthText2.Text = v6 .. _G.Suffix(v12) .. "/" .. _G.Suffix(v11) .. " [" .. tostring(v10) .. "%]"
	else
		healthText2.Text = v6 .. _G.Suffix_Comma(v12) .. "/" .. _G.Suffix_Comma(v11) .. " [" .. tostring(v10) .. "%]"
	end

	TweenService:Create(
		healthBar2,
		TweenInfo.new(0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = UDim2.new(v9 * 1, 0, 1, 0)
		}
	):Play()
	TweenService:Create(
		underHealthBar,
		TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0.1),
		{
			Size = UDim2.new(v9 * 1, 0, 1, 0)
		}
	):Play()
end

function TweenBeliAddIn(p)
	p.Position = UDim2.new(0.253, 0, 0.26, 0)
	TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.253, 0, -0.25, 0),
		Size = UDim2.new(2.247, 0, 0.9, 0)
	}):Play()
end

function TweenBeliAddOut(p)
	TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.253, 0, -0.5, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
end

function TweenExpAddIn(p)
	p.Position = UDim2.new(0.5, 0, 0.76, 0)
	TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.5, 0, -0.5, 0),
		Size = UDim2.new(0.75, 0, 0.3, 0)
	}):Play()
end

function TweenExpAddOut(p)
	TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
end

local belis = {}
local v8 = nil
local v9 = nil

local function ProcessQueueMoney()
	while #belis > 0 do
		v8 = true
		local v11 = table.remove(belis, 1)
		task.spawn(function()
			if v9 then
				v9:Pause()
				v9 = nil
			end

			moneyText.TextColor3 = Color3.fromRGB(255, 225, 0)
			moneyText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			v9 = TweenService:Create(
				moneyText,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
				}
			)
			v9:Play()
			local clone = script.beliadd:Clone()
			_G.PU:Dust(clone, 3)
			clone.TextColor3 = Color3.fromRGB(0, 255, 0)
			clone.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			clone.Text = "+" .. _G.Suffix_Comma(v11)
			clone.Parent = parent3.Frame.BeliFolder
			TweenBeliAddIn(clone)
			task.wait(0.3)
			TweenBeliAddOut(clone)
			task.wait(1)
			clone:Destroy()
		end)
		task.wait(0.35)
	end

	v8 = nil
end

local exps = {}
local v10 = nil

local function ProcessQueueExp()
	while #exps > 0 do
		v10 = true
		local v12 = table.remove(exps, 1)
		task.spawn(function()
			local clone = script.expadd:Clone()
			_G.PU:Dust(clone, 3)
			clone.Text = "+" .. _G.Suffix_Comma(v12) .. " Exp"
			clone.Parent = parent3.Frame.BeliFolder
			TweenExpAddIn(clone)
			task.wait(0.3)
			TweenExpAddOut(clone)
			task.wait(1)
			clone:Destroy()
		end)
		task.wait(0.35)
	end

	v10 = nil
end

function PositionToScreen(p)
	local cFrame = currentCamera.CFrame
	local _ = cFrame.Position
	local pointToObjectSpace = cFrame:PointToObjectSpace(p)
	local fieldOfView = math.rad(currentCamera.FieldOfView)
	local viewportSize = currentCamera.ViewportSize
	local v11 = viewportSize.X / viewportSize.Y
	local v12 = math.tan(fieldOfView / 2)
	local v13 = pointToObjectSpace.X / -pointToObjectSpace.Z / (v12 * v11)
	local v14 = pointToObjectSpace.Y / -pointToObjectSpace.Z / v12
	return Vector2.new((v13 + 1) * 0.5 * viewportSize.X, (1 - v14) * 0.5 * viewportSize.Y)
end

local v11 = {}
local v12 = {}
local flag2 = nil
local lastTime = os.clock()
local RunService = game:GetService("RunService")

function ProcessValue(p)
	if flag2 then
		return
	end

	flag2 = true
	local clone = ReplicatedStorage.Chest.Etc.ValuePart:Clone()
	clone.Position = p.CoinPos
	local gemValue = clone.GemValue
	local moneyValue = clone.MoneyValue
	local billboardGui = clone.BillboardGui
	local gemText2 = billboardGui.Background.GemText
	local moneyText2 = billboardGui.Background.MoneyText
	billboardGui.Enabled = nil
	clone.Parent = workspace.Effects
	local total = 0
	local total2 = 0
	gemValue.Value = total
	gemText2.Text = total
	moneyValue.Value = total2
	moneyText2.Text = total2
	local lastTime2 = os.clock()
	local lastTime3 = os.clock()

	while true do
		RunService.Heartbeat:Wait()
		local v13 = currentCamera.CFrame * CFrame.new(0, 0, -5)
		local character = localPlayer.Character

		if character and character.PrimaryPart then
			v13 = character.PrimaryPart.CFrame * CFrame.new(0, 0, -5)
		end

		local position = v13.Position
		local count = 0
		local parts = {}
		local v14 = {}

		if #v12 > 0 then
			for i = #v12, 1, -1 do
				local v15 = v12[i]
				local amt = v15.Amt
				local part = v15.Part
				local origin = v15.Origin
				local startedTime = v15.StartedTime
				local v16 = math.min((os.clock() - startedTime) / 0.25, 1)
				local v17 = position - origin
				local unit = v17.Unit
				local v18 = v17.Magnitude * v16
				count += 1
				parts[count] = part
				v14[count] = CFrame.new(origin, origin + unit) * CFrame.new(0, 0, -v18) * CFrame.new(
					math.sin(3.141592653589793 * v16) * v15.Curve,
					0,
					0
				)

				if not (v16 >= 1) then
					continue
				end

				lastTime2 = os.clock()
				part:Destroy()
				total2 += amt
				TweenService:Create(moneyValue, TweenInfo.new(0.2), {
					Value = total2
				}):Play()
				table.remove(v12, i)
				table.clear(v15)

				if os.clock() - lastTime3 > 0.03333333333333333 then
					lastTime3 = os.clock()
					local sound = PeoUtils.CreateSound({
						Name = "CollectSound",
						Volume = 0.5,
						SoundId = "rbxassetid://607665037"
					})
					sound.Parent = clone
					sound:Play()
					_G.PU:Dust(sound, 1)
				end

				billboardGui.Background.Size = UDim2.fromScale(1, 1)
				TweenService:Create(billboardGui.Background, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					Size = UDim2.fromScale(1.32, 1.32)
				}):Play()
				task.delay(0.125, function()
					TweenService:Create(billboardGui.Background, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
						Size = UDim2.fromScale(1, 1)
					}):Play()
				end)
			end
		end

		if #v11 > 0 then
			for i = #v11, 1, -1 do
				local v15 = v11[i]
				local amt = v15.Amt
				local part = v15.Part
				local origin = v15.Origin
				local startedTime = v15.StartedTime
				local v16 = math.min((os.clock() - startedTime) / 0.25, 1)
				local v17 = position - origin
				local unit = v17.Unit
				local v18 = v17.Magnitude * v16
				count += 1
				parts[count] = part
				v14[count] = CFrame.new(origin, origin + unit) * CFrame.new(0, 0, -v18) * CFrame.new(
					math.sin(3.141592653589793 * v16) * v15.Curve,
					0,
					0
				)

				if not (v16 >= 1) then
					continue
				end

				lastTime2 = os.clock()
				part:Destroy()
				total += amt
				TweenService:Create(gemValue, TweenInfo.new(0.2), {
					Value = total
				}):Play()
				table.remove(v11, i)
				table.clear(v15)

				if os.clock() - lastTime3 > 0.03333333333333333 then
					lastTime3 = os.clock()
					local sound = PeoUtils.CreateSound({
						Name = "CollectSound",
						Volume = 0.5,
						SoundId = "rbxassetid://607665037"
					})
					sound.Parent = clone
					sound:Play()
					_G.PU:Dust(sound, 1)
				end

				billboardGui.Background.Size = UDim2.fromScale(1, 1)
				TweenService:Create(billboardGui.Background, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					Size = UDim2.fromScale(1.32, 1.32)
				}):Play()
				task.delay(0.125, function()
					TweenService:Create(billboardGui.Background, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
						Size = UDim2.fromScale(1, 1)
					}):Play()
				end)
			end
		end

		workspace:BulkMoveTo(parts, v14, Enum.BulkMoveMode.FireCFrameChanged)

		if (total > 0 or total2 > 0) and not billboardGui.Enabled then
			billboardGui.Enabled = true
		end

		if total2 > 0 then
			billboardGui.Background.MoneyText.Visible = true
			billboardGui.Background.CoinImage.Visible = true
		end

		if total > 0 then
			billboardGui.Background.GemText.Visible = true
			billboardGui.Background.GemImage.Visible = true
		end

		moneyText2.Text = _G.Suffix(moneyValue.Value)
		gemText2.Text = _G.Suffix(gemValue.Value)
		clone.Position = position

		if not (os.clock() - lastTime > 1.25 and #v12 <= 0 and #v11 <= 0 and os.clock() - lastTime2 > 0.5) then
			continue
		end

		flag2 = nil

		if gemText2.Visible then
			TweenService:Create(billboardGui.Background.GemImage, TweenInfo.new(1), {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(gemText2, TweenInfo.new(1), {
				TextTransparency = 1
			}):Play()
			TweenService:Create(gemText2.UIStroke, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
		end

		TweenService:Create(billboardGui.Background.CoinImage, TweenInfo.new(1), {
			ImageTransparency = 1
		}):Play()
		TweenService:Create(moneyText2, TweenInfo.new(1), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(moneyText2.UIStroke, TweenInfo.new(1), {
			Transparency = 1
		}):Play()
		task.delay(1, function()
			clone:Destroy()
		end)
		break
	end
end

ReplicatedStorage.Chest.Remotes.Bindables.Popup.Event:Connect(function(p, data)
	if p == "Beli" then
		if data.CoinPos then
			local beli = data.Beli
			local coinPos = data.CoinPos

			local function SpawnMiniCoin(amt)
				local clone = ReplicatedStorage.Chest.Etc.MiniCoin:Clone()
				clone.Position = coinPos
				clone.Parent = workspace.Effects
				table.insert(v12, {
					Part = clone,
					Origin = coinPos,
					Amt = amt,
					Curve = math.random(-12, 12),
					StartedTime = os.clock()
				})
			end

			local function StartCoinTween(p2, max)
				local lastTime2 = os.clock()
				local total = 0
				local v13 = math.clamp(math.floor(beli / p2), 1, max)
				task.spawn(function()
					repeat
						task.wait(0.06666666666666667)
						local v14 = math.min((os.clock() - lastTime2) / v13, 1)
						local amt = beli * v14 - total

						if amt > 0 then
							SpawnMiniCoin(amt)
							total += amt
						end
					until v14 >= 1
				end)
			end

			if beli >= 100000 then
				local lastTime2 = os.clock()
				local total = 0
				local v13 = math.clamp(math.floor(beli / 100000), 1, 10)
				task.spawn(function()
					repeat
						task.wait(0.06666666666666667)
						local v14 = math.min((os.clock() - lastTime2) / v13, 1)
						local amt = beli * v14 - total

						if amt > 0 then
							SpawnMiniCoin(amt)
							total += amt
						end
					until v14 >= 1
				end)
			elseif beli >= 10000 then
				local lastTime2 = os.clock()
				local total = 0
				local v13 = math.clamp(math.floor(beli / 10000), 1, 5)
				task.spawn(function()
					repeat
						task.wait(0.06666666666666667)
						local v14 = math.min((os.clock() - lastTime2) / v13, 1)
						local amt = beli * v14 - total

						if amt > 0 then
							SpawnMiniCoin(amt)
							total += amt
						end
					until v14 >= 1
				end)
			elseif beli >= 1000 then
				local lastTime2 = os.clock()
				local total = 0
				local v13 = math.clamp(math.floor(beli / 1000), 1, 2)
				task.spawn(function()
					repeat
						task.wait(0.06666666666666667)
						local v14 = math.min((os.clock() - lastTime2) / v13, 1)
						local amt = beli * v14 - total

						if amt > 0 then
							SpawnMiniCoin(amt)
							total += amt
						end
					until v14 >= 1
				end)
			else
				SpawnMiniCoin(beli)
			end

			lastTime = os.clock()
			ProcessValue(data)
		else
			table.insert(belis, data.Beli)

			if not v8 then
				ProcessQueueMoney(data)
			end
		end
	elseif p == "Exp" then
		table.insert(exps, data.Exp)

		if not v10 then
			ProcessQueueExp(data)
		end
	elseif p == "Gem" then
		if not data.CoinPos then
			return
		end

		local gem = data.Gem
		local coinPos = data.CoinPos

		local function SpawnMiniGem(amt)
			local clone = ReplicatedStorage.Chest.Etc.MiniGem:Clone()
			clone.Position = coinPos
			clone.Parent = workspace.Effects
			table.insert(v11, {
				Part = clone,
				Origin = coinPos,
				Amt = amt,
				Curve = math.random(-12, 12),
				StartedTime = os.clock()
			})
		end

		local function StartGemween(p2, max)
			local lastTime2 = os.clock()
			local total = 0
			local v13 = math.clamp(math.floor(gem / p2), 1, max)
			task.spawn(function()
				repeat
					task.wait(0.06666666666666667)
					local v14 = math.min((os.clock() - lastTime2) / v13, 1)
					local amt = gem * v14 - total

					if amt > 0 then
						SpawnMiniGem(amt)
						total += amt
					end
				until v14 >= 1
			end)
		end

		if gem >= 20 then
			local lastTime2 = os.clock()
			local total = 0
			local v13 = math.clamp(math.floor(gem / 20), 1, 10)
			task.spawn(function()
				repeat
					task.wait(0.06666666666666667)
					local v14 = math.min((os.clock() - lastTime2) / v13, 1)
					local amt = gem * v14 - total

					if amt > 0 then
						SpawnMiniGem(amt)
						total += amt
					end
				until v14 >= 1
			end)
		elseif gem >= 10 then
			local lastTime2 = os.clock()
			local total = 0
			local v13 = math.clamp(math.floor(gem / 10), 1, 5)
			task.spawn(function()
				repeat
					task.wait(0.06666666666666667)
					local v14 = math.min((os.clock() - lastTime2) / v13, 1)
					local amt = gem * v14 - total

					if amt > 0 then
						SpawnMiniGem(amt)
						total += amt
					end
				until v14 >= 1
			end)
		elseif gem >= 5 then
			local lastTime2 = os.clock()
			local total = 0
			local v13 = math.clamp(math.floor(gem / 5), 1, 2)
			task.spawn(function()
				repeat
					task.wait(0.06666666666666667)
					local v14 = math.min((os.clock() - lastTime2) / v13, 1)
					local amt = gem * v14 - total

					if amt > 0 then
						SpawnMiniGem(amt)
						total += amt
					end
				until v14 >= 1
			end)
		else
			SpawnMiniGem(gem)
		end

		lastTime = os.clock()
		ProcessValue(data)
	end
end)

function UpdateBeliText()
	if v.Value >= 1000000000 then
		moneyText.Text = _G.Suffix(v.Value)
	else
		moneyText.Text = _G.Suffix_Comma(v.Value)
	end
end

function CheckBeli()
	local moneyText2 = parent3.Frame.MoneyFrame.MoneyText

	if v.Value >= 1000000000 then
		moneyText2.Text = _G.Suffix(v.Value)
	else
		moneyText2.Text = _G.Suffix_Comma(v.Value)
	end
end

function CheckGem()
	local gemText2 = parent3.Frame.GemFrame.GemText

	if v3.Value >= 1000000 then
		gemText2.Text = _G.Suffix(v3.Value)
	else
		gemText2.Text = _G.Suffix_Comma(v3.Value)
	end
end

local v13 = nil

function CheckLvl()
	local lvl2 = parent3.Frame.Lvl

	if lvl2.Text == tostring(playerStats.lvl.Value) then
		return
	end

	task.spawn(function()
		if v13 then
			v13:Pause()
			v13 = nil
		end

		lvl2.TextColor3 = Color3.fromRGB(255, 255, 0)
		lvl2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		v13 = TweenService:Create(
			lvl2,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			}
		)
		v13:Play()
	end)
	lvl2.Text = playerStats.lvl.Value

	if playerStats.lvl.Value >= _G.LevelMaxClient then
		parent3.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
		baseFrameOG.Frame.Lvl.TextColor3 = Color3.fromRGB(255, 255, 0)
	end

	if playerStats.lvl.Value >= 2250 and playerStats.SecondSeaProgression.Value == "No" then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Go Talk To Traveler")
	elseif playerStats.lvl.Value >= 4000 and not _G.CheckAwakeClient(localPlayer, "ThirdSea") and (game.PlaceId == WorldsId.KingLegacy.SecondSea or game.PlaceId == WorldsId.Testing.SecondSea) then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Go Talk To Seaman")
	end
end

function UpdateHealthColor()
	local character = localPlayer.Character

	if not character then
		return
	end

	local iFrame = character:GetAttribute("IFrame")
	local color = Color3.fromRGB(0, 200, 0)

	if iFrame then
		color = Color3.fromRGB(255, 255, 255)
	end

	healthBar.BackgroundColor3 = color
end

localPlayer.CharacterAdded:Connect(function(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.HealthChanged:Connect(function()
		CheckBar()
	end)
	character:GetAttributeChangedSignal("ArmorHealth"):Connect(function()
		CheckBar()
	end)
	character:GetAttributeChangedSignal("IFrame"):Connect(function()
		UpdateHealthColor()
	end)
	CheckBar()
end)
HAOHAKI.Changed:Connect(function()
	UpdateImageBar()
end)
haogamepass.Changed:Connect(function()
	UpdateImageBar()
end)
exp.Changed:Connect(function()
	wait()
	CheckBar()
end)
expneed.Changed:Connect(function()
	wait()
	CheckBar()
end)
v.Changed:Connect(function()
	CheckBeli()
end)
v2.Changed:Connect(function()
	CheckLvl()
end)
x2ExpTime.Changed:Connect(function()
	wait()
	CheckBar()
end)

if humanoid then
	humanoid.HealthChanged:Connect(function()
		CheckBar()
	end)
end

if localPlayer.Character then
	localPlayer.Character:GetAttributeChangedSignal("ArmorHealth"):Connect(function()
		CheckBar()
	end)
	localPlayer.Character:GetAttributeChangedSignal("IFrame"):Connect(function()
		UpdateHealthColor()
	end)
end

v3.Changed:Connect(function()
	wait()
	CheckGem()
end)
wait(0.5)
_G.IsXbox = false

function ChangeButtonIcon(p)
	local character = localPlayer.Character
	local skillCooldown = localPlayer.PlayerGui.SkillCooldown
	local sWFrame = skillCooldown.SWFrame
	local fSFrame = skillCooldown.FSFrame
	local dFFrame = skillCooldown.DFFrame

	if p == "Xbox" then
		if character then
			character:SetAttribute("Device", "Xbox")
		end

		_G.IsXbox = true
		xboxZoom.Visible = true
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Gamepad",
			Overlay = true,
			Message = "Xbox Controller Activated!",
			Color = Color3.fromRGB(58, 255, 81)
		})
		sWFrame.Z.Text.Visible = nil
		sWFrame.Z.ControllerIcon.Xbox.Visible = true
		sWFrame.X.Text.Visible = nil
		sWFrame.X.ControllerIcon.Xbox.Visible = true
		fSFrame.Z.Text.Visible = nil
		fSFrame.Z.ControllerIcon.Xbox.Visible = true
		fSFrame.X.Text.Visible = nil
		fSFrame.X.ControllerIcon.Xbox.Visible = true
		fSFrame.C.Text.Visible = nil
		fSFrame.C.ControllerIcon.Xbox.Visible = true
		fSFrame.V.Text.Visible = nil
		fSFrame.V.ControllerIcon.Xbox.Visible = true
		fSFrame.E.Text.Visible = nil
		fSFrame.E.ControllerIcon.Xbox.Visible = true
		dFFrame.Z.Text.Visible = nil
		dFFrame.Z.ControllerIcon.Xbox.Visible = true
		dFFrame.X.Text.Visible = nil
		dFFrame.X.ControllerIcon.Xbox.Visible = true
		dFFrame.C.Text.Visible = nil
		dFFrame.C.ControllerIcon.Xbox.Visible = true
		dFFrame.V.Text.Visible = nil
		dFFrame.V.ControllerIcon.Xbox.Visible = true
		dFFrame.E.Text.Visible = nil
		dFFrame.E.ControllerIcon.Xbox.Visible = true
		dFFrame.B.Text.Visible = nil
		dFFrame.B.ControllerIcon.Xbox.Visible = true
	elseif p == "PlayStation" then
		if character then
			character:SetAttribute("Device", "PlayStation")
		end

		_G.IsXbox = true
		xboxZoom.Visible = true
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Gamepad",
			Overlay = true,
			Message = "PlayStation Controller Activated!",
			Color = Color3.fromRGB(58, 255, 81)
		})
		sWFrame.Z.Text.Visible = nil
		sWFrame.Z.ControllerIcon.PS5.Visible = true
		sWFrame.X.Text.Visible = nil
		sWFrame.X.ControllerIcon.PS5.Visible = true
		fSFrame.Z.Text.Visible = nil
		fSFrame.Z.ControllerIcon.PS5.Visible = true
		fSFrame.X.Text.Visible = nil
		fSFrame.X.ControllerIcon.PS5.Visible = true
		fSFrame.C.Text.Visible = nil
		fSFrame.C.ControllerIcon.PS5.Visible = true
		fSFrame.V.Text.Visible = nil
		fSFrame.V.ControllerIcon.PS5.Visible = true
		fSFrame.E.Text.Visible = nil
		fSFrame.E.ControllerIcon.PS5.Visible = true
		dFFrame.Z.Text.Visible = nil
		dFFrame.Z.ControllerIcon.PS5.Visible = true
		dFFrame.X.Text.Visible = nil
		dFFrame.X.ControllerIcon.PS5.Visible = true
		dFFrame.C.Text.Visible = nil
		dFFrame.C.ControllerIcon.PS5.Visible = true
		dFFrame.V.Text.Visible = nil
		dFFrame.V.ControllerIcon.PS5.Visible = true
		dFFrame.E.Text.Visible = nil
		dFFrame.E.ControllerIcon.PS5.Visible = true
		dFFrame.B.Text.Visible = nil
		dFFrame.B.ControllerIcon.PS5.Visible = true
	else
		_G.IsXbox = false
		xboxZoom.Visible = false

		for _, guiObject in pairs(skillCooldown:GetDescendants()) do
			if guiObject:IsA("TextLabel") and guiObject.Name == "Text" then
				guiObject.Visible = true
			elseif guiObject:IsA("ImageLabel") and (guiObject.Name == "Xbox" or guiObject.Name == "PS5") then
				guiObject.Visible = nil
			end
		end
	end
end

ChangeButtonIcon()
local _ = {
	gamepadTypeFromNewestInput = "none",
	inputTypeThePlayerIsUsing = "KeyboardAndMouse",
	gamepadType = "none"
}
local _ = {
	"ButtonA",
	"ButtonB",
	"ButtonX",
	"ButtonY",
	"ButtonLB",
	"ButtonLT",
	"ButtonLS",
	"ButtonRB",
	"ButtonRT",
	"ButtonRS",
	"ButtonStart",
	"ButtonSelect"
}
local v14 = {
	"ButtonCross",
	"ButtonCircle",
	"ButtonSquare",
	"ButtonTriangle",
	"ButtonL1",
	"ButtonL2",
	"ButtonL3",
	"ButtonR1",
	"ButtonR2",
	"ButtonR3",
	"ButtonOptions",
	"ButtonTouchpad",
	"ButtonShare"
}
local UserInputService2 = game:GetService("UserInputService")

function UpdateGamepadType()
	local v15 = "Xbox"

	for _, v16 in pairs(UserInputService2:GetGamepadState(Enum.UserInputType.Gamepad1)) do
		local stringForKeyCode = UserInputService2:GetStringForKeyCode(v16.KeyCode)

		for _, v17 in pairs(v14) do
			if v17 == stringForKeyCode then
				v15 = "PlayStation"
			end
		end
	end

	ChangeButtonIcon(v15)
end

function SetupBaseFrame()
	local v15 = 0
	local v16 = 60
	local v17 = -4
	local viewportSize = currentCamera.ViewportSize
	local v18 = math.min(viewportSize.X, viewportSize.Y)

	if v18 >= 1000 then
		v16 = 70
		v17 = -11
	elseif v18 >= 710 then
		v17 = -5
	end

	if UserInputService.TouchEnabled then
		_G.IsMobile = true

		if v18 >= 550 then
			_G.ExtendMobileGUI = 1
			v16 = 60
			v17 = 0
		else
			_G.ExtendMobileGUI = 1.25
			v16 = 50
			v17 = 8
		end

		v15 = -10
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdatePos()
		parent.Position = UDim2.new(0.5, 0, 1, -(v16 + v17) - parent.AbsoluteSize.Y / 2 - 0)
		parent.ButtonFrame.Position = UDim2.new(0.5, 0, -0.1, v15)
	end

	parent.Position = UDim2.new(0.5, 0, 1, -(v16 + v17) - parent.AbsoluteSize.Y / 2 - 0)
	parent.ButtonFrame.Position = UDim2.new(0.5, 0, -0.1, v15)
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		wait()
		UpdatePos() -- equivalent call inferred; original call site unknown
	end)
	local backpack = localPlayer.PlayerGui:FindFirstChild("Backpack")

	if backpack then
		backpack.Enabled = true
	end

	_G.VisibleGui(true)
end

_G.SetupBaseFrame = SetupBaseFrame

if UserInputService2.GamepadEnabled then
	localPlayer.CameraMinZoomDistance = 20
	localPlayer.CameraMaxZoomDistance = 20
	UpdateGamepadType()
else
	localPlayer.CameraMinZoomDistance = 0.5
	localPlayer.CameraMaxZoomDistance = 200
end

UserInputService2.GamepadConnected:Connect(function()
	wait()
	UpdateGamepadType()
end)
UserInputService2.GamepadDisconnected:Connect(function()
	localPlayer.CameraMinZoomDistance = 0.5
	localPlayer.CameraMaxZoomDistance = 200
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
		Name = "Gamepad",
		Overlay = true,
		Message = "Controller Disconnected!",
		Color = Color3.fromRGB(255, 57, 57)
	})
	ChangeButtonIcon()
end)
local step = 20
local flag3 = nil
xboxZoom.XboxZoomIn.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true
	xboxZoom.XboxZoomIn.Size = UDim2.new(1, 0, 0.40625, 0)
	TweenService:Create(
		xboxZoom.XboxZoomIn,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(1, 0, 0.5249999999999999, 0)
		}
	):Play()
	_G.ClickFrameEffect({
		Sound = true
	})
	step -= 20

	if step <= 20 then
		step = 20
	end

	_G.UpdateCameraMaxZoom({
		Step = step,
		Type = "Xbox"
	})
	task.delay(0.03, function()
		flag3 = nil
	end)
end)
xboxZoom.XboxZoomIn.MouseEnter:Connect(function()
	xboxZoom.XboxZoomIn.Size = UDim2.new(1, 0, 0.325, 0)
	TweenService:Create(xboxZoom.XboxZoomIn, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1, 0, 0.4375, 0)
	}):Play()
end)
xboxZoom.XboxZoomIn.MouseLeave:Connect(function()
	TweenService:Create(xboxZoom.XboxZoomIn, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1, 0, 0.35, 0)
	}):Play()
end)
xboxZoom.XboxZoomOut.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true
	xboxZoom.XboxZoomOut.Size = UDim2.new(1, 0, 0.40625, 0)
	TweenService:Create(
		xboxZoom.XboxZoomOut,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(1, 0, 0.5249999999999999, 0)
		}
	):Play()
	_G.ClickFrameEffect({
		Sound = true
	})
	step += 20

	if step >= 180 then
		step = 180
	end

	_G.UpdateCameraMaxZoom({
		Step = step,
		Type = "Xbox"
	})
	task.delay(0.03, function()
		flag3 = nil
	end)
end)
xboxZoom.XboxZoomOut.MouseEnter:Connect(function()
	xboxZoom.XboxZoomOut.Size = UDim2.new(1, 0, 0.325, 0)
	TweenService:Create(xboxZoom.XboxZoomOut, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1, 0, 0.4375, 0)
	}):Play()
end)
xboxZoom.XboxZoomOut.MouseLeave:Connect(function()
	TweenService:Create(xboxZoom.XboxZoomOut, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1, 0, 0.35, 0)
	}):Play()
end)
UpdateSettings()
SetupBaseFrame()