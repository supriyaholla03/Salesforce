@isTest
private class Draup_PostInstallScriptTest {
    static testMethod void installTest()
    {
        Draup_PostInstallScript postinstall = new Draup_PostInstallScript();
        Test.testInstall(postinstall, new Version(1, 0), true);
    }
}