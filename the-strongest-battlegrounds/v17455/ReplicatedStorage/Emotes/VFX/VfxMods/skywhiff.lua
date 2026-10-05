local Skywhiff = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local _ = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaceVFX(instance, pivot)
	instance:PivotTo(pivot * instance:GetAttribute("Offset"):Inverse())
end

function Skywhiff.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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
	local bind = data.bind
	local v2 = {}
	bind.Destroying:Once(function()
		if bind:GetAttribute("safe") then
			return
		end

		Clean() -- equivalent call inferred; original call site unknown

		for _, v3 in pairs(v2) do
			v3:Destroy()
		end
	end)

	local function FirstEvent()
		local parent = object._maid:give(vfx.thing:Clone())
		table.insert(v2, parent)
		local weld = Instance.new("Weld")
		table.insert(v2, weld)
		weld.Parent = parent
		weld.Part0 = parent.PrimaryPart
		weld.Part1 = humanoidRootPart
		parent.Parent = EFP
		shared.vfx.emit(parent.VFX.wind1)
		shared.vfx.emit(parent.VFX.wINDPARTICLE)
		shared.vfx.emit(parent.VFX.P1)

		for _, child in pairs(vfx.fake:GetChildren()) do
			local child2 = char:FindFirstChild(child.Name)

			if not child2 then
				continue
			end

			local v4 = quickWeld({
				FX = child,
				P = child2,
				Maid = object._maid
			})
			table.insert(v2, v4)
			local folder = v4
			task.delay(1.3, function()
				if not (data.bind and data.bind.Parent) then
					return
				end

				for i, trail in pairs(folder:GetDescendants()) do
					if trail:IsA("Trail") then
						playTween(trail, {
							Time = 0.5,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
					end
				end
			end)
		end

		task.wait(0.7)

		if not (data.bind and data.bind.Parent) then
			return
		end

		for _, child in pairs(parent.VFX.STEP:GetChildren()) do
			if not (child:IsA("Model") or child:IsA("BasePart")) then
				continue
			end

			PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		end

		shared.vfx.emit(parent.VFX.STEP)
		task.wait(0.03)

		if not (data.bind and data.bind.Parent) then
			return
		end

		PlaceVFX(parent.VFX.step2, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		shared.vfx.emit(parent.VFX.step2)
		task.wait(0.05)

		if not (data.bind and data.bind.Parent) then
			return
		end

		PlaceVFX(parent.VFX.step3, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		shared.vfx.emit(parent.VFX.step3)
		task.wait(0.2)

		if not (data.bind and data.bind.Parent) then
			return
		end

		PlaceVFX(parent.VFX.step4, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		shared.vfx.emit(parent.VFX.step4)
		task.wait(0.35)

		if not (data.bind and data.bind.Parent) then
			return
		end

		PlaceVFX(parent.VFX.step5, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		shared.vfx.emit(parent.VFX.step5)
		data.bind:SetAttribute("safe", true)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Skywhiff