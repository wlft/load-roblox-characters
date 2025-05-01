--[[
	Load Roblox Characters
	by @Wolf1te
	
	Originally created 19/02/22
	Revamped 27/06/22 - 31/08/22
	Revamped Again 03/06/23 - 23/06/23
	Revamped Again 17/02/24 - --/08/24
	
	Last Updated: 28/03/25, v4.4.2
	(dd/mm/yy)
	
	Changelog:
	
	- Mini fix: 12/10/23, v3.0b (proxy change + caching)
	...
	- Mini fix: 7/12/23, v3.0d (fixed outfits loading non-editable assets: ?isEditable=true&itemsPerPage=50&outfitType=Avatar&page=1)
	- 17/02/24: Switched to SemVer
	- Changelog now maintained on gitbook/lrc/load-roblox-characters-4
	
	-- this script and all modules were written by @Wolf1te unless stated otherwise
]]

if game:GetService("RunService"):IsRunning() then return end

--local plugin : Plugin = plugin

-- // create plugin
local toolbar = plugin:CreateToolbar('Load Roblox Characters') -- game:FindFirstChild("Wolfite")
toolbar:SetAttribute('__wlft', os.time())

if plugin.Name:gmatch('(%.rbxmx?)$')() then
	--warn('<color:dpblue>LRC4 DEV | REMOVING `Wolfite` TOOLBAR AT `game.Wolfite` TO PREVENT ERRORS')
	--game:GetService('Debris'):AddItem(toolbar, 0)
	--task.wait()
	--task.wait(.4)
end

--if not toolbar then
--	toolbar = plugin:CreateToolbar("Wolfite")
--	toolbar.Name = "Wolfite"
--	toolbar.Parent = game
--	toolbar.Archivable = false
--	toolbar:SetAttribute("load_metadata", `\{"initialism":"LRC","version":4\,"loaded_at":{os.time()}}`)
--	toolbar:SetAttribute("structure", 1)
--end

local lrc:PluginToolbarButton = toolbar:FindFirstChild("LoadRobloxCharacters") or toolbar:CreateButton("Load Character","Open the LRC4 widget to load a character from Roblox","rbxassetid://13835619451")
lrc.Name = "LoadRobloxCharacters"
lrc:SetAttribute("version", 4)
lrc:SetAttribute("load_metadata", `\{"name":\{"full":"Load Roblox Characters","initialism":"LRC"},"version":4\,"loaded_at":{os.time()},"is_local":{tostring(plugin.Name:match('(%.rbxmx?)$') ~= nil or false)}}`)
toolbar:SetAttribute("pl__lrc", `\{"name":\{"full":"Load Roblox Characters","initialism":"LRC"},"loading_completed":{os.time()}}`)
lrc.Parent = toolbar
lrc.ClickableWhenViewportHidden = true



local core_gui = game:GetService("CoreGui")
local http = game:GetService("HttpService")

if core_gui:FindFirstChild("LRC4") then core_gui:FindFirstChild("LRC4"):Destroy() end

local ii = {
	lv = "4.4.2";
	cv = nil;
	lc = os.time()
}

-- this table really isnt necessary and isnt referenced because settings could update in other studio windows, etc, etc
local data = {
	studio_theme = settings().Studio and settings().Studio.Theme and settings().Studio.Theme.Name and settings().Studio.Theme.Name:lower() or "dark"; -- "light"/"dark"
	--pinned = plugin:GetSetting("pinned") or {game:GetService("StudioService"):GetUserId()};
	--bookmarked = plugin:GetSetting("bookmarked") or {game:GetService("StudioService"):GetUserId()};
	--recent = plugin:GetSetting("recent") or {game:GetService("StudioService"):GetUserId(),game:GetService("StudioService"):GetUserId(),game:GetService("StudioService"):GetUserId()};
	--last_loaded_db = plugin:GetSetting("last_loaded_db");-- or {[655331725] = 1720244444};

	--prioritise_display_names = plugin:GetSetting("prioritise_display_names") or false;
	compact_title = plugin:GetSetting("compact_title") or false;
	--show_actions = plugin:GetSetting("show_actions") or false;
	--include_metadata = plugin:GetSetting("include_metadata") or false;
	--insert_at_camera = plugin:GetSetting("insert_at_camera") or true;
	--dont_show_again = plugin:GetSetting("dont_show_again") or {};
}

if data.studio_theme == "light" then
	lrc.Icon = "http://www.roblox.com/asset/?id=76657074697645"
end

--print(data)

local r = script.Parent.r
local ext = r.ext:Clone(); ext:SetAttribute('path', script.Parent:GetFullName()); ext.Parent = lrc;

local s, err = pcall(function()
	--[[ GET VERSION [V3] ]]
	local i = game:GetService("MarketplaceService"):GetProductInfo(8867876284, Enum.InfoType.Asset)
	local desc = i.Description
	local ve = desc:gmatch('Version: %d+%.%d+%.%d+')() and desc:gmatch('Version: %d+%.%d+%.%d+')():split('Version: ')[2]
	if not ve then ve = desc:gmatch('v%d+%.%d+%.%d+')() and desc:gmatch('v%d+%.%d+%.%d+')():split('v')[2] end
	
	ii.cv = ve

	local lvstring = ii.lv:gmatch('%d+%.%d+%.%d+')()
	local cvstring = ii.cv:gmatch('%d+%.%d+%.%d+')()

	if lvstring and cvstring then
		local lvp = string.split(lvstring, '.')
		local cvp = string.split(cvstring, '.')


		local should_update = false
		if #lvp == 3 and #cvp == 3 then
			for i = 1, 3 do
				local lvi = tonumber(lvp[i])
				local cvi = tonumber(cvp[i])

				if lvi < cvi then
					should_update = true
					break
				elseif lvi > cvi then
					break
				end
			end
		end
		
		
		if should_update then warn("Load Roblox Characters is currently running an outdated version. Please update.") end
	end
end)

if not s then
	ii.cv = ii.lv
	warn('(lrc4 error trace: ', debug.traceback(), ' : ', err, ')')
	warn('Load Roblox Characters failed to search for an update. Your installation may require an update.')
end

local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 600, 300, 300, 250 --[[1:1]])  -- standard position, enabled when Studio opens, if the widget goes back to the last position when opened again, standard horizontal size, standard vertical size, minimum horizontal size, minimum vertical size.
local widget = plugin:CreateDockWidgetPluginGui("LRC4", widget_info)
widget.Name = "LRC4" if data.compact_title then widget.Title = "LRC4" else widget.Title = "Load Roblox Characters" end widget.Enabled = false
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local app = script.Parent.r.ui.app:Clone()
app.Size = UDim2.new(1,0,1,0)
app.Position = UDim2.new(0,0,0,0)
if app and app.home and app.home.content then app.home.content.CanvasSize = UDim2.new(0,0,0,0) end
app.Parent = widget
widget.AutoLocalize = false
widget.ResetOnSpawn = false
if data.studio_theme == "light" then require(r.modules.themes):apply_light(widget) end

--print(require(r.modules.deserializer).utils.atob('{"msg":"hi"}'))

--plugin:SetSetting("boomarked", nil)
--plugin:SetSetting("bookmarked", {game:GetService("StudioService"):GetUserId()})
--plugin:SetSetting("bookmarked", {670607756}) -- terminated user test
--plugin:SetSetting("recent", {game:GetService("StudioService"):GetUserId(),game:GetService("StudioService"):GetUserId(),game:GetService("StudioService"):GetUserId()})
--plugin:SetSetting("last_loaded_db", nil)

local prompt_widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 600, 300, 250, 250 --[[1:1]])
local cclick_widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 600, 300, 250, 250 --[[1:1]])
local prompt_widget-- : DockWidgetPluginGui?
local cclick_widget
local prompt_app
local cclick_app
local pm = plugin:GetMouse()

local bdcm
local bdcm_a_del
local rdcm
local rdcm_a_del
local mcm
local mcm_a_oid
local mcm_m_adv
local mcm_adv_cc
local mcm_adv_cld
local ecm
local ecm_a_otf
local ecm_a_anm
local ecm_a_isp
local ecmna
local ecmna_a_otf
local ecmna_a_isp
local evucm, evucm_a_tvp, evucm_a_tvr, evucm_a_exp, evucm_a_imp, evucm_a_bkm, evucm_a_rfs

r.connect.plugin_gateway.OnInvoke = function(method, desire, desire_data:any?)
	if method == "get" then
		if desire == "mouse" then
			return plugin:GetMouse()
		elseif desire == "setting" then
			return plugin:GetSetting(desire_data.setting_name)
		elseif desire == "bookmark_delete_context_menu" then
			if not bdcm then
				bdcm = plugin:CreatePluginMenu("lrc4-bdcm")
				bdcm_a_del = bdcm:AddNewAction("lrc4-bdcm-del", "Remove Bookmark")
				bdcm:AddSeparator()
				bdcm:AddNewAction("lrc4-bdcm-oid", "Open in Outfit Loader")
				bdcm:AddSeparator()
				local bdcm_m_adv = plugin:CreatePluginMenu("lrc4-bdcm-adv", "Advanced...")
				bdcm_m_adv:AddNewAction("lrc4-bdcm-adv-cc", "Clear associated cache...")
				bdcm_m_adv:AddNewAction("lrc4-bdcm-adv-cld", "Clear associated local plugin data...")
				bdcm:AddMenu(bdcm_m_adv)
			end

			--local conn
			--local res

			--conn = bdcm_a_del.Triggered:Connect(function()
			--	res = bdcm_a_del.ActionId
			--end)

			--repeat task.wait() until res ~= nil

			--return bdcm:ShowAsync().ActionId

			local res = bdcm:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "recent_delete_context_menu" then
			if not rdcm then
				rdcm = plugin:CreatePluginMenu("lrc4-rdcm")
				rdcm_a_del = rdcm:AddNewAction("lrc4-rdcm-del", "Remove from Recent")
				rdcm:AddSeparator()
				rdcm:AddNewAction("lrc4-rdcm-oid", "Open in Outfit Loader")
				rdcm:AddSeparator()
				local rdcm_m_adv = plugin:CreatePluginMenu("lrc4-rdcm-adv", "Advanced...")
				rdcm_m_adv:AddNewAction("lrc4-rdcm-adv-cc", "Clear associated cache...")
				rdcm_m_adv:AddNewAction("lrc4-rdcm-adv-cld", "Clear associated local plugin data...")
				rdcm:AddMenu(rdcm_m_adv)
			end

			local res = rdcm:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "character_context_menu" then
			if not mcm then
				mcm = plugin:CreatePluginMenu("lrc4-mcm")
				mcm_a_oid = mcm:AddNewAction("lrc4-mcm-oid", "Open in Outfit Loader")
				mcm:AddSeparator()
				if not mcm_m_adv then
					mcm_m_adv = plugin:CreatePluginMenu("lrc4-mcm-adv", "Advanced...")
					mcm_adv_cc = mcm_m_adv:AddNewAction("lrc4-mcm-adv-cc", "Clear associated cache...")
					mcm_adv_cld = mcm_m_adv:AddNewAction("lrc4-mcm-adv-cld", "Clear associated local plugin data...")
				end
				mcm:AddMenu(mcm_m_adv)
			end

			local res = mcm:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "expand_context_menu" then
			if not ecm then
				local dark = data.studio_theme == 'dark'
				
				ecm = plugin:CreatePluginMenu("lrc4-ecm")
				ecm_a_otf = ecm:AddNewAction("lrc4-ecm-otf", "Outfits", if dark then "http://www.roblox.com/asset/?id=107645060548513" else "http://www.roblox.com/asset/?id=81070722826541")
				ecm_a_anm = ecm:AddNewAction("lrc4-ecm-anm", "Animations", if dark then "rbxasset://studio_svg_textures/Shared/InsertableObjects/Dark/Standard/Animation.png" else "rbxasset://studio_svg_textures/Shared/InsertableObjects/Light/Standard/Animation.png")
				ecm_a_isp = ecm:AddNewAction("lrc4-ecm-isp", "Inspect", if dark then "http://www.roblox.com/asset/?id=135255683290888" else "http://www.roblox.com/asset/?id=105053271007883")
				--ecm:AddSeparator()
			end

			local res = ecm:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "expand_context_menu_noanim" then
			if not ecmna then
				local dark = data.studio_theme == 'dark'
				
				ecmna = plugin:CreatePluginMenu("lrc4-ecmna")
				ecmna_a_otf = ecmna:AddNewAction("lrc4-ecmna-otf", "Outfits", if dark then "http://www.roblox.com/asset/?id=107645060548513" else "http://www.roblox.com/asset/?id=81070722826541")
				ecmna_a_isp = ecmna:AddNewAction("lrc4-ecmna-isp", "Inspect", if dark then "http://www.roblox.com/asset/?id=135255683290888" else "http://www.roblox.com/asset/?id=105053271007883")
				--ecm:AddSeparator()
			end

			local res = ecmna:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "expand_viewport_utils_context_menu" then
			if not evucm then
				local dark = data.studio_theme == 'dark'
				
				evucm = plugin:CreatePluginMenu("lrc4-evucm")
				evucm_a_tvp = evucm:AddNewAction("lrc4-evucm-tvp", "Toggle 3D View", if dark then "http://www.roblox.com/asset/?id=122051953862388" else "http://www.roblox.com/asset/?id=105427975205736")
				evucm_a_tvr = evucm:AddNewAction("lrc4-evucm-tvr", "Toggle Viewport Model Rotation", if dark then "http://www.roblox.com/asset/?id=99480869968894" else "http://www.roblox.com/asset/?id=140179814468599")
				evucm:AddSeparator()
				evucm_a_exp = evucm:AddNewAction("lrc4-evucm-exp", "Export Character", if dark then "http://www.roblox.com/asset/?id=124325384911523" else "http://www.roblox.com/asset/?id=86024535908507")
				evucm_a_imp = evucm:AddNewAction("lrc4-evucm-imp", "Import Character", if dark then "http://www.roblox.com/asset/?id=78629390016501" else "http://www.roblox.com/asset/?id=78839259331231")
				evucm_a_bkm = evucm:AddNewAction("lrc4-evucm-bkm", "Bookmark/Unbookmark", if dark then "http://www.roblox.com/asset/?id=93349801132802" else "http://www.roblox.com/asset/?id=81096445852597")
				evucm:AddSeparator()
				evucm_a_rfs = evucm:AddNewAction("lrc4-evucm-rfs", "Refresh Loader", if dark then "http://www.roblox.com/asset/?id=98821238887998" else "http://www.roblox.com/asset/?id=120301121960308")
			end
			
			local res = evucm:ShowAsync()

			return res and res.ActionId or "null"
		elseif desire == "is_outdated" then
			if ii.lc+3000 < os.time() then
				-- TODO unnecessarily reused code, fix later
				
				local s, err = pcall(function()
					--[[ GET VERSION [V3] ]]
					local i = game:GetService("MarketplaceService"):GetProductInfo(8867876284, Enum.InfoType.Asset)
					local desc = i.Description
					local ve = desc:gmatch('Version: %d+%.%d+%.%d+')() and desc:gmatch('Version: %d+%.%d+%.%d+')():split('Version: ')[2]
					if not ve then ve = desc:gmatch('v%d+%.%d+%.%d+')() and desc:gmatch('v%d+%.%d+%.%d+')():split('v')[2] end

					ii.cv = ve

					local lvstring = ii.lv:gmatch('%d+%.%d+%.%d+')()
					local cvstring = ii.cv:gmatch('%d+%.%d+%.%d+')()

					if lvstring and cvstring then
						local lvp = string.split(lvstring, '.')
						local cvp = string.split(cvstring, '.')


						local should_update = false
						if #lvp == 3 and #cvp == 3 then
							for i = 1, 3 do
								local lvi = tonumber(lvp[i])
								local cvi = tonumber(cvp[i])

								if lvi < cvi then
									should_update = true
									break
								elseif lvi > cvi then
									break
								end
							end
						end


						if should_update then warn("Load Roblox Characters is currently running an outdated version. Please update.") end
					end
				end)

				if not s then
					ii.cv = ii.lv
					warn('(lrc4 error trace: ', debug.traceback(), ' : ', err, ')')
					warn('Load Roblox Characters failed to search for an update. Your installation may require an update.')
				end
			end
			
			return ii.lv ~= ii.cv
		elseif desire == "plugin_name" then
			return plugin.Name
		elseif desire == "live_version" then
			return ii.lv
		elseif desire == "current_version" then
			return ii.cv
		end
	elseif method == "post" then
		if desire == "setting" then
			--print(desire_data.setting_name, desire_data.target)
			return plugin:SetSetting(desire_data.setting_name, desire_data.target)
		elseif desire == "prompt" then
			local res
			
			-- i dont trust this anymore
			local ps, perr = pcall(function()
				if not desire_data.force_show then
					if (plugin:GetSetting("dont_show_again") or {})[desire_data.prompt_id] == true then
						return true
					end
				end

				r.modules.adaptivity.__toggle_freeze_input:Fire(true)

				if not prompt_widget then
					prompt_widget = plugin:CreateDockWidgetPluginGui(`LRC4-prompt-{http:GenerateGUID(false)}` --[[generate a guid because roblox]], widget_info)
					prompt_widget.Name = "LRC4PROMPT"
					prompt_widget.Title = "LRC4 - Confirm Action"
					prompt_app = r.ui.dialog_app:Clone()
					prompt_widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					prompt_app.Name = "app"
					prompt_app.Size = UDim2.new(1,0,1,0)
					prompt_app.Position = UDim2.new(0,0,0,0)
					prompt_app.Parent = prompt_widget
					prompt_widget.AutoLocalize = false
					prompt_widget.ResetOnSpawn = false
					require(r.modules.cursors)(prompt_app) -- i only need this once but i also made a variable for this for some reason and forgot that this module requires this script to work first a!!
				end

				local dont_show_again_toggled = false

				prompt_app.m.content.header.Text = desire_data.prompt_header or "Error displaying header"
				prompt_app.m.content.desc.Text = desire_data.prompt_desc or "Error displaying description"
				prompt_widget.Enabled = true

				if desire_data.force_show then
					prompt_app.m.content.deactivate.Visible = false
				else
					prompt_app.m.content.deactivate.Visible = true
					dont_show_again_toggled = false
					prompt_app.m.content.deactivate.icon.img.Image = "rbxassetid://8445519745"
					prompt_app.m.content.deactivate.icon.img.ImageRectOffset = Vector2.new(940,784)
					prompt_app.m.content.deactivate.icon.img.ImageRectSize = Vector2.new(48,48)

					prompt_app.m.content.deactivate.c.hitbox.MouseButton1Click:Connect(function()
						if not dont_show_again_toggled then
							dont_show_again_toggled = true
							prompt_app.m.content.deactivate.icon.img.Image = "rbxassetid://8445519745"
							prompt_app.m.content.deactivate.icon.img.ImageRectOffset = Vector2.new(4,836)
							prompt_app.m.content.deactivate.icon.img.ImageRectSize = Vector2.new(48,48)
						else
							dont_show_again_toggled = false
							prompt_app.m.content.deactivate.icon.img.Image = "rbxassetid://8445519745"
							prompt_app.m.content.deactivate.icon.img.ImageRectOffset = Vector2.new(940,784)
							prompt_app.m.content.deactivate.icon.img.ImageRectSize = Vector2.new(48,48)
						end
					end)
				end

				if desire_data.disable_cancel then
					prompt_app.res.cancel.Visible = false
				else
					prompt_app.res.cancel.Visible = true
				end

				local conn
				conn = prompt_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
					r.modules.adaptivity.__toggle_freeze_input:Fire(false)
					if not prompt_widget.Enabled then
						pm.Icon = "rbxasset://SystemCursors/Wait"
						res = false
						conn:Disconnect()
					end
				end)

				prompt_app.res.cancel.c.hitbox.MouseButton1Click:Connect(function()
					pm.Icon = "rbxasset://SystemCursors/Wait"
					res = false
					conn:Disconnect()
					prompt_widget.Enabled = false
				end)

				prompt_app.res["continue"].c.hitbox.MouseButton1Click:Connect(function()
					pm.Icon = "rbxasset://SystemCursors/Wait"
					res = true
					conn:Disconnect()
					prompt_widget.Enabled = false
				end)

				repeat task.wait() until res ~= nil and type(res) == "boolean"

				pm.Icon = "rbxasset://SystemCursors/Arrow"
				if dont_show_again_toggled then
					local dsa = plugin:GetSetting("dont_show_again")
					if typeof(dsa) ~= 'table' then dsa = {} end
					
					
					dsa[desire_data.prompt_id] = true

					plugin:SetSetting("dont_show_again", dsa)
				end

				r.modules.adaptivity.__toggle_freeze_input:Fire(false)
			end)
			
			if not ps then
				warn('(lrc4 error trace: ', debug.traceback(), ' : ', err, ')')
				pcall(function() r.modules.adaptivity.__toggle_freeze_input:Fire(false) end)
			end
			
			return res
		elseif desire == "restart" then
			-- close enough, at least

			widget.Enabled = false
			task.wait() -- yes
			r.modules.nav.__swtich:Fire(app.home)
			r.modules.home.__content_sync:Fire("recent")
			r.modules.home.__content_sync:Fire("bookmarked")
			r.modules.home.__content_sync:Fire("lldbupd")
			task.wait()
			if (plugin:GetSetting("compact_title") or false) then widget.Title = "LRC4" else widget.Title = "Load Roblox Characters" end
			widget.Enabled = true
		elseif desire == "prompt_save_selection" then
			plugin:PromptSaveSelection(desire_data and desire_data.file_name or 'lrc4-export')
		elseif desire == "cclick" then
			local res

			-- i dont trust this anymore
			local ps, perr = pcall(function()
				r.modules.adaptivity.__toggle_freeze_input:Fire(true)

				if not cclick_widget then
					cclick_widget = plugin:CreateDockWidgetPluginGui(`LRC4-prompt-{http:GenerateGUID(false)}` --[[generate a guid because roblox]], widget_info)
					cclick_widget.Name = "LRC4CCLICK"
					cclick_widget.Title = "LRC4 - Info"
					cclick_app = r.ui.cclick_app:Clone()
					cclick_widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					cclick_app.Name = "app"
					cclick_app.Size = UDim2.new(1,0,1,0)
					cclick_app.Position = UDim2.new(0,0,0,0)
					cclick_app.Parent = cclick_widget
					cclick_widget.AutoLocalize = false
					cclick_widget.ResetOnSpawn = false
					require(r.modules.cursors)(cclick_app)
				end

				cclick_widget.Enabled = true
				
				cclick_app.m.CanvasPosition = Vector2.zero
				
				for _, v in pairs(cclick_app.m.content:GetChildren()) do
					if v:IsA('Frame') then
						v.Visible = false
					end
				end
				
				if cclick_app.m.content:FindFirstChild(desire_data.id) then
					cclick_app.m.content:FindFirstChild(desire_data.id).Visible = true
				end


				local conn
				conn = cclick_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
					r.modules.adaptivity.__toggle_freeze_input:Fire(false)
					if not cclick_widget.Enabled then
						pm.Icon = "rbxasset://SystemCursors/Wait"
						res = false
						conn:Disconnect()
					end
				end)

				cclick_app.res["continue"].c.hitbox.MouseButton1Click:Connect(function()
					pm.Icon = "rbxasset://SystemCursors/Wait"
					res = true
					conn:Disconnect()
					cclick_widget.Enabled = false
				end)

				repeat task.wait() until res ~= nil and type(res) == "boolean"

				pm.Icon = "rbxasset://SystemCursors/Arrow"

				r.modules.adaptivity.__toggle_freeze_input:Fire(false)
			end)

			if not ps then
				warn('(lrc4 error trace: ', debug.traceback(), ' : ', err, ')')
				pcall(function() r.modules.adaptivity.__toggle_freeze_input:Fire(false) end)
			end

			return res
		end
	end
end

plugin.Unloading:Connect(function()
	widget.Enabled = false
end)

settings().Studio.ThemeChanged:Connect(function() 
	local studio_theme = settings().Studio and settings().Studio.Theme and settings().Studio.Theme.Name and settings().Studio.Theme.Name:lower() or "dark"; -- "light"/"dark"
	
	if studio_theme == "dark" then
		lrc.Icon = "rbxassetid://13835619451"
		require(r.modules.themes):apply_dark(widget)
	elseif studio_theme == "light" then
		lrc.Icon = "http://www.roblox.com/asset/?id=76657074697645"
		require(r.modules.themes):apply_light(widget)
	end
end)

local t_init = false

lrc.Click:Connect(function()
	if not t_init then
		t_init = true
		widget.Enabled = true
		--local start = os.time()
		--repeat widget.Enabled = true task.wait(.1) until widget.Enabled == true or os.difftime(os.time(), start) >= 2
		--print('passed')
	else
		widget.Enabled = not widget.Enabled
		if widget.Enabled then lrc:SetActive(true) else lrc:SetActive(false) end
	end
	
	if ii.lc+3000 < os.time() then
		r.modules.settings.__recheck_v:Fire()
	end
end)

;(widget::DockWidgetPluginGui):GetPropertyChangedSignal('Enabled'):Connect(function() lrc:SetActive(widget.Enabled) end)

--local bs, bserr = pcall(function() require(r.modules.bridge)(widget, ext) end) if not bs then warn('LRC4 |' , bserr) end;

repeat task.wait() until t_init

require(r.modules.init):deploy(widget)