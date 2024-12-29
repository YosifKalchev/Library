import assertk.assertThat
import assertk.assertions.isEqualTo
import org.yk.core.getInitials
import kotlin.test.Test

class GetInitialsKtTest {

    @Test
    fun testGetInitials() {
        val fullName = "Yosif Kalchev"

        assertThat(getInitials(fullName)).isEqualTo("YK")
    }
}