//
//  ContentView.swift
//  physics
//
//  Created by Георгий Александров on 15.01.2021.
//

import SwiftUI
import CoreData

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

extension Binding {
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                didSet(newValue)
            }
        )
    }
}

func get_time_with_air_resistance(angle: Int, velocity: Double, m: Double, k: Double) -> (time: Double, height: Double, lenght: Double) {
    let g = 9.8
    let angle = deg2rad(Double(angle))
    let v_0y = velocity * sin(Double(angle))
    let v_0x = velocity * cos(Double(angle))
    
    var t: Double = 0
    var t_list = [Double]()
    while (m/k)*((v_0y + m*g/k)*(1 - exp(-k*t/m)) - g*t) >= 0 {
        t_list.append(t)
        t += 0.001
    }
    
    var x_list = [Double]()
    for t in t_list {
        let x = (v_0x*m/k)*(1 - exp(-k*t/m))
        x_list.append(x)
    }

    var y_list = [Double]()
    for t in t_list {
        let y = (m/k)*((v_0y + m*g/k)*(1 - exp(-k*t/m)) - g*t)
        y_list.append(y)
    }
    
    let t_full = t_list[-1]
    let height_max = y_list.max()!
    let length_max = x_list[-1]
    
    return (abs(t_full), height_max, length_max)
}


func get_time(angle: Int, velocity: Double) -> (time: Double, height: Double, lenght: Double) {
    let g = 9.8
    let angle = deg2rad(Double(angle))
    let v_0y = velocity * sin(Double(angle))
    let v_0x = velocity * cos(Double(angle))
    
    let t_up = v_0y / g
    let t_full = 2 * t_up
    
    let height_max = v_0y * t_up - g * (pow(t_up, 2)) / 2
    let length_max = v_0x * t_full
    
    
    return (abs(t_full), height_max, length_max)
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var velocity = ""
    @State var angle = ""
    
    @State var time = Double.zero
    @State var lenght = Double.zero
    @State var height = Double.zero
    
    @State var air_resist = false
    
    @State var k = Double.zero
    @State var m = Double.zero
    
    func updateData() {
        if !air_resist {
            time = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).time
            lenght = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).lenght
            height = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).height
        } else {
            time = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: m, k: k).time
            lenght = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: m, k: k).lenght
            height = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: m, k: k).height
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Параметры снаряда").font(.title2).bold()
                        .padding(.bottom, 6)
                    TextField("Модуль начальной скорости заряда (в м/с)", text: $velocity.didSet { _ in
                        updateData()
                    })
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.08)))
                    TextField("Угол между вектором начальной скорости и горизонтом в градусах", text: $angle.didSet { _ in
                        updateData()
                    })
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.08)))
                }.padding()
                .background(Color(UIColor.systemBackground).cornerRadius(16, antialiased: true).shadow(color: Color.black.opacity(0.1), radius: 16))
                .padding()
                VStack(alignment: .leading, spacing: 9) {
                    Text("Результаты").font(.title2).bold()
                        .padding(.bottom, 6)
                        .onTapGesture {
                        }
                    HStack {
                        Text("Время полёта")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f с", self.time))
                    }
                    HStack {
                        Text("Макс. высота полёта")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f м", self.height))
                    }
                    HStack {
                        Text("Дальность полёта")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f м", self.lenght))
                    }
                }.padding()
                .background(Color(UIColor.systemBackground).cornerRadius(16, antialiased: true).shadow(color: Color.black.opacity(0.1), radius: 16))
                .padding()
            }.navigationTitle("Physics")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
