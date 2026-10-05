local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local modules = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local ConfirmationController = require(legacyControllers.ConfirmationController)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local rods = require(modules.library.rods)
local wishCatalog = require(modules.library.wishCatalog)
local NumberUtils = require(utils.NumberUtils)
local HuntNames = require(ReplicatedStorage.shared.data.HuntNames)
local remoteEvent = Net:RemoteEvent("Skycrest/OpenWishMenu")
local remoteFunction = Net:RemoteFunction("Skycrest_RequestWish")
local wishOverlay = HudController:GetPlayerGui():WaitForChild("WishOverlay")
local header = wishOverlay.Header
local back = header.Back
local uIGradient = header.Label.UIGradient
local container = wishOverlay.Container
local rodList = container.RodList
local left = container.Left
local right = container.Right
local stats = wishOverlay.Stats
local wish = wishOverlay.Wish
local uIGradient2 = wishOverlay.Overlay.UIGradient
local rod = script.Rod
local hud = HudController:GetHud()
local backpackGui = HudController:GetBackpackGui()
local overlayGui = HudController:GetOverlayGui()
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 201, 201)
local color3 = Color3.fromRGB(255, 111, 111)
local color4 = Color3.fromRGB(70, 70, 70)
local v = {
	Luck = {
		key = "Luck",
		format = function(p)
			return (`Luck: {p.Luck}%`)
		end,
		bands = {
			{ 0, color2 },
			{ 1e999, color }
		}
	},
	LureSpeed = {
		key = "Lure",
		format = function(p)
			return (`Lure Speed: {p.Lure}%`)
		end,
		bands = {
			{ 0, color2 },
			{ 1e999, color }
		}
	},
	Control = {
		key = "Control",
		format = function(p)
			return (`Control: {math.round(p.Control * 1000) / 1000}`)
		end,
		bands = {
			{ -0.3, color3 },
			{ 0, color2 },
			{ 1e999, color }
		}
	},
	Strength = {
		key = "Strength",
		format = function(p)
			return (`Max Kg: {NumberUtils:Comma(p.Strength)}kg`)
		end,
		bands = {
			{ 0.001, color3 },
			{ 1e999, color }
		}
	},
	Resilience = {
		key = "Resilience",
		format = function(p)
			return (`Resilience: {p.Resilience}%`)
		end,
		bands = {
			{ -200, color3 },
			{ 0, color2 },
			{ 1e999, color }
		}
	},
	ProgressSpeed = {
		key = "ProgressSpeed",
		format = function(p)
			return "Progress Speed: " .. string.format("%+.0f%%", p.ProgressSpeed)
		end,
		visibleIf = function(p)
			return p.ProgressSpeed and p.ProgressSpeed ~= 0
		end,
		bands = {
			{ 0, color2 },
			{ 1e999, color }
		}
	},
	Disturbance = {
		key = "Disturbance",
		format = function(p)
			return (`Disturbance: +{p.Disturbance or 0}`)
		end,
		visibleIf = function(p)
			return p.Disturbance and p.Disturbance ~= 0
		end,
		bands = {
			{ 1e999, color }
		}
	},
	PreferredDisturbance = {
		key = "PreferredDisturbance",
		format = function(p)
			local preferredDisturbance = p.PreferredDisturbance
			return (`Hunt Focus: {HuntNames[preferredDisturbance.Event] or preferredDisturbance.Event} (+{preferredDisturbance.Risk})`)
		end,
		visibleIf = function(p)
			local preferredDisturbance = p.PreferredDisturbance
			return preferredDisturbance ~= nil and preferredDisturbance.Risk ~= 0 and preferredDisturbance.Event ~= ""
		end,
		bands = {
			{ 1e999, color }
		}
	}
}
local v2 = {
	[0] = 0,
	[1] = 0.2,
	[2] = 0.6
}
local WishOverlayController = {}
local v3 = Trove.new()
local entries = {}
local v4 = {}
local v5 = 1
local v6 = false
local total = 0
local v7 = 0
local total2 = 0.5
local v8 = {}
local X = nil
local total3 = 0
local v9 = {}

local function isComingSoon(p)
	return p ~= nil and wishCatalog.IsComingSoon(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCountdown(p: number)
	local v10 = math.max(0, (math.floor(p)))
	local v11 = v10 // 86400
	local v12 = v10 % 86400 // 3600
	local v13 = v10 % 3600 // 60

	if v11 > 0 then
		return (`{v11}d {v12}h`)
	end

	if v12 > 0 then
		return (`{v12}h {v13}m`)
	end

	return (`{v13}m {v10 % 60}s`)
end

local function cacheAlpha(folder)
	local v10 = {}

	local function record(instance)
		local v11 = {
			Instance = instance
		}
		local flag

		if instance:IsA("GuiObject") then
			v11.Background = instance.BackgroundTransparency
			flag = true
		else
			flag = false
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			v11.Image = instance.ImageTransparency
			flag = true
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			v11.Text = instance.TextTransparency
			v11.TextStroke = instance.TextStrokeTransparency
			flag = true
		end

		if instance:IsA("UIStroke") then
			v11.Stroke = instance.Transparency
			flag = true
		end

		if instance:IsA("UIShadow") then
			v11.Shadow = instance.Transparency
			flag = true
		end

		if flag then
			table.insert(v10, v11)
		end
	end

	record(folder)

	for _, descendant in folder:GetDescendants() do
		record(descendant)
	end

	return v10
end

local function applyAlpha(items, p: number)
	for _, item in items do
		local instance = item.Instance

		if not instance.Parent then
			continue
		end

		if item.Background then
			instance.BackgroundTransparency = 1 - (1 - item.Background) * p
		end

		if item.Image then
			instance.ImageTransparency = 1 - (1 - item.Image) * p
		end

		if item.Text then
			instance.TextTransparency = 1 - (1 - item.Text) * p
			instance.TextStrokeTransparency = 1 - (1 - item.TextStroke) * p
		end

		if item.Stroke then
			instance.Transparency = 1 - (1 - item.Stroke) * p
		end

		if item.Shadow then
			instance.Transparency = 1 - (1 - item.Shadow) * p
		end
	end
end

local function kickGradient(p: number)
	total2 += p
end

local updateCards

local function resolveStats(p)
	local rod2 = rods[p.Rod]

	if not rod2 then
		return nil
	end

	local clone = table.clone(rod2)
	clone.Lure = (clone.Lure or 0) + (100 - clone.LureSpeed)
	clone.ProgressSpeed = (clone.ProgressSpeed or 0) + (clone.ProgressEfficiency or 0) * 100 + (clone.ForcedProgressEfficiency or 0) * 100 + (clone.ForcedProgressSpeed or 0)
	return clone
end

local function updateStats(p)
	local v10 = p and resolveStats(p)

	for childName, v11 in v do
		local child = stats:FindFirstChild(childName)

		if not child then
			continue
		end

		if v10 then
			local visible = not v11.visibleIf or v11.visibleIf(v10)
			child.Visible = visible

			if visible then
				child.Label.Text = v11.format(v10)
				local v13 = v10[v11.key] or 0
				local v14 = color

				if typeof(v13) == "number" then
					for _, band in v11.bands do
						if not (v13 < band[1]) then
							continue
						end

						v14 = band[2]
						break
					end
				end

				child.Label.TextColor3 = v14
				child.Icon.ImageColor3 = v14
			end
		else
			child.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function styleWishButton(flag: boolean)
	local button = wish

	if button:IsA("GuiButton") then
		local backgroundColor

		if flag then
			backgroundColor = color4
		else
			backgroundColor = v9.Background
		end

		button.BackgroundColor3 = backgroundColor
	end

	local label = button.Label
	local textColor

	if flag then
		textColor = color4
	else
		textColor = v9.Text
	end

	label.TextColor3 = textColor
	local uIStroke = button:FindFirstChildWhichIsA("UIStroke")

	if uIStroke and v9.Stroke then
		local color5

		if flag then
			color5 = color4
		else
			color5 = v9.Stroke
		end

		uIStroke.Color = color5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSelection()
	local v10 = entries[v5]
	local v11

	if v10 == nil then
		v11 = false
	else
		v11 = wishCatalog.IsComingSoon(v10)
	end

	if v10 then
		wish.Label.Text = v11 and "[Coming Soon]" or `[Wish for {v10.DisplayName}]`
	end

	wish.Visible = v10 ~= nil
	styleWishButton(v11) -- equivalent call inferred; original call site unknown
	updateStats(v10)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function move(p: number)
	if #entries <= 1 then
		return
	end

	v5 = (v5 - 1 + p) % #entries + 1
	total2 += 1
	updateSelection() -- equivalent call inferred; original call site unknown
end

local function buildCards()
	for _, v10 in v4 do
		v10.Frame:Destroy()
	end

	table.clear(v4)

	for _, guiObject in rodList:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, entry in entries do
		local clone = rod:Clone()
		clone.Name = entry.Id
		clone.Visible = false
		local rod2 = rods[entry.Rod]
		clone.ImageLabel.Image = rod2 and rod2.Icon or entry.Icon
		clone.RodInfo.rodTitle.Text = `[{entry.DisplayName}]`
		clone.RodInfo.rodTitle.TextColor3 = rod2.Color
		clone.RodInfo.desc.Text = rod2 and rod2.Description or ""
		local comingSoon = nil
		local v11

		if entry == nil then
			v11 = false
		else
			v11 = wishCatalog.IsComingSoon(entry)
		end

		if v11 then
			clone.ImageLabel.ImageColor3 = color4
			comingSoon = clone.ImageLabel.ComingSoon
			comingSoon.Visible = true
			local text = formatCountdown(entry.ComingSoonAt - os.time()) -- equivalent call inferred; original call site unknown
			comingSoon.Text = text
		end

		clone.Parent = rodList
		table.insert(v4, {
			Frame = clone,
			Entry = entry,
			Timer = comingSoon,
			Scale = clone:WaitForChild("UIScale"),
			Records = cacheAlpha(clone),
			X = 0.5,
			ScaleValue = 1,
			Opacity = 0
		})
	end

	updateCards(1)
end

updateCards = function(p: number)
	local count = #v4

	if count == 0 then
		return
	end

	local v10 = math.floor(count / 2)
	local v11 = 1 - math.exp(-p * 12)

	for k, v12 in v4 do
		local v13 = (k - v5 + v10) % count - v10
		local v14 = math.abs(v13)
		local v15 = v13 * 0.23 + 0.5
		local v16 = 1 - v14 * 0.19
		local v17 = v14 > 2 and 0 or 1 - (v2[v14] or 0.6)
		v12.X += (v15 - v12.X) * v11
		v12.ScaleValue += (v16 - v12.ScaleValue) * v11
		v12.Opacity += (v17 - v12.Opacity) * v11
		v12.Frame.Position = UDim2.fromScale(v12.X, 0.5)
		v12.Frame.ZIndex = 10 - v14
		v12.Scale.Scale = v12.ScaleValue
		local visible

		if v12.Opacity > 0.01 then
			visible = total > 0.01
		else
			visible = false
		end

		v12.Frame.Visible = visible

		if visible then
			applyAlpha(v12.Records, v12.Opacity * total)
		end
	end
end

local function tickCountdowns()
	local now = os.time()
	local v10 = false

	for _, v11 in v4 do
		if not v11.Timer then
			continue
		end

		local v12 = v11.Entry.ComingSoonAt - now

		if v12 <= 0 then
			v10 = true
		else
			local timer = v11.Timer
			local text = formatCountdown(v12) -- equivalent call inferred; original call site unknown
			timer.Text = text
		end
	end

	if v10 and v6 then
		buildCards()
		updateSelection() -- equivalent call inferred; original call site unknown
	end
end

local function step(p: number)
	total2 += (0.5 - total2) * (1 - math.exp(-p * 1.6))
	total3 += p

	if total3 >= 1 then
		total3 = 0
		tickCountdowns()
	end

	v7 = (v7 + total2 * p) % 1
	local v10 = v7 * 2 - 1

	if not SettingsController:GetSettingValue("photosensitiveMode") then
		uIGradient2.Offset = Vector2.new(v10, uIGradient2.Offset.Y)
		uIGradient.Offset = Vector2.new(v10, uIGradient.Offset.Y)
	end

	total += ((v6 and 1 or 0) - total) * (1 - math.exp(-p * 9))

	if not v6 and total < 0.01 then
		total = 0
		wishOverlay.Enabled = false
	end

	applyAlpha(v8, total)
	updateCards(p)
end

function WishOverlayController:Close()
	if not v6 then
		return
	end

	v6 = false
	hud.Enabled = true
	hud.deviceinset.Enabled = true
	backpackGui.Enabled = true
	overlayGui.Enabled = true
	task.spawn(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	end)
end

function WishOverlayController:Open(p)
	entries = p and p.Entries or {}
	v5 = 1
	buildCards()
	updateSelection() -- equivalent call inferred; original call site unknown
	v6 = true
	wishOverlay.Enabled = true
	hud.Enabled = false
	hud.deviceinset.Enabled = false
	backpackGui.Enabled = false
	overlayGui.Enabled = false
	task.spawn(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
	total2 += 2.5
end

local function confirm()
	local entry = entries[v5]

	if not entry then
		return
	end

	local v10

	if entry == nil then
		v10 = false
	else
		v10 = wishCatalog.IsComingSoon(entry)
	end

	if v10 then
		total2 += 1
		return
	end

	total2 += 2.5

	if ConfirmationController.new({
		header = "Quest Wish",
		text = `Wishing for <b><font color="#{rods[entry.Rod].Color:ToHex()}">{entry.Rod}</font></b> means you will not immediately get the rod and <b>you will permanently get the quest for this rod</b>.<br/><br/><b><font color="#ffa1a1">YOU ONLY GET 1 WISH AND THIS CANNOT BE UNDONE.</font></b>`,
		options = {
			{
				text = "No",
				color = Color3.fromRGB(255, 120, 122)
			},
			{
				text = "Yes"
			}
		},
		overlayGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 84, 102))
		})
	}) == 1 then
		return
	end

	if ConfirmationController.new({
		header = "Quest Wish (2)",
		text = `Are you <b><font color="#ffa1a1">100%</font></b> sure you want to <b>get the quest</b> for <b><font color="#{rods[entry.Rod].Color:ToHex()}">{entry.Rod}</font></b>?<br/><br/><b><font color="#ffa1a1">YOU ONLY GET 1 WISH AND THIS CANNOT BE UNDONE.</font></b>`,
		options = {
			{
				text = "No",
				color = Color3.fromRGB(255, 120, 122)
			},
			{
				text = "Yes"
			}
		},
		overlayGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 27, 27))
		})
	}) == 1 then
		return
	end

	if ConfirmationController.new({
		header = "YOU CAN ONLY DO THIS ONCE!",
		text = `Are you <b><i><font color="#ffa1a1">POSITIVE</font></i></b> you want to <b>PERMANENTLY get the quest</b> for <b><font color="#{rods[entry.Rod].Color:ToHex()}">{entry.Rod}</font></b>?`,
		options = {
			{
				text = "No",
				color = Color3.fromRGB(255, 120, 122)
			},
			{
				text = "Yes",
				countdown = 3
			}
		},
		overlayGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 27, 27))
		})
	}) == 1 then
		return
	end

	if remoteFunction:InvokeServer(entry.Id) then
		WishOverlayController:Close()
		return
	end

	updateSelection() -- equivalent call inferred; original call site unknown
end

function WishOverlayController.Start(_)
	local button = wish
	local uIStroke = button:FindFirstChildWhichIsA("UIStroke")
	local image

	if button:IsA("ImageButton") then
		image = button.ImageColor3
	end

	v9 = {
		Image = image,
		Background = button.BackgroundColor3,
		Text = button.Label.TextColor3,
		Stroke = uIStroke and uIStroke.Color or nil
	}
	wishOverlay.Enabled = false
	v8 = cacheAlpha(wishOverlay)
	applyAlpha(v8, 0)
	v3:Connect(remoteEvent.OnClientEvent, function(p)
		WishOverlayController:Open(p)
	end)
	v3:Connect(back.Activated, function()
		WishOverlayController:Close()
	end)
	v3:Connect(left.Activated, function()
		if #entries <= 1 then
			return
		end

		v5 = (v5 - 1 + -1) % #entries + 1
		total2 += 1
		updateSelection() -- equivalent call inferred; original call site unknown
	end)
	v3:Connect(right.Activated, function()
		if #entries <= 1 then
			return
		end

		v5 = (v5 - 1 + 1) % #entries + 1
		total2 += 1
		updateSelection() -- equivalent call inferred; original call site unknown
	end)
	v3:Connect(wish.Activated, confirm)
	v3:Connect(UserInputService.InputChanged, function(p, p2)
		if p2 or not v6 or p.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end

		move(p.Position.Z > 0 and -1 or 1) -- equivalent call inferred; original call site unknown
	end)
	v3:Connect(UserInputService.TouchStarted, function(p, p2)
		if p2 or not v6 then
			return
		end

		X = p.Position.X
	end)
	v3:Connect(UserInputService.TouchEnded, function(p)
		if not (X and v6) then
			return
		end

		local v12 = p.Position.X - X
		X = nil

		if math.abs(v12) > wishOverlay.AbsoluteSize.X * 0.06 then
			move(v12 > 0 and -1 or 1) -- equivalent call inferred; original call site unknown
		end
	end)
	v3:Connect(RunService.RenderStepped, step)
end

return WishOverlayController