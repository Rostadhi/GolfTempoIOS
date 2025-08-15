//
//  InfoView.swift
//  GolfTempo
//
//  Created by rostadhi akbar on 01/08/25.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("About Coach Akbar")
                .font(.title)
                .bold()

            Text("""
Hi! I’m Coach Akbar 👋

I'm a certified golf coach with years of experience helping players improve their swing tempo, timing, and performance on the course.

This app is a tool I built for myself and other golfers who want to train rhythm just like in competition settings.

⛳ Let’s keep it simple. Let’s play better golf.
""")
                .multilineTextAlignment(.leading)
                .padding()

            Link(destination: URL(string: "https://saweria.co/coachakbar")!) {
                Text("Support Me to Compete")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
