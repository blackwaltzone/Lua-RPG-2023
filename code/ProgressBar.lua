--[[

	ProgressBar.lua

	Works by layering two images over each other
	Draw empty bar first, full bar second
	Full bar is cut depending on "progress" from 0 to 1
	Align background and foreground sprites on left edge


	Dustin Heyden

	27 April, 2023

]]--


ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar:Create(params)
	params = params or {}

	local this =
	{
		X = params.x or 0,
		Y = params.y or 0,
		Background = Sprite.Create(),
		Foreground = Sprite.Create(),
		Value = params.value or 0,
		Maximum = params.maximum or 1,
	}

	this.Background:SetTexture(params.background)
	this.Foreground:SetTexture(params.foreground)

	-- get UV pos in texture atlas
	-- a table with name fields: left, top, right, bottom
	-- halfwidth used to center-align progress bar
	this.HalfWidth = params.foreground:GetWidth() / 2

	setmetatable(this, self)

	this:SetValue(this.Value)

	return this
end


-- set the value of the progress bar, 0 to 1
-- convert value passed in to a percent 0 to 1
function ProgressBar:SetValue(value, max)
	self.Maximum = max or self.Maximum
	self:SetNormalValue(value / self.Maximum)
end


-- normalize the value to display progress bar
-- change the UVs for the foreground sprite
function ProgressBar:SetNormalValue(value)

	self.Foreground:SetUVs(
		0,		-- left
		1,		-- top
		value,	-- right
		0)		-- bottom

	-- U coordinate = width
	-- sprites are center-aligned, so need to compensate
	-- ensure left edges of background/foreground are aligned
	local position = Vector.Create(
		self.X - (self.HalfWidth * (1 - value)),
		self.Y)

	self.Foreground:SetPosition(position)
end


function ProgressBar:SetPosition(x, y)
	self.X = x
	self.Y = y
	local position = Vector.Create(self.X, self.Y)

	self.Foreground:SetPosition(position)
	self.Background:SetPosition(position)

	-- make sure the foreground position is set correctly
	self:SetValue(self.Value)
end


function ProgressBar:GetPosition()
	return Vector.Create(self.X, self.Y)
end


function ProgressBar:Render(renderer)
	renderer:DrawSprite(self.Background)
	renderer:DrawSprite(self.Foreground)
end