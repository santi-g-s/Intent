//
//  View+Extensions.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 22/11/2022.
//

import SwiftUI

extension View {
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
extension View{
    @ViewBuilder
        func bottomSheet<Content: View> (
            presentationDetents: Set<PresentationDetent>, isPresented: Binding<Bool>,
            dragIndicator: Visibility = .visible,
            sheetCornerRadius: CGFloat?,
            largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .large,
            isTransparentBG: Bool = false,
            interactiveDisabled: Bool = true,
            @ViewBuilder content: @escaping () ->Content, onDismiss: @escaping ()-> ()
        ) -> some View {
            self
                .sheet (isPresented: isPresented) {
                    onDismiss ()
                } content: {
                    content()
                        .presentationDetents(presentationDetents)
                        .presentationDragIndicator(dragIndicator)
                        .interactiveDismissDisabled(interactiveDisabled)
                        .onAppear {
                            guard let windows = UIApplication.shared.connectedScenes.first as?  UIWindowScene else { return }
                            
                            if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController {
                                
                                controller.presentingViewController?.view.tintAdjustmentMode = .normal

                                sheet.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                                sheet.preferredCornerRadius = sheetCornerRadius
                            } else {
                                print ("NO CONTROLLER FOUND")
                            }
                        }
                }
        }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
