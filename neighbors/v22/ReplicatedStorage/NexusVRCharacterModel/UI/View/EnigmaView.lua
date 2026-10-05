local createVector = vector.create
local v = {
	["1"] = true,
	["2"] = true
}
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent.Parent
local Enigma = require(parent:WaitForChild("Packages"):WaitForChild("Enigma"))
local NexusButton = require(parent:WaitForChild("Packages"):WaitForChild("NexusButton"))
local CharacterService = require(parent:WaitForChild("State"):WaitForChild("CharacterService"))
local instance = CharacterService.GetInstance()
local EnigmaService = require(parent:WaitForChild("State"):WaitForChild("EnigmaService"))
local instance2 = EnigmaService.GetInstance()
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance3 = Settings.GetInstance()
require(parent:WaitForChild("UI"):WaitForChild("View"):WaitForChild("ApiBaseView"))
local default = NexusButton.TextButtonFactory.CreateDefault(Color3.fromRGB(0, 170, 255))
default:SetDefault("Theme", "RoundedCorners")
local EnigmaView = {}
EnigmaView.__index = EnigmaView

local function AddColor(p: string, p2: number, p3: number, p4: number)
	return (`<font color="rgb({p2},{p3},{p4})">{p}</font>`)
end

function EnigmaView.new(object, object2)
	object:AddBackground()
	local container = object:GetContainer()
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0.9, 0, 0.6, 0)
	textLabel.Position = UDim2.new(0.05, 0, 0.075, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = ""
	textLabel.RichText = true
	textLabel.TextWrapped = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextSize = 28
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Parent = container
	local object3 = setmetatable({
		EnigmaText = textLabel
	}, EnigmaView)

	if instance3:GetSetting("Extra.EnigmaEnabled") == false then
		textLabel.Text = "This game has disabled Enigma."
		return object3
	end

	local showTrackersButton, v3 = default:Create()
	showTrackersButton.Size = UDim2.new(0.5, 0, 0.075, 0)
	showTrackersButton.Position = UDim2.new(0.25, 0, 0.775, 0)
	showTrackersButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	showTrackersButton.Parent = container
	v3.Text = " Show Trackers "
	object3.ShowTrackersButton = showTrackersButton
	object3.DebugTrackersVisible = false
	local v4 = true
	showTrackersButton.MouseButton1Down:Connect(function()
		if not v4 then
			return
		end

		v4 = false
		object3.DebugTrackersVisible = not object3.DebugTrackersVisible

		if object3.DebugTrackersVisible then
			task.spawn(function()
				object3:ShowDebugTrackers()
			end)
		end

		v3.Text = object3.DebugTrackersVisible and " Hide Trackers" or " Show Trackers "
		task.wait()
		v4 = true
	end)
	local calibrateButton, v6 = default:Create()
	calibrateButton.Size = UDim2.new(0.5, 0, 0.075, 0)
	calibrateButton.Position = UDim2.new(0.25, 0, 0.875, 0)
	calibrateButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	calibrateButton.Parent = container
	v6.Text = " Calibrate Trackers "
	object3.CalibrateButton = calibrateButton
	calibrateButton.MouseButton1Down:Connect(function()
		if not v4 then
			return
		end

		v4 = false
		local character = instance:GetCharacter(Players.LocalPlayer)

		if character then
			instance2:Calibrate(character)
		end

		task.wait()
		v4 = true
	end)
	object3:UpdateText()
	task.spawn(function()
		while true do
			object3:UpdateText()
			task.wait(0.1)
		end
	end)
	task.spawn(function()
		local v7 = {
			LeftFoot = false,
			RightFoot = false
		}

		while true do
			local v8 = {}
			local flag = true

			for k, v9 in v7 do
				if v9 then
					continue
				end

				if not v9 then
					flag = false
				end

				if not Enigma.Enabled or not Enigma:GetUserCFrameEnabled(k) or instance2.Offsets[k] then
					continue
				end

				table.insert(v8, k)
			end

			for _, v9 in v8 do
				v7[v9] = true
			end

			if #v8 > 0 then
				object2:UpdateVisibleView(object.Name)
				object2:Toggle(true)
				object3:UpdateText()
			end

			if flag then
				break
			else
				task.wait()
			end
		end
	end)
	return object3
end

function EnigmaView:UpdateText()
	local v2 = ""
	local userCFrameEnabled = Enigma.Enabled and Enigma:GetUserCFrameEnabled("LeftFoot")
	local userCFrameEnabled2 = Enigma.Enabled and Enigma:GetUserCFrameEnabled("RightFoot")
	local v3

	if userCFrameEnabled then
		if instance2.Offsets.LeftFoot then
			v3 = `{v2}Left Foot Tracker: {`<font color="rgb({0},{200},{0})">Active</font>`}`
		else
			v3 = `{v2}Left Foot Tracker: {`<font color="rgb({200},{150},{0})">Requires Calibration</font>`}`
		end
	else
		v3 = `{v2}Left Foot Tracker: {`<font color="rgb({200},{0},{0})">Inactive</font>`}`
	end

	local v4

	if userCFrameEnabled2 then
		if instance2.Offsets.RightFoot then
			v4 = `{v3}\nRight Foot Tracker: {`<font color="rgb({0},{200},{0})">Active</font>`}`
		else
			v4 = `{v3}\nRight Foot Tracker: {`<font color="rgb({200},{150},{0})">Requires Calibration</font>`}`
		end
	else
		v4 = `{v3}\nRight Foot Tracker: {`<font color="rgb({200},{0},{0})">Inactive</font>`}`
	end

	local text

	if Enigma:IsActive() then
		local focusedTextBox = UserInputService:GetFocusedTextBox()
		local v6

		if focusedTextBox and (not focusedTextBox.Parent or focusedTextBox.Parent.Name ~= "EnigmaTextBoxInput") then
			v6 = `{v4}\nData transfer: {`<font color="rgb({200},{0},{0})">Inactive</font>`}`
		else
			v6 = `{v4}\nData transfer: {`<font color="rgb({0},{200},{0})">Active</font>`}`

			if Enigma.Input then
				local v7 = string.split(Enigma.Input:GetCurrentText(), "|")[1]

				if v[v7] then
					v6 = `{v6}\n\nProtocol version: {v7}`
				else
					v6 = `{v6}\n\nProtocol version: {`<font color="rgb({200},{150},{0})">{`{v7} (Unsupported)`}</font>`}`
				end
			end
		end

		if userCFrameEnabled or userCFrameEnabled2 or not Enigma:GetUserCFrameEnabled("None") then
			text = `{v6}\n\nTo calibrate, stand up straight with your head level and facing forward with your feet next to each other pointing forward.`
		else
			text = `{v6}\n\n⚠️ Trackers are detected, but the role in SteamVR is "None". They need to have assigned roles through the SteamVR menu.`
		end

		if self.ShowTrackersButton then
			self.ShowTrackersButton.Visible = true
		end

		if self.CalibrateButton then
			self.CalibrateButton.Visible = true
		end
	else
		text = `{`{v4}\nData transfer: {`<font color="rgb({200},{150},{0})">Inactive</font>`}`}\n\n⚠️ Enigma requires a desktop application. There may be experience-specific issues when Enigma is active.`

		if self.ShowTrackersButton then
			self.ShowTrackersButton.Visible = false
		end

		if self.CalibrateButton then
			self.CalibrateButton.Visible = false
		end
	end

	self.EnigmaText.Text = text
end

function EnigmaView:ShowDebugTrackers()
	if not Enigma.Enabled then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "NexusVRCharacterModelEnigmaDebugTrackers"
	folder.Parent = Workspace.CurrentCamera
	local v2 = {}
	local v3 = {}

	while self.DebugTrackersVisible do
		local v4 = Workspace.CurrentCamera:GetRenderCFrame() * VRService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()
		local v5 = {}
		local count = 0

		for _, trackerRole in Enigma.TrackerRoles do
			local v6 = 1

			while Enigma:GetUserCFrameEnabled(trackerRole, v6) do
				v5[v6 == 1 and trackerRole or `{trackerRole} ({v6})`] = v4 * Enigma:GetUserCFrame(trackerRole, v6)
				count += 1
				v6 += 1
			end
		end

		local v6 = 1

		for k, cFrame in v5 do
			if not v2[v6] then
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Institutional white")
				part.Material = Enum.Material.Neon
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(0.2, 0.2, 0.2)
				part.Parent = folder
				v2[v6] = part
				local sphereHandleAdornment = Instance.new("SphereHandleAdornment")
				sphereHandleAdornment.Transparency = 0.5
				sphereHandleAdornment.AlwaysOnTop = true
				sphereHandleAdornment.Color3 = Color3.fromRGB(255, 255, 255)
				sphereHandleAdornment.ZIndex = 1
				sphereHandleAdornment.Radius = 0.1
				sphereHandleAdornment.Adornee = part
				sphereHandleAdornment.Parent = part
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.AlwaysOnTop = true
				billboardGui.Adornee = part
				billboardGui.Size = UDim2.new(2, 0, 0.4, 0)
				billboardGui.StudsOffset = createVector(0, 0.3, 0)
				billboardGui.Parent = part
				local textLabel = Instance.new("TextLabel")
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.TextScaled = true
				textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				textLabel.TextStrokeTransparency = 0
				textLabel.Parent = billboardGui
				v3[v6] = textLabel
			end

			v2[v6].CFrame = cFrame
			v3[v6].Text = k
			v6 += 1
		end

		for i = #v2, count + 1, -1 do
			v2[i]:Destroy()
			v2[i] = nil
			v3[i]:Destroy()
			v3[i] = nil
		end

		RunService.RenderStepped:Wait()
	end

	folder:Destroy()
end

return EnigmaView