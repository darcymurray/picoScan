Decorations = {}

Decorations.PointDecoration = Viewer.Decoration
Decorations.PointDecoration:setGraphType('DOT')
Decorations.PointDecoration:setDrawSize(30.0)
Decorations.PointDecoration:setGraphColor(20,180,100)

Decorations.LineSegmentPointDecoration = View.ShapeDecoration.create()
Decorations.LineSegmentPointDecoration:setPointSize(40.0)
Decorations.LineSegmentPointDecoration:setPointType('CROSS')
Decorations.LineSegmentPointDecoration:setFillColor(0,0,255,255)

Decorations.LineSegmentDecoration = View.ShapeDecoration.create()
Decorations.LineSegmentDecoration:setLineColor(255,0,0,255)

Decorations.CAFLineSegmentDecoration = View.ShapeDecoration.create()
Decorations.CAFLineSegmentDecoration:setLineColor(255,0,0,255)
Decorations.CAFLineSegmentDecoration:setLineWidth(15.0)

Decorations.CAFDecoration = View.ShapeDecoration.create()
Decorations.CAFDecoration:setPointSize(40.0)
Decorations.CAFDecoration:setPointType('DOT')
Decorations.CAFDecoration:setFillColor(255,0,0,255)