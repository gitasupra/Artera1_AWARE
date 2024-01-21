//
//  ContactPickerButton.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI
import ContactsUI

struct ContactPickerButton<Label: View>: UIViewControllerRepresentable {
    class Coordinator: NSObject, CNContactPickerDelegate {
        var onCancel: () -> Void
        var viewController: UIViewController = .init()
        var picker = CNContactPickerViewController()
        
        @Binding var contact: CNContact?
        @Binding var phoneNumber: String?
        
        init(contact: Binding<CNContact?>, phoneNumber: Binding<String?>, onCancel: @escaping () -> Void, @ViewBuilder content: @escaping () -> Label) {
            self._contact = contact
            self._phoneNumber = phoneNumber
            self.onCancel = onCancel
            super.init()
            let button = Button<Label>(action: showContactPicker, label: content)
            
            let hostingController: UIHostingController<Button<Label>> = UIHostingController(rootView: button)
            
            hostingController.view?.backgroundColor = .clear
            hostingController.view?.sizeToFit()
            
            (hostingController.view?.frame).map {
                hostingController.view!.widthAnchor.constraint(equalToConstant: $0.width).isActive = true
                hostingController.view!.heightAnchor.constraint(equalToConstant: $0.height).isActive = true
                viewController.preferredContentSize = $0.size
            }
                
            hostingController.willMove(toParent: viewController)
            viewController.addChild(hostingController)
            viewController.view.addSubview(hostingController.view)
            picker.delegate = self
        }
        
        func showContactPicker() {
            viewController.present(picker, animated: true)
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel()
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            self.contact = contact
            self.phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        }

        func makeUIViewController() -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ContactPickerButton>) {
        }
    }
    
    @Binding var contact: CNContact?
    @Binding var phoneNumber: String?
    
    @ViewBuilder
    var content: () -> Label

    var onCancel: () -> Void
    
    init(contact: Binding<CNContact?>, phoneNumber: Binding<String?>, onCancel: @escaping () -> Void, @ViewBuilder content: @escaping () -> Label) {
        self._contact = contact
        self._phoneNumber = phoneNumber
        self.onCancel = onCancel
        self.content = content
    }
    
    func makeCoordinator() -> Coordinator {
        .init(contact: $contact, phoneNumber: $phoneNumber, onCancel: onCancel, content: content)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.makeUIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.updateUIViewController(uiViewController, context: context)
    }
}
