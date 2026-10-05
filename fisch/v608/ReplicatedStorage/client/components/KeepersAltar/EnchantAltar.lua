local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local Signal = require(packages.Signal)
local modules = ReplicatedStorage.shared.modules
local SharedDataHelper = require(modules.SharedDataHelper)
local SharedKeeperEnchant = require(modules.SharedKeeperEnchant)
local rods = require(modules.library.rods)
local fish = require(modules.library.fish)
local enchants = require(modules.library.rods.enchants)
local spears = require(modules.library.spears)
local harpoonGuns = require(modules.library.harpoonGuns)
local spearEnchants = require(modules.library.spears.spearEnchants)
local harpoonEnchants = require(modules.library.harpoonGuns.harpoonEnchants)
local assets = require(ReplicatedStorage.shared.utils.assets)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local ConfirmationController = require(legacyControllers.ConfirmationController)
local HudController = require(legacyControllers.HudController)
local InventoryController = require(legacyControllers.InventoryController)
local PlayerController = require(legacyControllers.PlayerController)
local DataController = require(legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local module = require("./AltarPillar")
local remoteFunction = Net:RemoteFunction("EnchantAltar/Interact", -1)
local remoteEvent = Net:RemoteEvent("EnchantAltar/PlayVfx", -1)
local remoteFunction2 = Net:RemoteFunction("Enchant/ConfirmTarget", -1)
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local v = Component.new({
	Tag = "EnchantAltar",
	Ancestors = { workspace }
})
local color = Color3.new(0, 0, 0)
local v2 = {
	rod = {
		Display = "Fishing Rod",
		Library = rods,
		Enchants = enchants,
		GetEquipped = function()
			local legacyPathValue = SharedDataHelper.readLegacyPathValue(Players.LocalPlayer, { "Stats", "rod" })

			if typeof(legacyPathValue) == "string" and legacyPathValue ~= "" then
				return legacyPathValue
			end

			return nil
		end,
		GetRecord = function(p: string)
			return SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "Rods", p })
		end
	},
	spear = {
		Display = "Spear",
		Library = spears,
		Enchants = spearEnchants,
		GetEquipped = function()
			local legacyPathValue = SharedDataHelper.readLegacyPathValue(Players.LocalPlayer, { "Stats", "spear" })

			if typeof(legacyPathValue) == "string" and legacyPathValue ~= "" then
				return legacyPathValue
			end

			return nil
		end,
		GetRecord = function(p: string)
			return SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "Spears", p })
		end
	},
	harpoon = {
		Display = "Harpoon Gun",
		Library = harpoonGuns,
		Enchants = harpoonEnchants,
		GetEquipped = function()
			local indexNewFormat = SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "HarpoonGuns", "Equipped" })

			if typeof(indexNewFormat) == "string" and indexNewFormat ~= "" then
				return indexNewFormat
			end

			return nil
		end,
		GetRecord = function(p: string)
			return SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "HarpoonGuns", "Owned", p })
		end
	}
}
local v3 = "rod"
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getToolKind(name: string?)
	if not name then
		return nil
	end

	if rods[name] then
		return "rod"
	end

	if spears[name] then
		return "spear"
	end

	if harpoonGuns[name] then
		return "harpoon"
	end

	return nil
end

local function confirmFirstEnchant(p: string, p2: string)
	if flag then
		return true
	end

	local v4 = v2[p] or v2.rod

	if ConfirmationController.new({
		header = "The Keepers Await",
		text = `You are about to enchant your <b>{p2}</b>.<br/><br/>To enchant a Spear or Harpoon Gun instead, hold it out and interact with the Altar first.`,
		options = {
			{
				text = `Enchant {v4.Display}`
			},
			{
				text = "Cancel",
				color = Color3.fromRGB(255, 161, 161)
			}
		}
	}) ~= 1 then
		return false
	end

	flag = true
	return true
end

local v4 = Signal.new()

function v:Construct()
	self.trove = Trove.new()
	self.Core = self.Instance:WaitForChild("Core")
	self.Prompt = self.Core:WaitForChild("ProximityPrompt")
end

function v:GetState()
	return SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "StatuesSecret", "AltarState" })
end

function v:PlayVfx(p2: string, childName: string)
	local core = self.Instance:WaitForChild("Core")
	local v5 = fish[p2]

	if not v5 then
		return
	end

	local relicColorMain = v5.RelicColorMain or Color3.fromRGB(85, 255, 193)
	local relicColorSecondary = v5.RelicColorSecondary or v5.RelicColorMain or Color3.fromRGB(93, 255, 104)
	local colorSequence = ColorSequence.new(relicColorMain, relicColorSecondary)
	core.sparkles.Color = colorSequence
	core.shine.shine1.Color = colorSequence
	core.shine.worms.Color = colorSequence
	core.circles.a1.Color = colorSequence
	core.ground.g1.Color = colorSequence
	core.shine.shine1.Enabled = true
	core.shine.worms.Enabled = true
	core.ground.g1:Emit(1)
	core.circles.a1:Emit(3)
	core.enchantPurchase:Play()
	core.enchantsfx:Play()
	local clone

	if rods[childName] then
		clone = assets.getAsync("rod", childName):WaitForChild(childName):Clone()
	end

	for _, part in pairs(not clone and {} or clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end

	if clone and clone:FindFirstChild("handle") then
		clone.handle.Anchored = true
		clone.handle.CFrame = core.CFrame * CFrame.new(-0.093, -2.338, 1.049) * CFrame.Angles(-0.4311312318276393, 0, 0)
		clone.Parent = workspace.active
	end

	task.wait(0.5)
	core.shine.shine1.Enabled = false
	core.shine.worms.Enabled = false
	task.wait(0.5)
	core.sparkles:Emit(math.random(60, 70))

	if p2 ~= "Enchant Relic" then
		core.exalted:Play()
	end

	if clone then
		clone:Destroy()
	end
end

function v:ShowPrompt(p: string, p2: string?)
	local v5 = v2[v3] or v2.rod
	local enchants2 = v5.Enchants
	local equipped = v5.GetEquipped()

	if not equipped then
		anno_localthought:Fire((`You don't have a {v5.Display} equipped!`))
		return false
	end

	local record = v5.GetRecord(equipped)

	if not record then
		warn((`Failed to fetch data for equipped {v5.Display} "{equipped}"`))
		return false
	end

	local v6 = v5.Library[equipped]

	if not v6 then
		warn((`Unknown equipped {v5.Display} "{equipped}"`))
		return false
	end

	local v7 = fish[p]

	if not v7 then
		warn((`Unknown relic "{p}"`))
		return false
	end

	if v3 ~= "rod" and p == "Sovereign Relic" then
		anno_localthought:Fire((`The Keepers have not yet learned to bind that Relic to a {v5.Display}.`))
		return false
	end

	local relicColorMain = v7.RelicColorMain or Color3.fromRGB(85, 255, 193)
	local relicColorSecondary = v7.RelicColorSecondary or v7.RelicColorMain or Color3.fromRGB(93, 255, 104)
	local enchantConfirm = HudController:GetSafeZone():WaitForChild("EnchantConfirm")

	if enchantConfirm.Visible then
		v4:Fire(false)
	end

	local v8 = { "This action cannot be undone." }

	if p == "Sovereign Relic" then
		local v9, v10 = SharedKeeperEnchant.ValidateAltarState(Players.LocalPlayer, self:GetState())

		if not v9 then
			anno_localthought:Fire(v10)
			return false
		end

		if v10 == "ReplenishPower" then
			if record.keeperboundActive and record.enchant then
				table.insert(
					v8,
					1,
					"You have not offered any Relics to the pillars. <font color=\"#ffffff\">This will only refill the Power Level of your rod.</font>"
				)
			else
				anno_localthought:Fire("You must first offer Relics to the pillars...")
				return false
			end
		elseif record.keeperboundEnchant then
			table.insert(
				v8,
				1,
				(`Your current Keeperbound Enchantment, <b>{enchants2:GetRichDisplayName(record.keeperboundEnchant)}</b>, will be <font color="#ffffff">replaced</font>, along with all Affixes.`)
			)
		else
			table.insert(
				v8,
				1,
				"This will convert your rod into a Keeperbound Rod, disabling traditional enchantments. You can switch back by talking to the <font color=\"#ffffff\">Keeper Warden</font>."
			)
		end
	elseif record.keeperboundActive and record.keeperboundEnchant then
		local relicKeeperCharge = v7.RelicKeeperCharge

		if relicKeeperCharge == nil or relicKeeperCharge == 0 then
			anno_localthought:Fire("This Relic cannot be used to recharge a Keeperbound Rod.")
			anno_localthought:Fire("<i>(Speak to the Keeper Warden if you wish to disable Keeperbound for this rod.)</i>")
			return false
		else
			if (record.power or 0) >= 100 and relicKeeperCharge > 0 then
				anno_localthought:Fire((`Your {equipped} is already at maximum power!`))
				return false
			end

			table.clear(v8)
			table.insert(
				v8,
				1,
				(`Since this rod is Keeperbound, this action will instead replenish its Power Level by <font color="#ffffff">{relicKeeperCharge}%</font>.`)
			)
			table.insert(
				v8,
				2,
				"To apply a normal Enchantment, talk to the <font color=\"#ffffff\">Keeper Warden</font> to remove Keeperbound."
			)
		end
	else
		if p == "Admin Relic" then
			return true
		end

		if v7.RelicGroup then
			local v9 = false
			local v10 = false
			local flag2 = false
			local v11

			if record.enchant == nil then
				v11 = false
			else
				v11 = record.enchant ~= "none"
			end

			local v12

			if record.secondaryEnchant == nil then
				v12 = false
			else
				v12 = record.secondaryEnchant ~= "none"
			end

			for k, enchant in enchants2.Enchants do
				if enchant.Keeperbound or enchant.KeeperboundAffix or not (enchant.RelicGroup == v7.RelicGroup or p2 == k) then
					continue
				end

				flag2 = true

				if enchant.Secondary then
					if record.secondaryEnchant ~= k then
						v10 = true
					end
				elseif record.enchant ~= k then
					v9 = true
				end
			end

			local v13 = v9 and v11
			local v14 = v10 and v12

			if v13 and v14 then
				table.insert(
					v8,
					1,
					(`Your current primary enchantment ({enchants2:GetRichDisplayName(record.enchant)}) or secondary enchantment ({enchants2:GetRichDisplayName(record.secondaryEnchant)}) will be <font color="#ffffff">randomly replaced</font>.`)
				)
			elseif v13 then
				table.insert(
					v8,
					1,
					(`Your current primary enchantment, {enchants2:GetRichDisplayName(record.enchant)}, will be <font color="#ffffff">replaced</font>.`)
				)
			elseif v14 then
				table.insert(
					v8,
					1,
					(`Your current secondary enchantment, {enchants2:GetRichDisplayName(record.secondaryEnchant)}, will be <font color="#ffffff">replaced</font>.`)
				)
			elseif not (v9 or v10) then
				if flag2 then
					anno_localthought:Fire((`Your <b>{equipped}</b> already has that enchantment!`))
				else
					anno_localthought:Fire((`The Keepers cannot bind that Relic to a {v5.Display}.`))
				end

				return false
			end
		end
	end

	enchantConfirm.UIScale.Scale = 0.75
	enchantConfirm.header.Text = `Would you like to enchant your <b><font color="#{v6.Color:ToHex()}">{equipped}</font></b> using <b><font color="#{relicColorMain:ToHex()}">{p}</font></b> ×1?`
	enchantConfirm.body.Text = table.concat(v8, "\n")
	local colorSequence = ColorSequence.new(relicColorMain, relicColorSecondary)
	enchantConfirm.corner.UIGradient.Color = colorSequence
	enchantConfirm.Shine.UIGradient.Color = colorSequence
	enchantConfirm.UIStroke.UIGradient.Color = colorSequence
	enchantConfirm.enchantButton.Label.TextColor3 = relicColorMain
	enchantConfirm.enchantButton.Shine.ImageColor3 = relicColorMain
	enchantConfirm.enchantButton.corner.ImageColor3 = relicColorMain
	enchantConfirm.enchantButton.UIStroke.Color = relicColorMain
	enchantConfirm.enchantButton.BackgroundColor3 = relicColorMain:Lerp(color, 0.8)
	enchantConfirm.glowOverlay.ImageColor3 = relicColorMain
	enchantConfirm.glowOverlay.UIGradient.Offset = Vector2.new(0, -1)
	enchantConfirm.glowOverlay.inner.BackgroundColor3 = relicColorSecondary
	enchantConfirm.glowOverlay.inner.UIGradient.Offset = Vector2.new(0, -1)
	enchantConfirm.glowOverlay.SliceScale = 2
	enchantConfirm.glowOverlay.Visible = true
	enchantConfirm.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, relicColorMain:Lerp(color, 0.6)),
		ColorSequenceKeypoint.new(0.5, relicColorMain:Lerp(relicColorSecondary, 0.5):Lerp(color, 0.75)),
		ColorSequenceKeypoint.new(1, relicColorSecondary:Lerp(color, 0.8))
	})
	enchantConfirm.Visible = true
	TweenService:Create(enchantConfirm.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Scale = 1
	}):Play()
	TweenService:Create(enchantConfirm.glowOverlay.UIGradient, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		Offset = Vector2.new(0, 1)
	}):Play()
	TweenService:Create(enchantConfirm.glowOverlay, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
		SliceScale = 0.1
	}):Play()
	TweenService:Create(enchantConfirm.glowOverlay.inner.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
		Offset = Vector2.new(0, 1)
	}):Play()
	local v9 = v4:Wait()
	enchantConfirm.Visible = false
	return v9
end

function v:UpdatePrompt()
	local v5 = v2[v3] or v2.rod
	local equipped = v5.GetEquipped()
	local prompt = self.Prompt
	local actionText

	if equipped then
		actionText = `Enchant "{equipped}"`
	else
		actionText = `Enchant {v5.Display}`
	end

	prompt.ActionText = actionText
end

function v:PromptSwitchTarget(p: string, p2: string)
	local v5 = v2[p]

	if not v5 then
		return
	end

	if p == v3 then
		anno_localthought:Fire((`The Altar is already set to enchant your <b>{v5.Display}</b>.`))
		return
	end

	local v6 = v2[v3] or v2.rod
	self.Prompt.Enabled = false
	PlayerController:ToggleControls(false)

	if ConfirmationController.new({
		header = "Switch Target",
		text = `Set the Altar to enchant your <b>{p2}</b> instead of your {v6.Display}?`,
		options = {
			{
				text = `Enchant {v5.Display}`
			},
			{
				text = "Cancel",
				color = Color3.fromRGB(255, 161, 161)
			}
		}
	}) == 1 then
		local v7, v8 = remoteFunction:InvokeServer(p2)

		if v7 then
			v3 = p
			flag = true
			self:UpdatePrompt()
		end

		if v8 then
			anno_localthought:Fire(v8)
		end
	end

	self.Prompt.Enabled = true
	PlayerController:ToggleControls(true)
end

function v:UpdateKeeperCore()
	local enabled = false

	for k, v7 in self:GetState() do
		if not v7 then
			continue
		end

		local v8 = self.Instance:QueryDescendants((`.AltarRelicInput[$RelicType={k}]`))[1]

		if not (v8 and SharedKeeperEnchant.IsPillarActive(Players.LocalPlayer, v8.Parent)) then
			continue
		end

		enabled = true
		break
	end

	for _, child in self.Core:WaitForChild("keepercore"):GetChildren() do
		child.Enabled = enabled
	end
end

function v:Start()
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(...)
		self:PlayVfx(...)
	end))
	self.trove:Add(self.Prompt.Triggered:Connect(function()
		local character = Players.LocalPlayer.Character
		local tool = character and character:FindFirstChildWhichIsA("Tool")
		local name = tool and tool.Name
		local toolKind = getToolKind(name) -- equivalent call inferred; original call site unknown

		if toolKind then
			self:PromptSwitchTarget(toolKind, tool.Name)
			return
		end

		local equippedItem = InventoryController.EquippedItem

		if not (equippedItem and fish[equippedItem.name] and fish[equippedItem.name].RelicGroup) then
			anno_localthought:Fire("You must hold a <font color=\"#78ffb7\"><b>Relic</b></font> to enchant.")
			return
		end

		if ReplicatedStorage.world.cycle.Value ~= "Night" and ReplicatedStorage.world.cycle_timeshift.Value == 0.04 then
			anno_localthought:Fire("The Altar is only active during the <font color='#6551a5'><b>night</b></font>.")
			return
		end

		self.Prompt.Enabled = false
		PlayerController:ToggleControls(false)
		local v5 = v2[v3] or v2.rod
		local equipped = v5.GetEquipped()

		if equipped then
			if confirmFirstEnchant(v3, equipped) and self:ShowPrompt(
				equippedItem.name,
				equippedItem.sub and equippedItem.sub.Enchant
			) then
				local v6, v7 = remoteFunction:InvokeServer(equippedItem.name)

				if not v6 and v7 then
					anno_localthought:Fire(v7)
				end
			end
		else
			anno_localthought:Fire((`You don't have a {v5.Display} equipped!`))
		end

		self.Prompt.Enabled = true
		PlayerController:ToggleControls(true)
	end))
	local legacyPath = SharedDataHelper.readLegacyPath(Players.LocalPlayer, "Stats.rod")

	if legacyPath then
		self.trove:Add(legacyPath.Changed:Connect(function()
			self:UpdatePrompt()
		end))
	end

	local legacyPath2 = SharedDataHelper.readLegacyPath(Players.LocalPlayer, "Stats.spear")

	if legacyPath2 then
		self.trove:Add(legacyPath2.Changed:Connect(function()
			self:UpdatePrompt()
		end))
	end

	self.trove:Add(playerDataReplicator:Listen({ "HarpoonGuns", "Equipped" }, function()
		self:UpdatePrompt()
	end))
	self.trove:Add(module.PillarUpdate:Connect(function()
		self:UpdateKeeperCore()
	end))
	self.trove:Add(playerDataReplicator:Listen({ "StatuesSecret", "AltarState" }, function()
		self:UpdateKeeperCore()
	end))
	self:UpdatePrompt()
	self:UpdateKeeperCore()
end

function v.Stop(p)
	p.trove:Clean()
end

task.spawn(function()
	local enchantConfirm = HudController:GetSafeZone():WaitForChild("EnchantConfirm")
	enchantConfirm.enchantButton.Activated:Connect(function()
		v4:Fire(true)
	end)
	enchantConfirm.cancelButton.Activated:Connect(function()
		v4:Fire(false)
	end)
	enchantConfirm:GetPropertyChangedSignal("Visible"):Connect(function()
		if not enchantConfirm.Visible then
			v4:Fire(false)
		end
	end)
	InventoryController.EquippedToolChanged:Connect(function()
		v4:Fire(false)
	end)
end)

remoteFunction2.OnClientInvoke = function(p: string, p2: string)
	return (confirmFirstEnchant(p, p2))
end

return v