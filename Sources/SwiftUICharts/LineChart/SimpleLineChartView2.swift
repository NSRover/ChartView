//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct SimpleLineChartView2: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data:ChartData
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    
    public var valueSpecifier:String
    private let startTitle: String
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
                startTitle: String,
                style: ChartStyle = Styles.lineChartStyleX,
                valueSpecifier: String? = "%.1f") {
        self.startTitle = startTitle
        self.data = ChartData(points: data)
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.valueSpecifier = valueSpecifier!
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack {
                GeometryReader{ geometry in
                    LinearGradient(colors: [.green, .yellow, .red],
                                   startPoint: SwiftUI.UnitPoint(x: 0.5, y: 0),
                                   endPoint: SwiftUI.UnitPoint(x: 0.5, y: 1))
                        .mask(Line(data: self.data,
                                   frame: .constant(geometry.frame(in: .local)),
                                   touchLocation: self.$touchLocation,
                                   showIndicator: self.$showIndicatorDot,
                                   minDataValue: .constant(0),
                                   maxDataValue: .constant(100),
                                   padding: 5,
                                   showBackground: false,
                                   gradient: self.style.gradientColor)
                              
                        )
                        .shadow(radius: 5)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(uiColor: .tertiarySystemBackground)))
                HStack {
                    Text(startTitle)
                    Spacer()
                    Text("Present")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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

struct SimpleLineChartView2_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleLineChartView2(data: [70,71,72,73,74,75,76,77,78,90,100], startTitle: "Oct 2021")
                .frame(height: 80)
                .environment(\.colorScheme, .light)
        }
    }
}
