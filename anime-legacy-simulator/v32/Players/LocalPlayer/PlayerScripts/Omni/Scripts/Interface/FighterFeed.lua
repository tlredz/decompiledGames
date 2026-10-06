local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local fighterFeed = module.Shared.FighterFeed
local Controller = require(script.Parent.Inventory.Controller)
local AmountSelector = require(script.Parent.AmountSelector)
local fighters = module.Interface:WaitForChild("Frames"):WaitForChild("Fighters")
local feed = fighters:WaitForChild("Feed")
local main = feed:WaitForChild("Main")
local scroll = main.UnselectedFrame.List.Scroll
local scroll2 = main.SelectedFrame.List.Scroll
local item = module.Assets.Interface.Templates.Feed.Item
local v = nil
local v2 = {}
local v3 = {}
local v4 = {}
local connections = {}
local scope = fusion.scoped(fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(UDim2.fromScale(0.5, 0.5))
local spring2 = scope:Spring(value2, 10, 1)
local value3 = scope:Value(UDim2.fromScale(1, 1))
local spring3 = scope:Spring(value3, 10, 1)
local count = 0
local flag = false
local flag2 = false
local v5 = nil
local interactablesByButton = {}
local FighterFeed = {}

local function Notify(message)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearCard(p, k)
	local v6 = p[k]

	if not v6 then
		return
	end

	p[k] = nil
	v6.Instance:Destroy()
	v6.Scope:doCleanup()
end

local function SelectAmount(p, p2)
	if not v or flag or flag2 or module.Frame:IsFrameOpened("AmountSelector") then
		return
	end

	local maximum

	if p2 then
		maximum = v2[p] or 0
	else
		maximum = fighterFeed.GetAvailableAmount(p, module.Data) - (v2[p] or 0)
	end

	if maximum <= 0 then
		return
	end

	local v7 = count
	flag2 = true
	AmountSelector.Start({
		Start = 1,
		Minimum = 1,
		Maximum = maximum,
		Callback = function(value4)
			if count ~= v7 or not v or flag then
				return
			end

			if typeof(value4) ~= "number" or value4 ~= value4 or value4 == 1e999 then
				return
			end

			local v8 = v2[p] or 0
			local v9

			if p2 then
				v9 = v8
			else
				v9 = math.max(0, fighterFeed.GetAvailableAmount(p, module.Data) - v8)
			end

			local v10 = math.clamp(math.floor(value4), 0, v9)

			if p2 then
				v10 = -v10
			end

			local v11 = v8 + v10
			local v12 = v2

			if not (v11 > 0) then
				v11 = nil
			end

			v12[p] = v11
			FighterFeed.Refresh()
		end
	})
end

local function RenderCards(items, scroll3, p, p2)
	for k in items do
		if p[k] then
			continue
		end

		ClearCard(items, k) -- equivalent call inferred; original call site unknown
	end

	local total = 0

	for k, v6 in fighterFeed.GetFoods() do
		local v7 = p[v6]

		if not v7 or v7 <= 0 then
			continue
		end

		local v8 = module.Shared.Items.List[v6]
		local item2 = items[v6]

		if not item2 then
			local scope2 = fusion.scoped(fusion)
			local value4 = scope2:Value(UDim2.fromScale(0, 0))
			local clone = item:Clone()
			clone.Name = v6
			clone.Parent = scroll3
			clone.Visible = true
			item2 = {
				Instance = clone,
				Scope = scope2
			}
			items[v6] = item2
			local v9 = v6
			module.Button:Create(clone.Main, "Small"):BindFunction("Click", function()
				SelectAmount(v9, p2)
			end)
			scope2:Hydrate(clone.Main)({
				Size = scope2:Spring(value4, 10, 1)
			})
			local v10 = v6
			task.delay(total, function()
				if items[v10] ~= item2 then
					return
				end

				value4:set(UDim2.fromScale(1, 1))
			end)
			total += 0.05
		end

		local instance = item2.Instance
		instance.LayoutOrder = k
		instance.Main.Title.Text = v6
		instance.Main.Icon.Image = v8.Icon
		instance.Main.Amount.Text = `{module.Utils.Number:Format(v7)}x`
		instance.Main.UIGradient:SetAttribute("Rarity", v8.Rarity)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCanvas(instance)
	local uIGridLayout = instance:FindFirstChildWhichIsA("UIGridLayout")

	if not uIGridLayout then
		return
	end

	instance.CanvasSize = UDim2.fromOffset(uIGridLayout.AbsoluteContentSize.X, uIGridLayout.AbsoluteContentSize.Y)
end

function FighterFeed.Refresh()
	if not v then
		return
	end

	local v6 = module.Data.Fighters.List[v]

	if not v6 then
		FighterFeed.Stop()
		return
	end

	for k, v7 in v2 do
		local availableAmount = fighterFeed.GetAvailableAmount(k, module.Data)

		if fighterFeed.IsFood(k) and not (availableAmount <= 0) then
			v2[k] = math.min(v7, availableAmount)
		else
			v2[k] = nil
		end
	end

	local v7 = {}

	for _, v8 in fighterFeed.GetFoods() do
		local v9 = fighterFeed.GetAvailableAmount(v8, module.Data) - (v2[v8] or 0)

		if v9 > 0 then
			v7[v8] = v9
		end
	end

	RenderCards(v3, scroll, v7, false)
	RenderCards(v4, scroll2, v2, true)
	local preview = fighterFeed.GetPreview(v6, module.Data, v2)

	if not preview then
		return
	end

	local v8 = module.Shared.Fighters.List[v6.Name]
	local v9 = v6.Name .. tostring(v6.Shiny)

	if v5 ~= v9 then
		v5 = v9
		module.Utils.Camera.ViewportCharacter({
			Viewport = main.Fighter.Main.Viewport,
			Animation = module.Utils.Characters.GetCharacterAnimation(v6.Name, "Idle"),
			Character = module.Utils.Characters.Get({
				Name = v6.Name,
				Shiny = v6.Shiny,
				RemoveHumanoidStates = true
			})
		})
	end

	main.Fighter.Main.Title.Text = module.Shared.Fighters.GetDisplayName(v6.Name)
	main.Fighter.Main.UIGradient:SetAttribute("Rarity", v8.Rarity)
	main.Labels.Level.Text = `Lv. {v6.Level} > Lv. {preview.Level}`
	local totalExp = fighterFeed.GetTotalExp(v6, module.Data)
	main.Labels.Exp.Text = `{module.Utils.Number:Format(totalExp)} > {module.Utils.Number:Format(totalExp + preview.GainedExp)} EXP`
	local clone = table.clone(v6)
	clone.Level = preview.Level
	local fighterDamage = module.Shared.Fighters.GetFighterDamage(v6, module.Data)
	local fighterDamage2 = module.Shared.Fighters.GetFighterDamage(clone, module.Data)
	main.Labels.Damage.Text = `{module.Utils.Number:Format(fighterDamage)} > {module.Utils.Number:Format(fighterDamage2)} DMG`

	if preview.Level >= preview.MaxLevel then
		main.Progress.Value.Text = "MAXED"
		value:set(1)
	else
		local neededExpForLevel = module.Shared.Fighters.GetNeededExpForLevel(preview.Level + 1, v6, module.Data)
		main.Progress.Value.Text = `{module.Utils.Number:Format(preview.Exp)}/{module.Utils.Number:Format(neededExpForLevel)} XP`
		value:set((math.clamp(preview.Exp / neededExpForLevel, 0, 1)))
	end

	main.BottomButtons.Feed.Main.Interactable = not flag and next(preview.Consumed) ~= nil
end

function FighterFeed.Start(p: string)
	if not module.Data.Fighters.List[p] then
		return
	end

	if v then
		FighterFeed.Stop()
	end

	Controller.SetCategory("Fighters")
	Controller.SetMode("Default")
	local v6 = module.Libs.NeoHover.GetByIdentifier("Fighters")

	if v6 then
		v6:Close(nil, true)
	end

	Controller.LockMode()
	v = p
	count += 1
	value:set(0)
	spring:setPosition(0)
	spring2:setPosition(UDim2.fromScale(0.5, 1.5))
	spring3:setPosition(UDim2.fromScale(0, 0))

	for _, folder in { fighters.Main, fighters.Buttons } do
		for _, button in folder:GetDescendants() do
			if not button:IsA("GuiButton") then
				continue
			end

			interactablesByButton[button] = button.Interactable
			button.Interactable = false
		end
	end

	feed.Visible = true
	feed.Active = true
	value2:set(UDim2.fromScale(0.5, 0.5))
	value3:set(UDim2.fromScale(1, 1))

	for _, v7 in { scroll, scroll2 } do
		local uIGridLayout = v7:FindFirstChildWhichIsA("UIGridLayout")

		if not uIGridLayout then
			continue
		end

		local v8 = v7
		table.insert(connections, uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			UpdateCanvas(v8) -- equivalent call inferred; original call site unknown
		end))
	end

	FighterFeed.Refresh()
end

function FighterFeed.Stop()
	v = nil
	count += 1
	flag = false

	if flag2 then
		AmountSelector.Stop()
	end

	flag2 = false
	feed.Visible = false
	Controller.UnlockMode()

	for k, interactable in interactablesByButton do
		if k.Parent then
			k.Interactable = interactable
		end
	end

	table.clear(interactablesByButton)

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	for k in v3 do
		ClearCard(v3, k) -- equivalent call inferred; original call site unknown
	end

	for k in v4 do
		ClearCard(v4, k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v2)
	v5 = nil
	module.Utils.Camera.ClearViewport(main.Fighter.Main.Viewport)
end

function FighterFeed.ChooseFighter()
	Controller.SetMode("Selection", {
		Category = "Fighters",
		PastUI = fighters,
		Callback = FighterFeed.Start
	})
	fighters.Buttons.Selection.Text = "Select the fighter to feed!"
end

function FighterFeed.Init()
	feed.Visible = false
	module:OnDataChanged({ "Items" }, FighterFeed.Refresh)
	module:OnDataChanged({ "Fighters" }, FighterFeed.Refresh)
	module.Frame:OnFrameClosed(fighters, FighterFeed.Stop)
	module.Frame:OnFrameClosed("AmountSelector", function()
		flag2 = false
	end)
end

scope:Hydrate(main)({
	Position = spring2
})
scope:Hydrate(main.Fighter.Main)({
	Size = spring3
})
scope:Observer(spring):onBind(function()
	local v6 = math.clamp(fusion.peek(spring), 0, 1)
	local uIGradient = main.Progress.Bar.Slider.UIGradient

	if v6 <= 0 then
		uIGradient.Transparency = NumberSequence.new(1)
	elseif v6 >= 1 then
		uIGradient.Transparency = NumberSequence.new(0)
	else
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(v6, 0),
			NumberSequenceKeypoint.new(v6 + (1 - v6) * 0.01, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end)
module.Button:Create(main.BottomButtons.Close.Main, "Small"):BindFunction("Click", FighterFeed.Stop)
module.Button:Create(fighters.Buttons.Default.Deconstruct.Main, "Default"):BindFunction("Click", function()
	Controller.SetMode("Deconstruct")
end)
module.Button:Create(main.BottomButtons.Feed.Main, "Small"):BindFunction("Click", function()
	if flag or not v then
		return
	end

	flag = true
	FighterFeed.Refresh()
	local v6 = count
	local success, result = pcall(function()
		return module.Signal:Invoke("General", "Fighters", "Feed", v, table.clone(v2))
	end)

	if v6 ~= count then
		return
	end

	flag = false

	if success and result then
		table.clear(v2)
	else
		Notify("Unable to feed this fighter. Check your food and level limit.")
	end

	FighterFeed.Refresh()
end)
module.Button:Create(main.TopButtons.AddAll.Main, "Small"):BindFunction("Click", function()
	if flag or not v then
		return
	end

	local v6 = module.Data.Fighters.List[v]

	if not v6 then
		return
	end

	v2 = fighterFeed.AddAll(v6, module.Data, v2)
	FighterFeed.Refresh()
end)
module.Button:Create(main.TopButtons.RemoveAll.Main, "Small"):BindFunction("Click", function()
	if flag then
		return
	end

	table.clear(v2)
	FighterFeed.Refresh()
end)
return FighterFeed