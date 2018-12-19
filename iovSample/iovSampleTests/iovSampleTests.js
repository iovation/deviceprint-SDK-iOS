// Add a pass/fail convenience function.
UIALogger.logOkay = function logOkay(ok, testName) {
    if (ok) return this.logPass(testName);
    return this.logFail(testName);        
}

// Install alert handler to respond to submit notification.
UIATarget.onAlert = function onAlert(alert) {
    if (alert.name() != "Notification") return false;

    // Check the message for a successful 2xx submit.
    var testName = "UIKit Submit"
    UIALogger.logStart(testName);
    var msg = alert.scrollViews()[0].staticTexts()[1].value();
    UIALogger.logDebug('Response status: ' + msg);
    UIALogger.logOkay(/^2\d\d:/.test(msg), testName);

    // Okay!
    alert.buttons()["Okay"].tap();
    return true;
}


var target  = UIATarget.localTarget();
var app     = target.frontMostApp();
var window  = app.mainWindow();
var tabBar  = window.tabBar();
var bbRegex = /^0500(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$/;

// Set up a function to switch tabs (with tests).
tabBar.switchTo = function switchTo(tab) {
    var testName = "Select " + tab + " Tab";
    UIALogger.logStart(testName);
    if (this.selectedButton().name() != tab) {
        this.buttons()[tab].tap();
    }
    UIALogger.logPass(testName);
}

// Switch to thge UIKit tab.
tabBar.switchTo("UIKit");

// Set the URL.
UIALogger.logStart("Set URL");
urlField = window.textFields()[0].textFields()[0];
urlField.setValue("http://pdxdvbbxgast01.iovationnp.com/v1/bb/verify");
UIALogger.logPass("Set URL");

// Submit some blackboxes.
var go = window.buttons()["Go→"];

// Hit the “Go” button and wait for the alert.
go.tap();
app.alert();

// Validate the blackbox.
UIALogger.logOkay(bbRegex.test(window.textViews()[0].value()), "UIKit Blackbox");

// Test each of the web view tabs.
["UIWebView", "WebKit"].forEach(function(tab) {
    // Switch to thge web view tab.
    tabBar.switchTo(tab);

    // Grab the WebView, bb, and submit button.
    var testName = "Get " + tab + " fields";
    UIALogger.logStart(testName);
    var webView = window.scrollViews()[0].webViews()[0];
    var submit = webView.buttons()["Submit"];
    var bb     = webView.textFields()[3];
    UIALogger.logOkay(bb.isValid(), testName);

    // Make sure we have a blackbox.
    UIALogger.logOkay(bbRegex.test(bb.value()), tab + " Blackbox");

    // Submit and wait for the response.
    submit.tap();
    UIALogger.logPass("Submitted");

    // Wait for the submit to complete.
    testName = tab + " Request";
    UIALogger.logStart(testName);
    var json = webView.staticTexts().firstWithPredicate("name beginswith '{'");
    UIALogger.logDebug(json.name());
    UIALogger.logOkay(json.isValid(), testName);

    // Make sure it looks like the JSON we want.
    var body = eval('(' + json.name() + ')');
    UIALogger.logOkay(body["name"] == "MobileDeviceUser", tab + " response name");
    UIALogger.logOkay(bbRegex.test(body["blackbox"]), tab + " response blackbox");
    UIALogger.logDebug(json.name());
});
