-- Based on "Ultimate config.lua"
-- https://coronalabs.com/blog/2013/09/10/modernizing-the-config-lua/

local aspectRatio = display.pixelHeight / display.pixelWidth
application = {
   content = {
      width = aspectRatio > 1.5 and 1080 or math.floor( 1620 / aspectRatio ),
      height = aspectRatio < 1.5 and 1620 or math.floor( 1080 * aspectRatio ),
      scale = "letterBox",
      fps = 30,
      imageSuffix = { ["@2x"] = 1.3 },
   },
}
