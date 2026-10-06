local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local localPlayer = game.Players.LocalPlayer
local Chat = game:GetService("Chat")
local gui = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Gui")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local Lore = require(script:WaitForChild("Lore"))
local chest = ReplicatedStorage:WaitForChild("Chest")
local textShow_ = script:WaitForChild("TextShow_")
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local CollectionService = game:GetService("CollectionService")
local lastTime = nil

function GenerateTextSystem(data)
	return ("<font color='#" .. (data.Color and data.Color:ToHex() or Color3.fromRGB(255, 255, 255):ToHex()) .. "'>") .. ("<font face='" .. (data.Font or "Gotham") .. "'>") .. ("<font size='" .. (data.FontSize or "18") .. "'>") .. data.Text .. "</font></font></font>"
end

local function getAnimationTrack(humanoid, p)
	for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v and v.Animation and v.Animation.AnimationId == `rbxassetid://{p}` then
			return v
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomDirection()
	return Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
end

local function createHighlight(tehtacleHand, value)
	if not (tehtacleHand and tehtacleHand.Parent) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.Parent = tehtacleHand
	TweenService:Create(highlight, TweenInfo.new(0.55), {
		FillTransparency = 1
	}):Play()
	_G.PU:Dust(highlight, value or 0.65)
	return highlight
end

local function setRay(clone)
	if clone then
		local ray = Ray.new(clone.CFrame.Position, createVector(0, -25, 0))
		local _, v = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Island })

		if v then
			clone.CFrame = CFrame.new(v + Vector3.new(0, clone.Size.Y / 2, 0)) * CFrame.Angles(
				0,
				math.rad(clone.Orientation.Y),
				0
			)
		end
	end
end

local function NoCollision(part)
	if part:IsA("BasePart") then
		part.CanCollide = false
		part.Massless = true
		part.CollisionGroup = "p"
	end

	for _, part2 in pairs(part:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.CanCollide = false
		part2.Massless = true
		part2.CollisionGroup = "p"
	end
end

local function Emit(p)
	PeoUtils:EmitParticles(p)
	return true
end

return function(list)
	local v, cFrame3, v3, _ = unpack(list)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function textAlert(p)
		ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes").Bindables.TextAlert:Fire("LeeAlert", p)
	end

	local success, result = pcall(function()
		return (localPlayer.Character.HumanoidRootPart.Position - cFrame3.p).Magnitude > 1000
	end)

	if v and v3.Alert and v3.Text then
		textAlert({
			Text = v3.Text,
			Color = v3.Color or Color3.new(0, 1, 0.139086)
		}) -- equivalent call inferred; original call site unknown
	end

	local v4 = v and localPlayer == v and true or nil
	local class = {}
	class.__index = class

	function class:RequestQuest(p)
		if not v4 then
			return
		end

		local currentQuest = localPlayer:WaitForChild("CurrentQuest")
		local questProgress = localPlayer:WaitForChild("QuestProgress")
		return currentQuest.Value == p and questProgress.Value > 0 or nil
	end

	if v and v3.Machinima then
		local character = v.Character
		local playerGui = v.PlayerGui
		local mainGui = playerGui:WaitForChild("MainGui")
		local popup = playerGui:WaitForChild("Popup")
		mainGui.Enabled = false
		popup.Enabled = false

		if character:FindFirstChild("MachinimaMorphed") then
			local destroyingConnection = nil
			destroyingConnection = character.MachinimaMorphed.Destroying:Connect(function()
				if mainGui and popup then
					mainGui.Enabled = true
					popup.Enabled = true
				end

				if destroyingConnection then
					destroyingConnection:Disconnect()
					destroyingConnection = nil
				end
			end)
		end
	end

	if success then
		if result then
			return
		end

		local questType = v3.QuestType
		local object = v3.Object
		local class2 = {}
		local v5 = {
			Emit = function(self, folder, value, p)
				if folder and folder.Parent then
					local v6 = value or 1

					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter:GetAttribute("EmitCount") then
							local emitCount = tonumber(emitter:GetAttribute("EmitCount")) or 0

							if emitCount > 0 then
								v6 = emitCount
							end

							if p then
								emitter.Color = ColorSequence.new(p)
							end
						end

						emitter:Emit(v6)
					end
				end
			end,
			Enabled = function(self, folder)
				if folder and folder.Parent then
					for _, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			end,
			Disabled = function(self, folder)
				if folder and folder.Parent then
					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter:Clear()
						task.wait(0)
						emitter.Enabled = false
					end
				end
			end
		}

		function class2:Sound(options)
			local v6, v7 = unpack(options or {})
			local sound = Instance.new("Sound")
			sound.Parent = object or v7
			sound.SoundId = "rbxassetid://" .. v6
			task.spawn(function()
				if not sound.Loaded then
					sound.Loaded:Wait()
				end

				sound:Play()
				_G.PU:Dust(sound, sound.TimeLength + 5)
			end)
			return sound
		end

		function class2.Curve(_, ...)
			local v6 = ...

			if not v6 then
				return
			end

			local vector3Curve = Instance.new("Vector3Curve")
			local v7 = vector3Curve:X()
			local v8 = vector3Curve:Y()
			local v9 = vector3Curve:Z()

			for _, v10 in pairs(v6) do
				v7:InsertKey(FloatCurveKey.new(v10.Time, v10.CF.X, v10.Mode))
				v8:InsertKey(FloatCurveKey.new(v10.Time, v10.CF.Y, v10.Mode))
				v9:InsertKey(FloatCurveKey.new(v10.Time, v10.CF.Z, v10.Mode))
			end

			return vector3Curve
		end

		function class2:Ball(options)
			local _, v6, v7 = unpack(options or {})
			local part = Instance.new("Part")
			part.Anchored = true
			part.Name = script.Name .. v.Name .. "_"
			part.Shape = "Ball"
			part.Size = Vector3.new()
			part.CFrame = v7 or CFrame.new(0, 0, 0)
			part.CanCollide = false
			part.Material = v6 or Enum.Material.Neon
			return part
		end

		function class2:Weld(...)
			local v6, part = unpack(... or {})

			if not (v6 or part) then
				return
			end

			local weld = Instance.new("Weld")
			weld.Part0 = v6
			weld.Part1 = part
			weld.Parent = v6
			return weld
		end

		if v3.Gui and v3.Lore and object and object.Parent and v == localPlayer then
			local lore = v3.Lore
			local playerGui = localPlayer.PlayerGui
			local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart", 5)

			if not (humanoidRootPart and Lore[lore]) then
				return
			end

			local flag = nil
			local RichText = require(game.ReplicatedStorage.Chest.Modules.RichText)
			local v6 = nil

			if localPlayer:FindFirstChild("PlayerStats") then
				local language = localPlayer.PlayerStats:FindFirstChild("Language")
				v6 = language and language.Value == "TH" and true or v6
			end

			for _, child in pairs(playerGui:GetChildren()) do
				if child.Name ~= "LeePunggLoreViewer" then
					continue
				end

				child:Destroy()
				flag = true
			end

			if flag then
				return
			end

			local clone = gui:WaitForChild("LeePunggLoreViewer"):Clone()
			clone.Parent = playerGui
			local viewportFrame = clone:WaitForChild("ViewportFrame", 5)
			local v7 = nil
			local v8 = Lore[lore]
			local textFrame = clone.TextFrame

			if viewportFrame and viewportFrame:FindFirstChild("Anims") then
				local anims = viewportFrame.Anims
				local loreMDL = viewportFrame:FindFirstChild("LoreMDL")

				if loreMDL then
					local loreNPC = loreMDL:FindFirstChild("LoreNPC")

					if loreNPC and loreNPC:FindFirstChild("FakeHumanoid") then
						local v9 = { "Talking1", "Talking2", "Talking3" }
						local v10 = v9[math.random(#v9)]
						local fakeHumanoid = loreNPC.FakeHumanoid
						fakeHumanoid:LoadAnimation(anims.Idle):Play()

						if anims:FindFirstChild(v10) then
							local track = fakeHumanoid:LoadAnimation(anims[v10])
							track:Play()
							local thread = coroutine.create(function()
								while fakeHumanoid and fakeHumanoid.Parent do
									task.wait(2.5)

									if v7 or not (viewportFrame and viewportFrame.Parent and loreMDL.Parent and fakeHumanoid and fakeHumanoid.Parent) then
										break
									end

									v10 = v9[math.random(#v9)]
									track = fakeHumanoid:LoadAnimation(anims[v10])
									track:Play()
								end
							end)
							coroutine.resume(thread)
						end
					end
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function animateText(p)
				RichText:New(textFrame, p, {
					Font = "SourceSansSemibold"
				}):Animate(false)
			end

			local v9 = {}

			if v6 then
				for k, v10 in pairs(v8.DialoguesTH) do
					v9[k] = v10
				end
			else
				for k, dialogue in pairs(v8.Dialogues) do
					v9[k] = dialogue
				end
			end

			local v10 = nil
			task.spawn(function()
				local count = 0
				local v11 = #v9
				local v12 = nil
				local mouseButton1ClickConnection = nil
				mouseButton1ClickConnection = viewportFrame:WaitForChild("SkipButton").MouseButton1Click:Connect(function()
					if viewportFrame and viewportFrame.Parent then
						if not v12 then
							v12 = true
							viewportFrame.SkipButton.Visible = false
							mouseButton1ClickConnection:Disconnect()
							mouseButton1ClickConnection = nil
						end
					elseif mouseButton1ClickConnection then
						mouseButton1ClickConnection:Disconnect()
						mouseButton1ClickConnection = nil
					end
				end)

				for i = 1, #v9 do
					if not clone.Parent then
						break
					end

					if not v9[i] then
						continue
					end

					local v13 = i
					local thread = coroutine.create(function()
						if v8.Image and viewportFrame and v8.Image[v13] then
							clone.ViewportFrame.IMG.Image = v8.Image[v13]
						end
					end)
					math.min((string.len(v9[i]) or 2.5) / 2.5, 3)
					coroutine.resume(thread)
					animateText(v9[i]) -- equivalent call inferred; original call site unknown
					count += 1
					local v15 = #textFrame:GetChildren() and #textFrame:GetChildren() > 0 and #textFrame:GetChildren() + 1 or 2.5
					local v16 = v12 and 0.05 or v15
					task.wait(v16)
				end

				local v13 = v6 and "คุณได้อ่านหนังสือ " or "You've finished Reading the book of "

				if count > 0 and v11 <= count and not v10 then
					textAlert({
						Text = v13 .. object.Name,
						Color = Color3.new(0, 1, 0.139086)
					}) -- equivalent call inferred; original call site unknown
					v7 = true
				end
			end)
			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Cancel.MouseButton1Click:Connect(function()
				v10 = true
				textAlert({
					Text = (v6 and "คุณได้ปิดหนังสือ " or "You've closed the Book of ") .. object.Name,
					Color = Color3.new(1, 0, 0)
				}) -- equivalent call inferred; original call site unknown
				clone:Destroy()

				if mouseButton1ClickConnection then
					mouseButton1ClickConnection:Disconnect()
					mouseButton1ClickConnection = nil
				end
			end)
			task.spawn(function()
				while clone.Parent do
					wait()

					if not ((humanoidRootPart.Position - object.Position).Magnitude > 10) then
						continue
					end

					if clone and clone.Parent then
						clone:Destroy()
						break
					else
						break
					end
				end
			end)
		end

		if v3.Effect and v3.Actor then
			local actor = v3.Actor

			if v3["Kraken's Wraith"] then
				local tehtacleHand = actor.Parent:FindFirstChild("Tehtacle Hand")
				local v6 = unpack(v3["Kraken's Wraith"]) or ""
				local v7 = {
					grab = chest.Etc.WeaponPassiveEffect.Effect["Kraken's Arm"].Grab,
					slash = chest.Etc.WeaponPassiveEffect.Effect["Kraken's Arm"].Slash
				}
				local v8 = ({
					grab = 103697569336177,
					slash = 71499068964086
				})[v6]
				local v9

				if v8 then
					v9 = getAnimationTrack(actor.Parent.Humanoid, v8) or nil
				end

				if not v9 then
					return
				end

				local connections = {}

				local function Disconnect()
					for _, connection in pairs(connections) do
						connection:Disconnect()
					end

					connections = {}

					if tehtacleHand then
						createHighlight(tehtacleHand, 0.55)
					end
				end

				local clone = v7[v6] and v7[v6]:Clone()

				if clone then
					NoCollision(clone)
					class2:Weld({ clone, actor })
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 3.5)
				end

				table.insert(connections, v9:GetMarkerReachedSignal("Event"):Connect(function(childName)
					if clone and clone:FindFirstChild(childName) then
						v5:Emit(clone[childName])
					end

					if childName == "2" then
						local clone2 = chest.Etc.WeaponPassiveEffect.Effect["Kraken's Arm"].Rock:Clone()
						NoCollision(clone2)
						clone2.Anchored = true
						clone2.CFrame = actor.CFrame * CFrame.new(0, 0, -3.5)
						clone2.Parent = workspace.Effects
						setRay(clone2)
						v5:Emit(clone2)
						_G.PU:Dust(clone2, 3)
					end
				end))
				table.insert(connections, v9.Stopped:Connect(Disconnect))
				table.insert(connections, v9.Ended:Connect(Disconnect))
				return
			elseif v3["Bone Scythe"] then
				local boneScythe = v3["Bone Scythe"]
				local v6 = {}
				local clone = boneScythe.Summon and boneScythe.Summon:Clone()

				if not clone then
					return
				end

				clone:SetPrimaryPartCFrame(actor.CFrame * CFrame.new(0, 0, clone:GetExtentsSize().Z / 5))
				clone.Parent = workspace.Effects
				clone.PrimaryPart.Anchored = true
				_G.PU:Dust(clone, 11)
				local animationController = clone:WaitForChild("AnimationController")
				local animationPlayer = clone:WaitForChild("AnimationPlayer", 3)
				local rootPart = clone:WaitForChild("RootPart")

				if not animationPlayer then
					_G.PU:Dust(clone, 0)
					return
				end

				local module = require(animationPlayer)
				local animator = module

				-- equivalent calls inferred from this helper; original call sites unknown
				local function LoadAnimation(animationId)
					return animator:LoadAnimation(animationController, animationId)
				end

				local function Disconnect()
					for _, connection in pairs(v6) do
						connection:Disconnect()
					end
				end

				local anim = clone.Anim
				local loadAnimation = LoadAnimation(anim.GoDownSea.AnimationId) -- equivalent call inferred; original call site unknown
				local loadAnimation2 = LoadAnimation(anim.GoUpSea.AnimationId) -- equivalent call inferred; original call site unknown
				local loadAnimation3 = LoadAnimation(anim.Idle.AnimationId) -- equivalent call inferred; original call site unknown
				local loadAnimation4 = LoadAnimation(anim.Roar.AnimationId) -- equivalent call inferred; original call site unknown
				loadAnimation3:Play()
				loadAnimation2:Play()
				local modelCFrame = clone and clone:GetModelCFrame() or actor.CFrame
				local clone2 = ReplicatedStorage.Chest.Etc.HydraSB["Fire Roar"]:Clone()
				clone2.CFrame = modelCFrame
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 3)
				clone2.Attachment.base.Rate = 7
				clone2.Attachment.fluid.Rate = 12
				clone2.Attachment.slashes.Rate = 50
				clone2.Attachment.yea.Rate = 15
				local clone3 = ReplicatedStorage.Chest.Etc.HydraSB["Water Roar"]:Clone()
				clone3.CFrame = modelCFrame
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 3)
				clone3.Attachment.base.Rate = 7
				clone3.Attachment.fluid.Rate = 12
				clone3.Attachment.slashes.Rate = 50
				clone3.Attachment.yea.Rate = 15
				local clone4 = ReplicatedStorage.Chest.Etc.HydraSB["Lightning Roar"]:Clone()
				clone4.CFrame = modelCFrame
				clone4.Parent = workspace.Effects
				_G.PU:Dust(clone4, 3)
				clone4.Attachment.base.Rate = 7
				clone4.Attachment.fluid.Rate = 12
				clone4.Attachment.slashes.Rate = 50
				clone4.Attachment.yea.Rate = 15

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					wait(1.25)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				tick()
				v6.Destroyed = clone.Destroying:Connect(Disconnect)
				v6.Step = loadAnimation2.Ended:Connect(function()
					task.spawn(function()
						PeodizService.HeartbeatWait({
							Time = 1
						}, function()
							if rootPart and rootPart.Parent then
								rootPart.CFrame = CFrame.new(
									rootPart.CFrame.Position,
									(Vector3.new(actor.Position.X, rootPart.Position.Y, actor.Position.Z))
								)
							else
								return true
							end
						end)
					end)
					loadAnimation4:Play()
					local clone5 = chest.Etc.WeaponPassiveEffect.Effect["Skull King"].Roar:Clone()
					local weld = class2:Weld({ clone5, clone:FindFirstChild("Teeth") or clone.PrimaryPart })
					clone5.Parent = clone
					weld.C0 *= CFrame.new(0, 0, -8)
					_G.PU:Dust(clone5, 6)
					PeodizService.ForLoop({
						Step = 10,
						WaitTime = 0.2
					}, function()
						if not (clone5 and clone5.Parent and actor and actor.Parent) then
							return true
						end

						local cFrame = actor.CFrame
						local clone6 = chest.Etc.WeaponPassiveEffect.Effect["Skull King"].Magical_Explosion:Clone()
						clone6.Anchored = true
						clone6.CanCollide = false
						clone6.CFrame = cFrame
						setRay(clone6)
						clone6.Parent = workspace.Effects
						v5:Emit(clone6)
						_G.PU:Dust(clone6, 3)
						task.delay(0.25, function()
							local clone7 = chest.Etc.WeaponPassiveEffect.Effect["Skull King"].Explosion:Clone()
							clone7.Anchored = true
							clone7.CanCollide = false
							clone7.CFrame = cFrame
							clone7.Parent = workspace.Effects
							v5:Emit(clone7)
							_G.PU:Dust(clone7, 3)

							if (localPlayer.Character.HumanoidRootPart.Position - actor.CFrame.Position).Magnitude < 90 then
								_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
							end
						end)
						v5:Emit(clone5)
					end)
				end)
				task.spawn(function()
					task.wait(5.2)

					if loadAnimation4.IsPlaying then
						loadAnimation4:Stop()
					end

					loadAnimation:Play()
					loadAnimation.Stopped:Wait(0.1)
					_G.PU:Dust(clone, 0)
				end)
				return
			elseif v3["Abyssal Crab Axe"] then
				if not actor.Parent:WaitForChild("Humanoid", 5) then
					return
				end

				local abyssalCrabAxe = v3["Abyssal Crab Axe"]

				if (abyssalCrabAxe.Stone or "") ~= "Abyss Stone" or not abyssalCrabAxe.Object then
					return
				end

				local object2 = abyssalCrabAxe.Object

				if not (object2 and object2.Parent) then
					return
				end

				local v6 = {}
				local CF = abyssalCrabAxe.CF or object2.CFrame
				local model = abyssalCrabAxe.Model

				if v4 then
					local clone = chest.Etc.WeaponPassiveEffect.Effect.CircleArea:Clone()
					_G.PU:Dust(clone, 10)
					clone.Anchored = true
					clone.CFrame = CF * CFrame.new(0, 25, 0)
					clone.Parent = workspace.Effects
					clone.Transparency = 0.95
					setRay(clone)
					TweenService:Create(
						clone,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
						{
							Size = Vector3.new(),
							Transparency = 1
						}
					):Play()
					CollectionService:AddTag(clone, "Abyssal Crab")
				end

				local clone = chest.Etc.Tentacle.WaterSplash.WaterSplash:Clone()
				clone.CFrame = object2.CFrame
				clone.Anchored = true
				clone.CanCollide = false
				clone.Parent = workspace.Effects
				v5:Emit(clone, 5)
				_G.PU:Dust(clone, 2.5)

				local function Disconnect()
					_G.PU:Dust(model, 0)

					for _, connection in pairs(v6) do
						connection:Disconnect()
					end

					for _, v7 in pairs(CollectionService:GetTagged("Abyssal Crab")) do
						v7:Destroy()
					end
				end

				if not (model and model.Parent ~= nil) then
					return
				end

				model = model:Clone()
				model:PivotTo(CF)
				model.Parent = workspace.Effects
				_G.PU:Dust(model, 15)
				local animationController = model:WaitForChild("AnimationController")
				local AnimationPlayer = require(model.AnimationPlayer)
				local animation = model:WaitForChild("animation")
				local humanoidRootPart = model:WaitForChild("HumanoidRootPart")
				humanoidRootPart.Anchored = true

				-- equivalent calls inferred from this helper; original call sites unknown
				local function LoadAnimation(p)
					if model and model.Parent then
						return AnimationPlayer:LoadAnimation(animationController, p)
					end
				end

				local v7 = {
					Idle = AnimationPlayer:LoadAnimation(animationController, animation.Idle.AnimationId),
					Walking = AnimationPlayer:LoadAnimation(animationController, animation.WalkAnim.AnimationId)
				}
				local v8 = {
					Roar = animation.Roar.AnimationId,
					Slam = animation.Slam.AnimationId
				}
				v7.Idle:Play()
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 11
					}, function()
						if not (humanoidRootPart and humanoidRootPart.Parent) then
							return true
						end

						if actor and actor.Parent then
							humanoidRootPart.CFrame = CFrame.new(
								humanoidRootPart.CFrame.Position,
								(Vector3.new(actor.Position.X, humanoidRootPart.Position.Y, actor.Position.Z))
							)
						else
							return true
						end
					end)
				end)
				v6.CrabDestroy = model.Destroying:Connect(Disconnect)
				v6.CrabAdded = object2.ChildAdded:Connect(function(folder)
					if folder:IsA("Folder") then
						local name = folder.Name

						if v8[name] then
							local loadAnimation = LoadAnimation(v8[name]) -- equivalent call inferred; original call site unknown
							loadAnimation:Play()
						end

						local magnitude = (object2.Position - actor.Position).Magnitude
						local cFrame = CFrame.new(object2.CFrame.Position, actor.CFrame.Position) * CFrame.new(
							0,
							0,
							-magnitude
						)

						if name == "Ended" then
							if object2 and object2.Parent then
								for _, part in pairs(object2.Parent:GetDescendants()) do
									if part:IsA("BasePart") or part:IsA("MeshPart") then
										TweenService:Create(part, tweenInfo, {
											Transparency = 1
										}):Play()
									end
								end

								local clone2 = chest.SwordEffect["Abyssal Crab Axe"].WaterBall:Clone()
								NoCollision(clone2)
								clone2.Anchored = true
								clone2.CFrame = CF * CFrame.new(0, 5, 0)
								clone2.Parent = workspace.Effects
								v5:Emit(clone2)
							end
						elseif name == "Slam" then
							task.spawn(function()
								task.wait(1.25)

								if (localPlayer.Character.HumanoidRootPart.Position - object2.Position).Magnitude < 90 then
									_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
								end

								local clone2 = chest.SwordEffect.SharkBlade.Shockwave:Clone()
								clone2.Anchored = true
								clone2.CanCollide = false
								clone2.CFrame = object2.CFrame * CFrame.new(math.random(-3, 3), 0, 0) * CFrame.Angles(
									0,
									0,
									3.141592653589793
								)
								clone2.Parent = workspace.Effects
								v5:Emit(clone2)
								_G.PU:Dust(clone2, 3)
								local clone3 = chest.SwordEffect["Abyssal Crab Axe"].Impact:Clone()
								NoCollision(clone3)
								clone3.Anchored = true
								clone3.CFrame = object2.CFrame * CFrame.new(0, 5, 0)
								clone3.Parent = workspace.Effects
								v5:Emit(clone3)
								_G.PU:Dust(clone3, 3)
								local clone4 = chest.SwordEffect["Aquatic Anchor"].AnchorSmash2:Clone()
								clone4.Anchored = true
								clone4.CanCollide = false
								clone4.CFrame = object2.CFrame
								clone4.Parent = workspace.Effects
								v5:Emit(clone4)
								_G.PU:Dust(clone4, 1.5)
								local clone5 = chest.Etc.Tentacle.WaterSplash.WaterSplash:Clone()
								clone5.CFrame = CF
								clone5.Anchored = true
								clone5.CanCollide = false
								clone5.Parent = workspace.Effects
								v5:Emit(clone5, 5)
								_G.PU:Dust(clone5, 2.5)
							end)
						elseif name == "Roar" then
							class2:Sound({ 9113987603, object2 })
							local clone2 = chest.Etc.HydraSB["Minion Roar"]:Clone()

							if (localPlayer.Character.HumanoidRootPart.Position - object2.Position).Magnitude < 90 then
								_G.BeckCameraShake(_G.CameraShakerModule.Presets.HydraRoar)
							end

							NoCollision(clone2)
							clone2.CFrame = cFrame
							clone2.Parent = workspace.Effects
							class2:Weld({
								clone2,
								object2.Parent:FindFirstChild("Body") and object2.Parent.Body or object2
							})
							v5:Enabled(clone2)
							task.delay(2.8, function()
								v5:Disabled(clone2)
								_G.PU:Dust(clone2, 0)
							end)
						end
					end
				end)
				v6.Destroy = object2.Destroying:Connect(Disconnect)
				return
			else
				if v3["Shark Blade"] then
					local CF = v3["Shark Blade"].CF
					task.spawn(function()
						PeodizService.ForLoop({
							Step = 3,
							WaitTime = 0.15
						}, function(p)
							local v6 = math.floor(p * 3)
							local cFrame = CF * CFrame.new(0, 0, v6 * -3)
							local clone = chest.SwordEffect.SharkBlade.Shockwave:Clone()
							clone.Anchored = true
							clone.CanCollide = false
							clone.CFrame = cFrame * CFrame.new(math.random(-3, 3), 0, 0) * CFrame.Angles(
								0,
								0,
								3.141592653589793
							)
							clone.Parent = workspace.Effects
							local clone2 = chest.SwordEffect.SharkBlade.FatWomen.Slashes:Clone()
							_G.PU:Dust(clone2, 1)
							clone2.Anchored = true
							clone2.CanCollide = false
							clone2.CFrame = clone.CFrame
							clone2.Parent = workspace.Effects
							v5:Emit(clone2, 5)
							local _ = ReplicatedStorage.Chest.SwordEffect.SharkBlade.FatWomen
							local sound = PeoUtils.CreateSound({
								RollOffMaxDistance = 800,
								RollOffMinDistance = 10,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://15473285614",
								Volume = 5
							})
							_G.PU:Dust(sound, 4)
							sound.Parent = actor
							sound:Play()
							local clone3 = chest.SwordEffect["Aquatic Anchor"].AnchorSmash2:Clone()
							clone3.Anchored = true
							clone3.CanCollide = false
							clone3.CFrame = cFrame
							clone3.Parent = workspace.Effects
							v5:Emit(clone3)
							_G.PU:Dust(clone3, 1.5)

							if (localPlayer.Character.HumanoidRootPart.Position - CF.Position).Magnitude < 90 then
								_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
							end

							TweenService:Create(
								clone,
								TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									Size = clone.Size * 12,
									Transparency = 1
								}
							):Play()
							coroutine.wrap(function()
								PeodizService.HeartbeatWait({
									Time = 1
								}, function()
									if clone and clone.Parent then
										clone.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
									end
								end)
							end)()
							v5:Emit(clone, 1)
							_G.PU:Dust(clone, 1.5)
						end)
					end)
				end

				if v3.Avalon then
					if (v3.Avalon.Stone or "") == "Abyss Stone" then
						task.spawn(function()
							local cFrame = actor.CFrame
							local clone = chest.Etc.WeaponPassiveEffect.Effect.RisingSymbol:Clone()
							NoCollision(clone)
							clone.Anchored = true
							clone.CFrame = cFrame
							clone.Parent = workspace.Effects
							v5:Emit(clone, 5)
							_G.PU:Dust(clone, 1.5)
							PeodizService.ForLoop({
								Step = 4,
								WaitTime = 0.1
							}, function()
								local clone2 = chest.Etc.WeaponPassiveEffect.Riders.RisingSword:Clone()
								clone2:PivotTo(actor.CFrame)
								NoCollision(clone2)
								clone2.PrimaryPart.Anchored = true
								clone2:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame * CFrame.new(
									math.random(-24, 24),
									math.random(12, 24),
									math.random(-12, 12)
								) * CFrame.Angles(-1.5707963267948966, 0, 0))
								clone2:ScaleTo(1)
								clone2.Parent = workspace.Effects
								local clone3 = chest.Etc.LeePung.Smoke:Clone()
								clone3.Anchored = true
								clone3.CanCollide = false
								clone3.CFrame = clone2:GetModelCFrame()
								clone3.Parent = workspace.Effects
								v5:Emit(clone3)
								coroutine.wrap(function()
									PeodizService.ForLoop({
										Step = 5,
										WaitTime = 0.015
									}, function(p)
										clone2:ScaleTo(math.floor(p * 5) * 1)
									end)
									_G.PU:Dust(clone3, 1)
								end)()
								task.spawn(function()
									TweenService:Create(
										clone2.PrimaryPart,
										TweenInfo.new(0.15, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut),
										{
											CFrame = CFrame.lookAt(clone2.PrimaryPart.Position, cFrame.Position)
										}
									):Play()
									task.wait(tweenInfo.Time)
									local cFrame2 = clone2.PrimaryPart.CFrame
									TweenService:Create(
										clone2.PrimaryPart,
										TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
										{
											CFrame = cFrame2 * CFrame.new(0, 0, -55)
										}
									):Play()
									task.delay(0.15, function()
										if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.Position).Magnitude < 90 then
											_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
										end

										for _, part in pairs(clone2:GetDescendants()) do
											if part:IsA("BasePart") then
												TweenService:Create(part, tweenInfo, {
													Transparency = 1
												}):Play()
											end
										end
									end)
									_G.PU:Dust(clone2, tweenInfo.Time + 0.15)
									local clone4 = chest.SwordEffect.Pole.Pole.Z.Burn:Clone()
									clone4.Anchored = true
									clone4.CanCollide = false
									clone4.Size = Vector3.new()
									clone4.CFrame = cFrame
									clone4.Parent = workspace.Effects
									TweenService:Create(
										clone4,
										TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
										{
											Size = createVector(45.462, 0.001, 45.21)
										}
									):Play()
									setRay(clone4)
									local v6 = {
										Color3.new(0.888197, 0.195911, 0.876646),
										Color3.new(0.347997, 0.0769207, 0.343481)
									}
									local clone5 = chest.Etc.WeaponPassiveEffect.Effect.LightningGroundImpact:Clone()
									NoCollision(clone5)
									clone5.CFrame = clone4.CFrame
									clone5.Anchored = true
									clone5.Parent = workspace.Effects
									v5:Emit(clone5, 1, v6[math.random(#v6)])
									_G.PU:Dust(clone5, 3)
									v5:Emit(clone4, 1, Color3.new(0.580392, 0.128008, 0.572686))
									task.delay(0.55, function()
										TweenService:Create(clone4.Decal, tweenInfo, {
											Transparency = 1
										}):Play()
										_G.PU:Dust(clone4, 1)
									end)
								end)
							end)
						end)
					end

					return
				else
					if v3.Pole then
						local pole = v3.Pole
						local stone = pole.Stone or ""
						local CF = pole.CF

						if stone == "Tempestas Stone" then
							task.spawn(function()
								PeodizService.ForLoop({
									Step = 3,
									WaitTime = 0.15
								}, function()
									local clone = chest.SwordEffect.Pole.Pole.Z.Burn:Clone()
									clone.Anchored = true
									clone.CanCollide = false
									clone.CFrame = CF
									clone.Parent = workspace.Effects
									v5:Emit(clone, 1, Color3.new(0.841093, 0.447562, 1))
									_G.PU:Dust(clone, 1.5)
								end)

								if (localPlayer.Character.HumanoidRootPart.Position - CF.Position).Magnitude < 90 then
									_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
								end

								local clone = chest.SwordEffect.Pole.Pole.X.BurnMarks:Clone()
								clone.Anchored = true
								clone.CanCollide = false
								local ray = Ray.new(CF.Position + createVector(0, 50, 0), createVector(0, -100, 0))
								local _, v6 = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Island })
								local v7 = v6 or ray.Origin + ray.Direction
								clone.CFrame = CFrame.new(v7)
								clone.Parent = workspace.Effects
								v5:Emit(clone)
								_G.PU:Dust(clone, 1)
								local clone2 = chest.SwordEffect.Pole.Pole.X.Impact:Clone()
								clone2.Anchored = true
								clone2.CanCollide = false
								clone2.CFrame = CF
								clone2.Parent = workspace.Effects
								v5:Emit(clone2, 1, Color3.new(0.666773, 0.260502, 1))
								_G.PU:Dust(clone2, 1.5)
							end)
							return
						elseif stone == "Gale Stone" then
							local package = pole.Package or {}
							local clone = ReplicatedStorage:FindFirstChild("WeaponaryPassivePole") and ReplicatedStorage.WeaponaryPassivePole:Clone()
							local name = actor.Parent.Name
							local humanoidDescription = actor.Parent:FindFirstChild("Humanoid") and actor.Parent.Humanoid:FindFirstChild("HumanoidDescription") or nil

							if not (package and #package > 0) then
								return
							end

							for _, part in pairs(package) do
								if not (part and part.Parent and part:IsA("BasePart")) then
									continue
								end

								local clone2 = clone:Clone()
								local clone3 = chest.Etc.LeePung.Cache.Actor:Clone()
								clone3:SetPrimaryPartCFrame(part.CFrame)
								clone3.PrimaryPart.Anchored = false
								class2:Weld({ clone3.PrimaryPart, part })
								local fakeHumanoid = clone3:WaitForChild("FakeHumanoid")
								local motor6D = Instance.new("Motor6D")
								local part3

								if clone2:FindFirstChild("MainMotor6D") then
									part3 = clone2.MainMotor6D or nil
								end

								motor6D.Part1 = part3
								motor6D.Name = "Real Sword_6D"

								if clone2.MainMotor6D:FindFirstChild("RightHand") then
									motor6D.Part0 = clone3.RightHand
									motor6D.Parent = clone3.RightHand
								end

								for _, part2 in pairs(clone2:GetDescendants()) do
									if not (part2:IsA("MeshPart") or part2:IsA("BasePart")) then
										continue
									end

									part2.Transparency = part2:IsA("MeshPart") and 0 or 1
									part2.CollisionGroup = "p"
								end

								clone2.Parent = clone3
								clone2:SetPrimaryPartCFrame(clone3.PrimaryPart.CFrame)

								for _, part2 in pairs(clone3:GetDescendants()) do
									if not (part2:IsA("MeshPart") or part2:IsA("BasePart")) then
										continue
									end

									part2.Transparency = part2:IsA("MeshPart") and 0 or 1
									part2.CanCollide = false
									part2.Anchored = false
									part2.Massless = true
									part2.CollisionGroup = "p"
								end

								clone3.Parent = part
								_G.PU.PlayOneShotAnim({
									Animator = fakeHumanoid,
									Animation = ReplicatedStorage.Chest.Animation.CustomWeaponAnims.SpearStyle.RunAnim
								})

								if humanoidDescription and clone3.Parent ~= nil then
									fakeHumanoid:ApplyDescription(humanoidDescription)
									Chat:Chat(clone3.Head, (`Let's GO {name} !`))
								end

								if clone3 and clone3.Parent ~= nil then
									for _, part2 in pairs(clone3:GetDescendants()) do
										if not (part2:IsA("MeshPart") or part2:IsA("BasePart")) then
											continue
										end

										part2.CollisionGroup = "p"
										part2.CanCollide = false
										part2.Massless = true
									end
								end

								local clone4 = chest.Etc.LeePung.Smoke:Clone()
								clone4.Anchored = true
								clone4.CanCollide = false
								clone4.CFrame = part.CFrame
								clone4.Parent = workspace.Effects
								local v7 = part
								local childAddedConnection = part.ChildAdded:Connect(function(child)
									if child.Name == "Attack" and v7 and v7.Parent ~= nil then
										local v9 = "AT" .. math.random(1, 4)
										local child2 = ReplicatedStorage.Chest.Animation.Pole:FindFirstChild(v9)

										if child2 then
											_G.PU.PlayOneShotAnim({
												Animator = fakeHumanoid,
												Animation = child2
											})
										end

										local v10 = {
											CFrame.Angles(0, 0, -0.22689280275926285),
											CFrame.Angles(0, 0, -0.6108652381980153),
											CFrame.Angles(0, 0, -0.6283185307179586),
											(CFrame.Angles(0, 0, 0))
										}
										local clone5 = ReplicatedStorage.Chest.SwordEffect.SlashAni:Clone()
										clone5.Massless = true
										clone5.Anchored = true
										clone5.Top.Color3 = Color3.fromRGB(255, 251, 0)
										clone5.Mesh.Scale = createVector(8, 0.5, 8)
										clone5.CFrame = v7.CFrame * v10[math.random(#v10)]
										clone5.Parent = workspace.Effects
										_G.PU:Dust(clone5, 1)
										local Animate = require(clone5.Animate)
										Animate()
									end
								end)
								v5:Emit(clone4)
								_G.PU:Dust(clone4, 1.5)
								local clone5 = chest.Etc.LeePung["Wind Aura"]:Clone()
								class2:Weld({ clone5, part })
								clone5.Parent = part
								local v9 = part
								local connection = childAddedConnection
								part.Destroying:Connect(function()
									local cFrame = v9 and v9.CFrame or nil

									if connection then
										connection:Disconnect()
									end

									if cFrame then
										if (localPlayer.Character.HumanoidRootPart.Position - cFrame.Position).Magnitude < 35 then
											_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
										end

										local clone6 = chest.SwordEffect.Pole.Pole.Z.Impact:Clone()
										clone6.Anchored = true
										clone6.CanCollide = false
										clone6.CFrame = cFrame
										clone6.Parent = workspace.Effects
										setRay(clone6)
										v5:Emit(clone6, 1, Color3.new(0.545037, 0.976806, 0.545037))
										_G.PU:Dust(clone6, 1.5)
										local clone7 = chest.Etc.LeePung.Smoke:Clone()
										clone7.Anchored = true
										clone7.CanCollide = false
										clone7.CFrame = cFrame
										clone7.Parent = workspace.Effects
										v5:Emit(clone7)
										_G.PU:Dust(clone7, 1.5)
									end
								end)
							end

							if clone then
								clone:Destroy()
							end

							return
						end
					end

					if v3["Tashi Blade"] and v3["Tashi Blade"].Normal then
						task.spawn(function()
							local cFrame = cFrame3
							PeodizService.ForLoop({
								Step = 4,
								WaitTime = 0.1
							}, function(p)
								local v7 = math.floor(p * 6)
								local v8 = { "Slash", "Slashes" }
								local v9 = v8[math.random(#v8)]
								local child = chest.SwordEffect.TashiBlade.TashigiSkill1:FindFirstChild(v9)

								if child then
									local clone = child:Clone()
									clone.Anchored = true
									clone.CanCollide = false
									clone.CFrame = cFrame
									clone.Parent = workspace.Effects
									v5:Emit(clone)
									local pointLight = Instance.new("PointLight")
									pointLight.Brightness = 1
									pointLight.Range = 15
									pointLight.Color = Color3.new(0.296422, 0.787304, 1)
									pointLight.Parent = clone
									TweenService:Create(pointLight, tweenInfo, {
										Brightness = 0
									}):Play()
									local ray = Ray.new(cFrame.Position, createVector(0, -100, 0))
									local _, v10 = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Island })
									local clone2 = chest.SwordEffect.TashiBlade.TashiRings:Clone()
									clone2.Anchored = true
									clone2.CanCollide = false
									clone2.CFrame = v10 and CFrame.new(v10 + Vector3.new(0, clone2.Size.Y / 2, 0)) or cFrame
									clone2.Parent = workspace.Effects
									TweenService:Create(clone2, tweenInfo, {
										Size = clone2.Size * v7,
										Transparency = 1
									}):Play()
									_G.PU:Dust(clone2, 1)
									_G.PU:Dust(clone, 1)

									if (localPlayer.Character.HumanoidRootPart.Position - cFrame.Position).Magnitude < 55 then
										_G.BeckCameraShake(_G.CameraShakerModule.Presets.SwordHit)
									end
								end
							end)
						end)
					end

					if v3.PumpkinV then
						task.spawn(function()
							PeodizService.ForLoop({
								Step = 10,
								WaitTime = 0.15
							}, function(_)
								if not (actor and actor.Parent) then
									return true
								end

								local sound = PeoUtils.CreateSound({
									RollOffMaxDistance = 500,
									RollOffMinDistance = 0,
									RollOffMode = Enum.RollOffMode.Linear,
									SoundId = "rbxassetid://15157090209",
									PlaybackSpeed = 2,
									Volume = 0.5
								})
								_G.PU:Dust(sound, 3)
								sound.Parent = actor
								sound:Play()
								local sound2 = PeoUtils.CreateSound({
									RollOffMaxDistance = 500,
									RollOffMinDistance = 0,
									RollOffMode = Enum.RollOffMode.Linear,
									SoundId = "rbxassetid://15157091026",
									PlaybackSpeed = 2,
									Volume = 0.5
								})
								_G.PU:Dust(sound2, 3)
								sound2.Parent = actor
								sound2:Play()
								local clone = chest.Etc.MisterPumpkin.Slash:Clone()
								clone.Anchored = true
								clone.CanCollide = false
								clone.CFrame = actor.CFrame * CFrame.new(0, 0, math.random(-3, 3)) * CFrame.Angles(
									math.rad((math.random(-25, 25))),
									0,
									(math.rad((math.random(-25, 25))))
								)
								clone.Parent = workspace.Effects
								local clone2 = chest.Etc.MisterPumpkin.Skull:Clone()
								clone2.Anchored = true
								clone2.CanCollide = false
								clone2.CFrame = actor.CFrame * CFrame.new(0, 0, math.random(-3, 3)) * CFrame.Angles(
									math.rad((math.random(-25, 25))),
									0,
									(math.rad((math.random(-25, 25))))
								)
								clone2.Parent = workspace.Effects
								local pointLight = Instance.new("PointLight")
								pointLight.Brightness = 1
								pointLight.Range = 15
								pointLight.Color = Color3.new(1, 0.226169, 0)
								pointLight.Parent = clone
								TweenService:Create(pointLight, tweenInfo, {
									Brightness = 0
								}):Play()
								v5:Emit(clone2)
								v5:Emit(clone)
								_G.PU:Dust(clone, 1)
								_G.PU:Dust(clone2, 0.45)
							end)
						end)
					end

					if v3.TentacleForm then
						if v3.Warp then
							task.spawn(function()
								task.wait(0.35)
								local startCF = v3.StartCF or actor.CFrame
								task.spawn(function()
									for i = 1, 3 do
										local halfI = i / 2

										for i2 = 1, 20 do
											local cframe = CFrame.new(startCF.Position) * CFrame.Angles(
												0,
												6.283185307179586 * i2 / 20,
												0
											) * CFrame.new(0, 0, halfI * -50)
											local ray = Ray.new(cframe.p, createVector(0, -25, 0))
											local _, v7, _ = cframe:ToOrientation()
											local raycastParams = RaycastParams.new()
											raycastParams.FilterDescendantsInstances = { workspace.Island }
											raycastParams.FilterType = Enum.RaycastFilterType.Include
											local raycastResult = workspace:Raycast(
												ray.Origin,
												ray.Direction,
												raycastParams
											)
											local instance

											if raycastResult then
												instance = raycastResult.Instance or nil
											end

											local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
											local _ = raycastResult and raycastResult.Normal
											local material = raycastResult and raycastResult.Material or nil

											if not instance then
												continue
											end

											local part = Instance.new("Part")
											part.CastShadow = false
											part.Anchored = true
											part.CanCollide = false
											part.CFrame = CFrame.new(startCF.Position) * CFrame.fromOrientation(
												0,
												v7,
												0
											)
											part.Size = createVector(0, 0, 0)
											part.Parent = workspace.Effects
											TweenService:Create(
												part,
												TweenInfo.new(
													0.1,
													Enum.EasingStyle.Exponential,
													Enum.EasingDirection.Out
												),
												{
													CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v7, 0) * CFrame.new(
														0,
														math.random(-20, 1) / 10,
														0
													) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
													Size = createVector(17.25, 10, 10) * halfI
												}
											):Play()
											TweenService:Create(
												part,
												TweenInfo.new(
													0.5,
													Enum.EasingStyle.Linear,
													Enum.EasingDirection.Out,
													0,
													false,
													1
												),
												{
													Transparency = 1
												}
											):Play()
											part.Material = material or "SmoothPlastic"
											part.BrickColor = instance.BrickColor
											_G.PU:Dust(part, 2)
										end

										wait(0.25)
									end
								end)
								local clone = chest.Etc.Tentacle.WaterSplash.WaterSplash:Clone()
								clone.CFrame = startCF
								clone.Anchored = true
								clone.CanCollide = false
								clone.Parent = workspace.Effects
								v5:Emit(clone, 5)
								_G.PU:Dust(clone, 2.5)
								local clone2 = chest.Etc.Crab.charge:Clone()
								clone2.Anchored = true
								clone2.CFrame = startCF
								clone2.Parent = workspace.Effects
								v5:Emit(clone2)
								_G.PU:Dust(clone2, 3)
								local clone3 = chest.Etc.Crab.Crack:Clone()
								clone3.Anchored = true
								clone3.CFrame = startCF
								clone3.Parent = workspace.Effects
								v5:Emit(clone3)
								_G.PU:Dust(clone3, 3)

								if (localPlayer.Character.HumanoidRootPart.Position - cFrame3.p).Magnitude < 220 then
									_G.BeckCameraShake(_G.CameraShakerModule.Presets.Gura2)
									local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
									colorCorrectionEffect.Brightness = -5
									colorCorrectionEffect.Contrast = 5
									colorCorrectionEffect.Saturation = -5
									colorCorrectionEffect.TintColor = Color3.fromRGB(8, 255, 253)
									local clone4 = colorCorrectionEffect:Clone()
									clone4.Brightness = 5
									colorCorrectionEffect.Parent = workspace.CurrentCamera
									task.wait(0.04)
									colorCorrectionEffect:Destroy()
									clone4.Parent = workspace.CurrentCamera
									task.wait(0.04)
									clone4:Destroy()
									Utility.ImpactFrame({ actor.Parent, workspace.Effects }, 0.08)
								end
							end)
							return
						end

						if v3.MindControl then
							local model = v3.Model or ReplicatedStorage:FindFirstChild("KrakenFX_Replicated") or nil
							local startCF = v3.StartCF
							local v6 = CFrame.new(startCF * CFrame.new(0, 6.869500160217285, 0).Position) * CFrame.Angles(
								0,
								0,
								0
							)
							local clone = model and model:Clone() or nil
							local clone2 = ReplicatedStorage.Chest.SwordEffect.Noirceur.explode:Clone()
							clone2.Parent = workspace.Effects
							clone2.CFrame = v6 * CFrame.Angles(0, 0, 1.5707963267948966)
							v5:Emit(clone2)
							_G.PU:Dust(clone2, 3.5)
							task.delay(tweenInfo.Time, function()
								PeodizService.ForLoop({
									Step = 8
								}, function(_)
									local clone3 = clone and clone:Clone() or nil
									task.spawn(function()
										task.wait(0.35 + math.random(4) * 0.1)

										if clone3 then
											_G.PU:Dust(clone3, 10)

											for _, part in pairs(clone3:GetDescendants()) do
												if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
													continue
												end

												part.CanCollide = false
												part.Massless = true
												part.CollisionGroup = "p"
											end

											local humanoidRootPart = clone3:WaitForChild("HumanoidRootPart")
											clone3:ScaleTo(0.55)
											clone3:PivotTo(v6 * CFrame.new(
												math.random(-24, 24),
												-2,
												math.random(-24, 24)
											) * CFrame.Angles(0, math.random(0, 120), 0))
											clone3.Parent = workspace.Effects
											local anims = clone3:WaitForChild("Anims")
											local animationController = clone3:WaitForChild("AnimationController")
											local v7 = "Spawn" .. math.random(1, 2)
											local v8 = "Idle" .. math.random(1, 4)
											local track

											if anims:FindFirstChild(v8) then
												track = animationController:LoadAnimation(anims[v8]) or nil
											else
												track = nil
											end

											local track2

											if anims:FindFirstChild(v7) then
												track2 = animationController:LoadAnimation(anims[v7]) or nil
											else
												track2 = nil
											end

											local track3 = animationController:LoadAnimation(anims.Smash)

											if track2 and track then
												track2:Play()
												local clone4 = chest.Etc.LeePung.Smoke:Clone()
												clone4.Anchored = true
												clone4.CanCollide = false
												clone4.CFrame = humanoidRootPart.CFrame
												clone4.Parent = workspace.Effects
												v5:Emit(clone4, 1, Color3.new(0.208072, 0.0499886, 0.205447))
												_G.PU:Dust(clone4, 2)
												local clone5 = chest.Etc.WeaponPassiveEffect.Effect.LightningImpact:Clone()
												NoCollision(clone5)
												clone5.CFrame = humanoidRootPart.CFrame
												clone5.Anchored = true
												clone5.Parent = workspace.Effects
												v5:Emit(clone5, 1, Color3.new(0.385809, 0.0852674, 0.380804))
												_G.PU:Dust(clone5, 3)
												task.spawn(function()
													track2.Stopped:Wait()
													track:Play()
													tick()
													track3:Play()
													task.delay(0.55, function()
														local clone6 = chest.SwordEffect.Noirceur.slash:Clone()
														NoCollision(clone6)
														_G.PU:Dust(clone6, 3)
														clone6.Anchored = true
														clone6.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
															0,
															1.5707963267948966,
															0
														)
														clone6.Parent = workspace.Effects
														local sound = PeoUtils.CreateSound({
															RollOffMaxDistance = 1000,
															RollOffMinDistance = 10,
															RollOffMode = Enum.RollOffMode.InverseTapered,
															SoundId = "rbxassetid://8595976174",
															Volume = 1,
															PlaybackSpeed = 1.35
														})
														_G.PU:Dust(sound, 3)
														sound.Parent = clone6
														sound:Play()
														v5:Emit(clone6, Color3.new(0.500008, 0.110506, 0.493507))

														if (localPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude < 30 then
															_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
														end

														task.wait(0.15)

														for _, part in pairs(clone3:GetDescendants()) do
															if part:IsA("BasePart") then
																TweenService:Create(part, tweenInfo, {
																	Transparency = 1
																}):Play()
															end
														end
													end)
													_G.PU:Dust(clone3, 3)
												end)
											end
										end
									end)
								end)
								clone:Destroy()
							end)
							return
						elseif v3.Summon then
							if lastTime and tick() - lastTime >= 60 then
								lastTime = nil
							end

							if not (lastTime or v3.Deform) then
								lastTime = tick()
								local TextChatService = game:GetService("TextChatService")
								TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
									Text = "The mysterious Kraken uses an adventurer to become a massive, dangerous conduit!",
									Font = "SpecialElite",
									Color = Color3.fromRGB(255, 0, 0),
									FontSize = 18
								}))
							end

							if not v3.Deform then
								class2:Sound({ 6001756334, workspace.Effects })
							end

							local startCF = v3.StartCF or actor.CFrame
							local clone = ReplicatedStorage.Chest.Etc.HydraSB["Fire Roar"]:Clone()
							clone.CFrame = startCF
							clone.Parent = workspace.Effects
							_G.PU:Dust(clone, 3)
							clone.Attachment.base.Rate = 7
							clone.Attachment.fluid.Rate = 12
							clone.Attachment.slashes.Rate = 50
							clone.Attachment.yea.Rate = 15
							local clone2 = ReplicatedStorage.Chest.Etc.HydraSB["Water Roar"]:Clone()
							clone2.CFrame = startCF
							clone2.Parent = workspace.Effects
							_G.PU:Dust(clone2, 3)
							clone2.Attachment.base.Rate = 7
							clone2.Attachment.fluid.Rate = 12
							clone2.Attachment.slashes.Rate = 50
							clone2.Attachment.yea.Rate = 15
							local clone3 = ReplicatedStorage.Chest.Etc.HydraSB["Lightning Roar"]:Clone()
							clone3.CFrame = startCF
							clone3.Parent = workspace.Effects
							_G.PU:Dust(clone3, 3)
							clone3.Attachment.base.Rate = 7
							clone3.Attachment.fluid.Rate = 12
							clone3.Attachment.slashes.Rate = 50
							clone3.Attachment.yea.Rate = 15

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.spawn(function()
								wait(1.25)

								for _, emitter in pairs(clone:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end

								for _, emitter in pairs(clone2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end

								for _, emitter in pairs(clone3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)

							if v4 then
								PeodizService.ForceForLoop({
									Step = 4,
									WaitTime = 0.1
								}, function()
									_G.BeckCameraShake(_G.CameraShakerModule.Presets.HydraRoar)
									local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
									colorCorrectionEffect.Parent = game.Lighting
									colorCorrectionEffect.Name = "Fullmoon"
									TweenService:Create(
										colorCorrectionEffect,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											TintColor = Color3.fromRGB(0, 11, 213),
											Brightness = -0.1,
											Contrast = -0.1
										}
									):Play()
									task.delay(0.35, function()
										TweenService:Create(
											colorCorrectionEffect,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												TintColor = Color3.fromRGB(255, 255, 255),
												Brightness = 0,
												Contrast = 0
											}
										):Play()
										_G.PU:Dust(colorCorrectionEffect, 0.55)
									end)
								end)
							end

							return
						else
							if not v3.Hit then
								return
							end

							local clone = chest.Etc.Tentacle.WaterSplash.WaterSplash:Clone()
							clone.CFrame = cFrame3
							clone.Anchored = true
							clone.CanCollide = false
							clone.Parent = workspace.Effects
							v5:Emit(clone, 5)
							_G.PU:Dust(clone, 2.5)
							task.spawn(function()
								PeodizService.ForceForLoop({
									Step = 15
								}, function()
									local v6 = {
										createVector(1.259, 1, 1.237),
										createVector(54.636, 43.411, 53.712),
										createVector(18.712, 14.867, 18.395)
									}
									local part = Instance.new("Part")
									part.Anchored = false
									part.CastShadow = false
									part.CanCollide = false
									part.Massless = true
									part.Size = v6[math.random(#v6)]
									part.Material = Enum.Material.Slate
									part.CollisionGroup = "p"
									part.CFrame = cFrame3 * CFrame.new(math.random(-12, 12), 12, math.random(-12, 12)) * CFrame.Angles(
										math.random(0, 360),
										math.random(0, 360),
										math.random(0, 360)
									)
									part.Parent = workspace.Effects
									part.Velocity = part.CFrame.UpVector * 250 + randomDirection() * 555
									task.delay(tweenInfo.Time + 0.5, function()
										TweenService:Create(
											part,
											TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
											{
												Size = Vector3.new(),
												Transparency = 1
											}
										):Play()
										_G.PU:Dust(part, 2)
									end)
								end)
							end)
							task.spawn(function()
								PeodizService.ForceForLoop({
									Step = 6,
									WaitTime = 0.11
								}, function(p)
									local v6 = math.floor(p * 6)
									local v7 = cFrame3 * CFrame.new(0, 0, v6 * -15) * CFrame.new(
										math.random(-50, 50),
										0,
										math.random(-10, 10)
									)
									PeodizService.ForLoop({
										Step = 6
									}, function(_)
										local v8 = v7 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
											0,
											0,
											math.random(15, 30)
										)
										local raycastParams = RaycastParams.new()
										raycastParams.FilterType = Enum.RaycastFilterType.Exclude
										raycastParams.FilterDescendantsInstances = { workspace.Effects, actor.Parent }
										local raycastResult = workspace:Raycast(
											v7.Position,
											createVector(0, -25, 0),
											raycastParams
										)

										if raycastResult and raycastResult.Instance and raycastResult.Position then
											local part = Instance.new("Part")
											_G.PU:Dust(part, 3)
											part.Name = "Rock"
											part.Anchored = false
											part.CanCollide = false
											part.Massless = false
											part.Size = Vector3.new(
												math.random(2, 15),
												math.random(5, 15),
												math.random(1, 20) * 2
											) * 0.6

											if math.random(1, 2) == 1 then
												part.Size = Vector3.new(
													math.random(2, 10),
													math.random(2, 10),
													math.random(2, 10)
												) * 0.7
											end

											part.Size *= 0.66
											part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
												math.rad((math.random(-360, 360))),
												math.rad((math.random(-360, 360))),
												(math.rad((math.random(-360, 360))))
											)
											part.Material = raycastResult.Material
											part.Color = raycastResult.Instance.Color
											part.Parent = workspace.Effects
											local attachment = Instance.new("Attachment")
											attachment.Parent = part
											local alignPosition = Instance.new("AlignPosition")
											_G.PU:Dust(alignPosition, 0.25)
											alignPosition.ApplyAtCenterOfMass = false
											alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
											alignPosition.Attachment0 = attachment
											alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
											alignPosition.MaxAxesForce = createVector(3000000, 3000000, 3000000)
											alignPosition.Responsiveness = 40
											alignPosition.Position = v8.p + v8.UpVector * math.random(15, 70) + v7.RightVector * math.random(
												-40,
												40
											)
											alignPosition.Parent = part
											local alignOrientation = Instance.new("AlignOrientation")
											alignOrientation.CFrame = part.CFrame * CFrame.Angles(
												math.rad((math.random(-360, 360))),
												math.rad((math.random(-360, 360))),
												(math.rad((math.random(-360, 360))))
											)
											alignOrientation.Responsiveness = 10
											alignOrientation.Enabled = true
											alignOrientation.MaxTorque = 5000000
											alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
											alignOrientation.Attachment0 = attachment
											alignOrientation.Parent = part
											task.delay(0.2, function()
												task.wait(0.25)
												TweenService:Create(
													part,
													TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
													{
														Size = Vector3.new()
													}
												):Play()
												task.wait(1)
												part:Destroy()
											end)
										end
									end)
								end)
							end)

							if (localPlayer.Character.HumanoidRootPart.Position - cFrame3.p).Magnitude < 220 then
								_G.BeckCameraShake(_G.CameraShakerModule.Presets.Gura2)
							end

							return
						end
					else
						if v3.DiamondSlash then
							local v6 = math.random(50, 75) / 2
							local clone = chest.Etc.LeePung.SlashAni:Clone()
							clone.Mesh.Scale = Vector3.new(v6, 1, v6)
							clone.CFrame = actor.CFrame * CFrame.Angles(
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random()
							) * CFrame.new(0, 0, math.random(1, 20))
							clone.Parent = workspace.Effects
							_G.PU:Dust(clone, 1)
							local v7 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://6805419548",
								Volume = 0.25
							}
							local sound = PeoUtils.CreateSound(v7)
							_G.PU:Dust(sound, 0.5)
							sound.Parent = clone
							sound:Play()
							clone.swirldot:Emit(clone.swirldot:GetAttribute("EmitCount"))
							clone.swirldot2:Emit(clone.swirldot2:GetAttribute("EmitCount"))
							local Animate = require(clone.Animate)
							Animate()
						end

						if v3.SpawnPumpkin and v3.StartCF then
							local startCF = v3.StartCF
							task.spawn(function()
								local clone = chest.SwordEffect.PumpkinSmasher.particles:Clone()
								clone.CFrame = startCF
								clone.Parent = workspace.Effects
								clone.Attachment.bat:Emit(2)
								clone.Attachment.dark:Emit(15)
								clone.Attachment.spark:Emit(10)
								clone.Attachment.big:Emit(1)
								_G.PU:Dust(clone, 6)
								local v6 = {
									RollOffMaxDistance = 500,
									RollOffMinDistance = 0,
									RollOffMode = Enum.RollOffMode.Linear,
									SoundId = "rbxassetid://15157088909",
									Volume = 1
								}
								local sound = PeoUtils.CreateSound(v6)
								_G.PU:Dust(sound, 6)
								sound.Parent = clone
								sound:Play()
								local clone2 = chest.Etc.MisterPumpkin.PumpkinHead:Clone()
								clone2.Material = Enum.Material.Neon
								clone2.CanCollide = false
								clone2.Anchored = true
								clone2.CFrame = startCF
								clone2.Parent = workspace.Effects
								clone2.Size *= 10
								clone2.CFrame += Vector3.new(0, clone2.Size.Y / 3, 0)
								TweenService:Create(
									clone2,
									TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.In),
									{
										Size = Vector3.new(),
										Transparency = 1
									}
								):Play()
								_G.PU:Dust(clone2, 1)
								local ball = class2:Ball()
								ball.CFrame = cFrame3
								ball.Size = createVector(45, 45, 45)
								ball.Parent = workspace.Effects
								ball.Color = Color3.new(1, 0.624872, 0.0764477)
								TweenService:Create(ball, tweenInfo, {
									Transparency = 1,
									Size = Vector3.new()
								}):Play()
								_G.PU:Dust(ball, 1)
							end)
							task.spawn(function()
								PeodizService.ForLoop({
									Step = 15,
									WaitTime = 0.01
								}, function()
									local ball = class2:Ball()
									ball.CFrame = cFrame3
									ball.Size = createVector(5, 5, 5)
									ball.Parent = workspace.Effects
									ball.Color = Color3.new(1, 0.624872, 0.0764477)
									TweenService:Create(ball, tweenInfo, {
										CFrame = ball.CFrame * CFrame.new(
											math.random(-15, 15),
											math.random(-15, 15),
											math.random(-15, 15)
										),
										Transparency = 1,
										Size = Vector3.new()
									}):Play()
									_G.PU:Dust(ball, 1)
								end)
							end)
							task.spawn(function()
								local clone = chest.Etc.PumpkinImpact:Clone()
								clone.CFrame = CFrame.new(startCF.p)
								clone.Parent = workspace.Effects
								_G.PU:Dust(clone, 3)
								task.spawn(function()
									for _, emitter in pairs(clone:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end
								end)

								if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
									_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
								end

								local clone2 = chest.MeleeEffect.Cyborg.Thing:Clone()
								clone2.Color = Color3.fromRGB(255, 85, 0)
								clone2.CastShadow = false
								clone2.Transparency = -1
								clone2.Anchored = true
								clone2.CanCollide = false
								clone2.Size = createVector(50, 50, 50)
								clone2.CFrame = CFrame.new(startCF.p)
								clone2.Parent = workspace.Effects
								_G.PU:Dust(clone2, 0.15)
								TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
									Size = createVector(0, 75, 0),
									CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
								}):Play()
							end)
							task.spawn(function()
								PeodizService.ForLoop({
									Step = 14,
									WaitTime = 0
								}, function(p)
									local v6 = math.floor(p * 14)
									local cframe = CFrame.new(startCF.p) * CFrame.Angles(
										0,
										6.283185307179586 * v6 / 14,
										0
									) * CFrame.new(0, 0, -10)
									Ray.new(cframe.p, createVector(0, -5, 0))
									local _, v7, _ = cframe:ToOrientation()
									local raycastParams = RaycastParams.new()
									raycastParams.FilterType = Enum.RaycastFilterType.Include
									raycastParams.FilterDescendantsInstances = { workspace.Island }
									local raycastResult = workspace:Raycast(
										cframe.p,
										createVector(0, -5, 0),
										raycastParams
									)
									local position = cframe.p + createVector(0, -5, 0)
									local instance, material

									if raycastResult then
										position = raycastResult.Position
										instance = raycastResult.Instance
										local _ = raycastResult.Normal
										material = instance.Material
									end

									if instance then
										local part = Instance.new("Part")
										part.Anchored = true
										part.CanCollide = false
										part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v7, 0)
										part.Size = createVector(0, 0, 0)
										part.Parent = workspace.Effects
										TweenService:Create(
											part,
											TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
											{
												CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v7, 0) * CFrame.new(
													0,
													math.random(-10, 1) / 20,
													0
												) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
												Size = createVector(4.8, 2, 2)
											}
										):Play()
										TweenService:Create(
											part,
											TweenInfo.new(
												0.5,
												Enum.EasingStyle.Linear,
												Enum.EasingDirection.Out,
												0,
												false,
												1
											),
											{
												Transparency = 1
											}
										):Play()
										part.Material = material or "SmoothPlastic"
										part.BrickColor = instance.BrickColor
										_G.PU:Dust(part, 2)
									end
								end)
							end)
						end

						if v3.PumpkinModel then
							local pumpkinModel = v3.PumpkinModel
							local clone = chest.Etc.MisterPumpkin.Pumpkin:Clone()
							clone:SetPrimaryPartCFrame(pumpkinModel.CFrame)

							for _, part in pairs(clone:GetDescendants()) do
								if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
									continue
								end

								part.Massless = true
								part.CollisionGroup = "Decoy"
							end

							clone.Parent = pumpkinModel
							clone.AnimationController:LoadAnimation(chest.Animation["Pumpkin Smasher"].Z1):Play()
							class2:Weld({ clone.PrimaryPart, pumpkinModel })
						end
					end
				end
			end
		end

		if questType == "Hide'n Seek!" then
			class:RequestQuest("Hide'n Seek!")
			local smoke = Instance.new("Smoke")
			smoke.Parent = object
			_G.PU:Dust(smoke, 1.5)
			local v6 = {}
			task.delay(0.1, function()
				PeodizService.ForLoop({
					Step = 4
				}, function()
					local part = Instance.new("Part")
					part.Size = createVector(1, 1, 1)
					part.CFrame = object.CFrame * CFrame.new(0, 6, 0)
					part.Material = Enum.Material.Grass
					part.Parent = workspace.Effects
					part.CollisionGroup = "p"
					part.Color = Color3.fromRGB(0, 140, 0)
					part.Velocity = randomDirection() * 60
					table.insert(v6, part)
				end)
				task.wait(1)

				for _, v7 in pairs(v6) do
					if not v7 then
						continue
					end

					TweenService:Create(v7, tweenInfo, {
						Size = Vector3.new(),
						Transparency = 1
					}):Play()
					_G.PU:Dust(v7, 1)
				end

				table.clear(v6)
			end)
			local clone = textShow_:Clone()
			clone.Parent = object
			clone.TextLabel.Font = Enum.Font.Cartoon
			clone.TextLabel.Text = "YOU FOUND ME?!!"
			clone.Enabled = true
			TweenService:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
				StudsOffset = createVector(0, 4, 0)
			}):Play()
			_G.PU:Dust(clone, 1.5)
		end

		if questType == "Ring Ring Ring" then
			class2:Sound({ 1034263055, object })
			local clone = textShow_:Clone()
			clone.Parent = object
			clone.TextLabel.Font = Enum.Font.Cartoon
			clone.TextLabel.Text = "*Ding!!"
			clone.Enabled = true
			TweenService:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
				StudsOffset = createVector(0, 4, 0)
			}):Play()
			_G.PU:Dust(clone, 1.5)
		end

		if questType == "Mossy Must Gone" and object then
			local max = v3.Max
			local mossy = object:FindFirstChild("Base") and object.Base and object.Base:FindFirstChild("Mossy")

			if mossy then
				local clone = textShow_:Clone()
				clone.Parent = object
				clone.TextLabel.Font = Enum.Font.Cartoon
				clone.TextLabel.Text = "*Puff!!"
				clone.Enabled = true
				TweenService:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					StudsOffset = createVector(0, 4, 0)
				}):Play()
				_G.PU:Dust(clone, 1.5)
				local clone2 = mossy:Clone()
				clone2.Parent = workspace.Effects
				mossy.Transparency = 1

				if max then
					pcall(function()
						task.spawn(function()
							task.wait(0.55)
							TweenService:Create(mossy, tweenInfo, {
								Transparency = 0
							}):Play()
						end)
					end)
				end

				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					CFrame = clone2.CFrame * CFrame.new(0, -3, 0),
					Size = Vector3.new()
				}):Play()
				_G.PU:Dust(clone2, 1)

				if not max and object:FindFirstChild("PromptQuest") then
					object.PromptQuest.Enabled = false
				end
			end
		end

		if questType == "Puzzle Mania" then
			local reset = v3.Reset
			local interact = v3.Interact
			local hint = v3.Hint

			if not interact then
				if reset then
					for _, descendant in pairs(workspace.SpawnItem.Puzzle_Easy:GetDescendants()) do
						if descendant:IsA("ProximityPrompt") then
							descendant.Enabled = true
						elseif descendant:IsA("BillboardGui") then
							descendant.Enabled = true
						elseif descendant:IsA("MeshPart") then
							if descendant.Name == "Puzzle" then
								descendant.Transparency = 1
							else
								if descendant.Parent:FindFirstChild("Art") and descendant.Parent.Art:IsA("BasePart") then
									descendant.Parent.Art.Transparency = 1
								end

								if descendant.Parent.Name == "Puzzle" or descendant.Parent.Parent.Name == "Puzzle" then
									descendant.Transparency = 1
								else
									descendant.Transparency = 0
								end
							end
						end
					end
				else
					local ball = class2:Ball()
					ball.Transparency = 0.5
					ball.Anchored = true
					ball.CanCollide = false
					ball.CFrame = object.CFrame
					ball.Parent = workspace.Effects
					ball.Size = Vector3.new()
					TweenService:Create(ball, tweenInfo, {
						Size = createVector(15, 15, 15),
						Transparency = 1
					}):Play()
					_G.PU:Dust(ball, 1)

					if not reset and object:FindFirstChildOfClass("ProximityPrompt") then
						local proximityPrompt = object:FindFirstChildOfClass("ProximityPrompt")
						proximityPrompt.Enabled = false
					end

					if object:FindFirstChild("Puzzle_Plate") then
						local puzzle = object.Puzzle_Plate:FindFirstChild("Puzzle")

						if puzzle then
							puzzle.Transparency = 0

							for _, child in pairs(puzzle:GetChildren()) do
								child.Transparency = 0
							end
						end
					end

					local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Box:Clone()
					clone.Anchored = true
					clone.CanCollide = false
					clone.Transparency = 1
					clone.CFrame = object.CFrame * CFrame.new(0, 2, 0)
					clone.Parent = workspace.Effects
					v5:Emit(clone, 5)
					_G.PU:Dust(clone, 1)
				end
			end

			if hint and object then
				local ball = class2:Ball()
				ball.Transparency = 0.5
				ball.Anchored = true
				ball.CanCollide = false
				ball.CFrame = object.CFrame
				ball.Parent = workspace.Effects
				ball.Size = Vector3.new()
				TweenService:Create(ball, tweenInfo, {
					Size = createVector(15, 15, 15),
					CFrame = ball.CFrame * CFrame.new(0, 5, 0),
					Transparency = 1
				}):Play()
				local clone = textShow_:Clone()
				clone.Parent = ball
				clone.TextLabel.Text = hint
				clone.Enabled = true
				clone.Adornee = ball
				_G.PU:Dust(clone, 1)
				_G.PU:Dust(ball, 1.5)
			end

			if interact and object then
				if object:FindFirstChildOfClass("ProximityPrompt") then
					local proximityPrompt_2 = object:FindFirstChildOfClass("ProximityPrompt")
					proximityPrompt_2.Enabled = false
				end

				if object:FindFirstChildOfClass("BillboardGui") then
					local billboardGui = object:FindFirstChildOfClass("BillboardGui")
					billboardGui.Enabled = false
				end

				for _, part in pairs(object:GetDescendants()) do
					if part:IsA("MeshPart") then
						part.Transparency = 1
					end
				end
			end
		end

		if questType == "Ain't my Fault" and not v3.Max then
			object.Transparency = 1

			if object:FindFirstChild("PromptQuest") then
				object.PromptQuest.Enabled = false
			end
		end

		if questType == "Bone Hunter" then
			local clone = ReplicatedStorage.Chest.FruitEffect.Sand["Sand Projectile Explode"]:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = object.CFrame * CFrame.new(0, 2, 0)
			clone.Parent = workspace.Effects
			v5:Emit(clone, 5)
			_G.PU:Dust(clone, 1)

			if not v3.Max then
				object.Transparency = 1

				if object:FindFirstChild("PromptQuest") then
					object.PromptQuest.Enabled = false
				end
			end
		end

		if questType == "I'm not,YOU ARE!" then
			local humanoidRootPart = v.Character.HumanoidRootPart
			local clone = ReplicatedStorage.Chest.FruitEffect.Gold.crown:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Anchored = true
			clone.Transparency = 1
			clone.CanCollide = false
			clone.Parent = workspace.Effects
			v5:Emit(clone, 5)
			_G.PU:Dust(clone, 1.5)

			if object:FindFirstChild("LeePunggQuestTracker") then
				object.LeePunggQuestTracker:Destroy()
			end

			for _, decal in pairs(object:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Transparency = 1
				end
			end
		end

		if questType == "Venture Lagoons!" or questType == "Under The Sea~" then
			local humanoidRootPart = v.Character.HumanoidRootPart

			if (humanoidRootPart.Position - object.Position).Magnitude <= 60 then
				local ball = class2:Ball()
				ball.CFrame = humanoidRootPart.CFrame
				ball.Parent = workspace.Effects
				ball.Color = Color3.new(0.348775, 1, 0.412451)
				ball.Transparency = 0.5
				TweenService:Create(ball, tweenInfo, {
					Size = createVector(55, 55, 55),
					Transparency = 1
				}):Play()
				_G.PU:Dust(ball, 1.5)

				if object:FindFirstChild("LeePunggQuestTracker") then
					object.LeePunggQuestTracker:Destroy()
				end

				for _, decal in pairs(object:GetChildren()) do
					if decal:IsA("Decal") then
						decal.Transparency = 1
					end
				end
			end
		end

		if questType == "Pumpkin Smasher" or questType == "Pumpkin Smasher Ep.2" and object then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://15156931277"
			sound.Parent = object
			sound:Play()
			_G.PU:Dust(sound, 3)
			local clone = chest.Etc.PumpkinImpact:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.CFrame = object.CFrame
			clone.Parent = workspace.Effects
			v5:Emit(clone)
			_G.PU:Dust(clone, 1)
			local clone2 = chest.Etc.MisterPumpkin.PumpkinHead:Clone()
			clone2.Anchored = false
			clone2.CanCollide = true
			clone2.CollisionGroup = "p"
			clone2.CFrame = object.CFrame * CFrame.new(0, 2, 0)
			clone2.Parent = workspace.Effects
			clone2.Velocity = randomDirection() * 100
			_G.PU:Dust(clone2, 1.5)
			TweenService:Create(clone2, tweenInfo, {
				Transparency = 1,
				Size = Vector3.new()
			}):Play()

			if object:FindFirstChild("PromptQuest") then
				object.PromptQuest.Enabled = false
			end

			if not v3.Max then
				for _, part in pairs(object:GetChildren()) do
					if part:IsA("MeshPart") then
						part.Transparency = 1
					end
				end
			end
		end

		if questType == "Tear" and object then
			for _, child in pairs(object:GetChildren()) do
				if child:IsA("Decal") then
					child.Transparency = 1
				end

				if child:IsA("SurfaceGui") then
					child.Enabled = false
				end
			end

			local part = Instance.new("Part", workspace.Effects)
			part.Name = "Paper_Decal"
			part.CFrame = cFrame3
			part.Material = Enum.Material.ForceField
			part.Color = Color3.new(1, 0.620966, 0.312123)
			part.Size = createVector(2.203, 2.996, 0.085)
			part.CanCollide = false
			part.Anchored = false
			part.Velocity = part.CFrame.LookVector * 5
			TweenService:Create(part, tweenInfo, {
				Size = Vector3.new()
			}):Play()
			task.spawn(function()
				wait(10)

				if object and object.Parent then
					for _, child in pairs(object:GetChildren()) do
						if child:IsA("Decal") then
							child.Transparency = 0
						end

						if child:IsA("SurfaceGui") then
							child.Enabled = true
						end
					end
				end
			end)
			_G.PU:Dust(part, 1.5)
		end

		if questType == "Feather" and object then
			local part = Instance.new("Part", workspace.Effects)
			part.Name = "FeatherPickedUp"
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.5
			part.Shape = "Ball"
			part.Size = Vector3.new()
			part.CFrame = cFrame3
			part.Material = Enum.Material.Neon

			if v.Character:FindFirstChild("Head") then
				Chat:Chat(v.Character.Head, "Got it!")
			end

			TweenService:Create(part, tweenInfo, {
				Size = createVector(10, 10, 10),
				Transparency = 1
			}):Play()
			_G.PU:Dust(part, 1)
		end
	end
end