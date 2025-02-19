//
//  SearchFormView.swift
//  roboCaller
//  allows users to search for items
//  Created by Michelle Zheng on 2/2/25.
// 


import SwiftUI

struct SearchFormView: View {
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var selectedMoveSize: MoveSize = .small
    @State private var moveDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()

    enum MoveSize: String, CaseIterable {
        case small = "Small (1–10 small items)"
        case medium = "Medium (1–5 small items, 1–3 large items)"
        case large = "Large (5+ all large items)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search for quotes")
                .font(.title2)
                .padding(.top)

            Group {
                TextField("From", text: $fromLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("To", text: $toLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading) {
                Text("Size of Move:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Size of Move", selection: $selectedMoveSize) {
                    ForEach(MoveSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

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

            HStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()

                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }

            Spacer()

            NavigationLink(destination: QuoteResultsView(
                fromLocation: fromLocation,
                toLocation: toLocation,
                items: moveDescription,
                availability: "\(selectedDate), \(selectedTime)",
                quotes: [] // Pass actual quotes here
            )) {
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
    }
}

struct SearchFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchFormView()
        }
    }
}
