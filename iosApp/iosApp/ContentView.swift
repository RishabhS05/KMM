
import SwiftUI
import shared

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    @ObservedObject var viewModel: ContentView.ViewModel

                    
    var body: some View {
        NavigationView {
        VStack(spacing: 15.0) {
            ValidatedTextField(titleKey: "Username", secured: false, text: $username, errorMessage: viewModel.formState.usernameError,
                               onChange: {
                viewModel.loginDataChanged(username: username, password: password)
                               })
            ValidatedTextField(titleKey: "Password", secured: true, text: $password, errorMessage: viewModel.formState.passwordError, onChange: {
                viewModel.loginDataChanged(username: username, password: password)
            })
                        NavigationLink(destination: SecondView()) {
                                Text("login")
                                .frame(minWidth: 0, maxWidth: 300)
                                .padding()
                                .foregroundColor(.blue)
                                .font(.title)
                        }
                      .disabled(!viewModel.formState.isDataValid || (username.isEmpty && password.isEmpty))

        }.padding(.all).foregroundColor(Color.blue).font(Font.system(size: 20, weight: .medium, design: .serif))
    }
    }
}

struct ValidatedTextField: View {
    let titleKey: String
    let secured: Bool
    @Binding var text: String
    let errorMessage: String?
    let onChange: () -> ()

    @ViewBuilder var textField: some View {
        if secured {
            SecureField(titleKey, text: $text)
        }  else {
            TextField(titleKey, text: $text)
        }
    }

    var body: some View {

        ZStack {
            textField
            .font(Font.system(size: 15, weight: .medium, design: .serif))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
//                 .onChange(of: text) { _ in
//                     onChange()
//                 }
            if let errorMessage = errorMessage {
                HStack {
                    Spacer()
                    FieldTextErrorHint(error: errorMessage)
                }.padding(.horizontal, 5)
            }
        }
    }
}

struct FieldTextErrorHint: View {
    let error: String
    @State private var showingAlert = false

    var body: some View {
        Button(action: { self.showingAlert = true }) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("Got it!")))
        }
    }
}

extension ContentView {

    struct LoginFormState {
        let usernameError: String?
        let passwordError: String?
        var isDataValid: Bool {
            get { return usernameError == nil && passwordError == nil }
        }
    }

    class ViewModel: ObservableObject {
        @Published var formState = LoginFormState(usernameError: nil, passwordError: nil)

        let loginValidator: LoginDataValidator
        let loginRepository: LoginRepository

        init(loginRepository: LoginRepository, loginValidator: LoginDataValidator) {
            self.loginRepository = loginRepository
            self.loginValidator = loginValidator
        }

        func login(username: String, password: String) {
            if let result = loginRepository.login(username: username, password: password) as? ResultSuccess  {
                print("Successful login. Welcome, \(result.data.displayName)")
            } else {
                print("Error while logging in")
            }
        }

        func loginDataChanged(username: String, password: String) {
            formState = LoginFormState(
                usernameError: (loginValidator.checkUsername(username: username) as? LoginDataValidator.ResultError)?.message,
                passwordError: (loginValidator.checkPassword(password: password) as? LoginDataValidator.ResultError)?.message)
        }
    }
}
struct SecondView: View {
    var body: some View {
        ZStack {
            Text("Hello,\(Platform().platform)")
            .font(.largeTitle)
            .fontWeight(.medium)
            .foregroundColor(Color.blue)
    }.navigationBarBackButtonHidden(true)
    }
}
struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}

