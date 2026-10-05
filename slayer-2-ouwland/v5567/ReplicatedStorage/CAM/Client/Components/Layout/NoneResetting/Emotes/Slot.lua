local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local faye = require(ReplicatedStorage.Packages.faye)
local Emotes = require(ReplicatedStorage.CAM.Emotes)
local EmotesInfo = require(ReplicatedStorage.CAM.Global.EmotesInfo)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local localPlayer = Players.LocalPlayer
local color = Color3.new(1, 1, 1)
local uDim = UDim.new(0.6, 0)
local color2 = Color3.new()
local uDim2 = UDim.new(1, 0)
local info = faye.Info(0.15, Enum.EasingStyle.Back)
local springInfo = faye.SpringInfo(0.4, 1, 0.4)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local color3 = Color3.new()

local function follow(object, p, p2: number, p3, p4)
	local flag = false
	return object:Do(function(callback)
		local selected

		if callback(p) == p2 then
			selected = p4
		else
			selected = p3
		end

		if flag then
			return object:Animation(selected, info)
		end

		flag = true
		return selected
	end)
end

local v = nil
local flag = false

local function template()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local starterCharacterCloneable

	if assets ~= nil then
		starterCharacterCloneable = assets:FindFirstChild("StarterCharacterCloneable")
	end

	if starterCharacterCloneable == nil or not starterCharacterCloneable:IsA("Model") then
		return nil
	end

	return starterCharacterCloneable
end

local function dress()
	if flag then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local starterCharacterCloneable

	if assets ~= nil then
		starterCharacterCloneable = assets:FindFirstChild("StarterCharacterCloneable")
	end

	if starterCharacterCloneable == nil or not starterCharacterCloneable:IsA("Model") then
		starterCharacterCloneable = nil
	end

	if starterCharacterCloneable == nil then
		return
	end

	flag = true
	local clone = starterCharacterCloneable:Clone()
	local data = Utility.GetData(localPlayer, true)

	if data ~= nil then
		Load_Custom(localPlayer, clone, data, true)
	end

	if v ~= nil then
		v:Destroy()
	end

	v = clone
	flag = false
end

local function rig()
	local v2 = v

	if v2 ~= nil then
		return v2:Clone()
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local starterCharacterCloneable

	if assets ~= nil then
		starterCharacterCloneable = assets:FindFirstChild("StarterCharacterCloneable")
	end

	if starterCharacterCloneable == nil or not starterCharacterCloneable:IsA("Model") then
		starterCharacterCloneable = nil
	end

	if starterCharacterCloneable == nil then
		return nil
	end

	return (starterCharacterCloneable:Clone())
end

if RunService:IsRunning() and localPlayer ~= nil then
	task.spawn(dress)
	localPlayer.CharacterAppearanceLoaded:Connect(function()
		task.spawn(dress)
	end)
end

local function Preview(object, p: string)
	return object:Create("ViewportFrame")({
		Name = "Preview",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		function(parent)
			local clone, v2 = Emotes.Display(p)

			if not clone then
				local v3 = v

				if v3 == nil then
					local assets = ReplicatedStorage:FindFirstChild("Assets")
					local starterCharacterCloneable

					if assets ~= nil then
						starterCharacterCloneable = assets:FindFirstChild("StarterCharacterCloneable")
					end

					if starterCharacterCloneable == nil or not starterCharacterCloneable:IsA("Model") then
						starterCharacterCloneable = nil
					end

					if starterCharacterCloneable == nil then
						clone = nil
					else
						clone = starterCharacterCloneable:Clone()
					end
				else
					clone = v3:Clone()
				end
			end

			if clone == nil then
				return
			end

			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = parent
			clone.Parent = worldModel
			Emotes.Wear(clone, p)
			local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
			local camera = Instance.new("Camera")
			camera.Parent = parent
			parent.CurrentCamera = camera

			if humanoidRootPart ~= nil then
				humanoidRootPart.Anchored = true
				local v3 = EmotesInfo[p]
				local v4 = 5.85 + (v3 == nil and 0 or v3.PreviewZoom or 0)
				local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -v4)).Position
				camera.CFrame = CFrame.new(position, humanoidRootPart.Position) + createVector(0, 0, 0)
			end

			if v2 == nil then
				return
			end

			local animator = clone:FindFirstChildWhichIsA("Animator", true)

			if animator == nil then
				return
			end

			local track = animator:LoadAnimation(v2)
			track.Looped = true
			track:Play(0)
		end
	})
end

return function(object, p: number, p2: number, object2, flag2: boolean, p3: number, text: string?, callback)
	local v2 = -1.5707963267948966 + (p - 1) * (6.283185307179586 / p2)
	local v3 = text == nil and 0.55 or 0.15
	local flag3 = false
	local v4 = 1
	local transparency = object:Do(function(callback2)
		local selected

		if callback2(object2) == p then
			selected = v3
		else
			selected = v4
		end

		if flag3 then
			return object:Animation(selected, info)
		end

		flag3 = true
		return selected
	end)
	local uDim3 = UDim2.fromScale(0.5, 0.5)
	local uDim4 = UDim2.fromScale(0.6, 0.6)
	local uDim5 = UDim2.fromScale(0.3, 0.3)
	local info2 = faye.Info(p3)
	local flag4 = false
	local size = object:Do(function(callback2)
		local v7

		if callback2(object2) == p then
			v7 = uDim4
		else
			v7 = uDim3
		end

		if flag4 then
			return object:Animation(v7, info)
		end

		flag4 = true
		return object:Animation(v7, springInfo, {
			From = uDim5
		})
	end)
	local v7

	if text ~= nil then
		v7 = Preview(object, text)
	end

	local v8

	if text ~= nil then
		v8 = object:Create("TextLabel")({
			Name = "Name",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.9, 0.18),
			BackgroundTransparency = 1,
			Text = text,
			TextScaled = true,
			FontFace = rbxassetfontsfamiliesSourceSansProjson,
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			object:Create("UIStroke")({
				Color = color3,
				Thickness = 1.5,
				Transparency = 0.7
			})
		})
	end

	local v9 = object:Create("TextButton")
	local v10 = {
		Name = `Slot{p}`,
		BorderSizePixel = 0,
		OnClean = function(animator, folder)
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					animator:LoadAnimation(descendant, {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}, info2):Play()
				end

				if descendant:IsA("ImageLabel") or descendant:IsA("ViewportFrame") then
					animator:LoadAnimation(descendant, {
						ImageTransparency = 1
					}, info2):Play()
				end

				if descendant:IsA("UIStroke") or descendant:IsA("UIShadow") then
					animator:LoadAnimation(descendant, {
						Transparency = 1
					}, info2):Play()
				end
			end

			return {
				Size = animator:Animation(uDim5, info2)
			}
		end,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(math.cos(v2) * 0.5 + 0.5, math.sin(v2) * 0.5 + 0.5),
		Size = size,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		MouseEnter = flag2 and function()
			if not object2:Compare(p) then
				object2:Set(p)
			end
		end or nil,
		MouseLeave = flag2 and function()
			if object2:Compare(p) then
				object2:Set(0)
			end
		end or nil,
		MouseButton1Click = function()
			if text == nil then
				return
			end

			ScreenEffects.CircleClick()
			callback(text)
		end
	}
	local v11 = object:Create("UIShadow")
	local blurRadius

	if text == nil then
		blurRadius = uDim2
	else
		blurRadius = uDim
	end

	local color4

	if text == nil then
		color4 = color2
	else
		color4 = color
	end

	v10[1], v10[2], v10[3] = v11({
	BlurRadius = blurRadius,
	Color = color4,
	Spread = UDim2.fromScale(-0.5, -0.5),
	Transparency = transparency
}), v7, v8
	return v9(v10)
end