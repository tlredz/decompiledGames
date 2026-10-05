local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Trove = require(ReplicatedStorage.Packages.Trove)
local AttributeAPI = require(ReplicatedStorage.Packages.AttributeAPI)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals = require(ReplicatedStorage.Shared.Animals)
local EggScale = require(ReplicatedStorage.Shared.EggScale)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local _ = Players.LocalPlayer
local StealController = {
	StartDroppedBrainrotRendering = function(_)
		WorldBrainrotController:RenderPool({
			PoolId = "Steal/DroppedBrainrots",
			ReplicatorId = "Steal/DroppedBrainrots",
			ShowTimer = false,
			ShowDropButton = false,
			GrabHoldDuration = 2,
			GrabMaxDistance = 10
		})
	end,
	StartGrabbedBrainrotRendering = function(_)
		local animalOverhead = ReplicatedStorage.Overheads.AnimalOverhead
		local v

		if ServerData.IsJumpLTMServer() then
			v = ReplicatorClient.get("JumpLTM/Eggs")
		else
			v = nil
		end

		Observers.observeTag("ClientRenderBrainrot", function(part)
			local maid = Trove.new()
			local v2 = maid:Add(AttributeAPI.container(part))
			local v3 = nil
			local maid2 = maid:Extend()

			local function attachDespawnTimer(clone)
				if not v then
					return
				end

				local v4 = v
				local v5 = nil

				for _, v7 in part:GetTags() do
					local v8 = string.match(v7, "^Held_(%d+)$")

					if not v8 then
						continue
					end

					v5 = tonumber(v8)
					break
				end

				if not v5 then
					return
				end

				local stolen = clone:FindFirstChild("Stolen")

				if stolen and stolen:IsA("TextLabel") then
					local function findEntryId()
						local v7 = v4:TryIndex({ "brainrots" })

						if type(v7) ~= "table" then
							return nil
						end

						for k, v8 in v7 do
							if type(v8) == "table" and v8.grabbed == v5 then
								return k
							end
						end

						return nil
					end

					maid2:Add(task.spawn(function()
						local entryId = findEntryId()
						local v7 = os.clock() + 5

						while not entryId and os.clock() < v7 do
							task.wait(0.25)
							entryId = findEntryId()
						end

						if not entryId then
							return
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function update()
							local v8 = v4:TryIndex({ "brainrots", entryId, "despawnTimer" })

							if type(v8) == "number" then
								stolen.Text = `{v8}s`
								stolen.Visible = true
							end
						end

						maid2:Add(v4:Listen({ "brainrots", entryId, "despawnTimer" }, update))
						update() -- equivalent call inferred; original call site unknown
					end))
				end
			end

			local function renderOverhead()
				maid2:Clean()

				if not (v3 and v2:GetAttribute("__render_overhead")) then
					return
				end

				local OVERHEAD_ATTACHMENT = v3:FindFirstChild("OVERHEAD_ATTACHMENT", true)

				if not OVERHEAD_ATTACHMENT then
					OVERHEAD_ATTACHMENT = maid2:Add(Instance.new("Attachment"))
					local extentsSize = v3:GetExtentsSize()
					OVERHEAD_ATTACHMENT.CFrame = CFrame.new(0, extentsSize.Y * 0.5, 0)
					OVERHEAD_ATTACHMENT.Parent = v3.PrimaryPart
				end

				local clone = maid2:Clone(animalOverhead)
				local __render_stolen = v2:GetAttribute("__render_stolen")

				if __render_stolen ~= nil then
					for _, label in clone:GetChildren() do
						if not label:IsA("TextLabel") then
							continue
						end

						if label.Name == "Stolen" then
							label.Visible = __render_stolen
						else
							label.Visible = false
						end
					end
				end

				if v then
					local __render_traits = v2:GetAttribute("__render_traits")
					local v4

					if not (__render_traits == nil or __render_traits == "") then
						v4 = string.split(__render_traits, "|")
					end

					AnimalOverheadController:PopulateTraits(clone, v4, maid2)
				end

				attachDespawnTimer(clone)
				clone.Parent = OVERHEAD_ATTACHMENT
			end

			local maid3 = maid:Extend()
			local v4 = nil

			local function renderBrainrot()
				maid3:Clean()
				local v5 = {}
				v4 = v5
				local __render_brainrot = v2:GetAttribute("__render_brainrot")

				if not __render_brainrot then
					return
				end

				local __render_animation = v2:GetAttribute("__render_animation")

				if not __render_animation then
					return
				end

				local __render_mutation = v2:GetAttribute("__render_mutation")
				local __render_traits = v2:GetAttribute("__render_traits")
				local v6 = (__render_traits == nil or __render_traits == "") and {} or string.split(
					__render_traits,
					"|"
				)
				local animatedModel = Animals:GetAnimatedModel(__render_brainrot, __render_animation)

				if v4 == v5 then
					if not animatedModel then
						return
					end

					if animatedModel.PrimaryPart then
						v3 = animatedModel
						maid3:Add(function()
							v3 = nil
						end)
						maid3:Add(animatedModel)
						local v7 = maid3:Add(Instance.new("Weld"))
						v7.Part0 = animatedModel.PrimaryPart
						v7.Part1 = part
						v7.C0 = animatedModel.PrimaryPart.CFrame:Inverse() * animatedModel:GetPivot()
						v7.Parent = animatedModel.PrimaryPart
						local v8

						if __render_mutation then
							v8 = Animals:ApplyMutation(animatedModel, __render_brainrot, __render_mutation)
						end

						local v9

						if v6 and next(v6) then
							v9 = Animals:ApplyTraits(animatedModel, __render_brainrot, v6)
						end

						if v4 == v5 then
							if v8 then
								maid3:Add(v8)
							end

							if v9 then
								maid3:Add(v9)
							end

							local __render_scale = v2:GetAttribute("__render_scale") or EggScale.GetEggScale(__render_brainrot)

							if __render_scale ~= 1 then
								animatedModel:ScaleTo(animatedModel:GetScale() * __render_scale)
								v7.C0 = animatedModel.PrimaryPart.CFrame:Inverse() * animatedModel:GetPivot()
							end

							renderOverhead()
						else
							if v8 then
								v8()
							end

							if v9 then
								v9()
							end
						end
					else
						warn((`Brainrot has no primary part: {__render_brainrot}`))
						animatedModel:Destroy()
					end
				elseif animatedModel then
					animatedModel:Destroy()
				end
			end

			local v5 = nil

			local function queueRenderBrainrot()
				if v5 then
					return
				end

				v5 = maid:Add(task.defer(function()
					if v5 then
						maid:Pop(v5)
						v5 = nil
					end

					renderBrainrot()
				end))
			end

			maid:Add(v2:OnAttributeChanged("__render_brainrot", queueRenderBrainrot))
			maid:Add(v2:OnAttributeChanged("__render_animation", queueRenderBrainrot))
			maid:Add(v2:OnAttributeChanged("__render_mutation", queueRenderBrainrot))
			maid:Add(v2:OnAttributeChanged("__render_traits", queueRenderBrainrot))
			maid:Add(v2:OnAttributeChanged("__render_scale", queueRenderBrainrot))

			if not v5 then
				v5 = maid:Add(task.defer(function()
					if v5 then
						maid:Pop(v5)
						v5 = nil
					end

					renderBrainrot()
				end))
			end

			maid:Add(v2:OnAttributeChanged("__render_overhead", renderOverhead))
			maid:Add(v2:OnAttributeChanged("__render_stolen", renderOverhead))
			return maid:WrapClean()
		end)
	end
}

function StealController.Start(_)
	task.spawn(StealController.StartDroppedBrainrotRendering, StealController)
	task.spawn(StealController.StartGrabbedBrainrotRendering, StealController)
end

return StealController