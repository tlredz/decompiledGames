local createVector = vector.create

local function discoverHookChainSegmentCount(model)
	local v = {}
	local v2 = 0

	for _, part in ipairs(model:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local match = part.Name:match("^连接(%d+)$")

		if not match then
			continue
		end

		local v3 = tonumber(match)
		v[v3] = true
		v2 = math.max(v2, v3)
	end

	assert(v2 > 0, string.format("钩爪素材模型 '%s' 找不到任何 连接N 部件", model:GetFullName()))

	for i = 1, v2 do
		assert(v[i], string.format("钩爪素材模型 '%s' 缺少连接%d（编号必须从 1 连续到 %d）", model:GetFullName(), i, v2))
	end

	return v2
end

local function getTemplateBundle(instance, childName: string)
	local model = instance:FindFirstChild(childName)
	assert(model and model:IsA("Model"), string.format("素材模型 '%s' 缺失：%s", childName, instance:GetFullName()))
	local part = model:FindFirstChild("碰撞箱")
	assert(part and part:IsA("BasePart"), string.format("素材模型 '%s' 缺少碰撞箱", model:GetFullName()))
	local folder = model:FindFirstChild("装饰")
	local part2 = model:FindFirstChild("区域样式")
	local UI = model:FindFirstChild("等级UI")
	assert(not folder or folder:IsA("Folder"), string.format("素材模型 '%s' 的装饰必须为 Folder", model:GetFullName()))
	assert(not part2 or part2:IsA("BasePart"), string.format("素材模型 '%s' 的区域样式必须为 BasePart", model:GetFullName()))
	assert(not UI or UI:IsA("BillboardGui"), string.format("素材模型 '%s' 的等级UI必须为 BillboardGui", model:GetFullName()))

	for _, child in ipairs(model:GetChildren()) do
		assert(
			child == part or child == folder or child == part2 or child == UI,
			string.format("素材模型 '%s' 只能包含碰撞箱、装饰、区域样式和等级UI", model:GetFullName())
		)
	end

	for _, part3 in ipairs(model:GetDescendants()) do
		if part3:IsA("BasePart") then
			assert(
				part3 == part or part3 == part2 or folder and part3:IsDescendantOf(folder),
				string.format("素材模型 '%s' 的 BasePart 必须位于装饰内", model:GetFullName())
			)
		end
	end

	local attachment = part:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("素材模型 '%s' 的碰撞箱缺少朝向标记", model:GetFullName()))
	model.PrimaryPart = part
	return {
		model = model,
		root = part,
		forwardOffset = CFrame.fromMatrix(
			createVector(0, 0, 0),
			attachment.CFrame.XVector,
			attachment.CFrame.YVector,
			attachment.CFrame.ZVector
		),
		markerOffset = attachment.CFrame
	}
end

local function getOptionalTemplateBundle(folder, childName, p: string)
	if type(childName) ~= "string" or childName == "" then
		warn(string.format("[TemplateLibrary] %s 的 assetName 未配置，跳过该特效模板加载", p))
		return nil
	end

	if folder:FindFirstChild(childName) then
		return (getTemplateBundle(folder, childName))
	end

	warn(string.format("[TemplateLibrary] %s 的素材模型 '%s' 在 %s 下不存在，跳过该特效模板加载", p, childName, folder:GetFullName()))
	return nil
end

local function getPartTemplateBundle(assetName, childName: string)
	local part = assetName:FindFirstChild(childName)
	assert(part and part:IsA("BasePart"), string.format("Part 素材 '%s' 缺失：%s", childName, assetName:GetFullName()))
	local attachment = part:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("Part 素材 '%s' 缺少朝向标记", part:GetFullName()))
	local model = Instance.new("Model")
	model.Name = part.Name
	local clone = part:Clone()
	clone.Name = "碰撞箱"
	clone.Parent = model
	model.PrimaryPart = clone
	return {
		model = model,
		root = clone,
		forwardOffset = CFrame.fromMatrix(
			createVector(0, 0, 0),
			attachment.CFrame.XVector,
			attachment.CFrame.YVector,
			attachment.CFrame.ZVector
		),
		markerOffset = attachment.CFrame
	}
end

local function getDiceTemplateBundle(folder, diceTemplateName: string)
	local model = folder:FindFirstChild(diceTemplateName)
	assert(model and model:IsA("Model"), string.format("骰子素材模型缺失：%s", diceTemplateName))
	local part = model:FindFirstChild("碰撞箱")
	assert(part and part:IsA("BasePart"), string.format("骰子素材模型 '%s' 缺少碰撞箱", model:GetFullName()))
	model.PrimaryPart = part
	return {
		model = model,
		root = part,
		forwardOffset = CFrame.identity,
		markerOffset = CFrame.identity
	}
end

local TemplateLibrary = {}

function TemplateLibrary.load(instance, data)
	local bladeTemplateName = instance:WaitForChild("美术素材")
	local folder = bladeTemplateName:WaitForChild("球体模型")
	local folder2 = bladeTemplateName:WaitForChild("模型效果")
	assert(folder:IsA("Folder"), "ReplicatedStorage.美术素材.球体模型 is missing or not a Folder")
	assert(folder2:IsA("Folder"), "ReplicatedStorage.美术素材.模型效果 is missing or not a Folder")

	for _, folder3 in { folder, folder2 } do
		for _, part in folder3:GetDescendants() do
			if not (part:IsA("BasePart") and part.CastShadow) then
				continue
			end

			warn(string.format("[TemplateLibrary] 战斗模型部件未关闭投影，已自动修正：%s", part:GetFullName()))
			part.CastShadow = false
		end
	end

	local highlight = bladeTemplateName:WaitForChild("身份标识模板"):WaitForChild("同素材敌人高亮"):WaitForChild("Highlight")
	assert(highlight:IsA("Highlight"), "同素材敌人高亮模板必须包含 Highlight")
	local ballTemplateBundles = {}

	for k, role in data.roles do
		local templateName = role.templateName
		local v2

		if type(templateName) == "string" then
			v2 = templateName ~= ""
		else
			v2 = false
		end

		assert(v2, string.format("Role '%s' is missing templateName", k))
		ballTemplateBundles[k] = getTemplateBundle(folder, templateName)
	end

	bladeTemplateName = data.visual.bladeTemplateName
	local bladeTemplateBundle

	if type(bladeTemplateName) == "string" then
		bladeTemplateBundle = bladeTemplateName ~= ""
	else
		bladeTemplateBundle = false
	end

	assert(bladeTemplateBundle, "BattleConfig.visual.bladeTemplateName is missing")
	bladeTemplateBundle = getTemplateBundle(folder2, bladeTemplateName)
	bladeTemplateName = bladeTemplateBundle.forwardOffset
	local swordTemplateName = data.visual.swordTemplateName
	local swordTemplateBundle

	if type(swordTemplateName) == "string" then
		swordTemplateBundle = swordTemplateName ~= ""
	else
		swordTemplateBundle = false
	end

	assert(swordTemplateBundle, "BattleConfig.visual.swordTemplateName is missing")
	swordTemplateBundle = getTemplateBundle(folder2, swordTemplateName)
	swordTemplateName = data.visual.axeTemplateName
	local axeTemplateBundle

	if type(swordTemplateName) == "string" then
		axeTemplateBundle = swordTemplateName ~= ""
	else
		axeTemplateBundle = false
	end

	assert(axeTemplateBundle, "BattleConfig.visual.axeTemplateName is missing")
	axeTemplateBundle = getTemplateBundle(folder2, swordTemplateName)
	swordTemplateName = data.visual.spiderWebTemplateName
	local spiderWebTemplateBundle

	if type(swordTemplateName) == "string" then
		spiderWebTemplateBundle = swordTemplateName ~= ""
	else
		spiderWebTemplateBundle = false
	end

	assert(spiderWebTemplateBundle, "BattleConfig.visual.spiderWebTemplateName is missing")
	spiderWebTemplateBundle = getTemplateBundle(folder2, swordTemplateName)
	swordTemplateName = data.visual.vampireWebTemplateName
	local vampireWebTemplateBundle

	if type(swordTemplateName) == "string" then
		vampireWebTemplateBundle = swordTemplateName ~= ""
	else
		vampireWebTemplateBundle = false
	end

	assert(vampireWebTemplateBundle, "BattleConfig.visual.vampireWebTemplateName is missing")
	vampireWebTemplateBundle = getTemplateBundle(folder2, swordTemplateName)
	swordTemplateName = data.visual.hookTemplateName
	local cFrame

	if type(swordTemplateName) == "string" then
		cFrame = swordTemplateName ~= ""
	else
		cFrame = false
	end

	assert(cFrame, "BattleConfig.visual.hookTemplateName is missing")
	local model = folder2:FindFirstChild(swordTemplateName)
	assert(model and model:IsA("Model"), string.format("钩爪素材模型缺失：%s", swordTemplateName))
	swordTemplateName = discoverHookChainSegmentCount(model)
	local cFrames = table.create(swordTemplateName)

	for i = 1, swordTemplateName do
		local part = model:FindFirstChild(string.format("连接%d", i))
		local attachment = part and part:FindFirstChild("朝向标记")
		assert(
			part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment"),
			string.format("钩爪素材模型缺少连接%d或其朝向标记", i)
		)
		cFrames[i] = attachment.CFrame
	end

	cFrame = model:FindFirstChild("碰撞箱")
	local laserTemplateName = cFrame and cFrame:FindFirstChild("朝向标记")
	assert(
		cFrame and cFrame:IsA("BasePart") and laserTemplateName and laserTemplateName:IsA("Attachment"),
		"钩爪素材模型缺少碰撞箱或其朝向标记"
	)
	cFrame = laserTemplateName.CFrame
	laserTemplateName = data.visual.laserTemplateName
	local model2

	if type(laserTemplateName) == "string" then
		model2 = laserTemplateName ~= ""
	else
		model2 = false
	end

	assert(model2, "BattleConfig.visual.laserTemplateName is missing")
	model2 = folder2:FindFirstChild(laserTemplateName)
	assert(model2 and model2:IsA("Model"), string.format("激光素材模型缺失：%s", laserTemplateName))
	assert(model2:FindFirstChild("碰撞箱") and model2:FindFirstChild("附着点"), "激光素材必须包含碰撞箱与附着点")
	laserTemplateName = data.visual.electroKingTemplateName
	local model3

	if type(laserTemplateName) == "string" then
		model3 = laserTemplateName ~= ""
	else
		model3 = false
	end

	assert(model3, "BattleConfig.visual.electroKingTemplateName is missing")
	model3 = folder2:FindFirstChild(laserTemplateName)
	assert(model3 and model3:IsA("Model"), string.format("电王激光素材模型缺失：%s", laserTemplateName))
	assert(model3:FindFirstChild("碰撞箱") and model3:FindFirstChild("附着点"), "电王激光素材必须包含碰撞箱与附着点")
	laserTemplateName = data.visual.dogCannonTemplateName
	local model4

	if type(laserTemplateName) == "string" then
		model4 = laserTemplateName ~= ""
	else
		model4 = false
	end

	assert(model4, "BattleConfig.visual.dogCannonTemplateName is missing")
	model4 = folder2:FindFirstChild(laserTemplateName)
	assert(model4 and model4:IsA("Model"), string.format("大狗光炮素材模型缺失：%s", laserTemplateName))
	local part = model4:FindFirstChild("碰撞箱")
	assert(
		part and part:IsA("BasePart") and part:FindFirstChild("头") and part:FindFirstChild("尾"),
		"大狗光炮素材必须包含碰撞箱及其 头/尾 两个 Attachment"
	)
	laserTemplateName = getTemplateBundle(folder2, "大狗蓄力")
	local poisonSpikeTemplateName = data.visual.poisonSpikeTemplateName
	local poisonSpikeTemplateBundle

	if type(poisonSpikeTemplateName) == "string" then
		poisonSpikeTemplateBundle = poisonSpikeTemplateName ~= ""
	else
		poisonSpikeTemplateBundle = false
	end

	assert(poisonSpikeTemplateBundle, "BattleConfig.visual.poisonSpikeTemplateName is missing")
	poisonSpikeTemplateBundle = getTemplateBundle(folder2, poisonSpikeTemplateName)
	poisonSpikeTemplateName = poisonSpikeTemplateBundle.markerOffset
	local bigSpikeTemplateName = data.visual.bigSpikeTemplateName
	local bigSpikeTemplateBundle

	if type(bigSpikeTemplateName) == "string" then
		bigSpikeTemplateBundle = bigSpikeTemplateName ~= ""
	else
		bigSpikeTemplateBundle = false
	end

	assert(bigSpikeTemplateBundle, "BattleConfig.visual.bigSpikeTemplateName is missing")
	bigSpikeTemplateBundle = getTemplateBundle(folder2, bigSpikeTemplateName)
	bigSpikeTemplateName = bigSpikeTemplateBundle.markerOffset
	local templateBundle = getTemplateBundle(folder2, "领域扩张")
	local templateBundle2 = getTemplateBundle(folder2, "冰霜尾迹")
	local templateBundle3 = getTemplateBundle(folder2, "毒气尾迹")
	local templateBundle4 = getTemplateBundle(folder2, data.visual.machineGunBulletTemplateName)
	local diceTemplateName = data.visual.diceTemplateName
	local diceTemplateBundle

	if type(diceTemplateName) == "string" then
		diceTemplateBundle = diceTemplateName ~= ""
	else
		diceTemplateBundle = false
	end

	assert(diceTemplateBundle, "BattleConfig.visual.diceTemplateName is missing")
	diceTemplateBundle = getDiceTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.iceConeTemplateName
	local iceConeTemplateBundle

	if type(diceTemplateName) == "string" then
		iceConeTemplateBundle = diceTemplateName ~= ""
	else
		iceConeTemplateBundle = false
	end

	assert(iceConeTemplateBundle, "BattleConfig.visual.iceConeTemplateName is missing")
	iceConeTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.bombTemplateName
	local model5

	if type(diceTemplateName) == "string" then
		model5 = diceTemplateName ~= ""
	else
		model5 = false
	end

	assert(model5, "BattleConfig.visual.bombTemplateName is missing")
	model5 = folder2:FindFirstChild(diceTemplateName)
	assert(model5 and model5:IsA("Model"), string.format("炸弹素材模型缺失：%s", diceTemplateName))
	diceTemplateName = model5:FindFirstChild("碰撞箱")
	assert(
		diceTemplateName and diceTemplateName:IsA("BasePart"),
		string.format("炸弹素材模型 '%s' 缺少碰撞箱", model5:GetFullName())
	)
	local attachment = diceTemplateName:FindFirstChild("朝向标记")
	assert(attachment and attachment:IsA("Attachment"), string.format("炸弹素材模型 '%s' 的碰撞箱缺少朝向标记", model5:GetFullName()))
	local UI = model5:FindFirstChild("倒计时UI")
	assert(UI and UI:IsA("BillboardGui"), string.format("炸弹素材模型 '%s' 缺少倒计时UI", model5:GetFullName()))
	assert(UI:FindFirstChild("等级字"), string.format("炸弹素材模型 '%s' 的倒计时UI缺少等级字", model5:GetFullName()))
	model5.PrimaryPart = diceTemplateName
	local bombTemplateBundle = {
		model = model5,
		root = diceTemplateName,
		forwardOffset = CFrame.fromMatrix(
			createVector(0, 0, 0),
			attachment.CFrame.XVector,
			attachment.CFrame.YVector,
			attachment.CFrame.ZVector
		),
		markerOffset = attachment.CFrame
	}
	diceTemplateName = data.visual.bombExplosionTemplateName

	if type(diceTemplateName) == "string" then
		model5 = diceTemplateName ~= ""
	else
		model5 = false
	end

	assert(model5, "BattleConfig.visual.bombExplosionTemplateName is missing")
	model5 = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionRedFlyTemplateName

	if type(diceTemplateName) == "string" then
		attachment = diceTemplateName ~= ""
	else
		attachment = false
	end

	assert(attachment, "BattleConfig.visual.potionRedFlyTemplateName is missing")
	attachment = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionGreenFlyTemplateName

	if type(diceTemplateName) == "string" then
		UI = diceTemplateName ~= ""
	else
		UI = false
	end

	assert(UI, "BattleConfig.visual.potionGreenFlyTemplateName is missing")
	UI = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionBlueFlyTemplateName
	local potionBlueFlyTemplateBundle

	if type(diceTemplateName) == "string" then
		potionBlueFlyTemplateBundle = diceTemplateName ~= ""
	else
		potionBlueFlyTemplateBundle = false
	end

	assert(potionBlueFlyTemplateBundle, "BattleConfig.visual.potionBlueFlyTemplateName is missing")
	potionBlueFlyTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionRedImpactTemplateName
	local potionRedImpactTemplateBundle

	if type(diceTemplateName) == "string" then
		potionRedImpactTemplateBundle = diceTemplateName ~= ""
	else
		potionRedImpactTemplateBundle = false
	end

	assert(potionRedImpactTemplateBundle, "BattleConfig.visual.potionRedImpactTemplateName is missing")
	potionRedImpactTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionGreenImpactTemplateName
	local potionGreenImpactTemplateBundle

	if type(diceTemplateName) == "string" then
		potionGreenImpactTemplateBundle = diceTemplateName ~= ""
	else
		potionGreenImpactTemplateBundle = false
	end

	assert(potionGreenImpactTemplateBundle, "BattleConfig.visual.potionGreenImpactTemplateName is missing")
	potionGreenImpactTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionBlueImpactTemplateName
	local potionBlueImpactTemplateBundle

	if type(diceTemplateName) == "string" then
		potionBlueImpactTemplateBundle = diceTemplateName ~= ""
	else
		potionBlueImpactTemplateBundle = false
	end

	assert(potionBlueImpactTemplateBundle, "BattleConfig.visual.potionBlueImpactTemplateName is missing")
	potionBlueImpactTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionRedRegionTemplateName
	local potionRedRegionTemplateBundle

	if type(diceTemplateName) == "string" then
		potionRedRegionTemplateBundle = diceTemplateName ~= ""
	else
		potionRedRegionTemplateBundle = false
	end

	assert(potionRedRegionTemplateBundle, "BattleConfig.visual.potionRedRegionTemplateName is missing")
	potionRedRegionTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionGreenRegionTemplateName
	local potionGreenRegionTemplateBundle

	if type(diceTemplateName) == "string" then
		potionGreenRegionTemplateBundle = diceTemplateName ~= ""
	else
		potionGreenRegionTemplateBundle = false
	end

	assert(potionGreenRegionTemplateBundle, "BattleConfig.visual.potionGreenRegionTemplateName is missing")
	potionGreenRegionTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.visual.potionBlueRegionTemplateName
	local potionBlueRegionTemplateBundle

	if type(diceTemplateName) == "string" then
		potionBlueRegionTemplateBundle = diceTemplateName ~= ""
	else
		potionBlueRegionTemplateBundle = false
	end

	assert(potionBlueRegionTemplateBundle, "BattleConfig.visual.potionBlueRegionTemplateName is missing")
	potionBlueRegionTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = data.traits.ThiefKnives and data.traits.ThiefKnives.assetName
	local thiefKnifeTemplateBundle

	if type(diceTemplateName) == "string" then
		thiefKnifeTemplateBundle = diceTemplateName ~= ""
	else
		thiefKnifeTemplateBundle = false
	end

	assert(thiefKnifeTemplateBundle, "BattleConfig.traits.ThiefKnives.assetName is missing")
	thiefKnifeTemplateBundle = getTemplateBundle(folder2, diceTemplateName)
	diceTemplateName = getTemplateBundle(folder2, "盗贼蓄力特效")
	local snakeTailTemplateBundle = nil

	for _, role in data.roles do
		if not (role.skill and role.skill.trigger == "SnakeTail") then
			continue
		end

		local assetName = data.traits.SnakeTail and data.traits.SnakeTail.assetName
		local v22

		if type(assetName) == "string" then
			v22 = assetName ~= ""
		else
			v22 = false
		end

		assert(v22, "BattleConfig.traits.SnakeTail.assetName is missing")
		snakeTailTemplateBundle = getTemplateBundle(folder2, assetName)
		break
	end

	local templateBundle5 = getTemplateBundle(folder2, data.visual.glassShardTemplateName)
	local redStringTemplateName = data.visual.redStringTemplateName
	local redStringTemplateBundle

	if type(redStringTemplateName) == "string" then
		redStringTemplateBundle = redStringTemplateName ~= ""
	else
		redStringTemplateBundle = false
	end

	assert(redStringTemplateBundle, "BattleConfig.visual.redStringTemplateName is missing")
	redStringTemplateBundle = getTemplateBundle(folder2, redStringTemplateName)
	redStringTemplateName = redStringTemplateBundle.model:FindFirstChild("区域样式")
	assert(redStringTemplateName and redStringTemplateName:IsA("BasePart"), "区域边界线素材缺少 BasePart：区域样式")
	local thomasTemplateName = data.visual.thomasTemplateName
	local thomasTemplateBundle

	if type(thomasTemplateName) == "string" then
		thomasTemplateBundle = thomasTemplateName ~= ""
	else
		thomasTemplateBundle = false
	end

	assert(thomasTemplateBundle, "BattleConfig.visual.thomasTemplateName is missing")
	thomasTemplateBundle = getTemplateBundle(folder2, thomasTemplateName)
	thomasTemplateName = data.traits.Shield and data.traits.Shield.assetName
	local shieldTemplateBundle

	if type(thomasTemplateName) == "string" then
		shieldTemplateBundle = thomasTemplateName ~= ""
	else
		shieldTemplateBundle = false
	end

	assert(shieldTemplateBundle, "BattleConfig.traits.Shield.assetName is missing")
	shieldTemplateBundle = getTemplateBundle(folder2, thomasTemplateName)
	thomasTemplateName = folder2:FindFirstChild("象棋素材")
	assert(thomasTemplateName and thomasTemplateName:IsA("Model"), "象棋素材模型缺失")
	local folder3 = thomasTemplateName:FindFirstChild("装饰")
	assert(folder3 and folder3:IsA("Folder"), "象棋素材必须包含装饰 Folder")
	thomasTemplateName = folder3:FindFirstChild("Rook")
	local bishop = folder3:FindFirstChild("Bishop")
	local knight = folder3:FindFirstChild("Knight")
	local part2 = folder3:FindFirstChild("棋盘")
	assert(
		thomasTemplateName and thomasTemplateName:IsA("BasePart") and bishop and bishop:IsA("BasePart") and knight and knight:IsA("BasePart") and part2 and part2:IsA("BasePart"),
		"象棋素材缺少 Rook/Bishop/Knight/棋盘 BasePart"
	)
	folder3 = getOptionalTemplateBundle(
		folder2,
		data.traits.WDC and data.traits.WDC.assetName,
		"BattleConfig.traits.WDC"
	)
	local templateBundle6 = getTemplateBundle(folder2, "短暂加速效果")
	local templateBundle7 = getTemplateBundle(folder2, "冻结效果")
	local templateBundle8 = getTemplateBundle(folder2, "通用中毒效果")
	local templateBundle9 = getTemplateBundle(folder2, "通用减速效果")
	local templateBundle10 = getTemplateBundle(folder2, "无敌护盾")
	local assetName = data.traits.Interval and data.traits.Interval.assetName
	local burstDriveTemplateBundle

	if type(assetName) == "string" then
		burstDriveTemplateBundle = assetName ~= ""
	else
		burstDriveTemplateBundle = false
	end

	assert(burstDriveTemplateBundle, "BattleConfig.traits.Interval.assetName is missing")
	burstDriveTemplateBundle = getTemplateBundle(folder2, assetName)
	assetName = getOptionalTemplateBundle(
		folder2,
		data.traits.NoCollisionCharge and data.traits.NoCollisionCharge.assetName,
		"BattleConfig.traits.NoCollisionCharge"
	)
	local optionalTemplateBundle = getOptionalTemplateBundle(
		folder2,
		data.traits.Gravity and data.traits.Gravity.assetName,
		"BattleConfig.traits.Gravity"
	)
	local attackBuffTemplateName = data.visual.attackBuffTemplateName
	local attackBuffTemplateBundle

	if type(attackBuffTemplateName) == "string" then
		attackBuffTemplateBundle = attackBuffTemplateName ~= ""
	else
		attackBuffTemplateBundle = false
	end

	assert(attackBuffTemplateBundle, "BattleConfig.visual.attackBuffTemplateName is missing")
	attackBuffTemplateBundle = getTemplateBundle(folder2, attackBuffTemplateName)
	attackBuffTemplateName = data.visual.defenseBuffTemplateName
	local defenseBuffTemplateBundle

	if type(attackBuffTemplateName) == "string" then
		defenseBuffTemplateBundle = attackBuffTemplateName ~= ""
	else
		defenseBuffTemplateBundle = false
	end

	assert(defenseBuffTemplateBundle, "BattleConfig.visual.defenseBuffTemplateName is missing")
	defenseBuffTemplateBundle = getTemplateBundle(folder2, attackBuffTemplateName)
	attackBuffTemplateName = data.traits.ElectromagneticParalysis and data.traits.ElectromagneticParalysis.assetName
	local assetName2

	if type(attackBuffTemplateName) == "string" then
		assetName2 = attackBuffTemplateName ~= ""
	else
		assetName2 = false
	end

	assert(assetName2, "BattleConfig.traits.ElectromagneticParalysis.assetName is missing")
	assetName2 = folder2:FindFirstChild(attackBuffTemplateName)
	assert(assetName2, string.format("电磁麻痹素材容器缺失：%s", attackBuffTemplateName))
	attackBuffTemplateName = getPartTemplateBundle(assetName2, "麻痹进度1")
	local partTemplateBundle = getPartTemplateBundle(assetName2, "麻痹进度2")
	local partTemplateBundle2 = getPartTemplateBundle(assetName2, "已麻痹")
	assetName2 = data.traits.StrongParalysis and data.traits.StrongParalysis.assetName
	local assetName3

	if type(assetName2) == "string" then
		assetName3 = assetName2 ~= ""
	else
		assetName3 = false
	end

	assert(assetName3, "BattleConfig.traits.StrongParalysis.assetName is missing")
	assetName3 = folder2:FindFirstChild(assetName2)
	assert(assetName3, string.format("强力麻痹素材容器缺失：%s", assetName2))
	assetName2 = getPartTemplateBundle(assetName3, "已麻痹")
	assetName3 = data.traits.AppleThrow and data.traits.AppleThrow.assetName
	local appleTemplateBundle

	if type(assetName3) == "string" then
		appleTemplateBundle = assetName3 ~= ""
	else
		appleTemplateBundle = false
	end

	assert(appleTemplateBundle, "BattleConfig.traits.AppleThrow.assetName is missing")
	appleTemplateBundle = getTemplateBundle(folder2, assetName3)
	assetName3 = getOptionalTemplateBundle(folder2, data.traits.AcidSpit and data.traits.AcidSpit.assetName, "酸液")
	local assetName4 = data.traits.CannonTurret and data.traits.CannonTurret.assetName
	local cannonTurretTemplateBundle

	if type(assetName4) == "string" then
		cannonTurretTemplateBundle = assetName4 ~= ""
	else
		cannonTurretTemplateBundle = false
	end

	assert(cannonTurretTemplateBundle, "BattleConfig.traits.CannonTurret.assetName is missing")
	cannonTurretTemplateBundle = getTemplateBundle(folder2, assetName4)
	assetName4 = getTemplateBundle(folder2, "炮台子弹")
	local assetName5 = data.traits.LaserTurretV3 and data.traits.LaserTurretV3.assetName
	local laserTurretV3TemplateBundle

	if type(assetName5) == "string" then
		laserTurretV3TemplateBundle = assetName5 ~= ""
	else
		laserTurretV3TemplateBundle = false
	end

	assert(laserTurretV3TemplateBundle, "BattleConfig.traits.LaserTurretV3.assetName is missing")
	laserTurretV3TemplateBundle = getTemplateBundle(folder2, assetName5)
	assetName5 = data.visual.laserTurretV3BeamTemplateName
	local model6

	if type(assetName5) == "string" then
		model6 = assetName5 ~= ""
	else
		model6 = false
	end

	assert(model6, "BattleConfig.visual.laserTurretV3BeamTemplateName is missing")
	model6 = folder2:FindFirstChild(assetName5)
	assert(model6 and model6:IsA("Model"), string.format("激光V3光束素材模型缺失：%s", assetName5))
	assert(model6:FindFirstChild("碰撞箱") and model6:FindFirstChild("附着点"), "激光V3光束素材必须包含碰撞箱与附着点")
	assetName5 = data.traits.ChargedBow and data.traits.ChargedBow.assetName
	local bowTemplateBundle

	if type(assetName5) == "string" then
		bowTemplateBundle = assetName5 ~= ""
	else
		bowTemplateBundle = false
	end

	assert(bowTemplateBundle, "BattleConfig.traits.ChargedBow.assetName is missing")
	bowTemplateBundle = getTemplateBundle(folder2, assetName5)
	assetName5 = getTemplateBundle(folder2, "弓箭")
	local assetName6 = data.traits.Harpoon and data.traits.Harpoon.assetName
	local harpoonTemplateBundle

	if type(assetName6) == "string" then
		harpoonTemplateBundle = assetName6 ~= ""
	else
		harpoonTemplateBundle = false
	end

	assert(harpoonTemplateBundle, "BattleConfig.traits.Harpoon.assetName is missing")
	harpoonTemplateBundle = getTemplateBundle(folder2, assetName6)
	assetName6 = data.traits.HiveSwarm and data.traits.HiveSwarm.assetName
	local hiveBeeTemplateBundle

	if type(assetName6) == "string" then
		hiveBeeTemplateBundle = assetName6 ~= ""
	else
		hiveBeeTemplateBundle = false
	end

	assert(hiveBeeTemplateBundle, "BattleConfig.traits.HiveSwarm.assetName is missing")
	hiveBeeTemplateBundle = getTemplateBundle(folder2, assetName6)
	assetName6 = getTemplateBundle(folder2, data.traits.RobuxBarrage.assetName)
	local assetName7 = data.traits.Shuriken and data.traits.Shuriken.assetName
	local shurikenTemplateBundle

	if type(assetName7) == "string" then
		shurikenTemplateBundle = assetName7 ~= ""
	else
		shurikenTemplateBundle = false
	end

	assert(shurikenTemplateBundle, "BattleConfig.traits.Shuriken.assetName is missing")
	shurikenTemplateBundle = getTemplateBundle(folder2, assetName7)
	assetName7 = data.traits.MedicBarrage and data.traits.MedicBarrage.assetName
	local medicBulletTemplateBundle

	if type(assetName7) == "string" then
		medicBulletTemplateBundle = assetName7 ~= ""
	else
		medicBulletTemplateBundle = false
	end

	assert(medicBulletTemplateBundle, "BattleConfig.traits.MedicBarrage.assetName is missing")
	medicBulletTemplateBundle = getTemplateBundle(folder2, assetName7)
	assetName7 = getOptionalTemplateBundle(
		folder2,
		data.traits.OrbitSatellite and data.traits.OrbitSatellite.assetName,
		"轨道卫星"
	)
	local optionalTemplateBundle2 = getOptionalTemplateBundle(
		folder2,
		data.traits.MathEquation and data.traits.MathEquation.assetName,
		"数学追踪弹"
	)
	local assetName8 = data.traits.CactusThrow and data.traits.CactusThrow.assetName
	local cactusTemplateBundle

	if type(assetName8) == "string" then
		cactusTemplateBundle = assetName8 ~= ""
	else
		cactusTemplateBundle = false
	end

	assert(cactusTemplateBundle, "BattleConfig.traits.CactusThrow.assetName is missing")
	cactusTemplateBundle = getTemplateBundle(folder2, assetName8)
	assetName8 = data.visual.cactusThrowEffectTemplateName
	local cactusThrowEffectTemplateBundle

	if type(assetName8) == "string" then
		cactusThrowEffectTemplateBundle = assetName8 ~= ""
	else
		cactusThrowEffectTemplateBundle = false
	end

	assert(cactusThrowEffectTemplateBundle, "BattleConfig.visual.cactusThrowEffectTemplateName is missing")
	cactusThrowEffectTemplateBundle = getTemplateBundle(folder2, assetName8)
	assetName8 = getOptionalTemplateBundle(folder2, data.traits.TrapRelease and data.traits.TrapRelease.assetName, "陷阱")
	getOptionalTemplateBundle(folder2, data.visual.trapReleaseEffectTemplateName, "陷阱释放特效")
	local assetName9 = data.traits.SpearThrust and data.traits.SpearThrust.assetName
	local spearTemplateBundle

	if type(assetName9) == "string" then
		spearTemplateBundle = assetName9 ~= ""
	else
		spearTemplateBundle = false
	end

	assert(spearTemplateBundle, "BattleConfig.traits.SpearThrust.assetName is missing")
	spearTemplateBundle = getTemplateBundle(folder2, assetName9)
	assetName9 = getOptionalTemplateBundle(folder2, data.visual.spearDashEffectTemplateName, "长矛冲刺特效")
	local optionalTemplateBundle3 = getOptionalTemplateBundle(
		folder2,
		data.traits.OnePunch and data.traits.OnePunch.assetName,
		"BattleConfig.traits.OnePunch"
	)
	local trainTrack = data.traits and data.traits.TrainTrack
	local assetName10 = trainTrack and trainTrack.assetName
	local templateBundle11 = getTemplateBundle(
		folder2,
		(type(assetName10) ~= "string" or assetName10 == "") and "火车头" or assetName10
	)
	local templateBundle12 = getTemplateBundle(folder2, "火车身")
	local templateBundle13 = getTemplateBundle(folder2, "轨道木板")
	local assetName11 = data.traits.VolcanoEruption and data.traits.VolcanoEruption.assetName
	local volcanoFlameTemplateBundle

	if type(assetName11) == "string" then
		volcanoFlameTemplateBundle = assetName11 ~= ""
	else
		volcanoFlameTemplateBundle = false
	end

	assert(volcanoFlameTemplateBundle, "BattleConfig.traits.VolcanoEruption.assetName is missing")
	volcanoFlameTemplateBundle = getTemplateBundle(folder2, assetName11)
	assetName11 = getOptionalTemplateBundle(folder2, data.visual.volcanoWarningTemplateName, "火山预警线")
	local optionalTemplateBundle4 = getOptionalTemplateBundle(folder2, data.visual.volcanoBurnTemplateName, "火山着火效果")
	local v41 = instance:WaitForChild("美术素材"):WaitForChild("棋盘")
	local boardAssetName = data.arena.boardAssetName
	local model7

	if type(boardAssetName) == "string" then
		model7 = boardAssetName ~= ""
	else
		model7 = false
	end

	assert(model7, "BattleConfig.arena.boardAssetName is missing")
	model7 = v41:FindFirstChild(boardAssetName)
	assert(
		model7 and model7:IsA("Model"),
		string.format("ReplicatedStorage.美术素材.棋盘.%s is missing or not a Model", boardAssetName)
	)
	return {
		ballAssetRoot = folder,
		effectAssetRoot = folder2,
		sameMaterialEnemyHighlightTemplate = highlight,
		ballTemplateBundles = ballTemplateBundles,
		bladeTemplateBundle = bladeTemplateBundle,
		bladePivotOffset = bladeTemplateName,
		swordTemplateBundle = swordTemplateBundle,
		axeTemplateBundle = axeTemplateBundle,
		spiderWebTemplateBundle = spiderWebTemplateBundle,
		vampireWebTemplateBundle = vampireWebTemplateBundle,
		hookSegmentCount = swordTemplateName,
		hookSegmentMarkerLocalCFrames = cFrames,
		hookTemplate = model,
		hookTipMarkerOffset = cFrame,
		laserTemplate = model2,
		electroKingTemplate = model3,
		dogCannonTemplate = model4,
		dogChargeTemplateBundle = laserTemplateName,
		poisonSpikeTemplateBundle = poisonSpikeTemplateBundle,
		poisonSpikeMarkerOffset = poisonSpikeTemplateName,
		bigSpikeTemplateBundle = bigSpikeTemplateBundle,
		bigSpikeMarkerOffset = bigSpikeTemplateName,
		expandingAuraTemplateBundle = templateBundle,
		frostTrailTemplateBundle = templateBundle2,
		alchemistGasTrailTemplateBundle = templateBundle3,
		machineGunBulletTemplateBundle = templateBundle4,
		diceTemplateBundle = diceTemplateBundle,
		iceConeTemplateBundle = iceConeTemplateBundle,
		thiefKnifeTemplateBundle = thiefKnifeTemplateBundle,
		orbitSatelliteTemplateBundle = assetName7,
		mathBulletTemplateBundle = optionalTemplateBundle2,
		thiefChargeTemplateBundle = diceTemplateName,
		snakeTailTemplateBundle = snakeTailTemplateBundle,
		glassShardTemplateBundle = templateBundle5,
		redStringTemplateBundle = redStringTemplateBundle,
		zoneStyleTemplate = redStringTemplateName,
		thomasTemplateBundle = thomasTemplateBundle,
		shieldTemplateBundle = shieldTemplateBundle,
		chessAssets = {
			rook = thomasTemplateName,
			bishop = bishop,
			knight = knight,
			board = part2
		},
		wdcTemplateBundle = folder3,
		speedEffectTemplateBundle = templateBundle6,
		freezeEffectTemplateBundle = templateBundle7,
		poisonTemplateBundle = templateBundle8,
		vampireShieldTemplateBundle = templateBundle10,
		burstDriveTemplateBundle = burstDriveTemplateBundle,
		noCollisionChargeTemplateBundle = assetName,
		gravityTemplateBundle = optionalTemplateBundle,
		attackBuffTemplateBundle = attackBuffTemplateBundle,
		defenseBuffTemplateBundle = defenseBuffTemplateBundle,
		electromagneticParalysisProgress1TemplateBundle = attackBuffTemplateName,
		electromagneticParalysisProgress2TemplateBundle = partTemplateBundle,
		electromagneticParalysisParalyzedTemplateBundle = partTemplateBundle2,
		strongParalysisTemplateBundle = assetName2,
		slowOnHitTemplateBundle = templateBundle9,
		boardTemplate = model7,
		appleTemplateBundle = appleTemplateBundle,
		acidSpitTemplateBundle = assetName3,
		cannonTurretTemplateBundle = cannonTurretTemplateBundle,
		cannonBulletTemplateBundle = assetName4,
		laserTurretV3TemplateBundle = laserTurretV3TemplateBundle,
		laserTurretV3BeamTemplate = model6,
		bowTemplateBundle = bowTemplateBundle,
		arrowTemplateBundle = assetName5,
		harpoonTemplateBundle = harpoonTemplateBundle,
		hiveBeeTemplateBundle = hiveBeeTemplateBundle,
		robuxTemplateBundle = assetName6,
		shurikenTemplateBundle = shurikenTemplateBundle,
		medicBulletTemplateBundle = medicBulletTemplateBundle,
		trainHeadTemplateBundle = templateBundle11,
		trainBodyTemplateBundle = templateBundle12,
		trackSleeperTemplateBundle = templateBundle13,
		bombTemplateBundle = bombTemplateBundle,
		bombExplosionTemplateBundle = model5,
		potionRedFlyTemplateBundle = attachment,
		potionGreenFlyTemplateBundle = UI,
		potionBlueFlyTemplateBundle = potionBlueFlyTemplateBundle,
		potionRedImpactTemplateBundle = potionRedImpactTemplateBundle,
		potionGreenImpactTemplateBundle = potionGreenImpactTemplateBundle,
		potionBlueImpactTemplateBundle = potionBlueImpactTemplateBundle,
		potionRedRegionTemplateBundle = potionRedRegionTemplateBundle,
		potionGreenRegionTemplateBundle = potionGreenRegionTemplateBundle,
		potionBlueRegionTemplateBundle = potionBlueRegionTemplateBundle,
		cactusTemplateBundle = cactusTemplateBundle,
		cactusThrowEffectTemplateBundle = cactusThrowEffectTemplateBundle,
		trapTemplateBundle = assetName8,
		spearTemplateBundle = spearTemplateBundle,
		spearDashEffectTemplateBundle = assetName9,
		onePunchTrailTemplateBundle = optionalTemplateBundle3,
		volcanoFlameTemplateBundle = volcanoFlameTemplateBundle,
		volcanoWarningTemplateBundle = assetName11,
		volcanoBurnTemplateBundle = optionalTemplateBundle4
	}
end

function TemplateLibrary.clone(p)
	local clone = p.model:Clone()
	local part = clone:FindFirstChild("碰撞箱")
	assert(part and part:IsA("BasePart"), string.format("克隆素材 '%s' 缺少碰撞箱", p.model.Name))
	clone.PrimaryPart = part

	for _, part2 in ipairs(clone:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		part2:SetAttribute("OriginalTransparency", part2.Transparency)
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
	end

	return clone, part
end

function TemplateLibrary.setVisible(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local originalTransparency = part:GetAttribute("OriginalTransparency")
		part.Transparency = not flag and 1 or typeof(originalTransparency) == "number" and originalTransparency or part.Transparency or 1
	end
end

function TemplateLibrary.buildBoardModel(p, instance, cframe: CFrame)
	local clone = instance:Clone()
	clone.Name = "Board"
	local part = clone:FindFirstChild("绑定箱")

	if part and part:IsA("BasePart") then
		local size = p.arena.size

		if math.abs(part.Size.X - size.X) > 0.01 or math.abs(part.Size.Y - size.Y) > 0.01 then
			warn(string.format(
				"[TemplateLibrary] 棋盘 '%s' 绑定箱平面尺寸(%.2f, %.2f)与配置尺寸(%.2f, %.2f)不一致",
				instance.Name,
				part.Size.X,
				part.Size.Y,
				size.X,
				size.Y
			))
		end

		for _, part2 in ipairs(clone:GetDescendants()) do
			if not (part2:IsA("BasePart") and part2 ~= part) then
				continue
			end

			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
		end

		part.Anchored = true
		part.CanCollide = true

		for _, part2 in ipairs(clone:GetChildren()) do
			if not (part2:IsA("BasePart") and string.match(part2.Name, "位置%d+$")) then
				continue
			end

			part2.Transparency = 1
		end

		clone.PrimaryPart = part
		clone:PivotTo(cframe)
		return clone
	else
		warn(string.format("[TemplateLibrary] 棋盘 '%s' 缺少绑定箱，跳过本次棋盘生成", instance.Name))
		clone:Destroy()
		return nil
	end
end

TemplateLibrary.getTemplateBundle = getTemplateBundle
return TemplateLibrary