@isTest
private class DescribePackageCustomLabelsTest {
    static testMethod void describeLabelLsTest(){
        Boolean TestOk = DescribePackageCustomLabels.describeLabelLs();
        system.assert(TestOk == true);
    }
}