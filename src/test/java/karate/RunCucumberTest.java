package karate;

import com.intuit.karate.junit5.Karate;

public class RunCucumberTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run().relativeTo(getClass());
    }
}
