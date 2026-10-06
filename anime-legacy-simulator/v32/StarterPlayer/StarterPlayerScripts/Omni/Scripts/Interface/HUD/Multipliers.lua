local module = require("@game/ReplicatedStorage/Omni")
local v = {
	["Player Damage"] = Color3.fromRGB(255, 75, 75),
	["Fighter Damage"] = Color3.fromRGB(255, 145, 55),
	Luck = Color3.fromRGB(85, 255, 85),
	["Gacha Luck"] = Color3.fromRGB(180, 100, 255),
	Drops = Color3.fromRGB(60, 225, 255),
	Yen = Color3.fromRGB(255, 205, 55),
	["Player Exp"] = Color3.fromRGB(90, 155, 255),
	["Shiny Chance"] = Color3.fromRGB(255, 255, 120)
}
local uDim = UDim2.fromScale(0.25, 0)
local uDim2 = UDim2.fromScale(0.95, 0)
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local SidePanels = require(script.Parent.SidePanels)
local v2 = {
	{
		Name = "Player Damage",
		Function = "PlayerDamage",
		Format = "Multiplier"
	},
	{
		Name = "Fighter Damage",
		Function = "FighterDamage",
		Format = "Multiplier"
	},
	{
		Name = "Luck",
		Function = "Luck",
		Format = "Add"
	},
	{
		Name = "Gacha Luck",
		Function = "GachaLuck",
		Format = "Add"
	},
	{
		Name = "Drops",
		Function = "Drops",
		Format = "Drops"
	},
	{
		Name = "Yen",
		Function = "Yen",
		Format = "Multiplier"
	},
	{
		Name = "Player Exp",
		Function = "PlayerExp",
		Format = "Multiplier"
	},
	{
		Name = "Shiny Chance",
		Function = "ShinyChance",
		Format = "Percentage"
	}
}
local v3 = nil

for _, child in module.Interface:WaitForChild("HUD"):GetChildren() do
	if not (child.Name == "Multipliers" and child:FindFirstChild("List") and child:FindFirstChild("Arrow")) then
		continue
	end

	v3 = child
	break
end

local list = v3:WaitForChild("List")
local scroll = list:WaitForChild("Scroll")
local arrow = v3:WaitForChild("Arrow")
local multiplier = module.Assets.Interface.Templates.Multipliers.Multiplier
local v5 = false
local v6 = false
local flag = false
local count = 0
local v7 = {}
local v8 = {}
local v9 = nil
local value = scope:Value(uDim2)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(0)
local spring2 = scope:Spring(value2, 10, 1)
local Multipliers = {}

local function Clear()
	for k, v10 in v8 do
		v10.Instance:Destroy()
		v10.Scope:doCleanup()
		v8[k] = nil
	end
end

local function IsContextChange(list2)
	local v10 = list2[1]
	return v10 == "Gamemode" or v10 == "Maps" and (list2[2] == nil or list2[2] == "Current")
end

local function IsRelevantChange(p, p2, list2)
	local v10 = list2[1]
	local v11

	if v10 == "Gamemode" then
		v11 = true
	elseif v10 == "Maps" then
		v11 = list2[2] == nil or list2[2] == "Current"
	else
		v11 = false
	end

	if v11 then
		return true
	end

	return module.Utils.Multipliers.IsDataChangeRelevant(list2, p, p2)
end

local function Update()
	if not v5 or flag then
		return
	end

	for _, v10 in v2 do
		local v11 = v8[v10.Name]
		local v12, v13 = module.Utils.PlayerStats[v10.Function](module.Data, module.Instance)
		local formatted = module.Utils.Number:Format(v12)
		local v14

		if v10.Format == "Add" then
			v14 = "+" .. formatted
		elseif v10.Format == "Drops" then
			v14 = "+" .. formatted .. " / " .. module.Utils.Number:Format(v13) .. "x"
		elseif v10.Format == "Percentage" then
			v14 = formatted .. "%"
		else
			v14 = formatted .. "x"
		end

		v11.Instance.Title.Text = v10.Name .. ": " .. v14
	end
end

local function Open()
	count += 1
	local v10 = count
	v5 = true
	list.Visible = true

	for k, v11 in v2 do
		local scope2 = scope:innerScope()
		local position = scope2:Value(UDim2.fromScale(1.5, 0.5))
		local spring3 = scope2:Spring(position, 10, 1)
		local clone = multiplier:Clone()
		clone.Name = v11.Name
		clone.LayoutOrder = k
		local v12 = v[v11.Name]
		local colorSequence = ColorSequence.new(v12:Lerp(Color3.new(1, 1, 1), 0.35), v12)
		clone.Background.UIGradient.Color = colorSequence
		clone.Title.UIGradient.Color = colorSequence
		scope2:Hydrate(clone.Background)({
			Position = spring3
		})
		scope2:Hydrate(clone.Title)({
			Position = spring3
		})
		clone.Parent = scroll
		clone.Visible = true
		v8[v11.Name] = {
			Instance = clone,
			Scope = scope2,
			Position = position,
			PositionSpring = spring3,
			Index = k
		}
		task.delay((k - 1) * 0.05, function()
			if flag or not v5 or count ~= v10 then
				return
			end

			position:set(UDim2.fromScale(0.5, 0.5))
		end)
	end

	Update()
	v7.Data = module:OnDataChangedDeferred({}, Update, IsRelevantChange)
	value:set(uDim)
	value2:set(180)
end

local function Close()
	v5 = false
	count += 1

	if v7.Data then
		v7.Data:Disconnect()
		v7.Data = nil
	end

	for _, v10 in v8 do
		v10.Position:set(UDim2.fromScale(1.5, 0.5))
	end

	value:set(uDim2)
	value2:set(0)
	local v10 = os.clock() + 3

	while true do
		task.wait()

		if flag then
			break
		end

		local v11 = math.abs(fusion.peek(spring).X.Scale - uDim2.X.Scale) * v3.AbsoluteSize.X
		local v12 = math.abs((fusion.peek(spring2)))

		if not (v11 <= 1 and v12 <= 1 or v10 <= os.clock()) then
			continue
		end

		list.Visible = false
		spring:setPosition(uDim2)
		spring:setVelocity(UDim2.fromScale(0, 0))
		spring2:setPosition(0)
		spring2:setVelocity(0)
		Clear()
		break
	end
end

function Multipliers.Start()
	SidePanels.Open("Multipliers")
end

function Multipliers.Stop()
	SidePanels.Close("Multipliers")
end

function Multipliers.Toggle()
	SidePanels.Toggle("Multipliers")
end

function Multipliers.Destroy()
	if flag then
		return
	end

	flag = true
	v5 = false
	count += 1
	SidePanels.Unregister("Multipliers")

	for _, connection in v7 do
		connection:Disconnect()
	end

	table.clear(v7)
	list.Visible = false

	if v9 then
		v9:UnbindFunction("Click")
	end

	Clear()
	scope:doCleanup()
end

function Multipliers.Init()
	if v6 or flag then
		return
	end

	v6 = true
	list.Visible = false
	SidePanels.Register("Multipliers", {
		Arrow = arrow,
		CanOpen = function()
			return not flag
		end,
		Open = Open,
		Close = Close
	})
	v9 = module.Button:Create(arrow.Main, "Small")
	v9:BindFunction("Click", Multipliers.Toggle)
	scope:Hydrate(arrow)({
		Position = spring,
		Rotation = spring2
	})
	v7.Weather = module.Services.ReplicatedStorage:GetAttributeChangedSignal(module.Shared.Weather.AttributeName):Connect(Update)
	v7.Destroying = v3.Destroying:Connect(Multipliers.Destroy)
end

return Multipliers