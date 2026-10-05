local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cutscene_camera_handler = require(ServerStorage.SAM.Game_Play.Cutscene_camera_handler)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)

-- equivalent calls inferred from this helper; original call sites unknown
local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")

	if humanoid == nil then
		return nil
	end

	return humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function weldTo(cutscenePart, humanoidRootPart)
	local weld = Instance.new("Weld")
	weld.Part0 = cutscenePart
	weld.Part1 = humanoidRootPart
	weld.Parent = humanoidRootPart
	return weld
end

local function playCutscene(p, instance, state)
	local cutscenePart = state.CutscenePart
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if cutscenePart == nil or humanoidRootPart == nil then
		return
	end

	if state.Weld ~= nil then
		state.Weld:Destroy()
		state.Weld = nil
	end

	local sword = state.Sword
	state.Sword = nil

	if sword ~= nil then
		DebrisModule:AddItem(sword, 12.266)
	end

	local getvaluesfolder = Utility.getvaluesfolder(instance)

	if getvaluesfolder ~= nil then
		Utility.AddValue(getvaluesfolder, "pause_gameplay", 12.266)
		Utility.AddValue(getvaluesfolder, "skill_stand_still", 12.266)
		Utility.AddValue(getvaluesfolder, "iframe", 12.266)
		Utility.AddValue(getvaluesfolder, "noragdoll", 12.266)
		Utility.AddValue(getvaluesfolder, "FOV", 12.266, "NumberValue", 30)
	end

	DebrisModule:AddItem(weldTo(cutscenePart, humanoidRootPart), 12.166)
	local animator = getAnimator(instance) -- equivalent call inferred; original call site unknown
	local track = animator and animator:LoadAnimation(script.Parent.CutscenePlayer) or nil

	if track then
		track:Play()
	end

	local clone = script.Parent.Sabito:Clone()
	clone.Name = `{p.Name}_BoulderSplit_Sabito`
	clone.Parent = workspace.Debree
	clone:PivotTo(cutscenePart.CFrame)
	DebrisModule:AddItem(clone, 12.266)
	local rightHand = clone:FindFirstChild("RightHand")

	if rightHand then
		local clone2 = ItemModels.FindTool("Ocean Wave Katana").Equipped["Basic Katana"]:Clone()
		clone2.Parent = clone
		clone2.Weld.Part0 = rightHand
	end

	local animator2 = getAnimator(clone) -- equivalent call inferred; original call site unknown

	if animator2 then
		animator2:LoadAnimation(script.Parent.SabitoAnimation):Play()
	end

	local boulder = state.Boulder

	if boulder then
		local animator3 = getAnimator(boulder) -- equivalent call inferred; original call site unknown

		if animator3 then
			animator3:LoadAnimation(script.Parent.CutsceneBoulder):Play()
		end
	end

	EffectsEvent.ToAllInRange(cutscenePart, "BoulderSlashCutscene", instance)
	local clone2 = script.Parent.CameraRig:Clone()
	clone2.Name = `{p.Name}_BoulderSplit_cameraRig`
	clone2.Parent = workspace.Debree
	clone2.RootPart.CameraWeld.Part0 = cutscenePart
	DebrisModule:AddItem(clone2, 12.266)
	local animator3 = getAnimator(clone2) -- equivalent call inferred; original call site unknown

	if animator3 then
		animator3:LoadAnimation(script.Parent.CameraAnimation):Play()
	end

	Cutscene_camera_handler.Regular(p, clone2.Bone)
end

local BoulderSplit = {}

function BoulderSplit.Do(_, parent, p, _, p2)
	local parent2 = p2.Parent
	p.CutscenePart = parent2.Parent:FindFirstChild("CutscenePart")
	p.Boulder = parent2.Parent:FindFirstChild("Boulder")
	local weld = Instance.new("Weld")
	weld.Part0 = parent.HumanoidRootPart
	weld.Part1 = parent2
	weld.Parent = parent2
	p.Weld = weld
	p.Sword = ItemModels.FindTool("Regular Katana").Equipped["Basic Katana 1"]:Clone()
	p.Sword.Parent = parent
	p.Sword.Weld.Part0 = parent.RightHand
	return true, false
end

function BoulderSplit.StateChanged(p, p2, _, ...)
	EffectsEvent.ToOthersInRange(p, "BoulderSlashFailed", p2)
end

function BoulderSplit.Destroying(_, _, state, _)
	if state.Weld ~= nil then
		state.Weld.Part0 = nil
		state.Weld = nil
	end

	if state.Sword ~= nil then
		state.Sword:Destroy()
		state.Sword = nil
	end
end

function BoulderSplit.Stop(p, p2, p3, flag: boolean?)
	if flag ~= true then
		return true
	end

	playCutscene(p, p2, p3)
	return true, nil, 12.266
end

return BoulderSplit