local createVector = vector.create
local v = CFrame.new(0, -1.5, -2.5) * CFrame.Angles(0, -2.9670597283903604, 0)
local camera = workspace.Camera
local v2 = {}
local SetupViewport

SetupViewport = function(parent, imageColor: Color3, clone, cframe: CFrame, animation, flag: boolean?, flag2: boolean?)
	parent.BackgroundTransparency = 1
	parent.Ambient = Color3.new(1, 1, 1)
	parent.LightColor = Color3.new(1, 1, 1)
	parent.ImageColor3 = imageColor
	parent.LightDirection = createVector(-1, -1, -1)
	parent.BackgroundColor3 = Color3.fromRGB(-2, -2, -2)

	if not flag then
		v2.ClearViewport(parent)
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = parent

	if not flag2 then
		clone = clone:Clone()
	end

	clone:PivotTo(cframe)
	clone.Parent = worldModel

	if animation then
		local humanoid = clone:FindFirstChildOfClass("Humanoid")
		local animator

		if humanoid then
			animator = humanoid:FindFirstChildOfClass("Animator")
		end

		if animator then
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = true
			track:Play()
		end
	end

	local avatarOwnerId = clone:GetAttribute("AvatarOwnerId")

	if avatarOwnerId then
		local Players = game:GetService("Players")
		avatarOwnerId = Players:GetPlayerByUserId(avatarOwnerId)
	end

	if avatarOwnerId then
		local fighterAvatarRevisionChangedConnection = avatarOwnerId:GetAttributeChangedSignal("FighterAvatarRevision"):Connect(function()
			if not (clone.Parent and parent.Parent) then
				return
			end

			local Characters = require(script.Parent.Characters)
			local v3 = Characters.Get({
				Name = clone.Name,
				Owner = avatarOwnerId,
				RemoveHumanoidStates = true
			})

			if not v3 then
				return
			end

			if clone.Parent and parent.Parent then
				SetupViewport(parent, imageColor, v3, cframe, animation, nil, true)
			else
				v3:Destroy()
			end
		end)
		clone.Destroying:Once(function()
			fighterAvatarRevisionChangedConnection:Disconnect()
		end)
	end

	return clone
end

function v2.GetScreenCoverSize(p: number, p2: number)
	local v3 = 1 - p2
	local fieldOfView = camera.FieldOfView
	local viewportSize = camera.ViewportSize
	local v4 = p * 2 * math.tan((math.rad(fieldOfView / 2)))
	local v5 = v4 * (viewportSize.X / viewportSize.Y)
	return Vector3.new(v5 * v3, v4 * v3, 1), v4, v5
end

function v2.GetCameraBoundsFromPart(instance, p: number)
	local fieldOfView = camera.FieldOfView
	local viewportSize = camera.ViewportSize
	local v3 = viewportSize.X / viewportSize.Y
	local v4 = p * 2 * math.tan((math.rad(fieldOfView / 2)))
	local v5 = v4 * v3
	local cFrame = instance.CFrame
	local size = instance.Size
	local v6 = math.max((size.X - v5) / 2, 0)
	local v7 = math.max((size.Y - v4) / 2, 0)
	local position = cFrame.Position
	local v8 = cFrame.RightVector * v6
	local v9 = cFrame.UpVector * v7
	local v10 = position + v8 + v9
	local v11 = position + v8 - v9
	local v12 = position - v8 + v9
	local v13 = position - v8 - v9
	return {
		X = {
			Min = math.min(v10.X, v11.X, v12.X, v13.X),
			Max = math.max(v10.X, v11.X, v12.X, v13.X)
		},
		Y = {
			Min = math.min(v10.Y, v11.Y, v12.Y, v13.Y),
			Max = math.max(v10.Y, v11.Y, v12.Y, v13.Y)
		},
		Z = {
			Min = math.min(v10.Z, v11.Z, v12.Z, v13.Z),
			Max = math.max(v10.Z, v11.Z, v12.Z, v13.Z)
		}
	}
end

function v2.ClearViewport(viewportFrame)
	if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
		return
	end

	for _, child in viewportFrame:GetChildren() do
		if child:IsA("Model") or child:IsA("WorldModel") then
			child:Destroy()
		end
	end
end

function v2.ViewportCharacter(player)
	local character = player.Character
	local animation = player.Animation
	local customCFrame = player.CustomCFrame or v

	if not (character and character:IsA("Model")) then
		return
	end

	local v3 = {}
	local v4 = player.Viewport and player.Viewport:IsA("ViewportFrame")
	local v5 = player.ShadowViewport and player.ShadowViewport:IsA("ViewportFrame")
	local v6 = character.Parent == nil

	if v4 then
		local color = player.Locked and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
		table.insert(
			v3,
			(SetupViewport(
				player.Viewport,
				color,
				character,
				customCFrame,
				animation,
				player.CancelCleanup,
				v6 and not v5
			))
		)
	end

	if v5 then
		table.insert(
			v3,
			(SetupViewport(
				player.ShadowViewport,
				Color3.new(0, 0, 0),
				character,
				customCFrame,
				animation,
				player.CancelCleanup,
				v6
			))
		)
	end

	if not (v6 and (v4 or v5)) and (v6 or character:GetAttribute("AvatarOwnerId")) then
		character:Destroy()
	end

	return v3
end

return table.freeze(v2)