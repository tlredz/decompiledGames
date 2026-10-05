local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Codec = require(script.Parent.Codec)
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Renderer = require(script.Parent.Renderer)
local StaffTagFlags = require(ReplicatedStorage.Shared.Flags.StaffTagFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local frozen = table.freeze({
	[11907795] = true,
	[3871388597] = true
})
local parent = script.Parent
assert(parent:IsA("ScreenGui"), "OverlayDisplay must belong to a ScreenGui")
local frame = parent:FindFirstChild("Frame")

if not (frame and frame:IsA("GuiObject")) then
	frame = nil
end

parent.Enabled = false
Renderer.clear(parent)

if frame then
	frame.Visible = false
end

if not (Environment.IsDevPlace() or Environment.IsTestPlace()) then
	return
end

parent.ResetOnSpawn = false
parent.IgnoreGuiInset = true
parent.ScreenInsets = Enum.ScreenInsets.None
parent.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
parent.ClipToDeviceSafeArea = false
local maid = Trove.new()
local extended = maid:Extend()
local extended2 = maid:Extend()
local v = ""
local isStudio = RunService:IsStudio()
maid:AttachToInstance(parent)
maid:Add(function()
	Renderer.clear(parent)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function isStaff()
	local userId = Players.LocalPlayer.UserId
	return frozen[userId] == true or StaffTagFlags.Roles:Get()[tostring(userId)] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideForStaff()
	v = ""
	Renderer.clear(parent)

	if frame then
		frame.Visible = false
	end

	parent.Enabled = false
end

local function configureCapture(screenshotHud)
	if not screenshotHud:IsA("ScreenshotHud") then
		return
	end

	local hidePlayerGuiForCaptures = screenshotHud.HidePlayerGuiForCaptures
	local success, result = pcall(function()
		screenshotHud.HidePlayerGuiForCaptures = false
		return true
	end)

	if success then
		maid:Add(function()
			if not screenshotHud.Parent then
				return
			end

			pcall(function()
				screenshotHud.HidePlayerGuiForCaptures = hidePlayerGuiForCaptures
			end)
		end)
	else
		warn("[QAOverlay] Cannot include PlayerGui in capture: " .. tostring(result))
	end
end

local function showFallback()
	if isStaff() then
		hideForStaff() -- equivalent call inferred; original call site unknown
	else
		v = ""
		Renderer.clear(parent)

		if frame then
			for _, label in frame:QueryDescendants("#UID") do
				if label:IsA("TextLabel") then
					label.Text = tostring(Players.LocalPlayer.UserId)
				end
			end

			frame.Visible = true
		else
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "FingerprintUnavailable"
			textLabel:SetAttribute("OverlayOwner", Renderer.OWNER)
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, 0, 0, 32)
			textLabel.Text = "QA capture marker pending: " .. Players.LocalPlayer.UserId
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.TextStrokeTransparency = 0
			textLabel.TextSize = 16
			textLabel.Active = false
			textLabel.Interactable = false
			textLabel.Selectable = false
			textLabel.Parent = parent
		end

		parent.Enabled = true
	end
end

local function refresh()
	if not parent.Parent then
		return
	end

	if isStaff() then
		hideForStaff() -- equivalent call inferred; original call site unknown
	else
		local fingerprintUserId = parent:GetAttribute("FingerprintUserId")
		local PREVIEW_PAYLOAD

		if type(fingerprintUserId) == "number" and Codec.getIsUserId(fingerprintUserId) then
			PREVIEW_PAYLOAD = Codec.createUserIdPayload(fingerprintUserId)
		else
			if not isStudio then
				showFallback()
				return
			end

			local userId = Players.LocalPlayer.UserId

			if Codec.getIsUserId(userId) then
				PREVIEW_PAYLOAD = Codec.createUserIdPayload(userId)
			else
				PREVIEW_PAYLOAD = Codec.PREVIEW_PAYLOAD
			end
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera or currentCamera.ViewportSize.X <= 1 or currentCamera.ViewportSize.Y <= 1 then
			return
		end

		local joined = table.concat({
			PREVIEW_PAYLOAD,
			tostring(currentCamera.ViewportSize),
			tostring(parent:GetAttribute("DotOpacity")),
			(tostring(parent:GetAttribute("TilePixels")))
		}, ":")

		if joined ~= v then
			Renderer.mount(parent, {
				payload = PREVIEW_PAYLOAD,
				viewport = currentCamera.ViewportSize,
				isPreview = PREVIEW_PAYLOAD == Codec.PREVIEW_PAYLOAD
			})
			v = joined
		end

		if frame then
			frame.Visible = false
		end

		parent.Enabled = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleRefresh()
	extended2:Clean()
	extended2:AddPromise(Promise.delay(0.2):andThen(refresh))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindCamera()
	extended:Clean()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		extended:Connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), scheduleRefresh)
	end

	scheduleRefresh() -- equivalent call inferred; original call site unknown
end

local screenshotHud = GuiService:FindFirstChild("ScreenshotHud")

if screenshotHud then
	configureCapture(screenshotHud)
end

maid:Connect(GuiService.ChildAdded, configureCapture)
maid:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
maid:Connect(StaffTagFlags.Roles.Changed, scheduleRefresh)

for _, v2 in { "FingerprintUserId", "DotOpacity", "TilePixels" } do
	maid:Connect(parent:GetAttributeChangedSignal(v2), scheduleRefresh)
end

if not isStudio then
	showFallback()
	maid:AddPromise(Promise.delay(30):andThen(function()
		if parent.Parent then
			local userId = Players.LocalPlayer.UserId

			if frozen[userId] ~= true and StaffTagFlags.Roles:Get()[tostring(userId)] == nil and not Codec.getIsUserId(parent:GetAttribute("FingerprintUserId")) then
				warn("[QAOverlay] No UserId marker for " .. Players.LocalPlayer.Name)
			end
		end
	end))
end

bindCamera() -- equivalent call inferred; original call site unknown