local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BigGameHunterClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local flag = false
local v = {}
local v2 = {
	["Bunny Foot"] = "rbxassetid://72329636183848",
	["Wolf Pelt"] = "rbxassetid://94253978594094",
	["Arctic Fox Pelt"] = "rbxassetid://129593073643545",
	["Alpha Wolf Pelt"] = "rbxassetid://122754315206242",
	["Bear Pelt"] = "rbxassetid://88308590406676",
	["Mammoth Tusk"] = "rbxassetid://120268446129289",
	["Polar Bear Pelt"] = "rbxassetid://74115997642133",
	["Scorpion Shell"] = "rbxassetid://129221527940078",
	["Cultist King Antler"] = "rbxassetid://118917734469182",
	["Boar Tusk"] = "rbxassetid://105683130300245",
	["Blue Frog Leg"] = "rbxassetid://125502863187276"
}
local childrenByName = {}

function AttemptConsumePelt(instance)
	print("wants to consume pelt", instance:GetFullName())
	instance.Parent = game.ReplicatedStorage.TempStorage
	HighlightClosestPelt()
	BigGameParticles(instance)
	task.delay(2, function()
		if instance.Parent ~= nil then
			instance.Parent = workspace.Items
			HighlightClosestPelt()
		end
	end)
	Client.Events.RequestBGHConsumePelt:FireServer(instance)
end

function GetClosestPelt()
	local v3 = nil
	local v4 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped and currentlyEquipped.Name == "Hammer" then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for k in pairs(v) do
		if not (k.Parent == workspace.Items and (k.Name ~= "Mammoth Tusk" or not ((localPlayer:GetAttribute("ClassLevel") or 1) < 3))) then
			continue
		end

		local v5 = childrenByName[k.Name]

		if v5 and v5:GetAttribute("Complete") then
			print("remove from list", k)
			v[k] = nil
		else
			local magnitude = (position - k:GetPivot().Position).Magnitude

			if magnitude < v4 then
				v3 = k
				v4 = magnitude
			end
		end
	end

	return v3, v4
end

function HighlightClosestPelt()
	task.spawn(function()
		local bigGameHunterHighlight = workspace:WaitForChild("Highlights"):WaitForChild("BigGameHunterHighlight")
		local v3, v4 = GetClosestPelt()
		local adornee = nil

		if v3 and v4 <= 8 then
			adornee = v3
		end

		if adornee ~= CurrentFocus then
			if adornee then
				bigGameHunterHighlight.Adornee = adornee
				bigGameHunterHighlight.Enabled = true
				Prompt.Enabled = true
			else
				bigGameHunterHighlight.Adornee = nil
				bigGameHunterHighlight.Enabled = false
				Prompt.Enabled = false
			end
		end

		if adornee then
			Attachment.WorldCFrame = adornee:GetPivot()
		end

		CurrentFocus = adornee
	end)
end

function LoopCheckClosestPelt()
	task.spawn(function()
		while true do
			HighlightClosestPelt()
			task.wait(1)
		end
	end)
end

function CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	Attachment = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 8
	proximityPrompt.ActionText = "Consume"
	proximityPrompt.HoldDuration = 0.5
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	Prompt = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("consume", CurrentFocus)
		AttemptConsumePelt(CurrentFocus)
	end)
end

function PeltAdded(p)
	local v3 = childrenByName[p.Name]

	if not v3 or v3:GetAttribute("Complete") ~= nil then
		print("don't add", p)
		return
	end

	v[p] = true
	print("add", p)
end

function PeltRemoved(p)
	v[p] = nil
end

function LoadPelts()
	Client.Utility.ForAllTagged("BigGameHunterPelt", PeltAdded, PeltRemoved)
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	local v3 = {}

	for _, v4 in pairs(v2) do
		table.insert(v3, v4)
	end

	UtilityAlec.preload(v3)
	task.spawn(function()
		local peltList = localPlayer:WaitForChild("PeltList")

		for _, child in pairs(peltList:GetChildren()) do
			childrenByName[child.Name] = child
		end

		CreatePrompt()
		LoadPelts()
		LoopCheckClosestPelt()
	end)
end

function BigGameParticles(p)
	Client.Sound.Play("BigGame", {
		Duplicate = true
	})

	if not (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	for _, child in pairs(ReplicatedStorage.Assets.Particles.PeltConsumed.HumanoidRootPart:GetChildren()) do
		local clone = child:Clone()

		if not localPlayer.Character.HumanoidRootPart:FindFirstChild("RootAttachment") then
			continue
		end

		clone.Parent = localPlayer.Character.HumanoidRootPart.RootAttachment

		if clone:IsA("ParticleEmitter") then
			clone:Emit(clone:GetAttribute("EmitCount"))
		end

		if not clone:FindFirstChild("Pelt") then
			continue
		end

		clone.Pelt.Texture = v2[p.Name] or "rbxassetid://94253978594094"
		clone.Pelt:Emit(clone:GetAttribute("EmitCount"))
	end
end

Client.Events.BigGameParticles:Connect(function(p)
	BigGameParticles(p)
end)

function BigGameHunterClass.Init()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Big Game Hunter" then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return BigGameHunterClass