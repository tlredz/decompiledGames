local HeroHunterBurst = {}
local library = require(script.Parent.library)
local _ = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local EFP = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = library.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)

function HeroHunterBurst.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local humanoid = char.Humanoid
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
	local animSent = data.AnimSent
	task.spawn(function()
		if not animSent then
			return
		end

		local lastTime = tick()
		local v2 = nil

		while true do
			for _, v4 in pairs(humanoid:GetPlayingAnimationTracks()) do
				if v4.Animation.AnimationId ~= "rbxassetid://" .. tostring(animSent) then
					continue
				end

				v2 = v4
				break
			end

			if not v2 then
				task.wait()

				if not (tick() - lastTime > 0.5) then
					continue
				end
			end

			if not v2 then
				break
			end

			object._maid:give(v2.Stopped:Connect(function() end))
			task.delay(0.15, function()
				local _ = v2.IsPlaying
			end)
			break
		end
	end)

	local function FirstEvent()
		local v2 = FrameMarker.new({
			Framerate = 60
		})
		object._maid:give(function()
			v2:Destroy()
		end)
		return v2:Chain({
			[4] = function()
				local e1 = vfx.e1
				local v3 = quickFX({
					FX = e1,
					Maid = object._maid,
					Anchor = char:GetPivot() * e1:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end,
			[48] = function()
				local SLAP = vfx.SLAP
				local v3 = quickFX({
					FX = SLAP,
					Maid = object._maid,
					Anchor = char:GetPivot() * SLAP:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end,
			[77] = function()
				object.stuff = {}

				for _, child in pairs(vfx.GarouTemplate:GetChildren()) do
					local child2 = char:FindFirstChild(child.Name)

					if not child2 then
						continue
					end

					for _, child3 in pairs(child:GetChildren()) do
						local v3 = object._maid:give(child3:Clone())
						game.Debris:AddItem(v3, 3)
						v3.Parent = child2
						table.insert(object.stuff, v3)
					end
				end

				shared.vfx.emit(char["Left Arm"].xd, char["Right Arm"].xd)
			end,
			[103] = function()
				local windTrail = vfx.WindTrail
				local windTrail2 = quickFX({
					FX = windTrail,
					Maid = object._maid,
					Anchor = char:GetPivot() * windTrail:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(windTrail2)
				object.WindTrail = windTrail2
			end,
			[109] = function()
				object.WindTrail:PivotTo(char:GetPivot() * object.WindTrail:GetAttribute("Offset"):Inverse())
				shared.vfx.emit(object.WindTrail)
			end,
			[122] = function()
				object.WindTrail:PivotTo(char:GetPivot() * object.WindTrail:GetAttribute("Offset"):Inverse())
				shared.vfx.emit(object.WindTrail)
			end,
			[139] = function()
				object.WindTrail:PivotTo(char:GetPivot() * object.WindTrail:GetAttribute("Offset"):Inverse())
				shared.vfx.emit(object.WindTrail)
			end,
			[145] = function()
				local SLAP2 = vfx.SLAP2
				local v3 = quickFX({
					FX = SLAP2,
					Maid = object._maid,
					Anchor = char:GetPivot() * SLAP2:GetAttribute("Offset"):Inverse()
				})
				shared.vfx.emit(v3)
			end,
			[150] = function()
				object.WindTrail:PivotTo(char:GetPivot() * object.WindTrail:GetAttribute("Offset"):Inverse())
				shared.vfx.emit(object.WindTrail)
			end
		})
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return HeroHunterBurst