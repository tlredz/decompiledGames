local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("AvatarEditorService")
local HttpService = game:GetService("HttpService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
require(replicatedStorage.Modules.Icon)
require(replicatedStorage.Modules.BloodyZee)
_G.Settings = {}
_G.LocalSettings = {}
_G.SettingUpdate = {}
local controller = Knit.CreateController({
	Name = "SettingsController"
})

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local settings = menus.Group.Settings
	settings:SetAttribute("Loaded", true)
	localPlayer:WaitForChild("leaderstats")
	local gamepasses = localPlayer:WaitForChild("Gamepasses")
	local mouse = localPlayer:GetMouse()

	local function createSetting(moduleScript, child)
		local module = require(moduleScript)
		local clone = menus.Preset.Option:Clone()
		clone.Option.Text = moduleScript.Name
		clone.Name = moduleScript.Name
		clone.Description.Text = module.Desc
		clone.Parent = child
		clone.LayoutOrder = module.SortOrder
		local settings2 = _G.Settings

		if module.Val == nil then
			settings2 = _G.LocalSettings

			if not settings2[moduleScript.Name] then
				settings2[moduleScript.Name] = false
			end
		end

		local bindableEvent = Instance.new("BindableEvent")
		_G.SettingUpdate[module.Val or moduleScript.Name] = bindableEvent
		bindableEvent.Event:Connect(function()
			local setting = settings2[module.Val or moduleScript.Name]

			if setting == true then
				clone.Toggle.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
				clone.Toggle.Side.BackgroundColor3 = Color3.fromRGB(169, 255, 189)
				clone.Toggle.Side.Position = UDim2.new(0, 0, 0, 0)
			elseif setting == false then
				clone.Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				clone.Toggle.Side.BackgroundColor3 = Color3.fromRGB(85, 0, 0)
				clone.Toggle.Side.Position = UDim2.new(0.5, 0, 0, 0)
			end

			if module.Callback then
				module.Callback(setting)
			end
		end)
		clone.Toggle.Side.MouseButton1Down:Connect(function()
			local setting = settings2[module.Val or moduleScript.Name]

			if module.Val == nil then
				_G.LocalSettings[moduleScript.Name] = not setting
				bindableEvent:Fire()
			else
				v.Setting:Fire(module.Val, not setting)
			end

			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			v4:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
		end)

		if module.Val == nil then
			bindableEvent:Fire()
		end

		return clone
	end

	local function createIdSetting(moduleScript, child)
		local module = require(moduleScript)
		local clone = menus.Preset.OptionString:Clone()
		clone.Option.Text = moduleScript.Name
		clone.Name = moduleScript.Name
		clone.Description.Text = module.Desc
		clone.Parent = child
		clone.LayoutOrder = module.SortOrder
		local bindableEvent = Instance.new("BindableEvent")
		_G.SettingUpdate[module.Val] = bindableEvent
		bindableEvent.Event:Connect(function()
			local setting = _G.Settings[module.Val]
			clone.TextBox.Text = setting or ""
		end)
		clone.TextBox.FocusLost:Connect(function()
			local text = clone.TextBox.Text

			if not tonumber(text) and text ~= "" then
				clone.TextBox.Text = "Invalid ID"
				return
			end

			if tonumber(text) then
				text = tonumber(text)
			end

			v.Setting:Fire(module.Val, text)
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		end)

		if module.Gamepass then
			clone.Visible = gamepasses:GetAttribute(module.Gamepass)

			if clone.Visible == false then
				local connection = nil
				connection = gamepasses:GetAttributeChangedSignal(module.Gamepass):Connect(function()
					if gamepasses:GetAttribute(module.Gamepass) ~= true then
						return
					end

					connection:Disconnect()
					clone.Visible = true
				end)
			end
		end
	end

	local function createVolSetting(moduleScript, child)
		local module = require(moduleScript)
		local clone = menus.Preset.OptionValue:Clone()
		clone.Option.Text = moduleScript.Name
		clone.Name = moduleScript.Name
		clone.Description.Text = module.Desc
		clone.TextBox.PlaceholderText = module.Max or 2
		clone.Parent = child
		clone.LayoutOrder = module.SortOrder
		local bindableEvent = Instance.new("BindableEvent")
		_G.SettingUpdate[module.Val] = bindableEvent
		bindableEvent.Event:Connect(function()
			local text = _G.Settings[module.Val] or 1
			clone.TextBox.Text = text

			if module.Callback then
				module.Callback(text)
			end

			clone.Bar.BarClip.Size = UDim2.new(text / module.Max, 0, 1, 0)
			clone.Bar.BarClip.Bar.Size = UDim2.new(text > 0 and 1 / (text / module.Max) or 0, 0, 1, 0)
		end)
		clone.TextBox.FocusLost:Connect(function()
			local text = tonumber(clone.TextBox.Text)
			local v5 = not text and 1 or not math.isnan(text) and math.clamp(text, 0, module.Max) or 1
			v.Setting:Fire(module.Val, (tonumber(v5)))
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		end)
		clone.Bar.MouseButton1Down:Connect(function()
			local steppedConnection = RunService.Stepped:Connect(function()
				local absolutePosition = clone.Bar.AbsolutePosition
				local absoluteSize = clone.Bar.AbsoluteSize
				local X = absolutePosition.X
				local v5 = absolutePosition.X + absoluteSize.X
				local text = math.floor(math.clamp((mouse.X - X) / (v5 - X), 0, 1) * module.Max * 10) / 10
				clone.TextBox.Text = text
				local max = module.Max
				clone.Bar.BarClip.Size = UDim2.new(text / max, 0, 1, 0)
				clone.Bar.BarClip.Bar.Size = UDim2.new(not (text > 0) and 0 or 1 / (text / max) or 0, 0, 1, 0)

				if module.Callback then
					module.Callback(text)
				end
			end)
			local inputEndedConnection = nil
			inputEndedConnection = clone.Bar.InputEnded:Connect(function()
				inputEndedConnection:Disconnect()
				steppedConnection:Disconnect()
				v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				local absolutePosition = clone.Bar.AbsolutePosition
				local absoluteSize = clone.Bar.AbsoluteSize
				local X = absolutePosition.X
				local v5 = absolutePosition.X + absoluteSize.X
				local text = math.floor(math.clamp((mouse.X - X) / (v5 - X), 0, 1) * module.Max * 10) / 10
				clone.TextBox.Text = text
				local max = module.Max
				clone.Bar.BarClip.Size = UDim2.new(text / max, 0, 1, 0)
				clone.Bar.BarClip.Bar.Size = UDim2.new(not (text > 0) and 0 or 1 / (text / max) or 0, 0, 1, 0)
				v.Setting:Fire(module.Val, text)
			end)
		end)
	end

	local function createButtonSetting(moduleScript, child)
		local module = require(moduleScript)
		local clone = menus.Preset.OptionButton:Clone()
		clone.Option.Text = moduleScript.Name
		clone.Name = moduleScript.Name
		clone.TextButton.Text = module.BtnText or moduleScript.Name
		clone.Description.Text = module.Desc
		clone.Parent = child
		clone.LayoutOrder = module.SortOrder
		clone.TextButton.MouseButton1Down:Connect(function()
			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if module.Callback then
				module.Callback()
			end
		end)

		if module.Gamepass then
			clone.Visible = gamepasses:GetAttribute(module.Gamepass)

			if clone.Visible == false then
				local connection = nil
				connection = gamepasses:GetAttributeChangedSignal(module.Gamepass):Connect(function()
					if gamepasses:GetAttribute(module.Gamepass) ~= true then
						return
					end

					connection:Disconnect()
					clone.Visible = true
				end)
			end
		end
	end

	for _, button in settings.Settings.Categories:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v5 = button
		button.MouseButton1Down:Connect(function()
			for i, button2 in settings.Settings.Categories:GetChildren() do
				if button2:IsA("TextButton") then
					button2.Select.Visible = button2 == v5
				end
			end

			v4:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			for i, child in settings.Settings.Items:GetChildren() do
				child.Visible = child.Name == v5.Name
			end
		end)
	end

	for _, child in replicatedStorage.Modules.Settings:GetChildren() do
		local child2 = settings.Settings.Items:FindFirstChild(child.Name)

		for _, moduleScript in child:GetChildren() do
			local module = require(moduleScript)

			if module.Btn == 1 then
				createSetting(moduleScript, child2)
			elseif module.Btn == 2 then
				createIdSetting(moduleScript, child2)
			elseif module.Btn == 3 then
				createVolSetting(moduleScript, child2)
			elseif module.Btn == 4 then
				createButtonSetting(moduleScript, child2)
			end
		end
	end

	replicatedStorage.Remotes.ForceFun.OnClientEvent:Connect(function(p, _)
		_G.LocalSettings[p] = true
		_G.SettingUpdate[p]:Fire()
	end)
	local v5 = false
	local clone = nil
	RunService.RenderStepped:Connect(function()
		local Y = workspace.CurrentCamera.CFrame.Y

		if v5 == false then
			if Y > 15000 then
				v5 = true
				v2.Give:Fire("Space Shenanigans")
				clone = utils.Misc.Space:Clone()
				clone.Position = workspace.CurrentCamera.CFrame.Position
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(1), {
					Transparency = 0
				}):Play()
				TweenService:Create(clone.Earth, TweenInfo.new(1), {
					Transparency = 0
				}):Play()
				TweenService:Create(clone.Earth.Atmo, TweenInfo.new(1), {
					Transparency = 0
				}):Play()
			end
		elseif v5 == true and Y < 15000 then
			v5 = false
			TweenService:Create(clone, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Earth, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Earth.Atmo, TweenInfo.new(1), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 1)
			clone = nil
		end

		if clone then
			local v6 = (Y - 15000) / 20000
			clone.Position = workspace.CurrentCamera.CFrame.Position
			clone.Earth.Position = clone.Position - Vector3.new(0, math.clamp(v6 * 150, 0, 150) + 250, 0)
		end
	end)
	v2.Give:Connect(function()
		if _G.LocalSettings.Gravity and _G.LocalSettings.Invert then
			v2.Give:Fire("Betavision", true)
		end
	end)
	v.Setting:Connect(function(p, ...)
		local v6 = nil

		if p == "Batch" then
			local v7 = ({ ... })[1]
			local EncodingService = game:GetService("EncodingService")
			local decompressBuffer = EncodingService:DecompressBuffer(v7, Enum.CompressionAlgorithm.Zstd)
			v6 = HttpService:JSONDecode(buffer.tostring(decompressBuffer))
		elseif p == "Single" then
			v6 = {}
			v6[({ ... })[1]] = ({ ... })[2]
		end

		for k, v7 in v6 do
			_G.Settings[k] = v7

			if _G.SettingUpdate[k] then
				_G.SettingUpdate[k]:Fire()
			end
		end

		if v6.Keybinds then
			local v7 = {
				K = "Keyboard",
				G = "Gamepad"
			}

			for childName, keybind in v6.Keybinds do
				local child = replicatedStorage.Keybind:FindFirstChild(childName, true)

				if not child then
					continue
				end

				for k, v8 in keybind do
					if not child:FindFirstChild(v7[k]) then
						continue
					end

					child[v7[k]].KeyCode = Enum.KeyCode[v8[1]]

					if v8[2] then
						child[v7[k]].PrimaryModifier = Enum.KeyCode[v8[2]]
					end
				end
			end
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("JoinService")
	v2 = Knit.GetService("AchievementService")
	v3 = Knit.GetController("ToolController")
	v4 = Knit.GetController("FXController")
end

return controller