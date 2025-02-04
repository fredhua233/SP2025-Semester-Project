//
//  SearchFormView.swift
//  roboCaller
//  allows users to search for items
//  Created by Michelle Zheng on 2/2/25.
// ,,,,,,,,,,,,


import SwiftUI
//this is for repoooo000
struct SearchFormView: View {
    // MARK: - State variables
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    
    // For dropdown Picker
    enum MoveSize: String, CaseIterable {
        case small = "Small (1–10 small items)"
        case medium = "Medium (1–5 small, 1–3 large)"
        case large = "Large (1–10 all larger items)"
    }
    @State private var selectedMoveSize: MoveSize = .small
    
    // For description (limit 40 chars)
    @State private var moveDescription: String = ""
    
    // For date/time
    @State private var selectedDate: Date = Date()    // defaults to "now"
    @State private var selectedTime: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Title
            Text("Search for quotes")
                .font(.title2)
                .padding(.top)
            
            // "From" and "To" text fields
            Group {
                TextField("From", text: $fromLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("To", text: $toLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Picker for "size of move"
            VStack(alignment: .leading) {
                Text("Size of Move:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Size of Move", selection: $selectedMoveSize) {
                    ForEach(MoveSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(MenuPickerStyle())  // or .segmented, .wheel, etc.
            }
            
            // Large text box for description
            VStack(alignment: .leading) {
                Text("Describe your items to be moved (max 100 chars):")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $moveDescription)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: moveDescription) { oldValue, newValue in
                        if newValue.count > 100 {
                            moveDescription = String(newValue.prefix(100))
                        }
                    }

            }
            
            //Date and time pickers side-by-side
            HStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden() // hides the label to keep it minimal
                
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            
            Spacer()
            
            //search button
            Button(action: {
                // TODO: Implement the actual search call to your backend
                // e.g., send fromLocation, toLocation, selectedMoveSize, moveDescription, selectedDate, selectedTime
                // to your FastAPI endpoint
                print("Perform search with: \(fromLocation), \(toLocation), \(selectedMoveSize.rawValue)")
            }) {
                Text("Search")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // if you don't want a "Back" in nav
    }
}

struct SearchFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchFormView()
        }
    }
}


