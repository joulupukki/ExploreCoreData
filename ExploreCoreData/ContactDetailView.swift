//
//  ContactDetailView.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/31/23.
//

import SwiftUI

struct ContactDetailView: View {
    @Query(.all) private var contacts: QueryResults<Contact>
    var contactID: String
    private var contact: Contact? {
        contacts.first
    }
    var body: some View {
        VStack {
            HStack {
                Text("First Name")
                    .bold()
                Text(contact?.givenName ?? "Unknown")
            }
            HStack {
                Text("Last Name")
                    .bold()
                Text(contact?.familyName ?? "Unknown")
            }
        }
        .onAppear {
            $contacts.wrappedValue.contactID = contactID
        }
    }
}
