local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local sacredArtefacts = module.Interface:WaitForChild("Frames"):WaitForChild("Sacred Artefacts")
local scroll = sacredArtefacts:WaitForChild("List"):WaitForChild("Scroll")
local artefact = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Artefact")
local v = {}
local innerScopes = {}
local SacredArtefacts = {}

local function UpdateCard(instance, name, data)
	instance.Main.Title.Text = name

	if data.Icon then
		instance.Main.Icon.Image = data.Icon
	end

	local isUnlocked = module.Shared.SacredArtefacts.IsUnlocked(name, module.Data)
	instance.Main.LockedFrame.Visible = not isUnlocked
	instance.Main.UnlockedFrame.Visible = isUnlocked

	if not isUnlocked then
		instance.Main.LockedFrame.ObtainmentMethod.Text = data.ObtainmentMethod
		return
	end

	local count = module.Shared.SacredArtefacts.GetCount(name, module.Data)
	local currentRarity = module.Shared.SacredArtefacts.GetCurrentRarity(name, module.Data)
	local nextRarity = module.Shared.SacredArtefacts.GetNextRarity(name, module.Data)

	if nextRarity then
		local v2 = data.Needed[nextRarity] or count
		instance.Main.UnlockedFrame.Rarity.Text = currentRarity .. " (" .. module.Utils.Number:Format(count) .. "/" .. module.Utils.Number:Format(v2) .. ")"
	else
		instance.Main.UnlockedFrame.Rarity.Text = currentRarity .. " (MAXED)"
	end

	local levelInformation = module.Shared.SacredArtefacts.GetLevelInformation(name, currentRarity)

	if not levelInformation then
		instance.Main.UnlockedFrame.Perks.Text = ""
		return
	end

	local perksArray = {}
	local showPercentageForMultipliers = {}

	for k, perk in levelInformation.Perks do
		perksArray[k] = { perk }

		if not (module.Shared.Perks[k] or {}).NumericOnly then
			table.insert(showPercentageForMultipliers, k)
		end
	end

	instance.Main.UnlockedFrame.Perks.Text = module.Utils.Multipliers.ToStringTable({
		IsRich = true,
		ShowPercentageForMultipliers = showPercentageForMultipliers,
		PerksArray = perksArray
	})
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = artefact:Clone()
		self.Instance.Name = self.Name
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(UDim2.fromScale(1, 1))
			end)
		else
			self.Size:set(UDim2.fromScale(1, 1))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v2 = module.Shared.SacredArtefacts.List[self.Name]
		UpdateCard(self.Instance, self.Name, v2)
	end
})

function SacredArtefacts.UpdateAll()
	for _, v2 in innerScopes do
		v2:Update()
	end
end

function SacredArtefacts.Generate()
	local total = 0

	for k in module.Shared.SacredArtefacts.List do
		if innerScopes[k] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = k

		if innerScope:Build(total) then
			innerScopes[k] = innerScope
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end
end

function SacredArtefacts.Clear()
	for _, v2 in innerScopes do
		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)
end

function SacredArtefacts.Start()
	v.Index = module:OnDataChanged({ "Index" }, SacredArtefacts.UpdateAll)
	SacredArtefacts.Generate()
end

function SacredArtefacts.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	SacredArtefacts.Clear()
end

module.Frame:OnFrameOpened(sacredArtefacts, SacredArtefacts.Start)
module.Frame:OnFrameClosed(sacredArtefacts, SacredArtefacts.Stop)
return SacredArtefacts