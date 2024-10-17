Viewer = {}

-- Graph Decoration
Viewer.Decoration = View.GraphDecoration.create()
Viewer.Decoration:setAxisColor(0,0,0)
Viewer.Decoration:setAspectRatio('FIT')
Viewer.Decoration:setAxisVisible(true)
-- Viewer.Decoration:setAxisWidth()
Viewer.Decoration:setBackgroundColor(255,255,255)
Viewer.Decoration:setBackgroundVisible(true)
-- Viewer.Decoration:setDrawSize()
Viewer.Decoration:setDynamicSizing(false)
Viewer.Decoration:setGraphColor(0,0,255)
Viewer.Decoration:setGraphType('DOT')
-- Viewer.Decoration:setGridColor()
Viewer.Decoration:setGridVisible(false)
-- Viewer.Decoration:setIndexCoordinates()
Viewer.Decoration:setLabelColor(0,0,0)
-- Viewer.Decoration:setLabelSize()
Viewer.Decoration:setLabels("X", "Y")
Viewer.Decoration:setLabelsVisible(true)
-- Viewer.Decoration:setPolarPlot()
Viewer.Decoration:setTitle("Viewer.Decoration title")
Viewer.Decoration:setXBounds(0, 1200)
Viewer.Decoration:setYBounds(0, 2000)

-- UI Viewers
Viewer.ViewerProfiles = View.create('ViewerProfiles')
Viewer.ViewerPointClouds = View.create('ViewerPointClouds')
Viewer.ViewerPoints = View.create('ViewerPoints')
