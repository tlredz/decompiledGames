local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local ContentProvider = game:GetService("ContentProvider")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v3 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Packages.Trove)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Shared.Inventory)
local v8 = require3(ReplicatedStorage2.Shared.Emotes)
local v9 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v10 = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v11 = require3(ReplicatedStorage2.Shared.EmotesShared)
local v12 = require3(ReplicatedStorage2.Packages.Signal)
local v13 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v14 = require3(ReplicatedStorage2.Shared.LimitedSwordPacksData)
require3(ReplicatedStorage2.Shared.LimitedSwordPacksData.GiftToBundle)
require3(ReplicatedStorage2.Shared.LimitedSwordPacksData.BundleToPack)
local scope = require3("@game/ReplicatedStorage/Common/Logger").namespace("Shared", {
	enabled = true
}):scope("NPCLobbyAnimation")
local v15 = v12.new()
local v16 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local innerShowRooms = ReplicatedStorage2.Misc.ShowRooms.SwordPacks.InnerShowRooms

local function preloadShowroomAnimations(items)
	local v17 = {}

	for _, item in items do
		local animation = item.Animation

		if not (animation and animation:IsA("Animation")) then
			continue
		end

		table.insert(v17, animation)

		if animation.AnimationId ~= "" then
			table.insert(v17, animation.AnimationId)
		end
	end

	if #v17 > 0 then
		task.spawn(function()
			ContentProvider:PreloadAsync(v17)
		end)
	end
end

local function createFromEmoteName(name)
	local v17 = v8[name]

	if not v17 then
		local v18 = v16:GetCollection()[name] ~= nil
		v17 = {
			VFX = v18 and name,
			Emote = ReplicatedStorage2.Misc.Emotes[name],
			Play = v18 and v10
		}
	end

	return {
		Animation = v17.Emote,
		FX = v17.Play and function(parent, emoteScale, maid, _: string)
			local folder = Instance.new("Folder")
			maid:Add(folder)
			folder.Name = "EmoteVFX_Storage"
			folder.Parent = parent
			parent:SetAttribute("EmoteScale", emoteScale)
			local v18 = v17.Play(v17, parent, true)

			if v18 then
				maid:Add(v18)
			end

			maid:Add(function()
				v17.Play(v17, parent, false)
			end)
			return v18
		end or function() end
	}
end

local function getSwordFX(name: string)
	for _, v17 in v16:GetCollection() do
		if v17.Sword == name then
			return (createFromEmoteName(v17.Name))
		end
	end

	return nil
end

local function getStartDate(p)
	return p.FFlagStartTime and v9:GetKey(p.FFlagStartTime) or p.RootFFlagStartTime and v9:GetKey(p.RootFFlagStartTime) or 0
end

local function getEndDate(p)
	return p.FFlagEndTime and v9:GetKey(p.FFlagEndTime) or p.RootFFlagEndTime and v9:GetKey(p.RootFFlagEndTime)
end

local function fixTable(items)
	local result = {}

	for k, item in items do
		if item ~= nil then
			result[k] = item
		end
	end

	return result
end

local function getBundleColor(name: string)
	for _, v17 in v14 do
		for _, reward in v17.Rewards do
			if reward.ShowRoom == name then
				return reward.Color
			end

			for _, v18 in reward.Rewards or {} do
				if v18.ShowRoom == name then
					return reward.Color
				end
			end
		end
	end

	return nil
end

local function toGradientSequence(bundleColor)
	if typeof(bundleColor) == "ColorSequence" then
		return bundleColor
	end

	if typeof(bundleColor) ~= "Color3" then
		return nil
	end

	local HSV, v17, v18 = bundleColor:ToHSV()
	local v19 = math.max(v18, 0.35)
	local color = Color3.fromHSV(HSV, v17, v19)
	local v20 = v17 < 0.05
	local v21 = color.R * 0.2126 + color.G * 0.7152 + color.B * 0.0722 >= 0.55
	local v22 = (HSV + (v20 and 0 or math.clamp(((v21 and 0.75 or 0.15) - HSV + 0.5) % 1 - 0.5, -0.03, 0.03))) % 1

	if not v21 then
		local color2 = Color3.fromHSV(v22, v17 * 0.8, v19 + (1 - v19) * 0.55)
		return ColorSequence.new(color2, color)
	end

	if not v20 then
		v17 = math.min(v17 * 1.1 + 0.05, 1)
	end

	local color2 = Color3.fromHSV(v22, v17, (math.max(v19 * 0.72, 0.35)))
	return ColorSequence.new(color, color2)
end

local function useShowRoom(child, p: string, attribute: string)
	local bundleColor = getBundleColor(child.Name) or Color3.new(1, 1, 1)
	local billboardGui = child:FindFirstChildWhichIsA("BillboardGui", true)
	local uIGradient = billboardGui and billboardGui:FindFirstChildWhichIsA("UIGradient", true)
	local uIStroke = billboardGui and billboardGui:FindFirstChildWhichIsA("UIStroke", true)
	local parent

	if uIStroke or uIGradient then
		parent = (uIStroke or uIGradient).Parent
	else
		parent = uIGradient
	end

	local textColor

	if parent and parent:IsA("TextLabel") then
		textColor = parent.TextColor3
	else
		textColor = Color3.new(1, 1, 1)
	end

	return {
		Name = attribute,
		Type = p,
		Gradient = uIGradient,
		UIStroke = uIStroke,
		BundleColor = bundleColor,
		TextColor3 = textColor
	}
end

local function getShowRoomByName(value: string)
	local child = innerShowRooms:FindFirstChild(string.gsub(value, "%s+", "") .. "ShowRoom")

	if not child then
		scope:warn((`ShowRoom {value} not found`))
		return
	end

	local _1 = child.NPCS["1"]
	local v17 = _1:GetAttribute("Sword") and "Sword" or _1:GetAttribute("Emote") and "Emote" or nil

	if not v17 then
		scope:warn((`No attribute {v17} in npc {_1.Name}`))
		return
	end

	local attribute = _1:GetAttribute(v17)

	if attribute then
		return (useShowRoom(child, v17, attribute))
	end

	scope:warn((`No attribute {v17} in npc {_1.Name}`))
end

return function(instance)
	workspace:WaitForChild("Spawn", 1000000)
	local maid = v5.new()
	local v17 = {}

	local function CreateSword(p)
		local v18 = v17[p]
		local instance2 = v18 and v2:GetInstance(v18)
		local v19 = not (instance2 and instance2:GetAttribute("HideSword")) and v3:EquipSwordTo(
			instance,
			p,
			nil,
			v18 == "Emote711" or instance2 and instance2:GetAttribute("HideAccessory") == true
		)

		if v19 then
			v19.Name = "EquippedSword"
		end

		if v18 then
			local v20 = v11:Play(instance, maid, v18, true, workspace:GetServerTimeNow(), nil, nil, true)

			if v20 then
				local v21 = {}

				for _, v22 in v20 do
					table.insert(v21, v22)
					v22.Looped = false
					local v23 = v22

					local function stop()
						local index = table.find(v21, v23)

						if index then
							table.remove(v21, index)
						end

						v15:Fire()
					end

					maid:Add(v22:GetMarkerReachedSignal("GOTO"):Once(stop))
					maid:Add(v22.DidLoop:Once(stop))
					maid:Add(v22.Stopped:Once(stop))
				end

				while #v21 > 0 do
					v15:Wait()
				end
			end

			maid:Clean()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateStand(limitedSword)
		task.defer(function()
			local boards = workspace:WaitForChild("Spawn"):FindFirstChild("Boards")

			if boards then
				boards.Right.Screen:SetAttribute("LimitedSword", limitedSword)
				boards.Right.Screen:SetAttribute("ShowLimitedSword", false)
				boards.Right.Screen:SetAttribute("ShowLimitedSword", true)
			end
		end)
	end

	local v18 = {}

	for k, v19 in {
		getShowRoomByName("Verdant Thorn Blade"),
		getShowRoomByName("Verdant Thorn Lance"),
		getShowRoomByName("Ryuzakura Katana"),
		getShowRoomByName("Cherub"),
		getShowRoomByName("Swan Serenity")
	} do
		if v19 ~= nil then
			v18[k] = v19
		end
	end

	for _, v19 in v18 do
		if v19.Type ~= "Sword" then
			continue
		end

		local swordFX = getSwordFX(v19.Name)

		if swordFX then
			v19.Animation = swordFX.Animation
		else
			scope:warn("[!!] failed to find SwordFX for", v19.Name)
		end
	end

	for _, v19 in v18 do
		if v19.Type == "Sword" then
			if v19.Animation then
				v17[v19.Name] = v19.Animation.Name
			else
				scope:warn("[!!] failed to find animation for", v19.Name)
			end
		else
			local v20 = createFromEmoteName(v19.Name)
			v19.Animation = v20.Animation
			v17[v19.Name] = v20.Animation
		end
	end

	local uIGradient = instance.BillboardGui.RankedLabel.UIGradient
	local uIStroke = instance.BillboardGui.RankedLabel.UIStroke
	local v19 = v.isDevPlaceGame() or v.isTestGame()
	preloadShowroomAnimations(v18)

	while true do
		for k, v20 in v18 do
			if v20.Animation then
				local name = v20.Name
				v4.Client:WaitReplion("Data")

				if k == #v18 or v19 or not (#v7.Client:FindItems(v20.Type, name) > 0) then
					local equippedSword = instance:FindFirstChild("EquippedSword")

					if equippedSword then
						equippedSword:Destroy()
					end

					maid:Clean()
					local v21 = v20
					local name2 = name
					local v23 = k
					xpcall(function()
						if v21.Type == "Emote" then
							instance.BillboardGui.ImageLabel.Image = v6.Icons:GetEmoteIcon(name2) or v6.Icons:GetIcon("DEFAULT_MISSING")
						else
							instance.BillboardGui.ImageLabel.Image = v6.Icons:GetSwordIcon(name2) or v6.Icons:GetIcon("DEFAULT_MISSING")
						end

						local v24 = v13[v21.Type][name2]
						local rankedLabel = instance.BillboardGui.RankedLabel
						rankedLabel.Text = v24 and string.upper(v24.DisplayName) or string.upper(name2)
						rankedLabel.TextColor3 = v21.TextColor3 or rankedLabel.TextColor3
						local uIStroke2 = v21.UIStroke

						if uIStroke2 then
							uIStroke.Color = uIStroke2.Color
							uIStroke.Enabled = uIStroke2.Enabled
							uIStroke.Thickness = uIStroke2.Thickness
							uIStroke.LineJoinMode = uIStroke2.LineJoinMode
							uIStroke.ApplyStrokeMode = uIStroke2.ApplyStrokeMode
						else
							uIStroke.Color = Color3.new()
							uIStroke.Enabled = true
						end

						local gradient = v21.Gradient

						if gradient then
							for k2, tag in uIGradient:GetTags() do
								uIGradient:RemoveTag(tag)
							end

							for k2 in uIGradient:GetAttributes() do
								uIGradient:SetAttribute(k2, nil)
							end

							uIGradient.Color = gradient.Color
							uIGradient.Offset = gradient.Offset
							uIGradient.Enabled = gradient.Enabled
							uIGradient.Rotation = gradient.Rotation
							uIGradient.Transparency = gradient.Transparency

							for k2, v25 in gradient:GetAttributes() do
								uIGradient:SetAttribute(k2, v25)
							end

							for k2, tag in gradient:GetTags() do
								uIGradient:AddTag(tag)
							end
						else
							uIGradient.Color = toGradientSequence(v21.BundleColor)
							uIGradient.Enabled = true
						end

						UpdateStand(name2) -- equivalent call inferred; original call site unknown

						if v21.Type == "Sword" then
							CreateSword(name2)
							return
						end

						local v26 = v11:Play(instance, maid, name2, true, workspace:GetServerTimeNow(), nil, nil, true)

						if v26 then
							local v27 = {}

							for k2, v28 in v26 do
								table.insert(v27, v28)
								v28.Looped = false
								local v29 = {}
								local timePositions = v29
								local v30 = v28
								maid:Add(v28:GetMarkerReachedSignal("Pin"):Connect(function(p: string)
									timePositions[p] = v30.TimePosition
								end))
								local v32 = v28

								local function gotoReached(value: string?)
									if v23 == #v18 and type(value) == "string" then
										local timePosition = v29[value]

										if timePosition then
											v32.TimePosition = timePosition
										end
									else
										local index = table.find(v27, v32)

										if index then
											table.remove(v27, index)
										end

										v15:Fire()
									end
								end

								maid:Add(v28:GetMarkerReachedSignal("GOTO"):Once(gotoReached))
								maid:Add(v28.DidLoop:Once(gotoReached))
								maid:Add(v28.Stopped:Once(gotoReached))
							end

							while #v27 > 0 do
								v15:Wait()
							end
						end

						maid:Clean()
					end, function(p)
						scope:error(p)
					end)
				end
			else
				scope:warn("[!!] failed to find EmoteVFX Animation for Sword", v20.Name)
			end
		end

		task.wait()
	end
end