local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Packages.Observers)
local v4 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v6 = require3(ReplicatedStorage2.Shared.CherubVariants)
local v7 = require3(ReplicatedStorage2.Shared.LTM)
local v8 = require3(ReplicatedStorage2.Packages.Net)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v10 = require3(ReplicatedStorage2.Shared.WeightRandom)
local remoteEvent = v8:RemoteEvent("ReplicateEmote")
local isStudio = RunService:IsStudio()
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local v11 = {
	Emote143 = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote144 = CFrame.new(0, 0, -4.5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote154 = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote160 = CFrame.new(0, 0, -6.5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote163 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote164 = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote175 = CFrame.new(0, 0, -7) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote179 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote180 = CFrame.new(0, 0, -7) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote245 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote267 = CFrame.identity,
	Emote229 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote302 = CFrame.new(0, 0, 6),
	Emote314 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote315 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote333 = CFrame.new(0, 0, -1),
	Emote329 = CFrame.new(0, 0, -0.5),
	Emote345 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote347 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote372 = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote373 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote374 = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote386 = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote395 = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote401 = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote409 = CFrame.new(0, 0, -6.5) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote423 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote429 = CFrame.new(0, 0, -6.8) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote430 = CFrame.new(0, 0, -4.1) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote441 = CFrame.new(0, 0, -3.1) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote446 = CFrame.new(0, 0, -3.74) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote467 = CFrame.new(-0.5, 0, -2.9) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote473 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote474 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote475 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote491 = CFrame.new(0, 0, -2.1) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote536 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote541 = CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote548 = CFrame.identity,
	Emote562 = CFrame.new(-4.4, 0, 0),
	Emote571 = CFrame.new(4, 0, 0),
	Emote572 = CFrame.new(4.37, 0, 0),
	Emote588 = CFrame.new(-0.01, 0, -3.46) * CFrame.Angles(-3.15, 0, -3.15),
	Emote606 = CFrame.new(0, 0, -3.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote607 = CFrame.new(0, 0, -3.3) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote618 = CFrame.new(0, 0, -3.25) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote620 = CFrame.new(0, 0, -3.36) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote623 = CFrame.new(0, 0, -9.14) * CFrame.Angles(0, 3.141592653589793, 0),
	Emote627 = CFrame.new(0, 0, -4.42) * CFrame.Angles(-3.15, 0, -3.15),
	Emote632 = CFrame.new(0, 0, -4.07),
	Emote633 = CFrame.new(-4.72, 0, 0.04),
	Emote649 = CFrame.new(0, 0, -3.32) * CFrame.Angles(-3.15, 0, -3.15),
	Emote651 = CFrame.new(0, 0.02, -3.32) * CFrame.Angles(-3.15, 0, -3.15),
	Emote664 = CFrame.new(0.26, 0, -2.64),
	Emote674 = CFrame.new(3.45, 0, 0.55) * CFrame.Angles(-0, -0.14, -0),
	Emote669 = CFrame.new(0, 0, -4.88) * CFrame.Angles(-3.15, 0, -3.15),
	Emote688 = CFrame.new(0, 0, -2.33),
	Emote692 = CFrame.new(-5.2, 0, 0),
	Emote859 = CFrame.new(0, 0, 0),
	Emote1160 = CFrame.new(-3, 0, 0),
	Emote994 = CFrame.new(0, 0, 0)
}
local customPlayEmotes = {}
local v13 = {
	"Emote108",
	"Emote225",
	"Emote300",
	"Emote301"
}
local v14 = {
	Emote180 = { "Campfire" },
	Emote245 = { "Table" }
}
local v15 = {
	Emote284 = {
		Emote284 = 30,
		Emote298 = 60,
		Emote299 = 10
	},
	Emote301 = {
		Emote300 = 50,
		Emote301 = 50
	}
}
local v16 = {
	"Emote38",
	"Emote145",
	"Emote149",
	"Emote153",
	"Emote180",
	"Emote220",
	"Emote230",
	"Emote234",
	"Emote243",
	"Emote244",
	"Emote248",
	"Emote252",
	"Emote259",
	"Emote260",
	"Emote261",
	"Emote273",
	"Emote233",
	"Emote279",
	"Emote283",
	"Emote281",
	"Emote286",
	"Emote294",
	"Emote295",
	"Emote306",
	"Emote304",
	"Emote305",
	"Emote303",
	"Emote307",
	"Emote308",
	"Emote311",
	"Emote312",
	"Emote313",
	"Emote322",
	"Emote327",
	"Emote332",
	"Emote336",
	"Emote337",
	"Emote338",
	"Emote326",
	"Emote350",
	"Emote354",
	"Emote349",
	"Emote348",
	"Emote351",
	"Emote352",
	"Emote353",
	"Emote355",
	"Emote358",
	"Emote359",
	"Emote360",
	"Emote367",
	"Emote366",
	"Emote369",
	"Emote370",
	"Emote371",
	"Emote385",
	"Emote417",
	"Emote416",
	"Emote405",
	"Emote400",
	"Emote421",
	"Emote422",
	"Emote433",
	"Emote437",
	"Emote458",
	"Emote461",
	"Emote462",
	"Emote476",
	"Emote477",
	"Emote485",
	"Emote499",
	"Emote503",
	"Emote603",
	"Emote549",
	"Emote665"
}
local v17 = {
	Emote526 = true,
	Emote541 = true,
	Emote548 = true,
	Emote562 = true,
	Emote571 = true,
	Emote607 = true,
	Emote618 = true,
	Emote623 = true,
	Emote627 = true,
	Emote632 = true
}

for k, v18 in require3(ReplicatedStorage2.Shared.Emotes) do
	local v19 = v18

	customPlayEmotes[k] = function(...)
		return v19.Play and v19.Play(v19, ...)
	end
end

for _, v18 in require3(ReplicatedStorage2.Shared.RNG.Emotes).List do
	local v19 = v18

	customPlayEmotes[v18.Emote.Name] = function(...)
		return v19.Play and v19.Play(v19, ...)
	end
end

local function fn(...)
	return nil
end

local function fn2(...)
	return nil
end

local function fn3(...)
	return nil
end

local function setupPart(p)
	p.CanCollide = false
	p.Anchored = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.Transparency = 1
end

local function ignoreAccessory(instance, childName: string)
	local child = ReplicatedStorage2.Misc.Emotes:FindFirstChild(childName)

	if child and child:GetAttribute("IsDuo") and isClient or childName == "Emote158" and instance:GetAttribute("CurrentlyEquippedSword") ~= "Crystal Scissors" then
		return true
	end

	if childName == "Emote812" and instance:GetAttribute("CurrentlyEquippedSword") == "Frostbound Lantern" and instance:GetAttribute("HasAccessoryEquipped") then
		return true
	end

	local formatted = `Using{childName}`
	local formatted2 = `{childName}Target`
	local v18 = fn2(instance, formatted, formatted2)

	if (childName == "Emote144" or childName == "Emote160" or childName == "Emote175" or childName == "Emote235" or childName == "Emote240" or childName == "Emote333" or childName == "Emote329" or childName == "Emote345" or childName == "Emote347" or childName == "Emote372" or childName == "Emote395" or childName == "Emote401" or childName == "Emote409" or childName == "Emote423" or childName == "Emote424" or childName == "Emote429" or childName == "Emote430" or childName == "Emote441" or childName == "Emote446" or childName == "Emote467" or childName == "Emote562" or childName == "Emote571" or childName == "Emote572" or childName == "Emote606" or childName == "Emote623" or childName == "Emote649" or childName == "Emote651" or childName == "Emote664" or childName == "Emote669" or childName == "Emote686" or childName == "Emote516") and v18 then
		return true
	end

	return false
end

local function addAccessory(p, p2)
	return v2.Physics.AddAccoutrementToChar(p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cloneAndWeld(parent, p, cframe: CFrame, instance, p2)
	return v2.Physics.CloneAndWeld(parent, p, cframe, p2, instance)
end

local EmotesShared = {
	CustomPlayEmotes = customPlayEmotes,
	GetPlayCallback = function(self, p)
		local fn4 = customPlayEmotes[p]

		if not fn4 then
			local instance = v4:GetInstance(p)
			fn4 = instance and function(p2, ...)
				local VFX = p

				if instance:GetAttribute("Sword") == "Cherub" then
					VFX = instance:FindFirstChild(v6.GetEmoteVFXVariant(p2)) or instance
				end

				return play({
					VFX = VFX,
					Emote = ReplicatedStorage2.Misc.Emotes[p],
					Play = play
				}, p2, ...)
			end or fn4
		end

		return fn4
	end,
	SetDuoEmote = function(_, p)
		fn = p
	end,
	SetGetNearestCharacterToDuo = function(_, p)
		fn2 = p
	end,
	SetPlayEmoteEffects = function(_, p)
		fn3 = p
	end,
	GetAnimationTrackForAnimator = function(self, animator, maid, instance)
		local child

		if typeof(instance) == "Instance" then
			child = instance
		else
			child = ReplicatedStorage2.Misc.Emotes:WaitForChild(instance, 5)
		end

		if child then
			local v18 = maid:Add(animator:LoadAnimation(child))
			v18.Looped = table.find(v13, child.Name) == nil
			local timePositions = {}
			maid:Add(v18:GetMarkerReachedSignal("Pin"):Connect(function(p: string)
				timePositions[p] = v18.TimePosition
			end))
			maid:Add(v18:GetMarkerReachedSignal("GOTO"):Connect(function(p: string)
				local timePosition = timePositions[p]

				if timePosition then
					v18.TimePosition = timePosition
				end
			end))
			return v18, maid
		elseif isStudio or v3.isTestGame() then
			warn((`Failed to find Animation for {instance}`))
		end
	end,
	SetupAccessories = function(self, instance, maid, p: string, flag: boolean, flag2: boolean?)
		if not (instance and instance:FindFirstChildWhichIsA("Humanoid")) then
			return false
		end

		local v18 = true
		maid:Add(function()
			v18 = false
		end)
		local emote_Storage = instance:FindFirstChild("Emote_Storage") or v2.Physics.Instance("Folder", {
			Name = "Emote_Storage"
		}, instance)
		emote_Storage:ClearAllChildren()
		local instance2 = v5:GetInstance(p)

		if not v18 then
			return false
		end

		if instance2 and flag and not ignoreAccessory(instance, p) and instance:GetAttribute("PassiveRNGEmote") ~= p then
			local clone = instance2:Clone()

			if clone:IsA("Model") then
				clone:ScaleTo(instance:GetScale())
			else
				v2.Physics.ResizePart(clone, instance:GetScale())
			end

			local v19 = v14[p]

			if v19 then
				local formatted = `Using{p}`
				local formatted2 = `{p}Target`

				if fn2(instance, formatted, formatted2) then
					for _, childName in v19 do
						local child = clone:FindFirstChild(childName)

						if child then
							child:Destroy()
						end
					end
				end
			end

			if flag2 then
				for _, v20 in clone:QueryDescendants("[$HideNPCLobby=true]") do
					v20:Destroy()
				end
			end

			maid:Add(v2.Physics.WeldModelToChar(clone, instance, emote_Storage))
		elseif isServer then
			instance:SetAttribute("EmoteIgnoreHide", true)
			maid:Add(function()
				instance:SetAttribute("EmoteIgnoreHide", nil)
			end)
		end

		return true
	end
}

function EmotesShared.Play(object, parent, instance, childName: string, flag: boolean, p: number, p2: number?, flag2: boolean?, flag3: boolean?)
	local humanoid = parent and parent:FindFirstChildWhichIsA("Humanoid")
	local primaryPart = parent and parent.PrimaryPart

	if not (humanoid and primaryPart) then
		return
	end

	local child = ReplicatedStorage2.Misc.Emotes:FindFirstChild(childName)
	local v18 = child and child:GetAttribute("IsDuo") and true or isClient

	if isServer then
		remoteEvent:FireAllClients(parent, childName, flag, p)
		local v20

		if flag then
			v20 = childName
		end

		parent:SetAttribute("CurrentEmote", v20)
		local v22

		if flag then
			v22 = p2
		end

		parent:SetAttribute("CurrentEmoteSerial", v22)
		local v24

		if flag then
			v24 = p
		end

		parent:SetAttribute("CurrentEmoteTime", v24)
	end

	if not v18 then
		return
	end

	local flag4 = true
	instance:Add(function()
		flag4 = false
	end)
	local parent2 = parent:FindFirstChild("Emote_Storage")

	if parent2 then
		parent2:ClearAllChildren()
	else
		parent2 = Instance.new("Folder")
		parent2.Name = "Emote_Storage"
		parent2.Parent = parent
	end

	local emoteVFX_Storage = parent:FindFirstChild("EmoteVFX_Storage")

	if emoteVFX_Storage then
		emoteVFX_Storage:ClearAllChildren()
	else
		local folder = Instance.new("Folder")
		folder.Name = "EmoteVFX_Storage"
		folder.Parent = parent
	end

	if not EmotesShared:SetupAccessories(parent, instance, childName, flag, flag3) then
		return
	end

	local animationTrackForAnimators = nil

	if isClient and flag and parent:GetAttribute("PassiveRNGEmote") ~= childName then
		local animator = humanoid:FindFirstChildWhichIsA("Animator") or humanoid
		local emote = ReplicatedStorage2.Misc.Emotes[childName]
		local v20 = { task.spawn(function()
				v4:GetInstance(childName)
			end), task.spawn(function()
				v5:GetInstance(childName)
			end), task.spawn(function()
				local v21 = childName
				local v22 = v15[childName]

				if v22 then
					v21 = v10.getPicker(v22, nil, nil, p)()
				end

				if emote.AnimationId == "rbxassetid://0" or emote.AnimationId == "rbxassetid://" or emote.AnimationId == "" then
					pcall(function()
						local animationTrackForAnimator = object:GetAnimationTrackForAnimator(animator, instance, v21)
						animationTrackForAnimators = animationTrackForAnimator and { animationTrackForAnimator } or nil
					end)
					return
				end

				pcall(function()
					local animationTrackForAnimator = object:GetAnimationTrackForAnimator(animator, instance, v21)
					animationTrackForAnimators = animationTrackForAnimator and { animationTrackForAnimator } or nil
				end)

				if not animationTrackForAnimators then
					return
				end

				if v21 == "Emote711" then
					local clone = instance:Clone(ReplicatedStorage2.Misc.PolarBearEmote)
					clone.RootPart.Weld.Part0 = parent:FindFirstChild("HumanoidRootPart")
					clone:ScaleTo(clone:GetScale() * parent:GetScale())
					clone.Parent = parent
					local animationTrackForAnimator = object:GetAnimationTrackForAnimator(
						clone.AnimationController.Animator,
						instance,
						clone.Animation
					)

					if animationTrackForAnimator then
						table.insert(animationTrackForAnimators, animationTrackForAnimator)
					end
				elseif v21 == "Emote710" then
					local clone = instance:Clone(ReplicatedStorage2.Misc.PenguinEmote)
					clone.RootPart.Weld.Part0 = parent:FindFirstChild("HumanoidRootPart")
					clone:ScaleTo(clone:GetScale() * parent:GetScale())
					clone.Parent = parent
					local animationTrackForAnimator = object:GetAnimationTrackForAnimator(
						clone.AnimationController.Animator,
						instance,
						clone.Animation
					)

					if animationTrackForAnimator then
						table.insert(animationTrackForAnimators, animationTrackForAnimator)
					end
				elseif v21 == "Emote1217" then
					for _, model in parent2:GetChildren() do
						if not model:IsA("Model") then
							continue
						end

						local animation = model:FindFirstChild("Animation")
						local animationController = model:FindFirstChild("AnimationController")
						local animator2 = animationController and animationController:FindFirstChild("Animator")

						if not (animation and animator2) then
							continue
						end

						local animationTrackForAnimator = object:GetAnimationTrackForAnimator(
							animator2,
							instance,
							animation
						)

						if animationTrackForAnimator then
							table.insert(animationTrackForAnimators, animationTrackForAnimator)
						end
					end
				end

				for _, v23 in animationTrackForAnimators do
					v23:Play(0, 0, 0)
				end

				local thread = coroutine.running()
				local flag5 = true
				local thread2 = task.delay(60, v2.Thread.SafeResume, thread)
				local thread3 = task.defer(function()
					while flag5 do
						local flag6 = true

						for _, v24 in animationTrackForAnimators do
							if not (v24.Length <= 0) then
								continue
							end

							flag6 = false
							break
						end

						if flag6 then
							v2.Thread.SafeResume(thread)
							break
						else
							task.wait()
						end
					end
				end)
				coroutine.yield()
				flag5 = false
				v2.Thread.SafeCancel(thread3)
				v2.Thread.SafeCancel(thread2)

				for _, v23 in animationTrackForAnimators do
					v23:Stop(0)
					v23.TimePosition = 0
				end
			end) }

		while #v20 > 0 do
			if coroutine.status(v20[1]) == "dead" then
				table.remove(v20, 1)
			end

			task.wait()
		end

		if flag4 then
			if animationTrackForAnimators then
				for _, v21 in animationTrackForAnimators do
					v21:Stop(0)
					v21.TimePosition = 0
					v21:Play()

					if table.find(v16, childName) then
						instance:Add(v21.DidLoop:Once(function()
							instance:Clean()
							EmotesShared:Play(parent, instance, childName, flag, p, p2)
						end))
					end

					if table.find(v13, childName) then
						instance:Add(v21.Stopped:Connect(function()
							instance:Clean()
						end))
					end

					local v22 = v21
					instance:Add(function()
						v22:Stop()
						v22:Destroy()
					end)
				end

				instance:Add(function()
					table.clear(animationTrackForAnimators)
					animationTrackForAnimators = nil
				end)
			end
		else
			if not animationTrackForAnimators then
				return
			end

			for _, v21 in animationTrackForAnimators do
				v21:Stop(0)
				v21:Destroy()
			end

			table.clear(animationTrackForAnimators)
			animationTrackForAnimators = nil
			return
		end
	end

	if childName == "Empyrean" or childName == "Menacing" or childName == "Emote8" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.MenacingSong)
			clone.Parent = primaryPart
			local songz = clone.songz
			local add = instance:Add(songz)
			add.Parent = clone.Parent
			local clone2 = instance:Clone(ReplicatedStorage2.Misc.menaSloings)
			clone2.Parent = primaryPart
			clone2:Emit(1)
			clone:AddTag("EmoteSFX")
			clone.Playing = true
			clone.TimePosition = 0.1
			songz:AddTag("EmoteSFX")
			songz:Play()
		end
	elseif childName == "Wavelight" or childName == "Emote9" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.MenacingSong)
			clone.Parent = primaryPart
			local songz = clone.songz
			local add_2 = instance:Add(songz)
			add_2.Parent = primaryPart
			local clone2 = instance:Clone(ReplicatedStorage2.Misc.WavelightMenace)
			clone2.Parent = primaryPart
			local add_3 = instance:Add(clone2.atata)
			add_3.Parent = parent.Head
			local add_4 = instance:Add(clone2.atata1)
			add_4.Parent = parent.Head
			local v20 = instance:Add(clone2.menaSloings)
			v20.Parent = primaryPart
			v20:Emit(1)
			clone:AddTag("EmoteSFX")
			clone.Playing = true
			clone.TimePosition = 0.1
			songz:AddTag("EmoteSFX")
			songz:Play()
		end
	elseif childName == "Emote18" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.Broom)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote22" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.Surfboard)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote25" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.ThaiFlag)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote30" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.Snowglobe)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote31" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.MakeItRain)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote98" then
		if flag then
			local firework = v4:GetInstance("Firework").Firework

			if not flag4 then
				return
			end

			local clone = instance:Clone(firework)
			clone.Parent = parent
			local motor6D = Instance.new("Motor6D")
			instance:Add(instance)
			motor6D.Part0 = parent:FindFirstChild("Left Arm")
			motor6D.Part1 = clone["Meshes/FireworkMisc_Plane.001"]
			motor6D.Name = "FireworkGrip"
			motor6D.Parent = clone
		end
	elseif childName == "Emote26" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.Crown)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote27" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.Crown)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
			local clone2 = instance:Clone(ReplicatedStorage2.Misc.VIPText)
			v2.Physics.AddAccoutrementToChar(humanoid, clone2)
		end
	elseif childName == "Emote28" then
		if flag then
			local clone = instance:Clone(ReplicatedStorage2.Misc.TurkeyLeg)
			v2.Physics.AddAccoutrementToChar(humanoid, clone)
		end
	elseif childName == "Emote35" then
		if flag then
			local instance2 = v4:GetInstance("SerpentsAura")

			if not flag4 then
				return
			end

			for _, child2 in instance2:GetChildren() do
				local child3 = parent:FindFirstChild(child2.Name)

				if not child3 then
					continue
				end

				for _, child4 in child2:GetChildren() do
					local clone = instance:Clone(child4)
					clone.Parent = child3

					if clone.Name ~= "rotate" then
						continue
					end

					local v20 = clone
					local parent3 = child3
					instance:Add(task.delay(0.1, function()
						while v20 and v20.Parent == parent3 and v20:IsDescendantOf(workspace) do
							v20.CFrame *= CFrame.Angles(0, 0.08726646259971647, 0)
							task.wait(0.1)
						end
					end))
				end
			end
		end
	elseif childName == "Emote78" or childName == "Emote79" then
		local v20 = childName == "Emote79"
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local leftArm = parent:FindFirstChild("Left Arm")
		local rightArm = parent:FindFirstChild("Right Arm")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and leftArm and rightArm and torso) then
			return
		end

		local instance2 = v4:GetInstance("Prismatic")

		if not flag4 then
			return
		end

		local child2 = parent2:FindFirstChild((`Anim_{childName}`))

		if flag then
			local clone = instance:Clone(instance2.Part)
			clone.Name = `{childName}_Hole`
			clone:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(0, 3.13, 0))
			local weldConstraint = Instance.new("WeldConstraint")
			instance:Add(weldConstraint)
			weldConstraint.Part0 = clone
			weldConstraint.Part1 = humanoidRootPart
			weldConstraint.Parent = clone
			clone.Parent = parent2

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone2 = instance:Clone(instance2.SlashEmit)
			clone2.Name = `{childName}_SlashEmit`
			clone2:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(-0.39, 0.82, -1.89))
			local weldConstraint2 = Instance.new("WeldConstraint")
			instance:Add(weldConstraint2)
			weldConstraint2.Part0 = clone2
			weldConstraint2.Part1 = humanoidRootPart
			weldConstraint2.Parent = clone2
			clone2.Parent = parent2

			if child2 then
				child2.Parent = nil
			end

			instance:Add(task.delay(3.75, function()
				child2.Parent = parent2
			end))
			instance:Add(task.delay(4, function()
				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end))
			instance:Add(task.delay(v20 and 5.166666666666667 or 4.583333333333333, function()
				v2.Visual:PlayEffects(clone2)
			end))
		end
	elseif childName == "Emote103" or childName == "Emote104" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local leftArm = parent:FindFirstChild("Left Arm")
		local rightArm = parent:FindFirstChild("Right Arm")
		local torso = parent:FindFirstChild("Torso")

		if not (leftArm and rightArm and torso) then
			return
		end

		local instance2 = v4:GetInstance("AetherialAzure")

		if not flag4 then
			return
		end

		if flag then
			local v20 = cloneAndWeld(
				parent,
				instance2.TorsoEmit,
				CFrame.new(0, -3.85, -0.7),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local v21 = cloneAndWeld(
				parent,
				instance2.TorsoEmit1,
				CFrame.new(0, -3.85, -0.7),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v21.Parent = parent2
			local v22 = cloneAndWeld(
				parent,
				instance2.TorsoEmit2,
				CFrame.new(-0.4, -0.55, -1.9),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v22.Parent = parent2
			local v23 = cloneAndWeld(
				parent,
				instance2.TorsoEmit3,
				CFrame.new(-0.4, -0.55, -1.9),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v23.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.TorsoEmit4,
				CFrame.new(-0.4, -0.55, -1.9),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			local v24 = cloneAndWeld(
				parent,
				instance2.LeftHandEmit,
				CFrame.new(-0.4, 0.55, -1.9),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v24.Parent = parent2
			instance:Add(task.delay(0.23333333333333334, function()
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(1.15, function()
				v2.Visual:PlayEffects(v21)
			end))
			instance:Add(task.delay(2.183333333333333, function()
				v2.Visual:PlayEffects(v24)
			end))
			instance:Add(task.delay(2.6333333333333333, function()
				v2.Visual:PlayEffects(v22)
			end))
			instance:Add(task.delay(3.45, function()
				v2.Visual:PlayEffects(v23)
			end))
			instance:Add(task.delay(4.983333333333333, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
		end
	elseif childName == "Emote108" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local leftArm = parent:FindFirstChild("Left Arm")
		local rightArm = parent:FindFirstChild("Right Arm")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and leftArm and rightArm and torso) then
			return
		end

		local instance2 = v4:GetInstance("Firesmash")

		if not flag4 then
			return
		end

		if flag then
			for _, v20 in { leftArm, rightArm } do
				local child2 = v20:FindFirstChild(v20 == rightArm and "RightGripAttachment" or "LeftGripAttachment")

				if not child2 then
					continue
				end

				local clone = instance:Clone(instance2.ArmFire)
				clone:PivotTo(child2.WorldCFrame)
				clone.Parent = parent2
				local v21 = instance:Add(Instance.new("WeldConstraint"))
				v21.Part0 = clone
				v21.Part1 = v20
				v21.Parent = clone
				local clone_2 = instance:Clone(instance2.ArmTrail.Attachment)
				clone_2.Parent = v20
			end

			local clone = instance:Clone(instance2.Ground)
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3, 0))
			clone.Parent = parent2
			local v20 = instance:Add(Instance.new("WeldConstraint"))
			v20.Part0 = clone
			v20.Part1 = humanoidRootPart
			v20.Parent = clone
			local flag5 = true
			instance:Add(function()
				flag5 = false
			end)
			instance:Add(task.spawn(function()
				while flag5 do
					task.wait(0.633)
					v2.Visual:PlayEffects(clone)
					task.wait(0.516)
				end
			end))
		end
	elseif childName == "Emote114" then
		local torso = parent:FindFirstChild("Torso")
		local rightArm = parent:FindFirstChild("Right Arm")
		local leftArm = parent:FindFirstChild("Left Arm")

		if not (rightArm and leftArm and torso) then
			return
		end

		local instance2 = v4:GetInstance("Dual Crystal Reaperblade")

		if not flag4 then
			return
		end

		if flag then
			local v21 = cloneAndWeld(
				parent,
				instance2.ScytheEmit,
				CFrame.new(-1.17, -0.21, -1.39) * CFrame.Angles(1.5707963267948966, 0, 0),
				instance,
				rightArm
			) -- equivalent call inferred; original call site unknown
			v21.Parent = parent2
			local v23 = cloneAndWeld(
				parent,
				instance2.ScytheEmit1,
				CFrame.new(-1.17, -0.21, -1.39) * CFrame.Angles(1.5707963267948966, 0, 0),
				instance,
				leftArm
			) -- equivalent call inferred; original call site unknown
			v23.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.ScytheEnable,
				CFrame.new(-1.17, -0.21, -1.39) * CFrame.Angles(1.5707963267948966, 0, 0),
				instance,
				rightArm
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			local folder2 = cloneAndWeld(
				parent,
				instance2.ScytheEnable1,
				CFrame.new(-1.17, -0.21, -1.39) * CFrame.Angles(1.5707963267948966, 0, 0),
				instance,
				leftArm
			) -- equivalent call inferred; original call site unknown
			folder2.Parent = parent2
			local folder3 = cloneAndWeld(parent, instance2.ScytheIdle, CFrame.new(0, 0.1, -0.4), instance, torso) -- equivalent call inferred; original call site unknown
			folder3.Parent = parent2
			v2.Visual:PlayEffects(v21)
			instance:Add(task.delay(0.1, function()
				v2.Visual:PlayEffects(v21)
				v2.Visual:PlayEffects(v23)
			end))
			instance:Add(task.delay(0.43333333333333335, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in folder2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
			instance:Add(task.delay(1.5, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in folder2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end))
			instance:Add(task.delay(1.5, function()
				for _, emitter in folder3:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
		end
	elseif childName == "Emote118" then
		local child2 = parent2

		if child2 then
			child2 = parent2:FindFirstChild((`Anim_{childName}`))
		end

		if flag then
			instance:Add(task.delay(1.15, function()
				local patchofsalt = child2:FindFirstChild("Patch of salt")

				if patchofsalt then
					patchofsalt:AddTag("PatchOfSalt")
				end
			end))
		end
	elseif childName == "Emote122" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local instance2 = v4:GetInstance("Nightfall Violin")

		if not flag4 then
			return
		end

		if flag then
			local v20 = cloneAndWeld(
				parent,
				instance2.FloorAttachEmit,
				CFrame.new(0, -3, -0.4),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local v21 = cloneAndWeld(
				parent,
				instance2.BodyEmit,
				CFrame.new(-0.13, -0.49, -0.38),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v21.Parent = parent2
			local v22 = cloneAndWeld(
				parent,
				instance2.BodyEmit1,
				CFrame.new(-0.13, -0.49, -0.38),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v22.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.BodyEmit2,
				CFrame.new(-0.13, -0.49, -0.38),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			instance:Add(task.delay(0.4166666666666667, function()
				if v20.Parent then
					v2.Visual:PlayEffects(v20)
				end
			end))
			instance:Add(task.delay(2.0166666666666666, function()
				if v21.Parent then
					v2.Visual:PlayEffects(v21)
				end
			end))
			instance:Add(task.delay(2.816666666666667, function()
				if v22.Parent then
					v2.Visual:PlayEffects(v22)
				end
			end))
			instance:Add(task.delay(4, function()
				if folder.Parent then
					for _, emitter in folder:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			end))
		end
	elseif childName == "Emote136" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("Lotus")

			if not flag4 then
				return
			end

			local lotus = instance2.Lotus
			local v20 = math.random(5, 6)
			local random = Random.new()
			instance:Add(task.delay(0.6, function()
				if not humanoidRootPart then
					return
				end

				local cFrame = humanoidRootPart.CFrame
				local v21 = cFrame.Position.Y - 2.5

				for i = 1, v20 do
					local v22 = instance:Add(lotus:Clone())
					local cframe = CFrame.Angles(
						0,
						random:NextNumber(0, 6.283185307179586),
						(math.rad((random:NextNumber(-10, 10))))
					)
					local number = random:NextNumber(0, 6.283185307179586)
					local v23 = 6.25 / i * math.sqrt((math.random())) * i + 1.25
					local v24 = v23 * math.cos(number)
					local v25 = v23 * math.sin(number)
					local v26 = cFrame.Position * createVector(1, 0, 1) + Vector3.new(v24, v21, v25) + cFrame.LookVector * 5
					local v27 = CFrame.new(v26) * cframe
					local v28 = v22.Size * random:NextNumber(0.8, 1.5)
					v22.Size = createVector(0, 0, 0)
					v22:SetAttribute("TargetSize", v28)
					v22:SetAttribute("TargetCFrame", v27)
					v22.CFrame = v27 + Vector3.new(0, -v28.Y / 2, 0)
					v22.Anchored = true
					v22.Parent = parent2
					fn3("All", "LotusGrow", v22)
					task.wait(random:NextNumber(1, 1.25))
				end
			end))
		end
	elseif childName == "Emote142" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("CupidsBow")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(
				parent,
				instance2.FloorAttachEmit,
				CFrame.new(-0.041015625, -3.3450725078582764, -2.3984375),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local v21 = cloneAndWeld(
				parent,
				instance2.WeaponEmit,
				CFrame.new(-0.13104248046875, 0.8849272727966309, -3.1033935546875),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v21.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.BodyEmit,
				CFrame.new(0, -0.05, 1.75) * CFrame.Angles(0, 1.9634954084936207, 0),
				instance,
				torso
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			instance:Add(task.delay(0.5, function()
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(2.216666666666667, function()
				v2.Visual:PlayEffects(v21)
			end))
			instance:Add(task.delay(2.25, function()
				local clone = instance:Clone(ReplicatedStorage2.Misc.CupidBowHit)
				clone.Parent = humanoidRootPart
				clone:AddTag("EmoteSFX")
				clone:Play()
			end))
			instance:Add(task.delay(3.0833333333333335, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local clone = instance:Clone(ReplicatedStorage2.Misc.CupidBowHeart)
				clone.Parent = humanoidRootPart
				clone:AddTag("EmoteSFX")
				clone:Play()
			end))
		end
	elseif childName == "Emote149" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("Eruption")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(
				parent,
				instance2.FloorQuackEmit,
				CFrame.new(0, -2.91, 0),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.FloorQuackEnable,
				CFrame.new(0, -2.91, 0),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
					descendant.Enabled = true
				end
			end

			instance:Add(task.delay(3.0166666666666666, function()
				v20.EmitLight.Enabled = true
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(3, function()
				for _, descendant in folder:GetDescendants() do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end))
		end
	elseif childName == "Emote153" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("Dual Shadow Mirage")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(
				parent,
				instance2.BodyEmit,
				CFrame.new(0.13, -0.135, 0.3),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.DarkEnable,
				CFrame.new(-6, 0.9, -0.57),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			local folder2 = cloneAndWeld(
				parent,
				instance2.DarkEnable1,
				CFrame.new(6.95, 0.67, -0.57),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder2.Parent = parent2
			local folder3 = cloneAndWeld(
				parent,
				instance2.DarkEnable2,
				CFrame.new(0, 0.15, -0.57),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder3.Parent = parent2
			instance:Add(task.delay(0.016666666666666666, function()
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(0.7666666666666667, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in folder2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
			instance:Add(task.delay(2.05, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in folder2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end))
			instance:Add(task.delay(3.4166666666666665, function()
				local clone = instance:Clone(ReplicatedStorage2.Misc.DualMirage)
				clone.Parent = humanoidRootPart
				clone:AddTag("EmoteSFX")
				clone:Play()
			end))
			instance:Add(task.delay(3.5, function()
				for i = 1, 2 do
					local clone = instance:Clone(instance2["FireballEnable" .. i])

					for _, emitter in clone:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					clone:SetAttribute("Velocity", 2)
					clone:SetAttribute("Radius", 8)
					clone:SetAttribute("FireballIndex", i)
					clone:SetAttribute("TotalFireballs", 2)
					clone:SetAttribute("Angle", 3.141592653589793 * i)
					local v21 = instance:Add(Instance.new("ObjectValue"))
					v21.Name = "FireballTarget"
					v21.Value = humanoidRootPart
					v21.Parent = clone
					clone.CFrame = humanoidRootPart:GetPivot()
					clone.Parent = workspace.Runtime
					fn3("All", "MirageFireballs", clone)
				end
			end))
			instance:Add(task.delay(3.7666666666666666, function()
				for _, emitter in folder3:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
		end
	elseif childName == "Emote158" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("Crystal Scissors")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(
				parent,
				instance2.EmotePart,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local v21 = cloneAndWeld(
				parent,
				instance2.EmotePart1,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v21.Parent = parent2
			local v22 = cloneAndWeld(
				parent,
				instance2.EmotePart2,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v22.Parent = parent2
			local v23 = cloneAndWeld(
				parent,
				instance2.EmotePart3,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v23.Parent = parent2
			local v24 = cloneAndWeld(
				parent,
				instance2.FloorEmit,
				CFrame.new(-0.25, -2.99, -5.27),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v24.Parent = parent2
			local v25 = cloneAndWeld(
				parent,
				instance2.EmotePart4,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v25.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.EmotePart5,
				CFrame.new(0, -0.33, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			instance:Add(task.delay(0.38333333333333336, function()
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(0.7666666666666667, function()
				v2.Visual:PlayEffects(v21)
			end))
			instance:Add(task.delay(1.0666666666666667, function()
				v2.Visual:PlayEffects(v22)
			end))
			instance:Add(task.delay(2.066666666666667, function()
				v2.Visual:PlayEffects(v23)
			end))
			instance:Add(task.delay(2.066666666666667, function()
				v2.Visual:PlayEffects(v24)
			end))
			instance:Add(task.delay(3.2666666666666666, function()
				v2.Visual:PlayEffects(v25)
			end))
			instance:Add(task.delay(4.85, function()
				folder.loop:AddTag("EmoteSFX")
				folder.loop:Play()

				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
		end
	elseif childName == "Emote159" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local meshescrown = parent2:WaitForChild("Meshes/crown", 2)

			if not meshescrown then
				return
			end

			local instance2 = v4:GetInstance("WinFlex")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(parent, instance2.EmotePart, CFrame.new(0, 0, 0), instance, meshescrown) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local folder = cloneAndWeld(
				parent,
				instance2.EmotePart2,
				CFrame.new(0, 3.36, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			instance:Add(task.delay(2, function()
				v2.Visual:PlayEffects(v20)
			end))
			instance:Add(task.delay(3.3333333333333335, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
				fn3(
					"All",
					"WinFlex",
					folder.Flare.Billboard.InfoBillboard,
					playerFromCharacter and playerFromCharacter:GetAttribute("PlayerWins") or 0
				)
			end))
		end
	elseif childName == "Emote653" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("KillCollector")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(
				parent,
				instance2.EmotePart2,
				CFrame.new(0, 3.36, -0.05),
				instance,
				humanoidRootPart
			) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			instance:Add(task.delay(3.3333333333333335, function()
				local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
				fn3(
					"All",
					"KillCollector",
					v20.Flare.Billboard.InfoBillboard,
					playerFromCharacter and playerFromCharacter:GetAttribute("PlayerElims") or 0
				)
			end))
		end
	elseif childName == "Emote161" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			local instance2 = v4:GetInstance("Void Scythe")

			if not flag4 then
				return
			end

			local v20 = cloneAndWeld(parent, instance2.BodyEmit, CFrame.new(0, 3.85, 0), instance, humanoidRootPart) -- equivalent call inferred; original call site unknown
			v20.Parent = parent2
			local folder = cloneAndWeld(parent, instance2.BodyEmit2, CFrame.new(0, 3.85, 0), instance, humanoidRootPart) -- equivalent call inferred; original call site unknown
			folder.Parent = parent2
			instance:Add(task.delay(1.6, function()
				v2.Visual:PlayEffects(v20)
				local clone = instance:Clone(ReplicatedStorage2.Misc.VoidScythesLoop)
				clone.Parent = humanoidRootPart
				clone:AddTag("EmoteSFX")
				clone:Play()
			end))
			instance:Add(task.delay(1.8, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end))
			instance:Add(task.delay(0, function()
				local clone = instance:Clone(ReplicatedStorage2.Misc.VoidScythes)
				clone.Parent = humanoidRootPart
				clone:AddTag("EmoteSFX")
				clone:Play()
			end))
		end
	elseif childName == "Emote162" then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
		local torso = parent:FindFirstChild("Torso")

		if not (humanoidRootPart and torso) then
			return
		end

		if flag then
			if math.abs(workspace:GetServerTimeNow() - p) > 2 then
				return
			end

			local v20 = instance:Add(Instance.new("Folder"))
			v20.Parent = parent2
			fn3("All", childName, v20, parent, p)
		end
	elseif child and child:GetAttribute("IsDuo") then
		local currentLTM = v7.getCurrentLTM()

		if v3.isLTMServer() and currentLTM and currentLTM.getGameMode() == "Flying" or workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal" then
			return
		else
			fn(parent, instance, childName, flag, childName, v11[childName] or CFrame.identity, v17[childName])
		end
	else
		local playCallback = object:GetPlayCallback(childName)

		if playCallback then
			local v20 = playCallback(parent, flag, animationTrackForAnimators, flag2, p)

			if v20 then
				instance:Add(v20)
			end
		end
	end

	if parent:GetAttribute("PassiveRNGEmote") ~= childName then
		parent:SetAttribute("PassiveRNGEmote", nil)
	end

	return animationTrackForAnimators
end

if not isClient then
	return EmotesShared
end

local v18 = {}

local function getTroveFromCharacter(instance)
	local v19 = v18[instance]

	if v19 then
		return v19
	end

	local v20 = v.new()
	v18[instance] = v20
	instance.Destroying:Connect(function()
		v18[instance] = nil
		v20:Destroy()
	end)
	return v20
end

local function playEmoteFor(instance, p: string, flag: boolean, p2: number, p3: number?)
	local v19 = v18[instance]

	if not v19 then
		v19 = v.new()
		v18[instance] = v19
		instance.Destroying:Connect(function()
			v18[instance] = nil
			v19:Destroy()
		end)
	end

	v19:Destroy()
	EmotesShared:Play(instance, v19, p, flag, p2, p3)
end

for _, v19 in Players:GetPlayers() do
	local character = v19.Character
	local currentEmote

	if character then
		currentEmote = character:GetAttribute("CurrentEmote")
	end

	if currentEmote then
		task.spawn(
			playEmoteFor,
			character,
			currentEmote,
			true,
			character:GetAttribute("CurrentEmoteTime") or workspace:GetServerTimeNow(),
			character:GetAttribute("CurrentEmoteSerial")
		)
	end
end

remoteEvent.OnClientEvent:Connect(playEmoteFor)
return EmotesShared