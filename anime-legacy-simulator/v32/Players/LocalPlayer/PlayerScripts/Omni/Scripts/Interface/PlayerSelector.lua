local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local playerSelector = module.Interface:WaitForChild("Frames"):WaitForChild("PlayerSelector")
local main = playerSelector:WaitForChild("Main")
local search = main:WaitForChild("Search")
local scroll = main:WaitForChild("List"):WaitForChild("Scroll")
local playerSelector2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("PlayerSelector")
local placeholderText = search.PlaceholderText
local v = module.Libs.DataContainerClient.New("TradeInfo")
local v2 = nil
local v3 = {}
local thread = nil
local count = 0
local PlayerSelector = {}
local v4 = {
	Build = function(self)
		self.Instance = playerSelector2:Clone()
		self.Instance.Name = tostring(self.UserId)
		self.Instance.Main.UserName.Text = self.UserName
		self.Instance.Main.NickName.Text = self.NickName
		self.Instance.Main.Icon.Main.Image = `rbxthumb://type=AvatarHeadShot&id={self.UserId}&w=150&h=150`
		local v5 = self.Banner and module.Shared.ProfileBanners.List[self.Banner]
		self.Instance.Main.Banner.Image = v5 and v5.Icon or ""
		module.Button:Create(self.Instance.Main.Buttons.Select.Main, "Small"):BindFunction("Click", function()
			if not v2 then
				return
			end

			local callback = v2.Callback
			local userId = self.UserId
			local userName = self.UserName
			PlayerSelector.Stop()
			callback(userId, userName)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		return true
	end
}
local scope = fusion.scoped(fusion, v4)

-- equivalent calls inferred from this helper; original call sites unknown
local function AddRow(userId: number, userName: string, nickName: string, banner: string?)
	if v3[userId] then
		return
	end

	local innerScope = scope:innerScope()
	innerScope.UserId = userId
	innerScope.UserName = userName
	innerScope.NickName = nickName
	innerScope.Banner = banner

	if innerScope:Build() then
		v3[userId] = innerScope
	else
		innerScope:doCleanup()
	end
end

local function ClearRows()
	for _, v5 in v3 do
		v5.Instance:Destroy()
		v5:doCleanup()
	end

	table.clear(v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelGlobalSearch()
	count += 1

	if thread then
		task.cancel(thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasExactRow(p: string)
	for _, v5 in v3 do
		if string.lower(v5.UserName) == p then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CleanSearchText()
	local v5 = string.gsub(string.match(search.Text, "^%s*(.-)%s*$"), "^@", "")
	return string.lower(v5)
end

local function GlobalSearch(flag: boolean)
	CancelGlobalSearch() -- equivalent call inferred; original call site unknown

	if not (v2 and v2.GlobalSearch) then
		return
	end

	local cleanSearchText = CleanSearchText() -- equivalent call inferred; original call site unknown

	if not (#cleanSearchText < 3) then
		-- equivalent call inferred; original call site unknown
		if not HasExactRow(cleanSearchText) then
			local v6 = count
			local globalSearch, v7 = v2.GlobalSearch(cleanSearchText)

			if v6 == count and v2 and CleanSearchText() == cleanSearchText then
				if globalSearch == "Success" and v7 then
					AddRow(v7.UserId, v7.UserName, v7.NickName, v7.Banner) -- equivalent call inferred; original call site unknown
					local v8 = v3[v7.UserId]

					if v8 then
						v8.Instance.LayoutOrder = #module.Services.Players:GetPlayers() + 1
					end
				else
					if not flag then
						return
					end

					module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
						Message = globalSearch == "InCooldown" and "This is in cooldown!" or "This player wasn't found!",
						Color = Color3.new(1, 1, 0)
					})
				end
			end
		end
	end
end

local function RefreshRows()
	CancelGlobalSearch() -- equivalent call inferred; original call site unknown

	if not v2 then
		ClearRows()
		return
	end

	local text = string.lower(search.Text)
	local v5 = {}
	local count2 = 0

	for _, v6 in module.Services.Players:GetPlayers() do
		if not (v6 ~= module.Instance and (not v2.Filter or v2.Filter(v6))) then
			continue
		end

		if not (text == "" or string.find(string.lower(v6.Name), text, 1, true) or string.find(
			string.lower(v6.DisplayName),
			text,
			1,
			true
		)) then
			continue
		end

		v5[v6.UserId] = true
		count2 += 1
		AddRow(v6.UserId, v6.Name, v6.DisplayName, v:GetValue({ v6.UserId, "Banner" })) -- equivalent call inferred; original call site unknown
		local v7 = v3[v6.UserId]

		if v7 then
			v7.Instance.LayoutOrder = count2
		end
	end

	for k, v6 in v3 do
		if v5[k] then
			continue
		end

		v6.Instance:Destroy()
		v6:doCleanup()
		v3[k] = nil
	end

	if not v2.GlobalSearch then
		return
	end

	thread = task.delay(1, function()
		thread = nil
		GlobalSearch(false)
	end)
end

function PlayerSelector.Start(data)
	v2 = {
		Callback = data.Callback,
		Filter = data.Filter,
		GlobalSearch = data.GlobalSearch
	}
	search.PlaceholderText = data.GlobalSearch and "Search Globally..." or placeholderText
	search.Text = ""
	ClearRows()
	RefreshRows()

	if data.PastUI then
		module.Frame:SetPastUI(data.PastUI)
	end

	module.Frame:Open(playerSelector)
end

function PlayerSelector.Stop()
	v2 = nil
	CancelGlobalSearch() -- equivalent call inferred; original call site unknown
	ClearRows()
	module.Frame:Close(playerSelector)
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	if not v2 then
		return
	end

	RefreshRows()
end)
search.FocusLost:Connect(function(flag: boolean)
	if flag and v2 then
		GlobalSearch(true)
	end
end)
module.Frame:OnFrameClosed(playerSelector, function()
	v2 = nil
	CancelGlobalSearch() -- equivalent call inferred; original call site unknown
	ClearRows()
end)
return PlayerSelector