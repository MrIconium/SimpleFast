//
//  ContentView.swift
//  SimpleFast
//
//  Created by Mehmet Emrah Konya on 23.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var fastingDuration: Int = 16 // Varsayılan 16 saat
    @State private var fastingEndTime: Date = Date()
    @State private var isFasting: Bool = false
    @State private var elapsedTimePercentage: Double = 0.0
    @State private var progressStartAngle: Double = 0.0 // Progress bar başlangıç açısı
    @State private var currentTime: Date = Date()
    @State private var timer: Timer? = nil
    @State private var showFastingIntervalPicker: Bool = false // Alt ekran durumu

    let fastingIntervals = [
        ("12:12", 12),
        ("16:8", 16),
        ("18:6", 18),
        ("20:4", 20)
    ]

    var body: some View {
        VStack {
            // Başlık
            Text("Simple Fasting App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding()

            Spacer()

            // Saat Görselleştirme
            ZStack {
                // Saat Bileşenleri Ölçümleri
                let handWidth: CGFloat = 4.0
                let handHeight: CGFloat = 90.0

                // Saat Çerçevesi
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 20)

                // Saat Çizgileri
                ForEach(0..<24) { i in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: i % 6 == 0 ? 20 : 10)
                        .offset(y: -125)
                        .rotationEffect(.degrees(Double(i) * 15))
                }

                // Progress Bar (Oruç Süresi)
                Circle()
                    .trim(from: CGFloat(progressStartAngle / 360.0), to: CGFloat(progressStartAngle / 360.0) + CGFloat(elapsedTimePercentage))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: elapsedTimePercentage)

                // Akrep (Saat)
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: handWidth, height: handHeight)
                    .offset(y: -handHeight / 2)
                    .rotationEffect(currentHourAngle())

                // Saat Numaraları
                ForEach(0..<24) { i in
                    Text("\(i)")
                        .font(.system(size: i % 6 == 0 ? 18 : 14)) // Ana numaralar büyük, diğerleri küçük
                        .fontWeight(i % 6 == 0 ? .bold : .regular) // Ana numaralar bold
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(-Double(i) * 15))
                        .offset(x: 0, y: -150.0)
                        .rotationEffect(.degrees(Double(i) * 15))
                }
            }
            .frame(width: 250, height: 250)

            Spacer()

            // Oruç Aralığı Değiştirme Butonu
            Button(action: {
                showFastingIntervalPicker.toggle()
            }) {
                Text("Change Fasting Interval")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()

            // Oruç Başlat/Bitir Butonu
            Button(action: {
                isFasting ? endFasting() : startFasting()
            }) {
                Text(isFasting ? "End Fasting" : "Start Fasting")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFasting ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .background(Color("Background").ignoresSafeArea())
        .onAppear {
            updateTime()
            startTimerForClock()
        }
        .sheet(isPresented: $showFastingIntervalPicker) {
            FastingIntervalPickerView(selectedDuration: $fastingDuration)
        }
    }

    func startFasting() {
        fastingEndTime = Calendar.current.date(byAdding: .hour, value: fastingDuration, to: Date()) ?? Date()
        progressStartAngle = calculateCurrentAngle()
        isFasting = true
        startTimer()
    }

    func endFasting() {
        isFasting = false
        elapsedTimePercentage = 0.0
        progressStartAngle = 0.0
        timer?.invalidate()
        timer = nil
    }

    func updateTimer() {
        guard isFasting else { return }
        let totalDuration = Double(fastingDuration * 3600)
        let remaining = max(0, Int(fastingEndTime.timeIntervalSinceNow))
        let elapsed = totalDuration - Double(remaining)

        if remaining > 0 {
            elapsedTimePercentage = elapsed / totalDuration
        } else {
            elapsedTimePercentage = 1.0
            isFasting = false
            timer?.invalidate()
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimer()
        }
    }

    func currentHourAngle() -> Angle {
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        return .degrees(Double(hour) * 15 + Double(minute) / 4)
    }

    func calculateCurrentAngle() -> Double {
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        return Double(hour) * 15 + Double(minute) / 4
    }

    func updateTime() {
        currentTime = Date()
    }

    func startTimerForClock() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTime()
        }
    }
}

struct FastingIntervalPickerView: View {
    @Binding var selectedDuration: Int

    let intervals = [
        ("12:12", 12),
        ("16:8", 16),
        ("18:6", 18),
        ("20:4", 20)
    ]

    var body: some View {
        VStack {
            Text("Select Fasting Interval")
                .font(.headline)
                .padding()

            List(intervals, id: \.1) { interval in
                Button(action: {
                    selectedDuration = interval.1
                }) {
                    HStack {
                        Text(interval.0)
                            .font(.system(size: 18))
                            .padding()
                        Spacer()
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}




//MARK: Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
