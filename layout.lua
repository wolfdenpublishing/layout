-- ============================================================================================== --

--- ## layout.lua
-- A simple but powerful device and display-size independent layout manager for the Corona SDK.

-- **OVERVIEW**

-- The layout manager makes it easy to create *regions*, rectangular areas
-- defined relative to the screen, the stage (which may or may not be the full
-- screen), and to the previously created user-defined regions. The final
-- regions are created with content coordinates. No actual display objects are
-- created, the programmer is free to utilize the defined regions in any manner.
-- There are default 'screen' and 'stage' regions, but the real power of the
-- layout manager is its ability to easily define new regions using simple but
-- powerful positioning and sizing options relative to any region that already
-- exists.

-- Each **region** is stored as a table within the layout manager object. Each region contains the
-- following fields that define the region:

-- - `width`: (**_number_**) region width in content units
-- - `height`: (**_number_**) region height in content units
-- - `top`: (**_number_**) content coordinate for top region edge
-- - `right`: (**_number_**) content coordinte for right region edge
-- - `bottom`: (**_number_**) content coordinate for bottom region edge
-- - `left`: (**_number_**) content coordinate for left region edge
-- - `xCenter`: (**_number_**) content coordiate for horizontal center
-- - `yCenter`: (**_number_**) content coordinate for vertical center
-- - `xPct`: (**_number_**) content units for 1% of the region width
-- - `yPct`: (**_number_**) content units for 1% of the region height
-- - `aspect`: (**_number_**) ratio of region width to height (i.e. width / height)
-- - `isPortrait`: (**_bool_**) true if aspect <= 1

-- **EXAMPLES**

-- To quickly observe and understand the power and flexibility of the Layout manager, run the
-- examples in the Corona simulator and switch around to different devices and orientations.

-- The "examples" subfolder contains several examples of how to use the Layout manager. To run
-- an example, copy the "example-##.lua" (where ## is a two digit number) file to main.lua, and
-- then run the main.lua with the Corona simulator. The build.settings and config.lua files do
-- not need to be changed (unless you want to experiment with different settings), these two
-- files work with all the examples. Simply copy the example you want to try to main.lua and run.
--
-- @classmod Layout
-- @release 1.0.0-2016.06.22
-- @author [Ron Pacheco](mailto:ron@wolfden.pub)
-- @license [MIT](https://opensource.org/licenses/MIT)
-- @copyright 2016 [Wolfden Publishing](http://www.wolfden.pub/), [Ron Pacheco](mailto:ron@wolfden.pub)
-- @usage local LayoutManager = require( "layout" )

local Layout = {}

-- ============================================================================================== --

--- Constructor - build and return a new Layout object.
--
-- The new Layout object will contain the following entries:
--
-- - `pixel`: (**number**) content units for one screen pixel (assumes device to have square pixels;
-- if not, this value will represent the content units for one pixel in the largest screen dimension)
-- - `screen`: (**region**) content region for the full screen
-- - `stage`: (**region**) content region for the stage (generally the same as the screen minus the status bar)
-- - `pixels`: (**region**) special region for positioning and sizing by pixels
--
-- @return new Layout object
-- @usage local Layout = LayoutManager:new()

function Layout:new()
	local layout = {}
	-- screen --
	layout.screen = {}
	local screen = layout.screen
	screen.user = false
	screen.width = display.currentStage.width
	screen.height = display.currentStage.height
	screen.top = 0
	screen.right = screen.width
	screen.bottom = screen.height
	screen.left = 0
	screen.xCenter = 0.5 * screen.width
	screen.yCenter = 0.5 * screen.height
	screen.xPct = 0.01 * screen.width
	screen.yPct = 0.01 * screen.height
	screen.aspect = screen.width / screen.height
	screen.isPortrait = screen.aspect <= 1
	local statusBarHeight = display.topStatusBarContentHeight or 0
	-- stage (screen minus status bar if present ) --
	layout.stage = {}
	local stage = layout.stage
	stage.user = false
	stage.width = display.currentStage.width
	stage.height = display.currentStage.height - statusBarHeight
	stage.top = statusBarHeight
	stage.right = stage.width
	stage.bottom = stage.height + statusBarHeight
	stage.left = 0
	stage.xCenter = 0.5 * stage.width
	stage.yCenter = 0.5 * stage.height + statusBarHeight
	stage.xPct = 0.01 * stage.width
	stage.yPct = 0.01 * stage.height
	stage.aspect = stage.width / stage.height
	stage.isPortrait = stage.aspect <= 1
	-- pixel size --
	layout.pixel = math.max( screen.width, screen.height ) / math.max( display.pixelHeight, display.pixelWidth )
	layout.pixels = {}
	local pixels = layout.pixels
	pixels.user = false
	if ( screen.isPortrait ) then
		pixels.width = math.min( display.pixelWidth, display.pixelHeight )
		pixels.height = math.max( display.pixelWidth, display.pixelHeight )
	else
		pixels.width = math.max( display.pixelWidth, display.pixelHeight )
		pixels.height = math.min( display.pixelWidth, display.pixelHeight )
	end
	pixels.top = 0
	pixels.right = pixels.width
	pixels.bottom = pixels.height
	pixels.left = 0
	pixels.xCenter = 0.5 * pixels.width
	pixels.yCenter = 0.5 * pixels.height
	pixels.xPct = layout.pixel
	pixels.yPct = layout.pixel
	pixels.aspect = pixels.width / pixels.height
	pixels.isPortrait = pixels.aspect <= 1
	setmetatable( layout, self )
	self.__index = self
	return layout
end

-- ============================================================================================== --

--- addRegion - add a new region to the layout manager.
--
-- @param dimens a table specifying the options for the new region:
--
-- - `id`: (**_string_**) **required** unique identifier for the new region
-- - `sizeTo`: (**_string_**) id of region to size against (default: "stage")
-- - `width`: (**_number_**) new region width as a percentage of the `sizeTo` region (default: 100)
-- - `height`: (**_number_**) new region height as a percentage of the 'sizeTo' region (default: 100)
-- - `positionTo`: (**_string_**) id of region to position relative to (defaults to `sizeTo` region)
-- - `horizontal`: (**_string_**) one of: "before", "left", "center", "right", "after" (default: "center")
-- - `vertical`: (**_string_**) one of: "above", "top", "center", "bottom", "below" (default: "center")
-- - `padTo`: (**_string_**) id of region to pad relative to (defaults to `sizeTo` region)
-- - `padding`: (**_table_**) array of: `{top=#, right=#, bottom=#, left=#}` (all #'s default to 0)

function Layout:addRegion( dimens )
	assert( dimens.id, "Region id not defined" )
	assert( not self[dimens.id], "Region already exists" )
	self[ dimens.id ] = {}
	local region = self[ dimens.id ]
	region.user = true
	dimens.sizeTo = dimens.sizeTo or "stage"
	dimens.width = dimens.width or 100
	dimens.height = dimens.height or 100
	local sizTo = self[ dimens.sizeTo ]
	region.width = dimens.width * sizTo.xPct
	region.height = dimens.height * sizTo.yPct
	region.aspect = region.width / region.height
	region.isPortrait = region.aspect <= 1
	region.xPct = 0.01 * region.width
	region.yPct = 0.01 * region.height
	dimens.positionTo = dimens.positionTo or dimens.sizeTo
	dimens.padTo = dimens.padTo or dimens.sizeTo
	dimens.padding = dimens.padding or { top = 0, right = 0, bottom = 0, left = 0 }
	dimens.horizontal = dimens.horizontal or "center"
	dimens.vertical = dimens.vertical or "center"
	local posTo = self[ dimens.positionTo ]
	local padTo = self[ dimens.padTo ]
	if ( dimens.horizontal == "before" ) then
		local padding = dimens.padding.right or 0
		region.xCenter = posTo.left - padding * padTo.xPct - 0.5 * region.width
	elseif ( dimens.horizontal == "left" ) then
		local padding = dimens.padding.left or 0
		region.xCenter = posTo.left + padding * padTo.xPct + 0.5 * region.width
	elseif ( dimens.horizontal == "center" ) then
		region.xCenter = posTo.xCenter
	elseif ( dimens.horizontal == "right" ) then
		local padding = dimens.padding.right or 0
		region.xCenter = posTo.right - padding * padTo.xPct - 0.5 * region.width
	elseif ( dimens.horizontal == "after" ) then
		local padding = dimens.padding.left or 0
		region.xCenter = posTo.right + padding * padTo.xPct + 0.5 * region.width
	end
	if ( dimens.vertical == "above" ) then
		local padding = dimens.padding.bottom or 0
		region.yCenter = posTo.top - padding * padTo.yPct - 0.5 * region.height
	elseif ( dimens.vertical == "top" ) then
		local padding = dimens.padding.top or 0
		region.yCenter = posTo.top + padding * padTo.yPct + 0.5 * region.height
	elseif ( dimens.vertical == "center" ) then
		region.yCenter = posTo.yCenter
	elseif ( dimens.vertical == "bottom" ) then
		local padding = dimens.padding.bottom or 0
		region.yCenter = posTo.bottom - padding * padTo.yPct - 0.5 * region.height
	elseif ( dimens.vertical == "below" ) then
		local padding = dimens.padding.top or 0
		region.yCenter = posTo.bottom + padding * padTo.yPct + 0.5 * region.height
	end
	region.top = region.yCenter - 0.5 * region.height
	region.right = region.xCenter + 0.5 * region.width
	region.bottom = region.yCenter + 0.5 * region.height
	region.left = region.xCenter - 0.5 * region.width
end

-- ============================================================================================== --

--- removeRegion - remove a region from the layout.
--
-- @string id id of the region to be removed
-- @usage Layout:removeRegion( "toolbar" )

function Layout:removeRegion( id )
	assert( self[id], "Specified region does not exist" )
	self[id] = nil
end

-- ============================================================================================== --

--- adjustRegion - change a region's size and/or position.
--
-- @param dimens a table specifying the adjustments for the region:
--
-- - `id`: (**_string_**) **required** unique identifier for the new region
-- - `width`: (**_number_**) new region width in *content* units (default: no change)
-- - `height`: (**_number_**) new region height in *content* units (default: no change)
-- - `xCenter`: (**_number_**) new region horizontal center in *content* coordinates (default: no change)
-- - `yCenter`: (**_number_**) new region vertical center in *content* coordinates (default: no change)

function Layout:adjustRegion( dimens )
	assert( dimens.id, "Region id not defined" )
	assert( self[dimens.id], "Region does not exist" )
	assert( self[dimens.id].user, "Can't adjust non-user region" )
	local region = self[ dimens.id ]
	region.width = dimens.width or region.width
	region.height = dimens.height or region.height
	region.xCenter = dimens.xCenter or region.xCenter
	region.yCenter = dimens.yCenter or region.yCenter
	region.aspect = region.width / region.height
	region.isPortrait = region.aspect <= 1
	region.xPct = 0.01 * region.width
	region.yPct = 0.01 * region.height
	region.top = region.yCenter - 0.5 * region.height
	region.right = region.xCenter + 0.5 * region.width
	region.bottom = region.yCenter + 0.5 * region.height
	region.left = region.xCenter - 0.5 * region.width
end

-- ============================================================================================== --

--- regionRect - return a display rect matching a specified region.
--
-- @string id id of the region for which to return a display rect
-- @return ShapeObject (as returned by [display.newRect()](https://docs.coronalabs.com/api/library/display/newRect.html))
-- @usage local toolbarRect = Layout:regionRect( "toolbar" )

function Layout:regionRect( id )
	assert( self[id], "Specified region does not exist" )
	return display.newRect( self[id].xCenter, self[id].yCenter, self[id].width, self[id].height )
end

return Layout