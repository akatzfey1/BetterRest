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
    @State private var predictedBedtime = ""
    
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
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) { value in
                            calculateBedtime()
                        }
                } header: {
                    Text("When do you want to wake up?")
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { value in
                            calculateBedtime()
                        }
                } header: {
                    Text("Desired amount of sleep")
                }
                
                Section {
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                        .onChange(of: coffeeAmount) { value in
                            calculateBedtime()
                        }
                } header: {
                    Text("Daily coffee intake")
                }
                
                Section {
                    HStack {
                        Text("Your ideal bedtime is:")
                        Text("\(predictedBedtime == "" ? "11:00 PM" : predictedBedtime)")
                            .font(.title3)
                    }
                }
                
            }
            .navigationTitle("BetterRest")
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
            
            predictedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            predictedBedtime = "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
