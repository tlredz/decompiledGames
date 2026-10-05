local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local loveBowArrow = FX:WaitForChild("LoveEffects").LoveBowArrow
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticle(child, p)
	local keypoints = child.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	child.Size = NumberSequence.new(numberSequenceKeypoints)
	child.Speed = NumberRange.new(child.Speed.Min * p, child.Speed.Max * p)
	child.Acceleration *= p
end

return function(p)
	local _ = p.player
	local hrp = p.hrp
	local currentCamera = Workspace.CurrentCamera

	if hrp == nil or hrp.Parent == nil or (hrp.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local clone = loveBowArrow:Clone()
	clone.Parent = hrp.Parent
	destroyAfter(clone, 15)
	local loveBow = clone.LoveBow
	local v = Util.Sound:Play("LoveV2XBowCharge", loveBow)
	local connection = heartbeatLoopFor2(0.5, function(_, _, p2)
		loveBow.LightAttachment.PointLight.Brightness = p2 * 18
	end)

	local function endHeartbeat()
		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif descendant:IsA("BasePart") then
				descendant.Transparency = 1
			end
		end

		if connection ~= nil then
			connection:Disconnect()
		end

		local brightness = loveBow.LightAttachment.PointLight.Brightness
		heartbeatLoopFor2(0.5, function(_, _, p2)
			loveBow.LightAttachment.PointLight.Brightness = (1 - p2) * brightness
		end, function()
			loveBow.LightAttachment.PointLight.Brightness = 0
			loveBow.LightAttachment.PointLight.Enabled = false
		end)
		Util.Sound:FadeOut(v, 0.25)
		Util.Sound:Play("LoveV2XBowCharge", loveBow)
		Util.Sound:Play("FireArrowQuick", loveBow)
		Util.Sound:Play("LoveV2CharmedInit", loveBow)
		local clone2 = script.Parent.V.SummonHeart.EmitOnPulse:Clone()
		clone2.CFrame = hrp.CFrame

		for _, child in pairs(clone2:GetChildren()) do
			child.Lifetime = NumberRange.new(child.Lifetime.Min * 0.5, child.Lifetime.Max * 0.5)
			ScaleParticle(child, 2.5)
		end

		clone2.Parent = Workspace.Terrain
		Util.Debris:AddItem(clone2, 3)

		for _, child in pairs(clone2:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.wait(3)

		if clone ~= nil and clone.Parent ~= nil then
			clone:Destroy()
		end
	end

	local connection2 = nil
	connection2 = heartbeatLoopFor2(10, function(_)
		if hrp ~= nil and hrp.Parent ~= nil and hrp:GetAttribute("LoveXCharge") ~= false then
			return
		end

		connection2:Disconnect()
		connection2 = nil
		endHeartbeat()
	end, endHeartbeat)
	local rightHand = hrp.Parent:FindFirstChild("RightHand")

	if rightHand == nil then
		connection2:Disconnect()
		connection2 = nil
		endHeartbeat()
	else
		clone.LoveArrow.Anchored = false
		clone.LoveBow.Anchored = false
		clone:SetPrimaryPartCFrame(rightHand.CFrame)
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = rightHand
		weld.C0 = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0.666)
		weld.Parent = clone.PrimaryPart
	end
end