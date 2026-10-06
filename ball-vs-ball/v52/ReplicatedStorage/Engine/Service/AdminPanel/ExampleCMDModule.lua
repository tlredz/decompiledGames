return {
	["示例数量指令"] = {
		order = 10,
		desc = "类型简写或限制表；有默认值可留空",
		params = {
			["数量"] = {
				type = "integer",
				default = 1,
				min = 1,
				max = 100
			},
			["备注"] = {
				type = "string",
				required = false
			}
		},
		paramOrder = { "数量", "备注" },
		clientFn = function(_, p)
			return {
				ok = true,
				message = "执行完成",
				data = {
					count = p["数量"]
				}
			}
		end
	},
	["示例开关"] = {
		order = 20,
		toggle = true,
		desc = "开关状态由框架放在 args.enabled；成功后才改变按钮状态",
		clientFn = function(_, p)
			return {
				ok = true,
				message = p.enabled and "已开启" or "已关闭"
			}
		end
	},
	["示例补全"] = {
		order = 30,
		params = {
			["玩家名"] = "playerName",
			["分类"] = {
				type = "string",
				choices = { "小球", "飞行器" }
			}
		},
		paramOrder = { "玩家名", "分类" },
		serverFn = function(_, _)
			return {
				ok = true,
				message = "服务端执行完成"
			}
		end
	}
}