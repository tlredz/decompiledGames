local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetIconShape = require(ReplicatedStorage.Client.UI.AssetIconShape)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local Audio = require(ReplicatedStorage.Shared.Audio)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local GUI = require(ReplicatedStorage.Client.GUI)
local Message = require(ReplicatedStorage.Client.Message)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local SellPayout = require(ReplicatedStorage.Client.UI.VFX.SellPayout)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Timer = require(ReplicatedStorage.Packages.Timer)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
return {
	Start = function()
		local v = {
			Calculate = function(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, value: number)
				local v2 = math.max(1, p4 + p6)
				local v3 = math.max(1, p5 + p7)
				local columns = math.max(1, (math.floor((p2 + p6) / v2)))
				local canvasHeight = math.max(0, math.ceil(p / columns) * v3 - p7)
				local scrollY = math.clamp(value, 0, (math.max(0, canvasHeight - p3)))
				local v7 = math.floor(scrollY / v3)
				local v8 = math.max(v7, math.ceil((scrollY + p3) / v3) - 1)
				return {
					Columns = columns,
					First = p == 0 and 1 or math.max(0, v7 - 1) * columns + 1,
					Last = math.min(p, (v8 + 2) * columns),
					VisibleFirst = v7 * columns + 1,
					VisibleLast = math.min(p, (v8 + 1) * columns),
					CanvasHeight = canvasHeight,
					ScrollY = scrollY
				}
			end
		}
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tweenInfo3 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tweenInfo5 = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tweenInfo6 = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local uDim = UDim2.fromScale(0.72, 0.85)
		local uDim2 = UDim2.fromScale(0.31, 0.54)
		local tweenInfo7 = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tweenInfo8 = TweenInfo.new(0.098, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo9 = TweenInfo.new(0.18200000000000002, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		local tweenInfo10 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local color = Color3.fromRGB(190, 255, 180)
		local color2 = Color3.fromRGB(120, 120, 140)
		local color3 = Color3.fromRGB(4, 4, 4)
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 255, 0))
		})
		local colorSequence2 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 96, 116)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 64, 82))
		})
		local v2 = {
			Eggs = "Sell Eggs",
			Pets = "Sell Pets"
		}
		local hex = Color3.fromRGB(255, 170, 0):ToHex()
		local hex2 = Color3.fromRGB(0, 255, 8):ToHex()
		local v3 = {
			Eggs = "rbxassetid://103094823152347",
			Pets = "rbxassetid://83736894896123"
		}
		local localPlayer = Players.LocalPlayer
		local sellPrompt = GUI.SellPrompt()
		local frame = sellPrompt:FindFirstChild("Frame")
		assert(frame, "SellPrompt.Frame is missing")
		local header = frame.Header
		local scrollingFrame = frame.ScrollingFrame
		local uIGridLayout = scrollingFrame:FindFirstChildOfClass("UIGridLayout")
		local templateHolder = scrollingFrame.TemplateHolder
		local sortByHolder = frame.SortByHolder
		local sellInfoHolder = frame.SellInfoHolder
		local tabButtonHolder = frame.TabButtonHolder
		local backdrop = sellPrompt:FindFirstChild("Backdrop")
		local sell = sellInfoHolder.Sell
		local weight = sortByHolder.Weight
		local value = sortByHolder.Value
		local selectAll = sortByHolder.SelectAll
		local clear = sortByHolder.Clear
		local petsTab = tabButtonHolder.PetsTab
		local eggsTab = tabButtonHolder.EggsTab
		local maid = Trove.new()
		local v4 = Trove.new()
		local maid2 = Trove.new()
		local v5 = {}
		local v6 = {}
		local v7 = {}
		local v8 = {}
		local v9 = "Pets"
		local v10 = "Value"
		local v11 = true
		local v12 = {}
		local v13 = {}
		local v14 = {}
		local v15 = {}
		local v16 = false
		local count = 0
		local v17 = false
		local v18 = 0
		local v19 = nil
		local v20 = nil
		local v21 = {
			Selling = false,
			Confirming = false
		}
		local v22 = 0
		local count2 = 0
		local count3 = 0
		local v23 = false
		local visibleLast = nil
		local v24 = {}
		local flag = false
		local count4 = 0
		local v25 = false
		local count5 = 0
		local size = frame.Size
		local cellSize = uIGridLayout.CellSize
		local v26 = {}
		local frame2 = Instance.new("Frame")
		frame2.Name = "VisibleCards"
		frame2.BackgroundTransparency = 1
		frame2.BorderSizePixel = 0
		frame2.ClipsDescendants = false
		frame2.Parent = scrollingFrame
		uIGridLayout.Parent = nil
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
		scrollingFrame.ClipsDescendants = true
		maid:Add(uIGridLayout)
		maid:Add(frame2)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function money(p: number)
			if p > 99999 then
				return "$" .. Simple.FormatCompact(math.round(p), ".#")
			end

			return "$" .. Numbers.AddCommas((math.round(p)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function captionOf(instance)
			return instance:FindFirstChildWhichIsA("TextLabel")
		end

		local function namedScale(parent, name: string)
			local uIScale = parent:FindFirstChild(name)

			if uIScale and uIScale:IsA("UIScale") then
				return uIScale
			end

			local uIScale2 = Instance.new("UIScale")
			uIScale2.Name = name
			uIScale2.Parent = parent
			return uIScale2
		end

		local function captureFade(p, options)
			local v27 = {}
			local v28 = {}

			for _, v29 in ipairs(options or {}) do
				v27[v29] = true
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function add(instance, property: string)
				local base = instance[property]

				if typeof(base) == "number" then
					table.insert(v28, {
						Host = instance,
						Property = property,
						Base = base
					})
				end
			end

			local walk

			walk = function(instance)
				if instance ~= p and v27[instance] then
					return
				end

				if instance:IsA("CanvasGroup") then
					add(instance, "GroupTransparency") -- equivalent call inferred; original call site unknown
				else
					if instance:IsA("GuiObject") then
						add(instance, "BackgroundTransparency") -- equivalent call inferred; original call site unknown

						if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
							add(instance, "TextTransparency") -- equivalent call inferred; original call site unknown
							add(instance, "TextStrokeTransparency") -- equivalent call inferred; original call site unknown
						end

						if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
							add(instance, "ImageTransparency") -- equivalent call inferred; original call site unknown
						end
					elseif not instance:IsA("LuaSourceContainer") then
						local success, result = pcall(function()
							return instance.Transparency
						end)

						if success and typeof(result) == "number" then
							add(instance, "Transparency") -- equivalent call inferred; original call site unknown
						end
					end

					for _, child in ipairs(instance:GetChildren()) do
						walk(child)
					end
				end
			end

			walk(p)
			return v28
		end

		local function setFade(list, value2: number)
			local v27 = 1 - math.clamp(value2, 0, 1)

			for _, v28 in ipairs(list) do
				v28.Host[v28.Property] = v28.Base + (1 - v28.Base) * v27
			end
		end

		local function fadeIn(p, tweenInfo11, value2: number?, maid3)
			setFade(p, 0)
			local numberValue = Instance.new("NumberValue")
			local changedConnection = numberValue.Changed:Connect(function(p2: number)
				setFade(p, p2)
			end)
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(
					tweenInfo11.Time,
					tweenInfo11.EasingStyle,
					tweenInfo11.EasingDirection,
					tweenInfo11.RepeatCount,
					tweenInfo11.Reverses,
					tweenInfo11.DelayTime + (value2 or 0)
				),
				{
					Value = 1
				}
			)
			tween:Play()
			local completedConnection = tween.Completed:Once(function()
				changedConnection:Disconnect()
				setFade(p, 1)
				numberValue:Destroy()
			end)

			if maid3 then
				maid3:Add(function()
					completedConnection:Disconnect()
					changedConnection:Disconnect()
					tween:Cancel()
					tween:Destroy()
					setFade(p, 1)
					numberValue:Destroy()
				end)
			end

			return tween
		end

		local function fadeOut(p, tweenInfo11, value2: number?, maid3)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 1
			local changedConnection = numberValue.Changed:Connect(function(p2: number)
				setFade(p, p2)
			end)
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(
					tweenInfo11.Time,
					tweenInfo11.EasingStyle,
					tweenInfo11.EasingDirection,
					tweenInfo11.RepeatCount,
					tweenInfo11.Reverses,
					tweenInfo11.DelayTime + (value2 or 0)
				),
				{
					Value = 0
				}
			)
			tween:Play()

			if maid3 then
				maid3:Add(function()
					changedConnection:Disconnect()
					tween:Cancel()
					tween:Destroy()
					numberValue:Destroy()
				end)
			end

			tween.Completed:Once(function()
				changedConnection:Disconnect()
				numberValue:Destroy()
			end)
			return tween
		end

		local function paintButton(instance, flag2: boolean)
			local uIGradient = instance:FindFirstChildOfClass("UIGradient")

			if uIGradient then
				local color4

				if flag2 then
					color4 = colorSequence
				else
					color4 = colorSequence2
				end

				uIGradient.Color = color4
			end

			local uIStrokeClr = instance:FindFirstChild("UIStrokeClr")

			if uIStrokeClr and uIStrokeClr:IsA("UIStroke") then
				local color4

				if flag2 then
					color4 = color
				else
					color4 = color2
				end

				TweenService:Create(uIStrokeClr, tweenInfo3, {
					Color = color4
				}):Play()
			end

			local uIStroke = instance:FindFirstChild("UIStroke")

			if uIStroke and uIStroke:IsA("UIStroke") then
				local rimRestColor = uIStroke:GetAttribute("RimRestColor")

				if typeof(rimRestColor) ~= "Color3" then
					rimRestColor = uIStroke.Color
					uIStroke:SetAttribute("RimRestColor", rimRestColor)
				end

				if not flag2 then
					rimRestColor = color3
				end

				TweenService:Create(uIStroke, tweenInfo3, {
					Color = rimRestColor
				}):Play()
			end
		end

		local function twitch(imageLabel, p: number)
			if imageLabel == nil then
				return
			end

			local v27 = imageLabel:FindFirstChild("Twitch")

			if not (v27 and v27:IsA("UIScale")) then
				v27 = Instance.new("UIScale")
				v27.Name = "Twitch"
				v27.Parent = imageLabel
			end

			local twitchRotation = imageLabel:GetAttribute("TwitchRotation")

			if typeof(twitchRotation) ~= "number" then
				twitchRotation = imageLabel.Rotation
				imageLabel:SetAttribute("TwitchRotation", twitchRotation)
			end

			v27.Scale = 1.22
			imageLabel.Rotation = twitchRotation + p
			TweenService:Create(v27, tweenInfo7, {
				Scale = 1
			}):Play()
			local tween = TweenService:Create(imageLabel, tweenInfo8, {
				Rotation = twitchRotation - p * 0.45
			})
			tween:Play()
			tween.Completed:Once(function(p2)
				if p2 ~= Enum.PlaybackState.Completed then
					return
				end

				TweenService:Create(imageLabel, tweenInfo9, {
					Rotation = twitchRotation
				}):Play()
			end)
		end

		local function paintTab(parent, flag2: boolean)
			paintButton(parent, flag2)
			local v28 = parent:FindFirstChild("TabSelect")

			if not (v28 and v28:IsA("UIScale")) then
				v28 = Instance.new("UIScale")
				v28.Name = "TabSelect"
				v28.Parent = parent
			end

			TweenService:Create(v28, tweenInfo3, {
				Scale = flag2 and 1.05 or 1
			}):Play()
		end

		local function collectionCheckpoint(p: number, p2: number)
			if p2 <= os.clock() then
				task.wait()
				p2 = os.clock() + 0.002
			end

			return p == count3 and sellPrompt.Enabled, p2
		end

		local function petValue(p)
			local salePrice = AssetItems.SalePrice(p)

			if localPlayer:GetAttribute("VIP") then
				salePrice *= 2
			end

			return salePrice
		end

		local function collectPets(p: number)
			local result = {}
			local v27 = Save.Await()

			if p ~= count3 or not sellPrompt.Enabled then
				return nil
			end

			if v27 == nil then
				return result
			end

			local inventory = v27.Inventory

			if inventory == nil then
				return result
			end

			local v28 = {}

			for _, equippedAsset in ipairs(v27.EquippedAssets) do
				v28[equippedAsset] = true
			end

			local v29 = os.clock() + 0.002

			for k, v30 in pairs(inventory) do
				if v29 <= os.clock() then
					task.wait()
					v29 = os.clock() + 0.002
				end

				local v31

				if p == count3 then
					v31 = sellPrompt.Enabled
				else
					v31 = false
				end

				if not v31 then
					return nil
				end

				local v32, itemData = TryCall(AssetItems.Decode, v30)

				if not v32 or itemData.IsFavorite == true or itemData.InFuse == true or v28[k] then
					continue
				end

				if not Assets.AssetNameExists(itemData.Category) then
					continue
				end

				local v34 = {
					Icon = Assets.Directory[itemData.Category].Icon or "",
					ItemData = itemData,
					Kind = "Pets",
					Rate = AssetEarnings.RatePerSecond(itemData),
					Uid = k,
					Value = 0,
					Weight = 0,
					WeightLabel = 0
				}
				local salePrice = AssetItems.SalePrice(itemData)

				if localPlayer:GetAttribute("VIP") then
					salePrice *= 2
				end

				v34.Value = salePrice
				v34.Weight = AssetItems.WeightKg(itemData)
				v34.WeightLabel = AssetItems.WeightLabel(itemData)
				table.insert(result, v34)
			end

			return result
		end

		local function collectEggs(p: number)
			local result = {}
			local v27 = Save.Await()

			if p ~= count3 or not sellPrompt.Enabled then
				return nil
			end

			local eggInventory = v27 and v27.EggInventory

			if eggInventory == nil then
				return result
			end

			local v28 = os.clock() + 0.002

			for k, v29 in pairs(eggInventory) do
				if v28 <= os.clock() then
					task.wait()
					v28 = os.clock() + 0.002
				end

				local v30

				if p == count3 then
					v30 = sellPrompt.Enabled
				else
					v30 = false
				end

				if not v30 then
					return nil
				end

				if v29.Placement ~= nil then
					continue
				end

				local v31, v32 = TryCall(EggRecords.Decode, v29)

				if not v31 then
					continue
				end

				local v33 = Assets.Directory[v32.AssetCategory]

				if v33 ~= nil then
					table.insert(result, {
						Icon = v33.Egg and v33.Egg.Icon or v33.Icon or "",
						Kind = "Eggs",
						Rate = AssetEarnings.RatePerSecond(EggRecords.ToAssetItemData(v32)),
						Uid = k,
						Value = EggRecords.SellPrice(v32),
						Weight = EggRecords.WeightKg(v32),
						WeightLabel = EggRecords.WeightLabel(v32)
					})
				end
			end

			return result
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sortEntries()
			table.sort(v12, function(a, b)
				local weight2

				if v10 == "Weight" then
					weight2 = a.Weight
				else
					weight2 = a.Value
				end

				local weight3

				if v10 == "Weight" then
					weight3 = b.Weight
				else
					weight3 = b.Value
				end

				if weight2 == weight3 then
					return a.Uid < b.Uid
				end

				if v11 then
					return weight3 < weight2
				end

				return weight2 < weight3
			end)
		end

		local function selectionCount()
			local count6 = 0

			for _ in pairs(v13) do
				count6 += 1
			end

			return count6
		end

		local function popCard(instance, visible: boolean)
			local template = instance:FindFirstChild("Template")

			if template == nil then
				return
			end

			local v27 = template:FindFirstChild("SelectPop")

			if not (v27 and v27:IsA("UIScale")) then
				v27 = Instance.new("UIScale")
				v27.Name = "SelectPop"
				v27.Parent = template
			end

			v27.Scale = visible and 0.88 or 1.06
			TweenService:Create(v27, tweenInfo6, {
				Scale = 1
			}):Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function paintCard(instance, visible: boolean, flag2: boolean?)
			local selectedOverlay = instance:FindFirstChild("SelectedOverlay")
			local selectedIcon = instance:FindFirstChild("SelectedIcon")

			if selectedOverlay and selectedOverlay:IsA("GuiObject") then
				selectedOverlay.Visible = visible
			end

			if selectedIcon and selectedIcon:IsA("GuiObject") then
				selectedIcon.Visible = visible
			end

			if flag2 then
				popCard(instance, visible)
			end
		end

		local function totalLabel()
			local value2 = sellInfoHolder:FindFirstChild("Value")

			if value2 and value2:IsA("TextLabel") then
				return value2
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function writeTotal(p: number)
			local value2 = sellInfoHolder:FindFirstChild("Value")

			if not (value2 and value2:IsA("TextLabel")) then
				value2 = nil
			end

			if value2 then
				local text = money(p) -- equivalent call inferred; original call site unknown
				value2.Text = text
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearTotalRoll()
			if v19 then
				v19:Cancel()
				v19 = nil
			end

			if v20 then
				v20:Destroy()
				v20 = nil
			end
		end

		local function showTotal(total: number, flag2: boolean?)
			if flag2 then
				clearTotalRoll() -- equivalent call inferred; original call site unknown
				v18 = total
				writeTotal(total) -- equivalent call inferred; original call site unknown
			else
				if math.round(total) == math.round(v18) then
					return
				end

				local value2

				if v20 then
					value2 = v20.Value
				else
					value2 = v18
				end

				clearTotalRoll() -- equivalent call inferred; original call site unknown
				v18 = total
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = value2
				v20 = numberValue
				writeTotal(value2) -- equivalent call inferred; original call site unknown
				numberValue.Changed:Connect(writeTotal)
				local tween = TweenService:Create(numberValue, tweenInfo4, {
					Value = total
				})
				tween:Play()
				v19 = tween
				tween.Completed:Once(function(p)
					if v19 ~= tween then
						return
					end

					v19 = nil
					v20 = nil

					if p == Enum.PlaybackState.Completed then
						writeTotal(total) -- equivalent call inferred; original call site unknown
					end

					numberValue:Destroy()
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSellEnabled(flag2: boolean)
			sell.Active = flag2
			sell.AutoButtonColor = flag2
			paintButton(sell, flag2)
		end

		local function refreshFooter()
			local count6 = 0
			local total = 0

			for _, v27 in ipairs(v12) do
				if not v13[v27.Uid] then
					continue
				end

				count6 += 1
				total += v27.Value
			end

			local visible

			if #v12 > 0 then
				visible = count6 == #v12
			else
				visible = false
			end

			local v28 = captionOf(sell) -- equivalent call inferred; original call site unknown

			if v28 then
				v28.Text = count6 == 0 and "Sell" or visible and "Sell All" or `Sell ({count6})`
			end

			setSellEnabled(count6 > 0 and not (v17 or v21.Selling)) -- equivalent call inferred; original call site unknown
			showTotal(total)
			selectAll.Visible = not visible
			clear.Visible = visible
		end

		local function setEverySelected(flag2: boolean)
			if #v12 == 0 or v17 or v21.Selling or v21.Confirming then
				return
			end

			local count6 = 0

			for _, v27 in ipairs(v12) do
				v13[v27.Uid] = flag2 and true or nil
				local v28 = v14[v27.Uid]

				if v28 == nil then
					continue
				end

				local maid3 = v5[v27.Uid]
				count6 += 1
				local v29 = v28
				local v30 = v27
				maid3:Add(task.delay((count6 - 1) * 0.012, function()
					if v29.Parent then
						paintCard(v29, v13[v30.Uid] == true, true)
					end
				end))
			end

			refreshFooter()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function revealPanel()
			v4:Clean()
			fadeIn(captureFade(frame, { scrollingFrame }), tweenInfo5, nil, v4)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showBackdrop(visible: boolean)
			if backdrop == nil then
				return
			end

			local v27 = backdrop
			v27.BackgroundTransparency = 1
			v27.Visible = visible
		end

		local function labelScale(p)
			local parent = p.Parent
			local v27 = 1

			while parent and parent ~= sellPrompt do
				local uIScale = parent:FindFirstChildOfClass("UIScale")

				if uIScale then
					v27 *= uIScale.Scale
				end

				parent = parent.Parent
			end

			if v27 > 0 then
				return v27
			end

			return 1
		end

		local function widthPerPoint(label, text: string)
			local fontFace = label.FontFace
			local formatted = `{fontFace.Family}|{fontFace.Weight.Name}|{fontFace.Style.Name}|{label.RichText}|{text}`
			local v27 = v24[formatted]

			if v27 then
				return v27
			end

			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = text
			getTextBoundsParams.Font = fontFace
			getTextBoundsParams.Size = 100
			getTextBoundsParams.RichText = label.RichText
			local success, result = pcall(function()
				return TextService:GetTextBoundsAsync(getTextBoundsParams)
			end)
			getTextBoundsParams:Destroy()

			if not success or result == nil or result.X <= 0 then
				v25 = true
				return 0.55 * (utf8.len(text) or #text)
			end

			local v28 = result.X / 100
			v24[formatted] = v28
			return v28
		end

		local function fitSize(list)
			table.sort(list, function(a, b)
				return #a.Text > #b.Text
			end)
			local v27 = 1e999
			local count6 = 0

			for _, v28 in ipairs(list) do
				local label = v28.Label

				if label.Parent == nil then
					continue
				end

				local v29 = label.AbsoluteSize / labelScale(label)

				if v29.X <= 0 or v29.Y <= 0 then
					continue
				end

				v27 = math.min(v27, v29.Y)

				if not (count6 < 3) then
					continue
				end

				local v30 = widthPerPoint(label, v28.Text)

				if not (v30 > 0) then
					continue
				end

				count6 += 1
				v27 = math.min(v27, v29.X / v30)
			end

			if v27 == 1e999 then
				return 0
			end

			return v27
		end

		local function refitLabels(p: number)
			if not sellPrompt.Enabled then
				return
			end

			local v28 = {
				Sort = {}
			}

			for _, v29 in ipairs({
				weight,
				value,
				selectAll,
				clear
			}) do
				local label = captionOf(v29) -- equivalent call inferred; original call site unknown

				if label then
					table.insert(v28.Sort, {
						Label = label,
						Text = label.Text
					})
				end
			end

			for _, list in pairs(v26) do
				for _, v29 in ipairs(list) do
					local v30 = v28[v29.Role]

					if v30 == nil then
						v30 = {}
						v28[v29.Role] = v30
					end

					table.insert(v30, {
						Label = v29.Label,
						Text = v29.Text
					})
				end
			end

			for _, list in pairs(v28) do
				local v29 = math.floor((fitSize(list)))

				if p ~= count3 or not sellPrompt.Enabled then
					break
				end

				if v29 <= 0 then
					continue
				end

				local maxTextSize = math.max(v29, 6)

				for _, v31 in ipairs(list) do
					local label = v31.Label

					if label.Parent == nil then
						continue
					end

					local v32 = label:FindFirstChild("FitLimit")

					if v32 == nil or not v32:IsA("UITextSizeConstraint") then
						v32 = Instance.new("UITextSizeConstraint")
						v32.Name = "FitLimit"
						v32.Parent = label
					end

					v32.MaxTextSize = maxTextSize
					label.TextWrapped = false
					label.TextScaled = true
				end
			end
		end

		local queueRefit

		queueRefit = function()
			count4 += 1

			if flag then
				return
			end

			flag = true
			task.defer(function()
				RunService.PreRender:Wait()
				local v27 = count3
				local v28 = count4
				v25 = false
				refitLabels(v27)
				flag = false

				if v27 ~= count3 or not sellPrompt.Enabled then
					return
				end

				if v28 ~= count4 then
					queueRefit()
				end

				if v25 and count5 < 5 then
					count5 += 1
					task.delay(0.4, function()
						if v27 == count3 and sellPrompt.Enabled then
							queueRefit()
						end
					end)
				end
			end)
		end

		local function isPhone()
			local v27 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

			if not (PlatformController.IsMobile() or v27) then
				return false
			end

			local absoluteSize = sellPrompt.AbsoluteSize

			if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
				local currentCamera = Workspace.CurrentCamera

				if currentCamera then
					absoluteSize = currentCamera.ViewportSize
				end
			end

			local v28 = math.min(absoluteSize.X, absoluteSize.Y)
			return not (v28 <= 0) and (v28 <= 550 or math.max(absoluteSize.X, absoluteSize.Y) / v28 >= 1.7)
		end

		local function applyPlatformLayout()
			local phone = isPhone()
			local v27 = frame
			local size2

			if phone then
				size2 = uDim
			else
				size2 = size
			end

			v27.Size = size2
			local v29 = uIGridLayout
			local cellSize2

			if phone then
				cellSize2 = uDim2
			else
				cellSize2 = cellSize
			end

			v29.CellSize = cellSize2
			count4 += 1

			if flag then
				return
			end

			flag = true
			task.defer(function()
				RunService.PreRender:Wait()
				local v31 = count3
				local v32 = count4
				v25 = false
				refitLabels(v31)
				flag = false

				if v31 ~= count3 or not sellPrompt.Enabled then
					return
				end

				if v32 ~= count4 then
					queueRefit()
				end

				if v25 and count5 < 5 then
					count5 += 1
					task.delay(0.4, function()
						if v31 == count3 and sellPrompt.Enabled then
							queueRefit()
						end
					end)
				end
			end)
		end

		local function rollLabel(p, p2: number, callback, text: string, p3: number, maid3)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			p.Text = callback(0)
			local changedConnection = numberValue.Changed:Connect(function(p4: number)
				p.Text = callback(p4)
			end)
			maid3:Add(changedConnection)
			maid3:Add(numberValue)
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(tweenInfo2.Time, tweenInfo2.EasingStyle, tweenInfo2.EasingDirection, 0, false, p3),
				{
					Value = p2
				}
			)
			tween:Play()
			maid3:Add(function()
				tween:Cancel()
				tween:Destroy()
			end)
			maid3:Add(tween.Completed:Once(function(p4)
				changedConnection:Disconnect()

				if p4 == Enum.PlaybackState.Completed then
					p.Text = text
				end

				numberValue:Destroy()
			end))
		end

		local function weightText(p: number)
			return (`({Numbers.AddCommas(p)}Kg)`)
		end

		local function buildCard(data, layoutOrder: number, flag2: boolean)
			local v27 = Trove.new()
			v5[data.Uid] = v27
			local maid3 = Trove.new()
			v27:Add(maid3)

			if flag2 then
				v6[data.Uid] = maid3
			end

			local v28 = {}
			v26[data.Uid] = v28
			local parent = table.remove(v7) or templateHolder:Clone()
			parent.Name = data.Uid
			parent.LayoutOrder = layoutOrder
			parent.Visible = true
			local revealScale = parent:FindFirstChild("RevealScale")

			if revealScale and revealScale:IsA("UIScale") then
				revealScale.Scale = 1
			end

			local v30 = math.min((layoutOrder - 1) * 0.03, 0.7)
			local v31 = math.min(v22 + (layoutOrder - 1) * 0.03, 0.7)
			local template = parent:FindFirstChild("Template")

			if template then
				local icon = template:FindFirstChild("Icon")

				if icon and icon:IsA("ImageLabel") then
					icon.Image = data.Icon

					if data.ItemData == nil then
						AssetIconShape.Strip(icon)
					else
						AssetIconShape.Paint(icon, data.ItemData)
					end
				end

				local weight2 = template:FindFirstChild("Weight")

				if weight2 and weight2:IsA("TextLabel") then
					local formatted = `({data.WeightLabel})`
					table.insert(v28, {
						Label = weight2,
						Role = "Weight",
						Text = formatted
					})

					if flag2 then
						rollLabel(weight2, data.Weight, weightText, formatted, v30, maid3)
					else
						weight2.Text = formatted
					end
				end

				local amount = template:FindFirstChild("Amount")

				if amount and amount:IsA("TextLabel") then
					local v33 = money(data.Rate) -- equivalent call inferred; original call site unknown
					local formatted = `{v33}/s`
					table.insert(v28, {
						Label = amount,
						Role = "Amount",
						Text = formatted
					})

					if flag2 then
						rollLabel(amount, data.Rate, function(p: number)
							local v35 = money(p) -- equivalent call inferred; original call site unknown
							return (`{v35}/s`)
						end, formatted, v30, maid3)
					else
						amount.Text = formatted
					end
				end

				local valueHolder = template:FindFirstChild("ValueHolder")
				local label = valueHolder and valueHolder:FindFirstChild("Value")

				if label and label:IsA("TextLabel") then
					local text = money(data.Value) -- equivalent call inferred; original call site unknown
					table.insert(v28, {
						Label = label,
						Role = "Value",
						Text = text
					})

					if flag2 then
						rollLabel(label, data.Value, money, text, v30, maid3)
					else
						label.Text = text
					end
				end
			end

			paintCard(parent, v13[data.Uid] == true, false) -- equivalent call inferred; original call site unknown

			if v8[parent] == nil then
				local textButton = Instance.new("TextButton")
				textButton.BackgroundTransparency = 1
				textButton.Text = ""
				textButton.Name = "Hitbox"
				textButton.Size = UDim2.fromScale(1, 1)
				textButton.ZIndex = 100
				textButton.Parent = parent
				v8[parent] = ButtonFX(textButton, 1.06, function()
					if v17 or v21.Selling or v21.Confirming or parent.Parent ~= frame2 then
						return
					end

					local name = parent.Name
					v13[name] = not v13[name] or nil
					paintCard(parent, v13[name] == true, true)
					refreshFooter()
				end)
			end

			parent.Parent = frame2
			v14[data.Uid] = parent
			v15[data.Uid] = data

			if flag2 then
				local v33 = parent:FindFirstChild("RevealScale")

				if not (v33 and v33:IsA("UIScale")) then
					v33 = Instance.new("UIScale")
					v33.Name = "RevealScale"
					v33.Parent = parent
				end

				v33.Scale = 0.55
				local tween = TweenService:Create(
					v33,
					TweenInfo.new(tweenInfo.Time, tweenInfo.EasingStyle, tweenInfo.EasingDirection, 0, false, v31),
					{
						Scale = 1
					}
				)
				tween:Play()
				maid3:Add(function()
					tween:Cancel()
					tween:Destroy()
				end)
				fadeIn(captureFade(parent), tweenInfo, v31, maid3)
			end

			if flag2 and count2 < 8 then
				count2 += 1
				maid3:Add(task.delay(v31, function()
					if parent.Parent == nil then
						return
					end

					Audio.Play("rbxassetid://139800881181209", script, {
						PlaybackSpeed = 1.55,
						Volume = 0.11199999999999999
					})
				end))
			end

			return parent
		end

		local v27 = false

		local function finishOpeningReveal()
			v23 = false

			for k, v28 in pairs(v6) do
				v28:Clean()
				local parent = v14[k]

				if parent then
					local v30 = parent:FindFirstChild("RevealScale")

					if not (v30 and v30:IsA("UIScale")) then
						v30 = Instance.new("UIScale")
						v30.Name = "RevealScale"
						v30.Parent = parent
					end

					v30.Scale = 1
				end

				for _, v30 in ipairs(v26[k] or {}) do
					v30.Label.Text = v30.Text
				end

				v6[k] = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyCard(instance)
			local v28 = v8[instance]

			if v28 then
				v28()
				v8[instance] = nil
			end

			instance:Destroy()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeCard(p: string, flag2: boolean?)
			local v28 = v14[p]
			local v29 = v5[p]

			if v29 then
				v29:Destroy()
				v5[p] = nil
			end

			if v28 then
				v14[p] = nil

				if flag2 and #v7 < 24 then
					v28.Parent = nil
					local template = v28:FindFirstChild("Template")
					local selectPop = template and template:FindFirstChild("SelectPop")

					if selectPop then
						selectPop:Destroy()
					end

					table.insert(v7, v28)
				else
					destroyCard(v28) -- equivalent call inferred; original call site unknown
				end
			end

			v26[p] = nil
			v6[p] = nil
			v15[p] = nil
		end

		local function clearCards()
			for k in pairs(v14) do
				removeCard(k, false) -- equivalent call inferred; original call site unknown
			end

			for _, v28 in ipairs(v7) do
				destroyCard(v28) -- equivalent call inferred; original call site unknown
			end

			table.clear(v7)
		end

		local function renderWindow()
			if not v27 or v17 and #v12 == 0 or v21.Selling or not sellPrompt.Enabled then
				return
			end

			local v28 = labelScale(scrollingFrame)
			local v29 = scrollingFrame.AbsoluteSize / v28
			local v30 = scrollingFrame.AbsoluteWindowSize / v28

			if v29.X <= 0 or v29.Y <= 0 or v30.Y <= 0 then
				return
			end

			local cellSize2 = uIGridLayout.CellSize
			local cellPadding = uIGridLayout.CellPadding
			local v31 = v29.X * cellSize2.X.Scale + cellSize2.X.Offset
			local v32 = v29.Y * cellSize2.Y.Scale + cellSize2.Y.Offset
			local v33 = v29.X * cellPadding.X.Scale + cellPadding.X.Offset
			local v34 = v29.Y * cellPadding.Y.Scale + cellPadding.Y.Offset
			local calculated = v.Calculate(
				#v12,
				v30.X,
				v30.Y,
				v31,
				v32,
				v33,
				v34,
				scrollingFrame.CanvasPosition.Y / v28
			)
			local uDim3 = UDim2.fromOffset(v29.X, v29.Y)
			local v35 = frame2.Size ~= uDim3
			frame2.Size = uDim3
			scrollingFrame.CanvasSize = UDim2.fromOffset(0, calculated.CanvasHeight)

			if v23 and visibleLast == nil then
				visibleLast = calculated.VisibleLast
			end

			for k, v36 in pairs(v14) do
				local layoutOrder = v36.LayoutOrder

				if not (layoutOrder < calculated.First or calculated.Last < layoutOrder) then
					continue
				end

				removeCard(k, true)
				v35 = true
			end

			v27 = false
			local v36 = os.clock() + 0.002
			local count6 = 0

			local function mountRange(p: number, p2: number, flag2: boolean)
				for i = p, p2 do
					local v37 = v12[i]
					local v38 = v14[v37.Uid]
					local v39

					if v38 then
						v39 = i - 1
						v38.Size = UDim2.fromOffset(v31, v32)
						v38.Position = UDim2.fromOffset(
							v39 % calculated.Columns * (v31 + v33),
							math.floor(v39 / calculated.Columns) * (v32 + v34)
						)
					else
						local v40

						if flag2 then
							v40 = v23

							if v40 then
								if i <= 24 then
									if i <= (visibleLast or 0) then
										v40 = flag2
									else
										v40 = false
									end
								else
									v40 = false
								end
							end

							v38 = buildCard(v37, i, v40)
							count6 += 1
							v35 = true
							v39 = i - 1
							v38.Size = UDim2.fromOffset(v31, v32)
							v38.Position = UDim2.fromOffset(
								v39 % calculated.Columns * (v31 + v33),
								math.floor(v39 / calculated.Columns) * (v32 + v34)
							)
						else
							if not (count6 >= 4) and not (v36 <= os.clock()) then
								v40 = v23

								if v40 then
									if i <= 24 then
										if i <= (visibleLast or 0) then
											v40 = flag2
										else
											v40 = false
										end
									else
										v40 = false
									end
								end

								v38 = buildCard(v37, i, v40)
								count6 += 1
								v35 = true
								v39 = i - 1
								v38.Size = UDim2.fromOffset(v31, v32)
								v38.Position = UDim2.fromOffset(
									v39 % calculated.Columns * (v31 + v33),
									math.floor(v39 / calculated.Columns) * (v32 + v34)
								)
								continue
							end

							v27 = true
						end
					end
				end
			end

			mountRange(calculated.VisibleFirst, calculated.VisibleLast, true)
			mountRange(calculated.First, calculated.VisibleFirst - 1, false)
			mountRange(calculated.VisibleLast + 1, calculated.Last, false)

			if not v27 then
				v23 = false
				v22 = 0
			end

			if v35 then
				count4 += 1

				if not flag then
					flag = true
					task.defer(function()
						RunService.PreRender:Wait()
						local v37 = count3
						local v38 = count4
						v25 = false
						refitLabels(v37)
						flag = false

						if v37 ~= count3 or not sellPrompt.Enabled then
							return
						end

						if v38 ~= count4 then
							queueRefit()
						end

						if v25 and count5 < 5 then
							count5 += 1
							task.delay(0.4, function()
								if v37 == count3 and sellPrompt.Enabled then
									queueRefit()
								end
							end)
						end
					end)
				end
			end
		end

		local function sameCardContent(data, data2)
			if data.Icon ~= data2.Icon or data.Kind ~= data2.Kind or data.Value ~= data2.Value or data.Rate ~= data2.Rate or data.Weight ~= data2.Weight or data.WeightLabel ~= data2.WeightLabel then
				return false
			end

			local itemData = data.ItemData
			local itemData2 = data2.ItemData

			if itemData == nil or itemData2 == nil then
				return itemData == itemData2
			end

			local images = AssetIconShape.ResolveImages(itemData)
			local images2 = AssetIconShape.ResolveImages(itemData2)
			return images.Icon == images2.Icon and images.RainbowOverlay == images2.RainbowOverlay
		end

		local function rebuild(flag2: boolean?, flag3: boolean?)
			count3 += 1
			count += 1
			v16 = false
			local v28 = count3
			v23 = flag2 == true
			visibleLast = nil
			v17 = true

			if flag3 then
				finishOpeningReveal()
			else
				clearCards()
				v12 = {}
			end

			count2 = 0
			count5 = 0

			if not flag3 then
				scrollingFrame.CanvasPosition = Vector2.zero
			end

			refreshFooter()
			task.defer(function()
				task.wait()

				if v28 ~= count3 or not sellPrompt.Enabled then
					return
				end

				local v29

				if v9 == "Eggs" then
					v29 = collectEggs(v28)
				else
					v29 = collectPets(v28)
				end

				if v29 == nil or v28 ~= count3 or not sellPrompt.Enabled then
					return
				end

				v12 = v29
				sortEntries() -- equivalent call inferred; original call site unknown
				local v30 = {}

				for i, v31 in ipairs(v12) do
					local uid = v31.Uid
					v30[uid] = true
					local v32 = v14[uid]

					if not v32 then
						continue
					end

					local v33 = v15[uid]

					if v33 and sameCardContent(v33, v31) then
						v32.LayoutOrder = i
						v15[uid] = v31
					else
						removeCard(uid, true)
					end
				end

				for k in pairs(v14) do
					if not v30[k] then
						removeCard(k, true)
					end
				end

				for k in pairs(v13) do
					if not v30[k] then
						v13[k] = nil
					end
				end

				v17 = false
				v27 = true
				refreshFooter()
			end)
		end

		local function queueRebuild()
			if v16 or v21.Selling or v21.Confirming or not sellPrompt.Enabled then
				return
			end

			v16 = true
			count += 1
			local v28 = count
			task.delay(0.35, function()
				if v28 ~= count then
					return
				end

				v16 = false

				if sellPrompt.Enabled and not (v21.Selling or v21.Confirming) then
					count3 += 1
					count += 1
					v16 = false
					local v29 = count3
					v23 = false
					visibleLast = nil
					v17 = true
					finishOpeningReveal()
					count2 = 0
					count5 = 0
					refreshFooter()
					task.defer(function()
						task.wait()

						if v29 ~= count3 or not sellPrompt.Enabled then
							return
						end

						local v30

						if v9 == "Eggs" then
							v30 = collectEggs(v29)
						else
							v30 = collectPets(v29)
						end

						if v30 == nil or v29 ~= count3 or not sellPrompt.Enabled then
							return
						end

						v12 = v30
						sortEntries() -- equivalent call inferred; original call site unknown
						local v31 = {}

						for i, v32 in ipairs(v12) do
							local uid = v32.Uid
							v31[uid] = true
							local v33 = v14[uid]

							if not v33 then
								continue
							end

							local v34 = v15[uid]

							if v34 and sameCardContent(v34, v32) then
								v33.LayoutOrder = i
								v15[uid] = v32
							else
								removeCard(uid, true)
							end
						end

						for k in pairs(v14) do
							if not v31[k] then
								removeCard(k, true)
							end
						end

						for k in pairs(v13) do
							if not v31[k] then
								v13[k] = nil
							end
						end

						v17 = false
						v27 = true
						refreshFooter()
					end)
				end
			end)
		end

		local function setCategory(p: string, flag2: boolean?)
			if v21.Selling or v21.Confirming or v9 == p then
				return
			end

			v9 = p
			table.clear(v13)
			local title = header:FindFirstChild("Title")
			local title2Stroke = header:FindFirstChild("Title2Stroke")

			if title and title:IsA("TextLabel") then
				title.Text = v2[p]
			end

			if title2Stroke and title2Stroke:IsA("TextLabel") then
				title2Stroke.Text = v2[p]
			end

			local icon = header:FindFirstChild("Icon")

			if icon and icon:IsA("ImageLabel") then
				icon.Image = v3[p]
			end

			paintTab(petsTab, p == "Pets")
			paintTab(eggsTab, p == "Eggs")

			if flag2 then
				if not (icon and icon:IsA("ImageLabel")) then
					icon = nil
				end

				twitch(icon, 10)
				local v29

				if p == "Pets" then
					v29 = petsTab
				else
					v29 = eggsTab
				end

				twitch(v29:FindFirstChildWhichIsA("ImageLabel"), -12)
			end

			if sellPrompt.Enabled then
				rebuild()
			end
		end

		local function paintSortButtons()
			for _, v29 in ipairs({ weight, value }) do
				local v30 = v29 == weight == (v10 == "Weight")
				paintButton(v29, v30)
				local icon = v29:FindFirstChild("Icon")

				if icon and icon:IsA("ImageLabel") then
					icon.Rotation = v30 and not v11 and -90 or 90
				end
			end
		end

		local function setSort(p: string)
			if v21.Selling or v21.Confirming then
				return
			end

			if v10 == p then
				v11 = not v11
			else
				v10 = p
				v11 = true
			end

			paintSortButtons()
			rebuild()
		end

		local function flyPayout(p)
			local v28 = Save.Await()

			if v28 == nil then
				return
			end

			local money2 = v28.Money
			local v29 = false
			local changedConnection = nil
			changedConnection = Save.Changed:Connect(function(p2: string)
				if p2 ~= "Money" or v29 then
					return
				end

				local v30 = Save.Await()
				local v31 = not v30 and 0 or v30.Money - money2

				if v31 <= 0 then
					return
				end

				v29 = true

				if changedConnection then
					changedConnection:Disconnect()
				end

				SellPayout.Award(v31, p)
			end)
			task.delay(4, function()
				if not v29 and changedConnection then
					changedConnection:Disconnect()
				end
			end)
		end

		local function sell2()
			if v17 or v21.Selling or v21.Confirming then
				return
			end

			local v28 = count3
			local count6 = 0
			local uids = {}
			local uids2 = {}

			for _ in pairs(v13) do
				count6 += 1
			end

			local total = 0

			if count6 == 0 then
				return
			end

			for _, v29 in ipairs(v12) do
				if not v13[v29.Uid] then
					continue
				end

				total += v29.Value

				if v29.Kind == "Eggs" then
					table.insert(uids2, v29.Uid)
				else
					table.insert(uids, v29.Uid)
				end
			end

			local v29 = #uids + #uids2

			if v29 == 0 then
				return
			end

			if v29 == #v12 then
				local v30 = v9 == "Eggs" and "eggs" or "pets"
				v21.Confirming = true
				local confirm = Message.Confirm
				local v34 = money(total) -- equivalent call inferred; original call site unknown
				local v35 = confirm(string.format(
					"Would you like to sell <font color='#%s'>%d %s</font> for <font color='#%s'>%s</font>?",
					hex,
					v29,
					v30,
					hex2,
					v34
				))
				v21.Confirming = false

				if v35 then
					if v28 ~= count3 or v17 or v21.Selling then
						return
					end
				else
					if v16 or v21.Selling or v21.Confirming or not sellPrompt.Enabled then
						return
					end

					v16 = true
					count += 1
					local v36 = count
					task.delay(0.35, function()
						if v36 ~= count then
							return
						end

						v16 = false

						if sellPrompt.Enabled and not (v21.Selling or v21.Confirming) then
							count3 += 1
							count += 1
							v16 = false
							local v37 = count3
							v23 = false
							visibleLast = nil
							v17 = true
							finishOpeningReveal()
							count2 = 0
							count5 = 0
							refreshFooter()
							task.defer(function()
								task.wait()

								if v37 ~= count3 or not sellPrompt.Enabled then
									return
								end

								local v38

								if v9 == "Eggs" then
									v38 = collectEggs(v37)
								else
									v38 = collectPets(v37)
								end

								if v38 == nil or v37 ~= count3 or not sellPrompt.Enabled then
									return
								end

								v12 = v38
								sortEntries() -- equivalent call inferred; original call site unknown
								local v39 = {}

								for i, v40 in ipairs(v12) do
									local uid = v40.Uid
									v39[uid] = true
									local v41 = v14[uid]

									if not v41 then
										continue
									end

									local v42 = v15[uid]

									if v42 and sameCardContent(v42, v40) then
										v41.LayoutOrder = i
										v15[uid] = v40
									else
										removeCard(uid, true)
									end
								end

								for k in pairs(v14) do
									if not v39[k] then
										removeCard(k, true)
									end
								end

								for k in pairs(v13) do
									if not v39[k] then
										v13[k] = nil
									end
								end

								v17 = false
								v27 = true
								refreshFooter()
							end)
						end
					end)
					return
				end
			end

			local v30 = {}
			local v31 = {}

			for _, v32 in ipairs(v12) do
				local v33 = v14[v32.Uid]

				if not (v33 ~= nil and v13[v32.Uid]) then
					continue
				end

				table.insert(v30, v33)
				table.insert(v31, v33.AbsolutePosition + v33.AbsoluteSize / 2)
			end

			if #v31 == 0 then
				local icon = sellInfoHolder:FindFirstChild("Icon")

				if not icon then
					local value2 = sellInfoHolder:FindFirstChild("Value")

					if not (value2 and value2:IsA("TextLabel")) then
						value2 = nil
					end

					icon = value2 or sellInfoHolder
				end

				table.insert(v31, icon.AbsolutePosition + icon.AbsoluteSize / 2)
			end

			flyPayout(v31)
			finishOpeningReveal()
			v21.Selling = true
			maid2:Clean()

			for i, parent in ipairs(v30) do
				local v33 = math.min((i - 1) * 0.02, 0.2)
				local v34 = parent:FindFirstChild("RevealScale")

				if not (v34 and v34:IsA("UIScale")) then
					v34 = Instance.new("UIScale")
					v34.Name = "RevealScale"
					v34.Parent = parent
				end

				local v35 = captureFade(parent)
				local tween = TweenService:Create(
					v34,
					TweenInfo.new(tweenInfo10.Time, tweenInfo10.EasingStyle, tweenInfo10.EasingDirection, 0, false, v33),
					{
						Scale = 0.6
					}
				)
				tween:Play()
				maid2:Add(function()
					tween:Cancel()
					tween:Destroy()
				end)
				fadeOut(v35, tweenInfo10, v33, maid2)
				maid2:Add(function()
					v34.Scale = 1
					setFade(v35, 1)
				end)
			end

			task.delay(0.28, function()
				if v28 ~= count3 then
					return
				end

				maid2:Clean()
				v21.Selling = false

				if sellPrompt.Enabled then
					count3 += 1
					count += 1
					v16 = false
					local v32 = count3
					v23 = false
					visibleLast = nil
					v17 = true
					finishOpeningReveal()
					count2 = 0
					count5 = 0
					refreshFooter()
					task.defer(function()
						task.wait()

						if v32 ~= count3 or not sellPrompt.Enabled then
							return
						end

						local v33

						if v9 == "Eggs" then
							v33 = collectEggs(v32)
						else
							v33 = collectPets(v32)
						end

						if v33 == nil or v32 ~= count3 or not sellPrompt.Enabled then
							return
						end

						v12 = v33
						sortEntries() -- equivalent call inferred; original call site unknown
						local v34 = {}

						for i, v35 in ipairs(v12) do
							local uid = v35.Uid
							v34[uid] = true
							local v36 = v14[uid]

							if not v36 then
								continue
							end

							local v37 = v15[uid]

							if v37 and sameCardContent(v37, v35) then
								v36.LayoutOrder = i
								v15[uid] = v35
							else
								removeCard(uid, true)
							end
						end

						for k in pairs(v14) do
							if not v34[k] then
								removeCard(k, true)
							end
						end

						for k in pairs(v13) do
							if not v34[k] then
								v13[k] = nil
							end
						end

						v17 = false
						v27 = true
						refreshFooter()
					end)
				end
			end)

			local function sendBatches(uids3, flag2: boolean)
				for i = 1, #uids3, 512 do
					local v32 = {}
					table.move(uids3, i, math.min(i + 511, #uids3), 1, v32)
					Remotes.PetSatchel.SellSelection:FireServer({
						Assets = flag2 and {} or v32,
						Eggs = not flag2 and {} or v32
					})
				end
			end

			sendBatches(uids, false)
			sendBatches(uids2, true)
			Audio.Chime("Prompt")
			table.clear(v13)
			refreshFooter()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function guardArena()
			if ToolGameplayGuard.IsLocalInsideArena() and Tabs.IsActive("SellPrompt") then
				Tabs.Deactivate()
			end
		end

		sellPrompt.Enabled = false
		templateHolder.Visible = false

		if backdrop then
			backdrop.Visible = false
		end

		maid:Add(ButtonFX(petsTab, 1.06, function()
			setCategory("Pets", true)
		end))
		maid:Add(ButtonFX(eggsTab, 1.06, function()
			setCategory("Eggs", true)
		end))
		maid:Add(ButtonFX(weight, 1.06, function()
			if not v21.Selling then
				if v21.Confirming then
					return
				end

				if v10 == "Weight" then
					v11 = not v11
				else
					v10 = "Weight"
					v11 = true
				end

				paintSortButtons()
				rebuild()
			end
		end))
		maid:Add(ButtonFX(value, 1.06, function()
			if not v21.Selling then
				if v21.Confirming then
					return
				end

				if v10 == "Value" then
					v11 = not v11
				else
					v10 = "Value"
					v11 = true
				end

				paintSortButtons()
				rebuild()
			end
		end))
		maid:Add(ButtonFX(sell, 1.08, sell2))
		setCategory("Eggs")
		setCategory("Pets")
		paintSortButtons()
		maid:Add(ButtonFX(selectAll, 1.06, function()
			setEverySelected(true)
		end))
		maid:Add(ButtonFX(clear, 1.06, function()
			setEverySelected(false)
		end))
		maid:Add(sellPrompt:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyPlatformLayout))
		maid:Add(PlatformController.Changed:Connect(applyPlatformLayout))
		maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			v27 = true
		end))
		maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
			v27 = true
		end))
		maid:Add(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if scrollingFrame.CanvasPosition.Y ~= 0 then
				finishOpeningReveal()
			end

			v27 = true
		end))
		maid:Add(uIGridLayout:GetPropertyChangedSignal("CellSize"):Connect(function()
			v27 = true
		end))
		maid:Add(RunService.Heartbeat:Connect(renderWindow))
		maid:Add(v4)
		maid:Add(maid2)
		maid:Add(function()
			count3 += 1
			count += 1
			v27 = false
			clearCards()
		end)
		local phone = isPhone()

		if phone then
			size = uDim
		end

		frame.Size = size

		if phone then
			cellSize = uDim2
		end

		uIGridLayout.CellSize = cellSize
		count4 += 1

		if not flag then
			flag = true
			task.defer(function()
				RunService.PreRender:Wait()
				local v28 = count3
				local v29 = count4
				v25 = false
				refitLabels(v28)
				flag = false

				if v28 ~= count3 or not sellPrompt.Enabled then
					return
				end

				if v29 ~= count4 then
					queueRefit()
				end

				if v25 and count5 < 5 then
					count5 += 1
					task.delay(0.4, function()
						if v28 == count3 and sellPrompt.Enabled then
							queueRefit()
						end
					end)
				end
			end)
		end

		if backdrop then
			maid:Add(backdrop.Activated:Connect(function()
				Tabs.Deactivate()
			end))
		end

		maid:Add(Tabs.Activated:Connect(function(p: string)
			if p ~= "SellPrompt" then
				return
			end

			showBackdrop(true) -- equivalent call inferred; original call site unknown

			if v21.Confirming then
				count4 += 1

				if flag then
					return
				end

				flag = true
				task.defer(function()
					RunService.PreRender:Wait()
					local v28 = count3
					local v29 = count4
					v25 = false
					refitLabels(v28)
					flag = false

					if v28 ~= count3 or not sellPrompt.Enabled then
						return
					end

					if v29 ~= count4 then
						queueRefit()
					end

					if v25 and count5 < 5 then
						count5 += 1
						task.delay(0.4, function()
							if v28 == count3 and sellPrompt.Enabled then
								queueRefit()
							end
						end)
					end
				end)
			else
				table.clear(v13)
				v21.Selling = false
				clearTotalRoll() -- equivalent call inferred; original call site unknown
				v18 = 0
				local value2 = sellInfoHolder:FindFirstChild("Value")

				if not (value2 and value2:IsA("TextLabel")) then
					value2 = nil
				end

				if value2 then
					value2.Text = "$" .. Numbers.AddCommas(0)
				end

				count4 += 1

				if not flag then
					flag = true
					task.defer(function()
						RunService.PreRender:Wait()
						local v28 = count3
						local v29 = count4
						v25 = false
						refitLabels(v28)
						flag = false

						if v28 ~= count3 or not sellPrompt.Enabled then
							return
						end

						if v29 ~= count4 then
							queueRefit()
						end

						if v25 and count5 < 5 then
							count5 += 1
							task.delay(0.4, function()
								if v28 == count3 and sellPrompt.Enabled then
									queueRefit()
								end
							end)
						end
					end)
				end

				revealPanel() -- equivalent call inferred; original call site unknown
				v22 = 0.08
				rebuild(true)
			end
		end))
		maid:Add(Tabs.Deactivated:Connect(function(p: string, p2)
			if p == "SellPrompt" then
				showBackdrop(false) -- equivalent call inferred; original call site unknown

				if v21.Confirming and p2.replacedBy == "Message" then
					finishOpeningReveal()
					return
				end

				count3 += 1
				count += 1
				v16 = false
				v17 = false
				v21.Selling = false
				v27 = false
				v4:Clean()
				maid2:Clean()
				clearCards()
				table.clear(v24)
			end
		end))
		maid:Add(Save.WatchFields({ "Inventory", "EggInventory", "EquippedAssets" }, queueRebuild))
		maid:Add(Timer.Simple(0.1, guardArena, true))
		maid:AttachToInstance(script)
		guardArena() -- equivalent call inferred; original call site unknown
	end
}