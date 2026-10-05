local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ClientDebris = require(script.Parent.ClientDebris)
local color = Color3.fromRGB(255, 255, 255)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function track(part)
	table.insert(v, part)
end

local function poofAt(x: number, y: number, z: number)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(1.5, 1.5, 1.5)
	part.CFrame = CFrame.new(x, y, z)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.1
	part.Parent = ClientDebris()
	track(part) -- equivalent call inferred; original call site unknown
	TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(5, 5, 5)
	}):Play()
	task.delay(0.2, function()
		if not part.Parent then
			return
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		tween.Completed:Once(function()
			pcall(function()
				part:Destroy()
			end)
		end)
		tween:Play()
	end)
end

local NoobUncoloners = {}

function NoobUncoloners.NpcSummonFx(data)
	poofAt(data.x or 0, data.y or 0, data.z or 0)
end

function NoobUncoloners.NpcDied(_) end

function NoobUncoloners.DisappearNPC(_) end

function NoobUncoloners.cleanup()
	for _, v2 in v do
		local v3 = v2
		pcall(function()
			v3:Destroy()
		end)
	end

	table.clear(v)
end

return NoobUncoloners