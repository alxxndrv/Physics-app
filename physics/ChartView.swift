//
//  ChartView.swift
//  physics
//
//  Created by Георгий Александров on 31.01.2021.
//

import SwiftUI
import SwiftUICharts
struct ChartView: View {
    var angle: Int
    var velocity: Double
    var m: Double = 0
    var k: Double = 0
    var air_resist: Bool
    @State var data: [Double] = [Double]()
    var body: some View {
        VStack {
        LineView(data: data, title: "Высота полета", legend: "измерения в метрах и секундах").onAppear {
            if air_resist {
            data = get_time_with_air_resistance(angle: angle, velocity: velocity, m: m, k: k).y_list
            } else {
                data = get_time(angle: angle, velocity: velocity).y_list
            }
        }.padding()
        }
    }
}

//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView()
//    }
//}
