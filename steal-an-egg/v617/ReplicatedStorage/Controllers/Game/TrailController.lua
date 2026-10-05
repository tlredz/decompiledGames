local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trails = require(ReplicatedStorage.Data.Trails)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Log.new()
return {
	Start = function()
		local trails = ReplicatedStorage.Assets.Trails
		local v2 = {}

		local function reconcileTrailVisual(p)
			local v3 = assert(v2[p], (`Missing trail renderer state for {p.Name}`))
			v3.RenderRevision += 1
			local renderRevision = v3.RenderRevision
			v3.CharacterTrove:Clean()
			local trailId = v3.TrailId
			local character = v3.Character

			if trailId == nil or character == nil then
				return
			end

			v3.CharacterTrove:Add(task.defer(function()
				assert(Trails.TrailNameExists(trailId), (`Invalid active trail "{trailId}"`))
				local v4 = Player.WaitForRootPart(p)

				if v2[p] ~= v3 or v3.RenderRevision ~= renderRevision or v3.Character ~= character or v3.TrailId ~= trailId or v4.Parent ~= character then
					return
				end

				local part = trails[trailId]
				assert(part:IsA("BasePart"), (`Trail asset "{trailId}" must be a BasePart`))
				local clone = part:Clone()
				v3.CharacterTrove:Add(clone)
				clone.Anchored = false
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.Massless = true
				clone.Transparency = 1
				clone.CFrame = v4.CFrame
				clone.Parent = v4
				local mainPartTrailWeldConstraint = clone.MainPartTrailWeldConstraint
				assert(
					mainPartTrailWeldConstraint:IsA("WeldConstraint"),
					(`Trail asset "{trailId}" has an invalid weld`)
				)
				mainPartTrailWeldConstraint.Part1 = v4
			end))
		end

		local function applyActiveTrail(p, trailId: string?, flag: boolean)
			t.strict(t.instanceIsA("Player"))(p)
			t.strict(t.optional(t.string))(trailId)
			local v3 = assert(v2[p], (`Missing trail renderer state for {p.Name}`))
			v3.TrailId = trailId
			v3.ReceivedLiveUpdate = v3.ReceivedLiveUpdate or flag
			reconcileTrailVisual(p)
		end

		local function bindPlayer(p)
			if v2[p] ~= nil then
				return
			end

			local playerTrove = Trove.new()
			local extended = playerTrove:Extend()
			v2[p] = {
				TrailId = nil,
				Character = Player.FindCharacter(p),
				RenderRevision = 0,
				ReceivedLiveUpdate = false,
				PlayerTrove = playerTrove,
				CharacterTrove = extended
			}
			local v4 = v2[p]
			playerTrove:Connect(p.CharacterAdded, function(character)
				v4.Character = character
				reconcileTrailVisual(p)
			end)
			playerTrove:Connect(p.CharacterRemoving, function(p2)
				if v4.Character == p2 then
					v4.Character = nil
					reconcileTrailVisual(p)
				end
			end)

			if v4.Character ~= nil then
				reconcileTrailVisual(p)
			end
		end

		local function handleActiveTrailChanged(p, trailId: string?)
			bindPlayer(p)
			applyActiveTrail(p, trailId, true)
		end

		local function unbindPlayer(p)
			local v3 = assert(v2[p], (`Missing trail renderer state for {p.Name}`))
			v2[p] = nil
			v3.PlayerTrove:Destroy()
		end

		local function hydrateActiveTrailSnapshot()
			local v3 = Remotes.Trailwear.AskWornSnapshot:InvokeServer()

			for k, v4 in pairs(v3) do
				local playerByUserId = Players:GetPlayerByUserId(k)

				if playerByUserId == nil then
					v:AtDebug():Log((`Skipped trail snapshot for departed user {k}`))
				else
					bindPlayer(playerByUserId)

					if not assert(v2[playerByUserId], (`Missing trail renderer state for {playerByUserId.Name}`)).ReceivedLiveUpdate then
						applyActiveTrail(playerByUserId, v4, false)
					end
				end
			end
		end

		Players.PlayerAdded:Connect(bindPlayer)
		Players.PlayerRemoving:Connect(unbindPlayer)

		for _, v4 in ipairs(Players:GetPlayers()) do
			task.spawn(bindPlayer, v4)
		end

		Remotes.Trailwear.WornTrailShifted.OnClientEvent:Connect(handleActiveTrailChanged)
		task.defer(hydrateActiveTrailSnapshot)
		return {}
	end
}