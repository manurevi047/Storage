import SwiftUI

struct ProfileView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var isPremium = false
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(supabaseManager.currentUser?.email ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(supabaseManager.currentUser?.userMetadata["username"]?.stringValue ?? "No username")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Premium Status Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: isPremium ? "crown.fill" : "crown")
                            .foregroundColor(isPremium ? .yellow : .gray)
                        
                        Text(isPremium ? "Premium User" : "Free User")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(isPremium ? 
                         "You have access to all premium features" : 
                         "Upgrade to premium for unlimited storage and advanced features")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // User Info
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "User ID", value: supabaseManager.currentUser?.id.uuidString ?? "Unknown")
                    InfoRow(title: "Email Verified", value: supabaseManager.currentUser?.emailConfirmedAt != nil ? "Yes" : "No")
                    InfoRow(title: "Created", value: supabaseManager.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkPremiumStatus()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await supabaseManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func checkPremiumStatus() {
        isLoading = true
        Task {
            let premiumStatus = await supabaseManager.checkPremiumStatus()
            await MainActor.run {
                self.isPremium = premiumStatus
                self.isLoading = false
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
}