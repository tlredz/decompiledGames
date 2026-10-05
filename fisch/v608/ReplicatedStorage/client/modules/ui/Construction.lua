local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local personalAquariumLayouts = require(ReplicatedStorage.shared.modules.library.personalAquariumLayouts)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local construction = HudController:GetSafeZone():WaitForChild("construction")
local safezone = construction:WaitForChild("constructionFrame"):WaitForChild("scroll"):WaitForChild("safezone")
local textBox = construction:WaitForChild("Search"):WaitForChild("TextBox")
local close = construction:WaitForChild("Close")
local template = script:WaitForChild("template")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Construction/BuyLayout")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/Construction/EquipLayout")
local color = Color3.fromRGB(162, 234, 166)
local color2 = Color3.fromRGB(81, 81, 81)
local color3 = Color3.fromRGB(255, 232, 139)
local color4 = Color3.fromRGB(234, 116, 118)
local maid = Trove.new()
local maid2 = Trove.new()
local clonesByName = {}
local flag = false
local v = {}

local function getOwnedLayouts()
	return DataController.PlayerDataReplicator:Index({ "PersonalAquarium", "OwnedLayouts" })
end

local function getEquippedLayout()
	local index = DataController.PlayerDataReplicator:Index({ "PersonalAquarium", "EquippedLayout" })

	if typeof(index) == "string" and index ~= "" then
		return index
	end

	return personalAquariumLayouts.DEFAULT_LAYOUT_ID
end

local function applyTileState(p: string, p2)
	local equip = p2.layoutFrame.equip
	v[equip] = nil
	local v2 = personalAquariumLayouts.Get(p)

	if not v2 then
		return
	end

	local DEFAULT_LAYOUT_ID = DataController.PlayerDataReplicator:Index({ "PersonalAquarium", "EquippedLayout" })

	if typeof(DEFAULT_LAYOUT_ID) ~= "string" or DEFAULT_LAYOUT_ID == "" then
		DEFAULT_LAYOUT_ID = personalAquariumLayouts.DEFAULT_LAYOUT_ID
	end

	local v3, text

	if p == DEFAULT_LAYOUT_ID then
		v3 = color2
		text = "[Equipped]"
	elseif personalAquariumLayouts.IsOwned(p, getOwnedLayouts()) then
		v3 = color
		text = "[Equip]"
	else
		text = `[{NumberUtils:Comma(v2.Cost)} C$]`
		v3 = color3
	end

	equip.Text = text
	equip.TextColor3 = v3

	if equip:FindFirstChild("border") then
		equip.border.Color = v3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyAllStates()
	for k, v2 in pairs(clonesByName) do
		applyTileState(k, v2)
	end
end

local function armConfirm(p: string, equip, text: string, fn)
	local v2 = v[equip]

	if v2 and v2.ready then
		v[equip] = nil
		fn()
	else
		if v2 then
			return
		end

		local now = os.clock()
		v[equip] = {
			ready = false,
			token = now
		}
		equip.Text = text
		equip.TextColor3 = color4

		if equip:FindFirstChild("border") then
			equip.border.Color = color4
		end

		task.delay(0.1, function()
			local v3 = v[equip]

			if v3 and v3.token == now then
				v3.ready = true
			end
		end)
		task.delay(2, function()
			local v3 = v[equip]

			if v3 and v3.token == now then
				v[equip] = nil
				local v4 = clonesByName[p]

				if v4 then
					applyTileState(p, v4)
				end
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireWithCooldown(object, p: string)
	flag = true
	object:FireServer(p)
	task.delay(0.5, function()
		flag = false
		local v2 = clonesByName[p]

		if v2 then
			applyTileState(p, v2)
		end
	end)
end

local function onTileActivated(name: string, clone)
	if flag then
		return
	end

	local DEFAULT_LAYOUT_ID = DataController.PlayerDataReplicator:Index({ "PersonalAquarium", "EquippedLayout" })

	if typeof(DEFAULT_LAYOUT_ID) ~= "string" or DEFAULT_LAYOUT_ID == "" then
		DEFAULT_LAYOUT_ID = personalAquariumLayouts.DEFAULT_LAYOUT_ID
	end

	if not (name ~= DEFAULT_LAYOUT_ID and personalAquariumLayouts.Get(name)) then
		return
	end

	local equip = clone.layoutFrame.equip
	fx:PlaySound(ui.click2, equip, false)

	if personalAquariumLayouts.IsOwned(name, getOwnedLayouts()) then
		armConfirm(name, equip, "[Clear furniture?]", function()
			fireWithCooldown(remoteEvent2, name) -- equivalent call inferred; original call site unknown
		end)
	else
		armConfirm(name, equip, "[Confirm?]", function()
			fireWithCooldown(remoteEvent, name) -- equivalent call inferred; original call site unknown
		end)
	end
end

local function updateSearch()
	local v2 = textBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")

	for displayName, v3 in pairs(clonesByName) do
		local v4 = personalAquariumLayouts.Get(displayName)

		if v4 then
			displayName = v4.DisplayName or displayName
		end

		local lower = displayName:lower()

		if v2 == "" then
			v3.Visible = true
		else
			v3.Visible = lower:find(v2, 1, true) ~= nil
		end
	end
end

local function buildTile(id: string, entry, layoutOrder: number)
	local clone = template:Clone()
	clone.Name = id
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.layoutName.Text = entry.DisplayName
	clone.layoutFrame.icon.Image = entry.Icon
	local equip = clone.layoutFrame.equip
	maid2:Add(equip.MouseEnter:Connect(function()
		fx:PlaySound(ui.select, equip, false)
	end))
	maid2:Add(equip.Activated:Connect(function()
		onTileActivated(id, clone)
	end))
	applyTileState(id, clone)
	clone.Parent = safezone
	clonesByName[id] = clone
	maid2:Add(clone)
end

local function render()
	maid2:Clean()
	table.clear(clonesByName)
	table.clear(v)

	for i, v2 in ipairs(personalAquariumLayouts.GetSorted()) do
		buildTile(v2.Id, v2.Entry, i)
	end

	updateSearch()
end

local function setupObservers()
	local playerDataReplicator = DataController.PlayerDataReplicator
	playerDataReplicator:WaitForLoaded()
	render()
	maid:Add(playerDataReplicator:Observe({ "PersonalAquarium", "EquippedLayout" }, function(p, p2)
		if not construction.Visible then
			return
		end

		applyAllStates() -- equivalent call inferred; original call site unknown

		if p2 ~= nil and p ~= p2 then
			construction.Visible = false
		end
	end))
	maid:Add(playerDataReplicator:ObserveKeys({ "PersonalAquarium", "OwnedLayouts" }, function()
		if not construction.Visible then
			return
		end

		applyAllStates() -- equivalent call inferred; original call site unknown
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unload()
	maid2:Clean()
	table.clear(clonesByName)
	table.clear(v)
	maid:Clean()
	textBox.Text = ""
	flag = false
end

return {
	init = function()
		construction:GetPropertyChangedSignal("Visible"):Connect(function()
			if construction.Visible then
				setupObservers()
				return
			end

			unload() -- equivalent call inferred; original call site unknown
		end)
		close.Activated:Connect(function()
			fx:PlaySound(ui.click2, close, false)
			construction.Visible = false
		end)
		textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)
	end
}