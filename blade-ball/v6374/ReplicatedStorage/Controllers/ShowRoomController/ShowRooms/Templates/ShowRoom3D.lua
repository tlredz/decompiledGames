local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GamepadService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(script.Parent.Parent.Parent.ShowRoomUtility)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v4 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)

local function emoteHidesAccessory(p: string?)
	local v5 = p and v4:GetCollection()[p]
	return v5 ~= nil and v5.HideAccessory == true
end

local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local v6 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v7 = require3(ReplicatedStorage2.Shared.CherubVariants)
local v8 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v9 = require3(ReplicatedStorage2.Shared.SwordAPI)
local v10 = require3(ReplicatedStorage2.Shared.Emotes)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v12 = require3(ReplicatedStorage2.Shared.AnimationProfiles)
local v13 = require3(ReplicatedStorage2.Packages.Observers)
local v14 = require3(ReplicatedStorage2.Shared.ReplicatedInstancesUtils)
require3(ReplicatedStorage2.Shared.EmotesShared)
local v15 = require3(ReplicatedStorage2.Shared.AttrGeneration)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v16 = CFrame.new(-3.28, 805.436, -118.489) * CFrame.Angles(0, -1.5707963267948966, 0)
local v17 = CFrame.new(-3.28, 805.436, -298.78) * CFrame.Angles(0, -1.5707963267948966, 0)
local magnitude = (v16.Position - v17.Position).Magnitude
local v18 = true
local v19 = nil

local function createFromEmoteName(name)
	local v20 = v10[name]

	if not v20 then
		local v21 = v6:GetCollection()[name] ~= nil
		v20 = {
			VFX = v21 and name,
			Emote = ReplicatedStorage2.Misc.Emotes[name],
			Play = v21 and play
		}
	end

	return {
		Animation = v20.Emote,
		FX = v20.Play and function(parent, emoteScale, maid, _: string)
			local folder = Instance.new("Folder")
			maid:Add(folder)
			folder.Name = "EmoteVFX_Storage"
			folder.Parent = parent
			parent:SetAttribute("EmoteScale", emoteScale)
			parent:SetAttribute("CurrentEmote", name)
			local v21 = v20.Play(v20, parent, true)

			if v21 then
				maid:Add(v21)
			end

			maid:Add(function()
				parent:SetAttribute("CurrentEmote", nil)
				v20.Play(v20, parent, false)
			end)
			return v21
		end or function() end
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createAnimationObject(id)
	local animation = Instance.new("Animation")
	animation.AnimationId = id
	return animation
end

local function pickProfileAnimation(sword: string?, p: string)
	local v20 = sword and v12[sword]
	local v21 = v20 and v20[p]

	if not (v21 and next(v21)) then
		return nil
	end

	local total = 0

	for _, v22 in v21 do
		total += v22.weight or 1
	end

	local v22 = math.random() * total

	for _, v23 in v21 do
		v22 -= v23.weight or 1

		if v22 <= 0 and v23.id then
			return v23
		end
	end

	return nil
end

local v20 = {}
local scalesByChild = {}
local v21 = {}
local scalesByInstance = {}
local sizesByInstance = {}

local function applyBackgroundLayout(instance, holoPadLayout)
	local background = instance:FindFirstChild("Background")

	if not (background and background:IsA("BasePart")) then
		return
	end

	local surfaceGui = background:FindFirstChildWhichIsA("SurfaceGui")

	if surfaceGui then
		surfaceGui.Enabled = holoPadLayout ~= nil and holoPadLayout.ShowBackground == true
	end

	if not holoPadLayout then
		return
	end

	local showRoomCamera = v3:GetShowRoomCamera(instance)

	if not showRoomCamera then
		return
	end

	background.Size = Vector3.new(
		holoPadLayout.BackgroundWidth or background.Size.X,
		holoPadLayout.BackgroundHeight or background.Size.Y,
		background.Size.Z
	)

	if holoPadLayout.BackgroundDistance then
		local position = showRoomCamera.Position
		local NPCS = instance:FindFirstChild("NPCS")
		local v22 = NPCS and NPCS:GetChildren()[1]

		if v22 then
			position = v22:GetPivot().Position
		end

		local v23 = position + showRoomCamera.LookVector * holoPadLayout.BackgroundDistance
		background.CFrame = CFrame.lookAt(v23, v23 - showRoomCamera.LookVector)
	end
end

local function applyPlayerLayout(instance, holoPadLayout, showRoomCamera: CFrame, pivot: CFrame)
	local v22 = {}
	local NPCS = instance:FindFirstChild("NPCS")

	if NPCS then
		for _, child in NPCS:GetChildren() do
			table.insert(v22, child)
		end
	end

	local pad = instance:FindFirstChild("Pad")

	if pad then
		table.insert(v22, pad)
	end

	for _, instance2 in v22 do
		local v23 = v21[instance2]

		if not v23 then
			v23 = pivot:ToObjectSpace(instance2:GetPivot())
			v21[instance2] = v23
		end

		local objectSpace = showRoomCamera:ToObjectSpace(pivot * v23)

		if holoPadLayout then
			objectSpace += Vector3.new(
				holoPadLayout.PlayerSide or 0,
				holoPadLayout.PlayerHeight or 0,
				-(holoPadLayout.PlayerDepth or 0)
			)
		end

		local v24 = not holoPadLayout and 1 or holoPadLayout.PlayerScale or 1

		if v24 ~= 1 then
			if instance2:IsA("Model") then
				local scale = scalesByInstance[instance2]

				if not scale then
					scale = instance2:GetScale()
					scalesByInstance[instance2] = scale
				end

				local v25 = scale * v24

				if math.abs(instance2:GetScale() - v25) > 0.0001 then
					instance2:ScaleTo(v25)
				end
			elseif instance2:IsA("BasePart") then
				local size = sizesByInstance[instance2]

				if not size then
					size = instance2.Size
					sizesByInstance[instance2] = size
				end

				instance2.Size = size * v24
			end
		end

		instance2:PivotTo(showRoomCamera * objectSpace)
	end
end

local function applyHoloPadLayout(instance)
	local holoPadLayout = v3.HoloPadLayout
	local showRoomCamera = v3:GetShowRoomCamera(instance)

	if not showRoomCamera then
		return
	end

	local pivot = instance:GetPivot()
	applyPlayerLayout(instance, holoPadLayout, showRoomCamera, pivot)
	applyBackgroundLayout(instance, holoPadLayout)
	local holoPads = instance:FindFirstChild("HoloPads")

	if not holoPads then
		return
	end

	local visiblePads = holoPadLayout and holoPadLayout.VisiblePads

	if visiblePads then
		local children = holoPads:GetChildren()
		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)

		for k, v22 in children do
			v22:SetAttribute("IsShown", k <= visiblePads)
		end
	end

	local v22 = {}

	for _, child in holoPads:GetChildren() do
		local v23 = v20[child]

		if not v23 then
			v23 = pivot:ToObjectSpace(child:GetPivot())
			v20[child] = v23
		end

		if not scalesByChild[child] then
			scalesByChild[child] = child:GetScale()
		end

		if not visiblePads or child:GetAttribute("IsShown") == true then
			table.insert(v22, {
				Pad = child,
				Local = showRoomCamera:ToObjectSpace(pivot * v23)
			})
		end
	end

	table.sort(v22, function(a, b)
		return a.Local.Position.X < b.Local.Position.X
	end)

	if holoPadLayout then
		if holoPadLayout.SwapSides and #v22 == 2 then
			local v23 = v22[1].Local
			local v24 = v22[2].Local
			v22[1].Local = v23 - v23.Position + Vector3.new(v24.Position.X, v23.Position.Y, v23.Position.Z)
			v22[2].Local = v24 - v24.Position + Vector3.new(v23.Position.X, v24.Position.Y, v24.Position.Z)
		end

		if holoPadLayout.AlignDepth then
			local v23 = 1e999

			for _, v24 in v22 do
				v23 = math.min(v23, v24.Local.Position.Z)
			end

			for _, v24 in v22 do
				local position = v24.Local.Position
				v24.Local = v24.Local - position + Vector3.new(position.X, position.Y, v23)
			end
		end

		if holoPadLayout.AlignHeight then
			local total = 0

			for _, v23 in v22 do
				total += v23.Local.Position.Y
			end

			local v23 = total / math.max(#v22, 1)

			for _, v24 in v22 do
				local position = v24.Local.Position
				v24.Local = v24.Local - position + Vector3.new(position.X, v23, position.Z)
			end
		end

		local sideOffset = holoPadLayout.SideOffset or 0
		local heightOffset = holoPadLayout.HeightOffset or 0
		local depthOffset = holoPadLayout.DepthOffset or 0

		if #v22 == 1 then
			local v23 = v22[1]
			local single = holoPads:FindFirstChild("Single")
			local v24 = single and v20[single]

			if v24 and single ~= v23.Pad then
				local position = v23.Local.Position
				local X = showRoomCamera:ToObjectSpace(pivot * v24).Position.X
				v23.Local = v23.Local - position + Vector3.new(X, position.Y, position.Z)
			end
		end

		for k, v23 in v22 do
			local v24

			if #v22 < 2 then
				v24 = 0
			elseif k == 1 then
				v24 = -sideOffset
			else
				v24 = sideOffset
			end

			v23.Local += Vector3.new(v24, heightOffset, -depthOffset)
		end
	end

	local v23 = not holoPadLayout and 1 or holoPadLayout.PadScale or 1

	for _, v24 in v22 do
		local pad = v24.Pad
		local v25 = (holoPadLayout and holoPadLayout.PadBaseScale or scalesByChild[pad] or 1) * v23

		if math.abs(pad:GetScale() - v25) > 0.0001 then
			pad:ScaleTo(v25)
		end

		pad:PivotTo(showRoomCamera * v24.Local)
	end
end

local v22 = {}
local scope = v15.scope("ShowRoomNPC")
return function(data)
	local instance = data.Instance
	local trove = data.Trove
	v19 = nil
	v18 = true
	local character = localPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
	end

	local appliedDescription

	if humanoid then
		appliedDescription = humanoid:GetAppliedDescription()
	else
		appliedDescription = nil
	end

	if not (appliedDescription and humanoid and character) then
		return
	end

	local function addSwordToHoloPad(sword: string, parent)
		if not parent then
			return
		end

		local instance2 = v14.getInstance("Swords", sword)

		if not instance2 then
			return warn("Can't find sword", sword)
		end

		if parent:GetAttribute("RenderAccessoryOnly") then
			instance2 = v5:GetInstance(parent:GetAttribute("Accessory") or sword) or instance2
		end

		local C0 = parent.Main.Attachment.CFrame + createVector(0, -1.5, 0)
		local clone = trove:Clone(instance2)

		if not clone:IsA("Model") then
			local parent2 = trove:Add(Instance.new("Model"))

			for _, child in clone:GetChildren() do
				child.Parent = parent2
			end

			clone:Destroy()
			clone = parent2
		end

		clone.Name = "RenderedSword"
		clone:SetAttribute("Sword", sword)
		clone:PivotTo(C0)
		local v24 = 1.5

		if sword == "Chroma Blade" or sword == "Chroma Scythe" or sword == "Dual Chroma Set" or sword == "Santa's Greatsword" or sword == "Polar Bear" and not parent:GetAttribute("RenderAccessoryOnly") or sword == "Penguin" then
			v24 = 2
		elseif sword == "Sea Turtle" then
			v24 = 0.8
		elseif sword == "Radiant Duckling Lance" then
			v24 = 1.05
		elseif sword == "Ace" then
			v24 = 4

			for _, model in clone:GetChildren() do
				if model.Name ~= "1" and model:IsA("Model") then
					model:Destroy()
				end
			end
		elseif sword == "The Curse" then
			clone.sord.Torso.Part0 = parent.Main
			clone.sord.Torso.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		end

		if parent:GetAttribute("RenderAccessoryOnly") then
			clone.HumanoidRootPart.RootPart.Part1.Name = "sord"
			v24 = 1
		end

		clone:ScaleTo(clone:GetScale() * v24)
		local isDual = clone:GetAttribute("IsDual")

		for _, child in parent.Main.SwordWelds:GetChildren() do
			local child2 = clone:FindFirstChild(child.Name, true)
			child.Part0 = parent.Main
			child.Part1 = child2

			if sword == "Black Ninja Katana" or sword == "Red Ninja Katana" or sword == "Green Ninja Katana" or sword == "Blue Ninja Katana" or sword == "Pink Ninja Katana" or sword == "Chroma Ninja Katana" or sword == "Wonderwisp Greatsword" or sword == "Moonflower Greatsword" or sword == "Moonflower Katana" or sword == "Santa's Greatsword" or sword == "Serpent's Greatsword" or sword == "Blossom Katana" or sword == "Hollow Oath Katana" or sword == "Pink Oni Katana" or sword == "Black Oni Katana" or sword == "Blue Oni Katana" or sword == "Purple Oni Katana" or sword == "Red Oni Katana" or sword == "Chroma Oni Katana" or sword == "Gold Vanity Spear" or sword == "Deathwarden Lance" or sword == "Proyection Sorcery Katana" or sword == "Astral Seraph Blade" then
				child.C0 = CFrame.new(0, 5.5, 0) * CFrame.fromOrientation(
					0.6981317007977318,
					-1.0471975511965976,
					0.7853981633974483
				)
			elseif sword == "Phantom Ops" then
				child.C0 = CFrame.new(0, 7, 0) * CFrame.fromOrientation(0, 0, 0.4363323129985824)
			elseif sword == "Crimson Kagune" or sword == "Deathrider" then
				child.C0 = CFrame.new(0, 7, 0) * CFrame.fromOrientation(0.4363323129985824, -1.5707963267948966, 0)
			elseif sword == "Starlit Halo Wings" then
				child.C0 = CFrame.new(-0.32, 6, -2.436) * CFrame.fromOrientation(0, 0, 0)
			elseif sword == "Sea Turtle" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.fromOrientation(
					0,
					-0.7853981633974483,
					0.2617993877991494
				)
			elseif sword == "Shark" then
				child.C0 = CFrame.new(0, 5.5, 0) * CFrame.fromOrientation(
					1.5707963267948966,
					-1.5707963267948966,
					1.0471975511965976
				)
				local v25 = child
				trove:Add(RunService.PostSimulation:Connect(function(dt: number)
					v25.C1 = CFrame.new(0, 0, math.sin(os.clock() * 2) * 0.5)
				end))
			elseif sword == "Serpent" then
				child.C0 = CFrame.new(0, 4, -2.436) * CFrame.fromOrientation(-0.2617993877991494, 0.3490658503988659, 0)
			elseif sword == "Higanbana Katana" or sword == "Regret Blades" or sword == "Red Moon Katana" or sword == "Brutality Affection Bat" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.fromOrientation(
					0.6108652381980153,
					1.5707963267948966,
					0
				)
			elseif sword == "Wolf Greatsword" then
				child.C0 = CFrame.new(-0.32, 5.298, -2.436) * CFrame.fromOrientation(
					0.6108652381980153,
					1.5707963267948966,
					0
				)
			elseif sword == "Gyaru Katana" or sword == "Gravelight" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.fromOrientation(
					0.4363323129985824,
					1.5707963267948966,
					0
				)
			elseif sword == "Phantom Pact" then
				child.C0 = CFrame.new(-0.32, 6.5, -2.436) * CFrame.fromOrientation(
					0.4363323129985824,
					1.5707963267948966,
					0
				)
			elseif sword == "Night Raver" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.fromOrientation(
					0.4363323129985824,
					1.5707963267948966,
					-3.141592653589793
				)
			elseif sword == "Dual Vaporwave Crusher" or sword == "Ornament Crushers" then
				child.C0 = CFrame.new(1.75, 6.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			elseif sword == "Kitty Launcher" or sword == "Snowball Launcher" then
				child.C0 = CFrame.new(2, 6, 0) * CFrame.fromOrientation(-0.4363323129985824, -1.7453292519943295, 0)
			elseif sword == "Soulrender Scythe" or sword == "Jolly Scythe Set" or sword == "Venomlight Scythe" or sword == "The Curse" then
				child.C0 = CFrame.new(-0.32, 7, -2.436) * CFrame.fromOrientation(
					0,
					-1.5707963267948966,
					-0.6108652381980153
				)
			elseif sword == "Ocean Guitar" then
				child.C0 = CFrame.new(-0.32, 6.75, -2.436) * CFrame.fromOrientation(
					0.6108652381980153,
					-1.5707963267948966,
					0
				)
			elseif sword == "Candycane Sniper" then
				child.C0 = CFrame.new(0.7, 6.5, -2.436) * CFrame.fromOrientation(
					-0.6108652381980153,
					-1.5707963267948966,
					-0.2617993877991494
				)
			elseif sword == "Malice Parasol" then
				child.C0 = CFrame.new(0, 6.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			elseif sword == "Harmonic Staff" then
				child.C0 = CFrame.new(0, 10.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			elseif sword == "Frostbound Lantern" then
				child.C0 = CFrame.new(0, 10.5, 0)
			elseif sword == "Ace" then
				child.C0 = CFrame.new(0, 14, 0)
			elseif sword == "The Conjurer" then
				child.C0 = CFrame.new(0, 8.5, 0) * CFrame.Angles(0, -1.5707963267948966, -0.6108652381980153)
			elseif sword == "Radiant Duckling Lance" or sword == "Verdant Thorn Lance" then
				child.C0 = CFrame.new(0, 5.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			elseif sword == "Harmonic Fan" or sword == "Cat Paw" then
				child.C0 = CFrame.new(0, 6.5, 0)
			elseif sword == "Polar Bear" or sword == "Penguin" or sword == "Shatterflight Bird" then
				child.C0 = CFrame.new(0, 5.5, 0)
			elseif isDual or sword == "Desert Claws" or sword == "Aetherial Lance" or sword == "Sakura Parasol" or sword == "Dual Harmonic Set" then
				if (sword == "Desert Claws" or child.Name ~= "sord") and (sword ~= "Desert Claws" or child.Name ~= "dosdos2") then
					child.C0 = CFrame.new(-2, (sword == "Dual Harmonic Set" and 8 or 6.25) + -1.5, 0) * CFrame.fromOrientation(
						0.6981317007977318,
						-1.0471975511965976,
						0.7853981633974483
					)
				else
					child.C0 = CFrame.new(0, (sword == "Dual Harmonic Set" and 12 or 8) + -1.5, 0) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
				end
			elseif sword == "Guardian of the Underworld" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.Angles(0, 3.141592653589793, 0)
			elseif sword == "Riftflare Katana" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436) * CFrame.Angles(0.2617993877991494, 1.5707963267948966, 0)
			elseif sword == "Cherub" then
				child.C0 = CFrame.new(-0.32, 7, -2.436)
			elseif sword == "Swan Serenity" then
				child.C0 = CFrame.new(-0.32, 8.298, -2.436)
			else
				child.C0 = C0
			end

			child:SetAttribute("C0", child.C0)
			child.Enabled = true
		end

		clone.Parent = parent
		local child = ReplicatedStorage2.Misc.SwordPacksVFX:FindFirstChild(sword)

		if child and child:FindFirstChild("HoloPose") then
			local parent2 = trove:Add(Instance.new("AnimationController"))
			local animator = trove:Add(Instance.new("Animator"))
			animator.Parent = parent2
			parent2.Parent = clone
			local track = animator:LoadAnimation(child.HoloPose)
			trove:Add(function()
				track:Stop()
				track:Destroy()
			end)
			track:Play()
			track:AdjustSpeed(0)
		end
	end

	local maid = trove:Extend()

	local function addSwordToNPC(parent, sword, p: number?)
		local instance2 = v14.getInstance("Swords", sword)

		if not instance2 then
			return warn("Can't find sword", sword)
		end

		maid:Clean()

		if v8:GetSword(sword) then
			local ignoreAccessory = parent:GetAttribute("IgnoreAccessory")

			if not ignoreAccessory then
				if parent:GetAttribute("CurrentEmote") == "Emote711" then
					ignoreAccessory = true
				else
					local currentEmote = parent:GetAttribute("CurrentEmote")
					local v24 = currentEmote and v4:GetCollection()[currentEmote]

					if v24 == nil then
						ignoreAccessory = false
					else
						ignoreAccessory = v24.HideAccessory == true
					end
				end
			end

			local v24 = assert(v8:GetOrForceEquipSwordTo(parent, sword, p, ignoreAccessory))
			v24:SetAttribute("Sword", sword)
			v24.Name = "EquippedSword"
			local v25 = nil

			for _, child in parent:GetChildren() do
				if not child:GetAttribute("_swordAccessory") then
					continue
				end

				v25 = child
				break
			end

			if v25 then
				maid:Add(v13.observeChildren(v25, function(instance3)
					if not instance3:HasTag("AnimatedAccessory") then
						return nil
					end

					instance3:RemoveTag("AnimatedAccessory")
					local animator = instance3:FindFirstChildWhichIsA("Animator", true)
					local walk = animator and animator:FindFirstChild("Walk", true)

					if not (animator and walk) then
						return nil
					end

					local track = animator:LoadAnimation(walk)
					maid:Add(function()
						track:Stop()
						track:Destroy()
					end)
					track:Play()
					local v27 = v12[sword]

					if v27 and v27.walk then
						local id = v27.walk[1].id
						local v28 = maid:Add(Instance.new("Animation"))
						v28.AnimationId = id
						local track2 = parent.Humanoid.Animator:LoadAnimation(v28)
						maid:Add(function()
							track2:Stop()
							track2:Destroy()
						end)
						track2:Play()
					end

					return nil
				end))
			end
		else
			local clone = trove:Clone(instance2)
			clone.Name = "EquippedSword"
			clone:SetAttribute("Sword", sword)

			if p and p ~= 1 then
				clone:ScaleTo(clone:GetScale() * p)
			end

			clone:PivotTo(parent:GetPivot())
			local torso = parent.Torso

			for _, child in torso.SwordWelds:GetChildren() do
				local child2 = clone:FindFirstChild(child.Name, true)
				child.Part0 = torso
				child.Part1 = child2
				child.Enabled = true
			end

			clone.Parent = parent
		end
	end

	local children = {}
	local v23 = {}
	local ensureInnerShowRoomBuilt

	local function getStagePosition(p: number?)
		if v19 and p and p ~= 0 then
			local v24 = v19:GetPivot() * CFrame.new(math.sign(p) * 1 * magnitude, 0, 0)

			if (v24.Position - v16.Position).Magnitude < 20000 then
				return v24
			end
		end

		local v24

		if v18 then
			v24 = v17
		else
			v24 = v16
		end

		v18 = not v18
		return v24
	end

	local function moveToShowRoom(selected: string?, p: number?)
		data.Info.Selected = selected

		if not selected then
			return warn("No ShowRoom name found", selected)
		end

		local child = instance.InnerShowRooms:FindFirstChild(selected)

		if not child then
			return warn("No ShowRoom found for", selected)
		end

		ensureInnerShowRoomBuilt(child)

		if v19 ~= child then
			if v19 then
				local background = v19:FindFirstChild("Background")
				local surfaceGui = background and background:FindFirstChildWhichIsA("SurfaceGui")

				if surfaceGui then
					surfaceGui.Enabled = false
				end

				v19:PivotTo(CFrame.new(0, -100000, 0))

				for _, child2 in v19.NPCS:GetChildren() do
					child2:SetAttribute("IsShown", false)
				end

				for _, child2 in v19.HoloPads:GetChildren() do
					child2:SetAttribute("IsShown", false)
				end
			end

			for _, child2 in child.NPCS:GetChildren() do
				child2:SetAttribute("IsShown", true)
			end

			child:PivotTo((getStagePosition(p)))
			applyHoloPadLayout(child)

			for _, child2 in child.HoloPads:GetChildren() do
				child2:SetAttribute("IsShown", true)
			end

			v19 = child
		end

		local tween = TweenService:Create(currentCamera, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			CFrame = v3:GetCameraCFrameFor(currentCamera, child)
		})
		tween.Completed:Once(function()
			tween:Destroy()
		end)
		tween:Play()
	end

	local function createHoloPad(instance2)
		local function updateHovering()
			if not (instance2:GetAttribute("IsShown") and instance2:FindFirstChild("RenderedSword")) then
				return
			end

			if instance2:GetAttribute("IsHovering") then
				TweenService:Create(instance2.Light.BottomLight.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
					Brightness = 4.5
				}):Play()

				for _, child in instance2.Main.SwordWelds:GetChildren() do
					TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
						C0 = child:GetAttribute("C0") + createVector(0, 1.5, 0)
					}):Play()
				end
			else
				TweenService:Create(instance2.Light.BottomLight.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
					Brightness = 0.5
				}):Play()

				for _, child in instance2.Main.SwordWelds:GetChildren() do
					TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
						C0 = child:GetAttribute("C0")
					}):Play()
				end
			end
		end

		local function updateSword()
			if not instance2:GetAttribute("IsShown") then
				return
			end

			local sword = instance2:GetAttribute("Sword")
			local renderedSword = instance2:FindFirstChild("RenderedSword")

			if renderedSword and renderedSword:GetAttribute("Sword") == sword then
				return
			end

			if renderedSword then
				renderedSword:Destroy()
			end

			if sword then
				addSwordToHoloPad(sword, instance2)

				if sword == "Crimson Eclipse" or sword == "Dual Crimson Eclipse" then
					local renderedSword2 = instance2:FindFirstChild("RenderedSword")

					if not renderedSword2 then
						return
					end

					for _, emitter in renderedSword2:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Rate /= 2.25
						end
					end
				end
			end

			updateHovering()
		end

		trove:Add(instance2:GetAttributeChangedSignal("IsShown"):Connect(updateSword))
		trove:Add(instance2:GetAttributeChangedSignal("Sword"):Connect(updateSword))
		task.spawn(updateSword)
		trove:Add(instance2:GetAttributeChangedSignal("IsHovering"):Connect(updateHovering))
		trove:Add(instance2:GetAttributeChangedSignal("IsShown"):Connect(updateHovering))
		task.spawn(updateHovering)
	end

	local function createNPC(parent)
		local v24 = scope.beginForced(parent)
		parent:ScaleTo(1)
		task.wait()

		if not scope.isCurrent(parent, v24) then
			return
		end

		local humanoid2 = parent.Humanoid
		local animator = humanoid2:FindFirstChildOfClass("Animator")
		humanoid2:ApplyDescriptionAsync(appliedDescription)

		if not scope.isCurrent(parent, v24) then
			return
		end

		parent:ScaleTo(1.5)

		for _, v25 in animator:GetPlayingAnimationTracks() do
			v25:Stop(0)
			v25:Destroy()
		end

		local maid2 = trove:Extend()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function loadAnimation(animation)
			local track = animator:LoadAnimation(animation)
			maid2:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			return track
		end

		local inputStart = parent:GetAttribute("InputStart")
		trove:Add(parent:GetAttributeChangedSignal("InputStart"):Connect(function()
			inputStart = parent:GetAttribute("InputStart")
		end))
		local identity = CFrame.identity
		local total = 0
		local v25 = select(2, parent:GetPivot():ToOrientation())
		trove:Add(RunService.Heartbeat:Connect(function(dt: number)
			if not parent:GetAttribute("IsShown") then
				total = 0
				return
			end

			local v26 = dt * 0.1 * 60
			local v27 = not inputStart and 0 or math.rad((v:GetMouseLocation() - inputStart).X)
			total += (v27 - total) * v26
			parent:PivotTo(CFrame.new((parent:GetPivot() * identity:Inverse()).Position) * identity * CFrame.fromOrientation(
				0,
				v25 + total,
				0
			))
		end))

		local function updateSword()
			if not scope.isCurrent(parent, v24) then
				return
			end

			if not parent:GetAttribute("IsShown") then
				maid2:Clean()
				return
			end

			local emote = parent:GetAttribute("Emote")
			local sword = parent:GetAttribute("Sword")

			if sword or emote then
				local billboardGui = parent:FindFirstChild("BillboardGui")
				local rankedLabel = billboardGui and billboardGui:FindFirstChild("RankedLabel")

				if rankedLabel then
					if sword then
						rankedLabel.Text = string.upper(sword)
					else
						local child = ReplicatedStorage2.Misc.Emotes:FindFirstChild(emote)

						if child then
							rankedLabel.Text = string.upper(child:GetAttribute("EmoteName") or "")
						end
					end
				end
			end

			local lastIgnoreAccessory = parent:GetAttribute("LastIgnoreAccessory")
			local lastEmote = parent:GetAttribute("LastEmote")
			local lastSword = parent:GetAttribute("LastSword")
			local slash = parent:GetAttribute("Slash")
			local ignoreAccessory = parent:GetAttribute("IgnoreAccessory")

			if sword == lastSword and emote == lastEmote and not slash and ignoreAccessory == lastIgnoreAccessory then
				return
			end

			maid2:Clean()
			maid2:Add(function()
				parent:SetAttribute("LastSword", nil)
				parent:SetAttribute("LastEmote", nil)
				parent:SetAttribute("LastIgnoreAccessory", nil)
			end)
			parent:SetAttribute("LastSword", sword)
			parent:SetAttribute("LastEmote", emote)
			parent:SetAttribute("LastIgnoreAccessory", parent:GetAttribute("IgnoreAccessory"))
			local v26 = nil

			if not slash or sword ~= lastSword then
				local equippedSword = parent:FindFirstChild("EquippedSword")

				if equippedSword then
					equippedSword:Destroy()
				end

				if sword then
					local instance2 = v5:GetInstance(sword)

					if instance2 and not parent:GetAttribute("IgnoreAccessory") and emote ~= "Emote711" then
						local v27 = emote and v4:GetCollection()[emote]
						local v28

						if v27 == nil then
							v28 = false
						else
							v28 = v27.HideAccessory == true
						end

						if v28 then
							v26 = sword
						else
							local folder = Instance.new("Folder")
							maid2:Add(folder)
							folder.Name = "SwordAccessories"
							folder:SetAttribute("_swordAccessory", true)
							folder:SetAttribute("Seed", Random.new():NextNumber(0, 100))
							local clone = instance2:Clone()
							v2.Physics.ResizePart(clone, 1.5)
							v26 = sword

							for _, part in clone:GetChildren() do
								local child = parent:FindFirstChild(part.Name)

								if child and part:IsA("BasePart") then
									part:PivotTo(child:GetPivot())
									part.CanCollide = false
									part.Anchored = false
									part.CanQuery = false
									part.CanTouch = false
									part.Massless = true
									part.Transparency = 1
									v2.Physics.CreateWeld(part, child)
								end

								part.Parent = folder
							end

							clone:Destroy()
							folder.Parent = parent
						end
					else
						v26 = sword
					end
				end
			end

			if not (slash or parent:GetAttribute("NoEmote")) then
				local name = nil
				local forceIdle = parent:GetAttribute("ForceIdle") == true
				local v27 = v22[sword]

				if not (v27 or emote or forceIdle) then
					for _, v29 in v6:GetCollection() do
						if v29.Sword ~= sword then
							continue
						end

						name = v29.Name
						v27 = createFromEmoteName(v29.Name)
						break
					end
				end

				local idleAnimation

				if not forceIdle then
					idleAnimation = emote and ReplicatedStorage2.Misc.Emotes:FindFirstChild(emote) or v27 and v27.Animation
				end

				if not idleAnimation then
					local sword2 = v8:GetSword(sword)

					if sword2 then
						idleAnimation = v9:GetAnimations(parent, "Idle", sword2.AnimationType, sword2.SwordType)[1]
					else
						idleAnimation = ReplicatedStorage2.Misc.IdleAnimation
					end
				end

				local function loadAnimationObject(animation)
					local track = loadAnimation(animation) -- equivalent call inferred; original call site unknown
					track.Looped = true
					track.Name = animation.Name
					local timePositions = {}
					maid2:Add(track:GetMarkerReachedSignal("Pin"):Connect(function(p)
						timePositions[p] = track.TimePosition
					end))
					maid2:Add(track:GetMarkerReachedSignal("GOTO"):Connect(function(p)
						local timePosition = timePositions[p]

						if timePosition then
							track.TimePosition = timePosition
						end
					end))
					track:Play()
					return track
				end

				if emote == "Emote711" or name == "Emote711" then
					local clone = maid2:Clone(ReplicatedStorage2.Misc.PolarBearEmote)
					clone.RootPart.Weld.Part0 = parent:FindFirstChild("HumanoidRootPart")
					clone:ScaleTo(character:GetScale() * 1.5)
					clone.Parent = parent
					local track = clone.AnimationController.Animator:LoadAnimation(clone.Animation)
					maid2:Add(function()
						track:Stop(0)
						track:Destroy()
					end)
					track.Looped = true
					local timePositions = {}
					maid2:Add(track:GetMarkerReachedSignal("Pin"):Connect(function(p)
						timePositions[p] = track.TimePosition
					end))
					maid2:Add(track:GetMarkerReachedSignal("GOTO"):Connect(function(p)
						local timePosition = timePositions[p]

						if timePosition then
							track.TimePosition = timePosition
						end
					end))
					track:Play()
				elseif emote == "Emote710" or name == "Emote710" then
					local clone = maid2:Clone(ReplicatedStorage2.Misc.PenguinEmote)
					clone.RootPart.Weld.Part0 = parent:FindFirstChild("HumanoidRootPart")
					clone:ScaleTo(character:GetScale() * 1.5)
					clone.Parent = parent
					local track = clone.AnimationController.Animator:LoadAnimation(clone.Animation)
					maid2:Add(function()
						track:Stop(0)
						track:Destroy()
					end)
					track.Looped = true
					local timePositions = {}
					maid2:Add(track:GetMarkerReachedSignal("Pin"):Connect(function(p)
						timePositions[p] = track.TimePosition
					end))
					maid2:Add(track:GetMarkerReachedSignal("GOTO"):Connect(function(p)
						local timePosition = timePositions[p]

						if timePosition then
							track.TimePosition = timePosition
						end
					end))
					track:Play()
				end

				local v28 = {}

				if type(idleAnimation) == "table" then
					for _, item in idleAnimation do
						table.insert(v28, (loadAnimationObject(item)))
					end
				else
					table.insert(v28, (loadAnimationObject(idleAnimation)))
				end

				local folder = Instance.new("Folder")
				maid2:Add(folder)
				folder.Name = "Emote_Storage"
				folder.Parent = parent
				local instance2

				if typeof(idleAnimation) == "Instance" then
					instance2 = v4:GetInstance(idleAnimation.Name)
				else
					instance2 = false
				end

				if instance2 then
					if instance2:GetAttribute("HideSword") then
						v26 = nil
					end

					maid2:Add(v2.Physics.RigModelToChar(instance2, parent, folder))
				end

				if v27 and v27.FX then
					v27.FX(parent, 1.5, maid2, sword)
				elseif emote then
					local v29 = v10[emote]

					if not v29 and v6:GetCollection()[emote] ~= nil then
						local instance3 = v6:GetInstance(emote)
						local VFX

						if instance3 and instance3:GetAttribute("Sword") == "Cherub" then
							VFX = instance3:FindFirstChild(v7.GetEmoteVFXVariant(parent)) or instance3
						else
							VFX = emote
						end

						v29 = {
							VFX = VFX,
							Emote = ReplicatedStorage2.Misc.Emotes[emote],
							Play = play
						}
					end

					if v29 then
						local folder2 = Instance.new("Folder")
						maid2:Add(folder2)
						folder2.Name = "EmoteVFX_Storage"
						folder2.Parent = parent
						parent:SetAttribute("EmoteScale", 1.5)
						parent:SetAttribute("CurrentEmote", emote)
						local v30 = v29.Play(v29, parent, true, v28)

						if v30 then
							maid2:Add(v30)
						end

						maid2:Add(function()
							parent:SetAttribute("CurrentEmote", nil)
							v29.Play(v29, parent, false, v28)
						end)
					end
				end
			end

			if v26 and scope.isCurrent(parent, v24) then
				addSwordToNPC(parent, v26, 1.5)
			end

			if slash and sword then
				local sword2 = v8:GetSword(sword)

				if sword2 and sword2.SlashName then
					parent:SetAttribute("ServerParryCount", (parent:GetAttribute("ServerParryCount") or 0) + 1)
					local v27 = pickProfileAnimation(sword, "idle")

					if v27 then
						local maid3 = maid2
						local track = loadAnimation(maid3:Add(createAnimationObject(v27.id))) -- equivalent call inferred; original call site unknown
						track.Looped = true
						track:Play()

						if v27.speed then
							track:AdjustSpeed(v27.speed)
						end
					else
						for _, v28 in v9:GetAnimations(parent, "Idle", sword2.AnimationType, sword2.SwordType) do
							(loadAnimation(v28)):Play()
						end
					end

					local v28 = { "Parry", "SuccessParry" }
					local successParryVariantCount = v9:GetSuccessParryVariantCount(
						parent,
						sword2.AnimationType,
						sword2.SwordType
					)

					if successParryVariantCount then
						v28[2] = `SuccessParry{(parent:GetAttribute("ServerParryCount") or 0) % successParryVariantCount + 1}`
					end

					local animations = v9:GetAnimations(parent, v28, sword2.AnimationType, sword2.SwordType)
					local v29 = table.create(#animations)

					for k, animation in animations do
						local track = loadAnimation(animation) -- equivalent call inferred; original call site unknown
						track.Looped = false
						v29[k] = track
					end

					for _, v30 in v29 do
						v30:Play(0)
					end

					ReplicatedStorage2.Remotes.ParrySuccessClient:Fire(
						v9:GetSlashName(sword, sword2.SlashName),
						parent.Torso,
						sword
					)
				end
			end
		end

		local thread = nil

		local function tryUpdateSword()
			if thread then
				return
			end

			thread = coroutine.running()
			task.wait()

			if thread == coroutine.running() then
				updateSword()
			end

			thread = nil
		end

		trove:Add(parent:GetAttributeChangedSignal("IsShown"):Connect(tryUpdateSword))
		trove:Add(parent:GetAttributeChangedSignal("IgnoreAccessory"):Connect(tryUpdateSword))
		trove:Add(parent:GetAttributeChangedSignal("Sword"):Connect(tryUpdateSword))
		trove:Add(parent:GetAttributeChangedSignal("Emote"):Connect(tryUpdateSword))
		trove:Add(parent:GetAttributeChangedSignal("Slash"):Connect(tryUpdateSword))
		trove:Add(parent:GetAttributeChangedSignal("ForceIdle"):Connect(tryUpdateSword))
		task.spawn(tryUpdateSword)
	end

	ensureInnerShowRoomBuilt = function(child)
		if v23[child] then
			return
		end

		v23[child] = true

		for _, child2 in child.NPCS:GetChildren() do
			task.spawn(createNPC, child2)
			table.insert(children, child2)
		end

		for _, child2 in child.HoloPads:GetChildren() do
			task.spawn(createHoloPad, child2)
			table.insert(children, child2)
		end
	end

	local function updateSelection()
		local mouseLocation = v:GetMouseLocation()
		local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local flag = false

		for _, v25 in children do
			if not v25:GetAttribute("InputStart") then
				continue
			end

			flag = true
			break
		end

		local v25

		if not flag then
			v25 = v2.Physics.Raycast(viewportPointToRay.Origin, viewportPointToRay.Direction, 100, {}, function(p)
				local instance2 = p.Instance

				if instance2.Name == "Selection" then
					return false
				end

				return instance2:IsA("BasePart") and (instance2.Transparency >= 1 or not instance2.CanCollide)
			end)
		end

		local instance2 = v25 and v25.Instance

		for _, v26 in children do
			local v28

			if instance2 then
				if instance2.Name == "Selection" then
					v28 = instance2.Parent == v26
				else
					v28 = false
				end
			else
				v28 = instance2
			end

			v26:SetAttribute("IsHovering", v28)
		end
	end

	trove:Add(v.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		updateSelection()

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonX then
			for _, v24 in children do
				if not (v24:GetAttribute("IsHovering") and v24.Parent.Name == "NPCS") then
					continue
				end

				v24:SetAttribute("InputStart", v:GetMouseLocation())
				return
			end
		end
	end))
	trove:Add(v.InputChanged:Connect(updateSelection))
	trove:Add(v.InputEnded:Connect(function(input, gameProcessed: boolean)
		local v24 = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonX
		local v25 = false

		if v24 then
			for _, v26 in children do
				if not v26:GetAttribute("InputStart") then
					continue
				end

				v26:SetAttribute("InputStart", nil)
				v25 = true
			end
		end

		updateSelection()

		if v24 and not (gameProcessed or v25) then
			for _, v26 in children do
				if not (v26:GetAttribute("IsHovering") and v26.Parent.Name == "HoloPads" and v26:GetAttribute("NPC")) then
					continue
				end

				local child = v26.Parent.Parent.NPCS:FindFirstChild(v26:GetAttribute("NPC"))

				if not child then
					continue
				end

				local sword = v26:GetAttribute("Sword")
				child:SetAttribute("IsShown", false)
				child:SetAttribute("IsShown", true)
				child:SetAttribute("Emote", nil)
				child:SetAttribute("Slash", nil)
				child:SetAttribute("IgnoreAccessory", v26:GetAttribute("RenderAccessoryOnly") == false)
				child:SetAttribute("Sword", sword)
			end
		end
	end))
	return {
		moveToShowRoom = moveToShowRoom,
		applyLayout = function()
			if v19 then
				applyHoloPadLayout(v19)
			end
		end
	}
end