//
//  View.swift
//  StockScreener
//
//  Created by Najihah on 15/02/2025.
//
import SwiftUI

extension View {
    func toast(toastView: ToastView, show: Binding<Bool>) -> some View {
        self.modifier(ToastModifier.init(show: show, toastView: toastView))
    }
}
