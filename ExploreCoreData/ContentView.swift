//
//  ContentView.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/27/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Query(.all) var contacts: QueryResults<Contact>
    @Environment(\.dataStore) private var dataStore: DataStore

    var body: some View {
        NavigationView {
            List {
                TextField("Search", text: $contacts.searchString)
                ForEach(contacts) { contact in
                    NavigationLink {
                        Text(contact.displayName)
                            .font(.headline)
                    } label: {
                        Text(contact.displayName)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Contact", systemImage: "plus")
                    }
                }
            }
            Text("Select a contact")
        }
//        .onAppear {
//            contacts.searchString = .constant("G")
//        }
    }

    private func addItem() {
        withAnimation {
            let newContact = ManagedContact(context: dataStore.viewContext)
            newContact.id = UUID().uuidString
            newContact.givenName = ["John", "Angela", "Gordon", "Sally"].randomElement()
            newContact.familyName = ["Hawne", "Jordan", "Lightfoot", "Jones"].randomElement()

//            do {
                dataStore.viewContext.insert(newContact)
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                let contactID = contacts[offset].id
                let fetchRequest = ManagedContact.fetchRequest() as NSFetchRequest<ManagedContact>
                fetchRequest.predicate = NSPredicate(format: "id == %@", contactID)
                if let result = try? dataStore.viewContext.fetch(fetchRequest) {
                    for object in result {
                        dataStore.viewContext.delete(object)
                    }
                }
            }
            // Do not persist yet
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.dataStore, DataStore.shared)
    }
}
