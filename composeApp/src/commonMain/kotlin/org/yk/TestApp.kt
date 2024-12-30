package org.yk

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material.Button
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun TestApp() {
    MaterialTheme {
        Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {

            var input by remember { mutableStateOf("Hello") }
            Text(
                text = input,
                modifier = Modifier.testTag("text")
            )
            Button(
                onClick = { input = if (input == "Hello") "Compose" else "Hello" },
                modifier = Modifier.testTag("button")
            ) {
                Text("Click me")
            }
        }
    }
}
