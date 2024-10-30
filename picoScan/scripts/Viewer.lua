Viewer = {}
Viewer.MinX, Viewer.MaxX, Viewer.MinY, Viewer.MaxY = CAF.minX, CAF.maxX, CAF.minY, CAF.maxY

function Viewer.UpdateSidePanelDisplay()
end

-- UI Viewers
Viewer.ViewerPoints = View.create('ViewerPoints')
Viewer.ViewerPoints:register("OnConnect", Viewer.UpdateSidePanelDisplay)
Viewer.ViewerPointClouds = View.create('ViewerPointClouds')
Viewer.ViewerProfiles = View.create('ViewerProfiles')

-- Default Graph Decoration
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
Viewer.Decoration:setXBounds(Viewer.MinX, Viewer.MaxX)
Viewer.Decoration:setYBounds(Viewer.MinY, Viewer.MaxY)

-- Point decoration
Viewer.PointDecoration = Viewer.Decoration
Viewer.PointDecoration:setGraphType('DOT')
Viewer.PointDecoration:setDrawSize(30.0)
Viewer.PointDecoration:setGraphColor(20,180,100)

-- Line segment point decoration
Viewer.LineSegmentPointDecoration = View.ShapeDecoration.create()
Viewer.LineSegmentPointDecoration:setPointSize(40.0)
Viewer.LineSegmentPointDecoration:setPointType('CROSS')
Viewer.LineSegmentPointDecoration:setFillColor(0,0,255,255)

-- Line segment decoration
Viewer.LineSegmentDecoration = View.ShapeDecoration.create()
Viewer.LineSegmentDecoration:setLineColor(255,0,0,255)

-- CAF line segment decoration
Viewer.CAFLineSegmentDecoration = View.ShapeDecoration.create()
Viewer.CAFLineSegmentDecoration:setLineColor(255,0,0,255)
Viewer.CAFLineSegmentDecoration:setLineWidth(15.0)

-- CAF point decoration
Viewer.CAFDecoration = View.ShapeDecoration.create()
Viewer.CAFDecoration:setPointSize(40.0)
Viewer.CAFDecoration:setPointType('DOT')
Viewer.CAFDecoration:setFillColor(255,0,0,255)

-- Point cloud decoration
Viewer.PointCloudDecoration = View.PointCloudDecoration.create()
Viewer.PointCloudDecoration:setPointSize(3.0)

