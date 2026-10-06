local BallVisualRegistry = {
	DEFAULT_COLOR = Color3.fromRGB(200, 200, 200),
	DEFAULT_HIGHLIGHT_COLOR = Color3.fromRGB(235, 235, 235)
}
local v = {
	["爆发球"] = {
		color = Color3.fromRGB(80, 150, 255),
		highlightColor = Color3.fromRGB(185, 225, 255)
	},
	["蓄力球"] = {
		color = Color3.fromRGB(255, 207, 73),
		highlightColor = Color3.fromRGB(255, 245, 170)
	},
	["斐波那契球"] = {
		color = Color3.fromRGB(255, 193, 7),
		highlightColor = Color3.fromRGB(255, 224, 130)
	},
	["刀片球"] = {
		color = Color3.fromRGB(134, 228, 169),
		highlightColor = Color3.fromRGB(220, 255, 231)
	},
	["长剑球"] = {
		color = Color3.fromRGB(112, 178, 255),
		highlightColor = Color3.fromRGB(214, 236, 255)
	},
	["吸血鬼球"] = {
		color = Color3.fromRGB(210, 46, 46),
		highlightColor = Color3.fromRGB(255, 168, 168)
	},
	["蜘蛛球"] = {
		color = Color3.fromRGB(225, 225, 235),
		highlightColor = Color3.fromRGB(255, 255, 255)
	},
	["吸血蜘蛛球"] = {
		color = Color3.fromRGB(150, 20, 30),
		highlightColor = Color3.fromRGB(255, 150, 150)
	},
	["区域球"] = {
		color = Color3.fromRGB(255, 86, 86),
		highlightColor = Color3.fromRGB(255, 186, 186)
	},
	["毒刺球"] = {
		color = Color3.fromRGB(0, 255, 0),
		highlightColor = Color3.fromRGB(170, 255, 170)
	},
	["病毒球"] = {
		color = Color3.fromRGB(140, 60, 200),
		highlightColor = Color3.fromRGB(210, 170, 240)
	},
	["大刺球"] = {
		color = Color3.fromRGB(200, 90, 40),
		highlightColor = Color3.fromRGB(255, 180, 130)
	},
	["细胞球"] = {
		color = Color3.fromRGB(115, 232, 142),
		highlightColor = Color3.fromRGB(205, 255, 214)
	},
	["蛇球"] = {
		color = Color3.fromRGB(88, 186, 104),
		highlightColor = Color3.fromRGB(191, 255, 196)
	},
	["盗贼球"] = {
		color = Color3.fromRGB(92, 84, 122),
		highlightColor = Color3.fromRGB(196, 186, 232)
	},
	["冰锥球"] = {
		color = Color3.fromRGB(98, 196, 255),
		highlightColor = Color3.fromRGB(218, 246, 255)
	},
	["十万伏特"] = {
		color = Color3.fromRGB(107, 82, 255),
		highlightColor = Color3.fromRGB(255, 245, 170)
	},
	["骰子球"] = {
		color = Color3.fromRGB(244, 235, 204),
		highlightColor = Color3.fromRGB(255, 250, 225)
	},
	["象棋球"] = {
		color = Color3.fromRGB(207, 161, 76),
		highlightColor = Color3.fromRGB(255, 229, 151)
	},
	["苹果球"] = {
		color = Color3.fromRGB(200, 50, 50),
		highlightColor = Color3.fromRGB(255, 140, 140)
	},
	["炮台球"] = {
		color = Color3.fromRGB(90, 90, 100),
		highlightColor = Color3.fromRGB(160, 160, 175)
	},
	["电王球"] = {
		color = Color3.fromRGB(90, 160, 230),
		highlightColor = Color3.fromRGB(170, 220, 255)
	},
	["激光V3球"] = {
		color = Color3.fromRGB(200, 40, 40),
		highlightColor = Color3.fromRGB(255, 130, 110)
	},
	["弓球"] = {
		color = Color3.fromRGB(150, 110, 60),
		highlightColor = Color3.fromRGB(210, 170, 120)
	},
	["范围球"] = {
		color = Color3.fromRGB(120, 90, 220),
		highlightColor = Color3.fromRGB(190, 170, 250)
	},
	["冰霜球"] = {
		color = Color3.fromRGB(140, 210, 235),
		highlightColor = Color3.fromRGB(210, 240, 250)
	},
	["炼金术士球"] = {
		color = Color3.fromRGB(49, 98, 0),
		highlightColor = Color3.fromRGB(126, 255, 70)
	},
	WDC = {
		color = Color3.fromRGB(80, 200, 190),
		highlightColor = Color3.fromRGB(190, 245, 240)
	},
	["大狗球"] = {
		color = Color3.fromRGB(180, 140, 90),
		highlightColor = Color3.fromRGB(235, 205, 165)
	},
	["炸弹球"] = {
		color = Color3.fromRGB(55, 55, 60),
		highlightColor = Color3.fromRGB(255, 140, 60)
	},
	["药水球"] = {
		color = Color3.fromRGB(150, 90, 200),
		highlightColor = Color3.fromRGB(210, 170, 240)
	},
	["列车长球"] = {
		color = Color3.fromRGB(70, 70, 78),
		highlightColor = Color3.fromRGB(200, 60, 50)
	},
	["鱼叉球"] = {
		color = Color3.fromRGB(40, 90, 130),
		highlightColor = Color3.fromRGB(110, 170, 210)
	},
	["蜂巢球"] = {
		color = Color3.fromRGB(235, 180, 40),
		highlightColor = Color3.fromRGB(255, 220, 90)
	},
	["仙人掌球"] = {
		color = Color3.fromRGB(60, 140, 70),
		highlightColor = Color3.fromRGB(120, 200, 120)
	},
	["长矛球"] = {
		color = Color3.fromRGB(110, 135, 165),
		highlightColor = Color3.fromRGB(195, 215, 235)
	},
	["Robux球"] = {
		color = Color3.fromRGB(27, 25, 22),
		highlightColor = Color3.fromRGB(255, 205, 65)
	},
	["手里剑球"] = {
		color = Color3.fromRGB(150, 150, 165),
		highlightColor = Color3.fromRGB(210, 210, 220)
	},
	["医疗球"] = {
		color = Color3.fromRGB(90, 200, 120),
		highlightColor = Color3.fromRGB(190, 250, 205)
	},
	["数学球"] = {
		color = Color3.fromRGB(70, 130, 110),
		highlightColor = Color3.fromRGB(170, 220, 200)
	},
	["一拳球"] = {
		color = Color3.fromRGB(220, 70, 50),
		highlightColor = Color3.fromRGB(255, 170, 140)
	},
	["轨道球"] = {
		color = Color3.fromRGB(60, 72, 110),
		highlightColor = Color3.fromRGB(180, 235, 255)
	},
	["酸液球"] = {
		color = Color3.fromRGB(120, 200, 60),
		highlightColor = Color3.fromRGB(190, 240, 140)
	},
	["陷阱师球"] = {
		color = Color3.fromRGB(120, 40, 40),
		highlightColor = Color3.fromRGB(200, 70, 70)
	},
	["火山球"] = {
		color = Color3.fromRGB(225, 60, 15),
		highlightColor = Color3.fromRGB(255, 160, 40)
	}
}

function BallVisualRegistry.get(p: string)
	return v[p] or {
		color = BallVisualRegistry.DEFAULT_COLOR,
		highlightColor = BallVisualRegistry.DEFAULT_HIGHLIGHT_COLOR
	}
end

return BallVisualRegistry