//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct FocusedLineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [Double],
                title: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f",
                legendSpecifier: String? = "%.2f") {
        
        self.data = ChartData(points: data)
        self.title = title
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            ZStack{
                GeometryReader{ reader in
                    Line(data: self.data,
                         frame: .constant(CGRect(x: 0, y: 0, width: reader.size.width, height: reader.size.height)),
                         touchLocation: self.$indicatorLocation,
                         showIndicator: self.$hideHorizontalLines,
                         minDataValue: .constant(nil),
                         maxDataValue: .constant(nil),
                         showBackground: true,
                         gradient: self.style.gradientColor
                    )
                    .onAppear(){
                        
                    }
                    .onDisappear(){
                        
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height )
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("btc")
                                .font(.largeTitle.bold())
                                .padding(.horizontal)
                            if currentDataNumber != 0 {
                                Text("\(self.currentDataNumber, specifier: valueSpecifier)")
                                                                .font(.title)
                                                                .padding(.horizontal)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(DragGesture()
                        .onChanged({ value in
                            self.dragLocation = value.location
                            self.indicatorLocation = CGPoint(x: max(value.location.x,0), y: 32)
                            self.opacity = 1
                            self.closestPoint = self.getClosestDataPoint(toPoint: value.location, width: geometry.size.width, height: geometry.size.height)
                            self.hideHorizontalLines = true
                        })
                        .onEnded({ value in
                            self.opacity = 0
                            self.hideHorizontalLines = false
                        })
            )
            
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct FocusedLineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FocusedLineView(data: [1,2,3,4,5,6,7,8,9,10], title: "Full chart", style: Styles.lineChartStyleOne)
            
//            FocusedLineView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], title: "Full chart", style: Styles.lineChartStyleOne)
            
        }
    }
}

