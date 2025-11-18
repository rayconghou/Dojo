//
//  EditProfileView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//  Edit Profile Modal
//

import SwiftUI

// MARK: - Blue Gradient Component
struct BlueGradientButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                            Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct EditProfileView: View {
    @Binding var isPresented: Bool
    @State private var username: String = "@jameswang"
    @State private var name: String = "James Wang"
    @State private var phoneNumber: String = "+1 (601) 736-5682"
    @State private var country: String = "United States"
    @State private var showCountryPicker = false
    
    let countries = ["United States", "Canada", "United Kingdom", "Germany", "France", "Japan", "Australia", "Brazil", "India", "China"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with diagonal pattern
                Color(hex: "050715")
                    .edgesIgnoringSafeArea(.all)
                
                // Diagonal line pattern
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let spacing: CGFloat = 20
                        
                        for i in stride(from: -height, through: width + height, by: spacing) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + height, y: height))
                        }
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Picture Section
                        VStack(spacing: 20) {
                            ZStack {
                                // Profile Picture
                                Image("Profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                // Camera icon overlay at bottom right
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            // Transparent overlay background
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.black.opacity(0.4))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "camera")
                                                .foregroundColor(.white)
                                                .font(.system(size: 18, weight: .medium))
                                        }
                                        .offset(x: -4, y: 4)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 24) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                
                                TextField("Username", text: $username)
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "050715"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                
                                TextField("Name", text: $name)
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "050715"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Phone Number Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Phone Number")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                
                                TextField("Phone Number", text: $phoneNumber)
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .keyboardType(.phonePad)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "050715"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Country Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Country")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    showCountryPicker = true
                                }) {
                                    HStack {
                                        Text(country)
                                            .font(.custom("Satoshi-Bold", size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "050715"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: {
                            // TODO: Save profile data
                            isPresented = false
                        }) {
                            Text("Save Profile")
                                .font(.custom("Satoshi-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                            Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $country, countries: countries)
        }
    }
}

struct CountryPickerView: View {
    @Binding var selectedCountry: String
    let countries: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(countries, id: \.self) { country in
                Button(action: {
                    selectedCountry = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(country)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCountry == country {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Preview
struct EditProfileView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        EditProfileView(isPresented: $isPresented)
    }
}
