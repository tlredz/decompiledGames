local module = require("@game/ReplicatedStorage/Omni")
local potions = module.Interface:WaitForChild("Frames"):WaitForChild("Potions")
local scroll = potions:WaitForChild("List"):WaitForChild("Scroll")
local potion = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Potions"):WaitForChild("Potion")
local flag = false
local flag2 = false
local v = {}
local Potions = {}

local function FormatTime(remaining: number)
	local v2 = math.ceil(remaining)
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 / 60) % 60

	if v3 > 0 then
		return string.format("%02d:%02d:%02d", v3, v4, v2 % 60)
	end

	return string.format("%02d:%02d", v4, v2 % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveCard(k: string)
	local v2 = v[k]

	if not v2 then
		return
	end

	v[k] = nil
	v2.Instance:Destroy()
end

local function CreateCard(p: string, data)
	local clone = potion:Clone()
	clone.Name = p
	clone.LayoutOrder = data.Index
	clone.Main.Title.Text = p
	clone.Main.Icon.Image = data.Icon
	clone.Main.Icon.Visible = true
	clone.Main.Viewport.Visible = false
	clone.Main.UIGradient:SetAttribute("Rarity", data.Rarity)
	clone.Main.Paused.Active = false
	clone.Main.Paused.Icon.Active = false
	clone.Main.Inferior.Active = false
	clone.Main.Inferior.Icon.Active = false
	clone.Parent = scroll
	clone.Visible = true
	local v2 = {
		Instance = clone
	}
	v[p] = v2
	module.Button:Create(clone.Main, "Default"):BindFunction("Click", function()
		if flag2 then
			return
		end

		local potion2 = module.Data.Commerce.Potions[p]

		if not potion2 or potion2.Remaining <= 0 then
			return
		end

		flag2 = true
		local success, result = pcall(function()
			return module.Signal:Invoke("General", "Marketplace", "SetPotionPaused", p, potion2.Paused ~= true)
		end)
		flag2 = false

		if not (success and result) then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "This potion could not be updated.",
				Color = Color3.new(1, 1, 0)
			})
		end

		Potions.Refresh()
	end)
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsInferior(p: string, p2, potion2, active)
	if potion2.Paused == true then
		return false
	end

	local v2 = active[p2.Effect]

	if v2 and v2 ~= p then
		return module.Shared.Potions.List[v2].Amount >= p2.Amount
	end

	return false
end

function Potions.Refresh()
	if not flag then
		return
	end

	local v2 = {}

	for k, potion2 in module.Data.Commerce.Potions do
		local v3 = module.Shared.Potions.List[k]

		if not module.Shared.Potions.IsConfigured(v3) or potion2.Remaining <= 0 then
			continue
		end

		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		return module.Shared.Potions.List[a].Index < module.Shared.Potions.List[b].Index
	end)
	local active = module.Shared.Potions.GetActive(module.Data)

	for _, v3 in v2 do
		local potion2 = module.Data.Commerce.Potions[v3]
		local v4 = module.Shared.Potions.List[v3]
		local v5 = v[v3] or CreateCard(v3, v4)
		v5.Instance.Main.Time.Text = FormatTime(potion2.Remaining)
		v5.Instance.Main.Time.Visible = true
		v5.Instance.Main.Paused.Visible = potion2.Paused == true
		local inferior = v5.Instance.Main.Inferior
		local visible = IsInferior(v3, v4, potion2, active) -- equivalent call inferred; original call site unknown
		inferior.Visible = visible
	end

	for k in v do
		local potion2 = module.Data.Commerce.Potions[k]

		if not (not potion2 or potion2.Remaining <= 0 or not module.Shared.Potions.IsConfigured(module.Shared.Potions.List[k])) then
			continue
		end

		RemoveCard(k) -- equivalent call inferred; original call site unknown
	end
end

function Potions.Start()
	flag = true
	Potions.Refresh()
end

function Potions.Stop()
	flag = false
end

function Potions.Init()
	module.Frame:OnFrameOpened(potions, Potions.Start)
	module.Frame:OnFrameClosed(potions, Potions.Stop)
end

local connection = module:OnDataChanged({ "Commerce" }, function()
	if flag then
		Potions.Refresh()
		return
	end

	for k in v do
		if module.Data.Commerce.Potions[k] then
			continue
		end

		RemoveCard(k) -- equivalent call inferred; original call site unknown
	end
end)
potions.Destroying:Once(function()
	Potions.Stop()
	connection:Disconnect()

	for k in v do
		RemoveCard(k) -- equivalent call inferred; original call site unknown
	end
end)
return Potions