local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local ogclick = script:FindFirstChild("ogclick")

-- equivalent calls inferred from this helper; original call sites unknown
local function playClickSfx()
	if ogclick then
		ogclick:Play()
	end
end

local localPlayer = Players.LocalPlayer
localPlayer:GetMouse()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	["United States"] = "US",
	Canada = "CA",
	Mexico = "MX",
	Brazil = "BR",
	["United Kingdom"] = "GB",
	Germany = "DE",
	France = "FR",
	Poland = "PL",
	Spain = "ES",
	Netherlands = "NL",
	Sweden = "SE",
	Italy = "IT",
	Finland = "FI",
	Turkey = "TR",
	Ireland = "IE",
	Norway = "NO",
	Denmark = "DK",
	Russia = "RU",
	Japan = "JP",
	Singapore = "SG",
	Australia = "AU",
	India = "IN",
	["Hong Kong"] = "HK",
	["South Korea"] = "KR",
	Philippines = "PH",
	Vietnam = "VN",
	Thailand = "TH",
	Indonesia = "ID",
	China = "CN",
	Taiwan = "TW"
}
local v2 = utf8.char(127760)
local v3 = {}
local v4 = {}
local v5 = {}
local count = 0
local v6 = {}
local v7 = {}
local v8 = 0
local now = 0
local v9 = {}

for k, v10 in pairs(v) do
	local v11 = string.upper((tostring(v10)))
	v3[k] = v11
	v4[v11] = k
	v5[string.lower(k)] = k
end

local v10 = {
	us = "United States",
	usa = "United States",
	["u.s."] = "United States",
	["united states of america"] = "United States",
	uk = "United Kingdom",
	["great britain"] = "United Kingdom",
	england = "United Kingdom",
	korea = "South Korea",
	["republic of korea"] = "South Korea"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function trimregiontoken(value)
	if type(value) == "string" then
		return (value:gsub("^%s+", ""):gsub("%s+$", ""))
	end

	return ""
end

local function flagfromcountrycode(value)
	local v11 = string.upper(trimregiontoken(value))

	if #v11 ~= 2 then
		return v2
	end

	local v12 = string.byte(v11, 1)
	local v13 = string.byte(v11, 2)

	if v12 and v13 then
		if v12 < 65 or v12 > 90 or v13 < 65 or v13 > 90 then
			return v2
		end

		return utf8.char(v12 + 127397, v13 + 127397)
	else
		return v2
	end
end

local normalizecountry

normalizecountry = function(value)
	local selected = trimregiontoken(tostring(value or "")) -- equivalent call inferred; original call site unknown

	if selected == "" then
		return nil, nil
	end

	local v13 = string.upper(selected)

	if v4[v13] then
		return v4[v13], v13
	end

	if v3[selected] then
		return selected, v3[selected]
	end

	local v14 = string.lower(selected)
	local v15 = v5[v14]

	if v15 then
		return v15, v3[v15]
	end

	local v16 = v10[v14]

	if v16 and v3[v16] then
		return v16, v3[v16]
	end

	local match = selected:match(".*,%s*(.+)$")

	if match and match ~= selected then
		local v17, v18 = normalizecountry(match)

		if v17 then
			return v17, v18
		end
	end

	local match2 = string.upper(selected):match("^([A-Z][A-Z])[%s%-%_/]")

	if match2 and v4[match2] then
		return v4[match2], match2
	end

	if string.find(v14, "united states", 1, true) then
		return "United States", "US"
	end

	if string.find(v14, "united kingdom", 1, true) or string.find(v14, "great britain", 1, true) then
		return "United Kingdom", "GB"
	end

	if string.find(v14, "south korea", 1, true) or string.find(v14, "korea", 1, true) then
		return "South Korea", "KR"
	end

	return nil, nil
end

local function resolveserverregiondisplay(data)
	local v12 = trimregiontoken(tostring(not data and "" or data.region or "")) -- equivalent call inferred; original call site unknown
	local v14 = trimregiontoken(tostring(not data and "" or data.country or data.countryName or data.country_code or data.countryCode or "")) -- equivalent call inferred; original call site unknown
	local v15, v16 = normalizecountry(v14)

	if not v15 then
		v15, v16 = normalizecountry(v12)
	end

	local v17 = v15 or (v12 == "" or not v12) and "Unknown" or v12
	return v15 or (v12 == "" or not v12) and "Unknown" or v12, v17, v16 and flagfromcountrycode(v16) or v2
end

local v11 = {}

for k, list in pairs({
	NA = { "United States", "Canada", "Mexico" },
	SA = { "Brazil" },
	EU = {
		"United Kingdom",
		"Germany",
		"France",
		"Poland",
		"Spain",
		"Netherlands",
		"Sweden",
		"Italy",
		"Finland",
		"Turkey",
		"Ireland",
		"Norway",
		"Denmark",
		"Russia"
	},
	ASIA = {
		"Japan",
		"Singapore",
		"India",
		"Hong Kong",
		"South Korea",
		"Philippines",
		"Vietnam",
		"Thailand",
		"Indonesia",
		"China",
		"Taiwan"
	},
	OCE = { "Australia" }
}) do
	for _, v13 in ipairs(list) do
		v11[v13] = k
	end
end

local serverlist = script.Parent.Serverlist
local bg = serverlist.Bg
local buttons = serverlist.Buttons
local searchBarFrame = serverlist.SearchBarFrame
local pageFrame = serverlist.PageFrame
local filterFrame = bg.FilterFrame
local _ = bg.FriendJoin.FriendScroller
local sortby = filterFrame.sortby
local countryscroller = sortby.Parent.countryscroller
local v13 = {
	sortby = sortby,
	countriesBtn = filterFrame:FindFirstChild("countries"),
	scroller = countryscroller,
	openMode = nil,
	tweentime = 0.1,
	scrollerlodefault = 50,
	arrowclosed = 90,
	arrowopen = -90,
	openSize = countryscroller.Size,
	closedSize = UDim2.new(countryscroller.Size.X.Scale, countryscroller.Size.X.Offset, 0, 0),
	tween = nil,
	version = 0,
	sortitems = {
		players = true,
		uptime = true,
		kills = true,
		minkills = true,
		maxkills = true,
		tagbox = true
	},
	sortbyArrow = sortby:FindFirstChild("ImageButton"),
	countriesArrow = nil,
	arrowTweens = {}
}
v13.countriesArrow = v13.countriesBtn and v13.countriesBtn:FindFirstChild("ImageButton")
local guiObjects = {}
local v14 = false
local v15 = {
	NA = {
		NA = 0,
		SA = 120,
		EU = 100,
		ASIA = 180,
		OCE = 220
	},
	SA = {
		NA = 120,
		SA = 0,
		EU = 180,
		ASIA = 300,
		OCE = 300
	},
	EU = {
		NA = 100,
		SA = 180,
		EU = 0,
		ASIA = 160,
		OCE = 280
	},
	ASIA = {
		NA = 180,
		SA = 300,
		EU = 160,
		ASIA = 0,
		OCE = 130
	},
	OCE = {
		NA = 220,
		SA = 300,
		EU = 280,
		ASIA = 130,
		OCE = 0
	}
}

for _, guiObject in ipairs(filterFrame:GetChildren()) do
	if guiObject:IsA("GuiObject") and guiObject ~= countryscroller then
		table.insert(guiObjects, guiObject)
	end
end

table.sort(guiObjects, function(a, b)
	if a.LayoutOrder == b.LayoutOrder then
		return a.Name < b.Name
	end

	return a.LayoutOrder < b.LayoutOrder
end)

for i, v16 in ipairs(guiObjects) do
	v16.LayoutOrder = i * 10
end

countryscroller.LayoutOrder = v13.scrollerlodefault
countryscroller.Visible = false
countryscroller.Size = v13.closedSize

if v13.sortbyArrow then
	v13.sortbyArrow.Rotation = v13.arrowclosed
end

if v13.countriesArrow then
	v13.countriesArrow.Rotation = v13.arrowclosed
end

local v16 = {}

local function lockHiddenGuiObject(button)
	if not button then
		return
	end

	button.Visible = false
	pcall(function()
		button.Active = false
	end)
	pcall(function()
		button.Selectable = false
	end)

	if button:IsA("GuiButton") then
		button.AutoButtonColor = false
	end
end

local function keepGuiObjectHidden(instance)
	lockHiddenGuiObject(instance)

	if not instance or v16[instance] then
		return
	end

	v16[instance] = true
	instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible then
			lockHiddenGuiObject(instance)
		end
	end)
end

keepGuiObjectHidden(filterFrame:FindFirstChild("friendsonly"))
local uIListLayout = countryscroller:IsA("ScrollingFrame") and (countryscroller:FindFirstChildOfClass("UIListLayout") or countryscroller:FindFirstChildOfClass("UIGridLayout"))

if uIListLayout then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function syncCanvas()
		countryscroller.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
	end

	syncCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
end

function v13.tweenArrow(p, rotation)
	if not p then
		return
	end

	if v13.arrowTweens[p] then
		v13.arrowTweens[p]:Cancel()
	end

	v13.arrowTweens[p] = TweenService:Create(
		p,
		TweenInfo.new(v13.tweentime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Rotation = rotation
		}
	)
	v13.arrowTweens[p]:Play()
end

function v13.applyContents(p)
	for _, guiObject in ipairs(countryscroller:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		if v13.sortitems[guiObject.Name] then
			guiObject.Visible = p == "sort"
		else
			guiObject.Visible = p == "country"
		end
	end
end

v13.reorderCountriesBySelection = nil

function v13.setMode(openMode)
	if openMode == v13.openMode then
		return
	end

	local openMode2 = v13.openMode
	v13.openMode = openMode
	v14 = openMode ~= nil
	v13.version += 1
	local version = v13.version

	if v13.tween then
		v13.tween:Cancel()
		v13.tween = nil
	end

	v13.tweenArrow(v13.sortbyArrow, openMode == "sort" and v13.arrowopen or v13.arrowclosed)
	v13.tweenArrow(v13.countriesArrow, openMode == "country" and v13.arrowopen or v13.arrowclosed)

	if openMode then
		v13.applyContents(openMode)

		if openMode == "country" and v13.reorderCountriesBySelection then
			v13.reorderCountriesBySelection()
		end

		local uIListLayout2 = countryscroller:FindFirstChildOfClass("UIListLayout")

		if uIListLayout2 then
			uIListLayout2.Padding = openMode == "country" and UDim.new(0.003, 0) or UDim.new(0.01, 0)
		end

		local sortby2 = openMode == "sort" and v13.sortby or v13.countriesBtn

		if sortby2 then
			countryscroller.LayoutOrder = sortby2.LayoutOrder + 1
		end

		countryscroller.Visible = true

		if openMode2 ~= nil then
			return
		end
	end

	local openSize = openMode and v13.openSize or v13.closedSize
	v13.tween = TweenService:Create(
		countryscroller,
		TweenInfo.new(v13.tweentime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = openSize
		}
	)
	v13.tween:Play()

	if not openMode then
		v13.tween.Completed:Connect(function(p)
			if not (p == Enum.PlaybackState.Completed and version == v13.version) then
				return
			end

			if not v13.openMode then
				countryscroller.Visible = false
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCountryDropdown(p)
	if p then
		v13.setMode(v13.openMode or "country")
	else
		v13.setMode(nil)
	end
end

sortby.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	playClickSfx() -- equivalent call inferred; original call site unknown

	if v13.openMode == "sort" then
		setCountryDropdown(false) -- equivalent call inferred; original call site unknown
	else
		v13.setMode("sort")
	end
end)

if v13.countriesBtn then
	v13.countriesBtn.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		playClickSfx() -- equivalent call inferred; original call site unknown

		if v13.openMode == "country" then
			setCountryDropdown(false) -- equivalent call inferred; original call site unknown
		else
			v13.setMode("country")
		end
	end)
end

local v17 = { "players", "uptime", "kills" }
local v18 = {
	ANY = -90,
	HIGH = 0,
	LOW = -180
}
local v19 = {
	players = "ANY",
	uptime = "ANY",
	kills = "ANY"
}
local v20 = {}

local function applyarrowrotation(childName, p, p2)
	local child = countryscroller:FindFirstChild(childName)

	if not child then
		return
	end

	local arrow = child:FindFirstChild("Arrow")

	if not arrow then
		return
	end

	if v20[childName] then
		v20[childName]:Cancel()
		v20[childName] = nil
	end

	local rotation = v18[p] or -90

	if not p2 then
		arrow.Rotation = rotation
		return
	end

	v20[childName] = TweenService:Create(arrow, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Rotation = rotation
	})
	v20[childName]:Play()
end

local function applyvaltext(childName, text)
	local folder = countryscroller:FindFirstChild(childName)

	if not folder then
		return
	end

	local val = folder:FindFirstChild("val") or folder:FindFirstChild("Val") or folder:FindFirstChild("ValText") or folder:FindFirstChild("value")

	if not val then
		for _, label in ipairs(folder:GetDescendants()) do
			if not label:IsA("TextLabel") then
				continue
			end

			val = label
			break
		end
	end

	if val and (val:IsA("TextLabel") or val:IsA("TextButton") or val:IsA("TextBox")) then
		val.Text = text
	end
end

local function setsortstate(p, text, p3)
	v19[p] = text
	applyarrowrotation(p, text, p3 ~= false)
	applyvaltext(p, text)
end

local v21 = {
	ANY = "HIGH",
	HIGH = "LOW",
	LOW = "ANY"
}
local v22 = {}
local v23 = 0
local minKills = nil
local maxKills = nil
local v26 = {
	players = "ANY",
	uptime = "ANY",
	kills = "ANY"
}
local v27 = {}
local priority = {
	kills = 1,
	players = 2,
	uptime = 3
}

for _, childName in ipairs(v17) do
	v19[childName] = "ANY"
	local child = countryscroller:FindFirstChild(childName)
	local arrow = child and child:FindFirstChild("Arrow")

	if arrow then
		if v20[childName] then
			v20[childName]:Cancel()
			v20[childName] = nil
		end

		arrow.Rotation = v18.ANY or -90
	end

	applyvaltext(childName, "ANY")
end

for _, childName in ipairs(v17) do
	local child = countryscroller:FindFirstChild(childName)

	if not child then
		continue
	end

	local v30 = childName
	child.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		playClickSfx() -- equivalent call inferred; original call site unknown
		local text = v21[v19[v30]] or "HIGH"
		local v32 = v30
		v19[v32] = text
		applyarrowrotation(v32, text, true)
		applyvaltext(v32, text)
	end)
end

local function wirekillbox(list, fn, _)
	local child = nil

	for _, childName in ipairs(list) do
		child = countryscroller:FindFirstChild(childName)

		if child then
			break
		end
	end

	if not child then
		return
	end

	local textBox = child:FindFirstChildWhichIsA("TextBox")

	if not textBox then
		return
	end

	pcall(function()
		textBox.ClearTextOnFocus = false
	end)
	child.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			playClickSfx() -- equivalent call inferred; original call site unknown
			textBox:CaptureFocus()
		end
	end)
	textBox.FocusLost:Connect(function()
		local v31 = string.gsub(tostring(textBox.Text or ""), "%s", "")

		if v31 == "" then
			textBox.Text = ""
			fn(nil)
		else
			local v32 = tonumber(v31)

			if v32 and not (v32 < 0) then
				local v33 = math.floor(v32)
				textBox.Text = tostring(v33)
				fn(v33)
			else
				textBox.Text = ""
				fn(nil)
			end
		end
	end)
end

local function wiretagsbox(list)
	local textBox = nil

	for _, v32 in ipairs({ countryscroller, sortby, filterFrame }) do
		if v32 then
			for _, childName in ipairs(list) do
				local child = v32:FindFirstChild(childName, true)

				if not child then
					continue
				end

				textBox = child
				break
			end
		end

		if textBox then
			break
		end
	end

	if not textBox then
		return
	end

	local textBox2

	if textBox:IsA("TextBox") then
		textBox2 = textBox
	else
		textBox2 = textBox:FindFirstChildWhichIsA("TextBox", true)
	end

	if not textBox2 then
		return
	end

	pcall(function()
		textBox2.ClearTextOnFocus = false
	end)

	if textBox ~= textBox2 then
		textBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				playClickSfx() -- equivalent call inferred; original call site unknown
				textBox2:CaptureFocus()
			end
		end)
	end

	textBox2.FocusLost:Connect(function()
		v22 = {}
		v23 = 0
		local text = tostring(textBox2.Text or "")

		for k in string.gmatch(text, "[^,%s]+") do
			local v32 = string.lower((tostring(k or ""))):gsub("[^a-z0-9-]", "")

			if #v32 > 20 then
				v32 = string.sub(v32, 1, 20)
			end

			if v32 == "" or v22[v32] then
				continue
			end

			v22[v32] = true
			v23 += 1
		end

		local v32 = {}

		for k in pairs(v22) do
			table.insert(v32, k)
		end

		table.sort(v32)
		textBox2.Text = table.concat(v32, ", ")
	end)
end

wirekillbox({
	"minkills",
	"minKills",
	"MinKills",
	"min_kills"
}, function(p)
	minKills = p
end, "min-kills")
wirekillbox({
	"maxkills",
	"maxKills",
	"MaxKills",
	"max_kills"
}, function(p)
	maxKills = p
end, "max-kills")
wiretagsbox({
	"tagbox",
	"tagsbox",
	"tagBox",
	"tagsBox",
	"TagBox",
	"TagsBox",
	"tag_box",
	"tags_box",
	"tags",
	"tag"
})

local function normalizetagtoken(value)
	local v30 = string.lower((tostring(value or ""))):gsub("[^a-z0-9-]", "")

	if #v30 > 20 then
		return (string.sub(v30, 1, 20))
	end

	return v30
end

function shared.serverlistAddTagFilter(value)
	local v30 = string.lower((tostring(value or ""))):gsub("[^a-z0-9-]", "")

	if #v30 > 20 then
		v30 = string.sub(v30, 1, 20)
	end

	if v30 == "" or v22[v30] then
		return false
	end

	v22[v30] = true
	v23 += 1
	return true
end

function shared.serverlistRemoveTagFilter(value)
	local v30 = string.lower((tostring(value or ""))):gsub("[^a-z0-9-]", "")

	if #v30 > 20 then
		v30 = string.sub(v30, 1, 20)
	end

	if v30 == "" or not v22[v30] then
		return false
	end

	v22[v30] = nil
	v23 -= 1
	return true
end

function shared.serverlistToggleTagFilter(value)
	local v30 = string.lower((tostring(value or ""))):gsub("[^a-z0-9-]", "")

	if #v30 > 20 then
		v30 = string.sub(v30, 1, 20)
	end

	if v30 == "" then
		return false
	end

	if v22[v30] then
		v22[v30] = nil
		v23 -= 1
		return false
	else
		v22[v30] = true
		v23 += 1
		return true
	end
end

function shared.serverlistGetPendingTagFilters()
	local result = {}

	for k in pairs(v22) do
		table.insert(result, k)
	end

	return result
end

local v30 = {
	keys = { "hidefull", "hastag", "haspass" },
	defaults = {
		hidefull = false,
		hastag = true,
		haspass = true
	},
	pending = {
		hidefull = false,
		hastag = true,
		haspass = true
	},
	applied = {
		hidefull = false,
		hastag = true,
		haspass = true
	},
	buttons = {},
	origColor = {},
	tweens = {},
	oncolor = Color3.fromRGB(232, 232, 232),
	tweentime = 0.15
}

function v30.setVisual(p, p2)
	local button = v30.buttons[p]

	if not button then
		return
	end

	if v30.tweens[p] then
		v30.tweens[p]:Cancel()
	end

	local oncolor = p2 and v30.oncolor or v30.origColor[p]

	if not oncolor then
		return
	end

	v30.tweens[p] = TweenService:Create(
		button,
		TweenInfo.new(v30.tweentime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			BackgroundColor3 = oncolor
		}
	)
	v30.tweens[p]:Play()
end

for _, childName in ipairs(v30.keys) do
	local child = filterFrame:FindFirstChild(childName)

	if not child then
		continue
	end

	v30.buttons[childName] = child
	v30.origColor[childName] = child.BackgroundColor3

	if v30.defaults[childName] then
		child.BackgroundColor3 = v30.oncolor
	end

	local v31 = childName
	child.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		playClickSfx() -- equivalent call inferred; original call site unknown
		v30.pending[v31] = not v30.pending[v31]
		v30.setVisual(v31, v30.pending[v31])
	end)
end

local function filterschangedsinceapply()
	if not (minKills == nil and maxKills == nil) then
		return true
	end

	for _, v31 in ipairs(v17) do
		if v19[v31] ~= v26[v31] then
			return true
		end
	end

	if v23 ~= 0 then
		return true
	end

	for k in pairs(v22) do
		if not v27[k] then
			return true
		end
	end

	for _, key in ipairs(v30.keys) do
		if v30.pending[key] ~= v30.applied[key] then
			return true
		end
	end

	return false
end

shared.serverlistsortandfilter = {
	getAppliedSort = function()
		return v26
	end,
	getAppliedMinKills = function()
		return nil
	end,
	getAppliedMaxKills = function()
		return nil
	end,
	priority = priority,
	fieldByKey = {
		players = "players",
		uptime = "uptime",
		kills = "avgKills"
	}
}
local button = nil
local customServers = bg.CustomServers
local serverName = customServers.ServerName
local instanceServer = customServers:FindFirstChild("instanceServer")
local destroyServer = customServers.DestroyServer
local joinable = customServers.ButtonHolder:WaitForChild("Joinable")
local friends = customServers.ButtonHolder:FindFirstChild("Friends")
keepGuiObjectHidden(friends)
local color = Color3.fromRGB(115, 255, 159)
local color2 = Color3.fromRGB(255, 87, 95)

-- equivalent calls inferred from this helper; original call sites unknown
local function setvaltogglevisual(instance, p)
	if not instance then
		return
	end

	local val = instance:FindFirstChild("val")

	if not val then
		return
	end

	val.Text = p and "TRUE" or "FALSE"
	val.TextColor3 = p and color or color2
end

customServers:WaitForChild("instanceServer")
local serverTemplate = customServers:FindFirstChild("ServerTemplate")

if serverTemplate then
	serverTemplate.Visible = false
end

if serverTemplate then
	serverTemplate:FindFirstChild("RealButton")
end

local v31 = {
	tagButton = customServers.ButtonHolder:FindFirstChild("tag") or customServers.ButtonHolder:FindFirstChild("Tag"),
	passwordButton = customServers.ButtonHolder:FindFirstChild("password") or customServers.ButtonHolder:FindFirstChild("Password"),
	bannerButton = customServers.ButtonHolder:FindFirstChild("banner") or customServers.ButtonHolder:FindFirstChild("Banner"),
	applyButton = customServers:FindFirstChild("Applyserver"),
	valdefaulttext = "NONE",
	valdefaultcolor = Color3.fromRGB(180, 180, 180),
	valsetcolor = Color3.fromRGB(115, 255, 159),
	LastApplied = {
		Name = "",
		ListServer = true,
		FriendsAllowed = false,
		Tag = "",
		HasPassword = false,
		Banner = ""
	},
	PendingPasswordChange = nil,
	tagHandle = nil,
	pwHandle = nil,
	bannerHandle = nil,
	applyLocked = false,
	applyVersion = 0,
	applyIdleText = nil
}
local clones = {}

local function wiredropdownsearchbox(instance, p)
	if not instance then
		return
	end

	instance:GetPropertyChangedSignal("Text"):Connect(function()
		count += 1
		local v32 = count
		local text = tostring(instance.Text or "")

		if #text >= 1 and v13.openMode ~= p then
			v13.setMode(p)
		end

		if p == "country" then
			task.delay(0.15, function()
				if v32 ~= count then
					return
				end

				local v33 = string.lower(text)

				for k, v34 in pairs(clones) do
					local v35 = string.lower(k)
					v34.Visible = v33 == "" or string.find(v35, v33, 1, true) ~= nil
				end
			end)
		end
	end)
end

local searchbox = sortby:FindFirstChild("Searchbox")

if searchbox then
	local v32 = "sort"
	searchbox:GetPropertyChangedSignal("Text"):Connect(function()
		count += 1
		local v33 = count
		local text = tostring(searchbox.Text or "")

		if #text >= 1 and v13.openMode ~= v32 then
			v13.setMode(v32)
		end

		if v32 == "country" then
			task.delay(0.15, function()
				if v33 ~= count then
					return
				end

				local v34 = string.lower(text)

				for k, v35 in pairs(clones) do
					local v36 = string.lower(k)
					v35.Visible = v34 == "" or string.find(v36, v34, 1, true) ~= nil
				end
			end)
		end
	end)
end

local searchbox2 = v13.countriesBtn and v13.countriesBtn:FindFirstChild("Searchbox")

if searchbox2 then
	local v32 = "country"
	searchbox2:GetPropertyChangedSignal("Text"):Connect(function()
		count += 1
		local v33 = count
		local text = tostring(searchbox2.Text or "")

		if #text >= 1 and v13.openMode ~= v32 then
			v13.setMode(v32)
		end

		if v32 == "country" then
			task.delay(0.15, function()
				if v33 ~= count then
					return
				end

				local v34 = string.lower(text)

				for k, v35 in pairs(clones) do
					local v36 = string.lower(k)
					v35.Visible = v34 == "" or string.find(v36, v34, 1, true) ~= nil
				end
			end)
		end
	end)
end

local mainScroller = bg.MainScroller
local serverTemplate2 = script.ServerTemplate
local filterButton = bg.FilterButton
local searchbox3 = searchBarFrame.Searchbox
local activeservers = buttons:FindFirstChild("activeservers") or searchBarFrame:FindFirstChild("activeservers")
local pageamount = buttons:FindFirstChild("pageamount")
local page = pageFrame:FindFirstChild("Page#")
local refresh = pageFrame.Parent.Refresh
local _ = script.FriendTemplate
local ranked = ReplicatedStorage:WaitForChild("Ranked")
local getServerBrowserData = ranked:WaitForChild("GetServerBrowserData")
local defaultsById = {
	Countries = {}
}
local page2 = 1
local v32 = "Server List"
local v33 = "NA"
local v34 = "Unknown"
local v35 = false
local thread = nil
local count2 = 0
local flag = false
local now2 = 0
local v36 = {
	Name = "",
	ListServer = true,
	FriendsAllowed = false,
	IsOwner = false,
	Tag = "",
	Banner = ""
}

local function normalizebannerinput(banner)
	local v37 = tostring(banner or ""):gsub("%s+", "")

	if v37 == "" then
		return ""
	end

	local match = v37:match("^rbxassetid://(%d+)$")

	if match then
		return "rbxassetid://" .. match
	end

	local match2 = v37:match("[?&]id=(%d+)")

	if match2 then
		return "rbxassetid://" .. match2
	end

	if v37:match("^%d+$") then
		return "rbxassetid://" .. v37
	end

	return ""
end

local v37 = false
local count3 = 0
local now3 = 0
local totalCount = 0
local v38 = {}
local v39 = {}
local v40 = nil

local function refreshfriendsset()
	local friends2 = shared and shared.friends

	if friends2 == v40 then
		return
	end

	v40 = friends2
	v39 = {}

	if typeof(friends2) == "table" then
		for _, friend in ipairs(friends2) do
			local v41 = tonumber(friend)

			if v41 then
				v39[v41] = true
			end
		end
	end
end

for _, v41 in ipairs({
	{
		Name = "NOT FULL",
		Id = "NotFull",
		Default = false
	}
}) do
	defaultsById[v41.Id] = v41.Default
end

local refreshServer = customServers:WaitForChild("RefreshServer")
local v41 = "Server List"
local fn
local fn2

local function applyTabFrameVisibility(p)
	local v42 = false

	for k, list in pairs(v6) do
		local visible = k == p

		for i = #list, 1, -1 do
			local v44 = list[i]

			if v44 and v44.Parent then
				v44.Visible = visible

				if visible then
					v42 = true
				end
			else
				table.remove(list, i)
			end
		end
	end

	return v42
end

local loading = bg:FindFirstChild("loading")
local textLabel = loading and loading:FindFirstChildOfClass("TextLabel")
local guiObjects2 = {}

if loading then
	for _, guiObject in ipairs(loading:GetChildren()) do
		if not ((guiObject:IsA("Frame") or guiObject:IsA("ImageLabel")) and guiObject ~= textLabel) then
			continue
		end

		table.insert(guiObjects2, guiObject)
	end

	table.sort(guiObjects2, function(a, b)
		return tostring(a.Name) < tostring(b.Name)
	end)
end

local color3 = Color3.fromRGB(82, 137, 255)
local backgroundTransparency = not loading and 1 or loading.BackgroundTransparency or 1
local textTransparency = not textLabel and 0 or textLabel.TextTransparency or 0
local sizes = {}
local backgroundColor3s = {}
local positions = {}
local backgroundTransparencies = {}
local v44 = { "rbxassetid://97631984908199", "rbxassetid://108687700865434", "rbxassetid://76172048519874" }

for _, v45 in ipairs(guiObjects2) do
	sizes[v45] = v45.Size
	backgroundColor3s[v45] = v45.BackgroundColor3
	positions[v45] = v45.Position
	backgroundTransparencies[v45] = v45.BackgroundTransparency
end

if loading then
	loading.Visible = false
end

local v45 = {
	frame = loading and loading:FindFirstChild("PASSframe"),
	searchBox = nil,
	joinBtn = nil,
	closeBtn = nil,
	joinIdleText = nil,
	joinIdleColor = nil,
	callback = nil,
	locked = false,
	version = 0,
	hiddenSiblings = nil,
	fadeTween = nil,
	GREEN = Color3.fromRGB(115, 255, 159),
	RED = Color3.fromRGB(255, 87, 95)
}

if v45.frame then
	local searchBarFrame2 = v45.frame:FindFirstChild("SearchBarFrame")

	if searchBarFrame2 and searchBarFrame2:FindFirstChild("SearchBox") and searchBarFrame2.SearchBox:IsA("TextBox") then
		v45.searchBox = searchBarFrame2.SearchBox
	else
		for _, textBox in ipairs(v45.frame:GetDescendants()) do
			if not textBox:IsA("TextBox") then
				continue
			end

			v45.searchBox = textBox
			break
		end
	end

	v45.joinBtn = v45.frame:FindFirstChild("join")
	v45.closeBtn = v45.frame:FindFirstChild("close")
	v45.frame.Visible = false

	if v45.searchBox then
		pcall(function()
			v45.searchBox.ClearTextOnFocus = false
		end)
	end

	if v45.joinBtn then
		v45.joinIdleText = (v45.joinBtn:FindFirstChild("TemplateText") or v45.joinBtn).Text
		v45.joinIdleColor = (v45.joinBtn:FindFirstChild("TemplateText") or v45.joinBtn).TextColor3
	end
end

function v45.setJoinText(text, textColor)
	if not v45.joinBtn then
		return
	end

	local templateText = v45.joinBtn:FindFirstChild("TemplateText") or v45.joinBtn
	templateText.Text = text

	if textColor then
		templateText.TextColor3 = textColor
	end
end

function v45.show(callback)
	if not (v45.frame and loading) then
		return
	end

	v45.activePhase = true
	v45.version += 1
	v45.callback = callback
	v45.locked = false
	v45.setJoinText(v45.joinIdleText or "JOIN", v45.joinIdleColor)

	if v45.joinBtn and v45.joinBtn:IsA("GuiButton") then
		v45.joinBtn.Active = true
	end

	if v45.searchBox then
		v45.searchBox.Text = ""
	end

	v45.hiddenSiblings = {}

	for _, guiObject in ipairs(loading:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject ~= v45.frame) then
			continue
		end

		v45.hiddenSiblings[guiObject] = guiObject.Visible
		guiObject.Visible = false
	end

	loading.Visible = true
	v45.frame.Visible = true
	TweenService:Create(loading, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()

	if v45.searchBox then
		pcall(function()
			v45.searchBox:CaptureFocus()
		end)
	end
end

function v45.hide()
	v45.version += 1
	local version = v45.version
	v45.callback = nil
	v45.locked = false

	if v45.frame then
		v45.frame.Visible = false
	end

	if v45.fadeTween then
		v45.fadeTween:Cancel()
		v45.fadeTween = nil
	end

	if not loading then
		v45.activePhase = false
		return
	end

	v45.fadeTween = TweenService:Create(loading, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	})
	v45.fadeTween:Play()
	v45.fadeTween.Completed:Connect(function(p)
		if not (version == v45.version and p == Enum.PlaybackState.Completed) then
			return
		end

		for _, guiObject in ipairs(loading:GetChildren()) do
			if guiObject:IsA("GuiObject") and guiObject ~= v45.frame then
				guiObject.Visible = true
			end
		end

		loading.Visible = false
		loading.BackgroundTransparency = 1
		v45.activePhase = false
	end)
end

if v45.joinBtn then
	v45.joinBtn.Activated:Connect(function()
		if v45.locked or not v45.callback then
			return
		end

		v45.locked = true

		if v45.joinBtn:IsA("GuiButton") then
			v45.joinBtn.Active = false
		end

		local version = v45.version
		task.spawn(function()
			local v46 = 0

			while v45.version == version and v45.locked do
				v46 = (v46 + 1) % 3
				v45.setJoinText("CHECKING" .. string.rep(" .", v46), v45.joinIdleColor)
				task.wait(0.3)
			end
		end)
		local text = v45.searchBox and tostring(v45.searchBox.Text or "") or ""
		local callback = v45.callback
		task.spawn(function()
			pcall(callback, text)
		end)
	end)
end

if v45.closeBtn then
	v45.closeBtn.Activated:Connect(function()
		v45.hide()
	end)
end

function shared.serverlistPasswordPrompt(_, callback)
	if typeof(callback) == "function" then
		v45.show(callback)
	end
end

function shared.serverlistJoinFeedback(p)
	if not (p and v45.callback) then
		return
	end

	local version = v45.version

	if p.ok then
		v45.setJoinText("SUCCESS", v45.GREEN)
		v45.version += 1
		task.delay(0.6, function()
			if version + 1 ~= v45.version then
				return
			end

			if v45.frame then
				v45.frame.Visible = false
			end

			v45.callback = nil
			v45.locked = false
			v45.activePhase = false

			if v45.hiddenSiblings and loading then
				for _, child in ipairs(loading:GetChildren()) do
					if v45.hiddenSiblings[child] ~= nil then
						child.Visible = v45.hiddenSiblings[child]
					end
				end

				v45.hiddenSiblings = nil
			end

			if typeof(shared.serverlistfliptoteleporting) == "function" then
				shared.serverlistfliptoteleporting()
			end
		end)
	else
		local error = string.lower((tostring(p.error or "")))
		local v46 = (string.find(error, "password", 1, true) or string.find(error, "wrong", 1, true) or error == "empty-password") and "WRONG" or "FAILED"
		v45.setJoinText(v46, v45.RED)
		v45.version += 1
		local version2 = v45.version
		task.delay(1.2, function()
			if version2 ~= v45.version then
				return
			end

			v45.setJoinText(v45.joinIdleText or "JOIN", v45.joinIdleColor)
			v45.locked = false

			if v45.joinBtn and v45.joinBtn:IsA("GuiButton") then
				v45.joinBtn.Active = true
			end
		end)
	end
end

local tweens = {}
local flag2 = false
local v46 = "LOADING"
local v47 = false
local v48 = {
	gen = 0,
	lastSfx = 0
}
local v49 = nil
local count4 = 0
local now4 = 0
local flag3 = true

local function cancelloadingfades()
	for _, v50 in ipairs(tweens) do
		v50:Cancel()
	end

	tweens = {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function runtween(loading2, tweenInfo, p)
	local tween = TweenService:Create(loading2, tweenInfo, p)
	tween:Play()
	table.insert(tweens, tween)
	return tween
end

local function setsquarestate(data, p)
	local v50 = sizes[data] or data.Size
	local uDim = positions[data] or data.Position
	local backgroundColor = p and color3 or backgroundColor3s[data] or data.BackgroundColor3
	local uDim2

	if p then
		uDim2 = UDim2.new(v50.X.Scale * 1.25, v50.X.Offset * 1.25, v50.Y.Scale * 1.25, v50.Y.Offset * 1.25)
		local v52 = v50.X.Scale * 0.25
		local v53 = v50.X.Offset * 0.25
		local v54 = v50.Y.Scale * 0.25
		local v55 = v50.Y.Offset * 0.25
		local X = data.AnchorPoint.X
		local Y = data.AnchorPoint.Y
		uDim = UDim2.new(
			uDim.X.Scale + -(v52 / 2) * (1 - 2 * X),
			uDim.X.Offset + -(v53 / 2) * (1 - 2 * X),
			uDim.Y.Scale + -(v54 / 2) * (1 - 2 * Y),
			uDim.Y.Offset + -(v55 / 2) * (1 - 2 * Y)
		)
	else
		uDim2 = v50
	end

	TweenService:Create(data, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = backgroundColor,
		Size = uDim2,
		Position = uDim
	}):Play()
end

local function SetLoading(p)
	if v45 and v45.activePhase then
		return
	end

	v37 = p

	if not loading then
		return
	end

	count4 += 1
	local v50 = count4

	if p then
		if not v49 then
			v49 = {
				mainScroller = mainScroller.Visible,
				customServersFrame = customServers.Visible
			}
			mainScroller.Visible = false
			customServers.Visible = false
		end

		now4 = tick()
		cancelloadingfades()
		loading.Visible = true
		loading.BackgroundTransparency = 1

		if textLabel then
			textLabel.TextTransparency = 1
		end

		for _, v51 in ipairs(guiObjects2) do
			v51.BackgroundTransparency = 1
		end

		local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		runtween(loading, tweenInfo, {
			BackgroundTransparency = backgroundTransparency
		}) -- equivalent call inferred; original call site unknown

		if textLabel then
			local tween = TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = textTransparency
			})
			tween:Play()
			table.insert(tweens, tween)
		end

		for _, v51 in ipairs(guiObjects2) do
			local tween = TweenService:Create(v51, tweenInfo, {
				BackgroundTransparency = backgroundTransparencies[v51] or 0
			})
			tween:Play()
			table.insert(tweens, tween)
		end

		if #guiObjects2 > 0 and not v47 then
			v47 = true
			v48.gen += 1
			local gen = v48.gen
			task.spawn(function()
				local v52 = 1
				local v53 = true

				while v47 and v48.gen == gen do
					for i, v54 in ipairs(guiObjects2) do
						setsquarestate(v54, i == v52)
					end

					if not v53 and shared and typeof(shared.sfx) == "function" then
						local now5 = tick()

						if now5 - v48.lastSfx > 0.18 then
							v48.lastSfx = now5
							local soundId = v44[(v52 - 1) % #v44 + 1]
							pcall(function()
								shared.sfx({
									SoundId = soundId,
									Parent = workspace,
									Volume = 0.35
								}):Play()
							end)
						end
					end

					v52 = v52 % #guiObjects2 + 1
					task.wait(0.35)
					v53 = false
				end
			end)
		end

		if textLabel and not flag2 then
			flag2 = true
			task.spawn(function()
				local v51 = 0

				while flag2 do
					if textLabel.Parent then
						textLabel.Text = v46 .. string.rep(".", v51)
					end

					v51 = (v51 + 1) % 4
					task.wait(0.3)
				end
			end)
		end
	else
		if flag3 then
			local v51 = tick() - now4

			if v51 < 1 then
				task.wait(1 - v51)

				if v50 ~= count4 then
					return
				end
			end

			flag3 = false
		end

		flag2 = false
		v47 = false
		v48.gen += 1
		v46 = "LOADING"

		if v49 then
			mainScroller.Visible = v49.mainScroller
			customServers.Visible = v49.customServersFrame
			v49 = nil
		end

		cancelloadingfades()
		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		runtween(loading, tweenInfo, {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown

		if textLabel then
			local tween = TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			})
			tween:Play()
			table.insert(tweens, tween)
		end

		for _, v52 in ipairs(guiObjects2) do
			local tween = TweenService:Create(v52, tweenInfo, {
				BackgroundTransparency = 1
			})
			tween:Play()
			table.insert(tweens, tween)
		end

		task.delay(0.12, function()
			if v50 ~= count4 then
				return
			end

			loading.Visible = false

			for _, v52 in ipairs(guiObjects2) do
				v52.Size = sizes[v52] or v52.Size
				v52.BackgroundColor3 = backgroundColor3s[v52] or v52.BackgroundColor3
				v52.Position = positions[v52] or v52.Position
			end
		end)
	end
end

v45.setloading = SetLoading

function shared.serverlistfliptoteleporting()
	v46 = "TELEPORTING"
	SetLoading(true)
end

TeleportService.TeleportInitFailed:Connect(function(p, _, _)
	if p ~= localPlayer then
		return
	end

	if localPlayer:GetAttribute("Teleporting") then
		localPlayer:SetAttribute("Teleporting", nil)
	end

	if v45 and v45.activePhase then
		if typeof(shared.serverlistJoinFeedback) == "function" then
			pcall(shared.serverlistJoinFeedback, {
				ok = false,
				error = "teleport-failed"
			})
		end
	else
		SetLoading(false)
	end
end)

local function SetupCategoryButton(child, p)
	if typeof(child) == "string" then
		child = buttons:FindFirstChild(child)
	end

	if not child then
		return
	end

	child.MouseButton1Click:Connect(function()
		if v37 or flag or v41 == p then
			return
		end

		if v45 and v45.callback ~= nil then
			v45.hide()
		end

		playClickSfx() -- equivalent call inferred; original call site unknown

		if v41 then
			v7[v41] = v7[v41] or {}
			v7[v41].page = page2
			v7[v41].totalCount = totalCount
		end

		filterFrame.Visible = false

		if p == "Custom Servers" then
			v41 = "Custom Servers"
			mainScroller.Visible = false
			customServers.Visible = true
			pageFrame.Visible = false
			filterButton.Visible = false
			refresh.Visible = false

			if searchBarFrame and searchBarFrame:FindFirstChild("TextLabel") then
				searchBarFrame.TextLabel.Text = "CUSTOM SERVERS"
			end

			CheckIfOwner()
		elseif p == "Custom Serverlist" then
			v41 = "Custom Serverlist"
			v32 = "Custom Servers"
			mainScroller.Visible = true
			customServers.Visible = false
			pageFrame.Visible = true
			filterButton.Visible = true
			refresh.Visible = true

			if searchBarFrame and searchBarFrame:FindFirstChild("TextLabel") then
				searchBarFrame.TextLabel.Text = "CUSTOM SERVERS"
			end

			local v50 = applyTabFrameVisibility("Custom Serverlist")
			local customServerlist = v7["Custom Serverlist"]

			if v50 then
				if customServerlist then
					page2 = customServerlist.page or 1
					totalCount = customServerlist.totalCount or 0

					if activeservers then
						activeservers.Text = "ACTIVE: " .. totalCount
					end

					if page then
						page.Text = page2 > 1 and tostring(page2) or ""
					end

					fn2(totalCount, page2)
				end
			else
				page2 = 1

				if page then
					page.Text = ""
				end

				count3 += 1
				v37 = false
				now3 = 0
				fn(true)
			end
		elseif p == "Server List" then
			v41 = "Server List"
			v32 = "Server List"
			mainScroller.Visible = true
			customServers.Visible = false
			pageFrame.Visible = true
			filterButton.Visible = true
			refresh.Visible = true

			if searchBarFrame and searchBarFrame:FindFirstChild("TextLabel") then
				searchBarFrame.TextLabel.Text = "SERVER LIST"
			end

			local v50 = applyTabFrameVisibility("Server List")
			local serverList = v7["Server List"]

			if v50 then
				if serverList then
					page2 = serverList.page or 1
					totalCount = serverList.totalCount or 0

					if activeservers then
						activeservers.Text = "ACTIVE: " .. totalCount
					end

					if page then
						page.Text = page2 > 1 and tostring(page2) or ""
					end

					fn2(totalCount, page2)
				end
			else
				page2 = 1

				if page then
					page.Text = ""
				end

				count3 += 1
				v37 = false
				now3 = 0
				fn(true)
			end
		end
	end)
end

local function UpdateFilterVisual(instance, visible)
	local on = instance:FindFirstChild("On")

	if on then
		on.Visible = visible
		on.ImageTransparency = visible and 0 or 1
	end
end

local v50 = {
	selectedcolor = Color3.fromRGB(217, 217, 217),
	selectedtransparency = 0.5,
	tweentime = 0.2,
	origColor = nil,
	origTransparency = nil,
	tweens = {},
	selectionCounter = 0,
	selectionOrder = {}
}

local function tweencountryselected(p, p2)
	if v50.tweens[p] then
		v50.tweens[p]:Cancel()
	end

	local selectedcolor = p2 and v50.selectedcolor or v50.origColor
	local selectedtransparency = p2 and v50.selectedtransparency or v50.origTransparency
	v50.tweens[p] = TweenService:Create(
		p,
		TweenInfo.new(v50.tweentime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			BackgroundColor3 = selectedcolor,
			BackgroundTransparency = selectedtransparency
		}
	)
	v50.tweens[p]:Play()
end

for k, v51 in pairs(v) do
	local clone = script.CountryTemplate:Clone()
	clone.Parent = countryscroller
	local templateText = clone:FindFirstChild("TemplateText")

	if templateText then
		templateText.Text = flagfromcountrycode(v51) .. " " .. k
	end

	clone.Name = k
	local size = clone.Size
	clone.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, size.Y.Offset > 0 and size.Y.Offset or 32)
	clones[k] = clone

	if v50.origColor == nil then
		v50.origColor = clone.BackgroundColor3
		v50.origTransparency = clone.BackgroundTransparency
	end

	local on = clone:FindFirstChild("On")

	if on then
		on.Visible = false
	end

	local imageLabel = clone:FindFirstChild("ImageLabel")

	if imageLabel then
		imageLabel.Visible = false
	end

	local v52 = k
	clone.Activated:Connect(function()
		playClickSfx() -- equivalent call inferred; original call site unknown

		if defaultsById.Countries[v52] then
			defaultsById.Countries[v52] = nil
			v50.selectionOrder[v52] = nil
			tweencountryselected(clone, false)
		else
			defaultsById.Countries[v52] = true
			v50.selectionCounter += 1
			v50.selectionOrder[v52] = v50.selectionCounter
			tweencountryselected(clone, true)
		end
	end)
end

function v13.reorderCountriesBySelection()
	local count5 = 0

	for k, v51 in pairs(clones) do
		if defaultsById.Countries[k] then
			v51.LayoutOrder = v50.selectionOrder[k] or 0
		else
			count5 += 1
			v51.LayoutOrder = count5 + 10000
		end
	end
end

local function formatUptime(p)
	if not p then
		return "0m"
	end

	local v51 = tonumber(p)
	local v52 = math.floor(v51 / 86400)
	local v53 = math.floor(v51 % 86400 / 3600)
	local v54 = math.floor(v51 % 3600 / 60)

	if v52 > 0 then
		return string.format("%dd %dh", v52, v53)
	end

	if v53 > 0 then
		return string.format("%dh %dm", v53, v54)
	end

	return string.format("%dm", v54)
end

local function getMacroRegion(p)
	local v51 = select(1, normalizecountry(p)) or p

	if v51 and v11[v51] then
		return v11[v51]
	end

	local v52 = tostring(v51 or "")
	local v53 = string.upper(v52)

	if v53 == "NA" or v53 == "NORTH AMERICA" then
		return "NA"
	end

	if v53 == "SA" or v53 == "SOUTH AMERICA" then
		return "SA"
	end

	if v53 == "EU" or v53 == "EUROPE" then
		return "EU"
	end

	if v53 == "ASIA" or v53 == "APAC" then
		return "ASIA"
	end

	if v53 == "OCE" or v53 == "OCEANIA" then
		return "OCE"
	end

	if string.find(v52, "United States") then
		return "NA"
	end

	if string.find(v52, "Asia") then
		return "ASIA"
	end

	if string.find(v52, "Europe") then
		return "EU"
	end

	return "NA"
end

local function estimatePing(p)
	if not p or p == "Unknown" then
		return "???", Color3.fromRGB(150, 150, 150)
	end

	local v51 = select(1, normalizecountry(v34)) or v34
	local v52 = select(1, normalizecountry(p)) or p

	if v52 == v51 then
		return v8, Color3.fromRGB(85, 255, 127)
	end

	local macroRegion = getMacroRegion(v52)
	local macroRegion2 = getMacroRegion(v51)
	local v53 = v15[macroRegion2] and v15[macroRegion2][macroRegion] or 200
	local v54 = v8 + v53
	local color4 = Color3.fromRGB(85, 255, 127)

	if v54 > 100 then
		color4 = Color3.fromRGB(255, 255, 127)
	end

	if v54 > 180 then
		color4 = Color3.fromRGB(255, 85, 85)
	end

	return v54, color4
end

local function RefreshLocalRegion()
	local serverRegion = workspace:GetAttribute("ServerRegion") or localPlayer:GetAttribute("ServerRegion") or "United States"
	local v51 = select(1, normalizecountry(serverRegion)) or tostring(serverRegion)
	v34 = v51
	v33 = getMacroRegion(v51)
end

fn2 = function(totalCount2, page3)
	local v51 = math.ceil(totalCount2 / 60)
	local v52 = v51 < 1 and 1 or v51

	if pageamount then
		pageamount.Text = "PAGES : " .. v52
	end

	local v53 = {}

	if v52 <= 9 then
		for i = 1, 9 do
			if i <= v52 then
				v53[i] = i
			else
				v53[i] = nil
			end
		end
	else
		v53[1] = 1
		v53[9] = v52
		local v54 = math.max(2, page3 - 3)
		local v55 = math.min(v52 - 1, page3 + 3)
		local v56 = v54 == 2 and 8 or v55

		if v56 == v52 - 1 then
			v54 = v52 - 7
		end

		local v57 = 2

		for i = v54, v56 do
			v53[v57] = i
			v57 += 1
		end
	end

	for i = 1, 9 do
		local child = pageFrame:FindFirstChild("Page" .. i)

		if not child then
			continue
		end

		local v54 = v53[i]

		if v54 then
			child.Visible = true
			child.Text = tostring(v54)
			local v55 = v54 == page3

			if v55 then
				child.TextColor3 = Color3.new(1, 1, 1)
				child.TextTransparency = 0
			else
				child.TextColor3 = Color3.fromRGB(150, 150, 150)
				child.TextTransparency = 0.3
			end

			local uIStroke = child:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				uIStroke.Enabled = v55
			end

			local selected = child:FindFirstChild("Selected") or child:FindFirstChild("Highlight") or child:FindFirstChild("ActiveIndicator")

			if selected then
				selected.Visible = v55
			end

			child.TextStrokeTransparency = v55 and 0 or 1
		else
			child.Visible = false
		end
	end
end

local function JoinServer(jobId, serverCode, joinCode, password)
	if localPlayer:GetAttribute("Teleporting") then
		return
	end

	local v51 = password == nil

	if v51 then
		v46 = "TELEPORTING"
		SetLoading(true)
	end

	local customServerHandler = ranked:WaitForChild("CustomServerHandler")
	local success, result = pcall(function()
		return customServerHandler:InvokeServer({
			Action = "JoinServer",
			JobId = jobId,
			ServerCode = serverCode,
			JoinCode = joinCode,
			Password = password
		})
	end)

	if v51 then
		if success and result and result.ok then
			task.spawn(function()
				local flag4 = false
				local teleportingChangedConnection = nil
				teleportingChangedConnection = localPlayer:GetAttributeChangedSignal("Teleporting"):Connect(function()
					if localPlayer:GetAttribute("Teleporting") or flag4 then
						return
					end

					flag4 = true

					if teleportingChangedConnection then
						teleportingChangedConnection:Disconnect()
					end

					SetLoading(false)
				end)
				task.delay(4, function()
					if flag4 then
						return
					end

					flag4 = true

					if teleportingChangedConnection then
						teleportingChangedConnection:Disconnect()
					end

					if localPlayer:GetAttribute("Teleporting") then
						localPlayer:SetAttribute("Teleporting", nil)
					end

					SetLoading(false)
				end)
			end)
		else
			SetLoading(false)
		end
	end

	if success and result and result.ok then
		if typeof(shared.serverlistJoinFeedback) == "function" then
			pcall(shared.serverlistJoinFeedback, {
				jobId = jobId,
				serverCode = serverCode,
				joinCode = joinCode,
				ok = true
			})
		end
	else
		localPlayer:SetAttribute("Teleporting", nil)

		if typeof(shared.serverlistJoinFeedback) == "function" then
			pcall(shared.serverlistJoinFeedback, {
				jobId = jobId,
				serverCode = serverCode,
				joinCode = joinCode,
				ok = false,
				error = result and result.error or "join-failed"
			})
		end
	end
end

local function requestpasswordthenjoin(sLServerId, sLServerCode, sLServerJoinCode, serverName2)
	if typeof(shared.serverlistPasswordPrompt) == "function" then
		local v51 = {
			jobId = sLServerId,
			serverCode = sLServerCode,
			joinCode = sLServerJoinCode,
			serverName = serverName2
		}
		local success, _ = pcall(function()
			shared.serverlistPasswordPrompt(v51, function(password)
				if password ~= nil and password ~= "" then
					JoinServer(sLServerId, sLServerCode, sLServerJoinCode, password)
				elseif typeof(shared.serverlistJoinFeedback) == "function" then
					pcall(shared.serverlistJoinFeedback, {
						ok = false,
						error = "empty-password"
					})
				end
			end)
		end)

		if not success then
			return
		end
	end
end

local v51 = {}
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v51[input] = input.Position
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local v52 = v51[input]
	v51[input] = nil

	if not v52 then
		return
	end

	local v53 = input.Position.X - v52.X
	local v54 = input.Position.Y - v52.Y

	if v53 * v53 + v54 * v54 > 100 or v45 and v45.callback ~= nil then
		return
	end

	local position = input.Position
	local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(position.X, position.Y)

	for _, v55 in ipairs(guiObjectsAtPosition) do
		local sLServerId = v55:GetAttribute("SLServerId")

		if not sLServerId then
			continue
		end

		local now5 = tick()

		if now5 - (v38[localPlayer.UserId] or 0) < 0.75 then
			break
		end

		v38[localPlayer.UserId] = now5
		playClickSfx() -- equivalent call inferred; original call site unknown
		local sLServerCode = v55:GetAttribute("SLServerCode") or ""
		local sLServerJoinCode = v55:GetAttribute("SLServerJoinCode") or ""

		if v55:GetAttribute("SLServerHasPassword") ~= true then
			JoinServer(sLServerId, sLServerCode, sLServerJoinCode)
			break
		end

		local serverName2 = v55:FindFirstChild("ServerName")
		requestpasswordthenjoin(
			sLServerId,
			sLServerCode,
			sLServerJoinCode,
			not serverName2 and "" or tostring(serverName2.Text or "")
		)
		break
	end
end)
local flag4 = false
local count5 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function nextcreateuiversion()
	count5 += 1
	v35 = false
	count2 += 1
	return count5
end

local function iscreateuiversionactive(p)
	return count5 == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isteleportflowactive()
	return localPlayer:GetAttribute("Teleporting") == true or localPlayer:GetAttribute("CreatingServer") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getcreateidletext()
	if v36 and v36.IsOwner then
		return "[APPLY CHANGES]"
	end

	return "[CREATE SERVER]"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setcreateidlestate()
	instanceServer.Text = getcreateidletext()
	instanceServer.TextColor3 = Color3.fromRGB(255, 255, 255)
	instanceServer.Active = localPlayer:GetAttribute("Teleporting") ~= true and localPlayer:GetAttribute("CreatingServer") ~= true
end

local function SetButtonState(p)
	local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
	flag = true
	flag4 = true
	instanceServer.Active = false
	v35 = true

	if p == "CREATING" then
		instanceServer.Text = "Creating server"
		instanceServer.TextColor3 = Color3.fromRGB(200, 200, 200)
		task.spawn(function()
			local v53 = 0

			while v35 and count5 == count52 do
				v53 = v53 % 3 + 1
				instanceServer.Text = "Creating server" .. string.rep(".", v53)
				task.wait(0.3)
			end
		end)
	elseif p == "APPLYING" then
		instanceServer.Text = "Applying changes"
		instanceServer.TextColor3 = Color3.fromRGB(200, 200, 200)
		task.spawn(function()
			local v53 = 0

			while v35 and count5 == count52 do
				v53 = v53 % 3 + 1
				instanceServer.Text = "Applying changes" .. string.rep(".", v53)
				task.wait(0.3)
			end
		end)
	elseif p == "TELEPORTING" then
		instanceServer.Text = "Teleporting"
		instanceServer.TextColor3 = Color3.fromRGB(85, 255, 127)
		task.spawn(function()
			local v53 = 0

			while v35 and count5 == count52 do
				v53 = v53 % 3 + 1
				instanceServer.Text = "Teleporting" .. string.rep(".", v53)
				task.wait(0.3)
			end
		end)
	elseif p == "FAILED" then
		v35 = false
		instanceServer.Text = "Failed"
		instanceServer.TextColor3 = Color3.fromRGB(255, 85, 85)
		task.delay(2, function()
			if count5 ~= count52 then
				return
			end

			flag = false
			flag4 = false

			if isteleportflowactive() then
				instanceServer.Active = false
				return
			end

			setcreateidlestate() -- equivalent call inferred; original call site unknown
		end)
	elseif p == "SUCCESS" then
		v35 = false
		instanceServer.Text = "Success!"
		instanceServer.TextColor3 = Color3.fromRGB(85, 255, 127)
		task.delay(1.5, function()
			if count5 ~= count52 then
				return
			end

			flag = false
			flag4 = false

			if isteleportflowactive() then
				instanceServer.Active = false
				return
			end

			setcreateidlestate() -- equivalent call inferred; original call site unknown
		end)
	end
end

local function PopulateMyServerRow()
	if not serverTemplate then
		return
	end

	local realButton = serverTemplate:FindFirstChild("RealButton")

	if not realButton then
		return
	end

	local visible = workspace:GetAttribute("CustomServerOwnerId") == localPlayer.UserId
	local v53 = nil

	if not visible then
		local customServerData = localPlayer:GetAttribute("CustomServerData")

		if customServerData then
			local success, result = pcall(function()
				return HttpService:JSONDecode(customServerData)
			end)

			if success and result and result.ownsServer then
				v53 = result
			end
		end
	end

	local serverName2 = visible and workspace:GetAttribute("ServerName") or not v53 and "My Server" or v53.serverName or "My Server"
	local serverJoinCode = visible and workspace:GetAttribute("ServerJoinCode") or not v53 and "????" or v53.joinCode or "????"
	local visible2 = visible and workspace:GetAttribute("ServerHasPassword") == true and true or v53 and v53.hasPassword == true
	local text = ""

	if visible then
		local serverTags = workspace:GetAttribute("ServerTags")

		if typeof(serverTags) == "string" and serverTags ~= "" then
			local success, result = pcall(function()
				return HttpService:JSONDecode(serverTags)
			end)

			if success and typeof(result) == "table" and result[1] then
				text = tostring(result[1])
			end
		end
	elseif v53 and typeof(v53.tags) == "table" and v53.tags[1] then
		text = tostring(v53.tags[1])
	end

	local v56 = visible and #Players:GetPlayers() or not v53 and 0 or v53.playerCount or 0
	local serverRegion = visible and workspace:GetAttribute("ServerRegion") or "Unknown"
	local serverCity = visible and workspace:GetAttribute("ServerCity") or ""
	local v57, v58, v59 = resolveserverregiondisplay({
		country = serverRegion,
		city = serverCity,
		region = serverRegion
	})
	local _, _ = estimatePing(v58)
	realButton.ServerName.Text = serverName2
	local serverBanner = visible and tostring(workspace:GetAttribute("ServerBanner") or "") or v53 and tostring(v53.banner or "") or ""

	if serverBanner == "" then
		realButton.Image = ({
			"rbxassetid://133795601107199",
			"rbxassetid://117169709077351",
			"rbxassetid://139669726267144",
			"rbxassetid://93030332650834",
			"rbxassetid://89030584766632"
		})[math.random(1, 5)]
	else
		realButton.Image = serverBanner
	end

	if realButton:FindFirstChild("activeplayers") then
		realButton.activeplayers.Text = v56 .. "/" .. 15
	end

	realButton.ServerRegion.Text = v57 .. " " .. v59

	if realButton:FindFirstChild("averagekills") then
		realButton.averagekills.Text = "0"
	end

	if realButton:FindFirstChild("serveridholder") and realButton.serveridholder:FindFirstChild("serverid") then
		local serverid = realButton.serveridholder.serverid

		if visible2 then
			serverJoinCode = serverJoinCode .. " 🔒" or serverJoinCode
		end

		serverid.Text = serverJoinCode
	end

	local tager = realButton:FindFirstChild("tager")

	if tager then
		local visible3 = text ~= ""
		tager.Visible = visible3

		if visible3 then
			local tag = tager:FindFirstChild("tag") or tager:FindFirstChild("Tag") or tager:FindFirstChild("TextLabel")

			if not tag then
				for _, label in ipairs(tager:GetDescendants()) do
					if not label:IsA("TextLabel") then
						continue
					end

					tag = label
					break
				end
			end

			if tag then
				tag.Text = text
			end
		end
	end

	if realButton:FindFirstChild("Currentserver") then
		realButton.Currentserver.Visible = visible
	end

	if realButton:FindFirstChild("ServerAge") then
		realButton.ServerAge.RichText = false
		realButton.ServerAge.Text = visible and formatUptime(math.floor(workspace.DistributedGameTime or 0)) or "—"
	end

	if realButton:FindFirstChild("countryflag") then
		realButton.countryflag.Transparency = 1
	end

	local passwordIcon = realButton:FindFirstChild("passwordIcon")

	if passwordIcon then
		passwordIcon.Visible = visible2
	end

	realButton:SetAttribute("SLServerId", nil)
	realButton:SetAttribute("SLServerCode", nil)
	realButton:SetAttribute("SLServerJoinCode", nil)
	realButton:SetAttribute("SLServerHasPassword", nil)
	serverTemplate.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideMyServerRow()
	if serverTemplate then
		serverTemplate.Visible = false
	end
end

function CheckIfOwner()
	local customServerOwnerId = workspace:GetAttribute("CustomServerOwnerId")
	local v52 = customServerOwnerId ~= nil
	local v53 = customServerOwnerId == localPlayer.UserId
	tostring(game.PrivateServerId or "")
	local _ = game.PrivateServerOwnerId

	if v52 and v53 then
		v36.IsOwner = true
		v36.IsRemoteOwner = false
		local serverJoinCode = workspace:GetAttribute("ServerJoinCode") or "LOADING"
		local serverName2 = workspace:GetAttribute("ServerName") or ""
		instanceServer.Visible = false
		instanceServer.Active = false

		if serverName then
			serverName.Visible = false
		end

		destroyServer.Visible = true
		destroyServer.Active = true
		refreshServer.Visible = true
		refreshServer.Active = true

		if joinable then
			joinable.Visible = true
		end

		keepGuiObjectHidden(friends)

		if v31.applyButton then
			v31.applyButton.Visible = true
		end

		if v31.tagButton then
			v31.tagButton.Visible = true
		end

		if v31.passwordButton then
			v31.passwordButton.Visible = true
		end

		if v31.bannerButton then
			v31.bannerButton.Visible = true
		end

		v36.JoinCode = serverJoinCode
		local searchbox4 = serverName.Searchbox or serverName
		searchbox4.Text = serverName2
		searchbox4.TextEditable = true
		searchbox4.PlaceholderText = serverName2
		v36.Name = serverName2
		local serverListed = workspace:GetAttribute("ServerListed")
		local v54 = joinable
		local v55 = serverListed ~= false
		local val = v54 and v54:FindFirstChild("val")

		if val then
			val.Text = v55 and "TRUE" or "FALSE"
			val.TextColor3 = v55 and color or color2
		end

		local val2 = friends and friends:FindFirstChild("val")

		if val2 then
			val2.Text = "FALSE"
			val2.TextColor3 = color2
		end

		v36.ListServer = serverListed ~= false
		v36.FriendsAllowed = false
		local serverHasPassword = workspace:GetAttribute("ServerHasPassword") == true
		local serverTags = workspace:GetAttribute("ServerTags")
		local tag = ""

		if typeof(serverTags) == "string" and serverTags ~= "" then
			local success, result = pcall(function()
				return HttpService:JSONDecode(serverTags)
			end)

			if success and typeof(result) == "table" and result[1] then
				tag = tostring(result[1])
			end
		end

		local serverBanner = tostring(workspace:GetAttribute("ServerBanner") or "")
		v36.Tag = tag
		v36.Banner = serverBanner
		v31.PendingPasswordChange = nil
		v31.LastApplied.Name = serverName2
		v31.LastApplied.ListServer = serverListed ~= false
		v31.LastApplied.FriendsAllowed = false
		v31.LastApplied.Tag = tag
		v31.LastApplied.Banner = serverBanner
		v31.LastApplied.HasPassword = serverHasPassword

		if v31.tagHandle then
			v31.tagHandle.setValue(tag, tag ~= "")
		end

		if v31.bannerHandle then
			v31.bannerHandle.setValue(serverBanner, serverBanner ~= "")
		end

		if v31.pwHandle then
			v31.pwHandle.setValue(serverHasPassword and "SET" or "", serverHasPassword)
		end

		PopulateMyServerRow()
		return true
	else
		local customServerData = localPlayer:GetAttribute("CustomServerData")

		if customServerData then
			local success, result = pcall(function()
				return HttpService:JSONDecode(customServerData)
			end)

			if success and result and result.ownsServer then
				v36.IsOwner = true
				v36.IsRemoteOwner = true
				v36.JoinCode = result.joinCode or ""
				v36.Name = result.serverName or ""
				v36.ListServer = result.isListed ~= false
				v36.FriendsAllowed = false
				instanceServer.Visible = false
				instanceServer.Active = false
				refreshServer.Visible = false
				refreshServer.Active = false
				destroyServer.Visible = true
				destroyServer.Active = true

				if joinable then
					joinable.Visible = false
				end

				keepGuiObjectHidden(friends)

				if v31.applyButton then
					v31.applyButton.Visible = false
				end

				if v31.tagButton then
					v31.tagButton.Visible = false
				end

				if v31.passwordButton then
					v31.passwordButton.Visible = false
				end

				if v31.bannerButton then
					v31.bannerButton.Visible = false
				end

				if serverName then
					serverName.Visible = false
				end

				local hasPassword = result.hasPassword == true
				local tag = (typeof(result.tags) ~= "table" or not result.tags[1]) and "" or tostring(result.tags[1])
				local banner = tostring(result.banner or "")
				v36.Tag = tag
				v36.Banner = banner
				v31.PendingPasswordChange = nil
				v31.LastApplied.Name = result.serverName or ""
				v31.LastApplied.ListServer = result.isListed ~= false
				v31.LastApplied.FriendsAllowed = false
				v31.LastApplied.Tag = tag
				v31.LastApplied.Banner = banner
				v31.LastApplied.HasPassword = hasPassword

				if v31.tagHandle then
					v31.tagHandle.setValue(tag, tag ~= "")
				end

				if v31.bannerHandle then
					v31.bannerHandle.setValue(banner, banner ~= "")
				end

				if v31.pwHandle then
					v31.pwHandle.setValue(hasPassword and "SET" or "", hasPassword)
				end

				PopulateMyServerRow()
				return true
			else
				v36.IsOwner = false
				v36.IsRemoteOwner = false
				instanceServer.Text = "[CREATE SERVER]"
				instanceServer.Visible = true
				instanceServer.Active = true
				destroyServer.Visible = false
				refreshServer.Visible = false

				if joinable then
					joinable.Visible = true
				end

				keepGuiObjectHidden(friends)

				if v31.applyButton then
					v31.applyButton.Visible = false
				end

				if v31.tagButton then
					v31.tagButton.Visible = true
				end

				if v31.passwordButton then
					v31.passwordButton.Visible = true
				end

				if v31.bannerButton then
					v31.bannerButton.Visible = true
				end

				if serverName then
					serverName.Visible = true
				end

				HideMyServerRow() -- equivalent call inferred; original call site unknown
				v36.Tag = ""
				v36.Banner = ""
				v31.PendingPasswordChange = nil
				v31.LastApplied.Name = ""
				v31.LastApplied.ListServer = true
				v31.LastApplied.FriendsAllowed = false
				v31.LastApplied.Tag = ""
				v31.LastApplied.Banner = ""
				v31.LastApplied.HasPassword = false

				if v31.tagHandle then
					v31.tagHandle.setValue("")
				end

				if v31.bannerHandle then
					v31.bannerHandle.setValue("")
				end

				if v31.pwHandle then
					v31.pwHandle.setValue("")
				end

				local searchbox4 = serverName.Searchbox or serverName
				searchbox4.Text = ""
				searchbox4.TextEditable = true
				searchbox4.PlaceholderText = "Enter Server Name"
				return false
			end
		else
			v36.IsOwner = false
			v36.IsRemoteOwner = false
			instanceServer.Text = "[CREATE SERVER]"
			instanceServer.Visible = true
			instanceServer.Active = true
			destroyServer.Visible = false
			refreshServer.Visible = false

			if joinable then
				joinable.Visible = true
			end

			keepGuiObjectHidden(friends)

			if v31.applyButton then
				v31.applyButton.Visible = false
			end

			if v31.tagButton then
				v31.tagButton.Visible = true
			end

			if v31.passwordButton then
				v31.passwordButton.Visible = true
			end

			if v31.bannerButton then
				v31.bannerButton.Visible = true
			end

			if serverName then
				serverName.Visible = true
			end

			HideMyServerRow() -- equivalent call inferred; original call site unknown
			return false
		end
	end
end

instanceServer.Activated:Connect(function()
	if flag4 or flag or v36.IsRemoteOwner == true then
		return
	end

	local customServerOwnerId = workspace:GetAttribute("CustomServerOwnerId")

	if customServerOwnerId and customServerOwnerId ~= localPlayer.UserId then
		return
	end

	if v45 and v45.callback ~= nil then
		v45.hide()
	end

	playClickSfx() -- equivalent call inferred; original call site unknown
	local customServerHandler = ranked:WaitForChild("CustomServerHandler")
	local searchbox4 = serverName.Searchbox or serverName
	local text = searchbox4.Text

	if v36.IsOwner then
		if tick() - now2 < 5 then
			local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
			instanceServer.Active = false
			flag4 = true
			flag = false
			local v53 = math.ceil(5 - (tick() - now2))
			instanceServer.Text = "Wait " .. v53 .. "s"
			instanceServer.TextColor3 = Color3.fromRGB(255, 200, 100)
			task.delay(v53, function()
				if count5 ~= count52 then
					return
				end

				if isteleportflowactive() then
					instanceServer.Active = false
					return
				end

				instanceServer.Active = true
				flag4 = false
				flag = false
				setcreateidlestate() -- equivalent call inferred; original call site unknown
			end)
		else
			flag4 = true
			flag = true
			local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
			flag = true
			flag4 = true
			instanceServer.Active = false
			v35 = true
			instanceServer.Text = "Applying changes"
			instanceServer.TextColor3 = Color3.fromRGB(200, 200, 200)
			task.spawn(function()
				local v53 = 0

				while v35 and count5 == count52 do
					v53 = v53 % 3 + 1
					instanceServer.Text = "Applying changes" .. string.rep(".", v53)
					task.wait(0.3)
				end
			end)
			local success, result = pcall(function()
				return customServerHandler:InvokeServer({
					Action = "UpdateServer",
					ServerName = text,
					IsListed = v36.ListServer,
					FriendsOnly = false
				})
			end)

			if success and result and result.ok then
				local count53 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
				flag = true
				flag4 = true
				instanceServer.Active = false
				v35 = true
				v35 = false
				instanceServer.Text = "Success!"
				instanceServer.TextColor3 = Color3.fromRGB(85, 255, 127)
				task.delay(1.5, function()
					if count5 ~= count53 then
						return
					end

					flag = false
					flag4 = false

					if isteleportflowactive() then
						instanceServer.Active = false
						return
					end

					setcreateidlestate() -- equivalent call inferred; original call site unknown
				end)
				v36.Name = text
				searchbox4.PlaceholderText = text
			else
				local count53 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
				instanceServer.Text = result and result.error or "Failed to update"
				instanceServer.TextColor3 = Color3.fromRGB(255, 85, 85)
				task.delay(2, function()
					if count5 ~= count53 then
						return
					end

					flag4 = false
					flag = false

					if isteleportflowactive() then
						instanceServer.Active = false
						return
					end

					instanceServer.Active = true
					setcreateidlestate() -- equivalent call inferred; original call site unknown
				end)
			end

			now2 = tick()
		end
	elseif text == "" or text:match("^%s*$") then
		local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
		instanceServer.Text = "Enter a server name"
		instanceServer.TextColor3 = Color3.fromRGB(255, 200, 100)
		task.delay(2, function()
			if count5 ~= count52 then
				return
			end

			if isteleportflowactive() then
				instanceServer.Active = false
				return
			end

			setcreateidlestate() -- equivalent call inferred; original call site unknown
		end)
	else
		flag4 = true
		flag = true
		localPlayer:SetAttribute("CreatingServer", true)
		count5 += 1
		v35 = false
		count2 += 1
		instanceServer.Text = "WAITING..."
		instanceServer.TextColor3 = Color3.fromRGB(200, 200, 200)
		instanceServer.Active = false

		if v31.tagHandle then
			v31.tagHandle.collapse()
		end

		if v31.pwHandle then
			v31.pwHandle.collapse()
		end

		if v31.bannerHandle then
			v31.bannerHandle.collapse()
		end

		local tag = v36.Tag or ""
		local tags = tag == "" and {} or { tag } or {}
		local pendingPasswordChange = v31.PendingPasswordChange

		if typeof(pendingPasswordChange) ~= "string" or pendingPasswordChange == "" then
			pendingPasswordChange = nil
		end

		local v53 = normalizebannerinput(v36.Banner or "")
		local success, result = pcall(function()
			local v55 = {
				Action = "CreateServer",
				ServerName = text,
				IsListed = v36.ListServer,
				FriendsOnly = false,
				Tags = tags,
				Password = pendingPasswordChange,
				Banner = 0
			}
			local banner

			if v53 ~= "" then
				banner = v53 or nil
			end

			v55.Banner = banner
			return customServerHandler:InvokeServer(v55)
		end)

		if not (success and result and result.ok) then
			local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
			instanceServer.Text = result and result.error or "Failed to create server"
			instanceServer.TextColor3 = Color3.fromRGB(255, 85, 85)
			flag4 = false
			flag = false
			localPlayer:SetAttribute("CreatingServer", nil)
			instanceServer.Active = true
			task.delay(3, function()
				if count5 ~= count52 then
					return
				end

				if isteleportflowactive() then
					instanceServer.Active = false
					return
				end

				setcreateidlestate() -- equivalent call inferred; original call site unknown
			end)
		end
	end
end)
game.ReplicatedStorage:WaitForChild("Replication").OnClientEvent:Connect(function(p)
	if not p or type(p) ~= "table" then
		return
	end

	local effect = p.Effect

	if effect == "CustomServerTeleporting" then
		count5 += 1
		v35 = false
		count2 += 1
		flag = true
		flag4 = true
		instanceServer.Text = "TELEPORTING..."
		instanceServer.TextColor3 = Color3.fromRGB(85, 255, 127)
		instanceServer.Active = false
	elseif effect == "CustomServerCreationFailed" then
		local reason = p.Reason or "Unknown error"
		local count52 = nextcreateuiversion() -- equivalent call inferred; original call site unknown
		instanceServer.Text = "FAILED: " .. reason
		instanceServer.TextColor3 = Color3.fromRGB(255, 85, 85)
		flag4 = false
		flag = false
		localPlayer:SetAttribute("CreatingServer", nil)
		instanceServer.Active = true
		task.delay(3, function()
			if count5 ~= count52 then
				return
			end

			if isteleportflowactive() then
				instanceServer.Active = false
				return
			end

			setcreateidlestate() -- equivalent call inferred; original call site unknown
		end)
	end
end)
joinable.Activated:Connect(function()
	playClickSfx() -- equivalent call inferred; original call site unknown
	v36.ListServer = not v36.ListServer
	setvaltogglevisual(joinable, v36.ListServer) -- equivalent call inferred; original call site unknown
end)
setvaltogglevisual(joinable, true)
setvaltogglevisual(friends, false);
(function(guiObject, text)
	if not guiObject then
		return
	end

	if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
		guiObject.Text = text
		return
	end

	for _, guiObject2 in ipairs(guiObject:GetChildren()) do
		if not (guiObject2.Name ~= "val" and (guiObject2:IsA("TextLabel") or guiObject2:IsA("TextButton"))) then
			continue
		end

		guiObject2.Text = text
		break
	end
end)(joinable, "LISTED")
customServers.Visible = false
v36.Tag = ""

local function wireValTextboxToggle(instance, p)
	if not instance then
		return nil
	end

	local textBox = instance:FindFirstChildWhichIsA("TextBox")

	if not textBox then
		return nil
	end

	local onCommit = p.onCommit or function(_) end
	pcall(function()
		textBox.ClearTextOnFocus = false
	end)
	textBox.PlaceholderText = v31.valdefaulttext
	textBox.PlaceholderColor3 = v31.valdefaultcolor
	textBox.Text = ""
	textBox.TextColor3 = v31.valdefaultcolor
	local v52 = {
		value = "",
		applied = false
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function paintColor()
		if v52.value == nil or v52.value == "" then
			textBox.TextColor3 = v31.valdefaultcolor
		else
			textBox.TextColor3 = v52.applied and v31.valsetcolor or v31.valdefaultcolor
		end
	end

	local function commitFromBox()
		local text = string.gsub(tostring(textBox.Text or ""), "^%s+", ""):gsub("%s+$", "")

		if text ~= v52.value then
			v52.applied = false
		end

		v52.value = text
		textBox.Text = text
		paintColor() -- equivalent call inferred; original call site unknown
		onCommit(text)
	end

	instance.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		playClickSfx() -- equivalent call inferred; original call site unknown
		textBox:CaptureFocus()
	end)
	textBox.FocusLost:Connect(function(_)
		commitFromBox()
	end)
	return {
		setValue = function(value, p2)
			v52.value = value or ""
			v52.applied = p2 == true
			textBox.Text = v52.value
			paintColor() -- equivalent call inferred; original call site unknown
		end,
		getValue = function()
			return v52.value or ""
		end,
		collapse = function()
			pcall(function()
				textBox:ReleaseFocus()
			end)
			commitFromBox()
		end,
		markApplied = function()
			if v52.value == nil or v52.value == "" then
				v52.applied = false
			else
				v52.applied = true
			end

			paintColor() -- equivalent call inferred; original call site unknown
		end
	}
end

v31.tagHandle = wireValTextboxToggle(v31.tagButton, {
	onCommit = function(tag)
		v36.Tag = tag
	end
})
v31.pwHandle = wireValTextboxToggle(v31.passwordButton, {
	onCommit = function(pendingPasswordChange)
		v31.PendingPasswordChange = pendingPasswordChange
	end
})
v31.bannerHandle = wireValTextboxToggle(v31.bannerButton, {
	onCommit = function(banner)
		v36.Banner = banner
	end
})
local textBox = v31.passwordButton and v31.passwordButton:FindFirstChildWhichIsA("TextBox")

if textBox then
	pcall(function()
		textBox.TextHidden = true
	end)
end

v31.applyTextLabel = v31.applyButton and v31.applyButton:FindFirstChild("TemplateText")

if v31.applyButton and v31.applyTextLabel then
	v31.applyIdleText = v31.applyTextLabel.Text
	local color4 = Color3.fromRGB(115, 255, 159)
	local color5 = Color3.fromRGB(255, 87, 95)
	v31.applyIdleColor = v31.applyTextLabel.TextColor3

	function v31.setApplyText(text, p)
		if p ~= v31.applyVersion then
			return
		end

		v31.applyTextLabel.Text = text
	end

	function v31.tweenApplyColor(textColor, p2)
		if p2 ~= v31.applyVersion then
			return
		end

		TweenService:Create(v31.applyTextLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = textColor
		}):Play()
	end

	function v31.settingsDiffer()
		local v52 = v36
		local lastApplied = v31.LastApplied

		if not (v52.Name == lastApplied.Name and v52.ListServer == lastApplied.ListServer and v52.FriendsAllowed == lastApplied.FriendsAllowed and (v52.Tag or "") == (lastApplied.Tag or "")) then
			return true
		end

		return (v52.Banner or "") ~= (lastApplied.Banner or "") or v31.PendingPasswordChange ~= nil
	end

	function v31.animateApplying(p)
		task.spawn(function()
			local v52 = 0

			while v31.applyVersion == p and v31.applyLocked do
				v52 = (v52 + 1) % 4
				v31.setApplyText("APPLYING" .. string.rep(" .", v52), p)
				task.wait(0.3)
			end
		end)
	end

	function v31.finishWithMessage(p, p2, value, p3)
		if p ~= v31.applyVersion then
			return
		end

		v31.applyVersion += 1
		local applyVersion = v31.applyVersion
		v31.setApplyText(p2, applyVersion)

		if p3 then
			v31.tweenApplyColor(p3, applyVersion)
		end

		task.delay(value or 1, function()
			if applyVersion ~= v31.applyVersion then
				return
			end

			v31.setApplyText(v31.applyIdleText or "APPLY CHANGES", applyVersion)
			v31.tweenApplyColor(v31.applyIdleColor, applyVersion)
			v31.applyLocked = false

			if v31.applyButton:IsA("GuiButton") then
				v31.applyButton.Active = true
			end
		end)
	end

	function v31.finishApplied(p)
		v31.finishWithMessage(p, "APPLIED!", 1, color4)
	end

	function v31.finishFailed(p, value)
		v31.finishWithMessage(p, value or "FAILED", 1.5, color5)
	end

	v31.lastAppliedAt = -1e999
	v31.applyButton.Activated:Connect(function()
		playClickSfx() -- equivalent call inferred; original call site unknown

		if v31.applyLocked or v36.IsRemoteOwner == true then
			return
		end

		if v31.tagHandle then
			v31.tagHandle.collapse()
		end

		if v31.pwHandle then
			v31.pwHandle.collapse()
		end

		if v31.bannerHandle then
			v31.bannerHandle.collapse()
		end

		v31.applyVersion += 1
		local applyVersion = v31.applyVersion
		v31.applyLocked = true

		if v31.applyButton:IsA("GuiButton") then
			v31.applyButton.Active = false
		end

		local v53 = 30 - (tick() - v31.lastAppliedAt)

		if v53 > 0 then
			v31.finishWithMessage(applyVersion, "COOLDOWN : " .. math.ceil(v53), math.min(2, v53), color5)
			return
		end

		if not v31.settingsDiffer() then
			v31.finishWithMessage(applyVersion, "NO CHANGES", 1.2, Color3.fromRGB(255, 200, 100))
			return
		end

		local tag = v36.Tag or ""
		local banner = normalizebannerinput(v36.Banner or "")
		local v55 = {
			Name = v36.Name,
			Listed = v36.ListServer,
			FriendsOnly = false,
			Tag = tag,
			TagsArray = tag == "" and {} or { tag } or {},
			Banner = banner,
			PwChange = v31.PendingPasswordChange
		}
		v31.animateApplying(applyVersion)
		task.spawn(function()
			local customServerHandler = ranked:WaitForChild("CustomServerHandler")
			local success, result = pcall(function()
				return customServerHandler:InvokeServer({
					Action = "UpdateServer",
					ServerName = v55.Name,
					IsListed = v55.Listed,
					FriendsOnly = v55.FriendsOnly,
					Tags = v55.TagsArray,
					Banner = v55.Banner
				})
			end)

			if applyVersion ~= v31.applyVersion then
				return
			end

			if not (success and result and result.ok) then
				v31.finishFailed(applyVersion, "FAILED")
				return
			end

			if v55.PwChange ~= nil then
				local success2, result2 = pcall(function()
					return customServerHandler:InvokeServer({
						Action = "SetPassword",
						Password = v55.PwChange
					})
				end)

				if applyVersion ~= v31.applyVersion then
					return
				end

				if success2 and result2 and result2.ok then
					v31.LastApplied.HasPassword = v55.PwChange ~= ""
					v31.PendingPasswordChange = nil
				else
					v31.finishFailed(applyVersion, "PW FAILED")
					return
				end
			end

			v31.LastApplied.Name = v55.Name
			v31.LastApplied.ListServer = v55.Listed
			v31.LastApplied.FriendsAllowed = v55.FriendsOnly
			v31.LastApplied.Tag = v55.Tag
			v31.LastApplied.Banner = v55.Banner or ""
			v31.lastAppliedAt = tick()
			PopulateMyServerRow()

			if v31.tagHandle then
				v31.tagHandle.markApplied()
			end

			if v31.bannerHandle then
				v31.bannerHandle.markApplied()
			end

			if v55.PwChange ~= nil and v31.pwHandle then
				v31.pwHandle.markApplied()
			end

			v31.finishApplied(applyVersion)
		end)
	end)
end

fn = function(p, p2)
	if v37 then
		return
	end

	local v52 = tick() - now
	local v53 = not (v52 < 1.75) and 0 or 1.75 - v52
	SetLoading(true)
	now3 = tick()
	count3 += 1
	local v54 = count3
	task.spawn(function()
		if v53 > 0 then
			task.wait(v53)

			if v54 ~= count3 then
				return
			end
		end

		local v55 = {}
		local region = "GLOBAL"

		for k, _ in pairs(defaultsById.Countries) do
			table.insert(v55, k)
		end

		if #v55 == 1 then
			region = v55[1]
		end

		local category

		if v41 == "Custom Serverlist" then
			category = "Custom Servers"
		else
			category = "Server List"
		end

		local v58 = {}
		local keys = {}

		for _, v60 in ipairs(v17) do
			if v19[v60] ~= "ANY" then
				table.insert(v58, v60)
			end
		end

		table.sort(v58, function(a, b)
			return (priority[a] or 99) < (priority[b] or 99)
		end)

		for _, by in ipairs(v58) do
			table.insert(keys, {
				By = by,
				Dir = string.lower(v19[by])
			})
		end

		local tags2 = {}

		for k, _ in pairs(v22) do
			table.insert(tags2, k)
		end

		local filters = {
			Countries = defaultsById.Countries,
			Tags = tags2,
			HideFull = v30.pending.hidefull == true,
			HideTagged = v30.pending.hastag == false,
			HidePassword = v30.pending.haspass == false,
			FriendsOnly = false,
			MinKills = minKills,
			MaxKills = maxKills
		}
		local v62 = {
			QueryV2 = true,
			Page = page2,
			Search = searchbox3.Text,
			Category = category,
			Region = region,
			Filters = filters,
			Sort = {
				Keys = keys
			},
			limit = 60,
			notFull = defaultsById.NotFull
		}
		local success, result = pcall(function()
			return getServerBrowserData:InvokeServer(v62)
		end)

		if v54 ~= count3 then
			return
		end

		if success and result and result.ok then
			if p and not p2 then
				local v63 = v6[v41]

				if v63 then
					local v64 = v9[v41] or {}

					for _, v65 in ipairs(v63) do
						if not (v65 and v65.Parent) then
							continue
						end

						v65.Visible = false
						table.insert(v64, v65)
					end

					v9[v41] = v64
					v6[v41] = nil
				end

				mainScroller.CanvasPosition = Vector2.new(0, 0)
			end

			totalCount = result.total or 0

			if activeservers then
				activeservers.Text = "ACTIVE: " .. totalCount
			end

			local count6 = 0
			local count7 = 0

			for _, v63 in ipairs(result.servers or {}) do
				if v63.hasPassword == true then
					count7 += 1
				end

				if typeof(v63.tags) == "table" and #v63.tags > 0 then
					count6 += 1
				end
			end

			table.concat(tags2, ",")
			local v63 = ""

			for k, _ in pairs(defaultsById.Countries or {}) do
				if v63 ~= "" then
					v63 ..= ","
				end

				v63 ..= tostring(k)
			end

			local v64 = math.max(1, tonumber(result.pages) or 1)

			if v64 < page2 then
				page2 = v64

				if page then
					page.Text = ""
				end
			end

			fn2(totalCount, page2)
			local v65 = {
				"rbxassetid://133795601107199",
				"rbxassetid://117169709077351",
				"rbxassetid://139669726267144",
				"rbxassetid://93030332650834",
				"rbxassetid://89030584766632"
			}
			local count8 = 0

			if result.servers and #result.servers > 0 then
				refreshfriendsset()
				local count9 = 0

				for _, server in ipairs(result.servers) do
					if v54 ~= count3 then
						return
					end

					if server.friendsOnly == true then
						local vipOwnerId = tonumber(server.vipOwnerId)

						if vipOwnerId and vipOwnerId > 0 and vipOwnerId ~= localPlayer.UserId and not v39[vipOwnerId] then
							continue
						end
					end

					count8 += 1
					local v66 = v9[v41]
					local clone

					if v66 and #v66 > 0 then
						clone = table.remove(v66)
					else
						clone = serverTemplate2:Clone()
					end

					local realButton = clone.RealButton
					local name = server.name or "Unknown Server"
					local text, v68, v69 = resolveserverregiondisplay(server)
					local _, _ = estimatePing(v68)
					realButton.ServerName.Text = name
					local banner = tostring(server.banner or "")

					if banner == "" or not banner then
						banner = v65[math.random(1, #v65)]
					end

					realButton.Image = banner
					realButton.activeplayers.Text = (server.players or 0) .. "/" .. (server.max or 15)
					realButton.ServerRegion.Text = text

					if realButton:FindFirstChild("averagekills") then
						realButton.averagekills.Text = server.avgKills or "0"
					end

					if realButton:FindFirstChild("serveridholder") and realButton.serveridholder:FindFirstChild("serverid") then
						local joinCode = server.joinCode or "????"
						local serverid = realButton.serveridholder.serverid

						if server.hasPassword == true then
							joinCode = joinCode .. " 🔒" or joinCode
						end

						serverid.Text = joinCode
					end

					local tager = realButton:FindFirstChild("tager")

					if tager then
						local tags = server.tags
						local visible

						if typeof(tags) == "table" then
							visible = #tags > 0
						else
							visible = false
						end

						tager.Visible = visible

						if visible then
							local tag = tager:FindFirstChild("tag")

							if tag then
								local v71 = nil

								if v23 > 0 then
									for _, tag2 in ipairs(tags) do
										if not v22[string.lower((tostring(tag2)))] then
											continue
										end

										v71 = tostring(tag2)
										break
									end
								end

								tag.Text = v71 or tostring(tags[1])
							end
						end
					end

					local visible2 = server.id == game.JobId
					local v71

					if server.mode == "VIP" then
						v71 = tonumber(server.vipOwnerId) == localPlayer.UserId
					else
						v71 = false
					end

					if realButton:FindFirstChild("Currentserver") then
						realButton.Currentserver.Visible = visible2
					end

					if visible2 or v71 then
						clone.LayoutOrder = -1000
						realButton.LayoutOrder = -1000
					else
						clone.LayoutOrder = count8
						realButton.LayoutOrder = count8
					end

					local uptime = tonumber(server.uptime) or 0

					if realButton:FindFirstChild("ServerAge") then
						local text2 = formatUptime(uptime)

						if server.mode == "VIP" and server.vip and server.vip ~= "" then
							text2 ..= ", <stroke color=\"#000000\" joins=\"miter\" thickness=\"1\" transparency=\"0.5\">" .. server.vip .. "</stroke>"
							realButton.ServerAge.RichText = true
						else
							realButton.ServerAge.RichText = false
						end

						realButton.ServerAge.Text = text2
					end

					if realButton:FindFirstChild("countryflag") then
						realButton.countryflag.Transparency = 1
					end

					realButton.ServerRegion.Text = text .. " " .. v69
					local passwordIcon = realButton:FindFirstChild("passwordIcon")

					if passwordIcon then
						passwordIcon.Visible = server.hasPassword == true
					end

					realButton:SetAttribute("SLServerId", server.id)
					realButton:SetAttribute("SLServerCode", server.serverCode or "")
					realButton:SetAttribute("SLServerJoinCode", server.joinCode or "")
					realButton:SetAttribute("SLServerHasPassword", server.hasPassword == true)
					clone:SetAttribute("OwningTab", v41)
					clone.Parent = mainScroller
					clone.Visible = true
					v6[v41] = v6[v41] or {}
					table.insert(v6[v41], clone)
					count9 += 1

					if not (count9 >= 20 and (count9 - 20) % 5 == 0) then
						continue
					end

					task.wait()

					if v54 ~= count3 then
						return
					end
				end
			end

			now = tick()
			SetLoading(false)
		else
			now = tick()
			SetLoading(false)
		end
	end)
end

(function()
	local color4 = Color3.fromRGB(115, 255, 159)
	local color5 = Color3.fromRGB(255, 87, 95)
	local templateText = refreshServer:FindFirstChild("TemplateText") or refreshServer
	local text = templateText.Text
	local textColor3 = templateText.TextColor3
	local count6 = 0
	local flag5 = false
	local now5 = -1e999

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setRefreshText(text2, textColor, p)
		if p ~= count6 then
			return
		end

		templateText.Text = text2

		if textColor then
			templateText.TextColor3 = textColor
		end
	end

	local function tweenColor(textColor, p2)
		if p2 ~= count6 then
			return
		end

		TweenService:Create(templateText, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = textColor
		}):Play()
	end

	local function finalize(p, text2, color6, value)
		if p ~= count6 then
			return
		end

		count6 += 1
		local v52 = count6
		setRefreshText(text2, color6, v52) -- equivalent call inferred; original call site unknown

		if color6 then
			tweenColor(color6, v52)
		end

		task.delay(value or 1, function()
			if v52 ~= count6 then
				return
			end

			setRefreshText(text, textColor3, v52) -- equivalent call inferred; original call site unknown
			tweenColor(textColor3, v52)
			flag5 = false
			refreshServer.Active = true
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function animateRefreshing(p)
		task.spawn(function()
			local v52 = 0

			while count6 == p and flag5 do
				v52 = (v52 + 1) % 3
				setRefreshText("REFRESHING" .. string.rep(" .", v52), nil, p) -- equivalent call inferred; original call site unknown
				task.wait(0.3)
			end
		end)
	end

	refreshServer.Activated:Connect(function()
		playClickSfx() -- equivalent call inferred; original call site unknown

		if flag5 or v36.IsRemoteOwner == true then
			return
		end

		count6 += 1
		local v52 = count6
		flag5 = true
		refreshServer.Active = false
		local v53 = 500 - (tick() - now5)

		if v53 > 0 then
			finalize(v52, "COOLDOWN : " .. math.ceil(v53), color5, math.min(2, v53))
			return
		end

		animateRefreshing(v52) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			local customServerHandler = ranked:WaitForChild("CustomServerHandler")
			local success, result = pcall(function()
				return customServerHandler:InvokeServer({
					Action = "RefreshCode"
				})
			end)

			if v52 ~= count6 then
				return
			end

			if success and result and result.ok then
				now5 = tick()
				v36.JoinCode = result.joinCode
				PopulateMyServerRow()
				finalize(v52, "REFRESHED", color4, 1)
			else
				local error = result and result.error or "Failed to refresh"
				local v54 = tonumber(string.match(tostring(error), "(%d+)"))

				if v54 then
					finalize(v52, "COOLDOWN : " .. v54, color5, 2)
				else
					finalize(v52, string.upper((tostring(error))), color5, 2)
				end
			end
		end)
	end)
end)()
destroyServer.Activated:Connect(function()
	playClickSfx() -- equivalent call inferred; original call site unknown

	if flag or flag4 then
		return
	end

	if destroyServer.Text == "[CONFIRM?]" then
		if thread then
			task.cancel(thread)
			thread = nil
		end

		destroyServer.Text = "[DELETE SERVER]"
		destroyServer.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		flag = true
		flag4 = true
		v35 = false
		instanceServer.Visible = true
		instanceServer.Text = "Destroying server..."
		instanceServer.TextColor3 = Color3.fromRGB(255, 200, 100)
		instanceServer.Active = false
		destroyServer.Active = false
		refreshServer.Active = false
		local customServerHandler = ranked:WaitForChild("CustomServerHandler")
		local success, result = pcall(function()
			return customServerHandler:InvokeServer({
				Action = "DeleteServer"
			})
		end)

		if success and result and result.ok then
			if result.shuttingDown then
				instanceServer.Text = "Server shutting down..."
				instanceServer.TextColor3 = Color3.fromRGB(255, 200, 100)
			else
				instanceServer.Text = "Server destroyed!"
				instanceServer.TextColor3 = Color3.fromRGB(85, 255, 127)
				v36.IsOwner = false
				v36.IsRemoteOwner = false
				localPlayer:SetAttribute("CustomServerData", HttpService:JSONEncode({
					ownsServer = false
				}))
				task.wait(2)

				if workspace:GetAttribute("CustomServerOwnerId") == nil then
					instanceServer.Text = "[CREATE SERVER]"
					instanceServer.TextColor3 = Color3.fromRGB(255, 255, 255)
					instanceServer.Active = true
					destroyServer.Visible = false
					destroyServer.Active = true
					refreshServer.Visible = false
					refreshServer.Active = true

					if joinable then
						joinable.Visible = true
					end

					keepGuiObjectHidden(friends)

					if v31.applyButton then
						v31.applyButton.Visible = false
					end

					if v31.tagButton then
						v31.tagButton.Visible = true
					end

					if v31.passwordButton then
						v31.passwordButton.Visible = true
					end

					if v31.bannerButton then
						v31.bannerButton.Visible = true
					end

					if serverName then
						serverName.Visible = true
					end

					HideMyServerRow() -- equivalent call inferred; original call site unknown
					local searchbox4 = serverName.Searchbox or serverName
					searchbox4.Text = ""
					searchbox4.TextEditable = true
					searchbox4.PlaceholderText = "Enter Server Name"
				end

				flag = false
				flag4 = false
			end
		else
			local error = result and result.error or "Failed to destroy"
			local v52 = error == "You don't own a custom server"
			instanceServer.Text = error
			instanceServer.TextColor3 = Color3.fromRGB(255, 85, 85)
			instanceServer.Active = true
			destroyServer.Active = true
			refreshServer.Active = true
			flag = false
			flag4 = false

			if v52 then
				v36.IsOwner = false
				v36.IsRemoteOwner = false
				localPlayer:SetAttribute("CustomServerData", HttpService:JSONEncode({
					ownsServer = false
				}))

				if thread then
					task.cancel(thread)
					thread = nil
				end

				task.wait(1.5)
				instanceServer.Visible = true
				instanceServer.Active = true
				instanceServer.Text = "[CREATE SERVER]"
				instanceServer.TextColor3 = Color3.fromRGB(255, 255, 255)
				destroyServer.Visible = false
				destroyServer.Active = true
				destroyServer.Text = "[DELETE SERVER]"
				destroyServer.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
				refreshServer.Visible = false
				refreshServer.Active = true

				if joinable then
					joinable.Visible = true
				end

				keepGuiObjectHidden(friends)

				if v31.applyButton then
					v31.applyButton.Visible = false
				end

				if v31.tagButton then
					v31.tagButton.Visible = true
				end

				if v31.passwordButton then
					v31.passwordButton.Visible = true
				end

				if v31.bannerButton then
					v31.bannerButton.Visible = true
				end

				if serverName then
					serverName.Visible = true
				end

				HideMyServerRow() -- equivalent call inferred; original call site unknown
				local searchbox4 = serverName and (serverName.Searchbox or serverName)

				if searchbox4 then
					searchbox4.Text = ""
					searchbox4.TextEditable = true
					searchbox4.PlaceholderText = "Enter Server Name"
				end

				v36.Tag = ""
				v36.Banner = ""
				v31.PendingPasswordChange = nil
				v31.LastApplied.Name = ""
				v31.LastApplied.ListServer = true
				v31.LastApplied.FriendsAllowed = false
				v31.LastApplied.Tag = ""
				v31.LastApplied.Banner = ""
				v31.LastApplied.HasPassword = false

				if v31.tagHandle then
					v31.tagHandle.setValue("", false)
				end

				if v31.bannerHandle then
					v31.bannerHandle.setValue("", false)
				end

				if v31.pwHandle then
					v31.pwHandle.setValue("", false)
				end

				v35 = false
			else
				task.wait(2)
				instanceServer.Text = "[APPLY CHANGES]"
				instanceServer.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	else
		destroyServer.Text = "[CONFIRM?]"
		destroyServer.BackgroundColor3 = Color3.fromRGB(255, 200, 0)

		if thread then
			task.cancel(thread)
		end

		thread = task.delay(2, function()
			destroyServer.Text = "[DELETE SERVER]"
			destroyServer.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
			thread = nil
		end)
	end
end)
workspace:GetAttributeChangedSignal("ServerShuttingDown"):Connect(function()
	if not workspace:GetAttribute("ServerShuttingDown") then
		return
	end

	local playerGui2 = game.Players.LocalPlayer.PlayerGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShutdownUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.Parent = playerGui2
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(0.6, 0, 0.4, 0)
	frame2.Position = UDim2.new(0.2, 0, 0.3, 0)
	frame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.Parent = frame2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -40, 0, 60)
	textLabel2.Position = UDim2.new(0, 20, 0, 20)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "⚠️ SERVER SHUTTING DOWN"
	textLabel2.TextColor3 = Color3.fromRGB(255, 200, 0)
	textLabel2.TextSize = 36
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = frame2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Size = UDim2.new(1, -40, 1, -100)
	textLabel3.Position = UDim2.new(0, 20, 0, 80)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Text = [[
This custom server has been deleted.

You will be teleported to a public server shortly.]]
	textLabel3.TextColor3 = Color3.fromRGB(220, 220, 220)
	textLabel3.TextSize = 24
	textLabel3.Font = Enum.Font.Gotham
	textLabel3.TextWrapped = true
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.TextYAlignment = Enum.TextYAlignment.Top
	textLabel3.Parent = frame2
	task.spawn(function()
		local v52 = ""

		while true do
			local v53 = v52 .. "."
			v52 = #v53 > 3 and "" or v53
			textLabel3.Text = [[
This custom server has been deleted.

You will be teleported to a public server shortly]] .. v52
			task.wait(0.5)
		end
	end)
end)
local playerGui2 = localPlayer.PlayerGui
local Info = require(game.ReplicatedStorage.Info)

function shared.serverlistgui(visible, p)
	local serverlist2 = playerGui2.serverlist:FindFirstChild("Serverlist")

	if not serverlist2 then
		return
	end

	if p then
		return serverlist2.Visible
	end

	if playerGui2.serverlist.Serverlist.Visible then
		shared.virtualcursor()
	else
		Info.hideGUI(playerGui2.serverlist)
		shared.virtualcursor(playerGui2.serverlist)
	end

	if visible == nil then
		serverlist2.Visible = not serverlist2.Visible
	else
		serverlist2.Visible = visible
	end
end

SetupCategoryButton("serverlist", "Server List")
SetupCategoryButton("customservers", "Custom Servers")
SetupCategoryButton("realcustomserverlist", "Custom Serverlist")
searchbox3.FocusLost:Connect(function(p)
	if p or searchbox3.Text == "" then
		if v37 then
			return
		end

		page2 = 1

		if page then
			page.Text = ""
		end

		fn(true)
	end
end);
(function()
	for i = 1, 9 do
		local child = pageFrame:FindFirstChild("Page" .. i)

		if not child then
			continue
		end

		local v52 = child
		child.Activated:Connect(function()
			playClickSfx() -- equivalent call inferred; original call site unknown

			if v37 then
				return
			end

			local text = tonumber(v52.Text)

			if text then
				page2 = text
				fn(true)
			end
		end)
	end
end)()

if page then
	page.FocusLost:Connect(function(p)
		if p then
			if v37 then
				return
			end

			local text = tonumber(page.Text)
			local v52 = math.ceil(totalCount / 60)
			local v53 = v52 < 1 and 1 or v52

			if text then
				local v54 = text < 1 and 1 or text

				if v53 < v54 then
					v54 = v53
				end

				page.Text = tostring(v54)

				if page2 ~= v54 then
					page2 = v54
					fn(true)
				end
			else
				page.Text = ""
			end
		end
	end)
end

(function()
	local serveridbox = bg.serveridbox.serveridbox
	local joinButton = bg.JoinButton
	joinButton.Activated:Connect(function()
		local WAIT_INTERVAL = 1.5
		playClickSfx() -- equivalent call inferred; original call site unknown
		local now5 = tick()
		local v52 = v38[localPlayer.UserId] or 0

		if now5 - v52 < 0.75 then
			joinButton.Text = "WAIT " .. math.ceil(0.75 - (now5 - v52)) .. "s"
		else
			v38[localPlayer.UserId] = now5
			local joinCode = serveridbox.Text:upper():gsub("%s+", "")

			if joinCode == "" or #joinCode < 4 then
				joinButton.Text = "ENTER CODE"
				task.wait(WAIT_INTERVAL)
				joinButton.Text = "JOIN"
			else
				joinButton.Text = "SEARCHING..."
				joinButton.Active = false
				local customServerHandler = ranked:WaitForChild("CustomServerHandler")
				local success, result = pcall(function()
					return customServerHandler:InvokeServer({
						Action = "JoinByCode",
						JoinCode = joinCode
					})
				end)

				if success and result and result.ok then
					joinButton.Text = "JOINING..."
				elseif result and result.error == "password-required" then
					joinButton.Text = "LOCKED"
					task.spawn(function()
						while v45 and v45.callback ~= nil do
							task.wait(0.1)
						end

						if joinButton.Text == "LOCKED" then
							joinButton.Text = "JOIN"
							joinButton.Active = true
						end
					end)

					if typeof(shared.serverlistPasswordPrompt) == "function" then
						shared.serverlistPasswordPrompt({
							joinCode = joinCode
						}, function(password)
							if password == nil or password == "" then
								if typeof(shared.serverlistJoinFeedback) == "function" then
									pcall(shared.serverlistJoinFeedback, {
										ok = false,
										error = "empty-password"
									})
								end

								joinButton.Text = "JOIN"
								joinButton.Active = true
							else
								local success2, result2 = pcall(function()
									return customServerHandler:InvokeServer({
										Action = "JoinByCode",
										JoinCode = joinCode,
										Password = password
									})
								end)
								local ok = success2 and result2 and result2.ok == true

								if typeof(shared.serverlistJoinFeedback) == "function" then
									pcall(shared.serverlistJoinFeedback, {
										ok = ok,
										error = result2 and result2.error or success2 and "" or "request-failed"
									})
								end

								if ok then
									joinButton.Text = "JOINING..."
								else
									joinButton.Text = "LOCKED"
								end
							end
						end)
						return
					end

					joinButton.Text = "PASSWORD REQUIRED"
					task.wait(WAIT_INTERVAL)
					joinButton.Text = "JOIN"
					joinButton.Active = true
				else
					local error = result and result.error or "NOT FOUND"
					joinButton.Text = error
					task.wait(WAIT_INTERVAL)
					joinButton.Text = "JOIN"
					joinButton.Active = true
				end
			end
		end
	end)
end)()
refresh.MouseButton1Click:Connect(function()
	playClickSfx() -- equivalent call inferred; original call site unknown

	if v37 then
		return
	end

	fn(true)
end)
filterButton.MouseButton1Click:Connect(function()
	playClickSfx() -- equivalent call inferred; original call site unknown
	filterFrame.Visible = not filterFrame.Visible
end)
mainScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
filterFrame.Visible = false
serverlist:GetPropertyChangedSignal("Visible"):Connect(function()
	if not serverlist.Visible or v37 then
		return
	end

	if now == 0 or tick() - now >= 30 then
		fn(true)
	end
end)

if serverlist.Visible then
	fn(true)
end

task.spawn(function()
	local lastTime = tick()

	repeat
		task.wait(0.15)
	until workspace:GetAttribute("ServerRegion") or tick() - lastTime >= 4

	RefreshLocalRegion()
	task.wait(1.5)
	local total = 0

	for _ = 1, 5 do
		total += localPlayer:GetNetworkPing()
		task.wait(0.1)
	end

	v8 = math.floor(total / 5 * 1000)

	if v8 < 0 then
		v8 = 0
	end
end)
workspace:GetAttributeChangedSignal("ServerRegion"):Connect(function()
	RefreshLocalRegion()
end)
localPlayer:GetAttributeChangedSignal("ServerRegion"):Connect(function()
	RefreshLocalRegion()
end)

local function fn3()
	if v37 then
		return
	end

	page2 = 1

	if page then
		page.Text = ""
	end

	count3 += 1
	fn(true)
end

(function()
	local v52 = {
		countryscroller,
		filterFrame,
		sortby,
		v13.countriesBtn
	}
	local v53 = {
		"Load",
		"load",
		"LOAD",
		"loadButton",
		"loadbutton",
		"LoadButton"
	}

	for _, v54 in ipairs(v52) do
		if v54 then
			for _, childName in ipairs(v53) do
				local child = v54:FindFirstChild(childName, true)

				if not child then
					continue
				end

				button = child
				break
			end
		end

		if button then
			break
		end
	end

	if not button then
		return
	end

	if button:IsA("GuiButton") then
		button.Activated:Connect(function()
			playClickSfx() -- equivalent call inferred; original call site unknown
			fn3()
		end)
	else
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				playClickSfx() -- equivalent call inferred; original call site unknown
				fn3()
			end
		end)
	end
end)()
task.spawn(function()
	while true do
		task.wait(60)
		local now5 = tick()

		for k, v52 in pairs(v38) do
			if now5 - v52 > 5 then
				v38[k] = nil
			end
		end
	end
end)