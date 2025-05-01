--!nolint
--!nocheck

local themes = {
	def = { -- light
		bg = Color3.fromRGB(255,255,255); -- settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground);
		bg2 = Color3.fromRGB(220,220,220);
		txt = Color3.new(0,0,0);
		txt2 = Color3.fromRGB(80,80,80);
		img = Color3.new(0,0,0);
		scroll = Color3.new(0,0,0);
	};
	
	dark = {
		bg = Color3.fromRGB(10,10,14);
		bg2 = Color3.fromRGB(30, 30, 37);
		txt = Color3.new(1,1,1);
		txt2 = Color3.fromRGB(200,200,200);
		img = Color3.new(1,1,1);
		scroll = Color3.new(1,1,1);
	};
}

local r = script.Parent.Parent
local gateway = r.connect.plugin_gateway

function themes:apply_light(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	for _, v in pairs(widget:GetDescendants()) do
		if v:IsA("GuiObject") then
			if v:GetAttribute("clrsync") then
				local clr = themes.def[v:GetAttribute("clrsync")]
				
				if clr then
					if v:IsA("Frame") or v:IsA("ViewportFrame") then
						v.BackgroundColor3 = clr
					elseif v:IsA("TextLabel") then
						v.TextColor3 = clr
					elseif v:IsA("TextButton") then
						v.TextColor3 = clr
					elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.ImageColor3 = clr
					elseif v:IsA("TextBox") then
						v.TextColor3 = clr
						v.PlaceholderColor3 = themes.def.txt2
					elseif v:IsA("ScrollingFrame") then
						v.ScrollBarImageColor3 = clr
					end
				end
			end
		end
	end
end

function themes:apply_dark(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end

	for _, v in pairs(widget:GetDescendants()) do
		if v:IsA("GuiObject") then
			if v:GetAttribute("clrsync") then
				local clr = themes.dark[v:GetAttribute("clrsync")]

				if clr then
					if v:IsA("Frame") or v:IsA("ViewportFrame") then
						v.BackgroundColor3 = clr
					elseif v:IsA("TextLabel") then
						v.TextColor3 = clr
					elseif v:IsA("TextButton") then
						v.TextColor3 = clr
					elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.ImageColor3 = clr
					elseif v:IsA("TextBox") then
						v.TextColor3 = clr
						v.PlaceholderColor3 = themes.dark.txt2
					elseif v:IsA("ScrollingFrame") then
						v.ScrollBarImageColor3 = clr
					end
				end
			end
		end
	end
end

function themes:apply_theme_to_ic(obj:GuiObject, theme_def_name)
	if obj:GetAttribute("clrsync") then
		local clr = themes[theme_def_name][obj:GetAttribute("clrsync")]

		if clr then
			if obj:IsA("Frame") then
				obj.BackgroundColor3 = clr
			end
		end
	end
	
	for _, v in pairs(obj:GetDescendants()) do
		if v:IsA("GuiObject") then
			if v:GetAttribute("clrsync") then
				local clr = themes[theme_def_name][v:GetAttribute("clrsync")]

				if clr then
					if v:IsA("Frame") then
						v.BackgroundColor3 = clr
					elseif v:IsA("TextLabel") then
						v.TextColor3 = clr
					elseif v:IsA("TextButton") then
						v.TextColor3 = clr
					elseif v:IsA("ImageLabel") then
						v.ImageColor3 = clr
					elseif v:IsA("TextBox") then
						v.TextColor3 = clr
						v.PlaceholderColor3 = themes[theme_def_name].txt2
					end
				end
			end
		end
	end
end

return themes