local ts = game:GetService("TweenService")
local debris = game:GetService("Debris")
local txts = game:GetService("TextService")
local players = game:GetService('Players')

local r = script.Parent.Parent

--local sc = require(script.Parent.sprite_clip)
local sc2 = require(script.Parent.sprite_clip2)
local themes = require(r.modules.themes)


return function(widget:DockWidgetPluginGui)
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	local function scan_apply(v)
		if v.Name == "__loader" then
			task.spawn(function()
				v:SetAttribute("completion", 0)
				if v:FindFirstChild("m") and v.m:FindFirstChild("bar") then
					v.m.bar:TweenSize(UDim2.new((v:GetAttribute("completion") or 0)/100,0,1,0),"Out","Quad",0.25,true)

					v:GetAttributeChangedSignal("completion"):Connect(function()
						v.m.bar:TweenSize(UDim2.new((v:GetAttribute("completion") or 0)/100,0,1,0),"Out","Quad",0.25,true)
						if v:GetAttribute("completion") >= 100 then
							task.wait(1)
							v:SetAttribute("completion",0)
						end
					end)

					while task.wait() do
						ts:Create(v.m.bar, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
						task.wait(.6)
						ts:Create(v.m.bar, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.25}):Play()
						task.wait(.6)
					end
				end
			end)
		elseif v.Name == "__quantum_spinner" then -- correction: not a quantum because it's a single solid colour, should be called a circular progress indeterminate instead
			if v:IsA("ImageLabel") or v:IsA("ImageButton") then -- do you really always know?
				local obj = sc2.CompatibilitySprite.new()
				v.Image = "http://www.roblox.com/asset/?id=80321144315557" --"http://www.roblox.com/asset/?id=18334018297"
				obj.InheritSpriteSheet = true
				obj.Adornee = v
				obj.SpriteSizePixel = Vector2.new(31,31)
				obj.SpriteCountX = 5
				obj.SpriteCount = 162 --y:33 -- missing from the last row:3 -- catface reference??? -- (this is probably outdated, look above)
				obj.FrameRate = 30
				if v.Visible and v.Parent.Visible then
					obj:Play()
				end
				
				v:GetPropertyChangedSignal('Visible'):Connect(function()
					if v.Visible and v.Parent.Visible then
						obj:Play()
					else
						obj:Stop()
					end
				end)
				
				v.Parent:GetPropertyChangedSignal('Visible'):Connect(function()
					if v.Visible and v.Parent.Visible then
						obj:Play()
					else
						obj:Stop()
					end
				end)
			end
		elseif v.Name == "__slider" then
			if v:GetAttribute("state") == nil then v:SetAttribute("state", false) end

			if v:GetAttribute("state") == true then
				v.c:TweenPosition(UDim2.new(0,v.Size.X.Offset-v.c.Size.X.Offset),"Out","Quad",0.3,true)
				ts:Create(v.c.inner, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(42, 100, 246), BackgroundTransparency = 0}):Play()
			end
			
			if v:GetAttribute("enabled") == false then
				ts:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.6}):Play()
				ts:Create(v.c.inner, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.8}):Play()
			end

			local hitbox = v.Parent:FindFirstChild("mapped_hitbox") or v.hitbox

			if hitbox then
				hitbox.MouseButton1Click:Connect(function()
					if v:GetAttribute("enabled") == false then return end
					v:SetAttribute("state", if typeof(v:GetAttribute("state")) == "boolean" then not v:GetAttribute("state") else true)
					--if v:GetAttribute("state") == true then
					--	v:SetAttribute("state", false)
					--	v.c:TweenPosition(UDim2.new(0,0),"Out","Quad",0.3,true)
					--	ts:Create(v.c.inner, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(230, 230, 230), BackgroundTransparency = 0.2}):Play()
					--else
					--	v:SetAttribute("state", true)
					--	v.c:TweenPosition(UDim2.new(0,v.Size.X.Offset-v.c.Size.X.Offset),"Out","Quad",0.3,true)
					--	ts:Create(v.c.inner, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(42, 100, 246), BackgroundTransparency = 0}):Play()
					--end
				end)
			end

			v:GetAttributeChangedSignal("state"):Connect(function()
				if v:GetAttribute("state") == true then
					v.c:TweenPosition(UDim2.new(0,v.Size.X.Offset-v.c.Size.X.Offset),"Out","Quad",0.3,true)
					ts:Create(v.c.inner, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(42, 100, 246), BackgroundTransparency = 0}):Play()
					--v:SetAttribute("state", false)
				else
					--v:SetAttribute("state", true)
					v.c:TweenPosition(UDim2.new(0,0),"Out","Quad",0.3,true)
					ts:Create(v.c.inner, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(230, 230, 230), BackgroundTransparency = 0.2}):Play()
				end

				if v:GetAttribute("enabled") == false then return end
				r.connect.slider_opt:Fire(v.Parent.Name, v:GetAttribute("state"))
			end)

			v:GetAttributeChangedSignal("enabled"):Connect(function()
				if v:GetAttribute("enabled") == true then
					ts:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
					if v:GetAttribute("state") == true then
						ts:Create(v.c.inner, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
					else
						ts:Create(v.c.inner, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()
					end
				else
					task.wait() -- pause incase the state is being set simultaneously, otherwise the state's tween would override this
					ts:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.6}):Play()
					ts:Create(v.c.inner, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.8}):Play()
				end
			end)

		elseif v.Name == "__tooltip" then
			if v:IsA("GuiObject") then
				local t
				v.MouseEnter:Connect(function(x,y)
					t = r.ui.tooltip:Clone()
					t.txt.Text = v:GetAttribute("text") or "unknown"
					t.Parent = app
					--t.Size = UDim2.new(0,t.txt.TextBounds.X+8,0,16)
					t.Position = UDim2.new(0,x+6,0,y+6)
					--print(t.AbsolutePosition, t.AbsoluteSize)
					--if app.AbsoluteSize.X <= t.AbsolutePosition.X+t.AbsoluteSize.X then
					--	--print(txts:GetTextSize(t.txt.Text, 14, Enum.Font.MontserratMedium, Vector2.new(app.AbsoluteSize.X-(t.AbsolutePosition.X+t.AbsoluteSize.X), 32)))
					--	t.Size = UDim2.new(0,(t.txt.TextBounds.X/1.7)+8,0,32) -- if it works it works, dont ask questions, its not as bad as it looks
					--	--t.Position = UDim2.new(t.Position.X.Scale,t.Position.X.Offset-t.AbsoluteSize.X-8,t.Position.Y.Scale,t.Position.Y.Offset)
					--	--if app.AbsoluteSize.X <= t.AbsolutePosition.X+t.AbsoluteSize.X then
					--	--	t.Size = UDim2.new(0,(t.txt.TextBounds.X/1.7)+8,0,32) -- if it works it works, dont ask questions, its not as bad as it looks
					--	--end
					--end
				end)

				v.MouseMoved:Connect(function(x,y)
					if t then
						t.Position = UDim2.new(0,x+6,0,y+6)
					end
				end)

				v.MouseLeave:Connect(function()
					if t then
						debris:AddItem(t, 0)
					end
				end)
			end
		elseif v:GetAttribute("tooltip_is_hint") and v:IsA("GuiObject") then
			if v:GetAttribute("tooltip_text") then
				local isovr
				local t

				v.MouseEnter:Connect(function(x,y)
					isovr = true
					task.wait(2)
					if isovr then
						if not t then
							if v:GetAttribute('tooltip_text'):sub(1, 4) == 'usn:' then v:SetAttribute('tooltip_text', '@' .. players:GetNameFromUserIdAsync(tonumber(string.split(v:GetAttribute('tooltip_text'), 'usn:')[2] or 1))) end
							
							t = r.ui.tooltip:Clone()
							t.txt.Text = v:GetAttribute('tooltip_text') or "unknown"
							t.Parent = app
							t.Size = UDim2.new(0,t.txt.TextBounds.X+8,0,16)
							t.Position = UDim2.new(0,x+6,0,y+6)
							--print(t.AbsolutePosition, t.AbsoluteSize)
							--if app.AbsoluteSize.X <= t.AbsolutePosition.X+t.AbsoluteSize.X then
							--	--t.Size = UDim2.new(0,(t.txt.TextBounds.X/1.7)+8,0,32) -- if it works it works, dont ask questions, its not as bad as it looks
							--	t.Position = UDim2.new(t.Position.X.Scale,t.Position.X.Offset-t.AbsoluteSize.X-8,t.Position.Y.Scale,t.Position.Y.Offset+6)
							--end
						end
					end
				end)

				v.MouseMoved:Connect(function(x,y)
					if t then
						t.Position = UDim2.new(0,x+6,0,y+6)
						if app.AbsoluteSize.X <= t.AbsolutePosition.X+t.AbsoluteSize.X then
							--t.Size = UDim2.new(0,(t.txt.TextBounds.X/1.7)+8,0,32) -- if it works it works, dont ask questions, its not as bad as it looks
							t.Position = UDim2.new(t.Position.X.Scale,t.Position.X.Offset-t.AbsoluteSize.X-8,t.Position.Y.Scale,t.Position.Y.Offset+6)
						end
					end
				end)

				v.MouseLeave:Connect(function()
					isovr = false
					if t then
						debris:AddItem(t, 0)
						t = nil
					end
				end)
			end
		end
		
		themes:apply_theme_to_ic(v, settings().Studio and settings().Studio.Theme and settings().Studio.Theme.Name and settings().Studio.Theme.Name:lower() == "light" and "def" or "dark")
	end
	
	for _, v in pairs(app:GetDescendants()) do
		scan_apply(v)
	end
	
	script.__apply_scan.Event:Connect(function(v)
		if v then scan_apply(v) end
	end)
end