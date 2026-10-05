local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
HudController:GetHud()
local safeZone = HudController:GetSafeZone()
local harpoonCrafting = safeZone:WaitForChild("HarpoonCrafting")
local scrollingFrame = harpoonCrafting:WaitForChild("List").ScrollingFrame
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local library = shared.modules.library
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local fish = require(library.fish)
local items = require(library.items)
local harpoonGuns = require(library.harpoonGuns)
require(shared.modules.fishing.mutations)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)

if FischUtils.IsTradePlaza() then
	return {}
end

local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(script.Parent.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local remoteEvent = Net:RemoteEvent("Harpoon/ShowCrafting", -1)
local remoteFunction = Net:RemoteFunction("Harpoon/AttemptCraft", -1)
local remoteEvent2 = Net:RemoteEvent("HarpoonGunCrafting/TrackRecipe", -1)
local remoteEvent3 = Net:RemoteEvent("HarpoonGunCrafting/UntrackRecipe", -1)
local maid = Trove.new()
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(vector, tweenInfo, p)
	local tween = TweenService:Create(vector, tweenInfo, p)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAmount(p, mutation)
	return DataController.CountItem(p, {
		Mutation = mutation
	}, nil, true)
end

local function updateListCrafted()
	legacyLocalPlayerData.fetch()

	for _, button in scrollingFrame:GetChildren() do
		if not (button:IsA("GuiButton") and button.Name ~= "Recipe") then
			continue
		end

		if button:FindFirstChild("Crafted") then
			button:FindFirstChild("Crafted"):Destroy()
		end

		if not playerDataReplicator.Data.HarpoonGuns.Owned[button.Name] then
			continue
		end

		local clone = script.Crafted:Clone()
		clone.Parent = button
	end
end

local HarpoonCraftingController = {
	CurrentlySelected = ""
}

local function updateTrackButton()
	local track = harpoonCrafting.Track
	local currentlySelected = HarpoonCraftingController.CurrentlySelected

	if not currentlySelected or currentlySelected == "" or playerDataReplicator:TryIndex({
		"HarpoonGuns",
		"Owned",
		currentlySelected
	}) ~= nil then
		track.Visible = false
		return
	end

	if QuestShared:IsStarted(localPlayer, (`Recipe/{currentlySelected}`)) then
		track.Label.Text = "Untrack"
	else
		track.Label.Text = "Track"
	end

	track.Visible = true
end

function HarpoonCraftingController.UpdateSpearInfo(currentlySelected: string)
	local harpoonGun = harpoonGuns[currentlySelected]

	if not harpoonGun and currentlySelected ~= "" or harpoonGun and not harpoonGun.Recipe then
		return
	end

	legacyLocalPlayerData.fetch()
	local spearInfo = harpoonCrafting.SpearInfo
	local list = harpoonCrafting.Materials.List
	local craft = harpoonCrafting.Craft
	local info = spearInfo.Info
	local stats = spearInfo.Stats
	local vector = spearInfo.Vector
	local gradient = spearInfo.Gradient
	info.Visible = harpoonGun
	vector.Visible = harpoonGun
	gradient.Visible = harpoonGun
	stats.Visible = harpoonGun

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "_material" then
			frame:Destroy()
		end
	end

	maid:Clean()

	if not harpoonGun then
		return
	end

	gradient.BackgroundColor3 = harpoonGun.Color
	info._Name.Text = `[{currentlySelected}]`
	info.Hint.Text = harpoonGun.Hint

	for _, label in stats:GetChildren() do
		if label:IsA("TextLabel") and harpoonGun[label.Name] then
			label.Text = `{label.Name}: {harpoonGun[label.Name]}`
		end
	end

	vector.Image = harpoonGun.Icon
	vector.Shadow.Image = vector.Image
	local count = 0
	local count2 = 0

	for k, material in harpoonGun.Recipe.Materials do
		local name = material[1]
		local v2 = material[2]
		local mutation = material[3]
		local v4 = material[4]
		local v5 = fish[name] or items.Items[name]

		if not v5 then
			continue
		end

		count += 1
		local amount = getAmount(name, mutation) -- equivalent call inferred; original call site unknown

		if amount < v2 then
			count2 += 1
		end

		local clone = list._material:Clone()
		clone.Name = name
		clone.Icon.Image = v4 or v5.Icon or ""
		clone.Amount.Text = `{amount}/{v2}`
		clone.LayoutOrder = k
		clone.Visible = true
		clone.Parent = list
		local name2 = name
		local mutation2 = mutation
		clone.MouseEnter:Connect(function()
			local itemDisplay = FischUtils.ItemDisplay({
				name = name2,
				sub = {
					Mutation = mutation2
				}
			}, {
				rich = true,
				disable_newlines = true
			})
			local clone2 = script.HoverInfo:Clone()
			local label = clone2.Label
			label.Text = itemDisplay
			clone2.Parent = clone
			label.Position = UDim2.fromScale(0.5, -0.25)

			if label.Parent then
				local tween = TweenService:Create(
					label,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Position = UDim2.fromScale(0.5, -0.5)
					}
				)
				tween.Completed:Once(function()
					tween:Destroy()
				end)
				tween:Play()
			end
		end)
		local parent = clone
		clone.MouseLeave:Connect(function()
			for i, child in parent:GetChildren() do
				if child.Name == "HoverInfo" then
					child:Destroy()
				end
			end
		end)
	end

	local interactable

	if count - count2 == count then
		interactable = not playerDataReplicator.Data.HarpoonGuns.Owned[currentlySelected]
	else
		interactable = false
	end

	local visible = playerDataReplicator.Data.HarpoonGuns.Owned[currentlySelected]
	vector.Rotation = -25
	vector.Position = UDim2.fromScale(0.85, 0.6)
	fastTween(vector, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0,
		Position = UDim2.fromScale(0.75, 0.475)
	}) -- equivalent call inferred; original call site unknown
	HarpoonCraftingController.CurrentlySelected = currentlySelected
	local color = interactable and Color3.fromRGB(162, 234, 166) or Color3.fromRGB(118, 123, 140)
	craft.UIStroke.Color = color
	craft.Label.TextColor3 = color
	craft.corner.ImageColor3 = color
	craft.Interactable = interactable
	updateTrackButton()
	vector.ImageColor3 = not visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	info.Crafted.Visible = visible

	if interactable then
		maid:Add(craft.Activated:Connect(function()
			if flag then
				return
			end

			flag = true

			if remoteFunction:InvokeServer(currentlySelected) then
				HarpoonCraftingController.UpdateSpearInfo(currentlySelected)
			end

			flag = false
		end))
	end
end

function HarpoonCraftingController.Start(_)
	playerDataReplicator:WaitForLoaded()
	HarpoonCraftingController.UpdateSpearInfo("")
	local count = 0

	for k, harpoonGun in harpoonGuns do
		if not harpoonGun.Recipe then
			continue
		end

		count += 1
		local clone = scrollingFrame.Recipe:Clone()
		clone.Name = k
		clone._Name.Text = `[{k}]`
		clone.Vector.Image = harpoonGun.Icon
		clone.Gradient.BackgroundColor3 = harpoonGun.Color
		clone.UIStroke.Color = harpoonGun.Color
		clone.corner.ImageColor3 = harpoonGun.Color
		clone.Parent = scrollingFrame
		local v = k
		clone.Activated:Connect(function()
			HarpoonCraftingController.UpdateSpearInfo(v)
		end)
		clone.Visible = true
	end

	for _ = 1, 6 - count do
		local clone = scrollingFrame.FillerTemplate:Clone()
		clone.Name = "Filler"
		clone.Visible = true
		clone.Parent = scrollingFrame
	end

	remoteEvent.OnClientEvent:Connect(function()
		harpoonCrafting.Visible = true
	end)
	harpoonCrafting.Close.Activated:Connect(function()
		harpoonCrafting.Visible = false
	end)
	task.spawn(updateListCrafted)
	playerDataReplicator:Listen({ "HarpoonGuns", "Owned" }, updateListCrafted)
	harpoonCrafting:GetPropertyChangedSignal("Visible"):Connect(function()
		if harpoonCrafting.Visible then
			task.wait()
		else
			HarpoonCraftingController.UpdateSpearInfo("")
		end

		safeZone.topbar.Visible = not harpoonCrafting.Visible
		playerGui.backpack.Enabled = not harpoonCrafting.Visible
	end)
	harpoonCrafting.Track.Activated:Connect(function()
		if HarpoonCraftingController.CurrentlySelected == "" then
			return
		end

		if QuestShared:IsStarted(localPlayer, (`Recipe/{HarpoonCraftingController.CurrentlySelected}`)) then
			remoteEvent3:FireServer(HarpoonCraftingController.CurrentlySelected)
		else
			remoteEvent2:FireServer(HarpoonCraftingController.CurrentlySelected)
		end
	end)
	local questActive = legacyLocalPlayerData.fetch():WaitForChild("QuestActive")
	questActive.ChildAdded:Connect(function(child)
		if child.Name == `Recipe/{HarpoonCraftingController.CurrentlySelected}` then
			updateTrackButton()
		end
	end)
	questActive.ChildRemoved:Connect(function(child)
		if child.Name == `Recipe/{HarpoonCraftingController.CurrentlySelected}` then
			updateTrackButton()
		end
	end)
	updateTrackButton()
end

return HarpoonCraftingController