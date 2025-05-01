local ss = game:GetService("StudioService")

local init = {}
local cursors = require(script.Parent.cursors)
local nav = require(script.Parent.nav)
local home = require(script.Parent.home)
local loader = require(script.Parent.loader)
local components = require(script.Parent.components)
local resolver = require(script.Parent.resolver)
local settings_ = require(script.Parent.settings)

local deployed = false

function init:deploy(widget:DockWidgetPluginGui)
	if deployed then return end; deployed = true
	if not widget or not typeof(widget) == "Instance" or not widget:IsA("DockWidgetPluginGui") or not widget:FindFirstChild("app") then error("abandoned") return end
	local app = script.Parent.Parent.ui.app; if true then app = widget.app end
	
	app.loader.null_select.Visible = true
	app.loader.main.Visible = false
	app.loader.view.Visible = false
	
	resolver:init(widget)
	cursors(app)
	nav(widget)
	script.Parent.nav.__swtich:Fire(app.home)
	task.spawn(function() home:init(widget) end)
	components(widget)
	loader:init(widget)
	settings_(widget)
	task.spawn(function() loader:open(widget, ss:GetUserId(), nil, true) end)
	require(script.Parent.adaptivity):deploy(widget)
end

return init