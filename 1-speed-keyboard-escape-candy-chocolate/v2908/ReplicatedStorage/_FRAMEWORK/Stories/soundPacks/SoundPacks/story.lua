local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config)
local SoundPacks = require(ReplicatedStorage.FeatureConfigs.SoundPacks)
local SoundPacksView = require(ReplicatedStorage.UISystems.Components.SoundPacksView)
local GamepassPrices = require(ReplicatedStorage.UISystems.Components.GamepassPrices)

local function findModal()
	for _, guiObject in ipairs(StarterGui:GetDescendants()) do
		if guiObject.Name == "KeySoundModal" and guiObject:IsA("GuiObject") then
			return guiObject
		end
	end

	return nil
end

return {
	summary = "KeySoundModal : boutons générés au runtime depuis FeatureConfigs/SoundPacks (pack Free → ClassicSoundPack, packs payants → ScrollingFrame).",
	controls = {
		OwnsPremium = false,
		PreviewSounds = true
	},
	render = function(data)
		local target = data.target
		local modal = findModal()

		if modal then
			local clone = modal:Clone()
			clone.Visible = true
			clone.Parent = target
			local v = {
				owns = data.controls.OwnsPremium == true,
				preview = data.controls.PreviewSounds ~= false
			}
			local random = Random.new()
			local v2 = 0
			local v3 = {}

			local function previewSound(p: string)
				if not v.preview then
					return
				end

				local now = os.clock()

				if now - v2 < SoundPacks.PREVIEW_COOLDOWN then
					return
				end

				v2 = now
				local soundAssets = SoundPacks.ResolveSoundAssets(p)
				local randomAsset = SoundPacks.PickRandomAsset(soundAssets, random)
				local sound = Instance.new("Sound")
				sound.SoundId = randomAsset.assetId
				sound.Volume = SoundPacks.PREVIEW_VOLUME * randomAsset.volume
				sound.Parent = SoundService
				table.insert(v3, sound)
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				pcall(function()
					sound:Play()
				end)
				task.delay(3, function()
					if sound.Parent then
						sound:Destroy()
					end
				end)
			end

			local asyncs = {}
			local v4 = false
			local v5 = nil
			v5 = SoundPacksView.Hydrate(clone, {
				isPackUnlocked = function(_, p)
					return p.unlock.type == "Free" or v.owns
				end,
				getPriceText = function(_, p)
					local v6 = p.unlock.gamepassKey and asyncs[p.unlock.gamepassKey]
					return v6 and GamepassPrices.Format(v6) or nil
				end,
				onSoundActivated = function(p, _, p2, p3)
					if p2 then
						print(("[SoundPacks.story] '%s' locké → prompt gamepass du pack '%s'"):format(p, p3))
						return
					end

					print(("[SoundPacks.story] équipe '%s'"):format(p))
					v5:SetEquipped(p)
					previewSound(p)
				end,
				onSoundHovered = function(p, _, _)
					previewSound(p)
				end
			})
			task.spawn(function()
				local v6 = false

				for _, v7 in ipairs(SoundPacks.GetRequiredGamepassKeys()) do
					local v8 = Config.GAMEPASS_IDS[v7]

					if not (v8 and v8 ~= 0) then
						continue
					end

					local async = GamepassPrices.GetAsync(v8)

					if not async then
						continue
					end

					asyncs[v7] = async
					v6 = true
				end

				if v6 and not v4 then
					v5:RefreshLocks()
				end
			end)
			local v6

			if type(data.subscribe) == "function" then
				v6 = data.subscribe(function(p)
					local v7 = p or data.controls
					v.owns = v7.OwnsPremium == true
					v.preview = v7.PreviewSounds ~= false
					v5:RefreshLocks()
				end)
			else
				v6 = nil
			end

			return function()
				v4 = true

				if type(v6) == "function" then
					v6()
				end

				v5:Destroy()
				clone:Destroy()

				for _, v7 in ipairs(v3) do
					if v7.Parent then
						v7:Destroy()
					end
				end
			end
		else
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.fromScale(1, 0.2)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			textLabel.TextScaled = true
			textLabel.Text = "KeySoundModal introuvable dans StarterGui"
			textLabel.Parent = target
			return function()
				textLabel:Destroy()
			end
		end
	end
}