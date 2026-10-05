local localPlayer = game.Players.LocalPlayer
local AvatarEditorService = game:GetService("AvatarEditorService")
local UI = require(game.ReplicatedStorage.Modules.UI)
local Network = require(game.ReplicatedStorage.Modules.Network)
local SatchelScript = require(localPlayer.PlayerScripts.Satchel.SatchelScript)
local outfit = script.Parent:WaitForChild("Outfit")
local inventory = outfit:WaitForChild("Inventory")
local empty = outfit:WaitForChild("Empty")
local flag = false
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function load_outfit(clone, id)
	clone.Icon.Image = string.format("rbxthumb://type=Outfit&id=%d&w=420&h=420", id)
end

local function update()
	if flag then
		return
	end

	flag = true

	for _, frame in inventory:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local success, result = pcall(function()
		return AvatarEditorService:GetOutfits(Enum.OutfitSource.Created, Enum.OutfitType.Avatar)
	end)
	local v2 = {}

	if success and result then
		empty.Visible = false
		local clone = script.Sample:Clone()
		clone.Name = "!00000000"
		clone.Title.Text = "Default"
		clone.Icon.Image = string.format("rbxthumb://type=Avatar&id=%d&w=352&h=352", localPlayer.UserId)
		UI:Bind(clone.Button)
		UI:AddShadowOnHover(clone)
		clone.Button.MouseButton1Click:Connect(function()
			if localPlayer.Character:GetAttribute("PropMorphed") then
				return
			end

			Network:fire("RefreshCharacter")
			outfit.Visible = false
		end)
		clone.Parent = inventory

		while true do
			local currentPage = result:GetCurrentPage()

			for _, v3 in currentPage do
				if v2[v3.Id] then
					continue
				end

				v2[v3.Id] = true
				local clone2 = script.Sample:Clone()
				clone2.Name = v3.Name
				clone2.Title.Text = v3.Name
				UI:Bind(clone2.Button)
				UI:AddShadowOnHover(clone2)
				load_outfit(clone2, v3.Id) -- equivalent call inferred; original call site unknown
				local v4 = v3
				clone2.Button.MouseButton1Click:Connect(function()
					Network:fire("WearOutfit", v4.Id)
				end)
				clone2.Parent = inventory
			end

			if result.IsFinished then
				break
			end

			result:AdvanceToNextPageAsync()
			task.wait()
		end
	else
		empty.Visible = true
	end

	flag = false
end

local function shouldBackpackBeVisible()
	if localPlayer:GetAttribute("State") == 7 or localPlayer.Character:GetAttribute("Carried") or localPlayer.Character:GetAttribute("Tied") then
		return false
	end

	if localPlayer.Character:GetAttribute("BoogieDancing") or localPlayer.Character:GetAttribute("PropMorphed") then
		return false
	end

	if localPlayer.PlayerGui:FindFirstChild("PianoGui") and localPlayer.PlayerGui.PianoGui:GetAttribute("Visible") then
		return false
	end

	if localPlayer.PlayerGui:FindFirstChild("PV2Piano") and localPlayer.PlayerGui.PV2Piano:GetAttribute("Visible") then
		return false
	end

	return true
end

outfit:WaitForChild("Refresh").MouseButton1Click:Connect(function()
	return update()
end)
outfit:WaitForChild("Close").MouseButton1Click:Connect(function()
	outfit.Visible = false
end)
UI:Bind(outfit.Close)
UI:Bind(outfit.Refresh)
AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(p)
	if p == Enum.AvatarPromptResult.Success then
		update()
	else
		v = false
	end
end)
outfit:GetPropertyChangedSignal("Visible"):Connect(function()
	if outfit.Visible then
		script.Open:Play()
		local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			humanoid:UnequipTools()
		end

		if not v then
			v = true
			AvatarEditorService:PromptAllowInventoryReadAccess()
		end
	end

	if outfit.Visible then
		SatchelScript:SetBackpackEnabled(false)
	else
		task.delay(1, function()
			local state = localPlayer:GetAttribute("State")

			if state ~= 1 and state ~= 2 and state ~= 6 and state ~= 7 then
				SatchelScript:SetBackpackEnabled(true)
			end
		end)
	end
end)
Network:listen("CloseOutfitGui", function()
	outfit.Visible = false
end)