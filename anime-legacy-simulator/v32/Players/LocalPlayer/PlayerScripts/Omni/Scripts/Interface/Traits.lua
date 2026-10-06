local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local Reveal = require(script:WaitForChild("Reveal"))
local traits = module.Shared.Traits
local traits2 = module.Interface:WaitForChild("Frames"):WaitForChild("Traits")
local buttons = traits2:WaitForChild("Buttons")
local price = traits2:WaitForChild("Price")
local currency = traits2:WaitForChild("Currency")
local info = traits2:WaitForChild("Info")
local trait = info:WaitForChild("Trait")
local buffs = info:WaitForChild("Buffs")
local indexFrame = traits2:WaitForChild("IndexFrame")
local title = indexFrame:WaitForChild("Title")
local indexList = traits2:WaitForChild("IndexList")
local scroll = indexList:WaitForChild("Scroll")
local stopTraits = module.Interface:WaitForChild("HUD"):WaitForChild("StopButtons"):WaitForChild("StopTraits")
local traits3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Traits")
local buff = traits3:WaitForChild("Buff")
local trait2 = traits3:WaitForChild("Trait")
local traitPerks = traits3:WaitForChild("TraitPerks")
local v = nil

for _, button in traits2:GetChildren() do
	if not (button.Name == "Fighter" and button:IsA("ImageButton")) then
		continue
	end

	v = button
	break
end

local viewportFrame = v:FindFirstChildWhichIsA("ViewportFrame")
local flag = false
local v3 = nil
local v4 = nil
local v5 = nil
local scale = nil
local flag2 = false
local v6 = nil
local v7 = false
local v8 = 0
local v9 = false
local v10 = false
local count = 0
local v11 = nil
local v12 = 0
local count2 = 0
local v13 = false
local v14 = false
local count3 = 0
local v15 = {}
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = {}
local scope = Fusion.scoped(Fusion)
indexList.GroupTransparency = 0
local Traits = {}

local function ClearRows(items)
	for k, item in items do
		item.Scope:doCleanup()
		item.Instance:Destroy()
		items[k] = nil
	end
end

local function BindToggle(connections, toggle, name)
	local point = toggle.Point
	local value = connections:Value(1)
	local v20 = false
	local v21 = false
	point.Active = false
	point.Interactable = false
	point.Selectable = false
	connections:Hydrate(point:FindFirstChildWhichIsA("UIScale") or connections:New("UIScale")({
		Parent = point
	}))({
		Scale = connections:Spring(value, 40, 1)
	})
	local v22 = connections:New("TextButton")({
		Name = "Hitbox",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.zero,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = true,
		Active = true,
		Interactable = true,
		Selectable = true,
		ZIndex = point.ZIndex + 1,
		Parent = toggle
	})
	table.insert(connections, v22.MouseEnter:Connect(function()
		v20 = true
		value:set(1.05)
	end))
	table.insert(connections, v22.MouseLeave:Connect(function()
		v20 = false
		value:set(v21 and 1.05 or 1)
	end))
	table.insert(connections, v22.MouseButton1Down:Connect(function()
		value:set(0.95)
	end))
	table.insert(connections, v22.MouseButton1Up:Connect(function()
		value:set((v20 or v21) and 1.05 or 1)
	end))
	table.insert(connections, v22.SelectionGained:Connect(function()
		v21 = true
		value:set(1.05)
	end))
	table.insert(connections, v22.SelectionLost:Connect(function()
		v21 = false
		value:set(v20 and 1.05 or 1)
	end))
	table.insert(connections, v22.Activated:Connect(function()
		local autoStop = module.Data.Traits and module.Data.Traits.AutoStop or {}
		module.Signal:Fire("General", "Traits", "SetAutoStop", name, autoStop[name] ~= true)
	end))
end

local function GetRow(p, name, instance, parent, layoutOrder, p2: number?)
	local v20 = p[name]

	if v20 then
		return v20.Instance
	end

	local scope2 = scope:innerScope()
	local clone = instance:Clone()
	clone.Name = name
	clone.LayoutOrder = layoutOrder
	local position = clone.Main.Position
	local value = scope2:Value(UDim2.new(position.X.Scale - 1, position.X.Offset, position.Y.Scale, position.Y.Offset))
	scope2:Hydrate(clone.Main)({
		Position = scope2:Spring(value, 10, 1)
	})
	local v21 = {
		Instance = clone,
		Scope = scope2
	}
	p[name] = v21

	if instance == trait2 then
		BindToggle(scope2, clone.Main.Info.Toggle, name)
	end

	clone.Parent = parent
	clone.Visible = true
	task.delay(((p2 or layoutOrder) - 1) * 0.05, function()
		if p[name] == v21 then
			value:set(position)
		end
	end)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFighter()
	return v3 and module.Data.Fighters.List[v3]
end

local function IsAutoStop(p: string?)
	local autoStop = module.Data.Traits and module.Data.Traits.AutoStop
	return p ~= nil and autoStop ~= nil and autoStop[p] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetResults()
	return typeof(traits.List) == "table" and traits.List or {}
end

local function CanDisplayTrait(value, p)
	if typeof(value) ~= "string" or typeof(p) ~= "table" then
		return false
	end

	if typeof(p.Rarity) ~= "string" or typeof(p.Icon) ~= "string" then
		return false
	end

	for _, v20 in { "Attributes", "Perks" } do
		local v21 = p[v20]

		if typeof(v21) ~= "table" then
			return false
		end

		for k, v22 in v21 do
			if typeof(k) ~= "string" or typeof(v22) ~= "table" or typeof(v22.Type) ~= "string" then
				return false
			end

			if not module.Utils.Validator:ValidateNumber(v22.Amount) then
				return false
			end
		end
	end

	return true
end

local function GetTraitInfo(p)
	if typeof(traits.List) ~= "table" then
		return nil
	end

	local v20 = traits.Get(p)

	if typeof(v20) == "table" and CanDisplayTrait(v20.Name, v20) then
		return v20
	end

	return nil
end

local function IsRollProtected()
	local fighter = GetFighter() -- equivalent call inferred; original call site unknown
	local v21

	if typeof(traits.List) == "table" then
		v21 = traits.Get(fighter)

		if typeof(v21) ~= "table" or not CanDisplayTrait(v21.Name, v21) then
			v21 = nil
		end
	end

	if v21 == nil then
		return false
	else
		local name = v21.Name
		local autoStop = module.Data.Traits and module.Data.Traits.AutoStop

		if name == nil or autoStop == nil then
			return false
		else
			return autoStop[name] == true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CanPay(price2)
	local monetizationPolicy = module.Shared.MonetizationPolicy.FromPlayer(module.Instance)
	local canSpendRandom, v20 = module.Shared.Economy.CanSpendRandom(module.Data, price2, monetizationPolicy)
	return canSpendRandom, v20, monetizationPolicy
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOwnedAmount()
	local price2 = traits.Price

	if price2.Type == "Item" or price2.Type == "Items" then
		return module.Data.Items.List[price2.Name] or 0
	end

	return module.Data[price2.Name] or 0
end

local function GetLuck()
	return module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance)
end

local function GetPreview()
	for k, v20 in GetResults() do
		if not CanDisplayTrait(k, v20) then
			return nil
		end
	end

	local traits4 = module.Data.Traits
	return traits.GetPreview(
		module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance),
		traits4 and traits4.Pity,
		module.Shared.SoftPity.GetState(module.Data, "Traits")
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetChanceText(p, p2: string)
	if not p then
		return "Unavailable"
	end

	local chance = p.Chances[p2]
	local chance2 = chance and chance.Chance or 0
	return module.Utils.Probability.FormatPercentage(chance2) or "Unavailable"
end

local function Notify(message)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function ShowLateResult(p: string, name: string)
	local v20 = traits.List[name]

	if not v20 then
		return
	end

	module.Signal:FireSelf("Interface", "Notifications", "Create", "Drop", {
		Type = "Trait",
		Name = name,
		Rarity = v20.Rarity,
		Amount = 1
	})

	if flag2 and v3 == p then
		local autoStop = module.Data.Traits and module.Data.Traits.AutoStop
		local v21

		if name == nil or autoStop == nil then
			v21 = false
		else
			v21 = autoStop[name] == true
		end

		if v21 then
			Traits.CancelAuto()
			Notify(`Auto Stop: {name}!`)
		end
	end

	Traits.RefreshUI()
end

local function IsRelevantFighterChange(p, p2, p3)
	return not module:IsExpChange(p3, p, p2)
end

local function IsPriceItemChange(_, _, list)
	if list[1] ~= "List" then
		return true
	end

	local v20 = list[2]
	return v20 == nil or v20 == traits.Price.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelReveal()
	count3 += 1
	v13 = false
	Reveal.Cancel()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function InvalidateSession()
	count2 += 1
	count += 1
	v9 = false
	v10 = false
	v11 = nil
	CancelReveal() -- equivalent call inferred; original call site unknown
end

local function PlayReveal(p)
	if not Reveal.IsSupported(p.Rarity) then
		return false
	end

	CancelReveal() -- equivalent call inferred; original call site unknown
	v13 = true
	local v20 = count3
	local v21 = Reveal.Play(p, {
		Luck = module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance),
		OnComplete = function()
			if count3 ~= v20 then
				return
			end

			v13 = false
			Traits.RefreshUI()
		end,
		IsAutoRolling = function()
			return flag2
		end,
		OnStopAuto = function()
			Traits.CancelAuto()
			Traits.RefreshUI()
		end
	})

	if not v21 then
		v13 = false
	end

	return v21
end

function Traits.RefreshBuffs(p)
	local v20 = {}

	for k, v21 in module.Utils.Traits.GetRows(p, true) do
		v20[v21.Key] = true
		local row = GetRow(v15, v21.Key, buff, buffs, k)
		row.LayoutOrder = k
		row.Main.TextLabel.RichText = true
		row.Main.TextLabel.Text = v21.Text
	end

	for k, v21 in v15 do
		if v20[k] then
			continue
		end

		v21.Scope:doCleanup()
		v21.Instance:Destroy()
		v15[k] = nil
	end
end

function Traits.RefreshViewport(p)
	local v20 = not p and "Dummy" or `{v3}/{p.Name}/{tostring(p.Shiny)}` or "Dummy"

	if v20 ~= v4 then
		module.Utils.Camera.ClearViewport(viewportFrame)
		v5 = nil
		scale = nil
		v4 = nil
		local name = not p and "Dummy" or p.Name or "Dummy"
		local character = module.Utils.Characters.Get({
			Name = name,
			Shiny = p and p.Shiny,
			RemoveHumanoidStates = true
		})

		if not character then
			return
		end

		local viewportCharacter = module.Utils.Camera.ViewportCharacter({
			Viewport = viewportFrame,
			CustomCFrame = CFrame.new(0, -1, -4) * CFrame.Angles(0, 3.141592653589793, 0),
			Animation = module.Utils.Characters.GetCharacterAnimation(name, "Idle"),
			Character = character
		})
		v5 = viewportCharacter and viewportCharacter[1]
		scale = v5 and v5:GetScale()
		v4 = v5 and v20
	end

	if not (v5 and scale) then
		return
	end

	local v21 = p and module.Shared.Fighters.GetFighterSize(p) or 1
	local v22 = scale * v21

	if v5:GetScale() ~= v22 then
		v5:ScaleTo(v22)
	end
end

function Traits.RefreshIndex()
	local preview = GetPreview()
	local v21 = typeof(traits.List) ~= "table" and {} or traits.List or {}
	title.Text = preview and "Next roll chances (rounded)" or "Chances unavailable"
	local v22 = {}
	local v23 = {}

	for k, v24 in v21 do
		if not CanDisplayTrait(k, v24) then
			continue
		end

		table.insert(v22, k)
		v23[k] = true
	end

	table.sort(v22, function(a, b)
		local rarity = module.Utils.Order:Rarity(v21[a].Rarity)
		local rarity2 = module.Utils.Order:Rarity(v21[b].Rarity)

		if rarity ~= rarity2 then
			return rarity < rarity2
		end

		local v24 = preview and preview.Chances[a]
		local v25 = preview and preview.Chances[b]
		local chance = v24 and v24.Chance or tonumber(v21[a].Chance) or 0
		local chance2 = v25 and v25.Chance or tonumber(v21[b].Chance) or 0

		if chance == chance2 then
			return a < b
		end

		return chance2 < chance
	end)

	for k, text in v22 do
		local v25 = v21[text]
		local row = GetRow(v16, text, trait2, scroll, k * 2 - 1, k)
		row.LayoutOrder = k * 2 - 1
		row.Main.Info.Title.Text = text
		row.Main.UIGradient:SetAttribute("Rarity", v25.Rarity)
		row.Main.Info.Icon.UIGradient:SetAttribute("Rarity", v25.Rarity)
		row.Main.Info.Title.UIGradient:SetAttribute("Rarity", v25.Rarity)
		row.Main.Info.Icon.Image = v25.Icon or ""
		local chance = row.Main.Info.Chance
		local text2 = GetChanceText(preview, text) -- equivalent call inferred; original call site unknown
		chance.Text = text2
		local autoStop = module.Data.Traits and module.Data.Traits.AutoStop
		local v28

		if text == nil or autoStop == nil then
			v28 = false
		else
			v28 = autoStop[text] == true
		end

		local toggle = row.Main.Info.Toggle
		local color = v28 and Color3.fromRGB(0, 255, 149) or Color3.fromRGB(255, 51, 99)
		toggle.ImageColor3 = color
		toggle.Point.Position = UDim2.fromScale(v28 and 0.789 or 0.211, 0.5)
		toggle.Point.ImageColor3 = color
		toggle.Point.Glow.ImageColor3 = color
		local row2 = GetRow(v17, text, traitPerks, scroll, k * 2, k)
		row2.Name = `{text} Perks`
		row2.LayoutOrder = k * 2
		local v30 = {}

		for _, v31 in module.Utils.Traits.GetRows(v25, true) do
			table.insert(v30, v31.Text)
		end

		if v25.Rarity == "Mythical" and v25.Pity then
			local v31 = preview and preview.Pity.CurrentState[text]
			table.insert(
				v30,
				"\nPity: " .. (v31 == nil and "Unavailable" or tostring((math.min(v31, v25.Pity))) .. "/" .. tostring(v25.Pity))
			)
		end

		row2.Main.Info.Value.RichText = true
		row2.Main.Info.Value.Text = table.concat(v30, "\n")
	end

	for _, v24 in { v16, v17 } do
		for k, v25 in v24 do
			if v23[k] then
				continue
			end

			v25.Scope:doCleanup()
			v25.Instance:Destroy()
			v24[k] = nil
		end
	end
end

function Traits.SetIndex(visible: boolean)
	v7 = visible
	indexList.Visible = visible
	indexFrame.Visible = visible

	if visible then
		Traits.RefreshIndex()
		return
	end

	ClearRows(v16)
	ClearRows(v17)
end

function Traits.CancelAuto()
	module.AutoRoll.Release(v6)
	v6 = nil
	flag2 = false
	stopTraits.Visible = false
	buttons.Auto.Main:SetAttribute("AutoRolling", false)
	buttons.Auto.Main.Icon.ImageColor3 = Color3.new(1, 1, 1)

	if module.Frame:IsFrameOpened(traits2) then
		buttons.Spin.Main.Title.Text = flag and not GetPreview() and "Unavailable" or "Spin"
	end

	if v18.Auto then
		v18.Auto:Disconnect()
		v18.Auto = nil
	end
end

function Traits.Roll()
	if not flag or v9 or v13 or v14 or os.clock() < v8 then
		return
	end

	if GetPreview() then
		if GetFighter() then
			local fighter = GetFighter() -- equivalent call inferred; original call site unknown
			local v21

			if typeof(traits.List) == "table" then
				v21 = traits.Get(fighter)

				if typeof(v21) ~= "table" or not CanDisplayTrait(v21.Name, v21) then
					v21 = nil
				end
			end

			local v22

			if v21 == nil then
				v22 = false
			else
				local name = v21.Name
				local autoStop = module.Data.Traits and module.Data.Traits.AutoStop

				if name == nil or autoStop == nil then
					v22 = false
				else
					v22 = autoStop[name] == true
				end
			end

			if v22 then
				Traits.CancelAuto()
				Notify("Unselect this Trait in the index before spinning again!")
			else
				local canSpendRandom, v24, monetizationPolicy = CanPay(traits.Price) -- equivalent call inferred; original call site unknown

				if canSpendRandom then
					v9 = true
					v10 = flag2
					v11 = v3
					v12 = count2
					count += 1
					local v26 = count
					local traitsCooldown = module.Utils.PlayerStats.TraitsCooldown(module.Data, module.Instance)
					v8 = os.clock() + traitsCooldown + 0.1
					module.Signal:Fire("General", "Traits", "Spin", v3, v26)
					task.delay(math.max(30, traitsCooldown + 3), function()
						if count ~= v26 or not v9 then
							return
						end

						v9 = false
						v10 = false
						v11 = nil
						module.AutoRoll.Expire("Traits", v26)
						Traits.RefreshUI()
					end)
				else
					Traits.CancelAuto()
					local v27

					if v24 == "InsufficientBalance" then
						v27 = `You need {traits.Price.Amount} {traits.Price.Name} to spin Traits!`
					else
						v27 = module.Shared.MonetizationPolicy.GetPaymentMessage(v24, monetizationPolicy)
					end

					Notify(v27)
					Traits.RefreshUI()
				end
			end
		else
			Traits.CancelAuto()
			Notify("Select a Fighter first!")
		end
	else
		Traits.CancelAuto()
		Notify("Trait chances are unavailable. Please try again later!")
		Traits.RefreshUI()
	end
end

function Traits.RollFailed(p: string, p2: number?, p3: string?)
	if module.AutoRoll.TakeExpired("Traits", p2) or (not v9 or v11 ~= p or p2 ~= count) then
		return
	end

	local v20 = v12
	v9 = false
	v10 = false
	v11 = nil

	if module.AutoRoll.ShouldRetry(p3) then
		v8 = os.clock() + 1
	elseif v20 == count2 then
		Traits.CancelAuto()
	end

	Traits.RefreshUI()
end

function Traits.StartAuto()
	if flag2 then
		Traits.CancelAuto()
		Traits.RefreshUI()
	elseif not (flag and GetFighter()) then
		Notify("Select a Fighter first!")
	elseif GetPreview() then
		local fighter = GetFighter() -- equivalent call inferred; original call site unknown
		local v21

		if typeof(traits.List) == "table" then
			v21 = traits.Get(fighter)

			if typeof(v21) ~= "table" or not CanDisplayTrait(v21.Name, v21) then
				v21 = nil
			end
		end

		local v22

		if v21 == nil then
			v22 = false
		else
			local name = v21.Name
			local autoStop = module.Data.Traits and module.Data.Traits.AutoStop

			if name == nil or autoStop == nil then
				v22 = false
			else
				v22 = autoStop[name] == true
			end
		end

		if v22 then
			Notify("Unselect this Trait in the index before spinning again!")
			return
		end

		local canSpendRandom, _, _ = CanPay(traits.Price) -- equivalent call inferred; original call site unknown

		if not canSpendRandom then
			Traits.Roll()
			return
		end

		v6 = module.AutoRoll.Claim(Traits.CancelAuto, "Traits", v3)
		flag2 = true
		stopTraits.Visible = true
		buttons.Auto.Main:SetAttribute("AutoRolling", true)
		buttons.Auto.Main.Icon.ImageColor3 = Color3.fromRGB(255, 80, 80)
		v18.Auto = module.Utils.Loop:Connect({
			Time = 0.2,
			Identifier = "TraitsAutoRoll",
			Callback = function(p)
				if p == v18.Auto and flag2 then
					Traits.Roll()
				end
			end
		})
		Traits.Roll()
		Traits.RefreshUI()
	else
		Notify("Trait chances are unavailable. Please try again later!")
		Traits.RefreshUI()
	end
end

function Traits.Rolled(p: string, name: string, p3: number?)
	if module.AutoRoll.TakeExpired("Traits", p3) then
		ShowLateResult(p, name)
		return
	end

	if not v9 or v11 ~= p or p3 ~= count then
		return
	end

	local v20 = flag2 or v10
	local v21 = v12
	v9 = false
	v10 = false
	v11 = nil

	if v21 ~= count2 or not flag or v3 ~= p then
		return
	end

	if v20 then
		local autoStop = module.Data.Traits and module.Data.Traits.AutoStop
		local v22

		if name == nil or autoStop == nil then
			v22 = false
		else
			v22 = autoStop[name] == true
		end

		if v22 then
			Traits.CancelAuto()
			Notify(`Auto Stop: {name}!`)
		end
	end

	local v22 = traits.List[name]

	if not v22 then
		return
	end

	if PlayReveal(v22) then
		Traits.RefreshUI()
		return
	end

	local v23 = {
		{
			Name = name,
			Rarity = v22.Rarity,
			Icon = v22.Icon
		}
	}
	local v24 = {
		Info = traits.List,
		Chances = traits.List
	}
	v14 = true
	module.Gacha.Animation(
		module.Utils.PlayerStats.TraitsCooldown(module.Data, module.Instance),
		v23,
		v24,
		module.Utils.PlayerStats.GachaLuck(module.Data, module.Instance),
		{
			DropType = "Trait",
			OnFinish = function(p4)
				v14 = false

				if not p4 and v21 == count2 then
					Traits.CancelAuto()
				end

				if v21 == count2 then
					Traits.RefreshUI()
				end
			end
		}
	)
	Traits.RefreshUI()
end

function Traits.SelectFighter(p: string)
	if not (v3 ~= p and module.Data.Fighters.List[p]) then
		return
	end

	Traits.CancelAuto()
	InvalidateSession() -- equivalent call inferred; original call site unknown
	v3 = p
	Traits.RefreshUI()
end

function Traits.DeselectFighter()
	if v7 then
		return
	end

	Traits.CancelAuto()
	InvalidateSession() -- equivalent call inferred; original call site unknown
	v3 = nil
	Traits.RefreshUI()
end

function Traits.OpenFighterSelector()
	if v3 then
		Traits.DeselectFighter()
		return
	end

	Traits.CancelAuto()
	local v20 = module.Signal:InvokeSelf("Interface", "Inventory", "GetController")

	if not v20 then
		return
	end

	v20.SetMode("Selection", {
		Category = "Fighters",
		PastUI = traits2,
		Callback = function(p: string)
			Traits.SelectFighter(p)
			v20.CloseInterface()
		end
	})
end

function Traits.RefreshUI()
	if not (flag and (flag2 or module.Frame:IsFrameOpened(traits2))) then
		return
	end

	local preview = GetPreview()
	local fighter = GetFighter() -- equivalent call inferred; original call site unknown

	if not fighter then
		if v3 then
			InvalidateSession() -- equivalent call inferred; original call site unknown
		end

		v3 = nil
		Traits.CancelAuto()
	end

	if flag2 then
		if preview then
			local fighter2 = GetFighter() -- equivalent call inferred; original call site unknown
			local v23

			if typeof(traits.List) == "table" then
				v23 = traits.Get(fighter2)

				if typeof(v23) ~= "table" or not CanDisplayTrait(v23.Name, v23) then
					v23 = nil
				end
			end

			local v24

			if v23 == nil then
				v24 = false
			else
				local name = v23.Name
				local autoStop = module.Data.Traits and module.Data.Traits.AutoStop

				if name == nil or autoStop == nil then
					v24 = false
				else
					v24 = autoStop[name] == true
				end
			end

			if v24 then
				Traits.CancelAuto()
			end
		else
			Traits.CancelAuto()
		end
	end

	if not module.Frame:IsFrameOpened(traits2) then
		return
	end

	local v22

	if typeof(traits.List) == "table" then
		v22 = traits.Get(fighter)

		if typeof(v22) ~= "table" or not CanDisplayTrait(v22.Name, v22) then
			v22 = nil
		end
	end

	trait.Background.Title.Text = v22 and v22.Name or fighter and "No Trait" or "Select a Fighter"
	local uIGradient = trait.Background.Title.UIGradient
	local v24

	if v22 then
		v24 = v22.Rarity or nil
	end

	uIGradient:SetAttribute("Rarity", v24)
	local uIGradient2 = trait.Background.UIGradient
	local v26

	if v22 then
		v26 = v22.Rarity or nil
	end

	uIGradient2:SetAttribute("Rarity", v26)
	trait.Background.Icon.Image = not v22 and "" or v22.Icon or ""
	trait.Background.Icon.Visible = (v22 and v22.Icon) ~= nil
	local v27 = module.Utils.Info:Get(traits.Price.Type, traits.Price.Name) or {}
	price.Icon.Image = v27.Icon or ""
	local value = price.Value
	local number = module.Utils.Number
	local ownedAmount = GetOwnedAmount() -- equivalent call inferred; original call site unknown
	value.Text = `{number:Format(ownedAmount)}/{module.Utils.Number:Format(traits.Price.Amount)}`
	currency.Icon.Image = v27.Icon or ""
	local title2 = currency.Title
	local number2 = module.Utils.Number
	local ownedAmount2 = GetOwnedAmount() -- equivalent call inferred; original call site unknown
	title2.Text = number2:Format(ownedAmount2)
	buttons.Spin.Main.Title.Text = preview and (flag2 and "Stop Auto" or "Spin") or "Unavailable"
	Traits.RefreshBuffs(v22)
	Traits.RefreshViewport(fighter)

	if flag2 and not (v9 or v14 or v13) then
		local canSpendRandom, _, _ = CanPay(traits.Price) -- equivalent call inferred; original call site unknown

		if not canSpendRandom then
			Traits.CancelAuto()
		end
	end

	if v7 then
		Traits.RefreshIndex()
	end
end

local function Prepare()
	if flag then
		return
	end

	flag = true
	trait.Background.Title.TextWrapped = false
	title.Size = UDim2.new(0.96, title.Size.X.Offset, title.Size.Y.Scale, title.Size.Y.Offset)
	buttons.Index.Main.Title.Text = "See Chances"
	module.Utils.Camera.ClearViewport(viewportFrame)
	v4 = nil
	v5 = nil
	scale = nil
	Traits.SetIndex(false)
	Traits.RefreshUI()
	v18.SoftPity = module:OnDataChanged({ "SoftPity" }, Traits.RefreshUI)
	v18.Refresh = module.Utils.Loop:Connect({
		Time = 1,
		Identifier = "TraitsInterfaceRefresh",
		Callback = Traits.RefreshUI
	})
end

function Traits.Start()
	if flag then
		if not module.Frame:IsFrameOpened(traits2) then
			module.Frame:Open(traits2)
		end

		Traits.RefreshUI()
	else
		Prepare()
		module.Frame:Open(traits2)
	end
end

function Traits.Resume(p: string)
	Prepare()
	Traits.SelectFighter(p)

	if v3 == p then
		local canSpendRandom, _, _ = CanPay(traits.Price) -- equivalent call inferred; original call site unknown

		if canSpendRandom then
			Traits.StartAuto()
		end
	end

	if not flag2 then
		module.AutoRoll.SaveGacha(nil)
	end
end

function Traits.Close()
	if module.Frame:IsFrameOpened(traits2) then
		module.Frame:Close(traits2)
	end

	Traits.SetIndex(false)
	ClearRows(v15)
	ClearRows(v16)
	ClearRows(v17)
	module.Utils.Camera.ClearViewport(viewportFrame)
	v4 = nil
	v5 = nil
	scale = nil
end

function Traits.Stop()
	InvalidateSession() -- equivalent call inferred; original call site unknown

	if not flag then
		return
	end

	flag = false
	Traits.CancelAuto()

	for k, connection in v18 do
		connection:Disconnect()
		v18[k] = nil
	end

	Traits.SetIndex(false)
	ClearRows(v15)
	ClearRows(v16)
	ClearRows(v17)
	module.Utils.Camera.ClearViewport(viewportFrame)
	v4 = nil
	v5 = nil
	scale = nil
	module.Frame:Close(traits2)
end

module.Button:Create(currency.More, "Small"):BindFunction("Click", function()
	module.Signal:FireSelf("Interface", "GemProducts", "Open", "Traits", "Traits", "Traits")
end)
module.Button:Create(v, "Small"):BindFunction("Click", Traits.OpenFighterSelector)
module.Button:Create(buttons.Spin.Main, "Small"):BindFunction("Click", function()
	if not flag2 then
		Traits.Roll()
		return
	end

	Traits.CancelAuto()
	Traits.RefreshUI()
end)
module.Button:Create(buttons.Auto.Main, "Default"):BindFunction("Click", Traits.StartAuto)
module.Button:Create(stopTraits.Main, "Default"):BindFunction("Click", function()
	Traits.CancelAuto()
	Traits.RefreshUI()
end)
module.Button:Create(buttons.Index.Main, "Default"):BindFunction("Click", function()
	Traits.SetIndex(not v7)
end)
module.Button:Create(traits2.Close.Main, "Close"):BindFunction("Click", Traits.Close)
module.Frame:OnFrameOpened(traits2, Traits.Start)
module.Frame:OnFrameClosed(traits2, Traits.Close)
v19.Fighters = module:OnDataChangedDeferred({ "Fighters" }, Traits.RefreshUI, IsRelevantFighterChange)
v19.Items = module:OnDataChangedDeferred({ "Items" }, Traits.RefreshUI, IsPriceItemChange)
v19.Traits = module:OnDataChangedDeferred({ "Traits" }, Traits.RefreshUI)
script.Destroying:Connect(function()
	Traits.Stop()

	for k, connection in v19 do
		connection:Disconnect()
		v19[k] = nil
	end

	scope:doCleanup()
end)
return Traits