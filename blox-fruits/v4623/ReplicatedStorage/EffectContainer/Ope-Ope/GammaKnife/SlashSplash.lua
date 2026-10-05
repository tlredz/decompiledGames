local function GetEdgePoints(absoluteSize)
	local random = Random.new()
	return
		Vector2.new(random:NextNumber(0, absoluteSize.X), 0),
		Vector2.new(random:NextNumber(0, absoluteSize.X), random:NextNumber(0, absoluteSize.Y))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CalculateRotation(p, p2)
	local v = p2 - p
	return math.atan2(v.Y, v.X) - 1.5707963267948966
end

local currentCamera = workspace.CurrentCamera
local Tween = require(game.ReplicatedStorage.Util.Tween)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local RunService = game:GetService("RunService")
local slash = script:WaitForChild("Slash")
local parent = game.Players.LocalPlayer.PlayerGui:FindFirstChild(script.Name)

if not parent then
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:Preload("rbxassetid://2200369468")
	parent = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	parent.Name = script.Name
end

local v2 = {}
RunService:BindToRenderStep(script.Parent.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value, function(p)
	local now = tick()

	for k, v3 in pairs(v2) do
		local v4 = now - v3.Start

		if v3.Destroy then
			v3.Frame:Destroy()
			v2[k] = nil
		elseif v3.Frame.Parent then
			if v3.DestroyTime then
				local v5 = math.max(now - v3.DestroyTime, 0)

				if v5 > 0.5 then
					v3.Destroy = true
				else
					local circ = Tween.ease.out.circ(v5, 1, -1, 0.5)
					local quad = Tween.ease["in"].quad(v5, 0, 1, 0.5)

					for _, v6 in next, { v3.Frame.Back, v3.Frame.Front }, nil do
						v6.ImageTransparency = quad
					end

					v3.Frame.Size = UDim2.new(0.05 * circ, 0, 0, v3.Length)
				end
			else
				if v3.Attachment then
					if not (v3.Attachment:IsDescendantOf(workspace) or v3.DestroyTime) then
						v3.DestroyTime = now
					end
				elseif v4 - 0.5 > v3.Lifetime and not v3.DestroyTime then
					v3.DestroyTime = now
				end

				if v4 < 0.5 then
					local back = Tween.ease.out.back(v4, 0, 1, 0.5)
					v3.Frame.Size = UDim2.new(0.05 * back, 0, 0, v3.Length)
				end
			end

			v3.Trail += v3.Speed * p
			local scale = v3.Frame.Back.Position.Y.Scale

			if v3.Direction > 0 then
				if scale > 0 then
					v3.Trail = 0
				end
			elseif scale < -15 then
				v3.Trail = 0
			end

			v3.Frame.Back.Position = UDim2.new(0, 0, (v3.Direction > 0 and -15 or 0) + v3.Direction * v3.Trail, 0)
			v3.Frame.Front.Position = UDim2.new(0.5, 0, (v3.Direction > 0 and -15 or 0) + v3.Direction * v3.Trail, 0)
		end
	end
end)
return function(list)
	local v3, v4, v5, v6, attachment = unpack(list)
	local v8, v9 = GetEdgePoints(parent.AbsoluteSize)
	local lerped = v8:Lerp(v9, 0.5)
	local length = (v9 - v8).Magnitude * 1.5
	local clone = slash:Clone()
	local direction = math.random(2) == 1 and 1 or -1
	clone.Back.ImageColor3 = v3 or Color3.new(0, 1, 0)
	clone.Front.ImageColor3 = v4 or Color3.new(1, 1, 1)
	clone.Size = UDim2.new(0, 0, 0, length)
	clone.Position = UDim2.new(0, lerped.X, 0, lerped.Y)
	clone.Rotation = math.deg(CalculateRotation(v8, v9))
	clone.Parent = parent
	Sound:Play("Ope.RadioKnife.SwordSwing", currentCamera.CFrame.p)
	table.insert(v2, {
		Attachment = attachment,
		Length = length,
		Frame = clone,
		Speed = v5 or math.clamp(Random.new():NextNumber(0, 1), 0.1, 1.25),
		Lifetime = math.min(10, v6 or 5),
		Direction = direction,
		Trail = 0,
		Start = tick()
	})
end