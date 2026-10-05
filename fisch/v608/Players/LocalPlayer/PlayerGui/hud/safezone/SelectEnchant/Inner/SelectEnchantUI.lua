local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.fx)
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
local spearEnchants = require(ReplicatedStorage.shared.modules.library.spears.spearEnchants)
local harpoonEnchants = require(ReplicatedStorage.shared.modules.library.harpoonGuns.harpoonEnchants)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local PlayerController = require(ReplicatedStorage.client.legacyControllers.PlayerController)
local remoteFunction = Net:RemoteFunction("Enchant/SelectEnchant")
Players.LocalPlayer:WaitForChild("PlayerGui")
Lighting:WaitForChild("uiblur")
Lighting:WaitForChild("uicc")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function wrapIndex(p: number, p2: number)
	return (p - 1) % p2 + 1
end

local function getAppearance(p: number)
	local v = math.abs(p)

	if v >= 2 then
		return {
			textTransp = 1,
			descTransp = 1,
			scale = 0.7
		}
	end

	if v >= 1 then
		return {
			textTransp = 0.5,
			descTransp = 0.8,
			scale = 0.8
		}
	end

	return {
		textTransp = 0,
		descTransp = 0,
		scale = 1
	}
end

remoteFunction.OnClientInvoke = function(list)
	if not list or #list == 0 then
		return nil
	end

	local hud = HudController:GetHud()
	local safeZone = HudController:GetSafeZone()
	local backpackGui = HudController:GetBackpackGui()
	local selectEnchant = safeZone:WaitForChild("SelectEnchant")
	local inner = selectEnchant:WaitForChild("Inner")

	if selectEnchant.Visible then
		return nil
	end

	local enchantAreaDisplay = inner:WaitForChild("enchantAreaDisplay")
	local enchantTemplate = enchantAreaDisplay:WaitForChild("EnchantTemplate")
	local up = inner:WaitForChild("up")
	local down = inner:WaitForChild("down")
	local confirm = inner:WaitForChild("confirm")
	local cancel = inner:WaitForChild("cancel")
	local desc = inner:WaitForChild("desc")
	local bgFlare = inner:WaitForChild("bgFlare")
	local bgFlare2 = inner:WaitForChild("bgFlare2")
	local overlay = selectEnchant:WaitForChild("overlay")
	table.sort(list)
	enchantTemplate.Visible = false
	local v = {}
	local v2 = 1
	local flag = false
	local connections = {}
	local v3 = nil

	for i = 1, 5 do
		local clone = enchantTemplate:Clone()
		clone.Visible = true
		clone.Parent = enchantAreaDisplay
		table.insert(v, {
			frame = clone,
			offset = i - 3
		})
	end

	local function setContent(frame, p: number)
		local v4 = #list
		local text = list[(p - 1) % v4 + 1]
		local v7 = enchants.Enchants[text] or spearEnchants.Enchants[text] or harpoonEnchants.Enchants[text]
		local label = frame:FindFirstChild("label")
		local desc2 = frame:FindFirstChild("desc")

		if label then
			label.Text = text

			if v7 then
				label.TextColor3 = v7.Color
				local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

				if uIStroke then
					uIStroke.Color = v7.StrokeColor
				end
			end
		end

		if desc2 then
			desc2.Text = v7 and v7.Description or ""
		end
	end

	local function setVisuals(frame, p: number)
		local appearance = getAppearance(p)
		local v4 = p * 0.3333333333333333 + 0.5
		frame.Position = UDim2.fromScale(0.5, v4)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		local label = frame:FindFirstChild("label")
		local desc2 = frame:FindFirstChild("desc")
		local uIScale = frame:FindFirstChild("UIScale")

		if label then
			label.TextTransparency = appearance.textTransp
			local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Transparency = appearance.textTransp
			end
		end

		if desc2 then
			desc2.TextTransparency = appearance.descTransp
			local uIStroke = desc2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Transparency = appearance.descTransp
			end
		end

		if uIScale then
			uIScale.Scale = appearance.scale
		end
	end

	local function tweenVisuals(frame, offset: number)
		local appearance = getAppearance(offset)
		local v4 = offset * 0.3333333333333333 + 0.5
		TweenService:Create(frame, tweenInfo, {
			Position = UDim2.fromScale(0.5, v4)
		}):Play()
		local label = frame:FindFirstChild("label")
		local desc2 = frame:FindFirstChild("desc")
		local uIScale = frame:FindFirstChild("UIScale")

		if label then
			TweenService:Create(label, tweenInfo, {
				TextTransparency = appearance.textTransp
			}):Play()
			local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, tweenInfo, {
					Transparency = appearance.textTransp
				}):Play()
			end
		end

		if desc2 then
			TweenService:Create(desc2, tweenInfo, {
				TextTransparency = appearance.descTransp
			}):Play()
			local uIStroke = desc2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, tweenInfo, {
					Transparency = appearance.descTransp
				}):Play()
			end
		end

		if uIScale then
			TweenService:Create(uIScale, tweenInfo, {
				Scale = appearance.scale
			}):Play()
		end
	end

	for _, v4 in v do
		setContent(v4.frame, v2 + v4.offset)
		setVisuals(v4.frame, v4.offset)
	end

	local function scroll(p: number)
		if flag or #list <= 1 then
			return
		end

		flag = true
		local v4 = v2 + p
		local v5 = #list
		v2 = (v4 - 1) % v5 + 1
		local v6 = nil

		for _, v8 in v do
			if not (math.abs(v8.offset - p) > 2) then
				continue
			end

			v6 = v8
			break
		end

		if v6 then
			local offset = p > 0 and 2 or -2
			v6.offset = offset
			setContent(v6.frame, v2 + offset)
			setVisuals(v6.frame, offset)
		end

		for _, v8 in v do
			if v8 ~= v6 then
				v8.offset -= p
			end

			tweenVisuals(v8.frame, v8.offset)
		end

		local v8 = list[v2]
		local v9 = enchants.Enchants[v8] or spearEnchants.Enchants[v8] or harpoonEnchants.Enchants[v8]

		if v9 and typeof(v9.Color) == "Color3" then
			TweenService:Create(bgFlare, tweenInfo, {
				ImageColor3 = v9.Color
			}):Play()
			TweenService:Create(bgFlare2, tweenInfo, {
				ImageColor3 = v9.Color
			}):Play()
			TweenService:Create(overlay, tweenInfo, {
				ImageColor3 = v9.Color
			}):Play()
		end

		task.delay(0.2, function()
			flag = false
		end)
	end

	local v4 = list[v2]
	local v5 = enchants.Enchants[v4] or spearEnchants.Enchants[v4] or harpoonEnchants.Enchants[v4]

	if v5 and typeof(v5.Color) == "Color3" then
		bgFlare.ImageColor3 = v5.Color
		bgFlare2.ImageColor3 = v5.Color
		overlay.ImageColor3 = v5.Color
	end

	desc.Text = "Shape this relic's unbound energy into the enchantment of your choosing."
	selectEnchant.Visible = true
	backpackGui.Enabled = false
	PlayerController:ToggleControls(false)
	script.openSound:Play()
	table.insert(connections, up.MouseButton1Click:Connect(function()
		scroll(-1)
	end))
	table.insert(connections, down.MouseButton1Click:Connect(function()
		scroll(1)
	end))
	table.insert(connections, confirm.MouseButton1Click:Connect(function()
		local v7 = v2
		local v8 = #list
		v3 = list[(v7 - 1) % v8 + 1]
	end))
	table.insert(connections, cancel.MouseButton1Click:Connect(function()
		selectEnchant.Visible = false
	end))
	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonR1 then
			scroll(1)
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
			scroll(-1)
		end
	end))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			scroll(input.Position.Z > 0 and -1 or 1)
		end
	end))
	table.insert(connections, RunService.RenderStepped:Connect(function(dt)
		bgFlare2.Rotation += dt * 20
	end))

	repeat
		task.wait()
	until v3 ~= nil or not (selectEnchant.Visible and hud.Enabled)

	if v3 then
		script.boomSound:Play()
		script.enchantsfx:Play()
	end

	selectEnchant.Visible = false
	backpackGui.Enabled = true
	PlayerController:ToggleControls(true)

	for _, connection in connections do
		connection:Disconnect()
	end

	for _, v6 in v do
		v6.frame:Destroy()
	end

	return v3
end