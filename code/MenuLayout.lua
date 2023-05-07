--[[

	MenuLayout.lua

	Class for constructing menu layouts

	- Overall layout
		- automatically split into panels
		- panels based on percentages


	Dustin Heyden

	06 May, 2023

]]

MenuLayout = {}
MenuLayout.__index = MenuLayout

function MenuLayout:Create()

	local this =
	{
		Panels = {},
		PanelDef =
		{
			texture = Texture.Find("gradient_panel.png"),
			size = 3,
		},
	} 

	-- first panel is the full screen
	this.Panels['screen'] =
	{
		x = 0,
		y = 0,
		width = System.ScreenWidth(),
		height = System.ScreenHeight(),
	}

	setmetatable(this, self)

	return this
end


-- create a panel
function MenuLayout:CreatePanel(name)
	local layout = self.Panels[name]
	local panel = Panel:Create(self.PanelDef)
	panel:CenterPosition(layout.x, 
						layout.y,
						layout.width, 
						layout.height)
	return panel
end


-- debug function used when constructing a layout
-- iterates through layouts, creates a panel for each, renders
function MenuLayout:DebugRender(renderer)

	for k, v in pairs(self.Panels) do
		local panel = self:CreatePanel(k)
		panel:Render(renderer)
	end
end


-- contract panels
function MenuLayout:Contract(name, horiz, vert)
	horiz = horiz or 0
	vert = vert or 0
	
	local panel = self.Panels[name]
	assert(panel)

	panel.width = panel.width - horiz
	panel.height = panel.height - vert
end


-- split a panel horizontally
-- x = size to split as percentage
-- splitSize = how much space separates the new panels
function MenuLayout:SplitHorizontal(name, tname, bname, x, splitSize)

	-- get the panel to split, and erase from list
	local parent = self.Panels[name]
	self.Panels[name] = nil

	-- split the panel and get the heights for the new panels
	local p1Height = parent.height * x
	local p2Height = parent.height * (1 - x)

	-- child panel 1
	self.Panels[tname] =
	{
		x = parent.x,
		y = parent.y + parent.height/2 - p1Height/2 + splitSize/2,
		width = parent.width,
		height = p1Height - splitSize,
	}

	-- child panel 2
	self.Panels[bname] =
	{
		x = parent.x,
		y = parent.y - parent.height/2 + p2Height/2 - splitSize/2,
		width = parent.width,
		height = p2Height - splitSize,
	}
end


-- split panel vertically
-- y = size to split as percentage
-- splitSize = how much space betwen new panels
function MenuLayout:SplitVertical(name, lname, rname, y, splitSize)
	
	-- get the panel to split, and erase from list
	local parent = self.Panels[name]
	self.Panels[name] = nil

	-- split the panel and get the widths for the new panels
	local p1Width = parent.width * y
	local p2Width = parent.width * (1 - y)

	-- child panel 1
	self.Panels[rname] =
	{
		x = parent.x + parent.width/2 - p1Width/2 + splitSize/2,
		y = parent.y,
		width = p1Width - splitSize,
		height = parent.height,
	}

	-- child panel 2
	self.Panels[lname] =
	{
		x = parent.x - parent.width/2 + p2Width/2 - splitSize/2,
		y = parent.y,
		width = p2Width - splitSize,
		height = parent.height,
	}
end


-- helper functions for text/image layout

-- top frame
function MenuLayout:Top(name)
	local panel = self.Panels[name]
	return panel.y + panel.height/2
end


-- bottom frame
function MenuLayout:Bottom(name)
	local panel = self.Panels[name]
	return panel.y - panel.height/2
end


-- left frame
function MenuLayout:Left(name)
	local panel = self.Panels[name]
	return panel.x - panel.width/2
end


-- right frame
function MenuLayout:Right(name)
	local panel = self.Panels[name]
	return panel.x + panel.width/2
end


-- middle of the frame along x axis
function MenuLayout:MidX(name)
	local panel = self.Panels[name]
	return panel.x
end


-- middle of the frame along y axis
function MenuLayout:MidY(name)
	local panel = self.Panels[name]
	return panel.y
end