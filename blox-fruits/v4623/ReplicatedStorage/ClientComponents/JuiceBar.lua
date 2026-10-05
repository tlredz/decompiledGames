local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local random = Random.new()
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Promise = require(game.ReplicatedStorage.Modules.Util.Promise)
local Util = require(game.ReplicatedStorage.Util)
local sound = Util.Sound
local Effect = require(game.ReplicatedStorage.Effect)
local SkinVFX = require(game.ReplicatedStorage.Util.SkinVFX)
local v = nil
local v2 = nil
local fn = nil
local v3 = false
local localPlayer = game.Players.LocalPlayer
local v4 = {
	"Music",
	"Success",
	"Idle",
	"Start",
	"InputBerry",
	"Drink",
	"Pour",
	"CupHit"
}
local v5 = {
	Main = true,
	Backpack = true,
	Notifications = true,
	JuiceWindowRoot = true
}
local screenGuis = {}
local v6 = nil
local v7 = nil
local v8 = Component.new({
	Tag = "JuiceBar"
})
local v9 = {
	"Initial",
	"Setup",
	"Loop",
	"Pour",
	"Serve",
	"Drink"
}

local function swapDummies(flag: boolean)
	local cframe = CFrame.new(0, -workspace.FallenPartsDestroyHeight + 1, 0)

	if flag then
		if v6 then
			v6:PivotTo(v6:GetAttribute("_FakePivot"))
		end

		if v7 then
			v7:PivotTo(v7:GetAttribute("_RealPivot"))
		end
	else
		if v6 then
			v6:PivotTo(v6:GetAttribute("_RealPivot"))
		end

		if v7 then
			v7:PivotTo(cframe)
			local animator = v7:FindFirstChild("Animator", true)

			if animator then
				animator:Destroy()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNPCHolder()
	return workspace:FindFirstChild("NPCs")
end

local function toggleModelVisible(instance, flag: boolean)
	local descendants = {}

	if typeof(instance) == "table" then
		descendants = instance
	elseif instance:IsA("Instance") then
		descendants = instance:GetDescendants()
		table.insert(descendants, instance)
	end

	for _, instance2 in pairs(descendants) do
		if instance2:IsA("MeshPart") then
			instance2.LocalTransparencyModifier = flag and 0 or 1
		elseif instance2:IsA("Decal") then
			instance2.LocalTransparencyModifier = flag and 0 or 1
		end
	end
end

local function spawnBerry(parent, childName: string)
	local clone = v2:FindFirstChild(childName):FindFirstChildOfClass("MeshPart"):FindFirstChildOfClass("SurfaceAppearance"):Clone()
	parent:FindFirstChild("SurfaceAppearance", true):Destroy()
	clone.Parent = parent
	toggleModelVisible(parent, true)
	return parent
end

local function spawnChalice(object, flag: boolean?)
	if not object.recipe then
		warn("No recipe??")
		return
	end

	local chalices = v7:FindFirstChild("Chalices")

	if not chalices then
		warn("No Chalices??")
		return
	end

	local item = object.recipe.Item
	local model = chalices:FindFirstChild(item)

	if not (model and model:IsA("Model")) then
		warn("No chalice for", item)
		return
	end

	if fn then
		fn()
	end

	SkinVFX.applySkin(ItemConfig.match(object.recipe.StorageName, "Skin"):unwrap().Index.ItemId, {
		[model] = `Chalices.{item}`
	})

	if object.recipe.AuraColor and object.recipe.AuraColor.Type == "ColorSet" and object.recipe.AuraColor.FadeColor3 then
		local v10 = SkinVFX.applyChaliceColor(model, object.recipe.AuraColor)

		fn = function()
			fn = nil
			v10()
		end
	end

	if not flag and model then
		toggleModelVisible(model, true)
	end

	return model
end

local v10 = nil

function getMyNPC(p, flag: boolean?)
	if v10 then
		v10:cancel()
		v10 = nil
	end

	v10 = Promise.new(function(callback, callback2, callback3)
		local v11 = false
		callback3(function()
			v11 = true
		end)
		local total = 0
		local v12 = false

		while not v11 do
			if localPlayer.Team then
				local nPCHolder = getNPCHolder() -- equivalent call inferred; original call site unknown

				if nPCHolder then
					local barista = nPCHolder:FindFirstChild("Barista")

					if barista and barista:GetAttribute("NPCLoaded") then
						local baristaId

						if flag then
							local Global = require(game.ReplicatedStorage.Global)

							if Global.GetQueue then
								local Global2 = require(game.ReplicatedStorage.Global)

								if Global2.GetQueue(barista) then
									baristaId = barista:GetAttribute("BaristaId")

									if barista:GetAttribute("BaristaId") == nil then
										warn("Barista has no [BaristaId] and won't be found by the machine!!!")
									elseif p.id == baristaId then
										v6 = barista
										break
									end
								end
							end
						else
							baristaId = barista:GetAttribute("BaristaId")

							if barista:GetAttribute("BaristaId") == nil then
								warn("Barista has no [BaristaId] and won't be found by the machine!!!")
							elseif p.id == baristaId then
								v6 = barista
								break
							end
						end
					end
				end

				total += task.wait(2)

				if total >= 10 and not v12 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.TestGamePrint("GetMyNPC is taking awhile.", p.id)
					v12 = true
				end
			else
				task.wait(1)
			end
		end

		v10 = nil

		if v6 and not v11 then
			if not v7 then
				local _RealPivot = v6:GetAttribute("_RealPivot") or v6:GetPivot()
				v6:SetAttribute("_RealPivot", _RealPivot)
				v6:SetAttribute("_FakePivot", _RealPivot * CFrame.new(0, -(v6:GetExtentsSize().Y + 5), 0))
				local clone = v6:Clone()
				v7 = clone
				clone.Name = "BaristaCutsceneDummy_Stored"
				clone:PivotTo(CFrame.new(0, workspace.FallenPartsDestroyHeight + 1, 0))
				local descendants = clone:GetDescendants()
				table.insert(descendants, clone)

				for _, instance in pairs(descendants) do
					if instance:IsA("BillboardGui") or instance:IsA("Animator") or instance.Name == "SHOP" then
						instance:Destroy()
					end

					for _, tag in pairs(game.CollectionService:GetTags(instance)) do
						game.CollectionService:RemoveTag(instance, tag)
					end
				end

				clone.Parent = workspace
				task.spawn(function()
					local chalices = v6:WaitForChild("Chalices", 5)
					local berries = v6:WaitForChild("Berries", 5)

					if chalices then
						chalices:Destroy()
					end

					if berries then
						berries:Destroy()
					end
				end)
			end

			callback(v7, v6)
		else
			callback2("GetMyNPC/Cancelled")
		end
	end)
	return v10
end

function v8:PlaySound(p2: string, p3)
	local sound2 = self.sounds[p2]

	if sound2 then
		sound:Kill(sound2)
	end

	self.sounds[p2] = sound:Play(`BaristaCutscene.{p2}`, p3)
	return self.sounds[p2]
end

local function getAnimation(object, instance, p: string)
	if not object.tracks[instance.Name .. p] then
		local Util2 = require(game.ReplicatedStorage.Util)
		local v11 = assert(Util2.Anims:GetRaw(p), p)
		local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
		local v12 = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if not v12 then
			v12 = Instance.new("Animator")
			v12.Parent = humanoid
		end

		local track = nil

		if v12 then
			pcall(function()
				track = v12:LoadAnimation(v11)
			end)
		end

		if track then
			object.tracks[instance.Name .. p] = track
		else
			warn("Unknown", p, humanoid, v12)
			return nil
		end
	end

	object.tracks[instance.Name .. p].Looped = false
	object.tracks[instance.Name .. p].Priority = Enum.AnimationPriority.Action3
	return object.tracks[instance.Name .. p]
end

local playScene

playScene = function(object, p: string)
	if object.scenes[p] then
		object.scenes[p]:Destroy()
	end

	if object:IsDead() then
		return
	end

	local maid = object.cutscene:Extend()
	maid:Add(function()
		maid = nil
		object.scenes[p] = nil

		if object.cutscene then
			local v11 = table.find(v9, p) + 1

			if v9[v11] then
				playScene(object, v9[v11])
			elseif not object:IsDead() then
				object.cutscene:Destroy()
			end
		end
	end)
	object.scenes[p] = maid
	local success, result = pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		local instance = object.Instance
		local v11 = v7
		local camera = instance:FindFirstChild("Camera")
		local machine = instance:FindFirstChild("Machine")
		local animation = getAnimation(object, v11, "BaristaIdle")
		local animation2 = getAnimation(object, v11, "BaristaInitial")
		local animation3 = getAnimation(object, v11, "BaristaSetup")
		local animation4 = getAnimation(object, v11, "BaristaLoop")
		local animation5 = getAnimation(object, v11, "BaristaPour")
		local animation6 = getAnimation(object, camera, "JuiceCameraSetup")
		local animation7 = getAnimation(object, camera, "JuiceCameraPour")
		local animation8 = getAnimation(object, camera, "JuiceCameraLoop")
		local animation9 = getAnimation(object, machine, "JuiceMachineIdle")
		local animation10 = getAnimation(object, machine, "JuiceMachineSetup")
		local animation11 = getAnimation(object, machine, "JuiceMachineLoop")
		local animation12 = getAnimation(object, machine, "JuiceMachinePour")
		local animation13 = getAnimation(object, localPlayer.Character, "JuiceMachineDrink")
		assert(animation)
		assert(animation2)
		assert(animation3)
		assert(animation4)
		assert(animation5)
		assert(animation6)
		assert(animation7)
		assert(animation8)
		assert(animation9)
		assert(animation10)
		assert(animation11)
		assert(animation12)
		assert(animation13)
		local idle = object.sounds.Idle

		if idle and idle.Volume > 0 then
			TweenService:Create(idle, TweenInfo.new(1), {
				Volume = 0
			}):Play()
		end

		if p == "Initial" then
			local rightBerry = v7:FindFirstChild("RightBerry", true)

			if rightBerry then
				local parent = spawnBerry(rightBerry, object.recipe.Berries[#object.recipe.Berries])
				maid:Add(function()
					toggleModelVisible(parent, false)
				end)
			else
				warn("NPC has no RightHand.RightBerry")
			end

			maid:Add(animation2.Stopped:Once(function()
				maid:Destroy()
			end))
			maid:Add(function()
				if object:IsDead() then
					return
				end

				animation9:Stop()
				animation2:Stop()
			end)
			animation9.Looped = true
			animation9:Play()
			animation2:Play()
			local playSound = object:PlaySound("Start")
			playSound.Volume = 0.4
		elseif p == "Setup" then
			maid:Add(animation3:GetMarkerReachedSignal("End"):Once(function()
				maid:Destroy()
			end))
			maid:Add(function()
				if object:IsDead() then
					return
				end

				animation6:Stop()
				animation10:Stop()
				animation3:Stop()
			end)
			animation6:Play()
			animation10:Play()
			animation3:Play()
		elseif p == "Loop" then
			animation4.Looped = false
			animation11.Looped = false
			animation8.Looped = true
			local leftBerry = v7:FindFirstChild("LeftBerry", true)

			if leftBerry then
				if #object.recipe.Berries == 0 then
					warn("No berries to insert")
					maid:Destroy()
				else
					local berry = object.recipe.Berries[#object.recipe.Berries]
					local v12 = spawnBerry(leftBerry, berry)

					local function berryLoop()
						local berry2 = object.recipe.Berries[#object.recipe.Berries]

						if berry2 then
							berry = berry2
							v12 = spawnBerry(leftBerry, berry2)
							table.remove(object.recipe.Berries, #object.recipe.Berries)
							animation4:Play()
							animation11:Play()
						end
					end

					maid:Add(animation4:GetMarkerReachedSignal("SpawnBerry"):Connect(function()
						if #object.recipe.Berries == 0 then
							maid:Destroy()
						else
							berryLoop()
						end
					end))
					maid:Add(animation8:GetMarkerReachedSignal("Pause"):Connect(function()
						animation8:AdjustSpeed(0)
					end))
					maid:Add(animation4.Stopped:Once(function()
						maid:Destroy()
					end))
					local rootPart = machine:FindFirstChild("RootPart")

					if rootPart then
						local input = rootPart:FindFirstChild("Input")

						if input then
							maid:Add(animation4:GetMarkerReachedSignal("InputBerry"):Connect(function()
								if berry then
									local berryColor = object.recipe.BerryColors[berry]
									local berriesCutscene = Effect.new("Berries.Cutscene")
									local v13 = {
										Index = 1,
										CFrame = input.WorldCFrame,
										Color1 = 0,
										Color2 = 0
									}
									local color

									if berryColor then
										color = berryColor.PrimaryColor or nil
									end

									v13.Color1 = color
									v13.Color2 = berryColor and berryColor.SecondaryColor or nil
									berriesCutscene:play(v13)
								end

								local v13 = object:PlaySound("InputBerry")
								v13.Looped = false
								v13.Volume = 0.4

								if v12 then
									toggleModelVisible(v12, false)
								end
							end))
						else
							warn("Machine has no Root.Input")
						end
					else
						warn("Machine has no Machine.Root")
					end

					maid:Add(function()
						if object:IsDead() then
							return
						end

						animation8:Stop()
						animation11:Stop()
						animation4:Stop()

						if v12 then
							toggleModelVisible(v12, false)
						end
					end)
					animation8:Play()
					berryLoop()
				end
			else
				warn("Npc has no LeftHand.LeftBerry")
				maid:Destroy()
			end
		elseif p == "Pour" then
			maid:Add(animation5:GetMarkerReachedSignal("SpawnChalice"):Once(function()
				spawnChalice(object)
			end))
			local rootPart = machine:FindFirstChild("RootPart")
			local dispense = rootPart and rootPart:FindFirstChild("Dispense")

			if dispense then
				local berryColors = {}

				for _, berryColor in pairs(object.recipe.BerryColors) do
					table.insert(berryColors, berryColor)
				end

				local clone = table.clone(berryColors)
				local v12 = nil
				local count = 0
				maid:Add(animation12:GetMarkerReachedSignal("Dispense"):Connect(function()
					count += 1

					if count == 1 and object.sounds.Music then
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(object.sounds.Music, TweenInfo.new(1.5), {
							Volume = 0
						}):Play()
					end

					local integer = random:NextInteger(1, #berryColors)
					local _ = berryColors[integer]

					if #clone > 0 then
						integer = random:NextInteger(1, #clone)
						local _ = clone[integer]
						table.remove(clone, integer)
					end

					if v12 then
						v12()
						maid:Remove(v12)
						v12 = nil
					end

					local v13 = berryColors[integer]
					v12 = Effect.new("Berries.Cutscene"):play({
						Index = 2,
						Duration = 0.35,
						CFrame = dispense.WorldCFrame,
						Color1 = v13.PrimaryColor,
						Color2 = v13.SecondaryColor
					})
					maid:Add(function()
						if v12 then
							v12()
							v12 = nil
						end
					end)
				end))
			else
				warn("Machine has no RootPart.Dispense")
			end

			maid:Add(animation7:GetMarkerReachedSignal("Pause"):Once(function()
				animation7:Stop()
				maid:Destroy()
			end))
			maid:Add(function()
				if object:IsDead() then
					return
				end

				animation12:Stop()
				local playSound = object:PlaySound("Success")
				playSound.Volume = 0.5
			end)
			animation12:Play()
			animation7:Play()
			animation5:Play()
			local playSound_2 = object:PlaySound("Pour")
			playSound_2.Volume = 0.5
		elseif p == "Serve" then
			animation9:Play()
			maid:Add(animation5:GetMarkerReachedSignal("HandOff"):Once(function()
				maid:Destroy()
			end))
		elseif p == "Drink" then
			local chalices = v7:FindFirstChild("Chalices")
			local v12 = v

			if not v12 then
				local Net = require(game.ReplicatedStorage.Modules.Net)
				v12 = Net:RemoteFunction("JuiceNetworkRF")
			end

			v = v12
			task.spawn(function()
				v:InvokeServer({
					Context = "Drink"
				})
			end)

			if chalices then
				toggleModelVisible(chalices, false)
			end

			maid:Add(animation5:GetMarkerReachedSignal("Pause"):Once(function()
				animation.Looped = true
				animation:Play()
				animation5:Stop()
				animation9:Play()
			end))
			maid:Add(animation13.Stopped:Once(function()
				maid:Destroy()
			end))
			local berryColors = {}

			for _, berryColor in pairs(object.recipe.BerryColors) do
				table.insert(berryColors, berryColor)
			end

			local clone = table.clone(berryColors)
			local integer = random:NextInteger(1, #berryColors)
			local _ = berryColors[integer]

			if #clone > 0 then
				integer = random:NextInteger(1, #clone)
				local _ = clone[integer]
				table.remove(clone, integer)
			end

			local v13 = berryColors[integer]
			Effect.new("Berries.Cutscene"):play({
				Track = animation13,
				UserId = localPlayer.UserId,
				Index = 3,
				StorageName = object.recipe.StorageName,
				ForceStop = function()
					maid:Destroy()
				end,
				Color1 = v13.PrimaryColor,
				Color2 = v13.SecondaryColor
			})
			object:PlaySound("Drink", localPlayer.Character)
		end
	end)

	if not success then
		warn(result)

		if maid then
			maid:Destroy()
		end
	end
end

local function reset(object)
	for _, v11 in pairs(v9) do
		if object.scenes[v11] then
			object.scenes[v11]:Destroy()
		end
	end

	table.clear(object.scenes)

	for _, track in pairs(object.tracks) do
		track:Stop()
		track:Destroy()
	end

	table.clear(object.tracks)

	for _, sound2 in pairs(object.sounds) do
		sound2:Stop()
	end

	if object:IsDead() then
		return
	end

	toggleModelVisible(v7:FindFirstChild("Berries"), false)
	toggleModelVisible(v7:FindFirstChild("Chalices"), false)
end

function setDefault(object)
	if object:IsDead() then
		return
	end

	local v11 = object.cutscene ~= nil
	reset(object)
	local v12 = assert(object.Instance:FindFirstChild("Machine"))
	local animation = getAnimation(object, v12, "JuiceMachineIdle")

	if animation then
		animation.Looped = true
		animation:Play()
	end

	local v13 = object:PlaySound("Idle", v12.PrimaryPart)
	v13.Looped = true
	v13.Volume = 0

	if v11 then
		TweenService:Create(v13, TweenInfo.new(1.5), {
			Volume = 0.015
		}):Play()
	else
		v13.Volume = 0.015
	end
end

function v8:Construct()
	self.trove = Trove.new()
	self.scenes = {}
	self.tracks = {}
	self.sounds = {}
	self.cutscene = nil
	self.lockedPlayer = false
	self.id = self.Instance:GetAttribute("BaristaId")

	if not self.id then
		warn("Juice bar has no BaristaId and won't be able to match to an npc!!")
	end
end

function v8:IsDead()
	return self.trove._cleaning == true
end

function begin(object, storageName: string)
	if object.cutscene then
		object.cutscene:Destroy()
	end

	if object:IsDead() then
		return
	end

	object.trove:AddPromise(getMyNPC(object, true):andThen(function()
		task.spawn(function()
			getAnimation(object, v7, "BaristaInitial")
			getAnimation(object, v7, "BaristaSetup")
		end)
		local maid = object.trove:Extend()
		object.cutscene = maid
		CFrame.new(0, -workspace.FallenPartsDestroyHeight + 1, 0)

		if v6 then
			v6:PivotTo(v6:GetAttribute("_FakePivot"))
		end

		if v7 then
			v7:PivotTo(v7:GetAttribute("_RealPivot"))
		end

		maid:Add(function()
			local cframe = CFrame.new(0, -workspace.FallenPartsDestroyHeight + 1, 0)

			if v6 then
				v6:PivotTo(v6:GetAttribute("_RealPivot"))
			end

			if v7 then
				v7:PivotTo(cframe)
				local animator = v7:FindFirstChild("Animator", true)

				if animator then
					animator:Destroy()
				end
			end
		end)
		local busy = nil
		local success, result = pcall(function()
			tick()
			local Global = require(game.ReplicatedStorage.Global)
			local getQueue = Global.GetQueue

			if getQueue then
				local Global2 = require(game.ReplicatedStorage.Global)
				getQueue = Global2.GetQueue(v6)
			end

			maid:Add(localPlayer.CharacterAdded:Once(function()
				maid:Destroy()
			end))
			local thread = nil
			thread = task.delay(27, function()
				thread = nil
				print("Something broke..")
				maid:Destroy()
			end)
			maid:Add(function()
				if thread then
					task.cancel(thread)
					thread = nil
				end

				if fn then
					fn()
				end

				local Global2 = require(game.ReplicatedStorage.Global)
				Global2.updateMusic2(false)
			end)
			local playerGui = localPlayer:FindFirstChild("PlayerGui")

			if playerGui then
				for childName in v5 do
					local screenGui = playerGui:FindFirstChild(childName)

					if not screenGui then
						continue
					end

					if screenGui:IsA("ScreenGui") then
						table.insert(screenGuis, screenGui)
						screenGui.Enabled = false
					else
						warn((`toHide/{childName} is not a screenGui`))
					end
				end
			end

			maid:Add(function()
				task.spawn(function()
					local Net = require(game.ReplicatedStorage.Modules.Net)
					Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
						Context = "FinishCraft",
						StorageName = storageName
					})
				end)
				object.cutscene = nil

				for _, v11 in pairs(screenGuis) do
					v11.Enabled = true
				end

				table.clear(screenGuis)

				if busy then
					busy.Value = false
				end

				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					workspace.CurrentCamera.CameraSubject = humanoid
				end

				if getQueue then
					getQueue.GUI.InteractionLock:Unlock("JuiceBar")
				end

				if not object:IsDead() then
					setDefault(object)
				end
			end)

			if getQueue then
				getQueue.GUI.InteractionLock:Lock("JuiceBar")
			end

			local unwrapped = ItemConfig.match(storageName, "Skin"):unwrap()
			local unwrapped2 = ItemConfig.match(Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()):unwrap()
			local nullable = Skin.Definition.Appearance.match(unwrapped.Index.ItemId):asNullable()
			local recipe = {
				Item = unwrapped2.Index.StorageKey,
				StorageName = unwrapped.Index.StorageKey,
				SkinName = unwrapped.Display.Name or unwrapped.Index.StorageKey,
				Type = `{not unwrapped.Skin and "" or unwrapped.Skin.Type}Skin`,
				AuraColor = nullable,
				Berries = {},
				BerryColors = {}
			}
			object.recipe = recipe

			local function addBerries(items)
				for _, item in pairs(items) do
					local child = v2:FindFirstChild(item.Name)

					if not child then
						break
					end

					table.insert(recipe.Berries, child.Name)
					recipe.BerryColors[child.Name] = {
						PrimaryColor = child:GetAttribute("Color1"),
						SecondaryColor = child:GetAttribute("Color2")
					}

					if not recipe.BerryColors[child.Name].PrimaryColor then
						warn("Berry has no primary color", child.Name)
					end

					if not recipe.BerryColors[child.Name].SecondaryColor then
						warn("Berry has no secondary color", child.Name)
					end
				end
			end

			local nullable2 = Skin.Definition.Recipe.match(unwrapped.Index.ItemId):asNullable()

			if nullable2 then
				local v12 = {}

				for k, ingredient in nullable2.Ingredients do
					table.insert(v12, {
						Amount = ingredient,
						Name = ItemConfig.match(k):unwrap().Index.StorageKey
					})
				end

				addBerries(v12)
			end

			if #recipe.Berries == 0 then
				addBerries(v2:GetChildren())
			end

			local instance = object.Instance
			local camera = instance:FindFirstChild("Camera")
			instance:FindFirstChild("Machine")
			local cam = camera:FindFirstChild("Cam")
			local cameraPart = object.Instance:FindFirstChild("CameraPart")
			local head = v7:FindFirstChild("Head")
			v7:FindFirstChildOfClass("Humanoid")
			local cFrame = cameraPart.CFrame
			local character = localPlayer.Character
			local primaryPart = character and character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")

			if character then
				character:FindFirstChild("Head")
			end

			local primaryPart2 = v7 and (v7.PrimaryPart or v7:FindFirstChildOfClass("BasePart"))

			if not primaryPart2 then
				warn("Basista has no primary part")
				primaryPart2 = head
			end

			if character then
				busy = character:FindFirstChild("Busy")

				if busy then
					busy.Value = true
				else
					print("No busy `BoolValue` in player", localPlayer)
				end

				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					object.lockedPlayer = true
					local autoRotate = humanoid.AutoRotate
					humanoid.AutoRotate = false
					maid:Add(function()
						object.lockedPlayer = false

						if humanoid and humanoid.Parent then
							humanoid.AutoRotate = autoRotate
						end
					end)
				end
			end

			local count = 0
			local v12 = {
				p = 20,
				offset = -12,
				start = 120,
				stop = -130,
				mul = 120,
				height = not primaryPart and 0 or primaryPart.Size.Y * 1 or 0
			}
			local start = v12.start
			maid:Add(RunService.Heartbeat:Connect(function(dt: number)
				if not object.cutscene then
					return
				end

				if object.scenes.Initial == nil then
					if object.scenes.Serve or object.scenes.Drink then
						local cFrame2 = primaryPart and primaryPart.CFrame

						if not cFrame2 then
							return
						end

						local cframe = CFrame.Angles(0, math.rad(start), 0)
						local cframe2 = CFrame.new(0, 0, -v12.offset)
						local position = (cFrame2 * cframe * cframe2).Position
						local v13 = CFrame.lookAt(position, cFrame2.Position) * CFrame.new(0, v12.height, 0)
						local lerped = workspace.CurrentCamera.CFrame:Lerp(v13, dt * v12.p)
						workspace.CurrentCamera.CFrame = lerped

						if object.scenes.Drink then
							start = math.clamp(start - dt * v12.mul, v12.stop, v12.start)
						end
					elseif count > 2 then
						workspace.CurrentCamera.CFrame = cam.CFrame
					else
						count += 1
					end
				elseif primaryPart2 then
					workspace.CurrentCamera.CFrame = CFrame.lookAt(cFrame.Position, primaryPart2.CFrame.Position)
				end
			end))
			maid:Add(function()
				if object.sounds.Music and object.sounds.Music.Volume == 0.15 then
					object.sounds.Music.Volume = 0
				end
			end)
			reset(object)
			local Global2 = require(game.ReplicatedStorage.Global)
			task.spawn(Global2.updateMusic2, true)
			local v13 = object:PlaySound("Music")
			v13.Volume = 0
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v13, TweenInfo.new(0.25), {
				Volume = 0.15
			}):Play()
			playScene(object, "Initial")
		end)

		if not success then
			warn(result)

			if object.cutscene then
				object.cutscene:Destroy()
			end
		end
	end))
end

v8.Begin = begin

function v8:Start()
	self.trove:Add(function()
		for _, track in pairs(self.tracks) do
			track:Stop()
			track:Destroy()
		end

		for _, sound2 in pairs(self.sounds) do
			sound2:Stop()
			sound:Kill(sound2)
		end

		local cframe = CFrame.new(0, -workspace.FallenPartsDestroyHeight + 1, 0)

		if v6 then
			v6:PivotTo(v6:GetAttribute("_RealPivot"))
		end

		if v7 then
			v7:PivotTo(cframe)
			local animator = v7:FindFirstChild("Animator", true)

			if animator then
				animator:Destroy()
			end
		end

		table.clear(self.sounds)
		table.clear(self.tracks)
	end)
	self.trove:AddPromise(getMyNPC(self):andThen(function()
		if not v3 then
			v3 = true
			task.spawn(function()
				local children = {}

				for _, child in pairs(game.ReplicatedStorage.Storage.Anims["2"].JuiceBar.Barista:GetChildren()) do
					table.insert(children, child)
				end

				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(children)
			end)
			task.spawn(function()
				for _, v11 in pairs(v4) do
					sound:Preload((`BaristaCutscene.{v11}`))
				end
			end)
		end

		v2 = v2 or game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("Berries")

		if not self:IsDead() then
			setDefault(self)
			local v11, v12, chatted

			if RunService:IsStudio() then
				v11 = { "FALCSKINparrot" }
				v12 = 1

				chatted = function(p)
					if p == "/scene" then
						local Net = require(game.ReplicatedStorage.Modules.Net)
						Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
							Context = "TestScene",
							StorageName = v11[v12]
						})
						v12 = v12 + 1 > #v11 and 1 or v12 + 1
					elseif p == "/stream" then
						localPlayer.Character:MoveTo(localPlayer.Character.PrimaryPart.Position + createVector(
							0,
							999999,
							0
						))
					end
				end

				self.trove:Add(localPlayer.Chatted:Connect(chatted))
			else
				local Global = require(game.ReplicatedStorage.Global)

				if Global.TestGame then
					v11 = { "FALCSKINparrot" }
					v12 = 1

					chatted = function(p)
						if p == "/scene" then
							local Net = require(game.ReplicatedStorage.Modules.Net)
							Net:RemoteFunction("JuiceNetworkRF"):InvokeServer({
								Context = "TestScene",
								StorageName = v11[v12]
							})
							v12 = v12 + 1 > #v11 and 1 or v12 + 1
						elseif p == "/stream" then
							localPlayer.Character:MoveTo(localPlayer.Character.PrimaryPart.Position + createVector(
								0,
								999999,
								0
							))
						end
					end

					self.trove:Add(localPlayer.Chatted:Connect(chatted))
				end
			end
		end
	end):catch(print))
end

function v8:Stop()
	self.trove:Destroy()
end

return v8