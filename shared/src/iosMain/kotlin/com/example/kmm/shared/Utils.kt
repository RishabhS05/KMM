package com.example.kmm.shared

import platform.Foundation.NSUUID

actual fun randomUUID(): String = NSUUID().UUIDString()
