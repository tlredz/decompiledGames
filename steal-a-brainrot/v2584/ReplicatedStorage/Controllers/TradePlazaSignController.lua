local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local NotificationController = require(controllers.NotificationController)
local SoundController = require(controllers.SoundController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local Net = require(ReplicatedStorage.Packages.Net)
local TradingFlags = require(ReplicatedStorage.Shared.Flags.TradingFlags)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remoteFunction = Net:RemoteFunction("TradePlazaSignService/SetText")
local v = {}

local function truncateUtf8(value: string, p: number)
	local v2 = utf8.len(value)

	if not v2 then
		return ""
	end

	if v2 <= p then
		return value
	end

	local v3 = utf8.offset(value, p + 1)

	if v3 then
		return (string.sub(value, 1, v3 - 1))
	end

	return value
end

local function normalizeText(value: string)
	local v2 = string.gsub(value, "[\r\n]", "")
	local v3 = TradingFlags.TradePlazaSignMaxLength:Get()
	local v4 = utf8.len(v2)

	if not v4 then
		return ""
	end

	if v4 <= v3 then
		return v2
	end

	local v5 = utf8.offset(v2, v3 + 1)

	if v5 then
		return (string.sub(v2, 1, v5 - 1))
	end

	return v2
end

return {
	Start = function(_)
		local tradePlazaSignEdit = playerGui:WaitForChild("TradePlazaSignEdit", 30)

		if not (tradePlazaSignEdit and tradePlazaSignEdit:IsA("ScreenGui")) then
			warn("[TradePlazaSignController] PlayerGui.TradePlazaSignEdit not found")
			return
		end

		local tradePlazaSignEdit2 = tradePlazaSignEdit:WaitForChild("TradePlazaSignEdit")
		local main = tradePlazaSignEdit2.Main
		local header = main.Header
		local textBox = main.Decoration.Frame.TextBox
		local v2 = main.Decoration.Function
		local yes = main.Buttons.Yes
		local cancel = main.Buttons.Cancel
		local toolsFrames = playerGui:WaitForChild("ToolsFrames", 30)
		local editSign = toolsFrames and toolsFrames:WaitForChild("EditSign", 30)

		if not (editSign and editSign:IsA("GuiObject")) then
			warn("[TradePlazaSignController] PlayerGui.ToolsFrames.EditSign not found")
			return
		end

		local guiButton

		if editSign:IsA("GuiButton") then
			guiButton = editSign
		else
			guiButton = editSign:FindFirstChildWhichIsA("GuiButton", true)
		end

		if not guiButton then
			warn("[TradePlazaSignController] ToolsFrames.EditSign has no GuiButton")
			return
		end

		editSign.Visible = false
		local v3 = InterfaceController:Register("TradePlazaSignEdit", tradePlazaSignEdit2, "TopQuint")
		v3:AttachCloseButton(header.Close)
		v3:AttachCloseButton(cancel)
		v3:Close()
		local v4 = nil
		local v5 = false
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCharCount()
			local v6 = TradingFlags.TradePlazaSignMaxLength:Get()
			v2.Text = `{utf8.len(textBox.Text) or 0}/{v6}`
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setText(text: string)
			if textBox.Text ~= text then
				flag = true
				textBox.Text = text
			end

			updateCharCount() -- equivalent call inferred; original call site unknown
		end

		local function openEditor(instance)
			if TradingFlags.TradePlazaSignsDisabled:Get() then
				return
			end

			v4 = instance
			local text = instance:GetAttribute("Text")
			setText(typeof(text) ~= "string" and "" or text) -- equivalent call inferred; original call site unknown
			InterfaceController:SetState("TradePlazaSignEdit", true)
			task.defer(function()
				textBox:CaptureFocus()
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setActiveTool(p, flag2: boolean)
			if flag2 then
				v4 = p
			elseif v4 == p then
				v4 = nil
			end

			editSign.Visible = v4 ~= nil and not TradingFlags.TradePlazaSignsDisabled:Get()
		end

		local function bindSignTool(tool)
			if v[tool] or tool:GetAttribute("TradePlazaSign") ~= true then
				return
			end

			v[tool] = true

			local function update()
				local parent = tool.Parent
				setActiveTool(tool, parent ~= nil and parent:IsA("Model")) -- equivalent call inferred; original call site unknown
			end

			tool:GetPropertyChangedSignal("Parent"):Connect(update)
			tool.Destroying:Once(function()
				v[tool] = nil
				setActiveTool(tool, false) -- equivalent call inferred; original call site unknown
			end)
			local parent = tool.Parent
			local v6

			if parent == nil then
				v6 = false
			else
				v6 = parent:IsA("Model")
			end

			setActiveTool(tool, v6) -- equivalent call inferred; original call site unknown
		end

		local function watchContainer(instance)
			for _, tool in ipairs(instance:GetChildren()) do
				if tool:IsA("Tool") then
					bindSignTool(tool)
				end
			end

			instance.ChildAdded:Connect(function(tool)
				if tool:IsA("Tool") then
					bindSignTool(tool)
				end
			end)
		end

		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if flag then
				flag = false
				updateCharCount() -- equivalent call inferred; original call site unknown
			else
				local text = textBox.Text
				local text2 = string.gsub(text, "[\r\n]", "")
				local v7 = TradingFlags.TradePlazaSignMaxLength:Get()
				local v8 = utf8.len(text2)

				if v8 then
					if not (v8 <= v7) then
						local v9 = utf8.offset(text2, v7 + 1)

						if v9 then
							text2 = string.sub(text2, 1, v9 - 1)
						end
					end
				else
					text2 = ""
				end

				if text2 ~= textBox.Text and textBox.Text ~= text2 then
					flag = true
					textBox.Text = text2
				end

				updateCharCount() -- equivalent call inferred; original call site unknown
			end
		end)
		local v6 = TradingFlags.TradePlazaSignMaxLength:Get()
		v2.Text = `{utf8.len(textBox.Text) or 0}/{v6}`
		local v7 = AnimatedButton.new(yes)
		v7:Animate()
		v7.OnActivated:Connect(function()
			if v5 or TradingFlags.TradePlazaSignsDisabled:Get() then
				return
			end

			v5 = true
			SoundController:PlaySound("Sounds.Sfx.Activated")
			local success, result, v8, text = pcall(function()
				return remoteFunction:InvokeServer(textBox.Text)
			end)
			v5 = false

			if success then
				if not result then
					NotificationController:Error(typeof(v8) ~= "string" and "Failed to update sign" or v8)
					return
				end

				if v4 and typeof(text) == "string" then
					v4:SetAttribute("Text", text)
					setText(text) -- equivalent call inferred; original call site unknown
				end

				InterfaceController:SetState("TradePlazaSignEdit", false)
			else
				warn("[TradePlazaSignController] failed to set sign text", result)
				NotificationController:Error("Failed to update sign")
			end
		end)
		local v8 = AnimatedButton.new(guiButton)
		v8:Animate()
		v8.OnActivated:Connect(function()
			local v9 = v4

			if not v9 then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")
			openEditor(v9)
		end)
		TradingFlags.TradePlazaSignsDisabled.Changed:Connect(function(flag2: boolean)
			editSign.Visible = v4 ~= nil and not flag2

			if flag2 then
				InterfaceController:SetState("TradePlazaSignEdit", false)
			end
		end)
		watchContainer(localPlayer:WaitForChild("Backpack"))
		localPlayer.CharacterAdded:Connect(function(character)
			watchContainer(character)
		end)

		if localPlayer.Character then
			watchContainer(localPlayer.Character)
		end
	end
}