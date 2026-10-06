local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Parent.Parent.Controller)
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local mounts = backpack:WaitForChild("CategoryFrames"):WaitForChild("Mounts")
local scroll = mounts:WaitForChild("List"):WaitForChild("Scroll")
local search = mounts:WaitForChild("Utils"):WaitForChild("Search")
local main = module.Inset:WaitForChild("Mounts"):WaitForChild("Main")
local mount = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Mount")
local flag = false
local v = {}
local Mounts = {
	Interface = backpack,
	ListRender = function(currentID: string, instance)
		local v2 = module.Data.Mounts.List[currentID]

		if not v2 then
			return
		end

		local v3 = module.Shared.Mounts.List[v2.Name]

		if not v3 then
			return
		end

		if not instance:GetAttribute("Loaded") then
			instance:SetAttribute("Loaded", true)
			local v4 = module.Button:Create(instance.Main, "Default")
			v4:BindFunction("Click", function()
				local currentID2 = instance:GetAttribute("CurrentID")

				if not currentID2 then
					return
				end

				local v5 = module.Data.Mounts.List[currentID2]

				if not v5 then
					return
				end

				if Controller.Mode == "Default" or Controller.Mode == "Selection" then
					local v6 = Controller.Mode == "Selection"
					local v7 = module.Libs.NeoHover.GetByIdentifier("Mounts")

					if v7 then
						v7:Click(instance, {
							IsFake = v6,
							IsSelection = v6,
							Data = v5
						})
					end
				end
			end)
			v4:BindOnEnter("Hover", function()
				local currentID2 = instance:GetAttribute("CurrentID")

				if not currentID2 then
					return
				end

				local v5 = module.Data.Mounts.List[currentID2]

				if not v5 then
					return
				end

				local v6 = module.Libs.NeoHover.GetByIdentifier("Mounts")

				if v6 then
					local v7 = Controller.Mode == "Selection"
					v6:Open(instance, {
						IsFake = v7,
						IsSelection = v7,
						Data = v5
					})
				end
			end)
			v4:BindOnLeave("Hover", function()
				local v5 = module.Libs.NeoHover.GetByIdentifier("Mounts")

				if v5 then
					v5:Close(instance)
				end
			end)
		end

		if instance:GetAttribute("CurrentID") ~= currentID then
			instance:SetAttribute("CurrentID", currentID)
		end

		local visible = module.Data.Mounts.Equipped[v3.Type] == currentID
		instance.Main.InfoList.LockedIcon.Visible = false
		instance.Main.InfoList.EquippedIcon.Visible = visible
		instance.Main.MiscList.TraitIcon.Visible = false
		instance.Main.Title.Text = v2.Name
		instance.Main.Icon.Image = v3.Icon
		instance.Main.UIGradient:SetAttribute("Rarity", v3.Rarity)
		instance.Visible = true
	end
}
local v2 = module.Utils.VirtualList.New({
	List = scroll,
	Template = mount,
	Render = Mounts.ListRender
})

function Mounts.RefreshInventory(_, _, list)
	mounts.Selection.Visible = Controller.Mode == "Selection"
	local text = string.lower(search.Text)
	local v3 = {}
	local items = {}
	local v5 = {}

	for k, v6 in module.Data.Mounts.List do
		local v7 = module.Shared.Mounts.List[v6.Name]

		if not (v7 and string.find(string.lower(v6.Name), text, 1, true) ~= nil) then
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

			if not v8 or Controller.ModeParams.NeededProperties.Tradeable and not module.Shared.Trade.CanOffer({
				Type = "Mounts",
				ID = k
			}, module.Data) then
				continue
			end
		end

		table.insert(v3, {
			ID = k,
			IsEquipped = module.Data.Mounts.Equipped[v7.Type] == k,
			RarityOrder = module.Utils.Order:Rarity(v7.Rarity)
		})
		table.insert(items, k)
	end

	table.sort(v3, function(a, b)
		local v6 = a.RarityOrder * 10
		local v7 = b.RarityOrder * 10

		if a.IsEquipped then
			v6 += 999
		end

		if b.IsEquipped then
			v7 += 999
		end

		return v7 < v6
	end)

	for k, v6 in v3 do
		v5[v6.ID] = k
	end

	table.sort(items, function(a, b)
		return (v5[a] or 0) < (v5[b] or 0)
	end)
	v2.Items = items
	v2:Update()

	if list then
		local v6 = list[2]

		if v6 then
			v2:RenderID(v6)
		elseif list[1] == "Equipped" then
			v2:RenderAll()
		end
	end
end

function Mounts.Start()
	if flag then
		return
	end

	flag = true
	v.DataChanged = module:OnDataChanged({ "Mounts" }, Mounts.RefreshInventory)
	v.TextBoxChanged = search:GetPropertyChangedSignal("Text"):Connect(Mounts.RefreshInventory)
	v.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v2:Update()
		end
	})
	Mounts.RefreshInventory()
end

function Mounts.Stop()
	flag = false

	for _, connection in v do
		connection:Disconnect()
	end

	local v3 = module.Libs.NeoHover.GetByIdentifier("Mounts")

	if v3 then
		v3:Close()
	end

	table.clear(v)
end

function Mounts.Init()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Mounts.Start()
		else
			Mounts.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		if flag then
			Mounts.RefreshInventory()
		end

		v2:RenderAll()
	end)
	module.Frame:OnFrameOpened(backpack, function()
		if Controller.Category == script.Name then
			Mounts.Start()
		end
	end)
	module.Frame:OnFrameClosed(backpack, function()
		Mounts.Stop()
	end)
end

module.Button:Create(main.SelectFromSelection.Main, "Default"):BindFunction("Click", function()
	if Controller.Mode ~= "Selection" then
		return
	end

	local v3 = module.Libs.NeoHover.GetByIdentifier("Mounts")
	local data = v3 and v3.Params and v3.Params.Data

	if data then
		Controller.ModeParams.Callback(data.Name)
	end
end)
return Mounts