local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Presentation = require(ReplicatedStorage.Omni.Shared.Mutations.Presentation)
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local fighters = module.Inset:WaitForChild("Fighters")
local background = fighters:WaitForChild("Background")
local main = fighters:WaitForChild("Main")
local mutation = fighters:WaitForChild("Others"):WaitForChild("Mutation")
local v = module.Libs.NeoHover.Create(fighters, script.Name)
local value = scope:Value(UDim2.fromScale(0, 1))
local v2 = nil
local Fighters = {}

local function RenderViewport(data, owner)
	local v3

	if typeof(owner) == "Instance" then
		v3 = owner.UserId
	else
		v3 = owner
	end

	local formatted = `{data.Name}|{data.Shiny == true}|{v3}`

	if formatted == v2 then
		return
	end

	if not module.Utils.Camera.ViewportCharacter({
		Viewport = main.Header.Visibility.Viewport,
		CustomCFrame = CFrame.new(0, -1.5, -2.25) * CFrame.Angles(0, 3.141592653589793, 0),
		Animation = module.Utils.Characters.GetCharacterAnimation(data.Name, "Idle"),
		Character = module.Utils.Characters.Get({
			Name = data.Name,
			Owner = owner,
			Shiny = data.Shiny,
			RemoveHumanoidStates = true
		})
	}) then
		formatted = nil
	end

	v2 = formatted
end

function Fighters.Refresh()
	local element = v.Element
	local params = v.Params

	if not (element and params) then
		return
	end

	local data = params.Data
	local playerData = params.PlayerData or module.Data
	local v3, v4 = Presentation.Get(data.Mutations)
	mutation.Visible = v3 ~= nil
	mutation.Main.Title.Text = v4 or ""
	mutation.Main.Value.Text = v3 and v3.Description or ""
	local v5 = module.Shared.Fighters.List[data.Name]

	if not v5 then
		return
	end

	local v6 = module.Shared.Traits.Get(data)
	local fighterMaxLevel = module.Shared.Fighters.GetFighterMaxLevel(data, playerData)
	local fighterEffectiveLevel = module.Shared.Fighters.GetFighterEffectiveLevel(data, playerData)
	local fighterSPA = module.Shared.Fighters.GetFighterSPA(data, playerData)
	local fighterDamage = module.Shared.Fighters.GetFighterDamage(data, playerData)
	local locked = data.Locked == true
	local visible = (playerData.Fighters.Equipped or {})[data.ID]
	main.SPA.Value.Text = `<font color="rgb(31,0,255)">SPA:</font> {module.Utils.Number:Round(fighterSPA)}s`
	main.Damage.Value.Text = `<font color="rgb(255,0,31)">Damage:</font> {module.Utils.Number:Format(fighterDamage)}`
	main.Trait.Visible = false
	local trait = fighters.Others.Trait
	trait.Visible = not (params.IsFake or params.IsIndex or params.IsFromProfile)

	if v6 then
		trait.Main.Title.Text = v6.Name
		trait.Main.Value.RichText = true
		trait.Main.Value.Text = module.Utils.Traits.ToString(v6, true)
		trait.Main.UIGradient:SetAttribute("Rarity", v6.Rarity)
	else
		trait.Main.Title.Text = "No Trait"
		trait.Main.Value.Text = "Click to roll a Trait"
		trait.Main.UIGradient:SetAttribute("Rarity", nil)
	end

	if not params.IsIndex then
		local exp = data.Exp or 0
		main.Level.Level.Text = `Lvl <font color="rgb(255,198,0)">{fighterEffectiveLevel}</font>`

		if fighterMaxLevel <= fighterEffectiveLevel then
			value:set(UDim2.fromScale(1, 1))
			main.Level.Exp.Text = "<font color=\"rgb(186,186,186)\">MAXED</font>"
		else
			local neededExpForLevel = module.Shared.Fighters.GetNeededExpForLevel(
				fighterEffectiveLevel + 1,
				data,
				playerData
			)
			value:set(UDim2.fromScale(exp / neededExpForLevel, 1))
			main.Level.Exp.Text = `XP {module.Utils.Number:Format(exp)}/<font color="rgb(186,186,186)"><font size="12">{module.Utils.Number:Format(neededExpForLevel)}</font></font>`
		end
	end

	if params.IsFake then
		main.Unlock.Visible = false
		main.Lock.Visible = false
		main.Equip.Visible = false
		main.Unequip.Visible = false
		main.Trait.Visible = false
		main.Sell.Visible = false
	else
		main.Unlock.Visible = locked
		main.Lock.Visible = not locked
		main.Equip.Visible = not visible
		main.Unequip.Visible = visible
		local sell = main.Sell
		sell.Visible = v5.Sellable ~= false and not (locked or visible)
	end
end

function Fighters:Open(data, p)
	if not p and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	local data2 = data.Data
	local v3 = module.Shared.Fighters.List[data.Data.Name]

	if not v3 then
		return
	end

	main.Header.Labels.Title.Text = module.Shared.Fighters.GetDisplayName(data2.Name, data.Owner)
	main.Header.Labels.Rarity.Text = v3.Rarity
	background.RarityStroke.UIGradient:SetAttribute("Rarity", v3.Rarity)
	main.Header.Labels.Rarity.UIGradient:SetAttribute("Rarity", v3.Rarity)
	local feed = main.Feed
	feed.Visible = data.IsFake == false and not (data.IsIndex or data.IsFromProfile)
	local skillTree = fighters:FindFirstChild("SkillTree")

	if skillTree then
		skillTree.Visible = data.IsFake == false
	end

	main.RemoveFromProfile.Visible = data.IsFromProfile == true
	main.SelectFromSelection.Visible = data.IsSelection == true
	main.Level.Visible = data.IsIndex ~= true
	main.IndexLevel.Visible = data.IsIndex == true
	main.IndexShiny.Visible = data.IsIndex == true

	if data.IsIndex then
		main.IndexLevel.Main.Text = "Level " .. (data2.Level or 1)
		main.IndexShiny.Main.UIGradient.Enabled = data2.Shiny == true
	end

	RenderViewport(data2, data.Owner)
	return true
end

function Fighters:Close(p2)
	if self and not p2 and v.UpdateMode ~= "Mouse" and v.Element then
		return
	end

	v:SetUpdateMode("Mouse")
	return true
end

function Fighters.Click(p, p2)
	if p == v.Element then
		if v.UpdateMode == "Mouse" then
			v:SetUpdateMode("Element")
		else
			v:SetUpdateMode("Mouse")
		end
	else
		if v.Element then
			v:Open(p, p2, true)
			return
		end

		v:SetUpdateMode("Element")
		v:Open(p, p2)
	end
end

mutation.LayoutOrder = 1
mutation.Visible = false
mutation.Main.Title.Text = ""
mutation.Main.Value.Text = ""
v:SetSafeBound(0.1)
v:SetRestrictedToOne(true)
v:SetOpenHandler(Fighters.Open, {
	IsFake = "boolean",
	Data = {
		Name = "string"
	}
})
v:SetCloseHandler(Fighters.Close)
v:SetClickHandler(Fighters.Click)
v:SetRefreshHandler(Fighters.Refresh)
scope:Hydrate(main.Level.Bar.Slider)({
	Size = scope:Spring(value, 25, 1)
})
module.Button:Create(main.Equip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Fighters", "Equip", data.ID)
end)
module.Button:Create(main.Unequip.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Fighters", "Equip", data.ID)
end)
module.Button:Create(main.RemoveFromProfile.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not (params and params.IsFromProfile) then
		return
	end

	local ID = params.Data.ID
	local v3 = nil

	for k, fighter in module.Data.Profile.Fighters do
		if fighter ~= ID then
			continue
		end

		v3 = tonumber(k)
		break
	end

	if not v3 then
		return
	end

	module.Signal:Fire("General", "Profile", "SetFighter", v3)
end)
module.Button:Create(main.Lock.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Fighters", "Lock", {
		[data.ID] = true
	})
end)
module.Button:Create(main.Unlock.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	module.Signal:Fire("General", "Fighters", "Lock", {
		[data.ID] = true
	})
end)
module.Button:Create(main.Sell.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	local v3 = module.Shared.Fighters.List[data.Name]

	if not v3 or v3.Sellable == false then
		return
	end

	local ID = data.ID
	local v4 = not v3.Price and "" or ` for {module.Utils.Number:Format(v3.Price.Amount)} {v3.Price.Name}`
	module.Signal:FireSelf("Interface", "Confirmation", "Start", {
		Title = "Sell",
		Description = `Sell {data.Name}{v4}?`,
		ConfirmText = "Sell",
		CancelText = "Cancel",
		Callback = function(p)
			if p and module.Data.Fighters.List[ID] then
				module.Signal:Fire("General", "Fighters", "Sell", {
					[ID] = true
				})
			end
		end
	})
end)
module.Button:Create(main.Feed.Main, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params then
		return
	end

	local data = params.Data
	v:Close(nil, true)
	module.Signal:FireSelf("Interface", "FighterFeed", "Start", data.ID)
end)
module.Button:Create(main.IndexShiny.Main, "Small"):BindFunction("Click", function()
	local params = v.Params

	if not (params and params.IsIndex) then
		return
	end

	local data = params.Data
	data.Shiny = not data.Shiny
	main.IndexShiny.Main.UIGradient.Enabled = data.Shiny == true
	RenderViewport(data, params.Owner)
	Fighters.Refresh()
end)
main.IndexLevel.Main.FocusLost:Connect(function()
	local params = v.Params

	if not (params and params.IsIndex) then
		return
	end

	local data = params.Data
	local playerData = params.PlayerData or module.Data
	local fighterMaxLevel = module.Shared.Fighters.GetFighterMaxLevel(data, playerData)
	local level = math.clamp(math.floor(tonumber(main.IndexLevel.Main.Text) or data.Level or 1), 1, fighterMaxLevel)
	data.Level = level
	main.IndexLevel.Main.Text = "Level " .. level
	Fighters.Refresh()
end)
local main2 = fighters.Others.Trait.Main
local textButton = Instance.new("TextButton")
textButton.Name = "OpenTraits"
textButton.Size = UDim2.fromScale(1, 1)
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.ZIndex = main2.ZIndex + 1
textButton.Parent = main2
module.Button:Create(textButton, "Default"):BindFunction("Click", function()
	local params = v.Params

	if not params or params.IsFake or params.IsIndex or params.IsFromProfile then
		return
	end

	local ID = params.Data.ID

	if not module.Data.Fighters.List[ID] then
		return
	end

	v:Close(nil, true)
	module.Signal:FireSelf("Interface", "Traits", "SelectFighter", ID)
	module.Signal:FireSelf("Interface", "Traits", "Start")
end)
module:OnDataChanged({ "Fighters" }, Fighters.Refresh)
return Fighters