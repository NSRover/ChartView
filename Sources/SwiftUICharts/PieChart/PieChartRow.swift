//
//  PieChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartRow : View {
    struct SliceData {
        let value: Double
        let coinName: String
        let color: Color
    }
    var data: [SliceData]
    var backgroundColor: Color
    var slices: [PieSlice] {
        var tempSlices:[PieSlice] = []
        var lastEndDeg:Double = 0
        let maxValue = data.map({ $0.value }).reduce(0, +)
        for slice in data.map({ $0.value }) {
            let normalized:Double = Double(slice)/Double(maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice, normalizedValue: normalized))
        }
        return tempSlices
    }
    
    var showValue: Bool = false
    var currentValue: Double = 0
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    public var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack{
                    ForEach(0..<self.slices.count){ i in
                        PieChartCell(rect: geometry.frame(in: .local), startDeg: self.slices[i].startDeg, endDeg: self.slices[i].endDeg, index: i, backgroundColor: self.backgroundColor, accentColor: self.data[i].color)
                    }
                }
            }
            .padding(.trailing)
            distributionText
                .font(Font.system(.body, design: .monospaced).monospacedDigit())
        }
    }
    
    init(globalData: Global) {
        self.data = globalData.market_cap_percentage
            .sorted(by: { $0.value > $1.value })
            .map({ key, value in
            return PieChartRow.SliceData(value: value, coinName: key, color: Color.random)
        })
        let total = self.data
            .reduce(into: 0.0) { partialResult, sliceData in
                partialResult += sliceData.value
            }
        if total > 0 {
            self.data.append(PieChartRow.SliceData(value: (100.0-total), coinName: "others", color: .white))
        }
        
        self.backgroundColor = .clear
    }
    
    var distributionText: Text {
        var output = Text("")
        for i in 0..<self.slices.count {
            let coinData = self.data[i]
            let newText =
            Text("\(coinData.coinName) ")
                .bold()
                .foregroundColor(coinData.color)
            +
            Text("\(coinData.value, specifier: "%.1f")")
                .foregroundColor(.secondary)
            +
            Text((i==self.slices.count-1) ? " " : ", ")
            output = output + newText
        }
        return output
    }
}

#if DEBUG
struct PieChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            PieChartRow(globalData: Global(market_cap_change_percentage_24h_usd: 5,
                                           market_cap_percentage: [
                                            "btc":40.0,
                                            "eth":20.0,
                                            "ada":10.0,
                                            "xxx":10.0,
                                            "xxx2":10.0,
                                            "xxx3":10.0
                                           ]))
        }
    }
}
#endif
