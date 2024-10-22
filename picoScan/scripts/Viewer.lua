Viewer = {}
Viewer.MinX, Viewer.MaxX = 5000, 7500
Viewer.MinY, Viewer.MaxY = -2500, 2500
Viewer.EnableBounds = true

-- Graph Decoration
Viewer.Decoration = View.GraphDecoration.create()
Viewer.Decoration:setAxisColor(0,0,0)
Viewer.Decoration:setAspectRatio('FIT')
Viewer.Decoration:setAxisVisible(true)
-- Viewer.Decoration:setAxisWidth()
Viewer.Decoration:setBackgroundColor(255,255,255)
Viewer.Decoration:setBackgroundVisible(true)
-- Viewer.Decoration:setDrawSize(20.0)
Viewer.Decoration:setDynamicSizing(false)
Viewer.Decoration:setGraphColor(0,255,0)
-- Viewer.Decoration:setGridColor()
Viewer.Decoration:setGridVisible(true)
-- Viewer.Decoration:setIndexCoordinates()
Viewer.Decoration:setLabelColor(0,0,0)
-- Viewer.Decoration:setLabelSize()
Viewer.Decoration:setLabels("X", "Y")
Viewer.Decoration:setLabelsVisible(true)
-- Viewer.Decoration:setPolarPlot()
Viewer.Decoration:setTitle("Title")
if Viewer.EnableBounds then 
  Viewer.Decoration:setXBounds(Viewer.MinX, Viewer.MaxX)
  Viewer.Decoration:setYBounds(Viewer.MinY, Viewer.MaxY)
end

-- UI Viewers
Viewer.ViewerProfiles = View.create('ViewerProfiles')
Viewer.ViewerPointClouds = View.create('ViewerPointClouds')
Viewer.ViewerPoints = View.create('ViewerPoints')
