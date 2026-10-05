local TrinityFinishSend = {}
local library = require(script.Parent.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function TrinityFinishSend.FirstEvent(p)
	local char = p.Char
	local victim = p.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local lastTime = tick()
		local v2 = nil

		while true do
			task.wait()

			for _, v4 in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
				if v4.Animation.AnimationId ~= "rbxassetid://" .. 97347443597947 then
					continue
				end

				v2 = v4
				break
			end

			if not (tick() - lastTime >= 0.25 or v2) then
				continue
			end

			if not v2 then
				break
			end

			local TrinityTearFinisher = require(script.TrinityTearFinisher)
			TrinityTearFinisher(char, victim, v2)
			break
		end
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return TrinityFinishSend