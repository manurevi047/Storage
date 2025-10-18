import SwiftUI

struct AuthView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("File Upload App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    if isSignUp {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                    }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        let success = isSignUp ? 
                            await supabaseManager.signUp(email: email, password: password, username: username) :
                            await supabaseManager.signIn(email: email, password: password)
                        
                        if !success {
                            showingAlert = true
                        }
                    }
                }) {
                    HStack {
                        if supabaseManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isSignUp ? "Sign Up" : "Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(supabaseManager.isLoading || email.isEmpty || password.isEmpty || (isSignUp && username.isEmpty))
                .padding(.horizontal)
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(supabaseManager.errorMessage ?? "An error occurred")
            }
        }
    }
}

#Preview {
    AuthView()
}