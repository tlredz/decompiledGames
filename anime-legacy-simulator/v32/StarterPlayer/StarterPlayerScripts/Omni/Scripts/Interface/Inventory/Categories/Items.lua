local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Parent.Parent.Controller)
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local items = backpack:WaitForChild("CategoryFrames"):WaitForChild("Items")
local utils = items:WaitForChild("Utils")
local scroll = items:WaitForChild("List"):WaitForChild("Scroll")
local main = module.Inset:WaitForChild("Items"):WaitForChild("Main")
local item = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Item")
local flag = false
local v = {}
local v2 = {}
local Items = {
	Interface = backpack
}

local function FilterDataChange(_, _, list)
	if list[1] ~= "List" then
		return true
	end

	local v3 = list[2]

	if not v3 then
		return true
	end

	local v4 = module.Shared.Items.List[v3]

	if not v4 or v4.Type == "Potions" then
		return false
	end

	v2[v3] = true
	return true
end

function Items.ListRender(text: string, instance)
	local v3 = module.Data.Items.List[text] or 0
	local v4 = module.Shared.Items.List[text]

	if not v4 then
		return
	end

	if not instance:GetAttribute("Loaded") then
		instance:SetAttribute("Loaded", true)
		local v5 = module.Button:Create(instance.Main, "Default")
		v5:BindFunction("Click", function()
			local currentItem = instance:GetAttribute("CurrentItem")

			if not currentItem then
				return
			end

			if Controller.Mode == "Default" or Controller.Mode == "Selection" then
				local isSelection = Controller.Mode == "Selection"
				local v7 = module.Libs.NeoHover.GetByIdentifier("Items")

				if v7 then
					v7:Click(instance, {
						Name = currentItem,
						IsSelection = isSelection
					})
				end
			else
				Controller.SelectItem(currentItem)
			end
		end)
		v5:BindOnEnter("Hover", function()
			local currentItem = instance:GetAttribute("CurrentItem")

			if not currentItem then
				return
			end

			local v6 = module.Libs.NeoHover.GetByIdentifier("Items")

			if v6 then
				v6:Open(instance, {
					Name = currentItem,
					IsSelection = Controller.Mode == "Selection"
				})
			end
		end)
		v5:BindOnLeave("Hover", function()
			local v6 = module.Libs.NeoHover.GetByIdentifier("Items")

			if v6 then
				v6:Close(instance)
			end
		end)
	end

	if instance:GetAttribute("CurrentItem") ~= text then
		instance:SetAttribute("CurrentItem", text)
	end

	instance.Main.Title.Text = text
	instance.Main.Icon.Image = v4.Icon
	instance.Main.Amount.Text = module.Utils.Number:Format((math.floor(v3))) .. "x"
	instance.Main.UIGradient:SetAttribute("Rarity", v4.Rarity)
	instance.Visible = true
end

local v3 = module.Utils.VirtualList.New({
	List = scroll,
	Template = item,
	Render = Items.ListRender
})

function Items.RefreshInventory()
	items.Selection.Visible = Controller.Mode == "Selection"
	local text = string.lower(utils.Search.Text)
	local items2 = {}
	local v5 = {}

	for k, v6 in module.Data.Items.List do
		if v6 <= 0 then
			continue
		end

		local v7 = module.Shared.Items.List[k]

		if not (v7 and v7.Type ~= "Potions") then
			continue
		end

		if Controller.Mode == "Selection" and typeof(Controller.ModeParams.NeededProperties) == "table" then
			local v8 = true

			for k2, neededProperty in Controller.ModeParams.NeededProperties do
				if v7[k2] == neededProperty then
					continue
				end

				v8 = false
				break
			end

			if not v8 then
				continue
			end
		end

		local v8 = string.find(string.lower(k), text, 1, true) ~= nil
		local v9 = module.Utils.Order:Rarity(v7.Rarity) * 10

		if v8 then
			table.insert(items2, k)
		end

		v5[k] = v9
	end

	table.sort(items2, function(a, b)
		return (v5[a] or 0) > (v5[b] or 0)
	end)
	v3.Items = items2
	v3:Update()
end

function Items.RefreshFromData()
	Items.RefreshInventory()

	for k in v2 do
		v3:RenderID(k)
	end

	table.clear(v2)
end

function Items.Start()
	if flag then
		return
	end

	flag = true
	v.DataChanged = module:OnDataChangedDeferred({ "Items" }, Items.RefreshFromData, FilterDataChange)
	v.TextBoxChanged = utils.Search:GetPropertyChangedSignal("Text"):Connect(Items.RefreshInventory)
	v.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v3:Update()
		end
	})
	Items.RefreshInventory()
end

function Items.Stop()
	flag = false

	for _, connection in v do
		connection:Disconnect()
	end

	local v4 = module.Libs.NeoHover.GetByIdentifier("Items")

	if v4 then
		v4:Close()
	end

	table.clear(v)
	table.clear(v2)
end

function Items.Init()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Items.Start()
		else
			Items.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		if flag then
			Items.RefreshInventory()
		end

		v3:RenderAll()
	end)
	module.Frame:OnFrameOpened(backpack, function()
		if Controller.Category == script.Name then
			Items.Start()
		end
	end)
	module.Frame:OnFrameClosed(backpack, function()
		Items.Stop()
	end)
end

module.Button:Create(main.SelectFromSelection.Main, "Default"):BindFunction("Click", function()
	if Controller.Mode ~= "Selection" then
		return
	end

	local v4 = module.Libs.NeoHover.GetByIdentifier("Items")
	local name = v4 and v4.Params and v4.Params.Name

	if name then
		Controller.ModeParams.Callback(name)
	end
end)
return Items