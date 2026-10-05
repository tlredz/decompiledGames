local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local PetRenderer = require(script.Parent:WaitForChild("PetRenderer"))
local parent = ReplicatedStorage:FindFirstChild("HiddenPets")

if not parent then
	parent = Instance.new("Folder")
	parent.Name = "HiddenPets"
	parent.Parent = ReplicatedStorage
end

local v2 = true
local v3 = true
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ShouldHide(p)
	if p.OwnerUserId == localPlayer.UserId then
		return not v2
	end

	return not v3
end

local function SilenceRig(folder, flag: boolean)
	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		if flag then
			if sound.IsPlaying then
				sound:SetAttribute("WasPlaying", true)
			end

			sound:Stop()
		elseif sound:GetAttribute("WasPlaying") then
			sound:SetAttribute("WasPlaying", nil)
			sound:Play()
		end
	end
end

local function Hide(state)
	if v4[state] then
		return
	end

	local model = state.Model

	if not (model and model.Parent) then
		return
	end

	PetRenderer.PauseMove(state.OwnerUserId, state.PetKey)

	if state.Tracks then
		for _, animationTrack in state.Tracks do
			if not (typeof(animationTrack) == "Instance" and animationTrack:IsA("AnimationTrack") and animationTrack.IsPlaying) then
				continue
			end

			animationTrack:Stop(0)
		end
	end

	SilenceRig(model, true)
	local part = Instance.new("Part")
	part.Name = "HiddenPetAnchor"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = model:GetPivot()
	part.Parent = model.Parent
	local v5 = {
		Home = model.Parent,
		StandIn = part
	}
	state.HiddenAnchor = part
	local billboard = state.Billboard

	if billboard then
		v5.BillboardHome = billboard.Parent
		billboard.Adornee = part
		billboard.Parent = part
		local income = billboard:FindFirstChild("Income")

		if income and income:IsA("GuiObject") then
			income.Visible = false
		end
	end

	if state.SpeedBillboard then
		state.SpeedBillboard.Enabled = false
	end

	model.Parent = parent
	v4[state] = v5
end

local function Show(state)
	local v5 = v4[state]

	if not v5 then
		return
	end

	v4[state] = nil
	local model = state.Model

	if model then
		if v5.StandIn and v5.StandIn.Parent then
			model:PivotTo(v5.StandIn.CFrame)
		end

		model.Parent = v5.Home or workspace
		SilenceRig(model, false)
	end

	state.HiddenAnchor = nil
	local ridePrompt = v5.StandIn and model and model.PrimaryPart and v5.StandIn:FindFirstChild("RidePrompt")

	if ridePrompt then
		ridePrompt.Parent = model.PrimaryPart
	end

	local billboard = state.Billboard

	if billboard and model then
		billboard.Adornee = model.PrimaryPart
		billboard.Parent = v5.BillboardHome or model
		local income = billboard:FindFirstChild("Income")

		if income and income:IsA("GuiObject") then
			income.Visible = true
		end
	end

	if v5.StandIn then
		v5.StandIn:Destroy()
	end

	if state.SpeedBillboard then
		state.SpeedBillboard.Enabled = true
	end

	PetRenderer.ResumeMove(state.OwnerUserId, state.PetKey)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyTo(p)
	-- equivalent call inferred; original call site unknown
	if ShouldHide(p) then
		Hide(p)
	else
		Show(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyAll()
	for _, v5 in PetRenderer.GetAll() do
		ApplyTo(v5) -- equivalent call inferred; original call site unknown
	end
end

local function ReadSetting(p: string, flag: boolean)
	local attribute = localPlayer:GetAttribute("Setting_" .. p)

	if type(attribute) == "boolean" then
		return attribute
	end

	return flag
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Refresh()
	local setting_ViewYourPets = localPlayer:GetAttribute("Setting_ViewYourPets")
	v2 = type(setting_ViewYourPets) ~= "boolean" or setting_ViewYourPets
	local setting_ViewOtherPets = localPlayer:GetAttribute("Setting_ViewOtherPets")
	v3 = type(setting_ViewOtherPets) ~= "boolean" or setting_ViewOtherPets
	ApplyAll() -- equivalent call inferred; original call site unknown
end

localPlayer:GetAttributeChangedSignal("Setting_ViewYourPets"):Connect(Refresh)
localPlayer:GetAttributeChangedSignal("Setting_ViewOtherPets"):Connect(Refresh)
Refresh() -- equivalent call inferred; original call site unknown
PetRenderer.Added.Event:Connect(function(p, p2)
	local v5 = PetRenderer.Get(p, p2)

	if v5 then
		ApplyTo(v5) -- equivalent call inferred; original call site unknown
	end
end)
PetRenderer.Removed.Event:Connect(function(p, p2)
	for k, v5 in v4 do
		if not (k.OwnerUserId == p and k.PetKey == p2) then
			continue
		end

		k.HiddenAnchor = nil

		if v5.StandIn then
			v5.StandIn:Destroy()
		end

		v4[k] = nil
		break
	end
end)