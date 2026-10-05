local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Matteo = {}
local matteo = ReplicatedStorage.Models.Events.Matteo
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local TweenPivot = require(ReplicatedStorage.Shared.TweenPivot)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local name = script.Name
local maid = Trove.new()
local _ = workspace.CurrentCamera

function Matteo.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	local serverTimeNow = workspace:GetServerTimeNow()
	ReplicatedStorage:SetAttribute("MatteoEvent", true)
	SoundController:UpdateOST()
	maid:Add(function()
		ReplicatedStorage:SetAttribute("MatteoEvent", nil)
		SoundController:UpdateOST()
	end)
	local v = false
	maid:Add(function()
		v = true
	end)
	local v2 = activeEventData.startedAt + 10 - serverTimeNow
	maid:Add(task.delay(v2, function()
		local v3 = activeEventData.startedAt + 14 - serverTimeNow

		if v3 > 0 then
			local clone = ShakePresets.Bump:Clone()
			maid:Add(clone)
			clone.Sustain = true
			maid:Add(ShakePresets.BindShakeToCamera(clone, workspace.CurrentCamera))
			clone:Start()
			maid:Add(task.delay(v3, function()
				clone:StopSustain()
			end))
			maid:Add(function()
				local clone2 = ShakePresets.Bump:Clone()
				clone2.Sustain = true
				local v4 = ShakePresets.BindShakeToCamera(clone2, workspace.CurrentCamera)
				clone2:Start()
				task.wait(4)
				clone2:StopSustain()
				task.wait(2)
				clone2:Destroy()
				v4()
			end)
		end

		local v4 = Synchronizer:Wait("MatteoEvent")
		local isRainbow = v4:Get("IsRainbow")
		local v5 = activeEventData.startedAt + 15 - serverTimeNow
		local v6

		if isRainbow then
			v6 = {
				matteo.RainbowTrees.Tree1,
				matteo.RainbowTrees.Tree2,
				matteo.RainbowTrees.Tree3,
				matteo.RainbowTrees.Tree4,
				matteo.RainbowTrees.Tree5
			}
		else
			v6 = {
				matteo.NormalTrees.Tree1,
				matteo.NormalTrees.Tree2,
				matteo.NormalTrees.Tree3,
				matteo.NormalTrees.Tree4,
				matteo.NormalTrees.Tree5
			}
		end

		local clone = script.WindParts:Clone()
		clone.Parent = workspace
		maid:Add(function()
			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(5)
			clone:Destroy()
		end)
		local v7 = {}
		local clones = {}

		for k, position in v4:Get("TreePositions") do
			local random = Random.new(position.X * 100 // 1 + position.Z * 100 // 1)
			local integer = random:NextInteger(1, #v6)
			local number = random:NextNumber(0, 6.283185307179586)
			local maid2 = maid:Extend()
			v7[k] = maid2
			local clone2 = v6[integer]:Clone()
			local extentsSize = clone2:GetExtentsSize()
			local v8 = CFrame.new(position) * CFrame.new(0, -extentsSize.Y * 0.5, 0) * CFrame.Angles(0, number, 0)
			local v9 = CFrame.new(position) * CFrame.new(0, extentsSize.Y * 0.485, 0) * CFrame.Angles(0, number, 0)
			local clone3 = maid2:Clone(matteo.SpawnVFX)
			clone3.CFrame = CFrame.new(position) * CFrame.Angles(0, number, 0)
			clone3.Parent = workspace
			maid2:Add(function()
				task.wait()

				if not v then
					clone2:Destroy()
					return
				end

				local tweenPivot = TweenPivot(
					clone2,
					TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					v8 * CFrame.new(0, -1, 0)
				)
				tweenPivot:Play()
				tweenPivot.Completed:Wait()
				clone2:Destroy()
			end)

			if v5 <= 1 then
				clone2:PivotTo(v9)
				clone3:Destroy()
			else
				clone2:PivotTo(v8)
				maid2:Add(TweenPivot(clone2, TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v9)):Play()
				local v12 = clone3
				local v13 = maid2
				maid2:Add(task.delay(v5 - 1, function()
					v12.ParticleEmitter.Enabled = false
					task.wait(1)
					v13:Remove(v12)
				end))
			end

			if isRainbow then
				for _, child in clone2:GetChildren() do
					if child.Name ~= "Handle" then
						child:AddTag("RainbowModel")
					end
				end
			end

			clone2.Parent = workspace
			local character = Players.LocalPlayer.Character

			if not (integer == 1 or integer == 2 or integer == 3) or character and character:GetAttribute("Matteo_CollectedTree") then
				continue
			end

			local clone4 = maid2:Clone(matteo.ProximityPart)
			table.insert(clones, clone4)
			clone4.ProximityPrompt.Enabled = false
			maid2:Add(task.delay(v5 - 1, function()
				clone4.ProximityPrompt.Enabled = true
			end))
			clone4:PivotTo(CFrame.new(position) * CFrame.new(0, 3, 0))
			clone4.Parent = workspace
			local v13 = k
			maid2:Add(clone4.ProximityPrompt.Triggered:Connect(function()
				if not Net:Invoke("EventService/Matteo/CollectTree", v13) then
					return
				end

				for k2, v14 in clones do
					v14:Destroy()
				end

				table.clear(clones)
			end))
		end

		v4:OnDictionaryRemoved("TreePositions", function(_, p: string)
			local v8 = v7[p]

			if v8 then
				v8:Destroy()
				v7[p] = nil
			end
		end)
	end))
end

function Matteo.OnStop(_)
	maid:Destroy()
end

function Matteo.OnLoad(_) end

return Matteo