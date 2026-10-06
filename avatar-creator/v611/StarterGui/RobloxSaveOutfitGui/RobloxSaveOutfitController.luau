local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local Players = game:GetService("Players")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local catalogGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("CatalogGui")
local parent = script.Parent
local panel = parent.Root.Panel
local wearingRemote = game.ReplicatedStorage:WaitForChild("WearingRemote")
local appliedDescription = nil
local v = nil
local applyDescriptionFinishedConnection = nil
local v2 = nil
local now = 0

local function cleanup()
	if applyDescriptionFinishedConnection then
		applyDescriptionFinishedConnection:Disconnect()
		applyDescriptionFinishedConnection = nil
	end

	if appliedDescription then
		appliedDescription:Destroy()
		appliedDescription = nil
	end

	v = nil
end

local OutfitSaveFlow = require(game.ReplicatedStorage:WaitForChild("OutfitSaveFlow"))
v2 = OutfitSaveFlow.new({
	Capture = function()
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return false, "Wait for your character to spawn, then try again."
		end

		v = humanoid
		appliedDescription = humanoid:GetAppliedDescription()
		applyDescriptionFinishedConnection = humanoid.ApplyDescriptionFinished:Connect(function()
			v2:Cancel("Your outfit changed. Choose a save option again.")
		end)
		return true
	end,
	Cleanup = cleanup,
	Busy = function(robloxSaveBusy)
		panel:SetAttribute("RobloxSaveBusy", robloxSaveBusy)
		panel.SaveAvatar.Interactable = not robloxSaveBusy
		panel.CreateOutfit.Interactable = not robloxSaveBusy
		panel.SaveInGame.Interactable = not (robloxSaveBusy or panel:GetAttribute("GameSaveBusy"))
	end,
	Status = function(text)
		panel.Status.Text = text
	end,
	Check = function(purchase)
		local v3 = 0.9 - (os.clock() - now)

		if v3 > 0 then
			task.wait(v3)
		end

		if not v or not v.Parent or v.Health <= 0 then
			return {
				error = "Wait for your character to spawn, then try again."
			}
		end

		now = os.clock()
		return wearingRemote:InvokeServer("PrepareSave", {
			purchase = purchase
		})
	end,
	Save = function(p)
		if not appliedDescription or not v or not v.Parent or v.Health <= 0 then
			error("Character changed.")
		end

		if p == "Avatar" then
			AvatarEditorService:PromptSaveAvatar(appliedDescription, v.RigType)
		else
			AvatarEditorService:PromptCreateOutfit(appliedDescription, v.RigType)
		end
	end,
	Wait = task.wait,
	Warn = function(p)
		warn("Roblox outfit prompt: " .. tostring(p))
	end
})

local function completed(p, p2)
	local v3

	if p2 == Enum.AvatarPromptResult.Success then
		v3 = p == "Avatar" and "Your Roblox avatar was updated!" or "New outfit saved to your Roblox account!"
	else
		v3 = p2 == Enum.AvatarPromptResult.PermissionDenied and "Save canceled or permission denied. No save was confirmed." or "Roblox couldn't save this look. Check item ownership and available outfit slots, then try again."
	end

	v2:SaveFinished(p, v3)
end

AvatarEditorService.PromptSaveAvatarCompleted:Connect(function(p)
	local v3 = p == Enum.AvatarPromptResult.Success and "Your Roblox avatar was updated!" or p == Enum.AvatarPromptResult.PermissionDenied and "Save canceled or permission denied. No save was confirmed." or "Roblox couldn't save this look. Check item ownership and available outfit slots, then try again."
	v2:SaveFinished("Avatar", v3)
end)
AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(p)
	local v3 = p == Enum.AvatarPromptResult.Success and "New outfit saved to your Roblox account!" or p == Enum.AvatarPromptResult.PermissionDenied and "Save canceled or permission denied. No save was confirmed." or "Roblox couldn't save this look. Check item ownership and available outfit slots, then try again."
	v2:SaveFinished("Outfit", v3)
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer then
		v2:PurchaseFinished(p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed)
	end
end)
catalogGui.Root.LivePreview:WaitForChild("SaveOutfit").Activated:Connect(function()
	MenuFade.Set(parent, "Enabled", true)
end)
panel.Close.Activated:Connect(function()
	v2:Cancel("Save canceled.")
	MenuFade.Set(parent, "Enabled", false)
end)
panel.SaveAvatar.Activated:Connect(function()
	if not (panel:GetAttribute("GameSaveBusy") or panel:GetAttribute("SavedOutfitActionBusy")) then
		v2:Start("Avatar")
	end
end)
panel.CreateOutfit.Activated:Connect(function()
	if not (panel:GetAttribute("GameSaveBusy") or panel:GetAttribute("SavedOutfitActionBusy")) then
		v2:Start("Outfit")
	end
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not parent.Enabled then
		v2:Cancel("Save canceled.")
	elseif v2.phase == "idle" then
		panel.Status.Text = "For Roblox saves, missing items are shown before you confirm."
	end
end)
localPlayer.CharacterRemoving:Connect(function()
	v2:Cancel("Your character changed. Choose a save option again.")
end)
catalogGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not catalogGui.Enabled then
		MenuFade.Set(parent, "Enabled", false)
	end
end)

local function syncSaveButtons()
	local robloxSaveBusy = panel:GetAttribute("RobloxSaveBusy") or panel:GetAttribute("GameSaveBusy") or panel:GetAttribute("SavedOutfitActionBusy")

	for _, v3 in { panel.SaveAvatar, panel.CreateOutfit, panel.SaveInGame } do
		v3.Interactable = not robloxSaveBusy
	end
end

for _, v3 in { "RobloxSaveBusy", "GameSaveBusy", "SavedOutfitActionBusy" } do
	panel:GetAttributeChangedSignal(v3):Connect(syncSaveButtons)
end

syncSaveButtons()

-- equivalent calls inferred from this helper; original call sites unknown
local function box(p, p2, p3, p4, p5, value)
	p.AnchorPoint = Vector2.zero
	p.Position = UDim2.fromOffset(p2, p3)
	p.Size = UDim2.fromOffset(p4, p5)
	p.TextScaled = false
	p.TextSize = value or 14
end

local function fit()
	local absoluteSize = parent.Root.AbsoluteSize
	local v3 = math.min(470, absoluteSize.X - 24)
	local v4 = math.min(448, absoluteSize.Y - 24)

	for _, uIScale in panel:GetChildren() do
		if uIScale:IsA("UIScale") then
			uIScale.Scale = 1
		end
	end

	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(v3, v4)
	local v5 = v4 < 400
	local title = panel.Title
	local v6 = v3 - 110
	title.AnchorPoint = Vector2.zero
	title.Position = UDim2.fromOffset(16, 10)
	title.Size = UDim2.fromOffset(v6, 36)
	title.TextScaled = false
	title.TextSize = 23
	box(panel.Close, v3 - 86, 12, 70, 36) -- equivalent call inferred; original call site unknown
	panel.Intro.Visible = not v5

	for _, v8 in { "GameHint", "AvatarHint", "OutfitHint" } do
		panel[v8].Visible = not v5
	end

	local intro = panel.Intro
	local v8 = v3 - 32
	intro.AnchorPoint = Vector2.zero
	intro.Position = UDim2.fromOffset(16, 54)
	intro.Size = UDim2.fromOffset(v8, 40)
	intro.TextScaled = false
	intro.TextSize = 13
	local v9 = v5 and 52 or 90
	local v10 = v5 and 58 or 108

	for k, v11 in { "SaveInGame", "SaveAvatar", "CreateOutfit" } do
		box(panel[v11], 16, v10 + (k - 1) * v9, v3 - 32, 44) -- equivalent call inferred; original call site unknown
	end

	for k, v11 in { "GameHint", "AvatarHint", "OutfitHint" } do
		local v12 = panel[v11]
		local v13 = v10 + (k - 1) * v9 + 46
		local v14 = v3 - 32
		v12.AnchorPoint = Vector2.zero
		v12.Position = UDim2.fromOffset(16, v13)
		v12.Size = UDim2.fromOffset(v14, 32)
		v12.TextScaled = false
		v12.TextSize = 12
	end

	local status = panel.Status
	local v11 = v3 - 32
	local v12 = v5 and math.max(40, v4 - 230) or 56
	status.AnchorPoint = Vector2.zero
	status.Position = UDim2.fromOffset(16, v5 and 218 or 376)
	status.Size = UDim2.fromOffset(v11, v12)
	status.TextScaled = false
	status.TextSize = 12
end

parent.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(fit)
fit()