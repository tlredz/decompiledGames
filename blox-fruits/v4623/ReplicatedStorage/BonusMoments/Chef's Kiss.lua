local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local Effect = require(game.ReplicatedStorage.Effect)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Util = require(game.ReplicatedStorage.Util)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local CauldronMenu = require(script.CauldronMenu)
local MaterialSprite = require(script.MaterialSprite)
local v = {
	"PirateVillageSFX.PirateVillBonus_Place_Ingredient_In_Cauldron_01",
	"PirateVillageSFX.PirateVillBonus_Place_Ingredient_In_Cauldron_02",
	"PirateVillageSFX.PirateVillBonus_Place_Ingredient_In_Cauldron_03"
}
local numberRange = NumberRange.new(0.65, 1)
local numberRange2 = NumberRange.new(0.7, 1)
local color = Color3.fromRGB(255, 108, 24)
local v2 = {
	playAt = function(p: string, p2)
		if p2 == nil then
			return
		end

		pcall(function()
			Sound:Play(p, p2)
		end)
	end
}

function v2.playRandom(list, p)
	v2.playAt(list[math.random(#list)], p)
end

function v2:startCauldronFire()
	local pot = self.Pot

	if self.FireSound ~= nil or pot == nil then
		return
	end

	pcall(function()
		local fireSound2 = Sound:Play("PirateVillageSFX.PirateVillBonus_Fire_Ambient_Cauldron_Loop_01", pot, {
			fadeIn = 1
		})
		fireSound2.Looped = true
		self.FireSound = fireSound2
	end)
	local fireSound = self.FireSound

	if fireSound ~= nil then
		self.Maid:GiveTask(function()
			self.FireSound = nil
			pcall(function()
				Sound:FadeOut(fireSound, 1)
			end)
		end)
	end
end

function v2.getFolder()
	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	if pirate then
		return (pirate:FindFirstChild("Cauldron_Moment"))
	end

	return nil
end

function v2.getCauldronPart(instance)
	local cauldron = instance:FindFirstChild("Cauldron")

	if not cauldron then
		return nil
	end

	if cauldron:IsA("BasePart") then
		return cauldron
	end

	if cauldron:IsA("Model") then
		return cauldron.PrimaryPart or cauldron:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

function v2.getNotes(instance)
	local parts = {}

	for _, part in instance:GetChildren() do
		if part.Name == "Note" and part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		if a.Position.X == b.Position.X then
			return a.Position.Z < b.Position.Z
		end

		return a.Position.X < b.Position.X
	end)
	return parts
end

function v2:setNote(p: string?)
	local surfaceGui = self:FindFirstChildWhichIsA("SurfaceGui")
	local imageLabel

	if surfaceGui then
		imageLabel = surfaceGui:FindFirstChildWhichIsA("ImageLabel", true)
	end

	local textLabel

	if surfaceGui then
		textLabel = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
	end

	if surfaceGui then
		surfaceGui.Enabled = true
	end

	if imageLabel then
		MaterialSprite.paint(imageLabel, p)
	end

	if textLabel then
		textLabel.Text = ""
	end

	self.LocalTransparencyModifier = 0
end

function v2.refreshPrompt(data)
	local prompt = data.Prompt

	if not (prompt and prompt.Parent) then
		return
	end

	local latest = data.Latest
	local cooked = not data.Moment.Active or data.Cancelled or data.Cooking or CauldronMenu.isOpen()

	if not cooked then
		if latest == nil then
			cooked = false
		else
			cooked = latest.Cooked
		end
	end

	prompt.Enabled = not cooked
end

function v2.drawNotes(data)
	local latest = data.Latest
	local v3 = not latest and {} or latest.Sheet
	local v4 = not (#v3 > 0 and #data.Notes > 0) and 0 or math.ceil(#v3 / #data.Notes)

	for k, note in data.Notes do
		local v5 = nil

		if v4 > 0 then
			local v6 = (k - 1) * v4
			local v7 = math.clamp(#v3 - v6, 0, v4)

			if v7 > 0 then
				v5 = v3[v6 + data.NoteStep % v7 + 1]
			end
		end

		v2.setNote(note, v5)
	end
end

function v2.startNoteCycle(p)
	task.spawn(function()
		while not p.Cancelled do
			task.wait(1.6)

			if p.Cancelled then
				break
			end

			p.NoteStep += 1
			v2.drawNotes(p)
		end
	end)
end

function v2:applyState(latest)
	self.Latest = latest
	v2.drawNotes(self)
	CauldronMenu.update(latest)

	if not (latest.Cooked or self.Cutscene) then
		self.Cooking = false
	end

	v2.refreshPrompt(self)
end

function v2.playBrew(data, color2: Color3)
	local liquid = data.Liquid

	if data.Cancelled or not (liquid and liquid.Parent) then
		return
	end

	Effect.new("Chests.Despawn"):play({
		CFrame = liquid.CFrame
	})
	local tween = TweenService:Create(liquid, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Color = color2
	})
	data.Maid:GiveTask(tween)
	tween:Play()
end

function v2.randomBrewColor()
	local v3 = numberRange.Min + math.random() * (numberRange.Max - numberRange.Min)
	local v4 = numberRange2.Min + math.random() * (numberRange2.Max - numberRange2.Min)
	return Color3.fromHSV(math.random(), v3, v4)
end

function v2.resetBrew(data)
	local liquid = data.Liquid
	local liquidColor = data.LiquidColor

	if data.Cancelled or data.Cooking or not (liquid and liquid.Parent and liquidColor) then
		return
	end

	local tween = TweenService:Create(liquid, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Color = liquidColor
	})
	data.Maid:GiveTask(tween)
	tween:Play()
end

function v2.buildBoil(p, parent)
	local attachment = Instance.new("Attachment")
	attachment.Name = "ChefsKissBoil"
	attachment.Parent = parent
	p.Maid:GiveTask(attachment)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Bubbles"
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = ColorSequence.new(parent.Color)
	particleEmitter.LightEmission = 0.4
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 1.1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.5, 0.9)
	particleEmitter.Speed = NumberRange.new(3, 6)
	particleEmitter.SpreadAngle = Vector2.new(22, 22)
	particleEmitter.Acceleration = createVector(0, 6, 0)
	particleEmitter.Rate = 14
	particleEmitter.Parent = attachment
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "Steam"
	particleEmitter2.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(226, 226, 226))
	particleEmitter2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 4) })
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(1.1, 1.8)
	particleEmitter2.Speed = NumberRange.new(2, 4)
	particleEmitter2.SpreadAngle = Vector2.new(35, 35)
	particleEmitter2.Rate = 7
	particleEmitter2.Parent = attachment
	return { particleEmitter, particleEmitter2 }
end

function v2.cookFrame(p, p2: number, p3: number, p4: number)
	local v3 = p.Position + createVector(0, 2, 0)
	local v4 = Vector3.new(math.cos(p4), 0, (math.sin(p4))) * p2
	return CFrame.lookAt(v3 + v4 + Vector3.new(0, p3, 0), v3)
end

function v2.playCookCutscene(p, state, p2: number)
	local liquid = state.Liquid

	if state.Cancelled or state.Cutscene or not (liquid and liquid.Parent) then
		return
	end

	state.Cutscene = true
	state.Cooking = true
	v2.refreshPrompt(state)
	CauldronMenu.close()
	local boil = v2.buildBoil(state, liquid)
	local v3 = CameraController.new(workspace.CurrentCamera, 1, 0.45)
	state.Maid:GiveTask(function()
		pcall(function()
			v3:Destroy()
		end)
	end)
	local character = p.Player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local v4 = math.atan2(
		not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and 1 or humanoidRootPart.Position.Z - liquid.Position.Z,
		not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and 0 or humanoidRootPart.Position.X - liquid.Position.X
	)
	Sound:Play("KiDash", liquid)
	v2.playAt("PirateVillageSFX.PirateVillBonus_Cook_Potion_Success_Cutscene_01", liquid)
	local total = 0
	local v5 = false

	while total < p2 and not state.Cancelled and liquid.Parent do
		local v6 = math.clamp(total / p2, 0, 1)
		local v7 = 1 - (1 - v6) * (1 - v6)
		v3.Animations:AnimateTo(
			v2.cookFrame(liquid, v7 * -5.5 + 13, v7 * -3.8 + 7, v4 + v7 * 0.9599310885968813),
			1,
			2.4
		)

		for _, v8 in boil do
			local rate

			if v8.Name == "Bubbles" then
				rate = v6 * 150 * v6 + 14
			else
				rate = v6 * 40 * v6 + 7
			end

			v8.Rate = rate
		end

		if not v5 and v6 >= 0.72 then
			v2.playBrew(state, color)
			v5 = true

			for _, v8 in boil do
				v8:Emit(45)
			end

			pcall(function()
				Util.CameraShaker:ShakeOnce(7, 5, 0.1, 1.1, createVector(1, 1, 1), createVector(1, 1, 2))
			end)
		end

		total += task.wait()
	end

	for _, v6 in boil do
		v6.Enabled = false
	end

	pcall(function()
		v3:FadeOut(0.45)
	end)
	state.Cutscene = false
	state.Cooking = false
	v2.refreshPrompt(state)
end

function v2.watchWalkAway(p, p2, instance)
	task.spawn(function()
		while CauldronMenu.isOpen() and not p2.Cancelled do
			task.wait(0.4)

			if not CauldronMenu.isOpen() or p2.Cancelled then
				break
			end

			local character = p.Player.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (not humanoidRootPart or not (humanoidRootPart:IsA("BasePart") and instance.Parent) or (humanoidRootPart.Position - instance.Position).Magnitude > 20) then
				continue
			end

			CauldronMenu.close()
			break
		end
	end)
end

function v2.openMenu(object, state, p)
	if not object.Active or state.Cancelled or CauldronMenu.isOpen() then
		return
	end

	local prompt = state.Prompt

	if prompt then
		prompt.Enabled = false
	end

	local v3 = object:InvokeServer("OpenCauldron")

	if state.Cancelled then
		return
	end

	if not v3 then
		v2.refreshPrompt(state)
		return
	end

	v2.applyState(state, v3)
	CauldronMenu.open(v3, {
		Insert = function(p2: string)
			local v4 = object:InvokeServer("Insert", p2)

			if state.Cancelled then
				return v4
			end

			if not v4 then
				v2.playAt("PirateVillageSFX.PirateVillBonus_Cook_Potion_Fail_01", state.Pot)
				return v4
			end

			v2.applyState(state, v4)
			v2.playBrew(state, v2.randomBrewColor())
			v2.playRandom(v, state.Pot)
			return v4
		end,
		Cook = function()
			local v4 = object:InvokeServer("Cook")

			if v4 == "Cooked" and not state.Cancelled then
				state.Cooking = true
				v2.refreshPrompt(state)
			end

			return v4
		end,
		Close = function()
			object:FireServer("CloseCauldron")
			v2.resetBrew(state)
			v2.refreshPrompt(state)
		end
	})
	v2.watchWalkAway(object, state, p)
end

function v2.addPrompt(p, p2, parent)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Cook"
	proximityPrompt.ObjectText = "Cauldron"
	proximityPrompt.MaxActivationDistance = 14
	proximityPrompt.HoldDuration = 0.4
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = parent
	p2.Prompt = proximityPrompt
	p2.Maid:GiveTask(proximityPrompt)
	p2.Maid:GiveTask(proximityPrompt.Triggered:Connect(function()
		v2.openMenu(p, p2, parent)
	end))
end

function v2.getState(maid)
	local _kitchenState = maid.MiscData._kitchenState

	if _kitchenState ~= nil then
		return _kitchenState
	end

	local kitchenState = {
		Moment = maid,
		Maid = Maid.new(),
		Cancelled = false,
		Notes = {},
		NoteStep = 0,
		Prompt = nil,
		Liquid = nil,
		LiquidColor = nil,
		Pot = nil,
		FireSound = nil,
		Latest = nil,
		Cooking = false,
		Cutscene = false
	}
	maid.MiscData._kitchenState = kitchenState
	maid:GiveTask(kitchenState.Maid)
	kitchenState.Maid:GiveTask(function()
		kitchenState.Cancelled = true
		CauldronMenu.close()

		for _, note in kitchenState.Notes do
			v2.setNote(note, nil)
		end

		local liquid = kitchenState.Liquid

		if liquid and liquid.Parent and kitchenState.LiquidColor then
			liquid.Color = kitchenState.LiquidColor
		end
	end)
	v2.startNoteCycle(kitchenState)
	return kitchenState
end

local ChefSKiss = {}
ChefSKiss.DataName = script.Name
ChefSKiss.Repeatable = true

function ChefSKiss.OnLoad(object)
	local folder = v2.getFolder()

	if not folder then
		warn((`[{script.Name}] missing workspace.Map.Pirate.Cauldron_Moment`))
		return
	end

	local state = v2.getState(object)
	state.Notes = v2.getNotes(folder)

	for _, note in state.Notes do
		local surfaceGui = note:FindFirstChildWhichIsA("SurfaceGui")

		if not (surfaceGui and surfaceGui:FindFirstChildWhichIsA("ImageLabel", true)) then
			warn((`[{script.Name}] Cauldron_Moment.Note has no ImageLabel to draw the recipe on`))
		end

		v2.setNote(note, nil)
	end

	local cauldronPart = v2.getCauldronPart(folder)

	if not cauldronPart then
		warn((`[{script.Name}] missing Cauldron_Moment.Cauldron`))
		return
	end

	local parent = cauldronPart.Parent
	local liquid

	if parent then
		liquid = parent:FindFirstChild("Liquid")
	end

	if liquid and liquid:IsA("BasePart") then
		state.Liquid = liquid
		state.LiquidColor = liquid.Color
	end

	v2.addPrompt(object, state, cauldronPart)
	local v3 = object:InvokeServer("GetState")

	if v3 and not state.Cancelled then
		v2.applyState(state, v3)
	end
end

function ChefSKiss.OnActive(p, flag: boolean)
	local _kitchenState = p.MiscData._kitchenState

	if not _kitchenState then
		return
	end

	if not flag then
		CauldronMenu.close()
	end

	v2.refreshPrompt(_kitchenState)
end

ChefSKiss.RemoteEvents = {
	CookCutscene = function(p, p2: number)
		local _kitchenState = p.MiscData._kitchenState

		if _kitchenState ~= nil and not _kitchenState.Cancelled then
			task.spawn(v2.playCookCutscene, p, _kitchenState, p2)
		end
	end,
	State = function(p, p2)
		local _kitchenState = p.MiscData._kitchenState

		if _kitchenState ~= nil and not _kitchenState.Cancelled then
			v2.applyState(_kitchenState, p2)
		end
	end
}

function ChefSKiss.OnComplete(p)
	local _kitchenState = p.MiscData._kitchenState

	if _kitchenState == nil then
		return
	end

	_kitchenState.Cooking = false
	CauldronMenu.close()
	v2.refreshPrompt(_kitchenState)
end

return ChefSKiss