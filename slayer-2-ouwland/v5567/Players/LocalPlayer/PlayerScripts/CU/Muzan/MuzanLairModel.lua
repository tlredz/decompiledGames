local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local biwaBell = ReplicatedStorage:WaitForChild("ToolScripts"):WaitForChild("Biwa Bell"):WaitForChild("Biwa Bell")
local v = nil
local v2 = false
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getTemplate()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local npcs = assets ~= nil and assets:FindFirstChild("Npcs") or nil
	return npcs ~= nil and npcs:FindFirstChild("Muzan") or nil
end

local function loadMuzan()
	if v ~= nil then
		v:Destroy()
		v = nil
	end

	local template = getTemplate() -- equivalent call inferred; original call site unknown

	if template == nil then
		if not v3 then
			v3 = true
			warn("[MuzanLairModel] ReplicatedStorage/Assets/Npcs/Muzan not found — Muzan not spawned")
		end
	else
		local race = data:FindFirstChild("Race")
		local v4

		if race == nil then
			v4 = false
		else
			v4 = race.Value == "Demon" or race.Value == "Hybrid"
		end

		local isDemon

		if v4 then
			isDemon = MuzanSettings.muzanPositions.IsDemon
		else
			isDemon = MuzanSettings.muzanPositions.IsNotDemon
		end

		if isDemon.Position.Magnitude < 1 then
			if not v2 then
				v2 = true
				warn("[MuzanLairModel] muzanPositions CFrame is still the origin placeholder — Muzan not spawned")
			end
		else
			local clone = template:Clone()
			clone.Name = "MuzanLairModel"
			clone:RemoveTag("Humanoids")
			clone:RemoveTag("Players")
			clone:PivotTo(isDemon)
			local primaryPart = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart")

			if primaryPart ~= nil then
				primaryPart.Anchored = true
			end

			local humanoid = clone:FindFirstChildOfClass("Humanoid")

			if humanoid ~= nil then
				humanoid:Destroy()
			end

			local parent = clone:FindFirstChildOfClass("AnimationController")

			if parent == nil then
				parent = Instance.new("AnimationController")
				parent.Parent = clone
			end

			local v6 = parent:FindFirstChildOfClass("Animator")

			if v6 == nil then
				v6 = Instance.new("Animator")
				v6.Parent = parent
			end

			if not v4 then
				local itemAssets = ReplicatedStorage:FindFirstChild("ItemAssets")
				local muzansBlood

				if itemAssets ~= nil then
					muzansBlood = itemAssets:FindFirstChild("Muzan's Blood", true) or nil
				end

				local rightHand = clone:FindFirstChild("RightHand", true)
				local clone2

				if muzansBlood ~= nil then
					clone2 = muzansBlood:Clone() or nil
				end

				local weld

				if clone2 ~= nil then
					weld = clone2:FindFirstChild("Weld", true) or nil
				end

				if clone2 == nil or weld == nil or rightHand == nil then
					if clone2 ~= nil then
						clone2:Destroy()
					end

					warn((`[MuzanLairModel] flask skipped — missing {muzansBlood == nil and "ItemAssets/Muzan's Blood" or weld == nil and "its Weld" or "rig RightHand"}`))
				else
					weld.Part0 = rightHand
					clone2.Parent = clone
				end
			end

			if primaryPart ~= nil then
				Utility.CreatePrompt({
					ActionText = "Chat",
					ObjectText = "Muzan",
					MaxActivationDistance = 10,
					Tags = { "Dialogue" },
					Attributes = {
						DialogueName = "MuzanLair",
						Name = "Muzan",
						Icon = BunchaIcons.MuzanIcon
					},
					Parent = primaryPart
				})
			end

			clone.Parent = workspace.Debree
			v = clone
			local child = biwaBell:FindFirstChild(v4 and "MuzanIdleSeated" or "MuzanIdlePotion")

			if child == nil or v6 == nil then
				if child == nil then
					warn((`[MuzanLairModel] idle clip "{v4 and "MuzanIdleSeated" or "MuzanIdlePotion"}" missing under ToolScripts/Biwa Bell/Biwa Bell`))
				end
			else
				local track = v6:LoadAnimation(child)
				track.Looped = true
				track:Play()
			end
		end
	end
end

loadMuzan()
task.spawn(function()
	local race = data:WaitForChild("Race", 30)

	if race == nil then
		return
	end

	race.Changed:Connect(loadMuzan)
	loadMuzan()
end)