//
//  LearnView.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/8/25.
//  Copyright © 2025 Skull Ninja Inc. All rights reserved.
//

import SwiftUI

struct SunSafetyTipsView: View {
    let tips: [SunTip] = [
        SunTip(icon: "sun.max.fill", text: "All skin tones need sunscreen. Anyone, no matter their skin tone, can get skin cancer."),
        SunTip(icon: "drop.fill", text: "Dermatologists recommend SPF 30 as the minimum daily protection."),
        SunTip(icon: "shield.lefthalf.fill", text: "Use a Broad Spectrum sunscreen to protect against both UVA and UVB rays."),
        SunTip(icon: "face.smiling.fill", text: "UVA rays cause aging, wrinkles, and age spots. UVB rays cause sunburn."),
        SunTip(icon: "sparkles", text: "Mineral sunscreens bounce UV rays off your skin to prevent radiation exposure."),
        SunTip(icon: "leaf.fill", text: "Seek shade midday—especially between 10 A.M. and 4 P.M."),
        SunTip(icon: "figure.pool.swim", text: "During vigorous activity like swimming, sunscreen may wear off after 40–80 minutes."),
        SunTip(icon: "cloud.sun.fill", text: "Up to 80% of UV rays pass through clouds. You can still get burned on cloudy days."),
        SunTip(icon: "thermometer.sun.fill", text: "At UV Index 9, you can burn in under 20 minutes. At Index 4, it takes about 50 minutes."),
        SunTip(icon: "person.fill.viewfinder", text: "Use the Shadow Rule: If your shadow is shorter than you, UV rays are strong."),
        SunTip(icon: "repeat.circle.fill", text: "We often apply too little sunscreen. Reapply after 20 minutes to ensure full coverage."),
        SunTip(icon: "baby.fill", text: "Sunburns in childhood greatly increase the risk of skin cancer later in life.")
    ]
    
    @State private var appearedTips: Set<UUID> = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("☀️ SUN SAFETY TIPS")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 10)

                    ForEach(tips.indices, id: \.self) { index in
                        let tip = tips[index]

                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: tip.icon)
                                .foregroundColor(.orange)
                                .font(.title3)
                                .frame(width: 24)

                            Text(tip.text)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                        .opacity(appearedTips.contains(tip.id) ? 1 : 0)
                        .scaleEffect(appearedTips.contains(tip.id) ? 1 : 0.9)
                        .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.05), value: appearedTips)
                        .onAppear {
                            appearedTips.insert(tip.id)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Sun Safety")
        }
    }
}

struct SunTip: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

