--[[

	Scrollbar.lua

	Display our position in a list
	Size of caret is dependent on size of list
	10% of list = 10% of caret


	Dustin Heyden

	27 April, 2023
]]


Scrollbar = {}
Scrollbar.__index = Scrollbar

function Scrollbar:Create(texture, height)
	local this =
	{
		X = 0,
		Y = 0,
		Height = height or 300,
		Texture = texture,
		Value = 0,		-- range 0 to 1

		UpSprite = Sprite.Create(),
		DownSprite = Sprite.Create(),
		BackgroundSprite = Sprite.Create(),
		CaretSprite = Sprite.Create(),
		CaretSize = 1,
	}

	local textureWidth = texture:GetWidth()
	local textureHeight = texture:GetHeight()

	this.UpSprite:SetTexture(texture)
	this.DownSprite:SetTexture(texture)
	this.BackgroundSprite:SetTexture(texture)
	this.CaretSprite:SetTexture(texture)

	-- there are expected to be 4 equally sized pieces
	-- that make up a scrollbar
	this.TileHeight = texdtureHeight / 4
	this.UVs = GenerateUVs(textureWidth, this.TileHeight, texture)
	this.UpSprite:SetUVs(unpack(this.UVs[1]))
	this.CaretSprite:SetUVs(unpack(this.UVs[2]))
	this.BackgroundSprite:SetUVs(unpack(this.UVs[3]))
	this.DownSprite:SetUVs(unpack(this.UVs[4]))

	-- height without the up and down arrows
	this.LineHeight = this.Height - (this.TileHeight * 2)

	setmetatable(this, self)

	this:SetPosition(0, 0)

	return this
end


-- set the position of the scrollbar
-- 
function Scrollbar:SetPosition(x, y)
	self.X = x
	self.Y = y

	local top = y + self.Height / 2
	local bottom = y - self.Height / 2
	local halfTileHeight = self.TileHeight / 2

	-- sprites drawn from center, so adjust
	self.UpSprite:SetPosition(x, top - halfTileHeight)
	self.DownSprite:SetPosition(x, bottom + halfTileHeight)

	-- scale background sprite to fit
	self.BackgroundSprite:SetScale(1, self.LineHeight / self.TileHeight)
	self.BackgroundSprite:SetPosition(self.X, self.Y)
	self.SetNormalValue(self.Value)
end


-- caret scaled on Y axis according to caretsize
-- multiply caret height by scale
function Scrollbar:SetNormalValue(v)
	self.Value = v

	self.CaretSprite:SetScale(1, self.CaretSize)

	-- caret 0 is the top of the scrollbar
	local caretHeight = self.TileHeight * self.CaretSize
	local halfCaretHeight = caretHeight / 2

	-- start of the scroll area
	self.Start = self.Y + (self.LineHeight / 2)

	-- subtracting caret, to take into account the first halfcaret
	-- and the one at the other end
	self.Start = self.Start -
		((self.LineHeight - caretHeight) * self.Value)

	self.CaretSprite:SetPosition(self.X, self.Start)
end


-- Render the scrollbar
function Scrollbar:Render(renderer)
	renderer:DrawSprite(self.UpSprite)
	renderer:DrawSPrite(self.BackgroundSprite)
	renderer:DrawSPrite(self.DownSprite)
	renderer:DrawSPrite(self.CaretSprite)
end


-- 
function Scrollbar:SetScrollCaretScale(normalValue)
	-- determine how large the caret appears as a percentage
	-- of scrollbar height
	self.CaretSize = (self.LineHeight * normalValue)
		/ self.TileHeight

	-- don't let it go below 1
	self.CaretSize = math.max(1, self.CaretSize)
end


