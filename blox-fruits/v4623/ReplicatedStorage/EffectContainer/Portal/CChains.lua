local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):Inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):Inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("PortalEffects").Portal
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local v = {}
return function(data)
	local player = data.player
	local origin = data.origin
	local _ = data.createOrDelete
	local _ = data.lastsFor
	local lookDir = data.lookDir

	if data.character == nil or data.character.Parent == nil then
		print("CChains: Missing data.character")
	end

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 2500 and data.createOrDelete == "Create" then
		return
	end

	local BeamSpline = require(script:WaitForChild("BeamSpline"))
	local RenderSteppedLoopFor = require(script.Parent:WaitForChild("RenderSteppedLoopFor"))
	local renderSteppedLoopFor = RenderSteppedLoopFor.RenderSteppedLoopFor
	local RenderSteppedLoopFor2 = require(script.Parent:WaitForChild("RenderSteppedLoopFor"))
	local awaitRenderSteppedLoopFor = RenderSteppedLoopFor2.AwaitRenderSteppedLoopFor
	local SimpleElasticCatenary = require(script:WaitForChild("SimpleElasticCatenary"))
	local chainTemplateC = FX:WaitForChild("PortalEffects"):WaitForChild("ChainTemplateC")
	local attachment = Instance.new("Attachment")
	attachment.Name = "PortalChainAttachment"
	attachment.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), lookDir) + origin
	Util.SetParentOverrideWithColor(attachment, Workspace:WaitForChild("Terrain"), player, "PortalFruitVFXColor")
	destroyAfter(attachment, 14)

	local function createBeam()
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "PortalChainAttachment0"
		Util.SetParentOverrideWithColor(attachment2, Workspace.Terrain, player, "PortalFruitVFXColor")
		destroyAfter(attachment2, 20)
		local attachment3 = Instance.new("Attachment")
		attachment3.Name = "PortalChainAttachment1"
		Util.SetParentOverrideWithColor(attachment3, Workspace.Terrain, player, "PortalFruitVFXColor")
		destroyAfter(attachment3, 20)
		local clone = chainTemplateC:Clone()
		clone.Name = "PortalChainBeam"
		clone.Attachment0 = attachment2
		clone.Attachment1 = attachment3
		Util.SetParentOverrideWithColor(clone, attachment2, player, "PortalFruitVFXColor")
		destroyAfter(clone, 20)
		return clone
	end

	local function instantCleanupChain(p)
		local v2 = v[p]

		if v2 == nil then
			return
		end

		local beamsAroundChar = v2.beamsAroundChar
		pcall(function()
			for _, v3 in ipairs(beamsAroundChar) do
				v3:Destroy()
			end

			table.clear(beamsAroundChar)
		end)
		local beamsPortalToChar1 = v2.beamsPortalToChar1
		pcall(function()
			for _, v3 in ipairs(beamsPortalToChar1) do
				v3:Destroy()
			end

			table.clear(beamsPortalToChar1)
		end)
		local beamsPortalToChar2 = v2.beamsPortalToChar2
		pcall(function()
			for _, v3 in ipairs(beamsPortalToChar2) do
				v3:Destroy()
			end

			table.clear(beamsPortalToChar2)
		end)
		local elasticCatenarys = v2.elasticCatenarys
		pcall(function()
			for _, elasticCatenary in ipairs(elasticCatenarys) do
				elasticCatenary:Destroy()
			end

			table.clear(elasticCatenarys)
		end)
		v[p] = nil
		v2.state = "Cleaned"
	end

	local function createCharacterPortalChain(character)
		if v[character] then
			task.spawn(function()
				instantCleanupChain(character)
			end)
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		assert(humanoid)
		local rootPart = humanoid.RootPart
		assert(rootPart)
		local beamsPortalToChar = {}
		local beamsPortalToChar2 = {}
		local beamsAroundChar = {}

		for _ = 1, 4 do
			table.insert(beamsPortalToChar, (createBeam()))
			table.insert(beamsPortalToChar2, (createBeam()))
		end

		table.insert(beamsAroundChar, (createBeam()))
		table.insert(beamsAroundChar, (createBeam()))
		table.insert(beamsAroundChar, (createBeam()))
		table.insert(beamsAroundChar, (createBeam()))
		local v5 = {
			beamsPortalToChar1 = beamsPortalToChar,
			beamsPortalToChar2 = beamsPortalToChar2,
			beamsAroundChar = beamsAroundChar,
			state = "FlyingToCharacter",
			elasticCatenarys = {}
		}
		v[character] = v5
		v5.state = "FlyingToCharacter"
		Util.Sound:Play("Portal_C_ChainGrab_V2_01", character.PrimaryPart)

		local function makeSpiralCurve(p: number)
			return function(p2: number, p3)
				local pointToWorldSpace = attachment.WorldCFrame:PointToWorldSpace((Vector3.new(p * 3.5, 0, 0)))
				local v6 = p3.Position - pointToWorldSpace
				local magnitude = v6.Magnitude

				if magnitude < 0.0001 then
					return pointToWorldSpace
				end

				local vector2 = v6 / magnitude
				local unit = vector2:Cross(math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(
					1,
					0,
					0
				) or createVector(0, 1, 0)).Unit
				local cross = vector2:Cross(unit)
				local v7 = magnitude * 0.16666666666666666
				local v8 = math.sin(3.141592653589793 * p2) * v7
				local v9 = p * 2 * 2 * 3.141592653589793 * p2
				local v10 = unit * math.cos(v9) + cross * math.sin(v9)
				return pointToWorldSpace + vector2 * (magnitude * p2) + v10 * v8
			end
		end

		local v6 = 1
		local v7 = -1
		local v8 = { function(p: number, p2)
				local pointToWorldSpace = attachment.WorldCFrame:PointToWorldSpace((Vector3.new(v6 * 3.5, 0, 0)))
				local v9 = p2.Position - pointToWorldSpace
				local magnitude = v9.Magnitude

				if magnitude < 0.0001 then
					return pointToWorldSpace
				end

				local vector2 = v9 / magnitude
				local unit = vector2:Cross(math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(
					1,
					0,
					0
				) or createVector(0, 1, 0)).Unit
				local cross = vector2:Cross(unit)
				local v10 = magnitude * 0.16666666666666666
				local v11 = math.sin(3.141592653589793 * p) * v10
				local v12 = v6 * 2 * 2 * 3.141592653589793 * p
				local v13 = unit * math.cos(v12) + cross * math.sin(v12)
				return pointToWorldSpace + vector2 * (magnitude * p) + v13 * v11
			end, function(p: number, p2)
				local pointToWorldSpace = attachment.WorldCFrame:PointToWorldSpace((Vector3.new(v7 * 3.5, 0, 0)))
				local v9 = p2.Position - pointToWorldSpace
				local magnitude = v9.Magnitude

				if magnitude < 0.0001 then
					return pointToWorldSpace
				end

				local vector2 = v9 / magnitude
				local unit = vector2:Cross(math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(
					1,
					0,
					0
				) or createVector(0, 1, 0)).Unit
				local cross = vector2:Cross(unit)
				local v10 = magnitude * 0.16666666666666666
				local v11 = math.sin(3.141592653589793 * p) * v10
				local v12 = v7 * 2 * 2 * 3.141592653589793 * p
				local v13 = unit * math.cos(v12) + cross * math.sin(v12)
				return pointToWorldSpace + vector2 * (magnitude * p) + v13 * v11
			end }
		local v9 = { v5.beamsPortalToChar1, v5.beamsPortalToChar2 }
		awaitRenderSteppedLoopFor(0.4, function(_: number, _: number, p: number)
			if v5.state ~= "FlyingToCharacter" then
				return
			end

			local v10 = math.max(p, 0.1)

			for i, v11 in ipairs(v9) do
				local v13 = v8[i]

				local function fn(p2: number)
					return v13(math.map(p2, 0, 1, 0, v10), rootPart)
				end

				BeamSpline.drawSpaceCurveWithBeamArray(fn, v11)
			end
		end)

		if v5.state ~= "FlyingToCharacter" then
			return
		end

		v5.state = "WrappedAroundCharacter"

		for i, v10 in ipairs(v8) do
			local v11 = v10(0, rootPart)
			local cframe = attachment.WorldCFrame.Rotation + v11
			local pointToObjectSpace = cframe:PointToObjectSpace(v10(1, rootPart))
			local v12 = SimpleElasticCatenary.new(createVector(0, 0, 0), pointToObjectSpace)
			v12.Beam.Transparency = NumberSequence.new(1)
			v12.Part0.Transparency = 1
			v12.Part1.Transparency = 1
			v12.Ball.Transparency = 1
			v5.elasticCatenarys[i] = v12
			v12.Ball.CFrame = CFrame.new(cframe:PointToObjectSpace(v10(0.5, rootPart)))
		end

		renderSteppedLoopFor(24, function(p: number, _: number, _: number)
			if v5.state == "Cleaned" then
				return
			end

			for i, v10 in ipairs(v8) do
				local v11 = v9[i]
				local elasticCatenary = v5.elasticCatenarys[i]
				local v12 = v10(0, rootPart)
				local cframe = attachment.WorldCFrame.Rotation + v12
				local beamToBezierControlPoints, v13, v14, v15 = BeamSpline.beamToBezierControlPoints(elasticCatenary.Beam)
				-- equivalent calls inferred from this helper; original call sites unknown
				local cframe2 = cframe

				local function catenaryCurve(p2)
					return cframe2:PointToWorldSpace((BeamSpline.cubicBezier(
						p2,
						beamToBezierControlPoints,
						v13,
						v14,
						v15
					)))
				end

				local v21 = v10
				local v22 = beamToBezierControlPoints
				local v23 = v13
				local v24 = v14
				local v25 = v15
				local v27 = math.clamp(math.map(p, 0, 0.4, 0, 1), 0, 1)

				local function fn(p2: number)
					return v21(p2, rootPart):Lerp(catenaryCurve(p2), v27)
				end

				if v5.state ~= "Destroyed" then
					elasticCatenary.Part1.CFrame = CFrame.new(cframe:PointToObjectSpace(v10(1, rootPart)))
				end

				BeamSpline.drawSpaceCurveWithBeamArray(fn, v11)
			end
		end)
		local v10 = chainTemplateC.Brightness + 240
		local brightness = chainTemplateC.Brightness

		local function fn(p: number, rootPart2, p2: number)
			return (rootPart2.CFrame - Vector3.new(0, rootPart2.Size.Y * 0.5, 0)):PointToWorldSpace(Vector3.new(
				0,
				rootPart2.Size.Y * p,
				0
			) + p2 * Vector3.new(math.cos(18.84955592153876 * p) * 2, 0, math.sin(18.84955592153876 * p) * 1.2))
		end

		for _, v11 in ipairs(v5.beamsAroundChar) do
			v11.TextureLength = 3.5
		end

		renderSteppedLoopFor(24, function(p: number, _: number, _: number)
			if v5.state ~= "WrappedAroundCharacter" then
				return
			end

			local v11 = math.max(math.clamp(math.map(p, 0, 0.4, 0, 1), 0, 1), 0.1)
			local v12 = math.lerp(1.7, 1, v11)

			local function fn2(p2: number)
				return fn(math.map(p2, 0, 1, 0, v11), rootPart, v12)
			end

			BeamSpline.drawSpaceCurveWithBeamArray(fn2, v5.beamsAroundChar)

			for _, v13 in ipairs(v5.beamsAroundChar) do
				v13.Brightness = math.lerp(v10, brightness, v11)
				v13.LightEmission = math.lerp(1, 0.7, v11)
			end
		end)
	end

	local function destroyCharacterPortalChain(character)
		local v2 = v[character]

		if v2 == nil or (v2.state == "Destroyed" or v2.state == "Cleaned") then
			return
		end

		v2.state = "Destroyed"
		pcall(function()
			for _, v3 in ipairs(v2.beamsAroundChar) do
				v3:Destroy()
			end

			table.clear(v2.beamsAroundChar)

			for _, elasticCatenary in ipairs(v2.elasticCatenarys) do
				elasticCatenary.Part1.CanCollide = true
				elasticCatenary.Part1.Anchored = false
			end
		end)
		task.wait(2)
		instantCleanupChain(character)
	end

	if data.createOrDelete == "Create" then
		task.spawn(function()
			local humanoid = data.character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid:IsDescendantOf(Workspace) then
				humanoid:GetAttributeChangedSignal("LastCPortalUseTime"):Once(function()
					instantCleanupChain(data.character)
				end)
			end
		end)
		createCharacterPortalChain(data.character)
	else
		if data.createOrDelete ~= "Delete" then
			error("data.createOrDelete incorrect format")
			return
		end

		print("CChain: out of radius", v[data.character])
		destroyCharacterPortalChain(data.character)
	end
end