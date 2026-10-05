local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local faye = require(ReplicatedStorage.Packages.faye)
local CenterPanel = require(script.CenterPanel)
local EffectLadder = require(script.EffectLadder)
local ItemList = require(script.ItemList)
local TargetList = require(script.TargetList)
require(script.Types)
local info = faye.Info(0.2, Enum.EasingStyle.Quad)
local v = {
	Left = { 0, 0.3 },
	SepLeft = 0.315,
	Center = { 0.33, 0.43 },
	SepRight = 0.775,
	Right = { 0.79, 0.21 }
}
local v2 = {
	Left = { 0, 0.26 },
	SepLeft = 0.275,
	Center = { 0.29, 0.43 },
	SepRight = 0.735,
	Right = { 0.75, 0.25 }
}
local uDim = UDim2.fromScale(0.94, 0.92)
local uDim2 = UDim2.fromScale(0.94, 0.96)

-- equivalent calls inferred from this helper; original call sites unknown
local function levelOf(instance)
	local refineLevel = instance:FindFirstChild("RefineLevel")

	if refineLevel == nil then
		return 0
	end

	return refineLevel.Value
end

return function(object)
	local localPlayer = Players.LocalPlayer
	local v3 = Platform_Handler.Platform.Value == "Mobile"
	local v4

	if v3 then
		v4 = v2
	else
		v4 = v
	end

	local data = Utility.GetData(localPlayer)
	local inventory = data.Inventory.Inventory
	local v5 = nil

	local function rescan()
		local v6 = {}

		for _, valueBase in data.Inventory.Toolbar:GetChildren() do
			if valueBase:IsA("ValueBase") and valueBase.Value ~= 0 then
				v6[valueBase.Value] = true
			end
		end

		local v7 = v5.Filter:Get()
		local v8 = {}

		for _, v9 in Utility.HeldEntries(data) do
			local id = v9:FindFirstChild("Id")

			if not (id ~= nil and Refinement.IsRefinable(v9.Name) and v9:FindFirstChild("NoSave") == nil and v9:FindFirstChild("QuestGrant") == nil) then
				continue
			end

			local item = Items[v9.Name]
			local v10 = item.HasCombat == true and "Weapons" or item.Stats == nil and "Rods" or "Gear"

			if not (v7 == "All" or v7 == v10) then
				continue
			end

			local v11 = {
				Name = v9.Name,
				Id = id.Value,
				RefineLevel = levelOf(v9),
				Equipped = v6[id.Value] == true
			}
			table.insert(v8, v11)
		end

		table.sort(v8, function(a, b)
			if a.Equipped ~= b.Equipped then
				return a.Equipped
			end

			if a.RefineLevel ~= b.RefineLevel then
				return a.RefineLevel > b.RefineLevel
			end

			if a.Name == b.Name then
				return a.Id < b.Id
			end

			return a.Name < b.Name
		end)
		v5.Rows:Set(v8)
	end

	local function update()
		if v5.Busy:Get() == true then
			return
		end

		rescan()
		local v6

		if v5.Selected:Get() ~= 0 then
			v6 = Character_info_provider.GetItemFromId(localPlayer, v5.Selected:Get())
		end

		local v7

		if v5.Target:Get() ~= 0 then
			v7 = Character_info_provider.GetItemFromId(localPlayer, v5.Target:Get())
		end

		if v7 == nil or v6 == nil then
			v5.Target:Set(0)
		else
			local v8 = levelOf(v7) -- equivalent call inferred; original call site unknown

			if levelOf(v6) <= v8 then
				v5.Target:Set(0)
			end
		end

		if v5.Selected:Get() == 0 or v6 ~= nil then
			v5.Selected:Refresh()
		else
			v5.Selected:Set(0)
		end
	end

	v5 = {
		Data = data,
		Inventory = inventory,
		Selected = object:Value(0),
		Mode = object:Value("Refine"),
		Target = object:Value(0),
		Filter = object:Value("All"),
		Rows = object:Value({}),
		Busy = object:Value(false),
		UseGuard = false,
		Dim = object:Value(1),
		update = update
	}
	rescan()
	object:Connect(v5.Filter.Changed, rescan)
	local v6 = v5.Selected:Get()
	object:Connect(v5.Selected.Changed, function()
		if v5.Selected:Get() == v6 then
			return
		end

		v6 = v5.Selected:Get()
		v5.Target:Set(0)
	end)

	for _, v7 in Utility.ItemBags(data) do
		object:Connect(v7.ChildAdded, update)
		object:Connect(v7.ChildRemoved, update)
	end

	for _, valueBase in data.Inventory.Toolbar:GetChildren() do
		if valueBase:IsA("ValueBase") then
			object:Connect(valueBase.Changed, rescan)
		end
	end

	for _, v7 in v5.Rows:Get() do
		if not v7.Equipped then
			continue
		end

		v5.Selected:Set(v7.Id)
		break
	end

	if v5.Selected:Get() == 0 and v5.Rows:Get()[1] ~= nil then
		v5.Selected:Set(v5.Rows:Get()[1].Id)
	end

	local v7 = object:Create("Frame")
	local v8 = {
		Name = "RefinementPanel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v9 = object:Create("UIAspectRatioConstraint")({
		AspectRatio = v3 and 2.2 or 1.92
	})
	local v10 = object:Create("Frame")({
		Name = "Plate",
		ZIndex = 0,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = 0.02,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 10)
		}),
		object:Create("UIStroke")({
			BorderOffset = UDim.new(0, -6),
			Color = Color3.new(1, 1, 1),
			Transparency = 0.8
		}),
		object:Create("UIGradient")({
			Rotation = 40,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.04) })
		})
	})
	local v11 = object:Create("Frame")({
		Name = "PanelDim",
		ZIndex = 0,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = object:Animation(v5.Dim, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 10)
		})
	})
	local v12 = object:Create("Frame")
	local v13 = {
		Name = "Columns",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5)
	}
	local size

	if v3 then
		size = uDim2
	else
		size = uDim
	end

	v13.Size = size
	v13.BackgroundTransparency = 1
	do local _values = table.pack(object:Create("Frame")({
	Name = "Left",
	Size = UDim2.fromScale(v4.Left[2], 1),
	BackgroundTransparency = 1,
	ItemList(object, v5)
}), object:Create("Frame")({
	Name = "SepLeft",
	Position = UDim2.fromScale(v4.SepLeft, 0.05),
	Size = UDim2.new(0, 1, 0.9, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.88
}), object:Create("Frame")({
	Name = "Center",
	Position = UDim2.fromScale(v4.Center[1], 0),
	Size = UDim2.fromScale(v4.Center[2], 1),
	BackgroundTransparency = 1,
	CenterPanel(object, v5)
}), object:Create("Frame")({
	Name = "SepRight",
	Position = UDim2.fromScale(v4.SepRight, 0.05),
	Size = UDim2.new(0, 1, 0.9, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.88
}), object:Create("Frame")({
	Name = "Right",
	Position = UDim2.fromScale(v4.Right[1], 0),
	Size = UDim2.fromScale(v4.Right[2], 1),
	BackgroundTransparency = 1,
	object:State(function(callback, p)
		if callback(v5.Mode) == "Transfer" then
			return (TargetList(p, v5))
		end

		return (EffectLadder(p, v5, v3))
	end)
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v9, v10, v11, v12(v13)); for _k = 1, _values.n do v8[_k] = _values[_k] end end
	return v7(v8)
end