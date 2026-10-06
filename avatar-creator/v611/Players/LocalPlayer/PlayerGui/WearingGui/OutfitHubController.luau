local createVector = vector.create
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local panel = parent.Root.Panel
local saved = panel.Saved
local savedDetails = panel.SavedDetails
local savedOutfitsRemote = game.ReplicatedStorage:WaitForChild("SavedOutfitsRemote")
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local MenuFade = require(game.ReplicatedStorage.MenuFade)
local OutfitHubLayout = require(game.ReplicatedStorage.OutfitHubLayout)
local SavedOutfitPreview = require(game.ReplicatedStorage.SavedOutfitPreview)
local robloxSaveOutfitGui = playerGui:WaitForChild("RobloxSaveOutfitGui")
local panel2 = robloxSaveOutfitGui.Root.Panel
local v = false
local items = {}
local v2 = false
local v3 = nil
local v4 = nil
local v5 = nil
local nows = {}
local onActivated
local v6 = nil
local id = nil
local decoded = nil
local R6 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function fit()
	OutfitHubLayout.Apply(parent)
end

local function call(p, options)
	local v7 = (({
		List = 1.05,
		Save = 2.05,
		Wear = 1.55,
		Delete = 1.05,
		PrepareSave = 0.9
	})[p] or 0) - (os.clock() - (nows[p] or -100))

	if v7 > 0 then
		task.wait(v7)
	end

	nows[p] = os.clock()
	local success, result = pcall(function()
		return savedOutfitsRemote:InvokeServer(p, options or {})
	end)
	return (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Please retry."
	} or result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeDetails()
	if v6 then
		v6:Cancel("Outfit action canceled.")
	end

	savedDetails.Visible = false

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	v3 = nil
	savedDetails.Delete.Text = "Delete"
end

local function selectTab(p)
	local v7 = p ~= "Wearing" and p ~= "Saved" and p ~= "Loader" and "Wearing" or p
	closeDetails() -- equivalent call inferred; original call site unknown
	panel.Current.Visible = v7 == "Wearing"
	saved.Visible = v7 == "Saved"
	panel.Loader.Visible = v7 == "Loader"

	for _, v8 in { "Wearing", "Saved", "Loader" } do
		panel.HubTabs[v8].BackgroundColor3 = v8 == v7 and CatalogUI.colors.accent or CatalogUI.colors.raised
	end

	panel:SetAttribute("ActiveTab", v7)
	fit() -- equivalent call inferred; original call site unknown

	if v7 == "Saved" and not v2 and onActivated then
		task.spawn(onActivated)
	end
end

local function wearing(p)
	if v then
		return
	end

	v = true
	savedDetails.Wear.Interactable = false
	saved.Status.Text = "Wearing " .. p.title .. "..."
	savedDetails.Status.Text = saved.Status.Text
	local v7 = call("Wear", {
		id = p.id
	})
	v = false
	savedDetails.Wear.Interactable = true
	saved.Status.Text = v7.error or v7.message
	savedDetails.Status.Text = saved.Status.Text
end

local function view(data)
	closeDetails() -- equivalent call inferred; original call site unknown
	v3 = data
	savedDetails.Visible = true
	savedDetails.Title.Text = data.title
	savedDetails.Status.Text = "Saved " .. os.date("%b %d, %Y", data.created) .. "\nPreview, wear, purchase, or save this outfit to Roblox."
	v4 = SavedOutfitPreview.Mount(savedDetails.Avatar, data.appearance, data.rig, true)
	fit() -- equivalent call inferred; original call site unknown
end

local function render()
	for _, guiObject in saved.Results:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for i, v7 in ipairs(items) do
		local v8 = CatalogUI.make("Frame", "Outfit_" .. v7.id, saved.Results, {
			BackgroundColor3 = CatalogUI.colors.surface,
			BorderSizePixel = 0,
			LayoutOrder = i
		})
		v8:SetAttribute("OutfitId", v7.id)
		CatalogUI.round(v8, 10)
		local v9 = CatalogUI.make("ViewportFrame", "Avatar", v8, {
			BackgroundTransparency = 1,
			Ambient = Color3.fromRGB(200, 200, 215),
			LightColor = Color3.new(1, 1, 1),
			LightDirection = createVector(-1, -1, -1)
		})
		local label = CatalogUI.label("OutfitTitle", v8, v7.title, UDim2.new(), UDim2.new(), 13)
		label.TextTruncate = Enum.TextTruncate.AtEnd
		local v10 = v7
		CatalogUI.button("View", v8, "View", UDim2.new(), UDim2.new()).Activated:Connect(function()
			view(v10)
		end)
		local v11 = v7
		CatalogUI.button("Wear", v8, "Wear", UDim2.new(), UDim2.new(), true).Activated:Connect(function()
			wearing(v11)
		end)
		SavedOutfitPreview.Mount(v9, v7.appearance, v7.rig)
	end

	saved.Empty.Visible = #items == 0
	fit() -- equivalent call inferred; original call site unknown
end

onActivated = function()
	if v then
		return
	end

	v = true
	saved.Refresh.Interactable = false
	saved.Status.Text = "Loading saved outfits..."
	local v7 = call("List")
	v = false
	saved.Refresh.Interactable = true

	if v7.error then
		saved.Status.Text = v7.error
		return
	end

	items = v7.items or {}
	v2 = true
	render()
	saved.Status.Text = #items .. " / " .. (v7.limit or 50) .. " saved outfits"
end

local function saveCurrent(p)
	if v or panel2:GetAttribute("RobloxSaveBusy") then
		return
	end

	v = true
	panel2:SetAttribute("GameSaveBusy", true)
	saved.SaveCurrent.Interactable = false
	panel2.SaveInGame.Interactable = false
	panel2.SaveAvatar.Interactable = false
	panel2.CreateOutfit.Interactable = false
	saved.Status.Text = "Saving current avatar..."
	panel2.Status.Text = saved.Status.Text
	local title = p and "" or saved.OutfitName.Text

	if not v5 or v5.title ~= title then
		v5 = {
			id = HttpService:GenerateGUID(false),
			title = title
		}
	end

	local v8 = call("Save", v5)
	v = false
	panel2:SetAttribute("GameSaveBusy", false)
	saved.SaveCurrent.Interactable = true
	panel2.SaveInGame.Interactable = true
	panel2.SaveAvatar.Interactable = true
	panel2.CreateOutfit.Interactable = true
	saved.Status.Text = v8.error or v8.message
	panel2.Status.Text = saved.Status.Text

	if v8.error then
		return
	end

	v5 = nil
	saved.OutfitName.Text = ""
	local v9 = false

	for _, item in items do
		if item.id ~= v8.item.id then
			continue
		end

		v9 = true
		break
	end

	if not v9 then
		table.insert(items, 1, v8.item)
	end

	render()

	if not v2 then
		task.spawn(onActivated)
	end

	selectTab("Saved")

	if p then
		MenuFade.Set(robloxSaveOutfitGui, "Enabled", false)
		MenuFade.Set(playerGui.CatalogGui, "Enabled", false)
		MenuFade.Set(playerGui.CommunityGui, "Enabled", false)
		task.delay(0.2, function()
			MenuFade.Set(parent, "Enabled", true)
		end)
	end
end

local OutfitSaveFlow = require(game.ReplicatedStorage.OutfitSaveFlow)
v6 = OutfitSaveFlow.new({
	Capture = function()
		if not v3 then
			return false, "Choose a saved outfit first."
		end

		if panel2:GetAttribute("RobloxSaveBusy") or panel2:GetAttribute("GameSaveBusy") then
			return false, "Finish your other save first."
		end

		id = v3.id
		return true
	end,
	Cleanup = function()
		if decoded then
			decoded:Destroy()
			decoded = nil
		end

		id = nil
		R6 = nil
	end,
	Busy = function(savedOutfitActionBusy)
		v = savedOutfitActionBusy
		panel2:SetAttribute("SavedOutfitActionBusy", savedOutfitActionBusy)

		for _, v7 in {
			savedDetails.Wear,
			savedDetails.Delete,
			savedDetails.PurchaseOutfit,
			savedDetails.SaveToRoblox,
			savedDetails.Back,
			panel.Close
		} do
			v7.Interactable = not savedOutfitActionBusy
		end
	end,
	Status = function(text)
		savedDetails.Status.Text = text
		saved.Status.Text = text
	end,
	Check = function(purchase)
		local id2 = id
		local v8 = call("PrepareSave", {
			id = id2,
			purchase = purchase
		})

		if id2 ~= id then
			return {
				error = "Outfit action canceled."
			}
		end

		if not v8.ready then
			return v8
		end

		if decoded then
			decoded:Destroy()
		end

		local OutfitCodec = require(game.ReplicatedStorage.OutfitCodec)
		decoded = OutfitCodec.decode(v8.appearance)
		R6 = v8.rig == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
		return v8
	end,
	Save = function()
		if not decoded then
			error("Saved outfit snapshot is missing.")
		end

		AvatarEditorService:PromptCreateOutfit(decoded, R6)
	end,
	Wait = task.wait,
	Warn = function(p)
		warn("Saved outfit Roblox prompt: " .. tostring(p))
	end
})

local function startAction(p)
	if v or not v3 or panel2:GetAttribute("RobloxSaveBusy") or panel2:GetAttribute("GameSaveBusy") then
		return
	end

	savedDetails.Delete.Text = "Delete"
	v6:Start(p)
end

savedDetails.PurchaseOutfit.Activated:Connect(function()
	if not v and v3 and not panel2:GetAttribute("RobloxSaveBusy") then
		if panel2:GetAttribute("GameSaveBusy") then
			return
		end

		savedDetails.Delete.Text = "Delete"
		v6:Start("Purchase")
	end
end)
savedDetails.SaveToRoblox.Activated:Connect(function()
	if not v and v3 and not panel2:GetAttribute("RobloxSaveBusy") then
		if panel2:GetAttribute("GameSaveBusy") then
			return
		end

		savedDetails.Delete.Text = "Delete"
		v6:Start("Outfit")
	end
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer then
		v6:PurchaseFinished(p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed)
	end
end)
AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(p)
	local v7 = p == Enum.AvatarPromptResult.Success and "Outfit saved to your Roblox account!" or "Roblox save canceled or unsuccessful. Your in-game saved outfit is still here."
	v6:SaveFinished("Outfit", v7)
end)

for _, v7 in { "Wearing", "Saved", "Loader" } do
	local v8 = v7
	panel.HubTabs[v7].Activated:Connect(function()
		selectTab(v8)
	end)
end

saved.SaveCurrent.Activated:Connect(function()
	saveCurrent(false)
end)
panel2.SaveInGame.Activated:Connect(function()
	saveCurrent(true)
end)
saved.Refresh.Activated:Connect(onActivated)
savedDetails.Back.Activated:Connect(closeDetails)
savedDetails.Wear.Activated:Connect(function()
	if v3 then
		wearing(v3)
	end
end)
savedDetails.Delete.Activated:Connect(function()
	if v or not v3 then
		return
	end

	if savedDetails.Delete.Text ~= "Confirm delete" then
		savedDetails.Delete.Text = "Confirm delete"
		return
	end

	v = true
	savedDetails.Delete.Interactable = false
	local v7 = v3
	local v8 = call("Delete", {
		id = v7.id
	})
	v = false
	savedDetails.Delete.Interactable = true

	if v8.error then
		savedDetails.Status.Text = v8.error
		return
	end

	for k, item in items do
		if item.id ~= v7.id then
			continue
		end

		table.remove(items, k)
		break
	end

	closeDetails() -- equivalent call inferred; original call site unknown
	render()
	saved.Status.Text = v8.message
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if parent.Enabled then
		if panel:GetAttribute("ActiveTab") == "Saved" and not v2 then
			task.spawn(onActivated)
		end
	else
		closeDetails() -- equivalent call inferred; original call site unknown
	end
end)
panel.Close.Activated:Connect(closeDetails)
parent.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
localPlayer:GetAttributeChangedSignal("MobileLayoutRevision"):Connect(fit)
local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(fit)
selectTab("Wearing")