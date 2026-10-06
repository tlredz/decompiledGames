local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Parent.Parent.Controller)
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local potions = backpack:WaitForChild("CategoryFrames"):WaitForChild("Potions")
local utils = potions:WaitForChild("Utils")
local scroll = potions:WaitForChild("List"):WaitForChild("Scroll")
local item = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Item")
local flag = false
local v = {}
local Potions = {
	Interface = backpack
}

local function FilterDataChange(_, _, list)
	if list[1] ~= "List" then
		return true
	end

	local v2 = list[2]

	if not v2 then
		return true
	end

	local v3 = module.Shared.Items.List[v2]
	return v3 ~= nil and v3.Type == "Potions"
end

function Potions.ListRender(text: string, instance)
	local v2 = module.Data.Items.List[text] or 0
	local v3 = module.Shared.Items.List[text]

	if not v3 then
		return
	end

	if not instance:GetAttribute("Loaded") then
		instance:SetAttribute("Loaded", true)
		local v4 = module.Button:Create(instance.Main, "Default")
		v4:BindFunction("Click", function()
			local currentItem = instance:GetAttribute("CurrentItem")

			if not currentItem then
				return
			end

			if Controller.Mode == "Default" or Controller.Mode == "Selection" then
				local isSelection = Controller.Mode == "Selection"
				local v6 = module.Libs.NeoHover.GetByIdentifier("Items")

				if v6 then
					v6:Click(instance, {
						Name = currentItem,
						IsSelection = isSelection
					})
				end
			else
				Controller.SelectItem(currentItem)
			end
		end)
		v4:BindOnEnter("Hover", function()
			local currentItem = instance:GetAttribute("CurrentItem")

			if not currentItem then
				return
			end

			local v5 = module.Libs.NeoHover.GetByIdentifier("Items")

			if v5 then
				v5:Open(instance, {
					Name = currentItem,
					IsSelection = Controller.Mode == "Selection"
				})
			end
		end)
		v4:BindOnLeave("Hover", function()
			local v5 = module.Libs.NeoHover.GetByIdentifier("Items")

			if v5 then
				v5:Close(instance)
			end
		end)
	end

	if instance:GetAttribute("CurrentItem") ~= text then
		instance:SetAttribute("CurrentItem", text)
	end

	instance.Main.Title.Text = text
	instance.Main.Icon.Image = v3.Icon
	instance.Main.Amount.Text = module.Utils.Number:Format((math.floor(v2))) .. "x"
	instance.Main.UIGradient:SetAttribute("Rarity", v3.Rarity)
	instance.Visible = true
end

local v2 = module.Utils.VirtualList.New({
	List = scroll,
	Template = item,
	Render = Potions.ListRender
})

function Potions.RefreshInventory()
	potions.Selection.Visible = Controller.Mode == "Selection"
	local text = string.lower(utils.Search.Text)
	local items = {}
	local indexes = {}

	for k, v4 in module.Data.Items.List do
		if v4 <= 0 then
			continue
		end

		local v5 = module.Shared.Items.List[k]

		if not (v5 and v5.Type == "Potions") then
			continue
		end

		local v6 = string.find(string.lower(k), text, 1, true) ~= nil
		local index = module.Shared.Potions.List[k].Index

		if v6 then
			table.insert(items, k)
		end

		indexes[k] = index
	end

	table.sort(items, function(a, b)
		return (indexes[a] or 0) < (indexes[b] or 0)
	end)
	v2.Items = items
	v2:Update()
	v2:RenderAll()
end

function Potions.Start()
	if flag then
		return
	end

	flag = true
	v.DataChanged = module:OnDataChangedDeferred({ "Items" }, Potions.RefreshInventory, FilterDataChange)
	v.TextBoxChanged = utils.Search:GetPropertyChangedSignal("Text"):Connect(Potions.RefreshInventory)
	v.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v2:Update()
		end
	})
	Potions.RefreshInventory()
end

function Potions.Stop()
	if not flag then
		return
	end

	flag = false

	for _, connection in v do
		connection:Disconnect()
	end

	local v3 = module.Libs.NeoHover.GetByIdentifier("Items")

	if v3 then
		v3:Close()
	end

	table.clear(v)
end

function Potions.Init()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Potions.Start()
		else
			Potions.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		potions.Selection.Visible = Controller.Mode == "Selection"
		v2:RenderAll()
	end)
	module.Frame:OnFrameOpened(backpack, function()
		if Controller.Category == script.Name then
			Potions.Start()
		end
	end)
	module.Frame:OnFrameClosed(backpack, function()
		Potions.Stop()
	end)
end

potions.Destroying:Once(function()
	Potions.Stop()
	v2:Destroy()
end)
return Potions