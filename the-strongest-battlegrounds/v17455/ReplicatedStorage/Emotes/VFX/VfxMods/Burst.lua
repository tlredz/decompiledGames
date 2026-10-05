local createVector = vector.create
local Burst = {}
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local able = library.Able
local _ = library.LifeScale
local quickFX = library.QuickFX
local quickWeld = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { game.Workspace.Map }

function Burst.FirstEvent(p)
	local char = p.Data.Char
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

	local function FirstEvent()
		local function TP(folder, value)
			local v2 = value or 0.9

			for i = 1, 2 do
				local transparenciesByDescendant = {}
				local enabledsByDescendant = {}

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						transparenciesByDescendant[descendant] = descendant.Transparency
						descendant.Transparency = 1
					end

					if not descendant:IsA("ParticleEmitter") then
						continue
					end

					enabledsByDescendant[descendant] = descendant.Enabled
					descendant.Enabled = false
				end

				if i < 2 then
					dtwait(0.05)
				else
					dtwait(v2)
				end

				for k, enabled in pairs(enabledsByDescendant) do
					k.Enabled = enabled
				end

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = transparenciesByDescendant[descendant]
					end
				end

				dtwait(0.05)
			end
		end

		local FX = quickWeld({
			FX = vfx.TempLeg,
			Maid = object._maid,
			P = char["Left Leg"]
		})
		task.delay(0.4, function()
			local v3 = object._maid:give(Instance.new("Highlight"))
			v3.FillTransparency = -1
			v3.OutlineTransparency = 0
			v3.DepthMode = Enum.HighlightDepthMode.Occluded
			v3.FillColor = Color3.fromRGB(255, 131, 48)
			v3.OutlineColor = Color3.fromRGB(255, 0, 0)
			v3.Parent = char["Left Leg"]
			TweenService:Create(FX.PointLight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Brightness = 0
			}):Play()
			able({
				FX = FX,
				On = true
			})
			dtwait(0.2)
			TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			able({
				FX = FX,
				On = false
			})
		end)
		local raycastResult = game.Workspace:Raycast(humanoidRootPart.Position, createVector(0, -5, 0), raycastParams)

		if raycastResult then
			local folder = quickFX({
				FX = vfx.Jump,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position)
			})

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:HasTag("MeshEmitter") then
					descendant:SetAttribute("EMIT", true)
				end
			end

			playAttachment(folder)
		end

		TP(char, 0.1)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Burst.KickEvent(p)
	local char = p.Data.Char
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
	local target = p.Data.Target

	local function KickEvent()
		local folder = quickFX({
			FX = vfx.Kick,
			Maid = object._maid,
			Anchor = CFrame.new(humanoidRootPart.CFrame * CFrame.new(0, 0, -1).Position, target.Position)
		})

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:HasTag("MeshEmitter") then
				descendant:SetAttribute("EMIT", true)
			end
		end

		playAttachment(folder)
	end

	task.spawn(KickEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Burst.ExplodeEvent(p)
	local char = p.Data.Char
	local _ = char.HumanoidRootPart
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

	local function ExplodeEvent()
		local target = p.Data.Target

		if p.Data.HitGround then
			local folder = quickFX({
				FX = vfx.Explosion,
				Maid = object._maid,
				Anchor = target
			})

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:HasTag("MeshEmitter") then
					descendant:SetAttribute("EMIT", true)
				end
			end

			playAttachment(folder)
		else
			local folder = quickFX({
				FX = vfx.Explosion2,
				Maid = object._maid,
				Anchor = target
			})

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:HasTag("MeshEmitter") then
					descendant:SetAttribute("EMIT", true)
				end
			end

			playAttachment(folder)
		end
	end

	task.spawn(ExplodeEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Burst