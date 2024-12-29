package org.yk

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform