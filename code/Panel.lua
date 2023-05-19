--[[

	Panel.lua

	params =
  	{
    	texture = [texture],
    	size = [size of a single tile in pixels]
 	}

	Dustin Heyden

	06 May, 2023

]]

Panel = {}
Panel.__index = Panel

function Panel:Create(params)

	local this =
	{
		-- texture used for decoration
		Texture = params.texture,
		UVs = GenerateUVs(params.size, params.size, params.texture),
		TileSize = params.size,
		-- sprites representing the border
		Tiles = {}
	}

	-- Fix up center U,Vs by moving them 0.5 texels in.
	-- done so border isn't included in gradient interpolation
    local center = this.UVs[5]
    local pixelToTexelX = 1 / this.Texture:GetWidth()
    local pixelToTexelY = 1 / this.Texture:GetHeight()
    center[1] = center[1] + (pixelToTexelX / 2)
    center[2] = center[2] + (pixelToTexelY / 2)
    center[3] = center[3] - (pixelToTexelX / 2)
    center[4] = center[4] - (pixelToTexelY / 2)
    -- The center sprite is going to be 1 pixel smaller on the X, Y
    -- So we need a variable that will account for that when scaling.
    this.CenterScale = this.TileSize / (this.TileSize - 1)

	-- Create a sprite for each tile of the panel
	-- 1. top left 2. top 3. top right
	-- 4. left 5. middle 6. right
	-- 7. bottom left 8. bottom 9. bottom right
	for k, v in ipairs(this.UVs) do
		local sprite = Sprite:Create()
		sprite:SetTexture(this.Texture)
		sprite:SetUVs(unpack(v))
		this.Tiles[k] = sprite
	end

	setmetatable(this, self)
	
	return this
end


-- define positon and size on screen
-- forms two points: top-left, bottom-right
function Panel:Position(left, top, right, bottom)
	
	-- Reset scales
	for k, v in ipairs(self.Tiles) do
		-- reset so no scale applied
		v:SetScale(1, 1)
	end

	-- all sprites drawn from center, so adjust by half width and height
	local hSize = self.TileSize / 2

	-- Align the corner tiles
	self.Tiles[1]:SetPosition(left + hSize, top - hSize)
	self.Tiles[3]:SetPosition(right - hSize, top - hSize)
	self.Tiles[7]:SetPosition(left + hSize, bottom + hSize)
	self.Tiles[9]:SetPosition(right - hSize, bottom + hSize)

	-- Calculate how much to scale the side tiles
	local widthScale = (math.abs(right - left) - (2 * self.TileSize))
						/ self.TileSize
	local centerX = (right + left) / 2

	-- bottm middle tile
	self.Tiles[2]:SetPosition(centerX, top - hSize)
	self.Tiles[2]:SetScale(widthScale, 1)

	-- top middle tile
	self.Tiles[8]:SetPosition(centerX, bottom + hSize)
	self.Tiles[8]:SetScale(widthScale, 1)

	local heightScale = (math.abs(bottom - top) - (2 * self.TileSize))
						/ self.TileSize
	local centerY = (top + bottom) / 2

	-- right middle tile
	self.Tiles[4]:SetScale(1, heightScale)
	self.Tiles[4]:SetPosition(left + hSize, centerY)

	-- left middle tile
	self.Tiles[6]:SetScale(1, heightScale)
	self.Tiles[6]:SetPosition(right - hSize, centerY)

	-- Scale the middle backing panel/center tile
	self.Tiles[5]:SetScale(widthScale * self.CenterScale, 
							heightScale * self.CenterScale)
	self.Tiles[5]:SetPosition(centerX, centerY)

	-- Hide corner tiles when scale is equal to zero
	if left - right == 0 or top - bottom == 0 then
		for k, v in ipairs(self.Tiles) do
			v:SetScale(0, 0)
		end
	end
end


-- makes a panel centered on an (x, y) coordinate,
-- and lets us specify a height and width
function Panel:CenterPosition(x, y, width, height)
    local hWidth = width / 2
    local hHeight = height / 2
    return self:Position(x - hWidth, y + hHeight,
                         x + hWidth, y - hHeight)
end


-- render the panel
function Panel:Render(renderer)
	-- loop through the tiles
	for k, v in ipairs(self.Tiles) do
		renderer:DrawSprite(v)
	end
end