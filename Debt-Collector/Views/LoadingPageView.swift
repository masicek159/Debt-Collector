//
//  LoadingPageView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 12/2/23.
//

import SwiftUI

struct LoadingPageView: View {
    @State private var loadingProgress: Double = 0.7
    
    var body: some View {
        ZStack {
            Color.black.opacity(loadingProgress)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Loading")
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
