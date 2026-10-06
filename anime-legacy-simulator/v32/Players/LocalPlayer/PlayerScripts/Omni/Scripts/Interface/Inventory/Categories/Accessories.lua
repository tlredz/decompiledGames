local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("@game/ReplicatedStorage/Omni")
local v = {
	"Head",
	"Face",
	"Back",
	"Waist",
	"Body"
}
local _ = {
	Position = createVector(0, -7.5, -7.5),
	Rotation = createVector(0, 0, 0)
}
local _ = {
	Position = createVector(0, -1.25, -4),
	Rotation = createVector(-0, -180, 0)
}
local default2 = {
	Sorting = {
		Rarity = true
	},
	Order = {
		Descending = true
	},
	Rarities = {}
}
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local Controller = require(script.Parent.Parent.Controller)
local backpack = module.Interface:WaitForChild("Frames"):WaitForChild("Backpack")
local accessories = backpack:WaitForChild("CategoryFrames"):WaitForChild("Accessories")
local scroll = accessories:WaitForChild("List"):WaitForChild("Scroll")
local slots = accessories:WaitForChild("Slots")
local search = accessories:WaitForChild("Search")
local default = accessories:WaitForChild("Buttons"):WaitForChild("Default")
local mode = accessories:WaitForChild("Buttons"):WaitForChild("Mode")
local selection = accessories:WaitForChild("Buttons"):WaitForChild("Selection")
local evolve = accessories:WaitForChild("Buttons"):WaitForChild("Evolve")
local evolveAll = accessories:WaitForChild("EvolveAll")
local hideAccessories = accessories:WaitForChild("HideAccessories")
local playerViewport = accessories:WaitForChild("PlayerViewport")
local holder = playerViewport:WaitForChild("Holder")
local main = accessories:WaitForChild("Left"):WaitForChild("Main")
local main2 = accessories:WaitForChild("Right"):WaitForChild("Main")
local accessory = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Accessories"):WaitForChild("Accessory")
local slot = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Inventory"):WaitForChild("Accessories"):WaitForChild("Slot")
local flag = false
local v3 = {}
local current = nil
local v5 = nil
local v6 = nil
local total = 0
local heartbeatConnection = nil
local spring = scope:Spring(scope:Value(1), 10, 1)
local Accessories = {
	Interface = backpack
}

local function GetSolvedFilters()
	local v7 = {}

	if current then
		local rarities = {}

		for k in current.Rarities do
			rarities[k] = true
		end

		v7.Order = next(current.Order) or next(default2.Order)

		if next(rarities) then
			v7.Rarities = rarities
			return v7
		end
	else
		v7.Order = next(default2.Order)
	end

	return v7
end

local function GetDeletableAmount(items)
	local count = 0

	for k in items do
		local v7 = module.Data.Accessories.List[k]

		if not v7 then
			continue
		end

		local v8 = module.Shared.Accessories.List[v7.Name]

		if v8 and v7.Locked ~= true and module.Data.Accessories.Equipped[v8.Type] ~= k then
			count += 1
		end
	end

	return count
end

local function GetEvolveTarget()
	if Controller.Mode ~= "Evolve" then
		return
	end

	local target = Controller.ModeParams.Target
	local selected = target and module.Data.Accessories.List[target]

	if selected then
		return target, selected
	end
end

local function IsEvolveFuel(p: string)
	local target, v7

	if Controller.Mode == "Evolve" then
		target = Controller.ModeParams.Target
		v7 = target and module.Data.Accessories.List[target]

		if not v7 then
			target = nil
			v7 = nil
		end
	end

	if not target or p == target then
		return false
	end

	local v8 = module.Data.Accessories.List[p]

	if not v8 or v8.Name ~= v7.Name then
		return false
	end

	local v9 = module.Shared.Accessories.List[v8.Name]

	if not v9 or (v8.Locked == true or module.Data.Accessories.Equipped[v9.Type] == p) then
		return false
	end

	return module.Shared.Accessories.GetRarity(v8) == module.Shared.Accessories.GetRarity(v7)
end

local function GetEvolveFuelAmount(items)
	local count = 0

	for k in items do
		if IsEvolveFuel(k) then
			count += 1
		end
	end

	return count
end

local function GetEvolveMissingAmount()
	local target, v7

	if Controller.Mode == "Evolve" then
		target = Controller.ModeParams.Target
		v7 = target and module.Data.Accessories.List[target]

		if not v7 then
			target = nil
			v7 = nil
		end
	end

	if not target then
		return 0
	end

	local rarity = module.Shared.Accessories.GetRarity(v7)

	if not module.Shared.Accessories.GetNextRarity(rarity) then
		return 0
	end

	local v8 = math.max(math.floor(module.Shared.Accessories.Rarities[rarity].Required), 2)
	local count = 0

	for k in Controller.SelectedItens do
		if IsEvolveFuel(k) then
			count += 1
		end
	end

	return (math.max(v8 - 1 - count, 0))
end

local function Notify(message: string)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function UpdatePlayerPosition()
	if not v5 then
		return
	end

	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local lerped = (createVector(0, -7.5, -7.5)):Lerp(createVector(0, -1.25, -4), currentSpring)
	local lerped2 = (createVector(0, 0, 0)):Lerp(createVector(-0, -180, 0), currentSpring)
	local v7 = CFrame.new(lerped) * CFrame.Angles(
		math.rad(lerped2.X),
		math.rad(lerped2.Y + total),
		(math.rad(lerped2.Z))
	)
	v5:PivotTo(v7)
end

local function RefreshPlayerAccessories()
	if not v5 then
		return
	end

	local v7

	if not module.Data.Settings["Hide My Accessories"] then
		v7 = {}

		for k, v8 in module.Data.Accessories.Equipped do
			local v9 = module.Data.Accessories.List[v8]

			if v9 then
				v7[k] = {
					Name = v9.Name
				}
			end
		end
	end

	module.Utils.Accessories.EnsureAccessories(v5, v7)
end

local function CreatePlayerModel()
	local humanoidModel = module.Utils.Players.GetHumanoidModel(module.Instance.UserId)

	if not humanoidModel then
		return
	end

	humanoidModel.Parent = holder
	local humanoid = humanoidModel:FindFirstChildOfClass("Humanoid")
	local characterAnimation = module.Utils.Characters.GetCharacterAnimation("Default", "Idle")
	local track

	if characterAnimation and humanoid then
		local v7 = humanoid:FindFirstChildOfClass("Animator")

		if not v7 then
			v7 = Instance.new("Animator")
			v7.Parent = humanoid
		end

		track = v7:LoadAnimation(characterAnimation)
		track.Looped = true

		if flag then
			track:Play()
		end
	end

	if v5 then
		v5:Destroy()
	end

	v5 = humanoidModel
	v6 = track
	total = 0
	spring:setPosition(0)
	RefreshPlayerAccessories()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopRotating()
	if not heartbeatConnection then
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

local function StartRotating(p: number)
	StopRotating() -- equivalent call inferred; original call site unknown
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += p * 120 * dt
		UpdatePlayerPosition()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshHideAccessories()
	hideAccessories.Main.Icon.Visible = module.Data.Settings["Hide My Accessories"] == true
end

function Accessories.RefreshButtons()
	default.Visible = Controller.Mode == "Default"
	selection.Visible = Controller.Mode == "Selection"
	mode.Visible = Controller.Mode ~= "Default" and Controller.Mode ~= "Selection"
	evolveAll.Visible = Controller.Mode == "Default"
	Accessories.RefreshEvolveLabel()
end

function Accessories.RefreshEvolveLabel()
	local evolveMissingAmount = GetEvolveMissingAmount()
	evolve.Visible = Controller.Mode == "Evolve" and evolveMissingAmount > 0
	evolve.Text = `Select {evolveMissingAmount} other {evolveMissingAmount == 1 and "accessory" or "accessories"}`
end

function Accessories.RefreshSlots()
	local v7 = module.Libs.NeoHover.GetByIdentifier("Accessories")

	for _, childName in v do
		local child = slots:FindFirstChild(childName)

		if not child then
			continue
		end

		local v8 = module.Data.Accessories.Equipped[childName]
		local v9 = v8 and module.Data.Accessories.List[v8]
		local v10 = v9 and module.Shared.Accessories.List[v9.Name]
		child.Main.Icon.Image = v10 and v10.Icon or module.Shared.Accessories.Slots[childName] or ""

		if v9 or not v7 or v7.Element ~= child then
			continue
		end

		v7:Close(child, true)
	end
end

function Accessories.BuildSlots()
	for k, childName in v do
		if slots:FindFirstChild(childName) then
			continue
		end

		local clone = slot:Clone()
		clone.Name = childName
		clone.LayoutOrder = k
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0
		uIScale.Parent = clone
		local value = scope:Value(0)
		local spring2 = scope:Spring(value, 15, 1)
		scope:Hydrate(uIScale)({
			Scale = spring2
		})
		local v7 = module.Button:Create(clone.Main, "Default")
		local v8 = childName
		v7:BindFunction("Click", function()
			local v10 = module.Data.Accessories.Equipped[v8]

			if not v10 then
				return
			end

			local v11 = module.Data.Accessories.List[v10]

			if not v11 then
				return
			end

			local v12 = module.Libs.NeoHover.GetByIdentifier("Accessories")

			if v12 then
				v12:Click(clone, {
					IsFake = false,
					Data = v11
				})
			end
		end)
		local v10 = childName
		local parent = clone
		v7:BindOnEnter("Hover", function()
			local v12 = module.Data.Accessories.Equipped[v10]

			if not v12 then
				return
			end

			local v13 = module.Data.Accessories.List[v12]

			if not v13 then
				return
			end

			local v14 = module.Libs.NeoHover.GetByIdentifier("Accessories")

			if v14 then
				v14:Open(parent, {
					IsFake = false,
					Data = v13
				})
			end
		end)
		local parent2 = clone
		v7:BindOnLeave("Hover", function()
			local v13 = module.Libs.NeoHover.GetByIdentifier("Accessories")

			if v13 then
				v13:Close(parent2)
			end
		end)
		clone.Parent = slots
		clone.Visible = true
		value:set(1)
	end
end

function Accessories.ListRender(currentID: string, instance)
	local v7 = module.Data.Accessories.List[currentID]

	if not v7 then
		return
	end

	local v8 = module.Shared.Accessories.List[v7.Name]

	if not v8 then
		return
	end

	if not instance:GetAttribute("Loaded") then
		instance:SetAttribute("Loaded", true)
		local v9 = module.Button:Create(instance.Main, "Default")
		v9:BindFunction("Click", function()
			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v10 = module.Data.Accessories.List[currentID2]

			if not v10 then
				return
			end

			if Controller.Mode == "Default" or Controller.Mode == "Selection" then
				local v11 = Controller.Mode == "Selection"
				local v12 = module.Libs.NeoHover.GetByIdentifier("Accessories")

				if v12 then
					v12:Click(instance, {
						IsFake = v11,
						IsSelection = v11,
						Data = v10
					})
				end
			elseif Controller.Mode == "Delete" or Controller.Mode == "Lock" then
				local v11 = module.Shared.Accessories.List[v10.Name]
				local v12 = v11 and module.Data.Accessories.Equipped[v11.Type] == currentID2

				if Controller.Mode == "Delete" and (v12 or v10.Locked == true) then
					return
				end

				Controller.SelectItem(currentID2)
			elseif Controller.Mode == "Evolve" then
				if not IsEvolveFuel(currentID2) then
					return
				end

				Controller.SelectItem(currentID2)
			end
		end)
		v9:BindOnEnter("Hover", function()
			local currentID2 = instance:GetAttribute("CurrentID")

			if not currentID2 then
				return
			end

			local v10 = module.Data.Accessories.List[currentID2]

			if not v10 then
				return
			end

			local v11 = module.Libs.NeoHover.GetByIdentifier("Accessories")

			if v11 then
				local v12 = Controller.Mode == "Selection"
				v11:Open(instance, {
					IsFake = v12,
					IsSelection = v12,
					Data = v10
				})
			end
		end)
		v9:BindOnLeave("Hover", function()
			local v10 = module.Libs.NeoHover.GetByIdentifier("Accessories")

			if v10 then
				v10:Close(instance)
			end
		end)
	end

	if instance:GetAttribute("CurrentID") ~= currentID then
		instance:SetAttribute("CurrentID", currentID)
	end

	instance.Main.Icon.Image = v8.Icon
	local locked = v7.Locked == true
	local visible = module.Data.Accessories.Equipped[v8.Type] == currentID
	local v10 = Controller.SelectedItens[currentID] == true
	instance.Main.DeleteSelection.Visible = v10 and Controller.Mode == "Delete"
	local unlockSelection = instance.Main.UnlockSelection
	local visible2

	if v10 then
		if Controller.Mode == "Lock" then
			visible2 = locked
		else
			visible2 = false
		end
	else
		visible2 = v10
	end

	unlockSelection.Visible = visible2
	local lockSelection = instance.Main.LockSelection
	local visible3

	if v10 then
		if Controller.Mode == "Lock" then
			visible3 = not locked
		else
			visible3 = false
		end
	else
		visible3 = v10
	end

	lockSelection.Visible = visible3
	local evolveReceiver = instance.Main.EvolveReceiver
	evolveReceiver.Visible = Controller.Mode == "Evolve" and Controller.ModeParams.Target == currentID
	instance.Main.EvolveSender.Visible = v10 and Controller.Mode == "Evolve"
	instance.Main.InfoList.LockedIcon.Visible = locked
	instance.Main.InfoList.EquippedIcon.Visible = visible
	instance.Main.MiscList.TraitIcon.Visible = false
	instance.Main.Title.Text = v7.Name
	instance.Main.UIGradient:SetAttribute("Rarity", module.Shared.Accessories.GetRarity(v7))
	instance.Visible = true
end

local v7 = module.Utils.VirtualList.New({
	List = scroll,
	Template = accessory,
	Render = Accessories.ListRender
})

function Accessories.RefreshInventory(_, _, list)
	local text = string.lower(search.Text)
	local solvedFilters = GetSolvedFilters()
	local v9 = {}
	local items = {}
	local v11 = {}

	for k, v12 in module.Data.Accessories.List do
		local v13 = module.Shared.Accessories.List[v12.Name]

		if not (v13 and string.find(string.lower(v12.Name), text, 1, true) ~= nil) then
			continue
		end

		local rarity = module.Shared.Accessories.GetRarity(v12)

		if not (not solvedFilters.Rarities or solvedFilters.Rarities[rarity]) then
			continue
		end

		table.insert(v9, {
			ID = k,
			IsLocked = v12.Locked == true,
			IsEquipped = module.Data.Accessories.Equipped[v13.Type] == k,
			RarityOrder = module.Utils.Order:Rarity(rarity)
		})
		table.insert(items, k)
	end

	table.sort(v9, function(a, b)
		local v12 = a.RarityOrder * 10
		local v13 = b.RarityOrder * 10

		if solvedFilters.Order == "Ascending" then
			v12 *= -1
			v13 *= -1
		end

		if a.IsLocked then
			v12 += 1
		end

		if a.IsEquipped then
			v12 += 999
		end

		if b.IsLocked then
			v13 += 1
		end

		if b.IsEquipped then
			v13 += 999
		end

		return v13 < v12
	end)

	for k, v12 in v9 do
		v11[v12.ID] = k
	end

	table.sort(items, function(a, b)
		return (v11[a] or 0) < (v11[b] or 0)
	end)
	v7.Items = items
	v7:Update()

	if list then
		local v12 = list[2]

		if v12 then
			v7:RenderID(v12)
		elseif list[1] == "Equipped" then
			for _, v13 in module.Data.Accessories.Equipped do
				v7:RenderID(v13)
			end
		end
	end

	Accessories.RefreshSlots()
end

function Accessories.Start()
	if flag then
		return
	end

	flag = true
	v3.DataChanged = module:OnDataChanged({ "Accessories" }, function(_, _, list)
		Accessories.RefreshInventory()
		Accessories.RefreshEvolveLabel()

		if list[1] == "Equipped" then
			RefreshPlayerAccessories()
		end
	end)
	v3.SettingsChanged = module:OnDataChanged({ "Settings" }, function()
		RefreshHideAccessories() -- equivalent call inferred; original call site unknown
		RefreshPlayerAccessories()
	end)
	v3.TextBoxChanged = search:GetPropertyChangedSignal("Text"):Connect(Accessories.RefreshInventory)
	v3.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = function()
			v7:Update()
		end
	})

	if v5 and v5.Parent then
		total = 0
		spring:setPosition(0)

		if v6 then
			v6:Play()
		end

		RefreshPlayerAccessories()
	else
		task.spawn(CreatePlayerModel)
	end

	RefreshHideAccessories() -- equivalent call inferred; original call site unknown
	Accessories.RefreshButtons()
	Accessories.RefreshInventory()
end

function Accessories.Stop()
	flag = false

	for _, connection in v3 do
		connection:Disconnect()
	end

	table.clear(v3)
	StopRotating() -- equivalent call inferred; original call site unknown

	if v6 then
		v6:Stop()
	end

	local v8 = module.Libs.NeoHover.GetByIdentifier("Accessories")

	if v8 then
		v8:Close()
	end
end

function Accessories.Init()
	local rig = playerViewport:FindFirstChild("Rig")

	if rig then
		rig:Destroy()
	end

	Accessories.BuildSlots()
	Controller.CategoryChanged:Connect(function(p: string)
		if p == script.Name then
			Accessories.Start()
		else
			Accessories.Stop()
		end
	end)
	Controller.ModeChanged:Connect(function()
		Accessories.RefreshButtons()
		v7:RenderAll()
	end)
	Controller.SelectedItensChanged:Connect(function()
		Accessories.RefreshEvolveLabel()
		v7:RenderAll()
	end)
	module.Frame:OnFrameOpened(backpack, function()
		if Controller.Category == script.Name then
			Accessories.Start()
		end
	end)
	module.Frame:OnFrameClosed(backpack, function()
		Accessories.Stop()
	end)
	scope:Observer(spring):onBind(UpdatePlayerPosition)
end

local v8 = module.Button:Create(main, "Default")
v8:BindOnPress("Rotate", function()
	StopRotating() -- equivalent call inferred; original call site unknown
	local v9 = -1
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += v9 * 120 * dt
		UpdatePlayerPosition()
	end)
end)
v8:BindOnRelease("Rotate", function()
	if not heartbeatConnection then
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end)
local v9 = module.Button:Create(main2, "Default")
v9:BindOnPress("Rotate", function()
	StopRotating() -- equivalent call inferred; original call site unknown
	local v10 = 1
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += v10 * 120 * dt
		UpdatePlayerPosition()
	end)
end)
v9:BindOnRelease("Rotate", function()
	if not heartbeatConnection then
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end)
module.Button:Create(hideAccessories.Main, "Default"):BindFunction("Click", function()
	local hideMyAccessories = module.Data.Settings["Hide My Accessories"] == true
	module.Signal:Fire("General", "Settings", "Set", "Hide My Accessories", not hideMyAccessories)
end)
module.Button:Create(default.Delete.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Delete")
end)
module.Button:Create(default.Lock.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Lock")
end)
module.Button:Create(default.Filter.Main, "Default"):BindFunction("Click", function()
	local list = {
		Order = {
			Index = 1,
			Multi = false,
			List = {
				{
					Name = "Descending",
					Text = "Descending"
				},
				{
					Name = "Ascending",
					Text = "Ascending"
				}
			}
		},
		Rarities = {
			Index = 2,
			Multi = true,
			List = {}
		}
	}

	for k, rarity in module.Utils.Order.Rarities do
		local count = 0

		for _, v11 in module.Data.Accessories.List do
			if not (module.Shared.Accessories.List[v11.Name] and module.Shared.Accessories.GetRarity(v11) == rarity) then
				continue
			end

			count += 1
		end

		list.Rarities.List[k] = {
			Name = rarity,
			Rarity = rarity,
			Text = `{rarity} ({count > 0 and `<font color="rgb(50,255,50)">{count}</font>` or "<font color=\"rgb(255,50,50)\">0</font>"})`
		}
	end

	module.Signal:FireSelf("Interface", "Filters", "Start", {
		PastUI = backpack,
		Current = current,
		List = list,
		Default = default2,
		Callback = function(p)
			current = p
			Accessories.RefreshInventory()
		end
	})
end)
module.Button:Create(default.Loadouts.Main, "Default"):BindFunction("Click", function()
	module.Signal:FireSelf("Interface", "AccessoryLoadouts", "Open", backpack)
end)
module.Button:Create(evolveAll.Main, "Default"):BindFunction("Click", function()
	if Controller.Mode ~= "Default" then
		return
	end

	module.Signal:FireSelf("Interface", "Confirmation", "Start", {
		Title = "Evolve All",
		Description = "Evolve all unlocked and unequipped accessories as far as possible? This cannot be undone.",
		ConfirmText = "Evolve",
		CancelText = "Cancel",
		Callback = function(p)
			if not p then
				return
			end

			module.Signal:Fire("General", "Accessories", "EvolveAll")
		end
	})
end)
module.Button:Create(mode.Cancel.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Default")
end)
module.Button:Create(mode.Confirm.Main, "Default"):BindFunction("Click", function()
	local copy = module.Utils.Table:DeepCopy(Controller.SelectedItens)

	if Controller.Mode == "Delete" then
		local deletableAmount = GetDeletableAmount(copy)

		if deletableAmount == 0 then
			return
		end

		module.Signal:FireSelf("Interface", "Confirmation", "Start", {
			Title = "Delete",
			Description = `Permanently delete {deletableAmount} {deletableAmount == 1 and "accessory" or "accessories"}? This cannot be undone.`,
			ConfirmText = "Delete",
			CancelText = "Cancel",
			Callback = function(p)
				if not p or Controller.Mode ~= "Delete" then
					return
				end

				module.Signal:Fire("General", "Accessories", "Delete", copy)
				Controller.SetMode("Default")
			end
		})
	elseif Controller.Mode == "Evolve" then
		local target, v10

		if Controller.Mode == "Evolve" then
			target = Controller.ModeParams.Target
			v10 = target and module.Data.Accessories.List[target]

			if not v10 then
				target = nil
				v10 = nil
			end
		else
			target = nil
		end

		if not target then
			Controller.SetMode("Default")
			return
		end

		local rarity = module.Shared.Accessories.GetRarity(v10)
		local getEvolveResult = module.Shared.Accessories.GetEvolveResult
		local count = 0

		for k in copy do
			if IsEvolveFuel(k) then
				count += 1
			end
		end

		local evolveResult, v12 = getEvolveResult(rarity, count)

		if not (v12 <= 0) then
			module.Signal:FireSelf("Interface", "Confirmation", "Start", {
				Title = "Evolve",
				Description = `Evolve {v10.Name} from {rarity} to {evolveResult} using {v12} {v12 == 1 and "accessory" or "accessories"}? This cannot be undone.`,
				ConfirmText = "Evolve",
				CancelText = "Cancel",
				Callback = function(p)
					if not p or Controller.Mode ~= "Evolve" then
						return
					end

					module.Signal:Fire("General", "Accessories", "Evolve", target, copy)
					Controller.SetMode("Default")
				end
			})
			return
		end

		local evolveMissingAmount = GetEvolveMissingAmount()

		if evolveMissingAmount > 0 then
			Notify(`Select {evolveMissingAmount} more {v10.Name} ({rarity}) to evolve!`)
		else
			Notify(`{v10.Name} can't be evolved any further!`)
		end
	else
		if Controller.Mode == "Lock" then
			module.Signal:Fire("General", "Accessories", "Lock", copy)
		end

		Controller.SetMode("Default")
	end
end)
module.Button:Create(mode.SelectAll.Main, "Default"):BindFunction("Click", function()
	local v10 = {}

	for k, v11 in module.Data.Accessories.List do
		if Controller.SelectedItens[k] then
			continue
		end

		local v12 = module.Shared.Accessories.List[v11.Name]

		if not v12 then
			continue
		end

		local v13 = module.Data.Accessories.Equipped[v12.Type] == k

		if not ((Controller.Mode ~= "Delete" or v11.Locked ~= true and not v13) and (Controller.Mode ~= "Evolve" or IsEvolveFuel(k))) then
			continue
		end

		v10[k] = true
	end

	Controller.BulkSelectItems(v10)
end)
module.Button:Create(mode.DeselectAll.Main, "Default"):BindFunction("Click", function()
	Controller.DeselectAllItems()
end)
return Accessories