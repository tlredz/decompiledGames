local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local profession = module.Interface:WaitForChild("Frames"):WaitForChild("Profession")
local scroll = profession:WaitForChild("List"):WaitForChild("Scroll")
local upgrade = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profession"):WaitForChild("Default"):WaitForChild("Upgrade")
local v = {}
local innerScopes = {}
local v2 = nil
local Default = {}

local function GetPerkText(levelInformation)
	local name = next(levelInformation.Perks)

	if not name then
		return ""
	end

	local v4 = module.Shared.Perks[name] or {}
	return module.Utils.Multipliers.ToStringSingle({
		Name = name,
		ShowPercentage = not v4.NumericOnly,
		MultiplierArray = { levelInformation.Perks[name] }
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRequirementLabel(requirement)
	if requirement.Type == "Kill" then
		return requirement.Name and requirement.Name .. " Kills" or "Kills"
	end

	return requirement.Type
end

local function UpdateCard(instance, name, upgrade2)
	local currentLevel = module.Shared.Profession.GetCurrentLevel(v2, name, module.Data)
	instance.Main.Title.Text = name
	instance.Main.Level.Text = "Level " .. currentLevel

	if upgrade2.Icon then
		instance.Main.Icon.Image = upgrade2.Icon
	end

	local levelInformation = module.Shared.Profession.GetLevelInformation(v2, name, (math.max(1, currentLevel)))
	instance.Main.Info.Perk.Value.Text = levelInformation and GetPerkText(levelInformation) or ""
	instance.Main.Buttons.Upgrade.Visible = false
	instance.Main.Buttons.LockedButton.Visible = false
	instance.Main.Buttons.Maxed.Visible = false

	if upgrade2.MaxLevel <= currentLevel then
		instance.Main.Buttons.Maxed.Visible = true
		instance.Main.Info.Requirement.Value.Text = "MAXED"
	else
		local levelInformation2 = module.Shared.Profession.GetLevelInformation(v2, name, currentLevel + 1)

		if not levelInformation2 then
			return
		end

		local currentProgress = module.Shared.Profession.GetCurrentProgress(v2, name, module.Data)
		local value = instance.Main.Info.Requirement.Value
		local formatted = module.Utils.Number:Format((math.min(currentProgress, levelInformation2.Requirement.Amount)))
		local formatted2 = module.Utils.Number:Format(levelInformation2.Requirement.Amount)
		local requirementLabel = GetRequirementLabel(levelInformation2.Requirement) -- equivalent call inferred; original call site unknown
		value.Text = formatted .. "/" .. formatted2 .. " " .. requirementLabel

		if module.Shared.Profession.CanUpgrade(v2, name, module.Data) then
			instance.Main.Buttons.Upgrade.Visible = true
		else
			instance.Main.Buttons.LockedButton.Visible = true
		end
	end
end

local v3 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(0.5, 1.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = upgrade:Clone()
		self.Instance.Name = self.Name
		self.Instance.LayoutOrder = self.Info.Index or 0
		module.Button:Create(self.Instance.Main.Buttons.Upgrade.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profession", "Upgrade", v2, self.Name)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local upgrade2 = module.Shared.Profession.List[v2].Upgrades[self.Name]
		UpdateCard(self.Instance, self.Name, upgrade2)
	end
}
local scope = fusion.scoped(fusion, v3)

function Default.UpdateAll()
	if not v2 then
		return
	end

	for _, v4 in innerScopes do
		v4:Update()
	end
end

function Default.Generate()
	local v4 = module.Shared.Profession.List[v2]

	if not v4 then
		return
	end

	local total = 0

	for k, upgrade2 in v4.Upgrades do
		if innerScopes[k] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = k
		innerScope.Info = upgrade2

		if innerScope:Build(total) then
			innerScopes[k] = innerScope
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end
end

function Default.Clear()
	for _, v4 in innerScopes do
		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(innerScopes)
end

function Default.Start(p: string)
	v2 = p
	v.Profession = module:OnDataChanged({ "Profession" }, Default.UpdateAll)
	module.Frame:Open(profession)
	Default.Generate()
end

function Default.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Default.Clear()
	v2 = nil
end

module.Frame:OnFrameClosed(profession, function()
	module.Signal:FireSelf("Interface", "Profession", "Stop")
end)
return Default