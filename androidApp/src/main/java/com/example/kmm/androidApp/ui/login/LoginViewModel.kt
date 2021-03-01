package com.example.kmm.androidApp.ui.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.kmm.androidApp.R

import com.example.kmm.shared.data.LoginRepository
import com.example.kmm.shared.data.Result


import com.example.kmm.shared.data.LoginDataValidator
import com.example.kmm.shared.data.LoginDataValidator.Result.*

class LoginViewModel(private val loginRepository: LoginRepository, private val dataValidator: LoginDataValidator) : ViewModel() {

    private val _loginForm = MutableLiveData<LoginFormState>()
    val loginFormState: LiveData<LoginFormState> = _loginForm

    private val _loginResult = MutableLiveData<LoginResult>()
    val loginResult: LiveData<LoginResult> = _loginResult

    fun login(username: String, password: String) {
        // can be launched in a separate asynchronous job
        val result = loginRepository.login(username, password)

        if (result is Result.Success) {
            _loginResult.value = LoginResult(success = LoggedInUserView(displayName = result.data.displayName))
        } else {
            _loginResult.value = LoginResult(error = R.string.login_failed)
        }
    }

    fun loginDataChanged(username: String, password: String) {
        _loginForm.value = LoginFormState(
            usernameError = (dataValidator.checkUsername(username) as? Error)?.message,
            passwordError = (dataValidator.checkPassword(password) as? Error)?.message
        )
    }
}