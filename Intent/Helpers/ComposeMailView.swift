//
//  ComposeMailView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/01/2023.
//

import AVFoundation
import Foundation
#if os(iOS)
import MessageUI
import UIKit
#endif

import SwiftUI

struct ComposeMailView<Content>: View where Content: View {
    #if os(iOS)
    @State var isShowingMailView = false
    @State var alertNoMail = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    #endif

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            #if os(iOS)
            Button(action: {
                MFMailComposeViewController.canSendMail() ? self.isShowingMailView.toggle() : self.alertNoMail.toggle()
            }) {
                content()
            }
            .buttonStyle(PlainButtonStyle())
            //            .disabled(!MFMailComposeViewController.canSendMail())
            .sheet(isPresented: $isShowingMailView, onDismiss: {
                // hideKeyboard()
            }) {
                MailView(result: self.$result)
            }
            .alert(isPresented: self.$alertNoMail) {
                Alert(title: Text("No email account is associated with this device. Please add an account to continue."))
            }
            #else
            Button(action: {
                let service = NSSharingService(named: NSSharingService.Name.composeEmail)

                service?.recipients = ["sumone.studios.ltd@gmail.com"]
                service?.perform(withItems: ["Test Mail body"])
            }) {
                content()
            }
            .buttonStyle(PlainButtonStyle())
            #endif
        }
    }
}

#if os(iOS)
struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients = ["support@thenoahapp.com"]
    var messageBody = ""

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>)
        {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?)
        {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)

            if result == .sent {
                AudioServicesPlayAlertSound(SystemSoundID(1001))
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setMessageBody(messageBody, isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_: MFMailComposeViewController,
                                context _: UIViewControllerRepresentableContext<MailView>) {}
}
#endif
