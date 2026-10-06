local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIToolkit = require(ReplicatedStorage.Packages.UIToolkit)
local UIManager = {}
local v = {
	"货币",
	"商店",
	"背包",
	"界面图标",
	"抽奖效果",
	"抽奖转盘",
	"战斗3选1",
	"战斗匹配UI",
	"通用确认框",
	"每日签到",
	"在线奖励",
	"玩家面板",
	"交易",
	"右侧菜单",
	"表情轮盘",
	"设置界面",
	"更新日志",
	"下方按钮区",
	"小摊",
	"经验条",
	"图鉴",
	"贴纸",
	"限定礼包",
	"邮件",
	"全服抽奖活动",
	"模式选择",
	"组队",
	"全服播报",
	"奖励领取通知"
}
local flag = false

function UIManager.Get(_: string)
	return nil
end

function UIManager.SetScreenGuiEnabled(_: string, _: boolean)
	return false
end

function UIManager.Init()
	if flag then
		return
	end

	flag = true
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	for _, childName in v do
		local waitForChild = playerGui:WaitForChild(childName)
		waitForChild.Enabled = true
	end

	local v2 = {
		["手柄按键提示"] = true,
		["手柄导航提示"] = true,
		["手柄瞄准提示"] = true
	}

	for _, childName in { "下方按钮区", "战斗3选1", "战斗匹配UI" } do
		for _, guiObject in playerGui:WaitForChild(childName):GetDescendants() do
			if guiObject:IsA("GuiObject") and v2[guiObject.Name] then
				guiObject.Visible = false
			end
		end
	end

	local v3 = UIToolkit.client.initUIManager(script.Parent, v)
	UIManager.Get = v3.Get
	UIManager.SetScreenGuiEnabled = v3.SetScreenGuiEnabled
end

return UIManager