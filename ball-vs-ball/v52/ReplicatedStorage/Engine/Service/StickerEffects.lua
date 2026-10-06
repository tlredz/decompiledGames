local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local StickerEffects = {
	client = {}
}
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("悬浮UI"):WaitForChild("贴纸显示小人"):WaitForChild("贴纸展示")
local v2 = StarterGui:WaitForChild("贴纸素材"):WaitForChild("素材面板")
local v3 = {}

function StickerEffects.getVisual(childName: string)
	local v4 = v3[childName]

	if v4 then
		return v4
	end

	local child = v2:FindFirstChild(childName)

	if not child then
		warn((`[StickerEffects] 贴纸素材面板缺少 "{childName}" 对应模板`))
		return nil
	end

	local firstChild = child:FindFirstChild("贴纸符号")
	local firstChild2 = child:FindFirstChild("贴纸图片")
	local firstChild3 = child:FindFirstChild("音效")
	local v5 = {
		symbolText = not firstChild and "" or firstChild.Text,
		symbolVisible = firstChild ~= nil and firstChild.Visible,
		image = not firstChild2 and "" or firstChild2.Image,
		imageVisible = firstChild2 ~= nil and firstChild2.Visible,
		sound = 0
	}
	local sound

	if firstChild3 then
		sound = firstChild3.SoundId
	end

	v5.sound = sound
	v3[childName] = v5
	return v5
end

local v4 = {}

function StickerEffects.client.isMuted()
	return client.settings.soundEffectsEnabled() == false
end

local function buildBillboard()
	local clone = v:Clone()
	local v5 = clone:WaitForChild("背景")
	local v6 = v5:WaitForChild("贴纸符号")
	local v7 = v5:WaitForChild("贴纸图片")
	v5.Size = UDim2.new(0, 0, 0, 0)
	return clone, v5, v6, v7
end

local function playSound(head, sound: string?)
	if StickerEffects.client.isMuted() or typeof(sound) ~= "string" or sound == "" then
		return
	end

	local sound2 = Instance.new("Sound")
	sound2.SoundId = sound
	sound2.Volume = 0.25
	sound2.RollOffMaxDistance = 35
	sound2.Parent = head
	sound2:Play()
	sound2.Ended:Once(function()
		sound2:Destroy()
	end)
	task.delay(5, function()
		if sound2.Parent then
			sound2:Destroy()
		end
	end)
end

function StickerEffects.playForPlayer(player, p: string)
	local v5 = Config.skin.byCnId[p]

	if not v5 or v5.skinType ~= "贴纸" then
		return
	end

	local visual = StickerEffects.getVisual(p)

	if not visual then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		return
	end

	local v6 = v4[player]

	if v6 then
		v6.billboard:Destroy()
	end

	local generation = (not v6 and 0 or v6.generation) + 1
	local billboard, v8, v9, v10 = buildBillboard()
	v9.Text = visual.symbolText
	v9.Visible = visual.symbolVisible
	v10.Image = visual.image
	v10.Visible = visual.imageVisible
	billboard.Adornee = head
	billboard.Parent = head
	v4[player] = {
		billboard = billboard,
		generation = generation
	}
	playSound(head, visual.sound)
	TweenService:Create(v8, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	task.delay(1.9000000000000001, function()
		local v11 = v4[player]

		if not v11 or v11.generation ~= generation then
			return
		end

		TweenService:Create(billboard, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			StudsOffset = billboard.StudsOffset + createVector(0, 2.2, 0)
		}):Play()
		TweenService:Create(v8, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		local tween = TweenService:Create(v9, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1
		})
		local tween2 = TweenService:Create(v10, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		})
		tween:Play()
		tween2:Play()
		tween.Completed:Once(function()
			if v4[player] and v4[player].generation == generation then
				v4[player] = nil
			end

			billboard:Destroy()
		end)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	v4[player] = nil
end)
return StickerEffects