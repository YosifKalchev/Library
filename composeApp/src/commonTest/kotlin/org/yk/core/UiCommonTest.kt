package org.yk.core

//import androidx.compose.ui.test.ExperimentalTestApi
//import androidx.compose.ui.test.assertTextEquals
//import androidx.compose.ui.test.onNodeWithTag
//import androidx.compose.ui.test.onNodeWithText
//import androidx.compose.ui.test.performClick
//import androidx.compose.ui.test.runComposeUiTest
//import org.yk.TestApp
//import kotlin.test.Test
//
//class UiCommonTest {
//
//    @OptIn(ExperimentalTestApi::class)
//    @Test
//    fun uiDemoTest() = runComposeUiTest {
//
//        setContent {
//            TestApp()
//        }
//
//        // Tests the declared UI with assertions and actions of the Compose Multiplatform testing API
//
//        onNodeWithTag("text").assertTextEquals("Hello")
//        onNodeWithText("Hello").assertExists()
//        onNodeWithText("Compose").assertDoesNotExist()
//        onNodeWithTag("button").performClick()
//        onNodeWithTag("text").assertTextEquals("Compose")
//        onNodeWithText("Compose").assertExists()
//        onNodeWithText("text").assertDoesNotExist()
//    }
//}