//
//  ContentView.swift
//  BetterRest
//
//  Created by Alexander Katzfey on 2/25/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) { value in
                            print("Wake up time changed! \(wakeUp)")
                            calculateBedtime()
                        }
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { value in
                            print("sleep amount changed! \(sleepAmount)")
                            calculateBedtime()
                        }
                }
                
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    //                    Picker("Coffee cups", selection: $coffeeAmount) {
                    //                        ForEach(1..<21) {
                    //                            Text($0, format: .number)
                    //                        }
                    //                    }
                        .onChange(of: coffeeAmount) { value in
                            print("Coffee amount changed! \(coffeeAmount)")
                            calculateBedtime()
                        }
                }
                
                Section {
                    HStack {
                        Text("Your ideal bedtime is:")
                        Text("\(alertMessage == "" ? "11:00 PM" : alertMessage)")
                            .font(.title3)
                    }
                }
                
            }
            .navigationTitle("BetterRest")
            //            .toolbar {
            //                Button("Calculate", action: calculateBedtime)
            //            }
            //            .alert(alertTitle, isPresented: $showingAlert) {
            //                Button("OK") {}
            //            } message: {
            //                Text(alertMessage)
            //            }
        }
        .onAppear() {
            calculateBedtime()
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSec = (components.hour ?? 0) * 60 * 60
            let minuteInSec = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourInSec + minuteInSec),
                                                  estimatedSleep: sleepAmount,
                                                  coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
