-- failed to load script (decompiled with syntax error):
-- VmSlGTAuAfAYctMozMPxiZhoJ:296: Expected identifier when parsing expression, got ';'

local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
return {
	Init = function()
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local DiamondTopUpService = require(ReplicatedStorage.Engine.Service.DiamondTopUpService)
		local TweenService = game:GetService("TweenService")
		local RunService = game:GetService("RunService")
		local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
		local BattleConfig = require(battleDemo:WaitForChild("BattleConfig"))
		local SkillFeatureParser = require(battleDemo:WaitForChild("SkillFeatureParser"))
		local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
		local CurrencyService = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("CurrencyService"))
		local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
		local client = PlayerData.client
		local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
		local SlotMachineCard = require(script:WaitForChild("SlotMachineCard"))
		local CardExitEffects = require(script:WaitForChild("CardExitEffects"))
		local remoteEvent = Net:RemoteEvent("DuelTableBallOffer")
		local remoteEvent2 = Net:RemoteEvent("DuelTableBallSelect")
		local remoteEvent3 = Net:RemoteEvent("DuelTableBallLocked")
		local remoteEvent4 = Net:RemoteEvent("DuelTableUpgradeOffer")
		local remoteEvent5 = Net:RemoteEvent("DuelTableUpgradeSelect")
		local remoteEvent6 = Net:RemoteEvent("DuelTableUpgradeLocked")
		local remoteEvent7 = Net:RemoteEvent("DuelTableState")
		local remoteEvent8 = Net:RemoteEvent("DuelTableBallReroll")
		local remoteEvent9 = Net:RemoteEvent("DuelTableBallRerollResult")
		local remoteEvent10 = Net:RemoteEvent("DuelTableUpgradeReroll")
		local remoteEvent11 = Net:RemoteEvent("DuelTableUpgradeRerollResult")
		local remoteEvent12 = Net:RemoteEvent("DuelTableRerollDenied")
		local remoteEvent13 = Net:RemoteEvent("DuelTableBallSelectPurchase")
		local remoteEvent14 = Net:RemoteEvent("DuelTableBallSelectPurchaseResult")
		local remoteEvent15 = Net:RemoteEvent("DuelTableBallSelectDenied")
		local remoteEvent16 = Net:RemoteEvent("DuelTableBallSelfSelect")
		local remoteEvent17 = Net:RemoteEvent("DuelTableBallSelectConfirmed")
		local remoteEvent18 = Net:RemoteEvent("DuelTableBallSelectConfirmDenied")
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local root = playerGui:WaitForChild("战斗3选1"):WaitForChild("背景")
		local main = root:WaitForChild("主容器")
		local v3 = main:WaitForChild("标题文本")
		local v4 = main:WaitForChild("卡牌列表")
		local colors = main:WaitForChild("重抽按钮")
		local pick = main:WaitForChild("自选按钮")
		local panel = root:WaitForChild("自选球")
		local v7 = panel:WaitForChild("球列表")
		local _1 = v7:WaitForChild("小球1")
		local v8 = panel:WaitForChild("文本")
		local v9 = panel:WaitForChild("按钮")
		local confirm = v9:WaitForChild("确定按钮")
		local back = v9:WaitForChild("返回按钮")
		local cards = {}
		table.insert(cards, (v4:WaitForChild("选项卡" .. 1)))
		table.insert(cards, (v4:WaitForChild("选项卡" .. 2)))
		table.insert(cards, (v4:WaitForChild("选项卡" .. 3)))

		local function resetAllSlotMachines()
			for _, v13 in ipairs(cards) do
				CardExitEffects.reset(v13)
				SlotMachineCard.reset(v13)
			end
		end

		local v13 = colors:WaitForChild("价格")
		local v14 = pick:WaitForChild("价格")
		local v15 = pick:WaitForChild("自选卡图标")
		local v16 = pick:WaitForChild("钻石图标")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getVoucherCount()
			local v17 = client.vouchers["指定卡"]()

			if typeof(v17) == "number" then
				return v17
			end

			return 0
		end

		colors.Visible = false
		pick.Visible = false
		panel.Visible = false
		_1.Visible = false
		confirm.Active = false

		for _, button in ipairs(v7:GetChildren()) do
			if button:IsA("GuiButton") and button ~= _1 then
				button:Destroy()
			end
		end

		local v17 = playerGui:WaitForChild("货币"):WaitForChild("货币栏")
		local currentCamera = workspace.CurrentCamera
		local size = main.Size
		local scale = size.X.Scale
		local scale2 = size.Y.Scale
		local sizeConstraint = main.SizeConstraint

		local function updateContainerSize()
			local viewportSize = currentCamera.ViewportSize
			local X = viewportSize.X
			local Y = viewportSize.Y
			local v18, v19

			if sizeConstraint == Enum.SizeConstraint.RelativeXX then
				local v20 = scale / scale2
				v18 = X * scale
				v19 = X * scale2

				if Y * 0.72 < v19 then
					v19 = Y * 0.72
					v18 = v19 * v20
				end

				if X * 0.92 < v18 then
					v18 = X * 0.92
					v19 = v18 / v20
				end
			elseif sizeConstraint == Enum.SizeConstraint.RelativeYY then
				local v20 = scale / scale2
				v18 = Y * scale
				v19 = Y * scale2

				if Y * 0.72 < v19 then
					v19 = Y * 0.72
					v18 = v19 * v20
				end

				if X * 0.92 < v18 then
					v18 = X * 0.92
					v19 = v18 / v20
				end
			else
				v18 = math.min(X * scale, X * 0.92)
				v19 = math.min(Y * scale2, Y * 0.72)
			end

			main.Size = UDim2.fromOffset(math.floor(v18), (math.floor(v19)))
		end

		updateContainerSize()
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateContainerSize)
		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tweenInfo4 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v18 = nil
		local v19 = {}

		local function setWeeklyFreeRoleIds(weeklyFreeRoleIds)
			v19 = {}

			if typeof(weeklyFreeRoleIds) == "table" then
				for _, item in weeklyFreeRoleIds do
					if typeof(item) == "string" then
						v19[item] = true
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setWeeklyFreeLabel(instance, roleId: string?)
			local label = instance:FindFirstChild("周免标签")

			if label and label:IsA("TextLabel") then
				label.Visible = roleId ~= nil and v19[roleId] == true
			end
		end

		for _, v20 in cards do
			local label = v20:FindFirstChild("周免标签")

			if label and label:IsA("TextLabel") then
				label.Visible = false
			end
		end

		local label = _1:FindFirstChild("周免标签")

		if label and label:IsA("TextLabel") then
			label.Visible = false
		end

		local v20 = false
		local v21 = nil
		local v22 = false
		local v23 = false
		local v24 = nil
		local roleId = nil
		local v25 = nil
		local v26 = 0
		local renderSteppedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playTween(p, p2, p3)
			local tween = TweenService:Create(p, p2, p3)
			tween:Play()
			return tween
		end

		local function bounceButton(instance)
			local size2 = instance.Size
			TweenService:Create(instance, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(size2.X.Scale * 0.94, 0, size2.Y.Scale * 0.94, 0)
			}):Play()
			task.delay(0.06, function()
				if instance.Parent then
					TweenService:Create(instance, tweenInfo, {
						Size = size2
					}):Play()
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setCardsInteractable(active: boolean)
			for _, v27 in ipairs(cards) do
				v27.Active = active
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setRerollAvailable(rerollPrice)
			if typeof(rerollPrice) ~= "number" or not (rerollPrice > 0) then
				colors.Visible = false
				return
			end

			colors.Visible = true
			v13.Text = tostring((math.floor(rerollPrice)))
		end

		local function setSelectAvailable(value)
			if typeof(value) == "number" and value >= 0 then
				v25 = value
				pick.Visible = true
				pick.Active = true

				if value == 0 then
					v14.Text = "Free"
					v15.Visible = false
					v16.Visible = false
				elseif getVoucherCount() > 0 then
					v14.Text = "x" .. tostring(getVoucherCount())
					v15.Visible = true
					v16.Visible = false
				else
					v14.Text = tostring((math.floor(value)))
					v15.Visible = false
					v16.Visible = true
				end
			else
				v25 = nil
				pick.Visible = false
				pick.Active = false
			end
		end

		local v27 = {}

		local function playButtonShakeFeedback(colorsByColorProperty)
			local v28 = v27[colorsByColorProperty]

			if not v28 then
				v28 = {
					originalPosition = colorsByColorProperty.Position,
					colorProperty = colorsByColorProperty.BackgroundTransparency < 1 and "BackgroundColor3" or "TextColor3",
					originalColor = Color3.new(),
					shaking = false
				}
				v28.originalColor = colorsByColorProperty[v28.colorProperty]
				v27[colorsByColorProperty] = v28
			end

			if v28.shaking then
				return
			end

			v28.shaking = true
			colorsByColorProperty[v28.colorProperty] = Color3.fromRGB(255, 76, 76)
			local tweenInfo5 = TweenInfo.new(0.15)
			local originalColorsByColorProperty = {
				[v28.colorProperty] = v28.originalColor
			}
			TweenService:Create(colorsByColorProperty, tweenInfo5, originalColorsByColorProperty):Play()
			task.spawn(function()
				for _, v29 in ipairs({
					6,
					-6,
					6,
					0
				}) do
					;(playTween(colorsByColorProperty, TweenInfo.new(0.05), {
						Position = v28.originalPosition + UDim2.fromOffset(v29, 0)
					})).Completed:Wait()
				end

				colorsByColorProperty.Position = v28.originalPosition
				v28.shaking = false
			end)
		end

		local backgroundColor3 = confirm.BackgroundColor3
		local color = Color3.fromRGB(140, 140, 140)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setConfirmEnabled(active: boolean)
			confirm.Active = active
			local v28 = confirm
			local backgroundColor

			if active then
				backgroundColor = backgroundColor3
			else
				backgroundColor = color
			end

			v28.BackgroundColor3 = backgroundColor
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBallCellSelected(instance, visible: boolean)
			local frame = instance:FindFirstChild("选中")

			if frame and frame:IsA("Frame") then
				frame.Visible = visible
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearBallSelection()
			if v24 then
				setBallCellSelected(v24, false) -- equivalent call inferred; original call site unknown
			end

			v24 = nil
			roleId = nil
			confirm.Active = false
			confirm.BackgroundColor3 = color
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeSelectPanel()
			clearBallSelection() -- equivalent call inferred; original call site unknown
			panel.Visible = false
			main.Visible = true
		end

		local v28 = nil

		local function playRerollDeniedFeedback()
			if not v28 then
				local useBackgroundColor = colors.BackgroundTransparency < 1
				local v30 = {
					originalPosition = colors.Position,
					useBackgroundColor = useBackgroundColor,
					originalColor = 0,
					shaking = false
				}
				local originalColor

				if useBackgroundColor then
					originalColor = colors.BackgroundColor3
				else
					originalColor = colors.TextColor3
				end

				v30.originalColor = originalColor
				v28 = v30
			end

			local v29 = v28

			if v29.shaking then
				return
			end

			v29.shaking = true
			local v30 = v29.useBackgroundColor and "BackgroundColor3" or "TextColor3"
			colors[v30] = Color3.fromRGB(255, 76, 76)
			TweenService:Create(colors, TweenInfo.new(0.15), {
				[v30] = v29.originalColor
			}):Play()
			local uDim = UDim2.new(0, 6, 0, 0)
			local tweenInfo6 = TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local v33 = {
				v29.originalPosition + uDim,
				v29.originalPosition - uDim,
				v29.originalPosition + uDim,
				v29.originalPosition
			}
			task.spawn(function()
				for _, position in v33 do
					;(playTween(colors, tweenInfo6, {
						Position = position
					})).Completed:Wait()
				end

				colors.Position = v29.originalPosition
				v29.shaking = false
			end)
		end

		local backgroundTransparency = root.BackgroundTransparency

		local function showRoot()
			if v21 then
				v21:Prefer(cards[2])
			end

			root.Visible = true
			root.BackgroundTransparency = 1
			local size2 = main.Size
			main.Size = UDim2.fromOffset(size2.X.Offset * 0.85, size2.Y.Offset * 0.85)
			TweenService:Create(root, tweenInfo2, {
				BackgroundTransparency = backgroundTransparency
			}):Play()
			TweenService:Create(main, tweenInfo3, {
				Size = size2
			}):Play()
			v17:SetAttribute("ForceVisible", true)
			v17.Visible = true
		end

		local function hideRoot()
			if v21 then
				v21:Release()
			end

			resetAllSlotMachines()
			local size2 = main.Size
			TweenService:Create(root, tweenInfo4, {
				BackgroundTransparency = 1
			}):Play()
			;(playTween(main, tweenInfo4, {
				Size = UDim2.fromOffset(size2.X.Offset * 0.85, size2.Y.Offset * 0.85)
			})).Completed:Once(function()
				root.Visible = false
				main.Size = size2
				root.BackgroundTransparency = backgroundTransparency
			end)
			colors.Visible = false
			v25 = nil
			pick.Visible = false
			pick.Active = false
			closeSelectPanel() -- equivalent call inferred; original call site unknown
			v17:SetAttribute("ForceVisible", nil)
		end

		local v29 = {
			["手柄A"] = true,
			["手柄X"] = true,
			["手柄Y"] = true,
			["滚轮容器"] = true,
			["问号遮罩"] = true,
			["高光条1"] = true,
			["高光条2"] = true
		}

		local function collectFadeRecords(p)
			local result = {}
			local visit

			visit = function(instance)
				for _, child in ipairs(instance:GetChildren()) do
					if v29[child.Name] then
						continue
					end

					if child:IsA("GuiObject") then
						table.insert(result, {
							instance = child,
							prop = "BackgroundTransparency",
							original = child.BackgroundTransparency
						})
					end

					if child:IsA("UIStroke") then
						table.insert(result, {
							instance = child,
							prop = "Transparency",
							original = child.Transparency
						})
					elseif child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
						table.insert(result, {
							instance = child,
							prop = "TextTransparency",
							original = child.TextTransparency
						})
						table.insert(result, {
							instance = child,
							prop = "TextStrokeTransparency",
							original = child.TextStrokeTransparency
						})
					elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
						table.insert(result, {
							instance = child,
							prop = "ImageTransparency",
							original = child.ImageTransparency
						})
					end

					visit(child)
				end
			end

			visit(p)
			return result
		end

		local CardQualityTitle = require(script:WaitForChild("CardQualityTitle"))
		local clone = cards[1]:WaitForChild("击杀数"):Clone()
		local v30 = {}

		for _, v31 in cards do
			v30[v31] = CardQualityTitle.bind(v31, clone)
		end

		clone:Destroy()
		local v31 = {}

		for _, v32 in ipairs(cards) do
			local v33 = {}
			local visit
			local visit2 = visit

			visit = function(instance)
				for i, child in ipairs(instance:GetChildren()) do
					if v29[child.Name] then
						continue
					end

					if child:IsA("GuiObject") then
						table.insert(v33, {
							instance = child,
							prop = "BackgroundTransparency",
							original = child.BackgroundTransparency
						})
					end

					if child:IsA("UIStroke") then
						table.insert(v33, {
							instance = child,
							prop = "Transparency",
							original = child.Transparency
						})
					elseif child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
						table.insert(v33, {
							instance = child,
							prop = "TextTransparency",
							original = child.TextTransparency
						})
						table.insert(v33, {
							instance = child,
							prop = "TextStrokeTransparency",
							original = child.TextStrokeTransparency
						})
					elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
						table.insert(v33, {
							instance = child,
							prop = "ImageTransparency",
							original = child.ImageTransparency
						})
					end

					visit2(child)
				end
			end

			visit(v32)
			v31[v32] = v33
			SlotMachineCard.register(v32, v33, v32.BackgroundTransparency, v32.Size)
			CardExitEffects.register(v32, v33, v32.BackgroundTransparency, v32.Size)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function collapseCards()
			resetAllSlotMachines()
			CardExitEffects.collapseAll(cards)
			setCardsInteractable(false) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function collapseSelectedCard(p)
			resetAllSlotMachines()
			setCardsInteractable(false) -- equivalent call inferred; original call site unknown

			if p then
				CardExitEffects.collapseWithSelection(cards, p)
			else
				CardExitEffects.collapseAll(cards)
			end
		end

		local function findCardByRoleId(roleId2)
			if typeof(roleId2) ~= "string" then
				return nil
			end

			for _, v32 in ipairs(cards) do
				if v32:GetAttribute("RoleId") == roleId2 then
					return v32
				end
			end

			return nil
		end

		local function findCardByCandidate(candidate)
			if typeof(candidate) ~= "table" or typeof(candidate.kind) ~= "string" or typeof(candidate.id) ~= "string" then
				return nil
			end

			for _, v32 in ipairs(cards) do
				if v32:GetAttribute("CandidateKind") == candidate.kind and v32:GetAttribute("CandidateId") == candidate.id then
					return v32
				end
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopCountdown()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end

		local v32 = ""
		local v33 = ""
		local v34 = ""

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startCountdown(duration: number, p: string)
			stopCountdown() -- equivalent call inferred; original call site unknown
			v32 = p
			v26 = os.clock() + duration
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v35 = math.max(0, (math.ceil(v26 - os.clock())))
				v3.Text = string.format(v32, v35)

				if panel.Visible then
					v8.Text = string.format(v34, v35)
				end

				if v35 <= 0 and renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function switchToWaitingTitle()
			v32 = v33
		end

		local function getAssetTitleTemplate(p: string, p2: string)
			local byCnId = Config.asset.byCnId

			if byCnId then
				local v35 = byCnId[p]

				if v35 and typeof(v35.txt) == "string" then
					return v35.txt
				end
			end

			if Config.asset and Config.asset.list then
				for _, v35 in ipairs(Config.asset.list) do
					if v35.assetCnId == p and typeof(v35.txt) == "string" then
						return v35.txt .. " - %ds"
					end
				end
			end

			return p2
		end

		local assetTitleTemplate = getAssetTitleTemplate("3选1球标题", "CHOOSE YOUR BALL - %ds")
		local assetTitleTemplate2 = getAssetTitleTemplate("3选1升级标题", "CHOOSE YOUR UPGRADE - %ds")
		v34 = getAssetTitleTemplate("等待自选", "SELECT ANY BALL - %ds")
		v33 = getAssetTitleTemplate("等待对手操作", "WAITING FOR OPPONENT - %ds")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isValidImageValue(image)
			return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setCardImage(p, image)
			if not p then
				return
			end

			-- equivalent call inferred; original call site unknown
			if isValidImageValue(image) then
				p.Image = image
			end
		end

		local v35 = {
			AllIn = "Stat Change"
		}

		local function describeCandidate(p)
			if p.kind == "basicStat" then
				local basicStat = BattleConfig.tournament_upgrade.basicStats[p.id]

				if not basicStat then
					return p.id, ""
				end

				local v36 = string.format("+%d%%", (math.floor(basicStat.amount * 100 + 0.5)))
				return basicStat.displayName, v36
			else
				local trait = BattleConfig.traits[p.id]

				if not trait then
					return p.id, ""
				end

				local v36

				if trait.desc then
					v36 = SkillFeatureParser.formatDescription(trait.desc, trait.rawFeature)
				else
					v36 = v35[p.id] or p.kind == "trait" and "Trait" or "On-Hit Effect"
				end

				return trait.displayName, v36
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function candidateCnId(p)
			if p.kind == "basicStat" then
				local basicStat = BattleConfig.tournament_upgrade.basicStats[p.id]
				return basicStat and basicStat.cnId
			end

			if p.kind ~= "effect" then
				return nil
			end

			local trait = BattleConfig.traits[p.id]
			return trait and trait.cnId
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function describeBallShortDesc(p)
			if p and typeof(p.shortDesc) == "string" then
				return p.shortDesc
			end

			return ""
		end

		local function findRatingByLvl(rating)
			if typeof(rating) ~= "number" or typeof(Config.rating.list) ~= "table" then
				return nil
			end

			for _, v36 in ipairs(Config.rating.list) do
				if v36.lvl == rating then
					return v36
				end
			end

			return nil
		end

		local function setSelectCellRatingColor(clone2, rating)
			if not rating or typeof(rating.colorHex) ~= "string" then
				return
			end

			local success, result = pcall(Color3.fromHex, rating.colorHex)

			if not success then
				return
			end

			local firstChild = clone2:FindFirstChild("品质框")
			local firstChild2 = clone2:FindFirstChild("名称框")
			local v36 = firstChild2 and firstChild2:FindFirstChild("品质框")

			if firstChild then
				firstChild.Color = result
			end

			if v36 then
				v36.Color = result
			end
		end

		local function confirmSelectedBall()
			if v23 or v20 or not confirm.Active or not roleId or not v18 or v18.flowKind ~= "DuelBall" then
				return
			end

			v23 = true
			confirm.Active = false
			confirm.BackgroundColor3 = color
			remoteEvent16:FireServer(v18.matchKey, roleId)
		end

		local function renderSelectBallList(roleIds)
			clearBallSelection() -- equivalent call inferred; original call site unknown

			for _, button in ipairs(v7:GetChildren()) do
				if button:IsA("GuiButton") and button ~= _1 then
					button:Destroy()
				end
			end

			local v36 = {}
			local v37 = {}

			for _, roleId2 in ipairs(roleIds) do
				if typeof(roleId2) ~= "string" or v36[roleId2] then
					continue
				end

				local ball = Config.ball.byCnId[roleId2]
				local role = BattleConfig.roles[roleId2]

				if not (ball and role) then
					continue
				end

				v36[roleId2] = true
				table.insert(v37, {
					roleId = roleId2,
					ball = ball,
					rating = findRatingByLvl(ball.rating)
				})
			end

			table.sort(v37, function(a, b)
				local v38 = not a.rating and -1e999 or a.rating.lvl or -1e999
				local v39 = not b.rating and -1e999 or b.rating.lvl or -1e999

				if v38 ~= v39 then
					return v39 < v38
				end

				local displayName = typeof(a.ball.displayName) == "string" and a.ball.displayName or a.roleId
				local displayName2 = typeof(b.ball.displayName) == "string" and b.ball.displayName or b.roleId

				if displayName == displayName2 then
					return a.roleId < b.roleId
				end

				return displayName < displayName2
			end)

			for i, v38 in ipairs(v37) do
				local clone2 = _1:Clone()
				clone2.Name = "自选球_" .. v38.roleId
				clone2:SetAttribute("RoleId", v38.roleId)
				clone2.LayoutOrder = i
				clone2.Text = ""
				clone2.Visible = true
				clone2.Active = true
				clone2.Parent = v7
				setCardImage(clone2:FindFirstChild("小球图片"), v38.ball.image) -- equivalent call inferred; original call site unknown
				local firstChild2 = clone2:FindFirstChild("名称框")
				local v39 = firstChild2 and firstChild2:FindFirstChild("名称")

				if v39 then
					CardQualityTitle.bind(clone2, clone2:WaitForChild("击杀数"), v39).showBall(
						v38.roleId,
						v38.ball.displayName or v38.roleId,
						client.items(),
						client.equipment()
					)
				end

				setSelectCellRatingColor(clone2, v38.rating)
				setWeeklyFreeLabel(clone2, v38.roleId) -- equivalent call inferred; original call site unknown
				local v41 = v38
				ButtonActions.Bind(clone2, function(p)
					if v23 or v20 or not v18 or v18.flowKind ~= "DuelBall" then
						return
					end

					local v42

					if p == nil then
						v42 = false
					else
						v42 = p.KeyCode == Enum.KeyCode.ButtonA
					end

					if v24 == clone2 and not v42 then
						clearBallSelection() -- equivalent call inferred; original call site unknown
					else
						if v24 then
							setBallCellSelected(v24, false) -- equivalent call inferred; original call site unknown
						end

						v24 = clone2
						roleId = v41.roleId
						setBallCellSelected(clone2, true) -- equivalent call inferred; original call site unknown
						confirm.Active = true
						confirm.BackgroundColor3 = backgroundColor3

						if v42 and not v23 and not v20 and confirm.Active and roleId and v18 then
							if v18.flowKind ~= "DuelBall" then
								return
							end

							v23 = true
							confirm.Active = false
							confirm.BackgroundColor3 = color
							remoteEvent16:FireServer(v18.matchKey, roleId)
						end
					end
				end)
			end

			v7.CanvasPosition = Vector2.zero
			v7.AutomaticCanvasSize = Enum.AutomaticSize.Y
		end

		local function populateBallCard(instance, roleId2: string, p)
			setWeeklyFreeLabel(instance, roleId2) -- equivalent call inferred; original call site unknown
			instance:SetAttribute("RoleId", roleId2)
			instance:SetAttribute("CandidateKind", nil)
			instance:SetAttribute("CandidateId", nil)
			instance:FindFirstChild("名称文本")
			local firstChild = instance:FindFirstChild("描述文本")
			local firstChild2 = instance:FindFirstChild("图片框")
			local v36 = firstChild2 and firstChild2:FindFirstChild("默认图片")
			v30[instance].showBall(roleId2, p.displayName, client.items(), client.equipment())
			local v37 = Config.ball.byCnId[roleId2]
			firstChild.Text = describeBallShortDesc(v37)
			local image = v37 and v37.image
			setCardImage(v36, image) -- equivalent call inferred; original call site unknown
			local firstChild3 = instance:FindFirstChild("星星")

			if firstChild3 then
				firstChild3.Visible = false
			end
		end

		local function populateUpgradeCard(instance, p)
			local label2 = instance:FindFirstChild("周免标签")

			if label2 and label2:IsA("TextLabel") then
				label2.Visible = false
			end

			instance:SetAttribute("RoleId", nil)
			instance:SetAttribute("CandidateKind", p.kind)
			instance:SetAttribute("CandidateId", p.id)
			local firstChild = instance:FindFirstChild("名称文本")
			local firstChild2 = instance:FindFirstChild("描述文本")
			local firstChild3 = instance:FindFirstChild("图片框")
			local v36 = firstChild3 and firstChild3:FindFirstChild("默认图片")
			local text, text2 = describeCandidate(p)
			v30[instance].showUpgrade()
			firstChild.Text = text
			firstChild2.Text = text2
			local v39 = candidateCnId(p) -- equivalent call inferred; original call site unknown
			local v40 = v39 and Config.upgradeChoice.byTargetCnId[v39]
			local image = v40 and v40.image
			setCardImage(v36, image) -- equivalent call inferred; original call site unknown
			local firstChild4 = instance:FindFirstChild("星星")

			if firstChild4 then
				local star = v40 and v40.star

				if typeof(star) == "number" and star > 0 then
					firstChild4.Text = string.rep("⭐️", star)
					firstChild4.Visible = true
				else
					firstChild4.Visible = false
				end
			end
		end

		local function buildBallPopulators(offer)
			local result = {}

			for i, v36 in ipairs(cards) do
				local v37 = offer[i]
				local v38

				if typeof(v37) == "string" then
					v38 = BattleConfig.roles[v37]
				end

				if not v38 then
					continue
				end

				local v39 = v36
				local v40 = v37
				local v41 = v38

				result[i] = function()
					populateBallCard(v39, v40, v41)
				end
			end

			return result
		end

		local function buildUpgradePopulators(offer)
			local result = {}

			for i, v36 in ipairs(cards) do
				local v37 = offer[i]

				if not (typeof(v37) == "table" and typeof(v37.kind) == "string" and typeof(v37.id) == "string") then
					continue
				end

				local v38 = v36
				local v39 = v37

				result[i] = function()
					populateUpgradeCard(v38, v39)
				end
			end

			return result
		end

		local function collectBallReelImages(offer)
			local images = {}

			for _, v36 in ipairs(offer) do
				if typeof(v36) ~= "string" then
					continue
				end

				local v37 = Config.ball.byCnId[v36]
				local image = v37 and v37.image

				-- equivalent call inferred; original call site unknown
				if isValidImageValue(image) then
					table.insert(images, image)
				end
			end

			return images
		end

		local function collectUpgradeReelImages(offer)
			local images = {}

			for _, v36 in ipairs(offer) do
				if not (typeof(v36) == "table" and typeof(v36.kind) == "string" and typeof(v36.id) == "string") then
					continue
				end

				local v37 = candidateCnId(v36) -- equivalent call inferred; original call site unknown
				local v38 = v37 and Config.upgradeChoice.byTargetCnId[v37]
				local image = v38 and v38.image

				-- equivalent call inferred; original call site unknown
				if isValidImageValue(image) then
					table.insert(images, image)
				end
			end

			return images
		end

		local function playSlotMachineEntrance(p, p2, flag: boolean?)
			local v36 = v18
			setCardsInteractable(false) -- equivalent call inferred; original call site unknown
			local v37 = false
			local count = 0

			for i, v38 in ipairs(cards) do
				CardExitEffects.reset(v38)
				local label2 = v38:FindFirstChild("周免标签")

				if label2 and label2:IsA("TextLabel") then
					label2.Visible = false
				end

				local v39 = p[i]

				if v39 then
					v38.Visible = true
					local v40 = v38

					local function fn()
						if v18 == v36 and not v20 then
							v40.Active = true
						end
					end

					if flag then
						SlotMachineCard.reopen(v38, v39, fn, not v37)
						v37 = true
					else
						local v41 = count * 0.3 + 0.35
						count += 1
						SlotMachineCard.play(v38, v41, p2, v39, fn)
					end
				else
					SlotMachineCard.reset(v38)
					v38.Visible = false
				end
			end
		end

		remoteEvent.OnClientEvent:Connect(function(model, data)
			if typeof(model) ~= "Instance" or not model:IsA("Model") or typeof(data) ~= "table" then
				return
			end

			v18 = {
				flowKind = "DuelBall",
				matchKey = model
			}
			setWeeklyFreeRoleIds(data.weeklyFreeRoleIds)
			v20 = false
			v22 = false
			v23 = false
			closeSelectPanel() -- equivalent call inferred; original call site unknown
			local offer = data.offer or {}
			playSlotMachineEntrance(buildBallPopulators(offer), collectBallReelImages(offer), data.isReselect == true)
			showRoot()
			setRerollAvailable(data.rerollPrice) -- equivalent call inferred; original call site unknown
			setSelectAvailable(data.selectPrice)
			local duration = data.duration or 30
			startCountdown(duration, assetTitleTemplate) -- equivalent call inferred; original call site unknown
		end)
		remoteEvent3.OnClientEvent:Connect(function(p, p2)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or typeof(p2) ~= "table" then
				return
			end

			v20 = true
			v22 = false
			v23 = false
			closeSelectPanel() -- equivalent call inferred; original call site unknown
			switchToWaitingTitle() -- equivalent call inferred; original call site unknown
			colors.Visible = false
			v25 = nil
			pick.Visible = false
			pick.Active = false
			collapseSelectedCard(findCardByRoleId(p2.roleId)) -- equivalent call inferred; original call site unknown
		end)
		remoteEvent14.OnClientEvent:Connect(function(p, p2)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or v20 then
				return
			end

			if typeof(p2) ~= "table" or typeof(p2.roleIds) ~= "table" then
				return
			end

			v22 = false
			pick.Visible = false
			pick.Active = false
			setWeeklyFreeRoleIds(p2.weeklyFreeRoleIds)
			renderSelectBallList(p2.roleIds)
			main.Visible = false
			panel.Visible = true
			v8.Text = string.format(v34, (math.max(0, (math.ceil(v26 - os.clock())))))
		end)
		remoteEvent15.OnClientEvent:Connect(function(p)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or v20 then
				return
			end

			v22 = false
			pick.Active = true
			playButtonShakeFeedback(pick)
		end)
		remoteEvent18.OnClientEvent:Connect(function(p, p2: string?, p3: number?)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or v20 then
				return
			end

			v23 = false
			setConfirmEnabled(roleId ~= nil) -- equivalent call inferred; original call site unknown
			playButtonShakeFeedback(confirm)

			if p2 == "insufficient" and p3 and getVoucherCount() <= 0 then
				DiamondTopUpService.promptIfInsufficient(p3)
			end
		end)
		remoteEvent17.OnClientEvent:Connect(function(p)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or v20 then
				return
			end

			v20 = true
			v23 = false
			closeSelectPanel() -- equivalent call inferred; original call site unknown
			switchToWaitingTitle() -- equivalent call inferred; original call site unknown
			colors.Visible = false
			v25 = nil
			pick.Visible = false
			pick.Active = false
			collapseCards() -- equivalent call inferred; original call site unknown
		end)
		remoteEvent4.OnClientEvent:Connect(function(model, data)
			if typeof(model) ~= "Instance" or not model:IsA("Model") or typeof(data) ~= "table" then
				return
			end

			v18 = {
				flowKind = "DuelUpgrade",
				matchKey = model
			}
			v19 = {}
			v20 = false
			v22 = false
			v23 = false
			closeSelectPanel() -- equivalent call inferred; original call site unknown
			v25 = nil
			pick.Visible = false
			pick.Active = false
			local offer = data.offer or {}
			playSlotMachineEntrance(buildUpgradePopulators(offer), (collectUpgradeReelImages(offer)))
			showRoot()
			setRerollAvailable(data.rerollPrice) -- equivalent call inferred; original call site unknown
			local duration = data.duration or 20
			startCountdown(duration, assetTitleTemplate2) -- equivalent call inferred; original call site unknown
		end)
		remoteEvent6.OnClientEvent:Connect(function(p, p2)
			if not v18 or v18.flowKind ~= "DuelUpgrade" or v18.matchKey ~= p or typeof(p2) ~= "table" then
				return
			end

			v20 = true
			switchToWaitingTitle() -- equivalent call inferred; original call site unknown
			colors.Visible = false
			collapseSelectedCard(findCardByCandidate(p2.candidate)) -- equivalent call inferred; original call site unknown
		end)
		remoteEvent9.OnClientEvent:Connect(function(p, data)
			if not v18 or v18.flowKind ~= "DuelBall" or v18.matchKey ~= p or v20 then
				return
			end

			if typeof(data) ~= "table" or typeof(data.offer) ~= "table" then
				return
			end

			local v36 = v18

			if v21 then
				v21:PreferCurrent()
			end

			collapseCards() -- equivalent call inferred; original call site unknown
			task.delay(CardExitEffects.COLLAPSE_TIME + 0.05, function()
				if v18 ~= v36 or v20 then
					return
				end

				setWeeklyFreeRoleIds(data.weeklyFreeRoleIds)
				playSlotMachineEntrance(buildBallPopulators(data.offer), (collectBallReelImages(data.offer)))
				setRerollAvailable(data.rerollPrice) -- equivalent call inferred; original call site unknown
			end)
		end)
		remoteEvent11.OnClientEvent:Connect(function(p, p2)
			if not v18 or v18.flowKind ~= "DuelUpgrade" or v18.matchKey ~= p or v20 then
				return
			end

			if typeof(p2) ~= "table" or typeof(p2.offer) ~= "table" then
				return
			end

			local v36 = v18

			if v21 then
				v21:PreferCurrent()
			end

			collapseCards() -- equivalent call inferred; original call site unknown
			task.delay(CardExitEffects.COLLAPSE_TIME + 0.05, function()
				if v18 ~= v36 or v20 then
					return
				end

				playSlotMachineEntrance(buildUpgradePopulators(p2.offer), (collectUpgradeReelImages(p2.offer)))
				setRerollAvailable(p2.rerollPrice) -- equivalent call inferred; original call site unknown
			end)
		end)
		remoteEvent12.OnClientEvent:Connect(function(p, p2: string?, p3: number?)
			if not v18 or v18.matchKey ~= p or v20 then
				return
			end

			playRerollDeniedFeedback()

			if p2 == "insufficient" and p3 then
				DiamondTopUpService.promptIfInsufficient(p3)
			end
		end)
		local PlayerThumbnail = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerThumbnail"))
		local v36 = main:WaitForChild("队友信息")
		local v37 = v36:WaitForChild("队友头像")
		local v38 = v36:WaitForChild("小球图片")
		local image = v38.Image
		local userId = nil
		v36.Visible = false

		local function updateTeammatePreview(table2)
			local userId2 = Players.LocalPlayer.UserId
			local players

			if typeof(table2) == "table" then
				players = table2.players
			else
				players = false
			end

			local v39

			if typeof(players) == "table" and typeof(table2.teamSize) == "number" and table2.teamSize > 1 and table2.state == "Picking" then
				v39 = not v20
			else
				v39 = false
			end

			if not v39 then
				v36.Visible = false
				return
			end

			local team = nil

			for _, player in pairs(players) do
				if typeof(player) == "table" and player.userId == userId2 then
					team = player.team
				end
			end

			local v40 = nil

			for _, player in pairs(players) do
				if not (typeof(player) == "table" and player.userId ~= userId2 and team ~= nil and player.team == team) then
					continue
				end

				v40 = player
			end

			if not v40 then
				v36.Visible = false
				return
			end

			if typeof(v40.userId) == "number" and userId ~= v40.userId then
				userId = v40.userId
				PlayerThumbnail.applyAsync(v37, v40.userId)
			end

			local v41 = typeof(v40.roleId) == "string" and Config.ball.byCnId[v40.roleId] or nil
			local v42 = v38
			local image2

			if v41 and typeof(v41.image) == "string" and v41.image ~= "" then
				image2 = v41.image
			else
				image2 = image
			end

			v42.Image = image2
			v36.Visible = true
		end

		remoteEvent7.OnClientEvent:Connect(function(p)
			if not v18 or v18.flowKind ~= "DuelBall" and v18.flowKind ~= "DuelUpgrade" then
				v36.Visible = false
				return
			end

			if typeof(p) ~= "table" or typeof(p.tables) ~= "table" then
				return
			end

			local v39 = v18.flowKind == "DuelBall" and "Picking" or "Upgrading"

			for _, table2 in ipairs(p.tables) do
				if table2.table ~= v18.matchKey then
					continue
				end

				updateTeammatePreview(table2)

				if table2.state == v39 then
					break
				end

				v18 = nil
				stopCountdown() -- equivalent call inferred; original call site unknown
				hideRoot()
				break
			end
		end)

		for _, v39 in ipairs(cards) do
			local size2 = v39.Size
			local v40 = v39
			v39.MouseEnter:Connect(function()
				if v20 or not v40.Active then
					return
				end

				TweenService:Create(v40, tweenInfo, {
					Size = UDim2.new(size2.X.Scale * 1.03, 0, size2.Y.Scale * 1.02, 0)
				}):Play()
			end)
			local v42 = v39
			local size4 = size2
			v39.MouseLeave:Connect(function()
				if v20 or not v42.Active then
					return
				end

				TweenService:Create(v42, tweenInfo, {
					Size = size4
				}):Play()
			end)
			local v44 = v39
			ButtonActions.Bind(v39, function()
				if v20 or not (v44.Active and v18) then
					return
				end

				local flowKind = v18.flowKind

				if flowKind == "DuelBall" then
					local roleId2 = v44:GetAttribute("RoleId")

					if typeof(roleId2) ~= "string" then
						return
					end

					v20 = true
					switchToWaitingTitle() -- equivalent call inferred; original call site unknown
					colors.Visible = false
					v25 = nil
					pick.Visible = false
					pick.Active = false
					closeSelectPanel() -- equivalent call inferred; original call site unknown
					remoteEvent2:FireServer(v18.matchKey, roleId2)
					collapseSelectedCard(v44) -- equivalent call inferred; original call site unknown
				elseif flowKind == "DuelUpgrade" then
					local candidateKind = v44:GetAttribute("CandidateKind")
					local candidateId = v44:GetAttribute("CandidateId")

					if typeof(candidateKind) ~= "string" or typeof(candidateId) ~= "string" then
						return
					end

					v20 = true
					switchToWaitingTitle() -- equivalent call inferred; original call site unknown
					colors.Visible = false
					remoteEvent5:FireServer(v18.matchKey, {
						kind = candidateKind,
						id = candidateId
					})
					collapseSelectedCard(v44) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local size2 = pick.Size
		pick.MouseEnter:Connect(function()
			if not pick.Active then
				return
			end

			TweenService:Create(pick, tweenInfo, {
				Size = UDim2.new(size2.X.Scale * 1.05, 0, size2.Y.Scale * 1.05, 0)
			}):Play()
		end)
		pick.MouseLeave:Connect(function()
			if not pick.Active then
				return
			end

			TweenService:Create(pick, tweenInfo, {
				Size = size2
			}):Play()
		end)
		local size3 = colors.Size
		colors.MouseEnter:Connect(function()
			if not colors.Active then
				return
			end

			TweenService:Create(colors, tweenInfo, {
				Size = UDim2.new(size3.X.Scale * 1.05, 0, size3.Y.Scale * 1.05, 0)
			}):Play()
		end)
		colors.MouseLeave:Connect(function()
			if not colors.Active then
				return
			end

			TweenService:Create(colors, tweenInfo, {
				Size = size3
			}):Play()
		end)

		local function activateSelect()
			if v20 or v22 or not pick.Active or not v18 or v18.flowKind ~= "DuelBall" then
				return
			end

			if typeof(v25) == "number" and v25 > 0 and getVoucherCount() <= 0 and CurrencyService.client.get(CurrencyService.ref.Diamonds) < v25 then
				playButtonShakeFeedback(pick)
				DiamondTopUpService.promptIfInsufficient(v25)
				return
			end

			v22 = true
			pick.Active = false
			bounceButton(pick)
			remoteEvent13:FireServer(v18.matchKey)
		end

		ButtonActions.Bind(pick, activateSelect)
		ButtonActions.Bind(confirm, confirmSelectedBall)

		local function returnFromSelectPanel()
			if v23 or v20 or not v18 or v18.flowKind ~= "DuelBall" then
				return
			end

			closeSelectPanel() -- equivalent call inferred; original call site unknown
			setSelectAvailable(v25)

			if v21 then
				v21:Prefer(pick)
			end
		end

		ButtonActions.Bind(back, returnFromSelectPanel)

		local function activateReroll()
			if v20 or v22 or panel.Visible or not (colors.Active and colors.Visible and v18) then
				return
			end

			local flowKind = v18.flowKind

			if flowKind ~= "DuelBall" and flowKind ~= "DuelUpgrade" then
				return
			end

			bounceButton(colors)

			if flowKind == "DuelBall" then
				remoteEvent8:FireServer(v18.matchKey)
			else
				remoteEvent10:FireServer(v18.matchKey)
			end
		end

		ButtonActions.Bind(colors, activateReroll)
		local GamepadNavigation = require(script.GamepadNavigation)
		v21 = GamepadNavigation.new({
			root = root,
			main = main,
			panel = panel,
			list = v7,
			cards = cards,
			pick = pick,
			reroll = colors,
			back = back,
			confirm = confirm,
			canNavigate = function()
				return v18 ~= nil and not v20 and os.clock() < v26
			end,
			onBack = returnFromSelectPanel,
			onPick = activateSelect,
			onReroll = activateReroll
		})
		root.Visible = false
		root.BackgroundTransparency = 1
	end
}