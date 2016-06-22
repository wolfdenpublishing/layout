-- ========================================================================== --
-- example-04.lua
--
-- Expands on example-03 by further dividing the content area into a grid of
-- additional regions. The grid size is controlled in this example code by
-- the ContentGridSize variable at line 19.

-- layout.lua is in parent folder
package.path = "../?.lua;" .. package.path
local LayoutManager = require( "layout" )

-- layout manager object
local Layout

-- Group to hold rects that display the regions
local Regions

-- Content grid size; change this to change the size of the generated grid
local ContentGridSize = 4

-- layout creation
local function createLayout()
	-- init the layout manager
	Layout = LayoutManager:new()
	-- device is in portrait orientation
	if ( Layout.stage.isPortrait ) then
		-- create a header occupying 10% of the stage
		Layout:addRegion( { id = "header", vertical = "top", height = 10 } )
		-- create a content area below the header with some small padding
		Layout:addRegion( { id = "content", positionTo = "header", vertical = "below", height = 83, padding = { top = 1 } } )
		-- create a footer area at the bottom of the stage
		Layout:addRegion( { id = "footer", vertical = "bottom", height = 5 } )
	-- device is in landscape orientation
	else
		-- create a header occupying 10% of the stage
		Layout:addRegion( { id = "header", horizontal = "left", width = 10 } )
		-- create a content area below the header with some small padding
		Layout:addRegion( { id = "content", positionTo = "header", horizontal = "after", width = 83, padding = { left = 1 } } )
		-- create a footer area at the bottom of the stage
		Layout:addRegion( { id = "footer", horizontal = "right", width = 5 } )
	end
	-- Create the content grid regions. This works independent of device
	-- orientation since we are working relative to the "content" region
	-- already created above.
	local cellWidth = 100 / ContentGridSize
	local cellHeight = 100 / ContentGridSize
	for row = 1, ContentGridSize do
		for col = 1, ContentGridSize do
			local dimens = {
				id = "("..row..","..col..")", sizeTo = "content",
				width = cellWidth, height = cellHeight,
				horizontal = "left", vertical = "top",
				padding = { left = cellWidth * ( col - 1 ), top = cellHeight * ( row - 1 ) }
			}
			Layout:addRegion( dimens )
		end
	end
end

-- ========================================================================== --

-- helper function to display a region as a rect
local function showRegion( id, fill )
	local rect = Layout:regionRect( id )
	Regions:insert( rect )
	rect.fill = fill or { 0, 0 }
	rect.stroke = { 1, 1 }
	rect.strokeWidth = Layout.pixel
	local region = Layout[id]
	local text = display.newText( id, region.xCenter, region.yCenter, native.systemFont, 20 * Layout.pixel )
	Regions:insert( text )
	text.fill = { 1, 1 }
end

-- for demo purposes just display the layout regions as rects on the screen
local function showLayout()
	Regions = display.newGroup()
	showRegion( "header", {0.5,0,0} )
	showRegion( "content", {1,0.5} )
	showRegion( "footer", {0,0,0.5} )
	for row = 1, ContentGridSize do
		for col = 1, ContentGridSize do
			showRegion( "("..row..","..col..")" )
		end
	end
end

-- ========================================================================== --

-- orientation change listener
local function onOrientationChange( event )
	Regions:removeSelf()
	Regions = nil
	createLayout()
	showLayout()
end

-- add listener for orientation change
Runtime:addEventListener( "orientation", onOrientationChange )

-- ========================================================================== --

-- initial layout and display
createLayout()
showLayout()
