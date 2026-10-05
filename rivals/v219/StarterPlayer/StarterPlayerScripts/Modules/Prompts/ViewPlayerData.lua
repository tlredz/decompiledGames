local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local winAffiliationSlot = Players.LocalPlayer.PlayerScripts.UserInterface.WinAffiliationSlot
local rawDataText = Players.LocalPlayer.PlayerScripts.UserInterface.RawDataText
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(name, p)
	assert(typeof(name) == "string", "Argument 1 invalid, expected a string, got " .. tostring(name))
	assert(typeof(p) == "table", "Argument 2 invalid, expected a table, got " .. tostring(p))
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.UsernameText = self.PromptFrame:WaitForChild("Username")
	self.TabsFrame = self.PromptFrame:WaitForChild("Tabs")
	self.RawDataButton = self.TabsFrame:WaitForChild("RawData")
	self.HaveWonAgainstButton = self.TabsFrame:WaitForChild("HaveWonAgainst")
	self.HaveWonWithButton = self.TabsFrame:WaitForChild("HaveWonWith")
	self.PagesFrame = self.PromptFrame:WaitForChild("Pages")
	self.RawDataFrame = self.PagesFrame:WaitForChild("RawData")
	self.RawDataSearchFrame = self.RawDataFrame:WaitForChild("Search")
	self.RawDataSearchBox = self.RawDataSearchFrame:WaitForChild("Box")
	self.RawDataLoadButton = self.RawDataFrame:WaitForChild("Load")
	self.RawDataList = self.RawDataFrame:WaitForChild("List")
	self.RawDataContainer = self.RawDataList:WaitForChild("Container")
	self.RawDataLayout = self.RawDataContainer:WaitForChild("Layout")
	self.HaveWonAgainstFrame = self.PagesFrame:WaitForChild("HaveWonAgainst")
	self.HaveWonAgainstList = self.HaveWonAgainstFrame:WaitForChild("List")
	self.HaveWonAgainstContainer = self.HaveWonAgainstList:WaitForChild("Container")
	self.HaveWonAgainstLayout = self.HaveWonAgainstContainer:WaitForChild("Layout")
	self.HaveWonAgainstEmptyText = self.HaveWonAgainstContainer:WaitForChild("Empty")
	self.HaveWonWithFrame = self.PagesFrame:WaitForChild("HaveWonWith")
	self.HaveWonWithList = self.HaveWonWithFrame:WaitForChild("List")
	self.HaveWonWithContainer = self.HaveWonWithList:WaitForChild("Container")
	self.HaveWonWithLayout = self.HaveWonWithContainer:WaitForChild("Layout")
	self.HaveWonWithEmptyText = self.HaveWonWithContainer:WaitForChild("Empty")
	self._name = name
	self._data = not p and {} or p.RawData or {}
	self._metadata = p and p.Metadata or {}
	self._raw_data_texts = {}
	self:_Init()
	return self
end

function object:SetPage(p2)
	for _, child in pairs(self.PagesFrame:GetChildren()) do
		child.Visible = child.Name == p2
	end
end

function object:_UpdateRawDataSearch()
	local text = string.lower(self.RawDataSearchBox.Text)
	local v = {}

	for k in pairs(self._raw_data_texts) do
		k.Visible = false
		v[k] = string.find(string.lower(k.Text), text) or nil
	end

	local make_children_visible

	make_children_visible = function(k)
		for k2, _raw_data_text in pairs(self._raw_data_texts) do
			if _raw_data_text ~= k then
				continue
			end

			k2.Visible = true
			make_children_visible(k2)
		end
	end

	local function make_ancestors_visible(p2)
		while self._raw_data_texts[p2] ~= true do
			p2 = self._raw_data_texts[p2]
			p2.Visible = true
		end
	end

	for k in pairs(v) do
		k.Visible = true
		make_children_visible(k)

		while self._raw_data_texts[k] ~= true do
			k = self._raw_data_texts[k]
			k.Visible = true
		end
	end
end

function object:_GenerateWinHistory()
	for _, v in pairs({ "HaveWonAgainst", "HaveWonWith" }) do
		local v2 = self[v .. "EmptyText"]
		local parent = self[v .. "Container"]
		local v4 = self[v .. "Button"]
		local v5 = self[v .. "Layout"]
		local v6 = self[v .. "List"]
		local v7 = v
		v4.MouseButton1Click:Connect(function()
			self:SetPage(v7)
		end)
		v5:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			v6.CanvasSize = UDim2.new(0, 0, 0, v5.AbsoluteContentSize.Y)
		end)
		ButtonEffect:Add(v4)
		v2.Visible = true
		v2.Text = "Loading..."
		local v10 = self._data[v] or {}
		local v11 = {}

		for _, v12 in pairs(v10) do
			table.insert(v11, v12[1])
		end

		local userInfos = ComplianceController:GetUserInfos(v11)
		local visible = true

		for k, list in pairs(v10) do
			local v13, v14, v15 = table.unpack(list)
			local userInfo = userInfos[tostring(v13)]
			local text = not userInfo and "[Failed to load user info]" or ComplianceController:UseDisplayNames() and userInfo.DisplayName or userInfo.Username or "[Failed to load user info]"
			local text2 = ("#" .. tostring(v13)) .. ((not userInfo or not userInfo.Username or not ComplianceController:UsernamesAllowed() or userInfo.Username == text) and "" or " @" .. tostring(userInfo.Username) or "")
			local clone = winAffiliationSlot:Clone()
			clone.Picture.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, v13)
			clone.DisplayName.Text = text
			clone.DisplayName.Position = text2 == "" and UDim2.new(0.15, 0, 0.5, 0) or UDim2.new(0.15, 0, 0.4, 0)
			clone.Username.Text = text2
			clone.Username.Visible = text2 ~= ""
			clone.Quantity.Text = Utility:PrettyNumber(v14)
			local quantityLabel = clone.QuantityLabel
			local text3

			if v == "HaveWonWith" then
				text3 = v14 == 1 and "win with them" or "wins with them"
			else
				text3 = v14 == 1 and "win against them" or "wins against them"
			end

			quantityLabel.Text = text3
			clone.LastLogged.Text = not v15 and "" or "last logged " .. Utility:TimeFormat2((math.floor(ServerOsTime:Get() - v15))) .. " ago"
			clone.LayoutOrder = k
			clone.Parent = parent
			visible = false
		end

		v2.Text = "Empty"
		v2.Visible = visible
	end
end

function object:_GenerateRawData()
	self.RawDataLoadButton.Visible = false
	self.RawDataSearchFrame.Visible = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function generate_top_text(layoutOrder, text)
		local clone = rawDataText:Clone()
		clone.Text = text
		clone.LayoutOrder = layoutOrder
		clone.Parent = self.RawDataContainer
	end

	local v = self._data.RedFlags and self._data.RedFlags[#self._data.RedFlags]

	if v then
		generate_top_text(-999, string.format("-- red flag:    %s", (tostring(v.Reason)))) -- equivalent call inferred; original call site unknown
	end

	if self._metadata.DataSize then
		generate_top_text(
			-998,
			string.format(
				"-- data size:    %s bytes    (%s%%)",
				Utility:PrettyNumber(self._metadata.DataSize),
				math.floor(self._metadata.DataSize / 4194304 * 1000) / 10
			)
		) -- equivalent call inferred; original call site unknown
	end

	if self._metadata.RobuxSpent then
		generate_top_text(
			-997,
			string.format(
				"-- robux spent:    %s%s %s",
				self._metadata.TrueRobuxSpentHidden and ">" or "",
				Utility:PrettyNumber(self._metadata.RobuxSpent),
				utf8.char(57346)
			)
		) -- equivalent call inferred; original call site unknown
	end

	generate_top_text(-1, "") -- equivalent call inferred; original call site unknown
	local count = 0

	local function generate_text(p, value, p2, p3)
		local v2 = string.format(typeof(value) == "string" and "\"%s\"" or "%s", (tostring(value)))
		local clone = rawDataText:Clone()
		clone.Text = string.format("%s[\"%s\"] = %s", p2, p, v2) .. ";"
		clone.LayoutOrder = count
		clone.Parent = self.RawDataContainer
		self._raw_data_texts[clone] = p3 or true
		count += 1
	end

	local generate_table

	generate_table = function(items, p, p2, p3)
		local v2 = string.rep(" ", 8 * (p - 1))
		local v3 = string.rep(" ", 8 * p)
		local clone

		if p2 then
			clone = rawDataText:Clone()
			clone.Text = string.format("%s[\"%s\"] = %s", v2, p2, "{")
			clone.LayoutOrder = count
			clone.Parent = self.RawDataContainer
			self._raw_data_texts[clone] = p3 or true
			count += 1
		end

		local flag = true

		for k, item in pairs(items) do
			flag = false

			if typeof(item) == "table" then
				generate_table(item, p + 1, k, clone)
			else
				generate_text(k, item, v3, clone)
			end
		end

		if flag then
			local clone2 = rawDataText:Clone()
			clone2.Text = v3 .. "-- empty"
			clone2.LayoutOrder = count
			clone2.Parent = self.RawDataContainer
			self._raw_data_texts[clone2] = p3 or true
			count += 1
		end

		if p2 then
			local clone2 = rawDataText:Clone()
			clone2.Text = v2 .. "};"
			clone2.LayoutOrder = count
			clone2.Parent = self.RawDataContainer
			self._raw_data_texts[clone2] = p3 or true
			count += 1
		end
	end

	local v2 = {}

	for k in pairs(self._data) do
		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		return Utility:StringLessThan(a, b)
	end)

	for _, v3 in pairs(v2) do
		local v4 = self._data[v3]

		if typeof(v4) == "table" then
			generate_table(v4, 1, v3)
		else
			generate_text(v3, v4, "")
		end
	end

	self.RawDataList.Visible = true
end

function object:_Setup()
	self.UsernameText.Text = "@" .. self._name
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.RawDataLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.RawDataList.CanvasSize = UDim2.new(0, 0, 0, self.RawDataLayout.AbsoluteContentSize.Y)
	end)
	self.RawDataButton.MouseButton1Click:Connect(function()
		self:SetPage("RawData")
	end)
	self.RawDataLoadButton.MouseButton1Click:Connect(function()
		self:_GenerateRawData()
	end)
	self.RawDataSearchBox.FocusLost:Connect(function()
		self:_UpdateRawDataSearch()
	end)
	self:_Setup()
	task.spawn(self._GenerateWinHistory, self)
	self:SetPage("RawData")
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.RawDataButton)
	ButtonEffect:Add(self.RawDataLoadButton)
end

return object