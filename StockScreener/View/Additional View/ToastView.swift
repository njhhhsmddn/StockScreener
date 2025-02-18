//
//  ToastView.swift
//  StockScreener
//
//  Created by Najihah on 15/02/2025.
//

import SwiftUI

struct ToastView: View {
    
    let dataModel: ToastDataModel
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: dataModel.image)
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text(dataModel.title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.customGray)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            )
            .onTapGesture {
                withAnimation {
                    self.show = false
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.show = false
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width / 1.5) 
    }

}

struct ToastModifier : ViewModifier {
    @Binding var show: Bool
    
    let toastView: ToastView
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if show {
                    toastView
                }
            }
        )
    }
}
