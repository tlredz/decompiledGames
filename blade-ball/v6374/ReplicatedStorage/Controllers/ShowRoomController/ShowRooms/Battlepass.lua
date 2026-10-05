local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GamepadService")
game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(script.Parent.Parent.ShowRoomUtility)
require3(script.Parent.Templates.ShowRoom3D)
require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v4 = require3(ReplicatedStorage2.Shared.SwordAPI)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v6 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
return {
	Template = ReplicatedStorage2.Misc.ShowRooms.Battlepass,
	AfterInit = function(data)
		local instance = data.Instance
		local trove = data.Trove
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

		local v7 = {}
		local showRoom = instance.ShowRoom
		showRoom.Parent = nil
		local NPC = instance.NPC
		NPC.Parent = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function createShowRoom(i, clone)
			clone.Parent = instance
			local trove2 = v.new()
			trove:Add(trove2)
			v7[i] = {
				Trove = trove2,
				Object = clone,
				Current = nil
			}
		end

		local pivot = showRoom:GetPivot()
		local extentsSize = showRoom:GetExtentsSize()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getShowRoomPosition(p: number)
			return pivot * CFrame.new(extentsSize.X * (p - 1), 0, 0)
		end

		local pivot2 = instance.Model.Bg:GetPivot()
		local extentsSize2 = showRoom:GetExtentsSize()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getBgPosition(p: number)
			return pivot2 * CFrame.new(-extentsSize2.X * (p - 1), 0, 0)
		end

		local function createReward(parent, p)
			local maid = v.new()

			if p.Type ~= "Sword" and p.Type ~= "Emote" then
				return maid
			end

			local sword = v6:GetSword(p.Value)
			local clone = maid:Clone(NPC)
			clone:PivotTo(parent:GetPivot())
			clone.Parent = parent
			pcall(function()
				clone.Humanoid:ApplyDescription(appliedDescription)
			end)

			if sword then
				v6:EquipSwordTo(clone, p.Value)
			end

			clone:ScaleTo(2)
			local animator = clone.Humanoid.Animator

			if p.Type == "Sword" then
				if not sword then
					return maid
				end

				for _, animation in v4:GetAnimations(clone, "Idle", sword.AnimationType, sword.SwordType) do
					local track = animator:LoadAnimation(animation)
					maid:Add(function()
						track:Stop()
						track:Destroy()
					end)
					track:Play()
				end

				local animations = v4:GetAnimations(clone, { "Parry" }, sword.AnimationType, sword.SwordType)
				local animations2 = v4:GetAnimations(clone, { "GrabParry" }, sword.AnimationType, sword.SwordType)
				local animations3 = v4:GetAnimations(clone, { "SuccessParry" }, sword.AnimationType, sword.SwordType)

				if #animations2 > 0 or #animations3 > 0 then
					local tracks = table.create(#animations2)

					for k, animation in animations2 do
						local track = animator:LoadAnimation(animation)
						maid:Add(function()
							track:Stop()
							track:Destroy()
						end)
						track.Looped = false
						tracks[k] = track
					end

					local tracks2 = table.create(#animations3)

					for k, animation in animations3 do
						local track = animator:LoadAnimation(animation)
						maid:Add(function()
							track:Stop()
							track:Destroy()
						end)
						track.Looped = false
						tracks2[k] = track
					end

					local flag = true
					maid:Add(function()
						flag = false
					end)
					maid:Add(task.spawn(function()
						while flag do
							local v8 = 0

							for _, v9 in tracks do
								v9:Play()
								v8 = math.max(v8, v9.Length)
							end

							task.wait(v8 * 0.75)

							if not flag then
								break
							end

							local v9 = 0

							for _, v10 in tracks2 do
								v10:Play()
								v9 = math.max(v9, v10.Length)
							end

							task.wait(v9)

							if not flag then
								break
							end
						end
					end))
					return maid
				else
					local tracks = table.create(#animations)

					for k, animation in animations do
						local track = animator:LoadAnimation(animation)
						maid:Add(function()
							track:Stop()
							track:Destroy()
						end)
						track.Looped = false
						tracks[k] = track
					end

					local flag = true
					maid:Add(function()
						flag = false
					end)
					maid:Add(task.spawn(function()
						while flag do
							local v8 = 0

							for _, v9 in tracks do
								v9:Play()
								v8 = math.max(v8, v9.Length)
							end

							task.wait(v8)

							if not flag then
								break
							end
						end
					end))
					return maid
				end
			else
				local child = p.Type == "Emote" and ReplicatedStorage2.Misc.Emotes:FindFirstChild(p.Value)

				if not child then
					return maid
				end

				local track = animator:LoadAnimation(child)
				maid:Add(function()
					track:Stop()
					track:Destroy()
				end)
				track.Looped = true
				track:Play()
				local timePositions = {}
				maid:Add(track:GetMarkerReachedSignal("Pin"):Connect(function(p2)
					timePositions[p2] = track.TimePosition
				end))
				maid:Add(track:GetMarkerReachedSignal("GOTO"):Connect(function(p2)
					track.TimePosition = timePositions[p2]
				end))
				local instance2 = v5:GetInstance(p.Value)

				if instance2 then
					local v8 = maid:Add(Instance.new("Folder"))
					v8.Parent = clone
					maid:Add(v2.Physics.WeldModelToChar(instance2, clone, v8))
				end

				return maid
			end
		end

		local v8 = nil
		trove:Extend()

		function data.Info.Render(p: number, list)
			if list ~= v8 then
				for _, v9 in v7 do
					v9.Object:Destroy()
					v9.Trove:Destroy()
				end

				table.clear(v7)

				for i = 0, #list do
					createShowRoom(i, showRoom:Clone()) -- equivalent call inferred; original call site unknown
					v7[i].Current = i
					v7[i].Object:PivotTo(getShowRoomPosition(i))
				end

				v8 = list
			end

			local v9 = nil

			for _, v11 in v7 do
				if v11.Current ~= p then
					continue
				end

				v9 = v11
				break
			end

			if not v9 then
				print("Failed to find rendered ShowRoom", v7)
				return
			end

			currentCamera.CFrame = v3:GetCameraCFrameFor(currentCamera, v9.Object)
			instance.Model.Bg.CFrame = getBgPosition(p)
			local v11 = list[p]

			if v11 and not v9.Rendered then
				v9.Rendered = true
				v9.Trove:Add(function()
					v9.Rendered = nil
				end)
				local free = v11.Free
				local premium = v11.Premium

				if free and premium then
					v9.Trove:Add((createReward(v9.Object["2"]["1"], free)))
					v9.Trove:Add((createReward(v9.Object["2"]["2"], premium)))
				elseif free or premium then
					v9.Trove:Add((createReward(v9.Object["1"]["1"], free or premium)))
				end
			end
		end
	end
}