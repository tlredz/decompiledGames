local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local library = shared.modules.library
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local fish = require(library.fish)
local items = require(library.items)
local spears = require(library.spears)
require(shared.modules.fishing.mutations)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)

if FischUtils.IsTradePlaza() then
	return {}
end

local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(script.Parent.DataController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local playerDataReplicator = DataController.PlayerDataReplicator
local playerGui = HudController:GetPlayerGui()
HudController:GetHud()
local safeZone = HudController:GetSafeZone()
local spearCrafting = safeZone:WaitForChild("SpearCrafting")
local scrollingFrame = spearCrafting:WaitForChild("List").ScrollingFrame
local remoteEvent = Net:RemoteEvent("Spear/ShowCrafting", -1)
local remoteFunction = Net:RemoteFunction("Spear/AttemptCraft", -1)
local remoteEvent2 = Net:RemoteEvent("SpearCrafting/TrackRecipe", -1)
local remoteEvent3 = Net:RemoteEvent("SpearCrafting/UntrackRecipe", -1)
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
	for _, button in scrollingFrame:GetChildren() do
		if not (button:IsA("GuiButton") and button.Name ~= "Recipe") then
			continue
		end

		if button:FindFirstChild("Crafted") then
			button:FindFirstChild("Crafted"):Destroy()
		end

		if not playerDataReplicator:TryIndex({ "Spears", button.Name }) then
			continue
		end

		local clone = script.Crafted:Clone()
		clone.Parent = button
	end
end

local SpearCraftingController = {
	CurrentlySelected = ""
}

local function updateTrackButton()
	local track = spearCrafting.Track
	local currentlySelected = SpearCraftingController.CurrentlySelected

	if not currentlySelected or currentlySelected == "" or playerDataReplicator:TryIndex({ "Spears", currentlySelected }) ~= nil then
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

function SpearCraftingController.UpdateSpearInfo(currentlySelected: string)
	local spear = spears[currentlySelected]

	if not spear and currentlySelected ~= "" or spear and not spear.Recipe then
		return
	end

	local spearInfo = spearCrafting.SpearInfo
	local list = spearCrafting.Materials.List
	local craft = spearCrafting.Craft
	local info = spearInfo.Info
	local stats = spearInfo.Stats
	local vector = spearInfo.Vector
	local gradient = spearInfo.Gradient
	info.Visible = spear
	vector.Visible = spear
	gradient.Visible = spear
	stats.Visible = spear

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "_material" then
			frame:Destroy()
		end
	end

	maid:Clean()

	if not spear then
		return
	end

	gradient.BackgroundColor3 = spear.Color
	info._Name.Text = `[{currentlySelected}]`
	info.Hint.Text = spear.Hint

	for _, label in stats:GetChildren() do
		if label:IsA("TextLabel") and spear[label.Name] then
			label.Text = `{label.Name}: {spear[label.Name]}`
		end
	end

	vector.Image = spear.Icon
	vector.Shadow.Image = vector.Image
	local count = 0
	local count2 = 0

	for k, material in spear.Recipe.Materials do
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

	local visible = playerDataReplicator:TryIndex({ "Spears", currentlySelected }) ~= nil
	local interactable

	if count - count2 == count then
		interactable = not visible
	else
		interactable = false
	end

	vector.Rotation = -25
	vector.Position = UDim2.fromScale(0.85, 0.6)
	fastTween(vector, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0,
		Position = UDim2.fromScale(0.75, 0.475)
	}) -- equivalent call inferred; original call site unknown
	SpearCraftingController.CurrentlySelected = currentlySelected
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
				SpearCraftingController.UpdateSpearInfo(currentlySelected)
			end

			flag = false
		end))
	end
end

function SpearCraftingController.Start(_)
	playerDataReplicator:WaitForLoaded()
	SpearCraftingController.UpdateSpearInfo("")
	local count = 0

	for _, name in spears.Craftable do
		local spear = spears[name]

		if not spear then
			continue
		end

		count += 1
		local clone = scrollingFrame.Recipe:Clone()
		clone.Name = name
		clone._Name.Text = `[{name}]`
		clone.Vector.Image = spear.Icon
		clone.Gradient.BackgroundColor3 = spear.Color
		clone.UIStroke.Color = spear.Color
		clone.corner.ImageColor3 = spear.Color
		clone.Parent = scrollingFrame
		local v2 = name
		clone.Activated:Connect(function()
			SpearCraftingController.UpdateSpearInfo(v2)
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
		spearCrafting.Visible = true
	end)
	spearCrafting.Close.Activated:Connect(function()
		spearCrafting.Visible = false
	end)
	task.spawn(updateListCrafted)
	playerDataReplicator:ListenKeys({ "Spears" }, updateListCrafted)
	spearCrafting:GetPropertyChangedSignal("Visible"):Connect(function()
		if spearCrafting.Visible then
			task.wait()
		else
			SpearCraftingController.UpdateSpearInfo("")
		end

		safeZone.topbar.Visible = not spearCrafting.Visible
		playerGui.backpack.Enabled = not spearCrafting.Visible
	end)
	spearCrafting.Track.Activated:Connect(function()
		if SpearCraftingController.CurrentlySelected == "" then
			return
		end

		if QuestShared:IsStarted(localPlayer, (`Recipe/{SpearCraftingController.CurrentlySelected}`)) then
			remoteEvent3:FireServer(SpearCraftingController.CurrentlySelected)
		else
			remoteEvent2:FireServer(SpearCraftingController.CurrentlySelected)
		end
	end)
	local questActive = legacyLocalPlayerData.fetch():WaitForChild("QuestActive")
	questActive.ChildAdded:Connect(function(child)
		if child.Name == `Recipe/{SpearCraftingController.CurrentlySelected}` then
			updateTrackButton()
		end
	end)
	questActive.ChildRemoved:Connect(function(child)
		if child.Name == `Recipe/{SpearCraftingController.CurrentlySelected}` then
			updateTrackButton()
		end
	end)
	updateTrackButton()
end

return SpearCraftingController