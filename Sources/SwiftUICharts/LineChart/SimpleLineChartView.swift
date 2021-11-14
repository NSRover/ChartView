//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct SimpleLineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data:ChartData
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    
    public var valueSpecifier:String
    private let heightRatio:Double
    private let padding: Double
    private let midlineColor: Color?
    private var minDataValue: Double?
    private var maxDataValue: Double?
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot) {
                HapticFeedback.playSelection()
            }
            
        }
    }
    public init(data: [Double],
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f",
                heightRatio: Double = 1.3,
                padding: Double = 30.0,
                midlineColor: Color? = nil,
                minDataValue: Double? = nil,
                maxDataValue: Double? = nil) {
        self.heightRatio = heightRatio
        self.data = ChartData(points: data)
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.valueSpecifier = valueSpecifier!
        self.padding = padding
        self.midlineColor = midlineColor
        self.minDataValue = minDataValue
        self.maxDataValue = maxDataValue
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            Line(data: self.data,
                 frame: .constant(geometry.frame(in: .local)),
                 touchLocation: self.$touchLocation,
                 showIndicator: self.$showIndicatorDot,
                 minDataValue: .constant(minDataValue),
                 maxDataValue: .constant(maxDataValue),
                 midlineColor: midlineColor,
                 padding: padding,
                 showBackground: false,
                 gradient: self.style.gradientColor
            )
        }
    }
    
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct SimpleLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleLineChartView(data: [0.0, 0.0, 3.6, 3.0, -5.4, -2.9, 0.7, -0.7], minDataValue: -10)
                .environment(\.colorScheme, .light)
                .frame(height: 400)
                .background(Color.black)
            
            //            SimpleLineChartView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], rateValue: nil)
            //                .environment(\.colorScheme, .light)
        }
    }
}
