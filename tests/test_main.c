#include "unity.h"

// Example function to test
int add(int a, int b) {
    return a + b;
}

void test_addition(void) {
    TEST_ASSERT_EQUAL_INT(5, add(2,3));
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_addition);
    return UNITY_END();
}
