local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Common.MarketplaceService)
local maid = v4.Maid
local _ = v4.ValueConvertor
require3(ReplicatedStorage2.Shared.ClansActivityData)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.NewQuestData)
local v6 = require3(ReplicatedStorage2.Shared.ClanCrateData)
require3(ReplicatedStorage2.Shared.LootboxData)
local v7 = require3(script.CrateAnimation)
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local clans = nil
local overview = nil
local views = nil
local clanCrates = nil
local rewards = nil
local holder = nil
local main = nil
local holder2 = nil
local itemHolder = nil
local v12 = nil
local maid2 = maid.new()

local function parseChestData(value)
	local v13 = {}

	for k in string.gmatch(value, "([^:]+)") do
		table.insert(v13, k)
	end

	return {
		uuid = v13[1],
		playerName = v13[2],
		userId = tonumber(v13[3]),
		crateLevel = tonumber(v13[4])
	}
end

local ClanCrateController = {}

function ClanCrateController:HookRewards(object)
	local maid3 = maid.new()
	maid2:GiveTask(maid3)

	local function generateRewards()
		maid3:DoCleaning()
		local v13 = object:Get("Info.CrateLevel") or 1

		for _, crateLevel in v6.crateLevels do
			local clone = script.RewardTemplate:Clone()
			clone.Parent = holder
			maid3:GiveTask(clone)
			clone.Level.Text = `Level {crateLevel.level}`

			for childName, v14 in crateLevel.SimpleReward do
				local child = clone:FindFirstChild(childName)

				if not child then
					continue
				end

				child.Visible = true
				local amount = child:FindFirstChild("Amount")
				amount.Text = `x{v14}`

				if childName == "Crowns" then
					child.ItemImg.Image = v4.Icons:GetIcon("Crowns")
				end

				if childName == "Crowns" and crateLevel.SimpleReward.ClanMagicalChest then
					child.Position = UDim2.fromScale(0.98, 0.5)
				end
			end

			if v13 == crateLevel.level then
				clone.Glow.Visible = true
			else
				clone.Glow.Visible = false
			end
		end
	end

	maid2:GiveTask(v2.observeReplionPath(object, "Info.CrateLevel", generateRewards))
end

function ClanCrateController:HookClaims(object)
	local v13 = maid.new()
	maid2:GiveTask(v13)

	local function generateClaims()
		v13:DoCleaning()
		local v14 = object:Get("Info.PurchasedChests") or {}
		local clanCrates2 = v12:Get("ClanCrates") or {}

		for _, v15 in v14 do
			local v16 = parseChestData(v15)

			if clanCrates2[v16.uuid] then
				continue
			end

			local clone = script.CrateTemplate:Clone()
			clone.Parent = holder2.Holder
			clone.PlrIcon.Image = `rbxthumb://type=AvatarHeadShot&id={v16.userId}&w=100&h=100`
			clone.PlrName.Text = v16.playerName
			local crateLevel = v6.crateLevels[v16.crateLevel]
			clone.Reward.Level.Text = `Level: {v16.crateLevel}`
			clone.Reward.Image = crateLevel.icon
			local _ = clone.Reward
			local flag = false
			local v17 = v16
			v13:GiveTasks({ clone, clone.Claim.Activated:Connect(function()
					if flag then
						return
					end

					flag = true
					v3:Invoke("ClaimCrate", v17.uuid)
					flag = false
				end) })
		end
	end

	maid2:GiveTask(v2.observeReplionPath(object, "Info.PurchasedChests", generateClaims))
	maid2:GiveTask(v2.observeReplionPath(v12, "ClanCrates", generateClaims))
	local purchase = itemHolder:WaitForChild("Purchase")
	local flag = false
	maid2:GiveTask(purchase.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		v8:FireServer()
	end))

	local function updateChest()
		local v14 = object:Get("Info.CrateLevel") or 1
		local crateLevel = v6.crateLevels[math.min(v14, #v6.crateLevels)]
		itemHolder.ItemIcon.Image = not crateLevel and "" or crateLevel.icon or ""
		itemHolder.ChestLevel.Text = `Lv.{v14}`
		local v15 = 0

		for _, v16 in object:Get("Info.PurchasedChests") or {} do
			if parseChestData(v16).crateLevel == v14 then
				v15 = math.clamp(v15 + 1, 0, crateLevel.purchasesRequired)
			end
		end

		itemHolder.ChestProgress.Text = `{v15}/{crateLevel.purchasesRequired}`
		itemHolder.Progress.Fill.Size = UDim2.fromScale(math.clamp(v15 / crateLevel.purchasesRequired, 0, 1), 1)
		purchase.Price.Text = `{crateLevel.cost}`
	end

	maid2:GiveTask(v2.observeReplionPath(object, "Info.CrateLevel", updateChest))
	maid2:GiveTask(v2.observeReplionPath(object, "Info.VisualUpdate", updateChest))
	maid2:GiveTask(v2.observeReplionPath(object, "Info.PurchasedChests", updateChest))
	v5.PromptProductPurchaseFinished:Connect(function(_, _, _)
		flag = false
	end)
end

function ClanCrateController.Init(_)
	v10 = require3(ReplicatedStorage2.Controllers.Clans.ClanController)
	v11 = require3(ReplicatedStorage2.Controllers.Clans.ClanPageController)
end

function ClanCrateController:Start()
	v12 = v.Client:WaitReplion("Data")
	playerGui = localPlayer.PlayerGui
	clans = playerGui:WaitForChild("Clans")
	overview = clans:WaitForChild("Overview")
	views = overview:WaitForChild("Views")
	clanCrates = views:WaitForChild("ClanCrates")
	rewards = clanCrates:WaitForChild("Rewards")
	holder = rewards:WaitForChild("Holder")
	v8 = v3:RemoteEvent("ClanCratePurchase")
	v9 = v3:RemoteEvent("ClanCrateSpinStarted")
	main = clanCrates:WaitForChild("Main")
	holder2 = main:WaitForChild("Holder")
	itemHolder = main:WaitForChild("ItemHolder")
	main.Close.Activated:Connect(function()
		v11:OpenPage("Overview")
	end)
	local openCrate = clans:WaitForChild("OpenCrate")
	v9.OnClientEvent:Connect(function(p, _, p2)
		v7:DoAnimation(openCrate, p2, p)
	end)
	overview.ChatBoxContainer.Buttons.XPButton.Activated:Connect(function()
		v11:OpenPage("ClanCrates")
	end)
	v10:ObserveClan(function(p, _: string)
		self:HookRewards(p)
		self:HookClaims(p)
		return function()
			maid2:DoCleaning()
		end
	end)
end

return ClanCrateController