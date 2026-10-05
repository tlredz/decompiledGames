local SantaSMiracleRod = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local v = {
	"rbxassetid://96397309962005",
	"rbxassetid://102747159032319",
	"rbxassetid://126154189035742",
	"rbxassetid://88691048913644",
	"rbxassetid://115517290806874"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function offsetToScale(uDim: UDim2)
	local viewportSize = workspace.Camera.ViewportSize
	return UDim2.fromScale(uDim.X.Offset / viewportSize.X, uDim.Y.Offset / viewportSize.Y)
end

function SantaSMiracleRod.Morph(p, parent, object)
	object:Preload(script:GetChildren())
	object:Preload(v)
	local random = object:GetRandom(81)
	task.spawn(function()
		object:WaitUntilReady()
		local _ = parent.Position

		while parent.Parent do
			local clone = script.Present:Clone()
			local v2 = math.random(15, 95) / 100
			local uDim = UDim2.fromScale(v2, 0.5)
			local tweenInfo = TweenInfo.new(2.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			local v3 = object.logicTweens:Create(clone, tweenInfo, {
				Position = uDim,
				Rotation = 360
			})
			clone.Image = v[math.random(1, #v)]
			clone.Rotation = -720
			clone.Position = uDim + UDim2.fromScale(0, -35)
			clone.Parent = parent
			p.reelTrove:Add(v3.Completed:Once(function()
				if object:IsInBar(uDim.X.Scale, (offsetToScale(UDim2.fromOffset(clone.AbsoluteSize.X, 0))).X.Scale) then
					script.Poof:Play()
					object.fx:SpawnShake(object.reel_bar, 0.3, 3, 0.01, true)
					object:AddProgress(10)
				end

				clone:Destroy()
			end))
			v3:Play()
			object:WaitLogic(random:NextNumber(2, 4))
		end
	end)
end

setmetatable(SantaSMiracleRod, module)
return SantaSMiracleRod