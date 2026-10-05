local createVector = vector.create
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
local DynamicFace = require(script.Parent.Parent.DynamicFace)
local Scene = require(script.Parent.Parent.Scene)
local Deck = require(script.Parent.Deck)
local FailureTemplates = require(script.Parent.FailureTemplates)
local Props = require(script.Parent.Props)
local Timing = require(script.Parent.Timing)
require(script.Parent.Types)
local frozen = table.freeze({
	MarineFaceIds = {
		"147551965983540",
		"114357694516233",
		"171354436203665",
		"48847223322759",
		"1164"
	},
	SuspiciousMarineFaceId = "1164",
	SmugglerFaceId = "255535022429711",
	PirateIdleAnimationName = "ShyPointingIdle",
	DoghouseScale = 0.85
})
return table.freeze({
	create = function(parent, p, items, p2: number, object, p3, p4)
		local v = p3 == "Failure"
		local v2

		if v then
			v2 = FailureTemplates.get(assert(p4))
		end

		local cargoDonor = Props.findCargoDonor()
		local v3 = {}
		local marineEntrances = {}
		local v4 = nil
		local flag = false
		local flag2 = false
		local flag3 = false
		local v5 = false
		local v6 = false
		local v7 = false
		local v8 = nil
		local v9 = nil

		for k, item in items do
			local pivot = item.Boat:GetPivot()
			local v10 = Scene.flattenedUnit(pivot.LookVector) or createVector(0, 0, 1)
			local v11 = Scene.flattenedUnit(pivot.RightVector) or createVector(1, 0, 0)
			local v12 = math.max(item.Size.X, item.Size.Z)
			local v13 = math.min(item.Size.X, item.Size.Z)
			local v14 = not v2 and "Pirate" or v2.ActorRole
			local clone = CharacterPresentation.clone(v14, p)

			if v14 == "Doghouse" then
				clone:ScaleTo(clone:GetScale() * frozen.DoghouseScale)
			end

			if not v then
				CharacterPresentation.setFace(clone, frozen.SmugglerFaceId)
			end

			clone.Parent = parent
			local v15

			if v14 == "Doghouse" then
				v15 = -v10
			else
				v15 = v10
			end

			local v16

			if k == p2 then
				local v17 = Vector3.new(pivot.X, item.DeckY, pivot.Z) - v10 * math.min(v12 * 0.1, 8) + v11 * math.min(
					v13 * 0.12,
					5
				)
				v16 = Deck.getSurfacePosition(item, v17)
				clone:PivotTo(Deck.calculateStandingCFrame(clone, v16, v15))
				v8 = clone:GetPivot().Position + createVector(0, 2.5, 0)

				if not v then
					CharacterPresentation.poseSurrender(clone)
				end

				local createFruitCrate = Props.createFruitCrate
				local crateContent

				if v2 then
					crateContent = v2.CrateContent
				end

				local v18
				v4, v18 = createFruitCrate(parent, p, item, v16, v10, v11, object, v3, crateContent)

				if v18 == 0 then
					v9 = clone
					flag2 = true
				else
					v9 = clone
				end
			else
				local v17 = Vector3.new(pivot.X, item.DeckY, pivot.Z) + v11 * object:NextNumber(
					-math.min(v13 * 0.12, 4),
					(math.min(v13 * 0.12, 4))
				) + v10 * object:NextNumber(-math.min(v12 * 0.1, 6), (math.min(v12 * 0.1, 6)))
				v16 = Deck.getSurfacePosition(item, v17)
				clone:PivotTo(Deck.calculateStandingCFrame(clone, v16, v15))
				local cargo = Props.cloneCargo(cargoDonor)
				cargo.Name = "LookoutFinaleCargo"
				cargo.Parent = parent
				Props.pivotCargo(cargo, clone:GetPivot() + v10 * 1.35 + createVector(0, 2.5, 0))
			end

			if p4 == "Fisherman" then
				local v17 = CharacterPresentation.equipFishingRod(clone)
				v5 = not v17 or v5
				v6 = not CharacterPresentation.playFishermanRodIdle(clone) or v6

				if v17 and not CharacterPresentation.playFishingRodModelIdle(v17) then
					v6 = true
				end
			elseif not CharacterPresentation.playPirateIdle(clone, frozen.PirateIdleAnimationName) then
				flag3 = true
			end

			clone:SetAttribute("FloorPos", v16)
			clone:SetAttribute("FloorNormal", createVector(0, 1, 0))
			local v17 = math.clamp(v13 * 0.18, 2.75, 5.5)
			local v18 = { -v11 * v17 + v10 * v17 * 0.35, v11 * v17 + v10 * v17 * 0.35 }
			local v19 = v18[1]
			local v20 = v19 + (Scene.flattenedUnit(v19) or v10) * math.clamp(v17 * 0.55, 2.25, 3.1)
			local v21 = { v18[1], v18[2], v20 }
			local position = pivot.Position
			local v22 = { v10 * 15 - v11 * 8, v10 * 15 + v11 * 10 }
			local v23 = { v22[1], v22[2], v22[1] + v10 * 3 }

			for k2, v24 in v21 do
				local surfacePosition = Deck.getSurfacePosition(item, v16 + v24)
				local surfacePosition2 = Deck.getSurfacePosition(item, position + v23[k2])
				local v25

				if k == p2 then
					v25 = k2 == 1
				else
					v25 = false
				end

				local clone2 = CharacterPresentation.clone(v25 and "Marine1" or "Marine", p)
				local v26

				if k == p2 then
					v26 = k2 == 3
				else
					v26 = false
				end

				local suspiciousMarineFaceId

				if v26 then
					suspiciousMarineFaceId = frozen.SuspiciousMarineFaceId
				else
					suspiciousMarineFaceId = frozen.MarineFaceIds[object:NextInteger(1, #frozen.MarineFaceIds)]
				end

				clone2.Parent = parent
				clone2:PivotTo(Deck.calculateStandingCFrame(clone2, surfacePosition2, v10))

				if v26 then
					if DynamicFace.applyHead(clone2, suspiciousMarineFaceId) then
						v7 = not DynamicFace.playExpression(clone2, suspiciousMarineFaceId) or v7
					else
						CharacterPresentation.setFace(clone2, suspiciousMarineFaceId)
						v7 = true
					end
				elseif not v25 then
					CharacterPresentation.setFace(clone2, suspiciousMarineFaceId)
				end

				local marineEntrance = Deck.createMarineEntrance(
					item,
					clone2,
					position,
					surfacePosition2,
					surfacePosition,
					v16 - surfacePosition,
					v10,
					v11,
					object:NextNumber(0, Timing.Shared.MarineEntranceMaxStartDelay),
					k2 == 3
				)
				table.insert(marineEntrances, marineEntrance)

				if k == p2 and k2 == 3 and v4 then
					v4.Follower = marineEntrance
					v4.PickupFeet = Deck.getSurfacePosition(item, v4.GroundCFrame.Position + v10 * 3.3)
				end

				clone2:SetAttribute("FloorPos", surfacePosition)
				clone2:SetAttribute("FloorNormal", createVector(0, 1, 0))

				if not CharacterPresentation.equipCanvander(clone2, p) then
					flag = true
				end
			end
		end

		if flag then
			warn("[Lookout] A finale marine could not equip the replicated Canvander visual")
		end

		if flag2 then
			warn("[Lookout] The replicated physical-fruit pile was unavailable")
		end

		if flag3 then
			warn("[Lookout] A finale pirate could not play its randomized idle")
		end

		if v5 then
			warn("[Lookout] The Fisherman failure actor could not equip his fishing rod")
		end

		if v6 then
			warn("[Lookout] The Fisherman failure actor or rod could not play its holding idle")
		end

		if v7 then
			warn("[Lookout] The follower marine could not initialize its dynamic face")
		end

		return
			assert(v8, "Lookout finale did not place its main actor"),
			marineEntrances,
			v3,
			assert(v4, "Lookout finale did not place its main fruit crate"),
			assert(v9, "Lookout finale did not retain its main actor")
	end
})