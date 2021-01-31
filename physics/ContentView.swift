//
//  ContentView.swift
//  physics
//
//  Created by Георгий Александров on 15.01.2021.
//

import SwiftUI
import CoreData
import SwiftUICharts

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

func get_time_with_air_resistance(angle: Int, velocity: Double, m: Double, k: Double) -> (time: Double, height: Double, lenght: Double, y_list: [Double]) {
    
    guard m != 0 && k != 0 else {
        return (0, 0, 0, [])
    }
    
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
    
    guard (t_list.last != nil) && (x_list.last != nil) else {
        return (0, 0, 0, [])
    }
    let t_full = t_list.last ?? 0
    let height_max = y_list.max()!
    let length_max = x_list.last ?? 0
    
    return (abs(t_full), height_max, length_max, y_list)
}


func get_time(angle: Int, velocity: Double) -> (time: Double, height: Double, lenght: Double, y_list: [Double]) {
    let g = 9.8
    let angle = deg2rad(Double(angle))
    let v_0y = velocity * sin(Double(angle))
    let v_0x = velocity * cos(Double(angle))
    
    let t_up = v_0y / g
    let t_full = 2 * t_up
    
    let height_max = v_0y * t_up - g * (pow(t_up, 2)) / 2
    let length_max = v_0x * t_full
    
    
    var t: Double = 0
    var t_list = [Double]()
    while t <= t_full {
        t_list.append(t)
        t += 0.001
    }

//    var x_list = [Double]()
//    for t in t_list {
//        let x = v_0x * t
//        x_list.append(x)
//    }
    
    var y_list = [Double]()
    for t in t_list {
        let y = v_0y * t - g * (pow(t, 2)) / 2
        y_list.append(y)
    }
    
    return (abs(t_full), height_max, length_max, y_list)
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
    
    @State var k = ""
    @State var m = ""
    
    @State var flightGraphData = [Double]()
    
    @State var graphShown = false
    
    func updateData() {
        if !air_resist {
            time = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).time
            lenght = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).lenght
            height = get_time(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0).height
        } else {
            time = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: Double(m) ?? 0, k: Double(k) ?? 0).time
            lenght = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: Double(m) ?? 0, k: Double(k) ?? 0).lenght
            height = get_time_with_air_resistance(angle: Int(angle) ?? 0, velocity: Double(velocity) ?? 0, m: Double(m) ?? 0, k: Double(k) ?? 0).height
        }
    }
    var body: some View {
            VStack {
                HStack {
                    Text("Физика")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }.padding()
                Spacer()
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
                    Toggle(isOn: $air_resist.didSet { _ in
                        withAnimation {
                        updateData()
                        }
                    }, label: {Text("Учитывать сопротивление воздуха?")}).padding(.vertical, 5)
                    if air_resist {
                    Group {
                    TextField("Коэффициент k", text: $k.didSet { _ in
                        updateData()
                    })
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.08)))
                    TextField("Масса снаряда (в кг)", text: $m.didSet { _ in
                        updateData()
                    })
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.08)))
                    }.transition(.opacity)
                }
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
                    HStack{
                        Button(action: {
                            graphShown.toggle()
                        }, label: {
                            Text("График полёта")
                        })
                    }
                    
                }.padding()
                .background(Color(UIColor.systemBackground).cornerRadius(16, antialiased: true).shadow(color: Color.black.opacity(0.1), radius: 16))
                .padding()
                Spacer()
            }.navigationTitle("Physics")
            .sheet(isPresented: $graphShown, content: {
                ChartView(angle: Int(angle)!, velocity: Double(velocity)!, m: Double(m) ?? 0, k: Double(k) ?? 0, air_resist: air_resist)
            })
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
